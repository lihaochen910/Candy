-- import
local AnimatorTrackFieldDiscrete = require 'candy.animator.AnimatorTrackFieldDiscrete'

---@class AnimatorTrackFieldString : AnimatorTrackFieldDiscrete
local AnimatorTrackFieldString = CLASS: AnimatorTrackFieldString ( AnimatorTrackFieldDiscrete )

function AnimatorTrackFieldString:createKey ( pos, context )
	local key = AnimatorKeyString ()
	key:setPos ( pos )

	local target = context.target
	key:setValue ( self.targetField:getValue ( target ) )

	return self:addKey ( key )
end

function AnimatorTrackFieldString:getIcon ()
	return "track_string"
end

return AnimatorTrackFieldString