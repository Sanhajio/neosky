local log = require("plenary.log")
local api = require("image")
local utils = require("neosky.utils")

local M = {}

M.display_img = function(ctx)
	local previous_images = api.get_images({
		window = ctx.window_id,
		buffer = ctx.buffer_id,
		namespace = ctx.namespace,
	})

	local new_image_ids = {}
	local new_images = {}
	for _, item in ipairs(ctx.img_data) do
		if item ~= {} then
			-- log.info("dataaa:", ctx.window, ctx.buffer, item.range.start_row, item.range.start_col, item.url)
			local id = string.format(
				"%d:%d:%d:%d:%s",
				ctx.window_id,
				ctx.buffer_id,
				item.range.start_row,
				item.range.start_col,
				item.url
			)
			table.insert(new_images, {
				id = id,
				url = item.url,
				window_id = ctx.window_id,
				buffer_id = ctx.buffer_id,
				range = {
					start_row = item.range.start_row,
					start_col = item.range.start_col,
					end_row = item.range.end_row,
					end_col = item.range.end_col,
				},
			})
			table.insert(new_image_ids, id)
		end
	end

	-- clear images
	for _, image in ipairs(previous_images) do
		if not vim.tbl_contains(new_image_ids, image.id) then
			image:clear()
		end
	end

	for _, item in ipairs(new_images) do
		pcall(ctx.api.from_url, item.url, {
			id = item.id,
			window = item.window_id,
			buffer = item.buffer_id,
			width = item.width,
			height = item.height,
			with_virtual_padding = true,
			namespace = ctx.namespace,
		}, function(image)
			if not image then
				return
			end
			image:render({
				x = item.range.start_col,
				y = item.range.start_row + 1,
			})
		end)
	end
end

-- local ctx = {
-- 	api = api,
-- 	window = window_id,
-- 	buffer = buffer_id,
-- 	namespace = namespace,
-- 	img_data = {
-- 		{
-- 			url = "https://gist.ro/s/remote.png",
-- 			range = {
-- 				start_row = 2,
-- 				start_col = 1,
-- 				end_row = 1,
-- 				end_col = 1,
-- 			},
-- 		},
-- 	},
-- }

return M
