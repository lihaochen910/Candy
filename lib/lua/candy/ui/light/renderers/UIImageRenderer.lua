-- import
local UIWidgetRenderer = require 'candy.ui.light.UIWidgetRenderer'
local UIWidgetElementImage = require 'candy.ui.light.renderers.UIWidgetElementImage'

---@class UIImageRenderer : UIWidgetRenderer
local UIImageRenderer = CLASS: UIImageRenderer ( UIWidgetRenderer )
	:MODEL {}

function UIImageRenderer:onInit ( widget )
	self.imageElement = self:addElement ( UIWidgetElementImage (), "image", "content" )
end

function UIImageRenderer:onUpdateContent ( widget, style )
	local img = widget:getContentData ( "image", "render" )
	self.imageElement:setDefaultSprite ( img )
end

return UIImageRenderer