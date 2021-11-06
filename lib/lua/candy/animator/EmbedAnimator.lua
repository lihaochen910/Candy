-- import
local Animator = require 'candy.animator.Animator'
local ComponentModule = require 'candy.Component'

-- module
local EmbedAnimatorModule = {}

local _clipDataCache = {}

local function loadEmbdedAnimatorData ( strData )
	local loadedData = _clipDataCache[ strData ]

	if loadedData then
		return loadedData
	end

	local animatorData = loadAnimatorDataFromString ( strData )
	_clipDataCache[ strData ] = animatorData

	return animatorData
end

---@class ExportAnimatorParam
local ExportAnimatorParam = CLASS: ExportAnimatorParam ()
	:MODEL {
		Field ( "animatorData" ):asset ( "animator_data" )
	}

---@class EmbedAnimator : Animator
local EmbedAnimator = CLASS: EmbedAnimator ( Animator )
	:MODEL {
		Field ( "serializedData" ):string ():no_edit ():getset ( "SerializedData" ),
		Field ( "data" ):asset ( "animator_data" ):no_edit ():no_save (),
		Field ( "uniqueKey" ):string ():no_edit (),
		"----",
		Field ( "exportData" ):action ( "toolActionExportData" )
	}

ComponentModule.registerComponent ( "EmbedAnimator", EmbedAnimator )

function EmbedAnimator:__init ()
	self.data = AnimatorData ()
	self.serializedData = ""
	self.uniqueKey = ""
end

function EmbedAnimator:onEditorInit ()
	self.data:createClip ( "default" )
	self.default = "default"
	self.uniqueKey = MOAIEnvironment.generateGUID ()
end

function EmbedAnimator:getSerializedData ()
	local serialized = serializeToString ( self.data, true )
	return serialized
end

function EmbedAnimator:setSerializedData ( strData )
	local animatorData = loadEmbdedAnimatorData ( strData )
	self.data = animatorData
end

function EmbedAnimator:toolActionExportData ()
	local param = ExportAnimatorParam ()

	if candy_edit.requestProperty ( "exporting animator data", param ) then
		if not param.animatorData then
			candy_edit.alertMessage ( "message", "no animator data specified", "info" )
			return false
		end

		local node = getAssetNode ( param.animatorData )
		candy.serializeToFile ( self.data, node:getObjectFile ( "data" ) )
		candy_edit.alertMessage ( "message", "animator data exported!", "info" )
	end
end


EmbedAnimatorModule.ExportAnimatorParam = ExportAnimatorParam
EmbedAnimatorModule.EmbedAnimator = EmbedAnimator

return EmbedAnimatorModule