--- popup.lua - Popup management module for the Neosky Neovim plugin.
-- This module uses the NUI library to create and manage interactive popups for posting content to Bluesky.

local log = require("plenary.log")
local nui = require("nui.popup")
local event = require("nui.utils.autocmd").event
local M = {}

--- Updates the status line of the popup with character count and language.
-- @param popup nui.popup The popup instance to update.
-- @param text string The current text from the popup's buffer.
-- @param language string The language context of the popup.
-- @param max number The maximum allowed characters.
local function update_status_line(popup, text, language, max)
	local character_count = #text
	local status_line_content = string.format("%s\t, %s/300", language, character_count)
	popup.border:set_text("bottom", status_line_content)
end

--- Creates a popup for entering a post.
-- This function sets up a new popup window for user input to create posts on Bluesky.
-- It also configures necessary autocmds to handle text changes and submission.
-- @param title string The title for the popup window.
-- @param language string The language context to display in the status line.
-- @param max number The maximum character limit for the post.
M.create_popup = function(title, language, max)
	local bufnr = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.5)
	local height = math.floor(vim.o.lines * 0.3)
	local submit_cmd = string.format('<cmd>lua require("neosky").popup.submit_post(%s)<CR>', bufnr)

	local bottom_text = string.format("%s\t, 0/%s", language, max)
	local popup = nui({
		enter = true,
		focusable = true,
		border = {
			style = "rounded",
			text = {
				top = title,
				top_align = "left",
				bottom = bottom_text,
				bottom_align = "left",
			},
		},
		position = "50%",
		size = {
			width = width,
			height = height,
		},
		bufnr = bufnr,
	})

	local hint_text = "What's up?"

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { hint_text })
	vim.api.nvim_buf_set_option(bufnr, "modifiable", true)

	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		buffer = bufnr,
		callback = function()
			local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
			local text = table.concat(lines, "")
			log.info(string.format("lines: %s, text: %s lines.len: %s text.len: %s", lines, text, #lines, #text))
			update_status_line(popup, text, language, max)
		end,
	})

	vim.api.nvim_create_autocmd("InsertEnter", {
		buffer = bufnr,
		once = true,
		callback = function()
			if vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == hint_text then
				vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, { "" })
			end
		end,
	})

	vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", submit_cmd, { noremap = true, silent = true })

	popup:mount()
	popup:on(event.BufLeave, function()
		popup:unmount()
	end)

	-- Set initial focus to the popup's buffer
	vim.api.nvim_set_current_buf(bufnr)
end

--- Submits the post from the popup's buffer to Bluesky.
-- This function gathers the content from the popup's buffer and sends it to Bluesky.
-- @param bufnr number The buffer number containing the post content.
M.submit_post = function(bufnr)
	local neosky = require("neosky")
	local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	-- Send content to BlueSky
	log.info("Posting to BlueSky: " .. table.concat(content, "\n"))
	neosky.handler.post(neosky.executor, content)

	-- Close the popup after posting
	vim.api.nvim_buf_delete(bufnr, { force = true })
end

return M
