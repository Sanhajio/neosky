--- Neosky Plugin Commands
-- This module defines Neovim user commands for the Neosky plugin,
-- providing integration with Bluesky social media functionalities directly from Neovim.

local log = require("plenary.log")

--- Command to read updates from Bluesky.
-- This command triggers the 'read' function of the Neosky plugin to fetch and display the latest updates.
-- Usage: :NeoSky
vim.api.nvim_create_user_command("NeoSky", function()
	require("neosky").read()
end, {
	nargs = 0, -- Accepts any number of arguments, which are ignored in this command.
})

--- Command to create a new post on Bluesky.
-- Opens a popup window to input and submit a new post to Bluesky.
-- Usage: :NeoSkyPost
vim.api.nvim_create_user_command("NeoSkyPost", function()
	require("neosky").popup.create_popup("Post to Bluesky", "English", 300)
end, {
	nargs = 0, -- Accepts any number of arguments, which are ignored in this command.
})

--- Command to reload the Neosky plugin.
-- Unloads and reloads the Neosky plugin modules and configurations, effectively resetting its state, Useful for development, and iterating on the plugin.
-- Usage: :NeoSkyReload
vim.api.nvim_create_user_command("NeoSkyReload", function()
	package.loaded["neosky"] = nil
	package.loaded["neosky.executor"] = nil
	package.loaded["neosky.handler"] = nil
	package.loaded["neosky.config"] = nil
	require("neosky")
	log.info("NeoSkyReload: Reloaded the plugin successfully.")
end, {
	nargs = "*", -- Accepts any number of arguments, which are ignored in this command.
})
