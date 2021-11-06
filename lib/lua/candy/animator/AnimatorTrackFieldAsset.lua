-- import
local AnimatorValueTrackModule = require 'candy.animator.AnimatorValueTrack'
local AnimatorValueKey = AnimatorValueTrackModule.AnimatorValueKey
local AnimatorTrackFieldDiscrete = require 'candy.animator.AnimatorTrackFieldDiscrete'

-- module
local AnimatorTrackFieldAssetModule = {}

function _getTargetFieldAssetType ( key )
	return key:getTargetFieldAssetType ()
end

---@class AnimatorKeyFieldAsset : AnimatorValueKey
local AnimatorKeyFieldAsset = CLASS: AnimatorKeyFieldAsset ( AnimatorValueKey ) :MODEL ( {
	Field ( "value" ):asset ( _getTargetFieldAssetType )
} )

function AnimatorKeyFieldAsset:__init ()
	self.value = false
end

function AnimatorKeyFieldAsset:setValue ( assetPath )
	self.value = assetPath
end

function AnimatorKeyFieldAsset:getTargetFieldAssetType ()
	local field = self:getTrack ().targetField
	local assetType = field.__assettype

	if type ( assetType ) == "function" then
		local target = self:getTrack ():getEditorTargetObject ()
		return assetType ( target )
	else
		return assetType
	end
end

---@class AnimatorTrackFieldAsset : AnimatorTrackFieldDiscrete
local AnimatorTrackFieldAsset = CLASS: AnimatorTrackFieldAsset ( AnimatorTrackFieldDiscrete )

function AnimatorTrackFieldAsset:createKey ( pos, context )
	local key = AnimatorKeyFieldAsset ()
	key:setPos ( pos )

	local target = context.target
	key:setValue ( self.targetField:getValue ( target ) )

	return self:addKey ( key )
end

function AnimatorTrackFieldAsset:getIcon ()
	return "track_asset"
end


AnimatorTrackFieldAssetModule.AnimatorKeyFieldAsset = AnimatorKeyFieldAsset
AnimatorTrackFieldAssetModule.AnimatorTrackFieldAsset = AnimatorTrackFieldAsset

return AnimatorTrackFieldAssetModule