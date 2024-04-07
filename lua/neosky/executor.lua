local log = require("plenary.log")

local M = {}

M._cmd = function(config)
	local cmd = ""
	if config.auto_update then
		cmd = string.format(
			"%s -c '%s --auto-update-interval %s --log-level %s --auto-update'",
			config.shell,
			config.bin,
			config.auto_update_interval,
			config.log_level
		)
	else
		cmd = string.format(
			"%s -c '%s --auto-update-interval %s --log-level %s'",
			config.shell,
			config.bin,
			config.auto_update_interval,
			config.log_level
		)
	end
	return cmd
end

M.start = function(config)
	local cmd = M._cmd(config)
	log.info(string.format("Starting %s", cmd))
	local job_id = vim.fn.jobstart(cmd, { rpc = true })
	if job_id == "0" then
		log.error("Invalid Arguments")
	elseif job_id == "-1" then
		log.error("Binary not executable")
	else
		M.job_id = job_id
	end
end

M.stop = function()
	if M.job_id ~= nil then
		log.info(string.format("Job rbsky with job_id: %d stopped successfully", M.job_id))
		vim.fn.jobstop(M.job_id)
		M.job_id = nil
	end
end

return M
