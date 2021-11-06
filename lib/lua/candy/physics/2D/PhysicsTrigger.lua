-- import
local PhysicsShape = require 'candy.physics.2D.PhysicsShape'
local ComponentModule = require 'candy.Component'
local Component = ComponentModule.Component

-- module
local PhysicsTriggerModule = {}

local function _triggerCollisionHandler ( phase, fixA, fixB, arb )
	local bodyA = fixA:getBody ()
	local ownerA = bodyA.component
	local bodyB = fixB:getBody ()
	local ownerB = bodyB.component

	if phase == MOAIBox2DArbiter.BEGIN then
		if ownerA.onCollisionEnter then
			ownerA:onCollisionEnter ( ownerB, fixA, fixB )
		end
	elseif ownerA.onCollisionExit then
		ownerA:onCollisionExit ( ownerB, fixA, fixB )
	end
end

---@class TriggerObjectBase : Component
local TriggerObjectBase = CLASS: TriggerObjectBase ( Component )
	:MODEL {
		Field ( "enterMessage" ):string (),
		Field ( "exitMessage" ):string ()
	}

function TriggerObjectBase:__init ()
	self.enterMessage = "collision.enter"
	self.exitMessage = "collision.exit"
end

function TriggerObjectBase:onAttach ( ent )
	local body = self:createBody ()
	self.body = body
	body:setSleepingAllowed ( false )

	local prop = ent:getProp ()
	body:setAttrLink ( MOAIProp.ATTR_X_LOC, prop, MOAIProp.ATTR_WORLD_X_LOC )
	body:setAttrLink ( MOAIProp.ATTR_Y_LOC, prop, MOAIProp.ATTR_WORLD_Y_LOC )
	body.component = self
	body:forceUpdate ()
	self:updateCollisionShape ()
end

function TriggerObjectBase:onDetach ()
	local body = self.body
	body:clearAttrLink ( MOAIProp.ATTR_X_LOC )
	body:clearAttrLink ( MOAIProp.ATTR_Y_LOC )
	body:destroy ()
end

function TriggerObjectBase:onStart ()
	self.active = true
end

function TriggerObjectBase:createBody ()
	local world = self:getScene ():getBox2DWorld ()
	local body = world:addBody ( MOAIBox2DBody.DYNAMIC )
	body:setGravityScale ( 0 )
	return body
end

function TriggerObjectBase:updateCollisionShape ()
	local body = self.body

	if not body then
		return
	end

	if self.shape then
		self.shape:destroy ()
	end

	local shape = body:addCircle ( 0, 0, self.radius )
	self.shape = shape

	self.shape:setSensor ( true )
	self:setupCollisionCallback ( self.shape )
end

function TriggerObjectBase:setupCollisionCallback ( shape )
	shape.component = self
	shape:setCollisionHandler ( _triggerCollisionHandler, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END )
end

function TriggerObjectBase:onCollisionEnter ( target )
	if not self.active then
		return
	end

	local msg = self.enterMessage or "collision.enter"
	self._entity:tell ( msg, target )
end

function TriggerObjectBase:onCollisionExit ( target )
	if not self.active then
		return
	end

	local msg = self.exitMessage or "collision.exit"
	self._entity:tell ( msg, target )
end


---@class TriggerObject : TriggerObjectBase
local TriggerObject = CLASS: TriggerObject ( TriggerObjectBase )
	:MODEL {
		"----",
		Field ( "radius" ):range ( 0 ):set ( "setRadius" )
	}

ComponentModule.registerComponent ( "TriggerObject", TriggerObject )

function TriggerObject:__init ()
	self.radius = 50
end

function TriggerObject:setRadius ( r )
	self.radius = r
	self:updateCollisionShape ()
end

function TriggerObject:createBody ()
	local world = self:getScene ():getBox2DWorld ()
	local body = world:addBody ( MOAIBox2DBody.DYNAMIC )
	body:setGravityScale ( 0 )
	return body
end


PhysicsTriggerModule.TriggerObjectBase = TriggerObjectBase
PhysicsTriggerModule.TriggerObject = TriggerObject

return PhysicsTriggerModule