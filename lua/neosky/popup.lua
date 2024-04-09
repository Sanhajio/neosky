local log = require("plenary.log")
local Popup = require("plenary.popup")
local M = {}

local function get_character_count(text)
	local count = #text
	return count
end

-- local function update_status_line(bufnr, language, max, height)
-- 	local character_count = vim.api.nvim_buf_get_var(bufnr, "character_count")
-- 	local status_line_content = string.format("%s\t%s/%s", language, character_count, max)
-- 	-- Set the status line content in the last line of the buffer
-- 	vim.api.nvim_buf_set_lines(bufnr, height, height, false, { status_line_content })
-- end

M.create_popup = function(title)
	local bufnr = vim.api.nvim_create_buf(false, true)

	-- Get initial dimensions for the popup

	local width = math.floor(vim.o.columns * 0.5)
	local height = math.floor(vim.o.lines * 0.3)
	local minwidth = 30
	local minheight = 20
	local maxwidth = 40
	local maxheight = 20

	local opts = {
		title = title,
		width = math.floor(vim.o.columns * 0.5),
		height = math.floor(vim.o.lines * 0.3),
		border = true,
		minwidth = minwidth,
		minheight = minheight,
		maxwidth = maxwidth,
		maxheight = maxheight,
		padding = { 1, 1, 1, 1 },
		-- line = math.floor(vim.o.lines / 2),
		line = 0,
		col = math.floor((vim.o.columns - width / 2) / 2),
	}

	vim.o.statusline = [[%f%m%r%h%w\ [%{&filetype}]\ [%{getline('.')}]%=%l,%c%V\ %P]]

	local hint_text = "What's up?"
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { hint_text })
	local character_count = 0
	vim.api.nvim_buf_set_var(bufnr, "character_count", character_count)

	local win_id = Popup.create(bufnr, opts)
	vim.api.nvim_win_set_option(win_id, "wrap", false)
	vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		buffer = bufnr,
		callback = function()
			local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
			local text = table.concat(lines, "")
			log.info(string.format("lines: %s, text: %s lines.len: %s text.len: %s", lines, text, #lines, #text))
			-- vim.api.nvim_buf_set_var(bufnr, "character_count", #lines)
			-- update_status_line(bufnr, "English", 300, height)
		end,
	})

	-- Autocommand to clear hint when typing starts
	vim.api.nvim_create_autocmd("InsertEnter", {
		buffer = bufnr,
		once = true,
		callback = function()
			if vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == hint_text then
				vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, { "" })
			end
		end,
	})

	-- Set up buffer-specific key mappings, autocommands, etc.
	vim.api.nvim_buf_set_keymap(
		bufnr,
		"n",
		"<CR>",
		string.format('<cmd>lua require("neosky").popup.submit_post(%s)<CR>', bufnr),
		{ noremap = true, silent = true }
	)

	-- Autocommand to handle window resizing
	vim.api.nvim_create_autocmd("VimResized", {
		callback = function()
			-- Resize the popup window
			vim.api.nvim_win_set_config(
				win_id,
				{ width = math.floor(vim.o.columns * 0.5), height = math.floor((vim.o.lines - height) / 2) }
			)
		end,
	})

	-- Place the cursor in the popup's buffer
	vim.api.nvim_set_current_win(win_id)
end

M.submit_post = function(bufnr)
	local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	-- Send content to BlueSky
	print("Posting to BlueSky: " .. table.concat(content, "\n"))
	-- Close the popup after posting
	vim.api.nvim_buf_delete(bufnr, { force = true })
end

return M
