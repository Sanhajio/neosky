local log = require("plenary.log")
local M = {}

M.buffer = require("neosky.buffer")
M.FeedItem = require("neosky.feed_item")

M.update_buffer_threaded = function(config, content)
	local bufnr = M.buffer._find_or_create_buffer(config)
	M.posts = {}
	M.line_to_post_map = {}

	local current_line = 1
	for _, item in ipairs(content) do
		local prefix = ""
		local feedItem = M.FeedItem.new(item)

		-- Display root and parent before the actual reply
		if feedItem.isReply then
			-- Add parent post details
			if feedItem.parentPost.cid ~= feedItem.rootPost.cid then
				prefix = prefix .. "\t\t"
				if feedItem.rootPost then
					local rootItem = M.FeedItem.from_post_data(feedItem.rootPost)
					local root_header = rootItem:getHeader()
					table.insert(M.posts, root_header)
					M.line_to_post_map[current_line] = rootItem.cid
					current_line = current_line + 1

					local root_text = rootItem:getText()
					for line in root_text:gmatch("([^\n]*)\n?") do
						table.insert(M.posts, line)
						M.line_to_post_map[current_line] = rootItem.cid
						current_line = current_line + 1
					end

					local root_footer = rootItem:getFooter()
					table.insert(M.posts, root_footer)
					M.line_to_post_map[current_line] = rootItem.cid
					table.insert(M.posts, "")
					table.insert(M.posts, "")
					current_line = current_line + 3
				end
			end

			if feedItem.parentPost then
				prefix = prefix .. "\t\t"
				local parentItem = M.FeedItem.from_post_data(feedItem.parentPost)
				local parent_header = parentItem:getHeader()
				table.insert(M.posts, prefix .. parent_header)
				M.line_to_post_map[current_line] = parentItem.cid
				current_line = current_line + 1

				local parent_text = parentItem:getText()
				for line in parent_text:gmatch("([^\n]*)\n?") do
					table.insert(M.posts, prefix .. line)
					M.line_to_post_map[current_line] = parentItem.cid
					current_line = current_line + 1
				end

				local parent_footer = parentItem:getFooter()
				table.insert(M.posts, prefix .. parent_footer)
				M.line_to_post_map[current_line] = parentItem.cid
				current_line = current_line + 1
			end
		end

		prefix = prefix .. "\t\t"
		table.insert(M.posts, "")
		table.insert(M.posts, "")
		current_line = current_line + 2
		-- Add actual post details
		local post_header = feedItem:getHeader()
		table.insert(M.posts, prefix .. post_header)
		M.line_to_post_map[current_line] = feedItem.cid
		current_line = current_line + 1

		local post_text = feedItem:getText()
		for line in post_text:gmatch("([^\n]*)\n?") do
			table.insert(M.posts, prefix .. line)
			M.line_to_post_map[current_line] = feedItem.cid
			current_line = current_line + 1
		end

		local post_footer = feedItem:getFooter()
		table.insert(M.posts, prefix .. post_footer)
		M.line_to_post_map[current_line] = feedItem.cid
		current_line = current_line + 1

		table.insert(M.posts, M.buffer.create_separator_line(config))
		current_line = current_line + 1
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, M.posts)
	vim.api.nvim_set_current_buf(bufnr)
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

M.update_buffer_flat = function(config, content)
	local bufnr = M.buffer._find_or_create_buffer(config)
	M.posts = {}
	M.line_to_post_map = {}

	local current_line = 1
	for _, item in ipairs(content) do
		local feedItem = M.FeedItem.new(item)

		local post_header = feedItem:getHeader()
		table.insert(M.posts, post_header)
		M.line_to_post_map[current_line] = feedItem.cid
		current_line = current_line + 1

		local post_text = feedItem:getText()
		for line in post_text:gmatch("([^\n]*)\n?") do
			table.insert(M.posts, line)
			M.line_to_post_map[current_line] = feedItem.cid
			current_line = current_line + 1
		end

		local post_footer = feedItem:getFooter()
		table.insert(M.posts, post_footer)
		M.line_to_post_map[current_line] = feedItem.cid
		current_line = current_line + 1

		-- Additional space after each post for readability
		table.insert(M.posts, "")

		table.insert(M.posts, M.buffer.create_separator_line(config))
		table.insert(M.posts, "")
		current_line = current_line + 2
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, M.posts)
	vim.api.nvim_set_current_buf(bufnr)
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

M.update_buffer = function(config, content)
	log.info(config)
	if config.view == "threaded" then
		M.update_buffer_threaded(config, content)
	elseif config.view == "flat" then
		M.update_buffer_flat(config, content)
	else
		log.error("Unsupported view type")
	end
end

M.read = function(executor, config)
	log.info(string.format("reading data from job_id: <%d>", executor.job_id))
	local feed_json = vim.fn.rpcrequest(executor.job_id, "read")
	local content = vim.fn.json_decode(feed_json)

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
	-- local answer = vim.rpcnotify(executor.job_id, "fetch_more")
	-- log.info(string.format("answer returns: <%s>", answer))
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
	-- local answer = vim.rpcnotify(executor.job_id, "fetch_more")
	-- log.info(string.format("answer returns: <%s>", answer))
end

return M
