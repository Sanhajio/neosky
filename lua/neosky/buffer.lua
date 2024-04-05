local log = require("plenary.log")
local M = {}

M._find_or_create_buffer = function(config)
	-- Check if the buffer already exists
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		-- log.info(vim.api.nvim_buf_get_name(bufnr))
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

M.create_separator_line = function(config)
	local bufnr = M._find_or_create_buffer(config)
	local width = 80 -- Default minimum width

	-- Find the window where the buffer is displayed, if any
	for _, win_id in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win_id) == bufnr then
			local win_width = vim.api.nvim_win_get_width(win_id)
			width = math.max(width, win_width) -- Ensure a minimum width
			break
		end
	end

	local separator = string.rep("-", width - 30) -- Create a string of dashes that matches the buffer's width
	return separator
end

return M
