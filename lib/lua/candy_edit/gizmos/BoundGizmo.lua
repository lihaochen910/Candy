-- import
local candy = require "candy"
local GizmoManagerModule = require "candy_edit.EditorCanvas.GizmoManager"
local Gizmo = GizmoManagerModule.Gizmo

--------------------------------------------------------------------
---@class SimpleBoundGizmo : Gizmo
local SimpleBoundGizmo = CLASS: SimpleBoundGizmo ( Gizmo )

function SimpleBoundGizmo:__init ()
	self.target = false
end

function SimpleBoundGizmo:onLoad ()
	self:attach ( candy.DrawScript () ):setBlend ( 'alpha' )
end

function SimpleBoundGizmo:setTarget( target )
	self.target = target
	self.drawBounds = target.drawBounds
end

function SimpleBoundGizmo:onDraw ()
	local drawBounds = self.drawBounds
	if drawBounds then
		applyColor 'selection'
		MOAIDraw.setPenWidth ( 1 )
		return drawBounds ( self.target )
	end	
end


--------------------------------------------------------------------
--Bind to core components
local function methodBuildBoundGizmo ( self )
	if self.drawBounds then		
		local giz = SimpleBoundGizmo ()
		giz:setTarget ( self )
		return giz
	end
end

local function installBoundGizmo ( clas )
	clas.onBuildSelectedGizmo = methodBuildBoundGizmo
end

-- TODO: installBoundGizmo
--installBoundGizmo( candy.DeckComponent )
--installBoundGizmo( candy.TexturePlane  )
--installBoundGizmo( candy.TextLabel     )
--installBoundGizmo( candy.MSprite       )

return SimpleBoundGizmo