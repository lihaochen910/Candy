-- import
local EntityModule = require 'candy.Entity'
local Entity = EntityModule.Entity
local AnimatorEventTrackModule = require 'candy.animator.AnimatorEventTrack'
local AnimatorEventKey = AnimatorEventTrackModule.AnimatorEventKey
local AnimatorEventTrack = AnimatorEventTrackModule.AnimatorEventTrack

-- module
local PathFollowingAnimatorTrackModule = {}

---@class PathFollowingAnimatorKey : AnimatorEventKey
local PathFollowingAnimatorKey = CLASS: PathFollowingAnimatorKey ( AnimatorEventKey )
	:MODEL {
		Field ( "pathName" ):string (),
		Field ( "offset" ):type ( "vec3" ):getset ()
	}

function PathFollowingAnimatorKey:__init ()
end

function PathFollowingAnimatorKey:getOffset ()
	return unpack ( self.offset )
end

function PathFollowingAnimatorKey:setOffset ( x, y, z )
	self.offset = { x, y, z }
end


---@class PathFollowingAnimatorTrack : AnimatorEventTrack
local PathFollowingAnimatorTrack = CLASS: PathFollowingAnimatorTrack ( AnimatorEventTrack )
	:MODEL {}

function PathFollowingAnimatorTrack:getIcon ()
	return "track_vec3"
end

function PathFollowingAnimatorTrack:toString ()
	local pathText = self.targetPath:toString ()
	return pathText .. ":(Path Follow)"
end

function PathFollowingAnimatorTrack:isPreviewable ()
	return true
end

PathFollowingAnimatorTrackModule.PathFollowingAnimatorKey = PathFollowingAnimatorKey
PathFollowingAnimatorTrackModule.PathFollowingAnimatorTrack = PathFollowingAnimatorTrack

return PathFollowingAnimatorTrackModule