-- import
local UIWidgetModule = require 'candy.ui.light.UIWidget'
local UIWidget = UIWidgetModule.UIWidget
local EntityModule = require 'candy.Entity'

---@class UISpacer : UIWidget	
local UISpacer = CLASS: UISpacer ( UIWidget )
	:MODEL {}

EntityModule.registerEntity ( "UISpacer", UISpacer )

function UISpacer:__init ()
	self.focusPolicy = false
end

function UISpacer:getDefaultRendererClass ()
	return false
end

return UISpacer