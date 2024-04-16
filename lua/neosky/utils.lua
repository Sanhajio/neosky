local M = {}

M.get_last_item_from_table = function(tbl)
	local max_key = nil

	for key, _ in pairs(tbl) do
		if type(key) == "number" and (max_key == nil or key > max_key) then
			max_key = key
		end
	end

	return max_key
end

M.get_first_item_from_table = function(tbl)
	local min_key = nil

	for key, _ in pairs(tbl) do
		if type(key) == "number" and (min_key == nil or key < min_key) then
			min_key = key
		end
	end

	return min_key
end

M.get_current_cursor_pos = function()
	local current_cursor_pos = vim.api.nvim_win_get_cursor(0)
	return current_cursor_pos
end

M.set_current_cursor_pos = function(bufnr, cursor_pos)
	local current_cursor_pos = pcall(vim.api.nvim_win_set_cursor, 0, cursor_pos)
end

M.insert_line = function(t, line, reverse)
	if reverse then
		table.insert(t, 1, line)
	else
		table.insert(t, line)
	end
end

M.P = function(o)
	print(vim.inspect(o))
end

return M
