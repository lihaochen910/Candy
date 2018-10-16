local rawget,rawset= rawget,rawset

local bridge = CANDY_PYTHON_BRIDGE

module( 'candy_editor', package.seeall )

--------------------------------------------------------------------
-- CORE FUNCTIONS
--------------------------------------------------------------------

--communication
emitPythonSignal     = bridge.emitPythonSignal
emitPythonSignalNow  = bridge.emitPythonSignalNow
connectPythonSignal  = bridge.connectPythonSignal
registerPythonSignal = bridge.registerPythonSignal

--data
sizeOfPythonObject   = bridge.sizeOfPythonObject
newPythonDict        = bridge.newPythonDict
newPythonList        = bridge.newPythonList
appendPythonList     = bridge.appendPythonList
deletePythonList     = bridge.deletePythonList
getDict              = bridge.getDict
setDict              = bridge.setDict
--other
throwPythonException = bridge.throwPythonException
getTime              = bridge.getTime
generateGUID         = bridge.generateGUID
showAlertMessage		= bridge.showAlertMessage

MOAIEnvironment.generateGUID = bridge.generateGUID

--import
importPythonModule   = bridge.importModule

--data conversion
local encodeDict = bridge.encodeDict
local decodeDict = bridge.decodeDict

function tableToDict(table)
	local json = MOAIJsonParser.encode(table)
	return decodeDict(json)
end

function tableToList(table)
	local list = bridge.newPythonList()
	for i, v in ipairs(table) do
		appendPythonList(list,v)
	end
	return list
end

function dictToTable(dict)
	local json = encodeDict(dict)
	return MOAIJsonParser.decode(json)
end

function dictToTablePlain(dict) --just one level?
	local t = {}
	for k in python.iter( dict ) do
		t[k] = dict[k]
	end
	return t	
end


local _sizeOf = bridge.sizeOfPythonObject
function listToTable(list)
	local c=_sizeOf(list)
	local r={}
	for i = 1, c do
		r[i]=list[i-1]
	end
	return r
end

function unpackPythonList( t )
	return unpack( listToTable( t ) )
end

--------------------------------------------------------------------
-- EDITOR RELATED
--------------------------------------------------------------------
function changeSelection( key, obj, ... )
	assert( type(key)=='string', 'selection key expected' )
	if obj then
		bridge.changeSelection( key, newPythonList(obj,...) )
	else
		bridge.changeSelection( key, nil )
	end
end

function addSelection( key, obj, ... )
	assert( type(key)=='string', 'selection key expected' )
	if obj then
		bridge.addSelection( key, newPythonList(obj,...) )
	else
		bridge.addSelection( key, nil )
	end
end

function removeSelection( key, obj, ... )
	assert( type(key)=='string', 'selection key expected' )
	if obj then
		bridge.removeSelection( key, newPythonList(obj,...) )
	else
		bridge.removeSelection( key, nil )
	end
end

function toggleSelection( key, obj, ... )
	assert( type(key)=='string', 'selection key expected' )
	if obj then
		bridge.toggleSelection( key, newPythonList(obj,...) )
	else
		bridge.toggleSelection( key, nil )
	end
end


function getSelection( key )
	assert( type(key)=='string', 'selection key expected' )
	return listToTable( bridge.getSelection( key ) )
end

-- Environment
-- getProjectExtPath = bridge.getProjectExtPath
-- getProjectPath    = bridge.getProjectPath
-- getAppPath        = bridge.getAppPath
app = bridge.app

function getProject()
	return app:getProject()
end

function getApp()
	return app
end

function getModule( id )
	return app:getModule( id )
end

function findDataFile( name )
	return app:findDataFile( name )
end

--------------------------------------------------------------------
-- PYTHON-LUA DELEGATION CREATION
--------------------------------------------------------------------
function loadLuaWithEnv(file, env, ...)
	if env then
		assert ( type( env ) == 'userdata' )
		env = dictToTablePlain( env )
	end

	env = setmetatable(env or {},
			{__index=function(t,k) return rawget(_G,k) end}
		)
	local func, err=loadfile(file)
	if not func then
		error('Failed load script:'..file..'\n'..err, 2)
	end
	
	env._C    = env

	setfenv(func, env)
	local args = {...}
	
	local function _f()
		return func( unpack( args ))
	end
	local function _onError( err, level )
		print ( err )
		print( debug.traceback( level or 2 ) )
		return err, level
	end

	local succ, err = xpcall( _f, _onError )
	if not succ then
		error('Failed start script:'.. file, 2)
	end

	local dir = env._path
	function env.dofile( path )

	end

	return env
end

function loadLuaDelegate( file, env, ... )
end

--------------------------------------------------------------------
-- Lua Functions For Python
--------------------------------------------------------------------
stepSim                 = assert(MOAISim.stepSim)
setBufferSize           = assert(MOAISim.setBufferSize)
local renderFrameBuffer = assert(MOAISim.renderFrameBuffer) --a manual renderer caller

local function renderTable(t)
	for i,f in ipairs(t) do
		local tt=type(f)
		if tt=='table' then
			renderTable(f)
		elseif tt=='userdata' then
			renderFrameBuffer(f)
		end
	end
end

function manualRenderAll()
	local rt = MOAIRenderMgr.getBufferTable()
	if rt then
		renderTable(rt)
	else
		renderFrameBuffer(MOAIGfxDevice.getFrameBuffer())
	end
end


--------------------------------------------------------------------
-- Editor Command
--------------------------------------------------------------------
registerLuaEditorCommand = bridge.registerLuaEditorCommand
doCommand = bridge.doCommand
undoCommand = bridge.undoCommand

--------------------------------------------------------------------
-- MODEL
--------------------------------------------------------------------
local modelBridge = bridge.ModelBridge.get()

function registerModelProvider( setting )
	local priority  = setting.priority or 10
	local name      = setting.name
	local getTypeId           = assert( setting.getTypeId, 'getTypeId not provided' )
	local getModel            = assert( setting.getModel,  'getModel not provided' )
	local getModelFromTypeId  = assert( setting.getModelFromTypeId,  'getModelFromTypeId not provided' )
	return modelBridge:buildLuaObjectModelProvider( 
			name, priority, getTypeId, getModel, getModelFromTypeId
		)
end


function registerObjectEnumerator( setting )
	local name      = setting.name
	local enumerateObjects   = assert( setting.enumerateObjects, 'enumerateObjects not provided' )
	local getObjectRepr      = assert( setting.getObjectRepr, 'getObjectRepr not provided' )
	local getObjectTypeRepr  = assert( setting.getObjectTypeRepr, 'getObjectTypeRepr not provided' )
	return modelBridge:buildLuaObjectEnumerator(
			name,
			enumerateObjects,
			getObjectRepr,
			getObjectTypeRepr
		)
end

print('PythonBridge.lua load ok.')
