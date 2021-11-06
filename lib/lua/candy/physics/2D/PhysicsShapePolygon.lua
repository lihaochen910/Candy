-- import
local PhysicsShape = require 'candy.physics.2D.PhysicsShape'
local ComponentModule = require 'candy.Component'

-- module
local PhysicsShapePolygonModule = {}

---@class Box2DShapeGroupProxy
local Box2DShapeGroupProxy = CLASS: Box2DShapeGroupProxy ()

function Box2DShapeGroupProxy:__init ()
	self.shapes = {}
	self.categoryBits = 0
	self.maskBits = 0
	self.group = 0
	self.friction = 1
	self.restitution = 1
	self.sensor = false
end

function Box2DShapeGroupProxy:getFilter ()
	return self.categoryBits, self.maskBits, self.group
end

function Box2DShapeGroupProxy:setFilter ( categoryBits, maskBits, group )
	self.group = group
	self.maskBits = maskBits
	self.categoryBits = categoryBits
	for i, shape in ipairs ( self.shapes ) do
		shape:setFilter ( categoryBits, maskBits, group )
	end
end

function Box2DShapeGroupProxy:getDensity ()
	return self.density
end

function Box2DShapeGroupProxy:setDensity ( density )
	self.density = density
	for i, shape in ipairs ( self.shapes ) do
		shape:setDensity ( density )
	end
end

function Box2DShapeGroupProxy:getFriction ()
	return self.friction
end

function Box2DShapeGroupProxy:setFriction ( friction )
	self.friction = friction
	for i, shape in ipairs ( self.shapes ) do
		shape:setFriction ( friction )
	end
end

function Box2DShapeGroupProxy:getRestitution ()
	return self.restitution
end

function Box2DShapeGroupProxy:setRestitution ( restitution )
	self.restitution = restitution
	for i, shape in ipairs ( self.shapes ) do
		shape:setRestitution ( restitution )
	end
end

function Box2DShapeGroupProxy:isSensor ()
	return self.sensor
end

function Box2DShapeGroupProxy:setSensor ( sensor )
	self.sensor = sensor
	for i, shape in ipairs ( self.shapes ) do
		shape:setSensor ( sensor )
	end
end

function Box2DShapeGroupProxy:destroy ()
	for i, shape in ipairs ( self.shapes ) do
		shape:destroy ()
	end
end

function Box2DShapeGroupProxy:setCollisionHandler ( func, phaseMask, categoryMask )
	self.collisionFunc = func
	self.collisionPhaseMask = phaseMask
	self.collisionCategoryMask = categoryMask
	for i, shape in ipairs ( self.shapes ) do
		shape:setCollisionHandler ( func, phaseMask, categoryMask )
	end
end

function Box2DShapeGroupProxy:getCollisionHandler ()
	return self.collisionFunc, self.collisionPhaseMask, self.collisionCategoryMask
end

function Box2DShapeGroupProxy:addShape ( shape )
	table.insert ( self.shapes, shape )
end

---@class PhysicsShapePolygon : PhysicsShape
local PhysicsShapePolygon = CLASS: PhysicsShapePolygon ( PhysicsShape )
	:MODEL {
		Field ( "verts" ):array ():no_edit (),
		Field ( "resetShape" ):action ()
	}

ComponentModule.registerComponent ( "PhysicsShapePolygon", PhysicsShapePolygon )

function PhysicsShapePolygon:resetShape ()
	self:__init ()
end

function PhysicsShapePolygon:__init ()
	self.verts = {
		20,
		-20,
		-20,
		-20,
		0,
		20
	}
	self.aabb = {
		0,
		0,
		0,
		0
	}
end

function PhysicsShapePolygon:setVerts ( verts )
	self.verts = verts
	self:updateShape ()
end

function PhysicsShapePolygon:getVerts ()
	return self.verts
end

function PhysicsShapePolygon:createShape ( body )
	self.aabb = {
		calcAABB ( self.verts )
	}
	local option = {
		maxPolygonSize = 8,
		nearThreshold = 2
	}
	local convexPolygons = PolygonHelper.convexPartition ( self.verts, option )
	local proxy = Box2DShapeGroupProxy ()

	for i, poly in ipairs ( convexPolygons ) do
		local poly = body:addPolygon ( poly )
		poly.component = self
		proxy:addShape ( poly )
	end

	return proxy
end

function PhysicsShapePolygon:getLocalVerts ( steps )
	return table.reversed2 ( self.verts )
end


PhysicsShapePolygonModule.Box2DShapeGroupProxy = Box2DShapeGroupProxy
PhysicsShapePolygonModule.PhysicsShapePolygon = PhysicsShapePolygon

return PhysicsShapePolygonModule