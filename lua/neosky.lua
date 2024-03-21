local log = require("plenary.log")
local M = {}

M.config = {
	bin = "/home/sanhajio/development/pp/growth/rbsky/target/debug/rbsky-nvim",
	bufname = "neosky.social",
}

M._find_or_create_buffer = function(bufname)
	-- Check if the buffer already exists
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		log.info(vim.api.nvim_buf_get_name(bufnr))
		local suffix = bufname
		if vim.api.nvim_buf_get_name(bufnr):sub(-#suffix) == suffix then
			return bufnr
		end
	end

	-- Create a new buffer if it doesn't exist
	local bufnr = vim.api.nvim_create_buf(false, true) -- nomodifiable, not listed
	vim.api.nvim_buf_set_name(bufnr, bufname)
	return bufnr
end

M.content = {}

-- TODO: add a setup function, to setup rsbskybin
-- TODO: add a filetype and colorscheme for the filetype neosky.social
M.start = function()
	log.info(string.format("Starting %s", M.config.bin))
	local bin = M.config.bin
	local job_id = vim.fn.jobstart(bin, { rpc = true })
	log.info(job_id)
	if job_id == "0" then
		log.info("Invalid Arguments")
	elseif job_id == "-1" then
		log.info("Binary not executable")
	else
		M.job_id = job_id
	end
end

M.read = function()
	local feed_json = vim.fn.rpcrequest(M.job_id, "read")
	log.debg(vim.inspect(feed_json))

	-- Decode the JSON string to a Lua table
	local content = vim.fn.json_decode(feed_json)

	-- Optionally log or process the content table
	log.info(vim.inspect(content))
	if content == nil then
		log.error("No content to display")
		return
	end

	local bufnr = M._find_or_create_buffer("neosky.social")
	log.info("item: ", content)
	M.posts = {}
	for _, item in ipairs(content) do
		log.info("item: ", content)
		table.insert(
			M.posts,
			string.format(
				"%s		@%s		%s",
				item.post.author.displayName,
				item.post.author.handle,
				item.post.record.createdAt
			)
		)
		for line in item.post.record.text:gmatch("([^\n]*)\n?") do
			table.insert(M.posts, line)
		end
	end
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, M.posts)
	vim.api.nvim_set_current_buf(bufnr)
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
	--
end

M.stop = function()
	vim.fn.jobstop(M.job_id)
	log.debug(string.format("Job rbsky with job_id: <%d> stopped successfully", M.job_id))
end

M.update_feed = function(feed_data)
	log.info(string.format("Calling Update feed with %s", feed_data))
end

return M
