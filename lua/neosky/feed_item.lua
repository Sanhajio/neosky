local FeedItem = {}
FeedItem.__index = FeedItem

function FeedItem.new(postData)
	local self = setmetatable({}, FeedItem)
	self.postData = postData
	self.author = postData.author
	self.cid = postData.cid
	self.createdAt = postData.record.createdAt
	self.text = postData.record.text
	self.likeCount = postData.likeCount
	self.replyCount = postData.replyCount
	self.repostCount = postData.repostCount
	self.uri = postData.uri
	self.reason = postData.reason

	-- Check if the post is a reply and capture the relevant details
	if postData.record.reply then
		self.isReply = true
		self.replyParentCid = postData.record.reply.parent.cid
		self.replyRootCid = postData.record.reply.root.cid
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
