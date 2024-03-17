local log = require("plenary.log")
local M = {}

M.config = {
	bin = "/home/sanhajio/development/pp/growth/rbsky/target/debug/rbsky-nvim",
}

M.content = {}

-- TODO: add a setup function, to setup rsbskybin
-- TODO: add a filetype and colorscheme for the filetype neosky.social
M.start = function()
	log.info(string.format("Starting %s", M.config.bin))
	local bin = M.config.bin
	local job_id = vim.fn.jobstart(bin, { rpc = true })
	log.info(job_id)
	if job_id == "0" then
		log.info("Invalid Arguments")
	elseif job_id == "-1" then
		log.info("Binary not executable")
	else
		M.job_id = job_id
	end
	vim.fn.rpcnotify(M.job_id, "read")
end

M.read = function()
	local content = {}
	vim.fn.rpcnotify(M.job_id, "read")
	log.info(vim.inspect(content))
end

M.stop = function()
	vim.fn.jobstop(M.job_id)
	log.debug(string.format("Job rbsky with job_id: <%d> stopped successfully", M.job_id))
end

M.update_feed = function(feed_data)
	log.debug("Calling Update feed with")
end

return M
