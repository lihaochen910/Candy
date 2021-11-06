-- import
local candy = require "candy"
local GizmoManagerModule = require "candy_edit.EditorCanvas.GizmoManager"
local Gizmo = GizmoManagerModule.Gizmo

--------------------------------------------------------------------
---@class DrawScriptGizmo : Gizmo
local DrawScriptGizmo = CLASS: DrawScriptGizmo ( Gizmo )

function DrawScriptGizmo:__init ()
	self.drawProp = MOAIGraphicsProp.new ()
	self.drawDeck = MOAIDrawDeck.new ()
	self.drawProp:setDeck ( self.drawDeck )
	self.pickingTarget = false
end

function DrawScriptGizmo:setTransform ( transform )
	inheritLoc ( self:getProp (), transform )
end

function DrawScriptGizmo:setTarget ( object )
    local drawOwner, onDrawGizmo = nil

	if self.onDrawGizmo then
		onDrawGizmo = self.onDrawGizmo
		drawOwner = self
	elseif object.onDrawGizmo then
		onDrawGizmo = object.onDrawGizmo
		drawOwner = object
	end

	if onDrawGizmo then
		self.drawDeck:setDrawCallback ( function ( ... )
            local parent = self:getParent () ---@type GizmoManager
			return onDrawGizmo ( drawOwner, parent:isGizmoSelected ( self ), ... )
		end )
	end
end

function DrawScriptGizmo:setPickingTarget ( target )
	self.pickingTarget = target
end

local ATTR_LOCAL_VISIBLE = MOAIProp. ATTR_LOCAL_VISIBLE
local ATTR_VISIBLE = MOAIProp. ATTR_VISIBLE

function DrawScriptGizmo:setParentEntity ( entity, propRole )
	self:setPickingTarget ( entity )
	local prop = entity:getProp ( propRole or 'render' )
	-- inheritVisible ( self:getProp (), prop )
	inheritLoc ( self:getProp (), prop )
end

function DrawScriptGizmo:getPickingTarget ()
	return self.pickingTarget
end

function DrawScriptGizmo:onLoad ()
	self:_attachProp ( self.drawProp )
	
end

function DrawScriptGizmo:onDestroy ()
	Gizmo.onDestroy ( self )
	self:_detachProp ( self.drawProp )
end

function DrawScriptGizmo:isPickable ()
	return self.pickingTarget and true or false
end

function DrawScriptGizmo:getPickingProp ()
	return self.drawProp
end

return DrawScriptGizmo