local log = require("plenary.log")
local hologram = require("hologram.image")
local M = {}

-- TODO: Move m.image_data to m.posts.image_Data and m.posts to m.posts.text
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

local function display_img(bufnr, img_data, line, col)
	log.info(bufnr, img_data, line, col)
	for _, img in ipairs(img_data) do
		local image = hologram:new(img.path, {
			data_width = 360,
			data_height = 360,
		})
		image:display(line, col, bufnr, {})
		break
	end
end

local function display_posts(bufnr, cursor_pos)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
	vim.api.nvim_set_current_buf(bufnr)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, M.posts)
	-- TODO: would only work with kitty terminal and similar, seems complex though
	-- awaiting better solution
	-- display_img(bufnr, M.img_data, 1, 1)

	set_current_cursor_pos(0, cursor_pos)
end

local function append_to_posts(prefix, config, item, reverse, current_line, bufnr)
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
	local win = vim.fn.bufwinid(bufnr)
	local info = vim.fn.getwininfo(win)[1]
	log.info("win")
	log.info(win, info)
	if config.images ~= "nil" and item.embeds then
		for i, img in ipairs(item.embeds) do
			local extension = img.thumb:match("^.+@(%w+)$")
			local local_img_path = string.format("%s.%s", os.tmpname(), extension)
			os.execute(string.format("wget %s -O %s -o /dev/null", img.thumb, local_img_path))
			table.insert(M.img_data, {
				path = local_img_path,
				line = current_line, -- adjust this based on where you want the image
				col = i * 100, -- adjust this based on where you want the image
				width = img.width,
				height = img.height,
			})
			-- TODO: adjut this accordingly, all the lines should have this
			current_line = current_line + 15
			M.line_to_post_map[current_line] = item.cid
			current_line = current_line + 1
		end
	end

	local footer = item:getFooter()
	insert_line(M.posts, prefix .. footer, reverse)
	M.line_to_post_map[current_line] = item.cid
	insert_line(M.posts, "", reverse)
	insert_line(M.posts, "", reverse)
	current_line = current_line + 2

	return current_line
end

M.update_buffer_threaded = function(config, content, reverse, bufnr)
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
					current_line = append_to_posts(prefix, config, rootItem, reverse, current_line, bufnr)
				end
			end

			-- Add the parent view for thread context
			if feedItem.parentPost then
				prefix = prefix .. "\t\t"
				local parentItem = M.FeedItem.from_post_data(feedItem.parentPost)
				current_line = append_to_posts(prefix, config, parentItem, reverse, current_line, bufnr)
			end
		end

		prefix = prefix .. "\t\t"
		insert_line(M.posts, "")
		insert_line(M.posts, "")
		current_line = current_line + 2
		-- Add actual post details
		current_line = append_to_posts(prefix, config, feedItem, reverse, current_line, bufnr)
		insert_line(M.posts, M.buffer.create_separator_line(config), reverse)
		current_line = current_line + 1
	end
	display_posts(bufnr, current_cursor_pos)
end

M.update_buffer_flat = function(config, content, reverse, bufnr)
	local current_cursor_pos = get_current_cursor_pos()
	local current_line = 1
	local prefix = ""
	for _, item in ipairs(content) do
		local feedItem = M.FeedItem.new(item)
		current_line = append_to_posts(prefix, config, feedItem, reverse, current_line, bufnr)
		insert_line(M.posts, M.buffer.create_separator_line(config), reverse)
		current_line = current_line + 1
	end

	display_posts(bufnr, current_cursor_pos)
end

M.update_buffer = function(config, content, reverse)
	M.posts = {}
	M.img_data = {}
	M.line_to_post_map = {}

	local bufnr = M.buffer._find_or_create_buffer(config)

	-- for image handling
	local empty_lines = {}
	for _ = 1, 1000 do
		table.insert(empty_lines, "")
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, empty_lines)
	vim.api.nvim_set_current_buf(bufnr)
	if config.view == "threaded" then
		M.update_buffer_threaded(config, content, reverse, bufnr)
	elseif config.view == "flat" then
		M.update_buffer_flat(config, content, reverse, bufnr)
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
		log.error("No content to display")
		return
	end

	M.update_buffer(config, content)
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
