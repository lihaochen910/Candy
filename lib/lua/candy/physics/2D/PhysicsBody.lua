-- import
local ComponentModule = require 'candy.Component'
local Component = ComponentModule.Component
local classHelperModule = require 'candy.ClassHelpers'

EnumBodyTransformSyncPolicy = _ENUM_V ( {
	"use_entity_transform",
	"use_body_transform",
	"smart_update"
} )

---@class PhysicsBody : Component
local PhysicsBody = CLASS: PhysicsBody ( Component )
	:MODEL {
		Field ( "active" ):boolean ():getset ( "Active" ),
		"----",
		Field ( "bodyDef" ):asset_pre ( "physics_body_def" ):getset ( "BodyDef" ),
		"----",
		Field ( "mass" ):getset ( "Mass" ),
		Field ( "transformSyncPolicy" ):enum ( EnumBodyTransformSyncPolicy ),
		Field ( "updateMassFromShape" ):boolean ()
	}
	:META {
		category = "physics"
	}

ComponentModule.registerComponent ( "PhysicsBody", PhysicsBody )

function PhysicsBody:__init ()
	self.bodyDef = false
	self.bodyDefPath = false
	self.updateMassFromShape = false
	self.bodyReady = false
	self.body = false
	self.joints = {}
	self.mass = 0
	self.bodyType = "dynamic"
	self.useEntityTransform = false
	self.transformSyncPolicy = "use_body_transform"
	self._bodyActive = true
end

function PhysicsBody:onAttach ( entity )
	local body = self:createBody ( entity )
	self.body = body
	self.body.component = self
	local prop = entity:getProp ( "physics" )

	body:setAttrLink ( MOAIProp.ATTR_X_LOC, prop, MOAIProp.ATTR_WORLD_X_LOC )
	body:setAttrLink ( MOAIProp.ATTR_Y_LOC, prop, MOAIProp.ATTR_WORLD_Y_LOC )
	body:setAttrLink ( MOAIProp.ATTR_Z_LOC, prop, MOAIProp.ATTR_WORLD_Z_LOC )
	body:setAttrLink ( MOAIProp.ATTR_Z_ROT, prop, MOAIProp.ATTR_WORLD_Z_ROT )
	self:updateBodyDef ()

	for com in pairs ( entity:getComponents () ) do
		if isInstance ( com, PhysicsShape ) then
			com:updateParentBody ( self )
		end
	end

	for j in pairs ( self.joints ) do
		j:updateJoint ()
	end

	for com in pairs ( entity:getComponents () ) do
		if isInstance ( com, PhysicsJoint ) then
			com:updateParentBody ( self )
		end
	end

	self.bodyReady = true

	self:updateMass ()
	body:setActive ( false )
	self.body:forceUpdate ()
end

function PhysicsBody:getMoaiBody ()
	return self.body
end

function PhysicsBody:onStart ( entity )
	self.body:setActive ( self._bodyActive )
	self:updateTransformSyncPolicy ( entity )
	self:updateMass ()
end

function PhysicsBody:onSuspend ()
	self.body:setActive ( false )
end

function PhysicsBody:onResurrect ()
	self.body:setActive ( self._bodyActive )
end

function PhysicsBody:setTransformSyncPolicy ( policy )
	self.transformSyncPolicy = policy
	if self:isEntityStarted () then
		return self:updateTransformSyncPolicy ( self._entity )
	end
end

function PhysicsBody:updateTransformSyncPolicy ( entity )
	local prop = entity:getProp ( "physics" )
	local body = self.body
	local policy = self.transformSyncPolicy

	if policy == "use_body_transform" then
		body:clearAttrLink ( MOAIProp.ATTR_X_LOC )
		body:clearAttrLink ( MOAIProp.ATTR_Y_LOC )
		body:clearAttrLink ( MOAIProp.ATTR_Z_LOC )
		body:clearAttrLink ( MOAIProp.ATTR_Z_ROT )
		prop:setAttrLink ( MOCKProp.SYNC_WORLD_LOC_2D, body, MOAIProp.TRANSFORM_TRAIT )
	elseif policy == "use_entity_transform" then
		prop:clearAttrLink ( MOCKProp.SYNC_WORLD_LOC_2D )
		body:setAttrLink ( MOAIProp.ATTR_X_LOC, prop, MOAIProp.ATTR_WORLD_X_LOC )
		body:setAttrLink ( MOAIProp.ATTR_Y_LOC, prop, MOAIProp.ATTR_WORLD_Y_LOC )
		body:setAttrLink ( MOAIProp.ATTR_Z_LOC, prop, MOAIProp.ATTR_WORLD_Z_LOC )
		body:setAttrLink ( MOAIProp.ATTR_Z_ROT, prop, MOAIProp.ATTR_WORLD_Z_ROT )
	end
end

function PhysicsBody:onDetach ( entity )
	if self.body then
		local body = self.body
		body:clearAttrLink ( MOAIProp.ATTR_X_LOC )
		body:clearAttrLink ( MOAIProp.ATTR_Y_LOC )
		body:clearAttrLink ( MOAIProp.ATTR_Z_LOC )
		body:clearAttrLink ( MOAIProp.ATTR_Z_ROT )

		local prop = entity:getProp ( "physics" )
		prop:clearAttrLink ( MOAIProp.ATTR_Z_ROT )
		prop:clearAttrLink ( MOCKProp.SYNC_WORLD_LOC_2D )

		self.body = false

		body:destroy ()
	end
end

local bodyTypeNames = {
	dynamic = MOAIBox2DBody.DYNAMIC,
	static = MOAIBox2DBody.STATIC,
	kinematic = MOAIBox2DBody.KINEMATIC
}

function PhysicsBody:getBox2DWorld ()
	return self._entity.scene:getBox2DWorld ()
end

function PhysicsBody:createBody ( entity )
	local world = self:getBox2DWorld ()
	local body = world:addBody ( bodyTypeNames[ self.bodyType ] or MOAIBox2DBody.DYNAMIC )
	return body
end

function PhysicsBody:setBodyDef ( path )
	self.bodyDefPath = path

	if path then
		self.bodyDef = candy.loadAsset ( path )
	end

	self:updateBodyDef ()
end

function PhysicsBody:getBodyDef ()
	return self.bodyDefPath
end

function PhysicsBody:updateBodyDef ()
	self:applyBodyDef ( self.bodyDef )
end

function PhysicsBody:applyBodyDef ( def )
	if not self.body then
		return
	end

	local def = def or getDefaultPhysicsBodyDef ()
	local body = self.body
	body:setType ( bodyTypeNames[ def.bodyType ] or MOAIBox2DBody.DYNAMIC )
	body:setFixedRotation ( def.fixedRotation )
	body:setSleepingAllowed ( def.allowSleep )
	body:setBullet ( def.isBullet )
	body:setGravityScale ( def.gravityScale )
	body:setLinearDamping ( def.linearDamping )
	body:setAngularDamping ( def.angularDamping )
end

function PhysicsBody:setType ( bodyType )
	if not self.body then
		return
	end

	self.body:setType ( bodyTypeNames[ bodyType ] or MOAIBox2DBody.DYNAMIC )
	self.bodyType = bodyType

	self:updateTransformSyncPolicy ( self._entity )
	self:updateMass ()
end

function PhysicsBody:getType ()
	return self.bodyType
end

function PhysicsBody:setGravityScale ( s )
	if self.body then
		self.body:setGravityScale ( s )
	end
end

function PhysicsBody:setMass ( mass )
	self.mass = mass
	self:updateMass ()
end

function PhysicsBody:getMass ()
	return self.mass
end

function PhysicsBody:updateMass ()
	if not self.bodyReady then
		return
	end

	if self.updateMassFromShape then
		self.body:resetMassData ()
	else
		self.body:setMassData ( self.mass )
	end
end

function PhysicsBody:testMass ()
	print ( self.mass )
end

function PhysicsBody:calcMass ()
	local deck = self._entity:com ( candy.DeckComponent )

	if deck then
		local x1, y1, z1, x2, y2, z2 = deck.prop:getBounds ()
		local w = x2 - x1
		local h = y2 - y1
		local radius =  ( w + h ) / 4
		local linearWeight = radius * 0.1
		self:setMass ( linearWeight * linearWeight )
	end
end

function PhysicsBody:getDefaultMaterial ()
	if self.bodyDef then
		local materialPath = self.bodyDef.defaultMaterial

		if materialPath then
			return loadAsset ( materialPath )
		end
	end

	return false
end

function PhysicsBody:_removeJoint ( j )
	self.joints[ j ] = nil
end

function PhysicsBody:_addJoint ( j )
	self.joints[ j ] = true
end

function PhysicsBody:setPosition ( x, y )
	local body = self.body
	local angle = body:getAngle ()
	body:setTransform ( x, y, angle )
end

function PhysicsBody:setAngle ( dir )
	local body = self.body
	local x, y = body:getPosition ()
	body:setTransform ( x, y, dir )
end

function PhysicsBody:addPosition ( dx, dy )
	local x, y = self:getPosition ()
	return self:setPosition ( x + dx, y + dy )
end

function PhysicsBody:addLinearVelocity ( dx, dy )
	local vx, vy = self:getLinearVelocity ()
	return self:setLinearVelocity ( vx + dx, vy + dy )
end

function PhysicsBody:addAngle ( da )
	local a = self:getAngle ()
	return self:setAngle ( da + a )
end

function PhysicsBody:getTag ()
	if self.bodyDef then
		return self.bodyDef.tag
	end

	return nil
end

function PhysicsBody:setActive ( active )
	self._bodyActive = active

	if self.body then
		self.body:setActive ( active )
	end
end

function PhysicsBody:isActive ()
	return self._bodyActive
end

function PhysicsBody:getActive ()
	return self._bodyActive
end

function PhysicsBody:refresh ()
	local body = self.body

	if not body then
		return
	end

	local act = body:isActive ()

	body:setActive ( not act )
	body:setActive ( act )
end

function PhysicsBody:refreshActive ()
	local body = self.body

	if not body then
		return
	end

	local act = body:isActive ()

	if not act then
		return
	end

	body:setActive ( false )
	body:setActive ( true )
end

local ATTR_X_LOC = MOAITransform.ATTR_X_LOC
local ATTR_Y_LOC = MOAITransform.ATTR_Y_LOC

function PhysicsBody:seekPosition ( x, y, duration, mode )
	local body = self.body
	local action = MOAICoroutine.new ()

	action:run ( function  ()
		local t = 0

		if duration <= 0 then
			return self:setPosition ( x, y )
		end

		local x0, y0 = self:getPosition ()
		while true do
			t = t + coroutine.yield ()
			local k = math.min ( t / duration, 1 )
			local x1 = lerp ( x0, x, k )
			local y1 = lerp ( y0, y, k )
			self:setPosition ( x1, y1 )

			if k == 1 then
				return
			end
		end
	end )

	return action
end

function PhysicsBody:movePosition ( dx, dy, duration, mode )
	local x, y = self:getPosition ()
	return self:seekPosition ( x + dx, y + dy, duration, mode )
end


local MOAIBox2DBodyIT = MOAIBox2DBody.getInterfaceTable ()
classHelperModule.wrapMoaiMethods ( MOAIBox2DBodyIT, PhysicsBody, "body", {
	"applyAngularImpulse@",
	"applyForce@",
	"applyLinearImpulse@",
	"applyTorque@",
	"getAngle",
	"getAngularVelocity",
	"getContactList",
	"getInertia",
	"getGravityScale",
	"getLinearVelocity",
	"getLocalCenter",
	"getMass",
	"getPosition",
	"getWorldCenter",
	"isActive",
	"isAwake",
	"isBullet",
	"isFixedRotation",
	"resetMassData",
	"setAngularDamping@",
	"setAngularVelocity@",
	"setAwake@",
	"setBullet@",
	"setFixedRotation@",
	"setLinearDamping@",
	"setLinearVelocity@",
	"setMassData@",
	"setTransform@"
} )

function installPhysicsPostUpdate ( klass )
	function klass:addPostPhysicsCallback ( func )
		local ent = self:getEntity ()
		local action = ent:callAsAction ( func )
		ent:setActionPriority ( action, 8 )
	end
	updateAllSubClasses ( klass )
end

return PhysicsBody