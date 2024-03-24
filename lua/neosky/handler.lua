local log = require("plenary.log")
local M = {}

-- TODO:Add replies, reply counts,
-- TODO: find a way to keep track of the posts lines, from line 1 -> 10; post did, etc.
M.buffer = require("neosky.buffer")

M.read = function(executor, config)
	log.info(string.format("reading data from job_id: <%d>", executor.job_id))
	local feed_json = vim.fn.rpcrequest(executor.job_id, "read")
	local content = vim.fn.json_decode(feed_json)

	if content == nil then
		log.error("No content to display")
		return
	end

	local bufnr = M.buffer._find_or_create_buffer(config)
	M.posts = {}
	M.line_to_post_map = {} -- Reset the map for fresh mapping

	local current_line = 1 -- Keep track of the current line number
	for _, item in ipairs(content) do
		-- Main post
		local post_info = string.format(
			"%s\t@%s\t%s",
			item.post.author.displayName,
			item.post.author.handle,
			item.post.record.createdAt
		)
		table.insert(M.posts, post_info)
		M.line_to_post_map[current_line] = item.post.cid
		current_line = current_line + 1

		-- Post text
		for line in item.post.record.text:gmatch("([^\n]*)\n?") do
			table.insert(M.posts, line)
			M.line_to_post_map[current_line] = item.post.cid
			current_line = current_line + 1
		end

		-- Handle replies, if any
		if item.reply and item.reply.parent then
			-- Here, we add a tab for indentation to visually represent a reply
			local reply_info = string.format(
				"\t↪ %s\t@%s\t%s",
				item.reply.parent.author.displayName,
				item.reply.parent.author.handle,
				item.reply.parent.record.createdAt
			)
			table.insert(M.posts, reply_info)
			M.line_to_post_map[current_line] = item.reply.parent.cid
			current_line = current_line + 1

			-- Reply text, with indentation
			for line in item.reply.parent.record.text:gmatch("([^\n]*)\n?") do
				table.insert(M.posts, "\t" .. line)
				M.line_to_post_map[current_line] = item.reply.parent.cid
				current_line = current_line + 1
			end
		end
	end
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, M.posts)
	vim.api.nvim_set_current_buf(bufnr)
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

M.update_feed = function(feed_data)
	log.info(string.format("Calling Update feed with %s", feed_data))
end

return M
