local M = {}

M.executor = require("neosky.executor")
M.handler = require("neosky.handler")
M.config = require("neosky.config")

local function quick_start_delayed()
	M.handler.read(M.executor, M.config)
	M.executor.stop()
end

M.start = function()
	M.executor.start(M.config)
end

M.read = function()
	M.handler.read(M.executor, M.config)
end

M.update_feed = function()
	M.handler.update_feed(M.executor)
end

M.quick_start = function()
	M.executor.start(M.config)
	M.handler.update_feed(M.executor)
	vim.defer_fn(quick_start_delayed, 3000)
end

M.stop = function()
	M.executor.stop()
end

return M
