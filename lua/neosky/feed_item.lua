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

return FeedItem
