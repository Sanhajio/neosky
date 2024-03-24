local log = require("plenary.log")
local M = {}

M._find_or_create_buffer = function(config)
	-- Check if the buffer already exists
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		log.info(vim.api.nvim_buf_get_name(bufnr))
		local suffix = config.bufname
		if vim.api.nvim_buf_get_name(bufnr):sub(-#suffix) == suffix then
			return bufnr
		end
	end

	-- Create a new buffer if it doesn't exist
	local bufnr = vim.api.nvim_create_buf(false, true) -- nomodifiable, not listed
	vim.api.nvim_buf_set_name(bufnr, config.bufname)
	return bufnr
end

return M
