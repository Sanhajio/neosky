local log = require("plenary.log")

vim.api.nvim_create_user_command("NeoSky", function()
	require("neosky").read()
end, {
	nargs = "*",
})

vim.api.nvim_create_user_command("NeoSkyStart", function()
	local nsky = require("neosky")
	nsky.start()
end, {
	nargs = "*",
})

vim.api.nvim_create_user_command("NeoSkyStop", function()
	require("neosky").stop()
end, {
	nargs = "*",
})

vim.api.nvim_create_user_command("NeoSkyUpdate", function()
	require("neosky").update_feed()
end, {
	nargs = "*",
})

vim.api.nvim_create_user_command("NeoSkyQuickStart", function()
	require("neosky").quick_start()
end, {
	nargs = "*",
})

vim.api.nvim_create_user_command("NeoSkyReload", function()
	-- write function here
	package.loaded["neosky"] = nil
	package.loaded["neosky.executor"] = nil
	package.loaded["neosky.handler"] = nil
	package.loaded["neosky.config"] = nil
	require("neosky")
	log.info("NeoSkyReload: Reloaded the plugin successfully.")
end, {
	nargs = "*",
})
