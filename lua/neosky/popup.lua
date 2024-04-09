local Popup = require("plenary.popup")
local M = {}

M.create_popup = function()
	local width = 50
	local height = 20

	local opts = {
		title = "Post to BlueSky",
		border = true,
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		padding = { 1, 1, 1, 1 },
	}

	local bufnr = vim.api.nvim_create_buf(false, true)
	local win_id = Popup.create(bufnr, {
		title = opts.title,
		highlight = "MyHighlightGroup",
		line = math.floor(((vim.o.lines - height) / 2) - 1),
		col = math.floor((vim.o.columns - width) / 2),
		minwidth = width,
		minheight = height,
		borderchars = opts.borderchars,
		padding = opts.padding,
	})

	-- Set up buffer-specific key mappings, autocommands, etc.
	vim.api.nvim_buf_set_keymap(
		bufnr,
		"n",
		"<CR>",
		"<cmd>lua submit_post(" .. bufnr .. ")<CR>",
		{ noremap = true, silent = true }
	)

	-- Focus the popup window and enter insert mode
	vim.api.nvim_set_current_win(win_id)
	vim.api.nvim_win_set_cursor(win_id, { 1, 0 }) -- Move cursor to start
	vim.cmd("startinsert")
end

local function submit_post(bufnr)
	local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	-- Send content to BlueSky
	print("Posting to BlueSky: " .. table.concat(content, "\n"))
	-- Close the popup after posting
	vim.api.nvim_buf_delete(bufnr, { force = true })
end

return M
