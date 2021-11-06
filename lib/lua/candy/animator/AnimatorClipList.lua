-- import
local AnimatorClipModule = require 'candy.animator.AnimatorClip'
local AnimatorClip = AnimatorClipModule.AnimatorClip

-- module
local AnimatorClipListModule = {}

EnumClipListMode = _ENUM_V {
	"sequence",
	"random",
	"shuffle"
}

---@class AnimatorClipListEntry
local AnimatorClipListEntry = CLASS: AnimatorClipListEntry ()
	:MODEL {
		Field ( "weight" ):number (),
		"----",
		Field ( "clip" ):string ():selection ( "getClipNames" ),
		Field ( "playMode" ):enum ( EnumTimerMode ),
		Field ( "throttle" ):float ():meta ( {
			step = 0.1
		} )
	}

function AnimatorClipListEntry:__init ()
	self.weight = 1
	self.clip = false
	self.mode = false
	self.duration = -1
end

---@class AnimatorClipList : AnimatorClip
local AnimatorClipList = CLASS: AnimatorClipList ( AnimatorClip )
	:MODEL {
		Field ( "clips" ):array ( "string" ):no_edit (),
		Field ( "mode" ):enum ( EnumClipListMode ),
		Field ( "duration" )
	}

function AnimatorClipList:__init ()
	self.clips = {}
	self.mode = "sequence"
	self.duration = -1
end


AnimatorClipListModule.AnimatorClipListEntry = AnimatorClipListEntry
AnimatorClipListModule.AnimatorClipList = AnimatorClipList

return AnimatorClipListModule