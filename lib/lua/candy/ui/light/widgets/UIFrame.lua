-- import
local UIWidgetModule = require 'candy.ui.light.UIWidget'
local UIWidget = UIWidgetModule.UIWidget
local UIFrameRenderer = require 'candy.ui.light.renderers.UIFrameRenderer'
local EntityModule = require 'candy.Entity'

---@class UIFrame : UIWidget
local UIFrame = CLASS: UIFrame ( UIWidget )
	:MODEL {}

function UIFrame:__init ()
	self.focusPolicy = false
	self:setClippingChildren ( true )
end

function UIFrame:getDefaultRendererClass ()
	return UIFrameRenderer
end


EntityModule.registerEntity ( "UIFrame", UIFrame )

return UIFrame