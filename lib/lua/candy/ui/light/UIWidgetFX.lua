-- import
local Behaviour = require 'candy.common.Behaviour'

-- module
local UIWidgetFXModule = {}

local UIWidgetFXRegistry = {}

--------------------------------------------------------------------
-- UIWidgetFX
--------------------------------------------------------------------
---@class UIWidgetFX : Behaviour
local UIWidgetFX = CLASS: UIWidgetFX ( Behaviour )
	:MODEL {}

function UIWidgetFX.register ( clas, name )
	if UIWidgetFXRegistry[ name ] then
		_warn ( "duplicated uiwidget class", name )
	end

	UIWidgetFXRegistry[ name ] = clas
end

function UIWidgetFX:__init ()
end

--------------------------------------------------------------------
-- UIWidgetFXHolder
--------------------------------------------------------------------
---@class UIWidgetFXHolder
local UIWidgetFXHolder = CLASS: UIWidgetFXHolder ()

function UIWidgetFXHolder:__init ()
end

function UIWidgetFXHolder:updateVisual ( style )
end


UIWidgetFXModule.UIWidgetFX = UIWidgetFX
UIWidgetFXModule.UIWidgetFXHolder = UIWidgetFXHolder

return UIWidgetFXModule