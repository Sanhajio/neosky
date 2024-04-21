--- neosky.lua - Main module for Neosky Neovim plugin.
-- This module integrates various components such as executor, handler, config, and popup to provide
-- the functionality of reading and managing social media updates directly within Neovim.

local M = {}

-- Load the required modules.
M.executor = require("neosky.executor") -- starts and stops the service that calls the bluesky api
M.handler = require("neosky.handler") -- Main Bluesky Plugin Component: Handles the calls to the background service to retrieve the data, send post, and handles the events in the buffer
M.config = require("neosky.config") -- Configuration settings for the Neosky plugin.
M.popup = require("neosky.popup") -- Popup management for social media interactions.

--- read_delayed - Helper function to read data after a delay.
-- This function is a private utility used to defer reading operations,
-- allowing time for preliminary operations like startup and timeline updates to complete.
local function read_delayed()
	M.handler.read(M.config, M.executor)
end

--- read - Main entrypoint for the plugin. Initiates reading of social media data.
-- This function checks if the background process is running and starts one if not, then proceeds to read data.
-- If the executor's job_id is nil, it sets up the configuration, starts the executor,
-- and defers the reading operation by 3000 milliseconds to ensure readiness.
M.read = function()
	if M.executor.job_id == nil then
		M.config.setup()
		M.executor.start(M.config)
		vim.defer_fn(read_delayed, 3000)
	else
		M.handler.read(M.config, M.executor)
	end
end

return M
