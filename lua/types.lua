---@meta

--- @class ImageRange
--- @field start_row number The starting row of the image.
--- @field start_col number The starting column of the image.
--- @field end_row number The ending row of the image.
--- @field end_col number The ending column of the image.

--- @class ImageData
--- @field url string The URL from where the image can be fetched.
--- @field range ImageRange The range within the buffer where the image should be displayed.

--- @class ImageContext
--- @field api API The image API interface.
--- @field window_id number The identifier of the window where the image is displayed.
--- @field buffer_id number The identifier of the buffer where the image is displayed.
--- @field namespace string A unique namespace associated with the image display.
--- @field img_data table<ImageData> A list of image data items to be processed and displayed.

---@class FeedItem
---@field new fun(data):table Creates a FeedItem a FeedViewPost, FeedViewPost includes a PostData object.
---@field from_post_data fun(data):table Creates a FeedItem from PostData,
---@field getHeader fun(self:FeedItem):string Method to get the header information of the feed item.
---@field getText fun(self:FeedItem):string Method to get the text content of the feed item.
---@field getFooter fun(self:FeedItem):string Method to get the footer information including likes, replies, and reposts.
---@field getEmbeddedImages fun(self:FeedItem):table Method to get any embedded images associated with the feed item.
---@field postData table Original post data from the feed.
---@field author table Author of the post.
---@field cid string Unique identifier for the content item.
---@field createdAt string Timestamp of when the item was created.
---@field text string Text content of the post.
---@field likeCount number Number of likes the post has received.
---@field replyCount number Number of replies the post has received.
---@field repostCount number Number of times the post has been reposted.
---@field uri string URI to access the post directly.
---@field reason table Reason why the post was displayed (e.g., reposted by someone).
---@field embeds table Array of embedded images information.
---@field postEmbed table Embed information specific to the post.
---@field recordEmbed table Embed information specific to the record.
---@field isReply boolean Indicates if the item is a reply to another post.
---@field replyParentCid string If a reply, the CID of the parent post.
---@field replyRootCid string If a reply, the CID of the root post.
---@field parentPost table Optional parent post data.
---@field rootPost table Optional root post data.