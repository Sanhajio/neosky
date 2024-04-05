local M = {}

M.executor = require("neosky.executor")
M.handler = require("neosky.handler")
M.config = require("neosky.config")

local function quick_start_delayed()
	M.handler.read(M.config, M.executor)
	M.stop()
end

M.start = function()
	M.config.setup()
	M.executor.start(M.config)
end

M.read = function()
	M.handler.read(M.config, M.executor)
end

M.update_feed = function()
	M.handler.update_feed(M.executor)
end

M.quick_start = function()
	if M.executor.job_id == nil then
		M.stop()
		M.executor.start(M.config)
	end
	M.handler.update_feed(M.executor)
	vim.defer_fn(quick_start_delayed, 6000)
end

M.stop = function()
	M.executor.stop()
end

return M
