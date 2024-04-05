local log = require("plenary.log")

local M = {}

-- TODO: add a setup function that sets up the config: check obsidian.nvim
-- TODO: change bufname, to bufextension: neosky.social, so that I can have a file named: following.neosky.social and another one gamedev.neosky.social
-- TODO: add a filetype and colorscheme for the filetype neosky.social
M = {
	bin = "/home/sanhajio/development/growth/rbsky/target/debug/rbsky-nvim",
	bufname = "neosky.social",
	view = "threaded",
}

-- TODO: add docs: ---@param opts opts
M.setup = function(opts)
	M.cursor_moved = false
	local group = vim.api.nvim_create_augroup("neosky", { clear = true })

	vim.api.nvim_create_autocmd("CursorMoved", {
		group = group,
		pattern = "*",
		callback = function()
			local neosky = require("neosky")
			local executor = neosky.executor
			local current_line = vim.api.nvim_win_get_cursor(0)[1]
			local total_lines = vim.api.nvim_buf_line_count(0)
			local bufnr = vim.api.nvim_get_current_buf()
			if current_line >= total_lines then
				local last_line = vim.api.nvim_buf_get_lines(bufnr, total_lines - 1, total_lines, false)[1]
				if last_line ~= "Loading More ..." then
					M.cursor_moved = false
					neosky.handler.fetch_more(M, executor)
				end
			elseif current_line <= 1 and M.cursor_moved then
				M.cursor_moved = false
				local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
				log.info(string.format("first line contains %s", first_line))
				if first_line ~= "Refreshing Timeline ..." then
					neosky.handler.refresh_timeline(M, executor)
				end
			elseif current_line > 1 and current_line < total_lines then
				M.cursor_moved = true
			end
			-- TODO: I think this deletes the autocmd after its run
			-- return true
		end,
	})
end

return M
