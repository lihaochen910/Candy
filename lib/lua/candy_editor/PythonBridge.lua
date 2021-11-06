-- module
local PythonBridgeModule = {}

local rawget, rawset = rawget, rawset
local bridge = CANDY_PYTHON_BRIDGE

-- 在非编辑器的情况下
if not bridge then return setmetatable ( PythonBridgeModule, { __index = function  () return function  () end end } ) end

--------------------------------------------------------------------
-- CORE FUNCTIONS
--------------------------------------------------------------------

--communication
PythonBridgeModule.emitPythonSignal     = bridge.emitPythonSignal
PythonBridgeModule.emitPythonSignalNow  = bridge.emitPythonSignalNow
PythonBridgeModule.connectPythonSignal  = bridge.connectPythonSignal
PythonBridgeModule.registerPythonSignal = bridge.registerPythonSignal

--data
PythonBridgeModule.sizeOfPythonObject   = bridge.sizeOfPythonObject
PythonBridgeModule.newPythonDict        = bridge.newPythonDict
PythonBridgeModule.newPythonList        = bridge.newPythonList
PythonBridgeModule.appendPythonList     = bridge.appendPythonList
PythonBridgeModule.deletePythonList     = bridge.deletePythonList
PythonBridgeModule.getDict              = bridge.getDict
PythonBridgeModule.setDict              = bridge.setDict
--other
PythonBridgeModule.throwPythonException = bridge.throwPythonException
PythonBridgeModule.getTime              = bridge.getTime
PythonBridgeModule.generateGUID         = bridge.generateGUID
PythonBridgeModule.showAlertMessage	 	= bridge.showAlertMessage
PythonBridgeModule.pyLogInfo   		 	= bridge.pyLogInfo
PythonBridgeModule.pyLogWarn   		 	= bridge.pyLogWarn
PythonBridgeModule.pyLogError			= bridge.pyLogError

--import
PythonBridgeModule.importPythonModule   = bridge.importModule
--------------------------------------------------------------------
--communication
PythonBridgeModule.emitPythonSignal     = bridge.emitPythonSignal
PythonBridgeModule.emitPythonSignalNow  = bridge.emitPythonSignalNow
PythonBridgeModule.connectPythonSignal  = bridge.connectPythonSignal
PythonBridgeModule.registerPythonSignal = bridge.registerPythonSignal

--data
PythonBridgeModule.sizeOfPythonObject   = bridge.sizeOfPythonObject
PythonBridgeModule.newPythonDict        = bridge.newPythonDict
PythonBridgeModule.newPythonList        = bridge.newPythonList
PythonBridgeModule.appendPythonList     = bridge.appendPythonList
PythonBridgeModule.deletePythonList     = bridge.deletePythonList
PythonBridgeModule.getDict              = bridge.getDict
PythonBridgeModule.setDict              = bridge.setDict
--other
PythonBridgeModule.throwPythonException = bridge.throwPythonException
PythonBridgeModule.getTime              = bridge.getTime
PythonBridgeModule.generateGUID         = bridge.generateGUID
PythonBridgeModule.showAlertMessage		= bridge.showAlertMessage

--import
PythonBridgeModule.importPythonModule   = bridge.importModule

MOAIEnvironment.generateGUID = bridge.generateGUID

--data conversion
local encodeDict = bridge.encodeDict
local decodeDict = bridge.decodeDict

local function tableToDict ( table )
	local json = MOAIJsonParser.encode ( table )
	return decodeDict ( json )
end

local function tableToList ( table )
	local list = bridge.newPythonList  ()
	for i, v in ipairs ( table ) do
		appendPythonList ( list,v )
	end
	return list
end

local function dictToTable ( dict )
	local json = encodeDict ( dict )
	return MOAIJsonParser.decode ( json )
end

local function dictToTablePlain ( dict ) --just one level?
	local t = {}
	for k in python.iter ( dict ) do
		t[ k ] = dict[ k ]
	end
	return t	
end


local _sizeOf = bridge.sizeOfPythonObject
local function listToTable ( list )
	local c = _sizeOf ( list )
	local r = {}
	for i = 1, c do
		r[ i ] = list[ i - 1 ]
	end
	return r
end

local function unpackPythonList ( t )
	return unpack ( listToTable ( t ) )
end

PythonBridgeModule.tableToDict 		= tableToDict
PythonBridgeModule.tableToList		= tableToList
PythonBridgeModule.dictToTable		= dictToTable
PythonBridgeModule.dictToTablePlain	= dictToTablePlain
PythonBridgeModule.listToTable		= listToTable
PythonBridgeModule.unpackPythonList	= unpackPythonList

--------------------------------------------------------------------
-- EDITOR RELATED
--------------------------------------------------------------------
local function changeSelection ( key, obj, ... )
	assert ( type ( key ) == 'string', 'selection key expected' )
	if obj then
		bridge.changeSelection ( key, newPythonList ( obj, ... ) )
	else
		bridge.changeSelection ( key, nil )
	end
end

local function addSelection ( key, obj, ... )
	assert ( type ( key ) == 'string', 'selection key expected' )
	if obj then
		bridge.addSelection ( key, newPythonList ( obj, ... ) )
	else
		bridge.addSelection ( key, nil )
	end
end

local function removeSelection( key, obj, ... )
	assert ( type ( key ) == 'string', 'selection key expected' )
	if obj then
		bridge.removeSelection( key, newPythonList ( obj,... ) )
	else
		bridge.removeSelection( key, nil )
	end
end

local function toggleSelection ( key, obj, ... )
	assert ( type ( key ) == 'string', 'selection key expected' )
	if obj then
		bridge.toggleSelection ( key, newPythonList ( obj,... ) )
	else
		bridge.toggleSelection ( key, nil )
	end
end

local function getSelection ( key )
	assert( type ( key )=='string', 'selection key expected' )
	return listToTable ( bridge.getSelection ( key ) )
end

-- Environment
-- getProjectExtPath = bridge.getProjectExtPath
-- getProjectPath    = bridge.getProjectPath
-- getAppPath        = bridge.getAppPath
PythonBridgeModule.app = bridge.app

local function getProject ()
	return app:getProject ()
end

local function getApp ()
	return app
end

local function getModule ( id )
	return app:getModule ( id )
end

local function findDataFile ( name )
	return app:findDataFile ( name )
end


PythonBridgeModule.changeSelection 	= changeSelection
PythonBridgeModule.addSelection		= addSelection
PythonBridgeModule.removeSelection 	= removeSelection
PythonBridgeModule.toggleSelection 	= toggleSelection
PythonBridgeModule.toggleSelection 	= toggleSelection
PythonBridgeModule.getSelection 	= getSelection

PythonBridgeModule.getProject 	= getProject
PythonBridgeModule.getApp		= getApp
PythonBridgeModule.getModule 	= getModule
PythonBridgeModule.findDataFile = findDataFile

--------------------------------------------------------------------
-- PYTHON-LUA DELEGATION CREATION
--------------------------------------------------------------------
function loadLuaWithEnv ( file, env, ... )
	if env then
		assert ( type ( env ) == 'userdata' )
		env = dictToTablePlain ( env )
	end

	env = setmetatable ( env or {},
		{ __index = function ( t, k ) return rawget ( _G, k ) end }
	)
	local func, err = loadfile ( file )
	if not func then
		error ( 'Failed load script:' .. file .. '\n' .. err, 2 )
	end
	
	env._C = env

	setfenv ( func, env )

	local args = { ... }
	local function _f ()
		return func ( unpack ( args ) )
	end
	local function _onError ( err, level )
		print ( err )
		print ( debug.traceback ( level or 2 ) )
		return err, level
	end

	local succ, err = xpcall ( _f, _onError )
	if not succ then
		error ( 'Failed start script:'.. file, 2 )
	end

	local dir = env._path
	function env.dofile ( path )
	end

	return env
end

function loadLuaDelegate ( file, env, ... )
end

PythonBridgeModule.loadLuaWithEnv 	= loadLuaWithEnv
PythonBridgeModule.loadLuaDelegate 	= loadLuaDelegate

--------------------------------------------------------------------
-- Lua Functions For Python
--------------------------------------------------------------------
stepSim                 = assert ( MOAISim.stepSim )
setBufferSize           = assert ( MOAISim.setBufferSize )
--local renderFrameBuffer = assert ( MOAISim.renderFrameBuffer ) --a manual renderer caller
local renderFrameBuffer = nil --a manual renderer caller

local function renderTable ( t )
	for i,f in ipairs ( t ) do
		local tt = type ( f )
		if tt == 'table' then
			renderTable ( f )
		elseif tt=='userdata' then
			renderFrameBuffer ( f )
		end
	end
end

local function manualRenderAll ()
	local rt = MOAIRenderMgr.getBufferTable ()
	if rt then
		renderTable ( rt )
	else
		renderFrameBuffer ( MOAIGfxMgr.getFrameBuffer () )
	end
end

PythonBridgeModule.renderTable 		= renderTable
PythonBridgeModule.manualRenderAll 	= manualRenderAll

--------------------------------------------------------------------
-- Editor Command
--------------------------------------------------------------------
PythonBridgeModule.registerLuaEditorCommand = bridge.registerLuaEditorCommand
PythonBridgeModule.doCommand 				= bridge.doCommand
PythonBridgeModule.undoCommand 				= bridge.undoCommand

--------------------------------------------------------------------
-- MODEL
--------------------------------------------------------------------
local modelBridge = bridge.ModelBridge.get ()

local function registerModelProvider ( setting )
	local priority  = setting.priority or 10
	local name      = setting.name
	local getTypeId           = assert ( setting.getTypeId, 'getTypeId not provided' )
	local getModel            = assert ( setting.getModel,  'getModel not provided' )
	local getModelFromTypeId  = assert ( setting.getModelFromTypeId,  'getModelFromTypeId not provided' )
	return modelBridge:buildLuaObjectModelProvider ( 
		name, priority, getTypeId, getModel, getModelFromTypeId
	)
end

local function registerObjectEnumerator ( setting )
	local name = setting.name
	local enumerateObjects   = assert ( setting.enumerateObjects, 'enumerateObjects not provided' )
	local getObjectRepr      = assert ( setting.getObjectRepr, 'getObjectRepr not provided' )
	local getObjectTypeRepr  = assert ( setting.getObjectTypeRepr, 'getObjectTypeRepr not provided' )
	return modelBridge:buildLuaObjectEnumerator (
		name,
		enumerateObjects,
		getObjectRepr,
		getObjectTypeRepr
	)
end


PythonBridgeModule.registerModelProvider = registerModelProvider
PythonBridgeModule.registerObjectEnumerator = registerObjectEnumerator

return PythonBridgeModule