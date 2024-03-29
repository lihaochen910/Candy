-- import
local AnimatorTrackField = require 'candy.animator.AnimatorTrackField'

---@class AnimatorTrackFieldDiscrete : AnimatorTrackField
local AnimatorTrackFieldDiscrete = CLASS: AnimatorTrackFieldDiscrete ( AnimatorTrackField )

function AnimatorTrackFieldDiscrete:build ( context )
	self.idCurve = self:buildIdCurve ()
	context:updateLength ( self:calcLength () )
end

function AnimatorTrackFieldDiscrete:onStateLoad ( state )
	local rootEntity, scene = state:getTargetRoot ()
	local target = self.targetPath:get ( rootEntity, scene )
	local context = { target, 0 }
	state:addUpdateListenerTrack ( self, context )
end

function AnimatorTrackFieldDiscrete:apply ( state, context, t )
	local target = context[ 1 ]
	local keyId = context[ 2 ]
	local newId = self.idCurve:getValueAtTime ( t )

	if newId > 0 then
		local value = self.keys[ newId ].value
		context[ 2 ] = newId
		return self.targetField:setValue ( target, value )
	end
end

function AnimatorTrackFieldDiscrete:reset ( state, context )
	context[ 2 ] = 0
end

return AnimatorTrackFieldDiscrete