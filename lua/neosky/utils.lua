--- Utils module contains all the utils functions used throughout the code
-- @module neosky.utils

--TODO: understand the difference between ---@module and -- @module

local M = {}

--- Retrieves the highest numerical index from a table.
--- This function iterates over the keys of the table and returns the largest numerical key found.
--- Useful for ordered tables where indices are numeric and you need to find the last item.
--- @param tbl table The table from which to retrieve the last item index.
--- @return number|nil max_key index in the table, or nil if the table has no numeric indices.
M.get_last_item_from_table = function(tbl)
	local max_key = nil

	for key, _ in pairs(tbl) do
		if type(key) == "number" and (max_key == nil or key > max_key) then
			max_key = key
		end
	end

	return max_key
end

--- Retrieves the smallest numerical index from a table.
--- This function iterates over the keys of the table and returns the smallest numerical key found.
--- Useful for ordered tables where indices are numeric and you need to find the first item.
--- @param tbl table The table from which to retrieve the first item index.
--- @return number|nil min_key The smallest index in the table, or nil if the table has no numeric indices.
M.get_first_item_from_table = function(tbl)
	local min_key = nil

	for key, _ in pairs(tbl) do
		if type(key) == "number" and (min_key == nil or key < min_key) then
			min_key = key
		end
	end

	return min_key
end

--- Gets the current cursor position in the active window.
--- This function wraps the Neovim API call to get the cursor's position, which includes the row and column.
--- @return table current_cursor_pos a table with two elements, {row, col}, representing the current cursor position.
M.get_current_cursor_pos = function(winid)
	local current_cursor_pos = vim.api.nvim_win_get_cursor(winid)
	return current_cursor_pos
end

--- Sets the cursor position in the specified buffer's window.
--- This function wraps the Neovim API call to set the cursor's position safely using pcall to handle potential errors.
--- @param winid number The window id where the cursor position will be set. If bufnr is 0, it applies to the current buffer.
--- @param cursor_pos table A table with two elements, {row, col}, where the cursor should be moved to.
M.set_current_cursor_pos = function(winid, cursor_pos)
	local current_cursor_pos = pcall(vim.api.nvim_win_set_cursor, winid, cursor_pos)
end

--- Inserts a line into a table at the beginning or at the end based on the reverse flag.
--- This function inserts a specified line into a given table. If 'reverse' is true, the line is inserted at the start; otherwise, it's added at the end.
--- @param t table The table where the line will be inserted.
--- @param line string The line to be inserted into the table.
--- @param reverse boolean If true, inserts the line at the beginning of the table; if false, at the end.
M.insert_line = function(t, line, reverse)
	if reverse then
		table.insert(t, 1, line)
	else
		table.insert(t, line)
	end
end

--- Prints the Lua object in a human-readable format.
--- This function is a utility for debugging; it prints out any Lua object using `vim.inspect` for easy reading.
--- @param o any The object to be printed.
M.P = function(o)
	print(vim.inspect(o))
end

return M
