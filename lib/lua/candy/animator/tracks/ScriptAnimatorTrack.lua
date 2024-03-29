-- import
local EntityModule = require 'candy.Entity'
local Entity = EntityModule.Entity
local AnimatorEventTrackModule = require 'candy.animator.AnimatorEventTrack'
local AnimatorEventKey = AnimatorEventTrackModule.AnimatorEventKey
local AnimatorEventTrack = AnimatorEventTrackModule.AnimatorEventTrack

-- module
local ScriptAnimatorTrackModule = {}

local defaultScript = "--Builtin Variable: self = Target Entity/Component;  time = current Time;\n"
local scriptHeader = "local self = ...\n"
local scriptTail = ""
local scriptMT = { __index = _G }

---@class ScriptAnimatorKey : AnimatorEventKey
local ScriptAnimatorKey = CLASS: ScriptAnimatorKey ( AnimatorEventKey )
	:MODEL {
		Field ( "script" ):string ():widget ( "codebox" ),
		Field ( "desc" ):string (),
		Field ( "isCoroutine" ):boolean ()
	}

function ScriptAnimatorKey:__init ()
	self.script = defaultScript
	self.isCoroutine = false
	self.compiledFunc = false
	self.desc = "Script"
end

function ScriptAnimatorKey:buildScript ()
	self.compiledFunc = false
	local script = self.script
	local finalScript = scriptHeader .. self.script .. scriptTail
	local func, err = loadstring ( finalScript, "track-script" )

	if not func then
		return _error ( err )
	end

	local envTable = setmetatable ( {}, scriptMT )
	setfenv ( func, envTable )
	self.compiledFunc = func
end

function ScriptAnimatorKey:toString ()
	return self.desc
end


---@class ScriptAnimatorTrack : AnimatorEventTrack
local ScriptAnimatorTrack = CLASS: ScriptAnimatorTrack ( AnimatorEventTrack ):MODEL {}

function ScriptAnimatorTrack:getIcon ()
	return "track_script"
end

function ScriptAnimatorTrack:toString ()
	local pathText = self.targetPath:toString ()
	return pathText .. ":(Script)"
end

function ScriptAnimatorTrack:isPreviewable ()
	return false
end

function ScriptAnimatorTrack:createKey ( pos, context )
	local key = ScriptAnimatorKey ()
	key:setPos ( pos )
	self:addKey ( key )
	return key
end

function ScriptAnimatorTrack:build ( context )
	self.idCurve = self:buildIdCurve ()

	context:updateLength ( self:calcLength () )

	for i, key in pairs ( self.keys ) do
		key:buildScript ()
	end
end

function ScriptAnimatorTrack:onStateLoad ( state )
	local rootEntity, scene = state:getTargetRoot ()
	local target = self.targetPath:get ( rootEntity, scene )
	local playContext = { target, 0 }
	state:addUpdateListenerTrack ( self, playContext )
end

function ScriptAnimatorTrack:apply ( state, playContext, t )
	local target = playContext[ 1 ]
	local keyId = playContext[ 2 ]
	local newId = self.idCurve:getValueAtTime ( t )

	if keyId ~= newId then
		local key = self.keys[ newId ]
		playContext[ 2 ] = newId

		if newId > 0 then
			if not key.isCoroutine then
				key.compiledFunc ( target, t )
			end
		end
	end
end

function ScriptAnimatorTrack:reset ( state, playContext )
end


registerCommonCustomAnimatorTrackType ( "Script", ScriptAnimatorTrack )

ScriptAnimatorTrackModule.ScriptAnimatorKey = ScriptAnimatorKey
ScriptAnimatorTrackModule.ScriptAnimatorTrack = ScriptAnimatorTrack

return ScriptAnimatorTrackModule