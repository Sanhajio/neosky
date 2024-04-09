local log = require("plenary.log")
local M = {}

M.buffer = require("neosky.buffer")
M.FeedItem = require("neosky.feed_item")

local function get_last_item_from_table(tbl)
	local max_key = nil

	for key, _ in pairs(tbl) do
		if type(key) == "number" and (max_key == nil or key > max_key) then
			max_key = key
		end
	end

	return max_key
end

local function get_first_item_from_table(tbl)
	local min_key = nil

	for key, _ in pairs(tbl) do
		if type(key) == "number" and (min_key == nil or key < min_key) then
			min_key = key
		end
	end

	return min_key
end

local function get_current_cursor_pos()
	local current_cursor_pos = vim.api.nvim_win_get_cursor(0)
	return current_cursor_pos
end

local function set_current_cursor_pos(bufnr, cursor_pos)
	local current_cursor_pos = pcall(vim.api.nvim_win_set_cursor, 0, cursor_pos)
end

local function insert_line(t, line, reverse)
	if reverse then
		table.insert(t, 1, line)
	else
		table.insert(t, line)
	end
end

local function display_posts(bufnr, cursor_pos)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})

	vim.api.nvim_set_current_buf(bufnr)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, M.posts)

	set_current_cursor_pos(0, cursor_pos)
end

local function append_to_posts(prefix, config, item, reverse, current_line)
	local header = item:getHeader()
	insert_line(M.posts, prefix .. header, reverse)
	M.line_to_post_map[current_line] = item.cid
	current_line = current_line + 1

	local text = item:getText()
	for line in text:gmatch("([^\n]*)\n?") do
		insert_line(M.posts, prefix .. line, reverse)
		M.line_to_post_map[current_line] = item.cid
		current_line = current_line + 1
	end

	local footer = item:getFooter()
	insert_line(M.posts, prefix .. footer, reverse)
	M.line_to_post_map[current_line] = item.cid
	insert_line(M.posts, "", reverse)
	insert_line(M.posts, "", reverse)
	current_line = current_line + 2

	return current_line
end

M.update_buffer_threaded = function(config, content, reverse)
	local bufnr = M.buffer._find_or_create_buffer(config)
	local current_cursor_pos = get_current_cursor_pos()

	local current_line = 1
	for _, item in ipairs(content) do
		local prefix = ""
		local feedItem = M.FeedItem.new(item)

		if feedItem.isReply then
			-- If the rootPost is different than the parent post display the root post
			if feedItem.parentPost.cid ~= feedItem.rootPost.cid then
				if feedItem.rootPost then
					local rootItem = M.FeedItem.from_post_data(feedItem.rootPost)
					current_line = append_to_posts(prefix, config, rootItem, reverse, current_line)
				end
			end

			-- Add the parent view for thread context
			if feedItem.parentPost then
				prefix = prefix .. "\t\t"
				local parentItem = M.FeedItem.from_post_data(feedItem.parentPost)
				current_line = append_to_posts(prefix, config, parentItem, reverse, current_line)
			end
		end

		prefix = prefix .. "\t\t"
		insert_line(M.posts, "")
		insert_line(M.posts, "")
		current_line = current_line + 2
		-- Add actual post details
		current_line = append_to_posts(prefix, config, feedItem, reverse, current_line)
		insert_line(M.posts, M.buffer.create_separator_line(config), reverse)
		current_line = current_line + 1
	end
	display_posts(bufnr, current_cursor_pos)
end

M.update_buffer_flat = function(config, content, reverse)
	local bufnr = M.buffer._find_or_create_buffer(config)
	local current_cursor_pos = get_current_cursor_pos()
	local current_line = 1
	local prefix = ""
	for _, item in ipairs(content) do
		local feedItem = M.FeedItem.new(item)
		current_line = append_to_posts(prefix, config, feedItem, reverse, current_line)
		insert_line(M.posts, M.buffer.create_separator_line(config), reverse)
		current_line = current_line + 1
	end

	display_posts(bufnr, current_cursor_pos)
end

M.update_buffer = function(config, content, reverse)
	M.posts = {}
	M.line_to_post_map = {}

	if config.view == "threaded" then
		M.update_buffer_threaded(config, content, reverse)
	elseif config.view == "flat" then
		M.update_buffer_flat(config, content, reverse)
	else
		log.error("Unsupported view type")
	end
end

M.read = function(config, executor)
	local feed_json = vim.fn.rpcrequest(executor.job_id, "read")
	-- log.info(string.format("retrieving feed_json: <%s>", feed_json))
	local content = vim.fn.json_decode(feed_json)
	-- log.info(string.format("retrieving feed_json: <%s>", vim.inspect(content)))handl
	if content == nil then
		return
	end
	for _, v in ipairs(content) do
		if v ~= nil then
			log.info(string.format("content: <%s>", vim.inspect(content)))
			log.info(string.format("getting embeds: <%s>", vim.inspect(M.FeedItem.new(v):getEmbeddedImages())))
		end
	end

	if content == nil then
		log.error("No content to display")
		return
	end

	-- M.update_buffer(config, content)
end

M.update_feed = function(executor)
	log.info("Calling Update feed")
	local answer = vim.rpcnotify(executor.job_id, "update")
	log.info(string.format("answer returns: <%s>", answer))
end

M.fetch_more = function(config, executor)
	log.info("Calling fetch more items")
	local bufnr = M.buffer._find_or_create_buffer(config)
	local total_lines = vim.api.nvim_buf_line_count(0)
	vim.api.nvim_buf_set_lines(bufnr, total_lines, -1, false, { "Loading More ..." })
	local last_cid = M.line_to_post_map[get_last_item_from_table(M.line_to_post_map)]
	local answer = vim.rpcnotify(executor.job_id, "more", last_cid)
	log.info(string.format("answer returns: <%s>", answer))
	vim.defer_fn(function()
		M.read(config, executor)
	end, 6000)
end

M.refresh_timeline = function(config, executor)
	log.info("Calling fetch newer items")
	local bufnr = M.buffer._find_or_create_buffer(config)
	vim.api.nvim_buf_set_lines(
		bufnr,
		0,
		0,
		false,
		{ "Refreshing Timeline ...", M.buffer.create_separator_line(config) }
	)
	local first_cid = M.line_to_post_map[get_first_item_from_table(M.line_to_post_map)]
	local answer = vim.rpcnotify(executor.job_id, "update", first_cid)
	log.info(string.format("answer returns: <%s>", answer))
	vim.defer_fn(function()
		M.read(config, executor)
	end, 6000)
end

M.post = function(executor, content)
	log.info(string.format("posting %s", content))
	local answer = vim.rpcnotify(executor.job_id, "post", content)
	log.info(string.format("answer returns: <%s>", answer))
end

return M
