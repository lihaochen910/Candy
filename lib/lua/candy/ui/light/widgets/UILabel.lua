-- import
local UIWidgetModule = require 'candy.ui.light.UIWidget'
local UIWidget = UIWidgetModule.UIWidget
local EntityModule = require 'candy.Entity'

---@class UILabel : UIWidget
local UILabel = CLASS: UILabel ( UIWidget )
	:MODEL {
		Field "text" :string () :getset ( "Text" )
	}

EntityModule.registerEntity ( "UILabel", UILabel )

function UILabel:__init ()
	self.text = "Label Text"
	self.layoutPolicy = { "minimum", "minimum" }
	self.trackingPointer = false
	self.focusPolicy = false
end

function UILabel:getText ( t )
	return self.text
end

function UILabel:setText ( t )
	self.text = t
	self:invalidateContent ()
end

function UILabel:setI18NText ( t )
	return self:setText ( self:translate ( t ) )
end

function UILabel:getContentData ( key, role )
	if key == "text" then
		return self.text
	end
end

function UILabel:getMinSizeHint ( widthLimit, heightLimit )
	return 20, 20
end

return UILabel