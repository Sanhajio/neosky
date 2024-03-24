local log = require("plenary.log")

local M = {}

M.start = function(config)
	log.info(string.format("Starting %s", config.bin))
	local bin = config.bin
	local job_id = vim.fn.jobstart(bin, { rpc = true })
	if job_id == "0" then
		log.error("Invalid Arguments")
	elseif job_id == "-1" then
		log.error("Binary not executable")
	else
		M.job_id = job_id
	end
end

M.stop = function()
	log.info(string.format("Job rbsky with job_id: <%d> stopped successfully", M.job_id))
	vim.fn.jobstop(M.job_id)
end

return M
