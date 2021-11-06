-- import
local UIWidgetModule = require 'candy.ui.light.UIWidget'
local UIWidget = UIWidgetModule.UIWidget
local ComponentModule = require 'candy.Component'
local Component = ComponentModule.Component

-- module
local UIViewMappingModule = {}

--------------------------------------------------------------------
local UIViewMappingRegistry = {}

function getUIViewMapping ( name )
	for mapping in pairs ( UIViewMappingRegistry ) do
		if mapping.name == name then
			return mapping
		end
	end
	return nil
end

--------------------------------------------------------------------
-- UIViewMapping
--------------------------------------------------------------------
---@class UIViewMapping : Component
local UIViewMapping = CLASS: UIViewMapping ( Component )
	:MODEL {
		Field "name" :string ()
	}

function UIViewMapping:__init ()
	self.name = "default"
end

function UIViewMapping:onAttach ( ent )
	UIViewMappingRegistry[ self ] = true
	emitGlobalSignal ( "ui.viewmapping.change" )
end

function UIViewMapping:onDetach ( ent )
	UIViewMappingRegistry[ self ] = nil
	emitGlobalSignal ( "ui.viewmapping.change" )
end

function UIViewMapping:wndToUI ( view, x, y )
	return self._entity:wndToWorld ( x, y )
end

function UIViewMapping:UIToWnd ( view, x, y )
	return self._entity:worldToWnd ( x, y )
end

--------------------------------------------------------------------
-- UIViewMapping
--------------------------------------------------------------------
---@class UIViewMappingRect : UIViewMapping
local UIViewMappingRect = CLASS: UIViewMappingRect ( UIViewMapping )
	:MODEL {
		Field "w";
		Field "h";
	}

ComponentModule.registerComponent ( "UIViewMappingRect", UIViewMappingRect )

function UIViewMappingRect:__init ()
	self.w = 100
	self.h = 100
end

function UIViewMappingRect:wndToUI ( view, x, y )
	local wx, wy = self._entity:wndToModel ( x, y )
	return wx, wy
end

function UIViewMappingRect:UIToWnd ( view, x, y )
	local wx, wy = self._entity:modelToWnd ( x, y )
	return wx, wy
end


UIViewMappingModule.UIViewMapping = UIViewMapping
UIViewMappingModule.UIViewMappingRect = UIViewMappingRect

return UIViewMappingModule