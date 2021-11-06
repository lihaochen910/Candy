-- import
local PhysicsShapeBox = require 'candy.physics.2D.PhysicsShapeBox'
local ComponentModule = require 'candy.Component'

---@class PhysicsShapeBevelBox : PhysicsShapeBox
local PhysicsShapeBevelBox = CLASS: PhysicsShapeBevelBox ( PhysicsShapeBox )
	:MODEL {
		Field ( "bevel" ):set ( "setBevel" ):range ( 0 )
	}

ComponentModule.registerComponent ( "PhysicsShapeBevelBox", PhysicsShapeBevelBox )

function PhysicsShapeBevelBox:__init ()
	self.bevel = 2
end

function PhysicsShapeBevelBox:setBevel ( b )
	self.bevel = b
	self:updateShape ()
end

function PhysicsShapeBevelBox:getLocalVerts ()
	local b = self.bevel
	local trans = MOAITransform.new ()
	trans:setRot ( 0, 0, self.rotation )
	trans:setLoc ( self:getLoc () )
	trans:forceUpdate ()

	local w = self.w
	local h = self.h
	local w2 = w / 2
	local h2 = h / 2
	b = math.min ( math.min ( b, w / 2 ), h / 2 )
	local srcVerts = {
		-w2,
		h2 - b,
		-w2 + b,
		h2,
		w2 - b,
		h2,
		w2,
		h2 - b,
		w2,
		-h2 + b,
		w2 - b,
		-h2,
		-w2 + b,
		-h2,
		-w2,
		-h2 + b
	}
	local verts = {}

	for i = 0, 7 do
		local x0 = srcVerts[ i * 2 + 1 ]
		local y0 = srcVerts[ i * 2 + 2 ]
		local x, y = trans:modelToWorld ( x0, y0 )
		table.insert ( verts, x )
		table.insert ( verts, y )
	end

	return verts
end

function PhysicsShapeBevelBox:createShape ( body )
	local b = self.bevel

	if b <= 0 then
		return PhysicsShapeBevelBox.__super.createShape ( self, body )
	end

	local verts = self:getLocalVerts ()
	return body:addPolygon ( verts )
end

return PhysicsShapeBevelBox