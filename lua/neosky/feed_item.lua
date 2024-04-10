local log = require("plenary.log")
local FeedItem = {}
FeedItem.__index = FeedItem

function FeedItem.from_post_data(data)
	local self = setmetatable({}, FeedItem)
	self.postData = data
	self.author = data.author
	self.cid = data.cid
	self.createdAt = data.record.createdAt
	self.text = data.record.text
	self.likeCount = data.likeCount
	self.replyCount = data.replyCount
	self.repostCount = data.repostCount
	self.uri = data.uri
	self.reason = data.reason
	self.embeds = {} -- Initialize embeds as an empty table
	self.postEmbed = {} -- Initialize embeds as an empty table
	self.recordEmbed = {} -- Initialize embeds as an empty table
	if data.embed then
		self.postEmbed = data.embed
	end

	-- Handling image#view embed
	if data.embed and data.embed["$type"] == "app.bsky.embed.images#view" and data.embed.images then
		for _, img in ipairs(data.embed.images) do
			table.insert(self.embeds, {
				alt = img.alt,
				fullsize = img.fullsize,
				thumb = img.thumb,
				width = img.aspectRatio.width,
				height = img.aspectRatio.height,
			})
		end
	end

	if data.record.embed then
		self.recordEmbed = data.record.embed
	end
	-- TODO: add a embed not supported
	-- TODO: images add a image view: preview or flat

	-- log.info(vim.inspect(self.uri), vim.inspect(self.author))
	-- log.info("post embed")
	-- log.info(vim.inspect(self.postEmbed))
	-- log.info("record embed")
	-- log.info(vim.inspect(self.recordEmbed))

	-- Check for embeds in the record data and extract image details
	-- if
	-- 	data.record
	-- 	and data.record.embed
	-- 	and data.record.embed["$type"] == "app.bsky.embed.images"
	-- 	and data.record.embed.images
	-- then
	-- 	for _, img in ipairs(data.record.embed.images) do
	-- 		table.insert(self.embeds, {
	-- 			alt = img.alt or "",
	-- 			fullsize = img.image and img.image["$type"] == "blob" and img.image.ref["$link"],
	-- 			-- Assuming the fullsize image URL needs to be constructed or is directly available
	-- 			thumb = img.thumb, -- Assuming there is a thumb field directly
	-- 		})
	-- 	end
	-- end

	-- Handle replies
	if data.reply then
		self.isReply = true
		self.replyParentCid = data.reply.parent.cid
		self.replyRootCid = data.reply.root.cid
	else
		self.isReply = false
	end

	return self
end

-- TODO: weird how new and from are different
function FeedItem.new(data)
	-- log.info(vim.inspect(data))
	local self = setmetatable({}, FeedItem)
	self.postData = data.post
	self.author = data.post.author
	self.cid = data.post.cid
	self.createdAt = data.post.record.createdAt
	self.text = data.post.record.text
	self.likeCount = data.post.likeCount
	self.replyCount = data.post.replyCount
	self.repostCount = data.post.repostCount
	self.uri = data.post.uri
	self.reason = data.post.reason
	self.postEmbed = {} -- Initialize embeds as an empty table
	self.recordEmbed = {} -- Initialize embeds as an empty table
	self.embeds = {} -- Initialize embeds as an empty table
	if data.post.embed then
		self.postEmbed = data.post.embed
	end

	-- Handling image#view embed
	if data.post.embed and data.post.embed["$type"] == "app.bsky.embed.images#view" and data.post.embed.images then
		for _, img in ipairs(data.post.embed.images) do
			table.insert(self.embeds, {
				alt = img.alt,
				fullsize = img.fullsize,
				thumb = img.thumb,
			})
		end
	end

	if data.post.record.embed then
		self.recordEmbed = data.post.record.embed
	end
	-- log.info(vim.inspect(self.uri))
	-- log.info("post embed")
	-- log.info(vim.inspect(self.postEmbed))
	-- log.info("record embed")
	-- log.info(vim.inspect(self.recordEmbed))

	if data.embed and data.embed["$type"] == "app.bsky.embed.images#view" and data.embed.images then
		for _, img in ipairs(data.embed.images) do
			table.insert(self.embeds, {
				alt = img.alt,
				fullsize = img.fullsize,
				thumb = img.thumb,
			})
		end
	end

	-- Check for embeds in the record data and extract image details
	-- if
	-- 	data.record
	-- 	and data.record.embed
	-- 	and data.record.embed["$type"] == "app.bsky.embed.images"
	-- 	and data.record.embed.images
	-- then
	-- 	for _, img in ipairs(data.record.embed.images) do
	-- 		table.insert(self.embeds, {
	-- 			alt = img.alt or "",
	-- 			fullsize = img.image and img.image["$type"] == "blob" and img.image.ref["$link"],
	-- 			-- Assuming the fullsize image URL needs to be constructed or is directly available
	-- 			thumb = img.thumb, -- Assuming there is a thumb field directly
	-- 		})
	-- 	end
	-- end

	-- Handle replies
	if data.parent then
		self.isReply = true
		self.replyParentCid = data.parent.cid
		self.replyRootCid = data.root.cid

		-- Optionally, store the parent and root post details directly in the FeedItem
		if data.parent then
			self.parentPost = data.parent
		end
		if data.root then
			self.rootPost = data.root
		end
	else
		self.isReply = false
	end

	return self
end

function FeedItem:getHeader()
	local header =
		string.format("%s\t@%s\t%s\t%s", self.author.displayName, self.author.handle, self.createdAt, self.cid)
	if self.isReply then
		header = header .. string.format("\tReply to: %s", self.replyParentCid)
	end
	return header
end

function FeedItem:getText()
	return self.text
end

function FeedItem:getFooter()
	local footer =
		string.format("(Likes: %d, Replies: %d, Reposts: %d)", self.likeCount, self.replyCount, self.repostCount)
	if self.reason and self.reason.by and self.reason.by.displayName then
		footer = string.format("%s, Reason: Repost By %s", footer, self.reason.by.displayName)
	end
	return footer
end

function FeedItem:getEmbeddedImages()
	return self.embeds
end

return FeedItem
