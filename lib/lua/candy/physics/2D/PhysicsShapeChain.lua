-- import
local PhysicsShape = require 'candy.physics.2D.PhysicsShape'
local ComponentModule = require 'candy.Component'

---@class PhysicsShapeChain : PhysicsShape
local PhysicsShapeChain = CLASS: PhysicsShapeChain ( PhysicsShape )
	:MODEL {
		Field ( "loc" ):no_edit (),
		Field ( "verts" ):array ( "number" ):getset ( "Verts" ):no_edit (),
		Field ( "looped" ):boolean ():isset ( "Looped" )
	}

ComponentModule.registerComponent ( "PhysicsShapeChain", PhysicsShapeChain )

function PhysicsShapeChain:__init ()
	self.looped = false
	self.boundRect = { 0,0,0,0 }
	self:setVerts ( { 0, 0, 100, 0 } )
end

function PhysicsShapeChain:setLooped ( looped )
	self.looped = looped
	self:updateVerts ()
end

function PhysicsShapeChain:isLooped ()
	return self.looped
end

function PhysicsShapeChain:onAttach ( ent )
	PhysicsShapeChain.__super.onAttach ( self, ent )
	self:updateVerts ()
end

function PhysicsShapeChain:getVerts ()
	return self.verts
end

function PhysicsShapeChain:setVerts ( verts )
	self.verts = verts
	self:updateVerts ()
end

function PhysicsShapeChain:updateVerts ()
	if not self._entity then
		return
	end

	local verts = self.verts
	local x0, y0, x1, y1 = nil

	for i = 1, #verts, 2 do
		local x = verts[ i ]
		local y = verts[ i + 1 ]
		x0 = x0 and  ( x < x0 and x or x0 ) or x
		y0 = y0 and  ( y < y0 and y or y0 ) or y
		x1 = x1 and  ( x1 < x and x or x1 ) or x
		y1 = y1 and  ( y1 < y and y or y1 ) or y
	end

	self.boundRect = {
		x0 or 0,
		y0 or 0,
		x1 or 0,
		y1 or 0
	}

	local count = #verts
	if count < 4 then
		return
	end

	self:updateShape ()
end

function PhysicsShapeChain:createShape ( body )
	local verts = self.verts
	local path = MOCKPolyPath.new ()
	local count = #verts / 2

	path:reserve ( count )

	for i = 1, count do
		local k =  ( i - 1 ) * 2
		local x = verts[ k + 1 ]
		local y = verts[ k + 2 ]
		path:setVert ( i, x, y )
	end

	path:clean ( 0.1 )

	local chain = body:addChain ( path:getVerts (), self:isLooped () )
	return chain
end

return PhysicsShapeChain