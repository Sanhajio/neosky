--- Module for neosky configuration settings.

local log = require("plenary.log")
local M = {}

--- Default configuration settings for the module.
M = {
	_defaults = {
		bin = "/home/sanhajio/development/pp/growth/rbsky/target/debug/rbsky-nvim",
		bufname = "neosky.social",
		view = "threaded",
		auto_update = false,
		auto_update_interval = 300,
		-- images: contains
		-- hover: Only when the cursor is on the link
		-- static: show images all the time
		-- nil: skip images
		images = "static",
		log_level = "info",
		signature = " #neosky",
		shell = "/bin/sh",
	},
}

--- Sets up the module configuration using the provided options, overriding defaults where provided.
-- @param opts table Configuration options to be applied.
M._setup_config = function(opts)
	log.info(string.format("opts are set to: %s", vim.inspect(opts)))
	M.shell = opts.shell
	M.bin = opts.bin
	M.bufname = opts.bufname
	M.view = opts.view
	M.auto_update = opts.auto_update
	M.auto_update_interval = opts.auto_update_interval
	M.log_level = opts.log_level
	M.signature = opts.signature
	log.info(string.format("config is set to: %s", vim.inspect(M)))
end

--- Loads more content asynchronously based on buffer and cursor position,
-- This function is triggered when the cursor moves to the end of the buffer.
-- It is in config.lua because it is an autocmd on CursorMoved
-- @param timer userdata A vim.loop timer used for cooldown handling.
-- @param neosky table The main Neosky module containing executor and handler.
-- @param bufnr number Buffer number where the content is loaded.
-- @param total_lines number Total lines in the current buffer to determine if content needs loading.
M._load_more = function(timer, neosky, bufnr, total_lines)
	neosky.executor.cooldown = 1
	timer:start(6000, 0, function()
		log.info("setting the cooldown to 0")
		neosky.executor.cooldown = 0
	end)
	local last_line = vim.api.nvim_buf_get_lines(bufnr, total_lines - 1, total_lines, false)[1]
	if last_line ~= "Loading More ..." then
		M.cursor_moved = false
		neosky.handler.fetch_more(M, neosky.executor)
	end
end

--- Refreshes the content of the buffer asynchronously.
-- This function is triggered when the cursor moves to the top of the buffer.
-- It is in config.lua because it is an autocmd on CursorMoved
-- @param timer userdata A vim.loop timer used for cooldown handling.
-- @param neosky table The main Neosky module containing executor and handler.
-- @param bufnr number Buffer number where the content is refreshed.
M._refresh = function(timer, neosky, bufnr)
	neosky.executor.cooldown = 1
	timer:start(6000, 0, function()
		log.info("setting the cooldown to 0")
		neosky.executor.cooldown = 0
	end)
	M.cursor_moved = false
	local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
	log.info(string.format("first line contains %s", first_line))
	if first_line ~= "Refreshing Timeline ..." then
		neosky.handler.refresh_timeline(M, neosky.executor)
	end
end

-- TODO: change bufname, to bufextension: neosky.social, so that I can have a file named: following.neosky.social and another one gamedev.neosky.social
-- TODO: add a filetype and colorscheme for the filetype neosky.social

-- TODO: add docs: ---@param opts opts

--- Public setup function for initializing module configuration and event listeners.
-- This function also sets up auto commands for dynamically loading or refreshing content based on cursor movements.
-- @param opts table Optional configuration options.
M.setup = function(opts)
	opts = opts or {}
	for k, v in pairs(M._defaults) do
		if opts[k] == nil then
			opts[k] = v
		end
	end

	M._setup_config(opts)
	M.cursor_moved = false
	local group = vim.api.nvim_create_augroup("neosky", { clear = true })
	vim.api.nvim_create_autocmd("CursorMoved", {
		group = group,
		pattern = "neosky.social",
		callback = function()
			local timer = vim.loop.new_timer()
			local neosky = require("neosky")
			local current_line = vim.api.nvim_win_get_cursor(0)[1]
			local total_lines = vim.api.nvim_buf_line_count(0)
			local bufnr = vim.api.nvim_get_current_buf()
			if current_line >= total_lines and neosky.executor.cooldown == 0 then
				M._load_more(timer, neosky, bufnr, total_lines)
			elseif current_line <= 1 and M.cursor_moved and neosky.executor.cooldown == 0 then
				M._refresh(timer, neosky, bufnr)
			elseif current_line > 1 and current_line < total_lines then
				M.cursor_moved = true
			end
		end,
	})
end

return M
