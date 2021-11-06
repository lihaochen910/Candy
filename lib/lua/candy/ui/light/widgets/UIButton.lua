-- import
local UIButtonBaseModule = require 'candy.ui.light.widgets.UIButtonBase'
local UIButtonBase = UIButtonBaseModule.UIButtonBase
local UIButtonRenderer = require 'candy.ui.light.renderers.UIButtonRenderer'

---@class UIButton : UIButtonBase
local UIButton = CLASS: UIButton ( UIButtonBase )
	:MODEL {
		Field "text" :string (): getset ( "Text" )
	}

function UIButton:__init ()
	self.text = "Button"
end

function UIButton:getDefaultRendererClass ()
	return UIButtonRenderer
end

function UIButton:setText ( t )
	self.text = t
	self:invalidateContent ()
end

function UIButton:getText ()
	return self.text
end

function UIButton:setI18NText ( t )
	return self:setText ( self:translate ( t ) )
end

function UIButton:getContentData ( key, role )
	if key == "text" then
		return self:getText ()
	end
end

function UIButton:getLabelRect ()
	return self:getContentRect ()
end

return UIButton