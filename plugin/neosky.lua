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

vim.api.nvim_create_user_command("NeoSkyReload", function()
	-- write function here
	package.loaded["neosky"] = nil
	require("neosky")
	log.info("NeoSkyReload: Reloaded the plugin successfully.")
end, {
	nargs = "*",
})
