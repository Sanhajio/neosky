local M = {}

M.executor = require("neosky.executor")
M.handler = require("neosky.handler")
M.config = require("neosky.config")

M.start = function()
	M.executor.start(M.config)
end

M.read = function()
	M.handler.read(M.executor, M.config)
end

M.stop = function()
	M.executor.stop()
end

return M
