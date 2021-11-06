-- import
local UIWidgetRenderer = require 'candy.ui.light.UIWidgetRenderer'
local UIWidgetElementImage = require 'candy.ui.light.renderers.UIWidgetElementImage'

---@class UIFrameRenderer : UIWidgetRenderer
local UIFrameRenderer = CLASS: UIFrameRenderer ( UIWidgetRenderer )
	:MODEL {}

function UIFrameRenderer:onInit ( widget )
	self.bgElement = self:addElement ( UIWidgetElementImage (), "background", "background" )
	self.bgElement:setZOrder ( -1 )
end

return UIFrameRenderer