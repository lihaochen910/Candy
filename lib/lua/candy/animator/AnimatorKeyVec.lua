-- import
local AnimatorValueTrackModule = require 'candy.animator.AnimatorValueTrack'
local AnimatorValueKey = AnimatorValueTrackModule.AnimatorValueKey

-- module
local AnimatorKeyVecModule = {}

---@class AnimatorKeyVec2 : AnimatorValueKey
local AnimatorKeyVec2 = CLASS: AnimatorKeyVec2 ( AnimatorValueKey )
	:MODEL {
		Field ( "value" ):type ( "vec2" ):getset ( "Value" )
	}

function AnimatorKeyVec2:__init ()
	self.y = 0
	self.x = 0
end

function AnimatorKeyVec2:getValue ()
	return self.x, self.y
end

function AnimatorKeyVec2:setValue ( x, y )
	self.y = y
	self.x = x
end

function AnimatorKeyVec2:isResizable ()
	return false
end

function AnimatorKeyVec2:toString ()
	return string.format ( "(.2f,.2f)", self.x, self.y )
end

---@class AnimatorKeyVec3 : AnimatorValueKey
local AnimatorKeyVec3 = CLASS: AnimatorKeyVec3 ( AnimatorValueKey ) :MODEL ( {
	Field ( "value" ):type ( "vec3" ):getset ( "Value" )
} )

function AnimatorKeyVec3:__init ()
	self.z = 0
	self.y = 0
	self.x = 0
end

function AnimatorKeyVec3:getValue ()
	return self.x, self.y, self.z
end

function AnimatorKeyVec3:setValue ( x, y, z )
	self.z = z
	self.y = y
	self.x = x
end

function AnimatorKeyVec3:isResizable ()
	return false
end

function AnimatorKeyVec3:toString ()
	return string.format ( "(.2f,.2f,.2f)", self.x, self.y, self.z )
end

AnimatorKeyVecModule.AnimatorKeyVec2 = AnimatorKeyVec2
AnimatorKeyVecModule.AnimatorKeyVec3 = AnimatorKeyVec3

return AnimatorKeyVecModule