-- import
local AnimatorClipModule = require 'candy.animator.AnimatorClip'
local AnimatorTrack = AnimatorClipModule.AnimatorTrack
local AnimatorKey = AnimatorClipModule.AnimatorKey

-- module
local AnimatorValueTrackModule = {}

---@class AnimatorValueTrack : AnimatorTrack
local AnimatorValueTrack = CLASS: AnimatorValueTrack ( AnimatorTrack )
	:MODEL {}

---@class AnimatorValueKey : AnimatorKey
local AnimatorValueKey = CLASS: AnimatorValueKey ( AnimatorKey )
	:MODEL {}

---@class AnimatorKeyNumber : AnimatorValueKey
local AnimatorKeyNumber = CLASS: AnimatorKeyNumber ( AnimatorValueKey )
	:MODEL ( {
		Field ( "value" ):number ()
	} )

function AnimatorKeyNumber:__init ()
	self.length = 0
	self.value = 0
end

function AnimatorKeyNumber:isResizable ()
	return false
end

function AnimatorKeyNumber:toString ()
	return tostring ( self.value )
end

function AnimatorKeyNumber:setValue ( v )
	self.value = v
end

function AnimatorKeyNumber:getCurveValue ()
	return self.value
end

function AnimatorKeyNumber:setCurveValue ( v )
	return self:setValue ( v )
end

---@class AnimatorKeyInt : AnimatorKeyNumber
local AnimatorKeyInt = CLASS: AnimatorKeyInt ( AnimatorKeyNumber )
	:MODEL {
		Field ( "value" ):int ()
	}

local floor = math.floor
function AnimatorKeyInt:setValue ( v )
	self.value = floor ( v )
end

---@class AnimatorKeyBoolean : AnimatorValueKey
local AnimatorKeyBoolean = CLASS: AnimatorKeyBoolean ( AnimatorValueKey )
	:MODEL {
		Field ( "tweenMode" ):no_edit (),
		Field ( "value" ):boolean ()
	}

function AnimatorKeyBoolean:__init ()
	self.length = 0
	self.value = true
	self.tweenMode = 1
end

function AnimatorKeyBoolean:toString ()
	return tostring ( self.value )
end

function AnimatorKeyBoolean:setValue ( v )
	self.value = v and true or false
end

function AnimatorKeyBoolean:getCurveValue ()
	return self.value and 1 or 0
end

---@class AnimatorKeyString : AnimatorValueKey
local AnimatorKeyString = CLASS: AnimatorKeyString ( AnimatorValueKey )
	:MODEL {
		Field ( "value" ):string ()
	}

function AnimatorKeyString:__init ()
	self.length = 0
	self.value = ""
	self.tweenMode = 1
end

function AnimatorKeyString:isResizable ()
	return false
end

function AnimatorKeyString:toString ()
	return tostring ( self.value )
end

function AnimatorKeyString:setValue ( v )
	self.value = v and tostring ( v ) or ""
end

function AnimatorKeyString:getCurveValue ()
	return self.value and 1 or 0
end

AnimatorValueTrackModule.AnimatorValueTrack = AnimatorValueTrack
AnimatorValueTrackModule.AnimatorValueKey = AnimatorValueKey
AnimatorValueTrackModule.AnimatorKeyNumber = AnimatorKeyNumber
AnimatorValueTrackModule.AnimatorKeyInt = AnimatorKeyInt
AnimatorValueTrackModule.AnimatorKeyBoolean = AnimatorKeyBoolean
AnimatorValueTrackModule.AnimatorKeyString = AnimatorKeyString

return AnimatorValueTrackModule