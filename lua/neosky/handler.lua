local log = require("plenary.log")
local api = require("image")
local utils = require("neosky.utils")
local images = require("neosky.image")
local M = {}

-- TODO: Move m.image_data to m.posts.image_Data and m.posts to m.posts.text
M.buffer = require("neosky.buffer")
M.FeedItem = require("neosky.feed_item")

local namespace = "neosky"

local function display_posts(bufnr, cursor_pos)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
	vim.api.nvim_set_current_buf(bufnr)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, M.posts)
	-- TODO: would only work with kitty terminal and similar, seems complex though
	-- awaiting better solution
	-- display_img(bufnr, M.img_data, 1, 1)

	utils.set_current_cursor_pos(0, cursor_pos)
end

local function append_to_posts(prefix, config, item, reverse, current_line, bufnr)
	local header = item:getHeader()
	utils.insert_line(M.posts, prefix .. header, reverse)
	M.line_to_post_map[current_line] = item.cid
	current_line = current_line + 1

	local text = item:getText()
	for line in text:gmatch("([^\n]*)\n?") do
		utils.insert_line(M.posts, prefix .. line, reverse)
		M.line_to_post_map[current_line] = item.cid
		current_line = current_line + 1
	end

	if config.images ~= "nil" and item.embeds then
		local total_width = 1
		for _, img in ipairs(item.embeds) do
			-- local extension = img.thumb:match("^.+@(%w+)$")
			table.insert(M.img_ctx.img_data, {
				url = img.thumb,
				-- width = img.width,
				-- height = img.height,
				range = {
					start_row = current_line,
					start_col = total_width,
					end_row = current_line + 1,
				},
			})
			if img.width then
				total_width = total_width + img.width
			end
			--line = current_line, -- adjust this based on where you want the image
			--col = i * 100, -- adjust this based on where you want the image
			--width = img.width,
			--height = img.height,
			--thumb = img.thumb,
			M.line_to_post_map[current_line] = item.cid
			utils.insert_line(M.posts, prefix .. img.thumb, reverse)
			current_line = current_line + 1
		end
	end

	local footer = item:getFooter()
	utils.insert_line(M.posts, prefix .. footer, reverse)
	M.line_to_post_map[current_line] = item.cid
	current_line = current_line + 1
	utils.insert_line(M.posts, "", reverse)
	utils.insert_line(M.posts, "", reverse)
	current_line = current_line + 2

	return current_line
end

M.update_buffer_threaded = function(config, content, reverse, bufnr)
	local current_cursor_pos = utils.get_current_cursor_pos()

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
		utils.insert_line(M.posts, "")
		utils.insert_line(M.posts, "")
		current_line = current_line + 2
		-- Add actual post details
		current_line = append_to_posts(prefix, config, feedItem, reverse, current_line, bufnr)
		utils.insert_line(M.posts, M.buffer.create_separator_line(config), reverse)
		current_line = current_line + 1
	end
	display_posts(bufnr, current_cursor_pos)
	M.img_ctx.window_id = vim.fn.bufwinid(bufnr)
	images.display_img(M.img_ctx)
end

M.update_buffer_flat = function(config, content, reverse, bufnr)
	local current_cursor_pos = utils.get_current_cursor_pos()
	local current_line = 1
	local prefix = ""
	for _, item in ipairs(content) do
		local feedItem = M.FeedItem.new(item)
		current_line = append_to_posts(prefix, config, feedItem, reverse, current_line, bufnr)
		utils.insert_line(M.posts, M.buffer.create_separator_line(config), reverse)
		current_line = current_line + 1
	end

	display_posts(bufnr, current_cursor_pos)
	M.img_ctx.window_id = vim.fn.bufwinid(bufnr)
	images.display_img(M.img_ctx)
end

M.update_buffer = function(config, content, reverse)
	M.posts = {}
	M.line_to_post_map = {}

	local bufnr = M.buffer._find_or_create_buffer(config)

	local win = vim.fn.bufwinid(bufnr)
	M.img_ctx = {
		api = api,
		window_id = win,
		buffer_id = bufnr,
		namespace = namespace,
		img_data = {},
	}

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
	local last_cid = M.line_to_post_map[utils.get_last_item_from_table(M.line_to_post_map)]
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
	local first_cid = M.line_to_post_map[utils.get_first_item_from_table(M.line_to_post_map)]
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
