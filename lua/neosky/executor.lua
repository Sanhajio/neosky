--- Module for managing background job operations within Neovim.
-- This module encapsulates functionalities to start and stop background jobs based on user-defined configurations.

local log = require("plenary.log")

local M = {}

--- Maintains the current cooldown state of the job, it is meant to space refresh timeline and Loading More calls to the background process
M.cooldown = 0

--- Internal function to construct a command string based on provided configuration.
-- @param config table The configuration settings for the job.
-- @return string The constructed command string.
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

--- Starts the rbsky background nvim handler with the specified configuration.
-- Logs the command and handles the job start, capturing the job ID.
-- @param config table The configuration for the background job to start.
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

--- Stops the currently running job.
-- Logs the successful job stop and cleans up the job ID.
M.stop = function()
	if M.job_id ~= nil then
		log.info(string.format("Job rbsky with job_id: %d stopped successfully", M.job_id))
		vim.fn.jobstop(M.job_id)
		M.job_id = nil
	end
end

return M
