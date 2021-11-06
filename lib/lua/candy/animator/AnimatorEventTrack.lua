-- import
local AnimatorClipModule = require 'candy.animator.AnimatorClip'
local AnimatorTrack = AnimatorClipModule.AnimatorTrack
local AnimatorKey = AnimatorClipModule.AnimatorKey

-- module
local AnimatorEventTrackModule = {}

---@class AnimatorEventTrack : AnimatorTrack
local AnimatorEventTrack = CLASS: AnimatorEventTrack ( AnimatorTrack )
	:MODEL {}

function AnimatorEventTrack:isPlayable ()
	return true
end

function AnimatorEventTrack:toString ()
	return ""
end

---@class AnimatorEventKey : AnimatorKey
local AnimatorEventKey = CLASS: AnimatorEventKey ( AnimatorKey ):MODEL {}

function AnimatorEventKey:isResizable ()
	return true
end


AnimatorEventTrackModule.AnimatorEventTrack = AnimatorEventTrack
AnimatorEventTrackModule.AnimatorEventKey = AnimatorEventKey

return AnimatorEventTrackModule