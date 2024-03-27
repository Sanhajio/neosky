local FeedItem = {}
FeedItem.__index = FeedItem

function FeedItem.new(postData)
	local self = setmetatable({}, FeedItem)
	self.postData = postData
	return self
end

return FeedItem
