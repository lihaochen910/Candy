-- import
local UIWidgetRenderer = require 'candy.ui.light.UIWidgetRenderer'
local UIButtonBaseModule = require 'candy.ui.light.widgets.UIButtonBase'
local UIButtonBase = UIButtonBaseModule.UIButtonBase
local UIWidgetElementImage = require 'candy.ui.light.renderers.UIWidgetElementImage'
local DeckComponent = require 'candy.gfx.DeckComponent'
local EntityModule = require 'candy.Entity'

-- module
local UICheckBoxModule = {}

--------------------------------------------------------------------
-- UIButtonBase
--------------------------------------------------------------------
---@class UICheckBoxRenderer : UIWidgetRenderer
local UICheckBoxRenderer = CLASS: UICheckBoxRenderer ( UIWidgetRenderer )

function UICheckBoxRenderer:onInit ()
	self.slotElement = self:addElement ( UIWidgetElementImage (), "slot" )
	self.markElement = self:addElement ( UIWidgetElementImage (), "mark" )
end

function UICheckBoxRenderer:onUpdateContent ( widget, style )
	local checked = widget:getContentData ( "value", "render" )
	self.markElement:setVisible ( checked )
end


--------------------------------------------------------------------
-- UICheckBox
--------------------------------------------------------------------
---@class UICheckBox : UIButtonBase
local UICheckBox = CLASS: UICheckBox ( UIButtonBase )
	:MODEL {
		Field "checked" :boolean () :isset ( "Checked" );
	}
	:SIGNAL {
		valueChanged = "";
	}

function UICheckBox:__init ()
	self.checked = false
	self.markSprite = self:attachInternal ( DeckComponent () )
	self.markSprite:hide ()
	self:connect ( self.clicked, "toggleChecked" )
end

function UICheckBox:getDefaultRendererClass ()
	return UICheckBoxRenderer
end

function UICheckBox:toggleChecked ()
	return self:setChecked ( not self.checked )
end

function UICheckBox:setChecked ( checked )
	checked = checked and true or false

	if self.checked == checked then
		return
	end

	self.checked = checked
	self.valueChanged ( self.checked )
	self:invalidateContent ()
	self:setFeature ( "checked", checked )
end

function UICheckBox:isChecked ()
	return self.checked
end

function UICheckBox:getLabelRect ()
end

function UICheckBox:getContentData ( key, role )
	if key == "value" then
		return self.checked
	end
end


EntityModule.registerEntity ( "UICheckBox", UICheckBox )

UICheckBoxModule.UICheckBoxRenderer = UICheckBoxRenderer
UICheckBoxModule.UICheckBox = UICheckBox

return UICheckBoxModule