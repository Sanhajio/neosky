local function undo_inserted(lines)
	local max_chars = 300 - 1
	local global_char_count = 0
	local result_lines = {}

	for _, line in ipairs(lines) do
		if global_char_count + #line + 1 > max_chars then
			local remaining_chars = max_chars - global_char_count
			if remaining_chars > 0 then
				local part_line = line:sub(1, remaining_chars)
				table.insert(result_lines, part_line)
				-- TODO: find a correct way to remove excess content
			end
			break
		else
			table.insert(result_lines, line)
			global_char_count = global_char_count + #line + 1 -- +1 for the newline character
		end
	end

	return result_lines
end

local function check_and_undo_excess_content(bufnr)
	-- Assuming bufnr is the buffer number, if not provided, use the current buffer
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local count = character_count(lines)
	if count > 300 then
		-- Undo the last change if the character count exceeds the limit
		vim.api.nvim_command("undo")
	end
	-- vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
	-- log.info("Content truncated to 300 characters.")
end
