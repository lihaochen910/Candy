-- import
local EntityModule = require 'candy.Entity'
local Entity = EntityModule.Entity

-- module
local GlobalManagerModule = {}

local rawget = rawget
local _GlobalManagerRegistry = setmetatable ( {}, { __no_traverse = true } )

local function getGlobalManagerRegistry ()
	return _GlobalManagerRegistry
end

---@class GlobalManager
local GlobalManager = CLASS: GlobalManager ()
	:MODEL {}

local _order = 0
local function _globlaManagerSortFunc ( a, b )
	local pa = a._priority
	local pb = b._priority

	if pa < pb then
		return true
	end

	if pb < pa then
		return false
	end

	return a._order < b._order
end

function GlobalManager:__init ()
	self._priority = self:getPriority ()

	assert ( not rawget ( self.__class, "_singleton" ) )
	rawset ( self.__class, "_singleton", self )

	self._order = _order
	_order = _order + 1
	local key = self:getKey ()

	if not key then
		return
	end

	for i, m in ipairs ( _GlobalManagerRegistry ) do
		if m:getKey () == key then
			_warn ( "duplciated global manager, overwrite", key )
			_GlobalManagerRegistry[ i ] = self
			return
		end
	end

	table.insert ( _GlobalManagerRegistry, self )
	table.sort ( _GlobalManagerRegistry, _globlaManagerSortFunc )
end

function GlobalManager.get ( clas )
	return rawget ( clas, "_singleton" )
end

function GlobalManager:getKey ()
	return self:getClassName ()
end

function GlobalManager:getPriority ()
	return 0
end

function GlobalManager:needUpdate ()
	return true
end

function GlobalManager:postInit ( game )
end

function GlobalManager:preInit ( game )
end

function GlobalManager:onInit ( game )
end

function GlobalManager:onStart ( game )
end

function GlobalManager:postStart ( game )
end

function GlobalManager:onStop ( game )
end

GlobalManager.onUpdate = false

function GlobalManager:saveConfig ()
end

function GlobalManager:loadConfig ( configData )
end

function GlobalManager:onSceneInit ( scene )
end

function GlobalManager:onSceneReset ( scene )
end

function GlobalManager:onSceneClear ( scene )
end

function GlobalManager:onSceneStart ( scene )
end

function GlobalManager:postSceneStart ( scene )
end

function GlobalManager:preSceneSave ( scene )
end

function GlobalManager:onSceneSave ( scene )
end

function GlobalManager:preSceneLoad ( scene )
end

function GlobalManager:onSceneLoad ( scene )
end


GlobalManagerModule.GlobalManager = GlobalManager
GlobalManagerModule.getGlobalManagerRegistry = getGlobalManagerRegistry

return GlobalManagerModule