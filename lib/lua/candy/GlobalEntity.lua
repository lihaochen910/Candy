-- import
local EntityModule = require 'candy.Entity'
local Entity = EntityModule.Entity

-- module
local GlobalEntityModule = {}

---@class GlobalEntity : Entity
local GlobalEntity = CLASS:GlobalEntity ( Entity )

local _globalInstances = {}
local _globalInstancesTraceback = {}

function GlobalEntity:__init ()
	local clas = self.__class

	if _globalInstances[ clas ] then
		print ( "------" )
		print ( _globalInstancesTraceback[ clas ] )
		print ( "------" )

		return error ( "global entity already created:" .. clas.__name, 2 )
	end

	_globalInstances[ clas ] = self
	_globalInstancesTraceback[ clas ] = debug.traceback ()
end

local _destroyNow = Entity._destroyNow

function GlobalEntity:_destroyNow ( ... )
	local clas = self.__class
	assert ( _globalInstances[ clas ] == self )
	_globalInstances[ clas ] = nil
	return _destroyNow ( self, ... )
end

function GlobalEntity.get ( clas )
	return _globalInstances[ clas ]
end

local function SingleEntity ( component )
	local e = Entity ()
	e:attach ( component )
	return e
end

local function SimpleEntity ( componentTable )
	local e = Entity ()

	for k, com in pairs ( componentTable ) do
		e[ k ] = e:attach ( com )
	end

	return e
end

GlobalEntityModule.GlobalEntity = GlobalEntity
GlobalEntityModule.SingleEntity = SingleEntity
GlobalEntityModule.SimpleEntity = SimpleEntity

return GlobalEntityModule