-- import
local AnimatorValueTrackModule = require 'candy.animator.AnimatorValueTrack'
local AnimatorValueKey = AnimatorValueTrackModule.AnimatorValueKey
local AnimatorTrackFieldDiscrete = require 'candy.animator.AnimatorTrackFieldDiscrete'

-- module
local AnimatorTrackFieldEnumModule = {}

---@class AnimatorKeyFieldEnum : AnimatorValueKey
local AnimatorKeyFieldEnum = CLASS: AnimatorKeyFieldEnum ( AnimatorValueKey )
	:MODEL {
		Field ( "value" ):selection ( "getTargetFieldEnumItems" ):string ()
	}

function AnimatorKeyFieldEnum:__init ()
	self.value = false
end

function AnimatorKeyFieldEnum:setValue ( value )
	self.value = value
end

function AnimatorKeyFieldEnum:getTargetFieldEnumItems ()
	local field = self:getTrack ().targetField
	local enum = field.__enum
	return enum
end

---@class AnimatorTrackFieldEnum : AnimatorTrackFieldDiscrete
local AnimatorTrackFieldEnum = CLASS: AnimatorTrackFieldEnum ( AnimatorTrackFieldDiscrete )

function AnimatorTrackFieldEnum:createKey ( pos, context )
	local key = AnimatorKeyFieldEnum ()
	key:setPos ( pos )

	local target = context.target
	key:setValue ( self.targetField:getValue ( target ) )

	return self:addKey ( key )
end

function AnimatorTrackFieldEnum:getIcon ()
	return "track_enum"
end


AnimatorTrackFieldEnumModule.AnimatorKeyFieldEnum = AnimatorKeyFieldEnum
AnimatorTrackFieldEnumModule.AnimatorTrackFieldEnum = AnimatorTrackFieldEnum

return AnimatorTrackFieldEnumModule