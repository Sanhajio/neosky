--- Module for managing Neovim buffers specifically tailored for display purposes.
-- This module includes functionalities to create or find buffers and generate formatting lines within those buffers.

local log = require("plenary.log")
local M = {}

--- Finds an existing buffer by name or creates a new one if it does not exist.
-- This function searches through all open buffers to find one that ends with the specified name suffix.
-- If no such buffer exists, it creates a new one that is not listed and is non-modifiable.
-- @param config table Configuration table containing 'bufname' as the buffer name suffix.
-- @return number Buffer number of the found or created buffer.
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

--- Creates a separator line based on the maximum width of the window displaying the buffer.
-- This function first finds or creates a buffer based on the provided config.
-- It then checks the width of the window displaying this buffer and creates a separator line of dashes.
-- The length of the separator is determined by the width of the window or a default minimum width.
-- @param config table Configuration table specifying the buffer settings.
-- @return string A string of dashes serving as a separator line.
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
