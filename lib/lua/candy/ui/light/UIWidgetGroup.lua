-- import
local UIWidgetModule = require 'candy.ui.light.UIWidget'
local UIWidget = UIWidgetModule.UIWidget
local EntityModule = require 'candy.Entity'

---@class UIWidgetGroup : UIWidget
local UIWidgetGroup = CLASS: UIWidgetGroup ( UIWidget )
	:MODEL {}

EntityModule.registerEntity ( "UIWidgetGroup", UIWidgetGroup )

function UIWidgetGroup:__init ()
	self.clippingChildren = false
	self.trackingPointer = false
end

return UIWidgetGroup