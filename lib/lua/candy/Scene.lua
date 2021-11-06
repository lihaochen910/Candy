-- import
local SignalModule = require 'candy.signal'
local GlobalManagerModule = require 'candy.GlobalManager'
local EntityGroup = require 'candy.EntityGroup'
local DebugDrawModule = require 'candy.DebugDrawQueue'
local DebugDrawQueue = DebugDrawModule.DebugDrawQueue

local DefaultPhysicsWorldOption = {
	unitsToMeters = 0.01,
	timeToSleep = 0,
	velocityIterations = 6,
	world = "Box2DWorld",
	angularSleepTolerance = 0,
	autoClearForces = true,
	positionIterations = 8,
	linearSleepTolerance = 0,
	gravity = {
		0,
		-10
	}
}

---@class Scene
local Scene = CLASS: Scene ()

function Scene:__init ()
	self.metadata = {}
	self.path = false
	self.filePath = false

	self.active = false
	self.main = false
	self.session = false ---@type SceneSession
	self.ready = false

	self.FLAG_EDITOR_SCENE = false
	self.running = false

	-- Layer --
	self.defaultLayer = false
	self.layers = {}
	self.layersByName = {}
	
	-- Folder
	self.rootGroups = {}
	self.defaultRootGroup = self:addRootGroup ( 'default' )
	self.defaultRootGroup._isDefault = true

	-- Entity --
	self.entities = {}
	self.entitiesByName = {}
	self.entityCount = 0

	-- Pending Handle --
	self.pendingStart = {}
	self.pendingDestroy = {}
	self.pendingCall = {}
	self.pendingDetach = {}
	self.laterDestroy = {}

	self.updateListeners = {}           -- for custom Entity:onUpdate(dt)
	
	self.actionPriorityGroups = {}
	self.defaultCamera = false

	self.b2world = false
	self.b2ground = false

	self.managers = {}
	self.globalActionGroups = {}

	-- Exit Variable --
	self.exiting = false
	self.exitingTime = false

	self.debugDrawQueue = DebugDrawQueue ()
	self.debugPropPartition = MOAIPartition.new ()
end

function Scene:__tostring ()
	-- return string.format ( "%s%s::%s", self:__repr (), self.path or "<nil>", self:getSessionName () or "???" )
	return string.format ( "%s%s::%s", Scene.__super.__tostring ( self ), self.path or "", self:getSessionName () or "???" )
end

function Scene:getSession ()
	return self.session
end

function Scene:getSessionName ()
	local session = self.session
	return session and session:getName ()
end

function Scene:init ()
	if self.initialized then return end 
	self.initialized = true
	self.exiting = false
	self.active  = true
	self.ready = false
	self.userObjects = {}

	self:initLayers ()
	self:initPhysics ()
	self:initManagers ()

	if self.onLoad then self:onLoad () end

	_stat ( 'Initialize Scene' )

	if not self.FLAG_EDITOR_SCENE then
		SignalModule.emitSignal ( 'scene.init', self )
	end
	
	self:reset ()
end

function Scene:initLayers ()
	local layers = {}
	local layersByName = {}
	local defaultLayer

	for i, l in ipairs ( self:getLayerSources () ) do
		local layer = l:makeMoaiLayer ()
		layers[ i ] = layer
		layersByName[ layer.name ] = layer
		if l.default then
			defaultLayer = layer
		end
	end

	if defaultLayer then
		self.defaultLayer = defaultLayer
	else
		self.defaultLayer = layers[ 1 ]
	end
	assert ( self.defaultLayer )
	self.layers = layers
	self.layersByName = layersByName
end

function Scene:initPhysics ()
	local option = game and game.physicsOption or table.simplecopy ( DefaultPhysicsWorldOption )
	local world = nil

	if option.world and _G[ option.world ] then
		local worldClass = rawget ( _G, option.world )
		world = worldClass.new ()
	else
		world = MOAIBox2DWorld.new ()
	end

	if option.gravity then
		world:setGravity ( unpack ( option.gravity ) )
	end

	if option.unitsToMeters then
		world:setUnitsToMeters ( option.unitsToMeters )
	end

	local velocityIterations = option.velocityIterations
	local positionIterations = option.positionIterations

	world:setIterations ( velocityIterations, positionIterations )
	world:setAutoClearForces ( option.autoClearForces )

	self.b2world = world
	local ground = world:addBody ( MOAIBox2DBody.STATIC )
	self.b2ground = ground

	world:setDebugDrawEnabled ( true )

	return world
end

function Scene:initManagers ()
	self.managers = {}

	local registry = getSceneManagerFactoryRegistry ()
	for i, fac in ipairs ( registry ) do
		if fac:accept ( self ) then
			local manager = fac:create ( self )
			if manager then
				manager._factory = fac
				manager._key = fac:getKey ()
				manager:init ( self )
				self.managers[ manager._key ] = manager
			end
		end
	end

	for i, globalManager in ipairs ( GlobalManagerModule.getGlobalManagerRegistry () ) do
		globalManager:onSceneInit ( self )
	end
end

function Scene:getBox2DWorld ()
	return self.b2world
end

function Scene:getBox2DWorldGround ()
	return self.b2ground
end

function Scene:pauseBox2DWorld ( paused )
	self.b2world:pause ( paused )
end

function Scene:getLayerSources ()
	return table.simplecopy ( candy.game.layers )
end

function Scene:getMainRenderContext ()
	return game:getMainRenderContext ()
end

function Scene:getMainRenderTarget ()
	return self:getMainRenderContext ():getRenderTarget ()
end

function Scene:flushPendingStart ()
	if not self.running then
		return self
	end

	local pendingStart = self.pendingStart
	local newPendingStart = {}
	self.pendingStart = newPendingStart

	for entity in pairs ( pendingStart ) do
		entity:start ()
	end

	if next ( newPendingStart ) then
		return self:flushPendingStart ()
	else
		return self
	end
end

function Scene:threadMain ( dt )
	_stat ( 'entering scene main thread', self )

	for i, globalManager in ipairs ( GlobalManagerModule.getGlobalManagerRegistry () ) do
		globalManager:onSceneStart ( self )
	end

	-- first run callback
	for entity in pairs ( self.entities ) do
		if not entity.parent then
			entity:start ()
		end
	end
	-- self:flushPendingStart()
	
	for i, globalManager in ipairs ( GlobalManagerModule.getGlobalManagerRegistry () ) do
		globalManager:postSceneStart ( self )
	end

	-- main loop
	_stat ( 'entering scene main loop', self )
	dt = 0
	
	local firstFrame = true
	local debugDrawQueue = self.debugDrawQueue
	local lastTime = self:getTime ()
	while true do
		local nowTime = self:getTime ()
		if self.active then
			-- local dt = nowTime - lastTime
			lastTime = nowTime

			if not firstFrame then
				--callNextFrame
				local pendingCall = self.pendingCall
				local count = #pendingCall

				if count > 0 then
					self.pendingCall = {}

					for i = 1, count do
						local t = pendingCall[ i ]
						local func = t.func

						if type ( func ) == "string" then
							local object = t.object
							func = object[ func ]

							func ( object, unpack ( t ) )
						else
							func ( unpack ( t ) )
						end
					end
				end
			else
				firstFrame = false
			end

			--onUpdate
			for obj in pairs ( self.updateListeners ) do
				local isActive = obj.isActive
				if not isActive or isActive ( obj ) then
					obj:onUpdate ( dt )
				end
			end
			
			--destroy later
			local laterDestroy = self.laterDestroy
			for entity, time in pairs ( laterDestroy ) do
				if time <= nowTime then
					entity:tryDestroy ()
					laterDestroy[ entity ] = nil
				end
			end

			if next ( self.pendingStart ) then
				self:flushPendingStart ()
			end

			--end of step update
		end
		
		local pendingDetach = self.pendingDetach
		self.pendingDetach = {}
		for com in pairs ( pendingDetach ) do
			local entity = com._entity
			if entity then
				entity:detach ( com )
			end
		end

		local pendingDestroy = self.pendingDestroy
		self.pendingDestroy = {}
		for entity in pairs ( pendingDestroy ) do
			if entity.scene then
				entity:destroyWithChildrenNow ()
			end
		end
		
		dt = coroutine.yield ()

		-- debugDrawQueue:update( dt )

		if self.exiting then 
			self:exitNow ()
		elseif self.exitingTime and self.exitingTime <= self:getTime () then
			self.exitingTime = false
			self:exitNow ()
		end
		--end of main loop
	end
end

function Scene:preUpdate ()
	-- local debugDrawQueue = self.debugDrawQueue
	-- debugDrawQueue:clear ()
	-- setCurrentDebugDrawQueue ( debugDrawQueue )
end

function Scene:postUpdate ( ... )
	-- print ( 'post scene!!', self, ... )
end

function Scene:callNextFrame ( f, ... )
	local t = {
		func = f,
		...
	}
	table.insert ( self.pendingCall, t )
end

function Scene:addUpdateListener ( obj )
	self.updateListeners[ obj ] = true
end

function Scene:removeUpdateListener ( obj )
	self.updateListeners[ obj ] = nil
end

function Scene:addRootGroup ( name )
	local group = EntityGroup ()
	group._isRoot = true
	group.scene = self
	group.name  = name
	table.insert ( self.rootGroups, group )
	return group
end

function Scene:setDefaultRootGroup ( group )
	if not group then
		for i, g in ipairs ( self.rootGroups ) do
			if g._isDefault then
				group = g
				break
			end
		end
	end

	if self.defaultRootGroup == group then
		return false
	end

	if group.scene == self then
		self.defaultRootGroup = group
		return true
	end

	return false
end

function Scene:getRootGroup ( name )
	if name then
		for i, group in ipairs ( self.rootGroups ) do
			if group.name == name then return group end
		end
		return nil
	else
		return self.defaultRootGroup
	end
end

function Scene:getRootGroups ()
	return self.rootGroups
end

function Scene:renameGroup ( group, name )
	local name0 = group.name
	local group0 = self.rootGroups[ name0 ]
	if group0 == group then
		self.rootGroups[ name0 ] = nil
		self.rootGroups[ name ] = group
		return true
	end
	return false
end

--------------------------------------------------------------------
--Flow Control
--------------------------------------------------------------------
function Scene:start ()
	--_stat ( 'scene start', self )
		
	if self.running then return end
	if not self.initialized then self:init () end

	self.active = true
	self.running = true
	self.mainThread = MOAICoroutine.new ()
	self.mainThread:run ( function ()
		return self:threadMain ()
	end )
	self.mainThread:attach ( self:getParentActionRoot() )

	_stat ( 'mainthread scene start' )
	self:setActionPriority ( self.mainThread, 0 )
	
	_stat( 'box2d scene start' )
	self:setActionPriority ( self.b2world, 1 )

	if self.onStart then self:onStart ( self ) end
	_stat ( 'scene start ... done' )
	self:pauseBox2DWorld ( false )
end


function Scene:pause ( paused )
	self.actionRoot:pause ( paused ~= false )
end


function Scene:resume ()
	return self:pause ( false )
end


function Scene:stop ()
	if not self.running then return end
	self.running = false
	self.mainThread:stop ()
	self.mainThread:clear ()
	self.mainThread = false
	self.actionRoot:stop ()
	self.actionRoot:clear ()
end


function Scene:reset ()
	self:resetActionRoot ()
	-- for key, manager in pairs( self.managers ) do
	-- 	manager:reset()
	-- end
	for i, globalManager in ipairs ( GlobalManagerModule.getGlobalManagerRegistry () ) do
		globalManager:onSceneReset ( self )
	end
end


function Scene:exit ()
	_stat ( 'scene exit' )
	self.exiting = true	
end


function Scene:exitNow ()
	_stat ( 'Exit Scene: %s', self.name )
	self:stop ()
	self.active  = false
	self.exiting = false
	if self.onExit then self.onExit () end
	self:clear ()
	SignalModule.emitSignal ( 'scene.exit', self )
end


function Scene:clear ( keepEditorEntity )
	_stat ( 'clearing scene' )
	-- self._GUIDCache = {}
	-- local entityListener = self.entityListener
	-- if entityListener then
	--     self.entityListener = false
	--     entityListener('clear', keepEditorEntity)
	-- end
	local toRemove = {}
	_stat ( 'pre clear', table.len ( self.entities ) )
	for a in pairs ( self.entities ) do
		if not a.parent then
			if not ( keepEditorEntity and a.FLAG_EDITOR_OBJECT ) then
				toRemove[ a ] = true
			end
		end
	end
	for a in pairs ( toRemove ) do
		a:destroyWithChildrenNow ()
	end
	_stat ( 'post clear', table.len ( self.entities ) )

	--layers in Scene is not in render stack, just let it go
	self.laterDestroy    	= {}
	self.pendDestroy    	= {}
	self.pendingCall    	= {}
	self.entitiesByName		= {}
	self.pendingStart    	= {}
	self.updateListeners	= {}
	self.rootGroups    		= {}

	self.defaultRootGroup = self:addRootGroup ( 'default' )
	self.defaultRootGroup._isDefault = true

	self.defaultCamera = false
	-- self.entityListener = entityListener
	-- self.arguments = {}
	-- self.userObjects = {}

	-- _stat('global action group reset')
	-- for id, gg in pairs(self.globalActionGroups) do
	--     gg:clear()
	--     gg:stop()
	-- end
	-- self.globalActionGroups = {}

	_stat ( 'scene action priority group reset' )
	for i, g in ipairs ( self.actionPriorityGroups ) do
		_stat ( 'stop priorityGroup', g )
		g:clear ()
		g:stop ()
	end
	self.actionPriorityGroups = {}

	-- for key, manager in pairs(self.managers) do
	--     manager:clear()
	-- end

	-- for i, globalManager in ipairs(getGlobalManagerRegistry()) do
	--     globalManager:onSceneClear(self)
	-- end

	if not self.FLAG_EDITOR_SCENE then
		SignalModule.emitSignal ( 'scene.clear', self )
	end
end


function Scene:destroy ()
	self:stop ()
	self:clear ()
end

--------------------------------------------------------------------
--TIMER
--------------------------------------------------------------------
function Scene:getTime ()
	if self.timer then
		return self.timer:getTime ()
	else
		return 0
	end
end

function Scene:getGameTime ()
	return candy.game:getTime ()
end

function Scene:getSceneTimer ()
	return self.timer
end

function Scene:createTimer ()
	local timer = MOAITimer.new ()
	timer:attach ( self:getActionRoot () )
	return timer
end


--------------------------------------------------------------------
--Action control
--------------------------------------------------------------------
function Scene:resetActionRoot ()
	_stat ( 'scene action root reset' )
	-- local prevActionRoot = self.actionRoot
	if self.actionRoot then
		self.actionRoot:setListener ( MOAIAction.EVENT_ACTION_PRE_UPDATE, nil )
		self.actionRoot:setListener ( MOAIAction.EVENT_ACTION_POST_UPDATE, nil )
		self.actionRoot:stop ()
		self.actionRoot:clear ()
		self.actionRoot = false
	end

	self.actionRoot = MOAICoroutine.new ()
	self.actionRoot:setDefaultParent ( true )
	self.actionRoot:run (
		function ()
			while true do
				coroutine.yield ()
			end
		end	
	)
	self.actionRoot:setListener ( MOAIAction.EVENT_ACTION_PRE_UPDATE, function ( ... ) self:preUpdate ( ... ) end )
	self.actionRoot:setListener ( MOAIAction.EVENT_ACTION_POST_UPDATE, function ( ... ) self:postUpdate ( ... ) end )
	self.actionRoot:attach ( self:getParentActionRoot () )

	_stat ( 'scene timer reset ')
	if self.timer then
		self.timer:detach ()
		self.timer = false
	end

	self.timer = MOAITimer.new ()
	self.timer:setMode ( MOAITimer.CONTINUE )
	self.timer:attach ( self.actionRoot )

	local root = self.actionRoot
	for i = 9, -9, -1 do
		local group = MOAIAction.new ()
		group:setAutoStop ( false )
		group:attach ( root )
		group.priority = i
		self.actionPriorityGroups[ i ] = group
	end

end

function Scene:getActionRoot ()
	return self.mainThread
end

function Scene:getParentActionRoot ()
	return game:getActionRoot ()
end

function Scene:setActionPriority ( action, priority )
	local group = self.actionPriorityGroups[ priority ]
	action:attach ( group )
end


--------------------------------------------------------------------
--Layer control
--------------------------------------------------------------------
--[[
	Layer in scene is only for placeholder/ viewport transform
	Real layers for render is inside Camera, which supports multiple viewport render
]]

---@param name string
---@return MOAILayer
function Scene:getLayer ( name )
	if not name then return self.defaultLayer end
	return self.layersByName[ name ]
end

--------------------------------------------------------------------
--Entity control
--------------------------------------------------------------------
--- Add Entity to scene
---@param entity candy.Entity
---@param layer candy.Layer | string
---@param group candy.EntityGroup
---@return MOAILayer
function Scene:addEntity ( entity, layer, group )
	assert ( entity )

	layer = layer or entity.layer or self.defaultLayer
	if type ( layer ) == 'string' then
		local layerName = layer
		layer = self:getLayer ( layerName )
		if not layer then
			_error ( 'layer not found:', layerName )
			_traceback ( '' )
			layer = self.defaultLayer
		end
	end

	assert ( layer )
	group = group or entity._entityGroup or self:getRootGroup ()
	group:addEntity ( entity )
	entity:_insertIntoScene ( self, layer )

	--_log ( "Scene:addEntity", layer, entity.name, entity )

	return entity
end

function Scene:setEntityListener ( func )
	self.entityListener = func or false
end

function Scene:changeEntityName ( entity, oldName, newName )
	local entitiesByName = self.entitiesByName
	if oldName then
		if entity == entitiesByName[ oldName ] then
			entitiesByName[ oldName ]=nil
		end
	end
	if not entitiesByName[ newName ] then
		entitiesByName[ newName ] = entity
	end
end

--------------------------------------------------------------------
-- User Data
--------------------------------------------------------------------
function Scene:setUserObject ( id, obj )
	self.userObjects[ id ] = obj
end

function Scene:getUserObject ( id )
	return self.userObjects[ id ]
end

function Scene:setUserConfig ( id, obj )
	self.userConfig[ id ] = obj
end

function Scene:getUserConfig ( id, default )
	local v = self.userConfig[ id ]

	if v ~= nil then
		return v
	end

	return game:getUserConfig ( id, default )
end

function Scene:getManager ( key )
	return self.managers[ key ]
end

function Scene:getManagers ()
	return self.managers
end

--------------------------------------------------------------------
-- Meta
--------------------------------------------------------------------
function Scene:setMetaData ( key, value )
	self.metadata[ key ] = value
end

function Scene:getMetaData ( key, defaultValue )
	local v = self.metadata[ key ]
	if v == nil then
		return defaultValue
	end
	return v
end

--------------------------------------------------------------------
-- Serialize
--------------------------------------------------------------------
function Scene:serializeConfig()
	local output = {}
	local commonData = {
		comment = self.comment
	}
	output[ 'common' ] = commonData

	local managerConfigData = {}
	for key, mgr in pairs ( self:getManagers () ) do
		local data = mgr:serialize ()
		if data then
			managerConfigData[ key ] = data
		end
	end
	output[ 'managers' ] = managerConfigData

	return output
end

function Scene:deserializeConfig ( data )
	--common
	local commonConfigData = data[ 'common' ]
	if commonConfigData then
		self.comment = commonConfigData[ 'comment' ]
	end

	--managers
	local managerConfigData = data[ 'managers' ]
	if managerConfigData then
		for key, data in pairs ( managerConfigData ) do
			local mgr = self:getManager ( key )
			if mgr then
				mgr:deserialize ( data )
			end
		end
	end
end

function Scene:serializeMetaData ()
	return self.metadata
end

function Scene:deserializeMetaData ( data )
	self.metadata = data and table.simplecopy ( data ) or {}
end

--------------------------------------------------------------------
-- Util
--------------------------------------------------------------------
local function collectEntity ( a, typeId, collection )
	if isEditorEntity ( a ) then return end
	if isInstance ( a, typeId ) then
		collection[ a ] = true
	end
	for child in pairs ( a.children ) do
		collectEntity ( child, typeId, collection )
	end
end

local function collectComponent ( entity, typeId, collection )
	if isEditorEntity ( entity ) then return end
	for com in pairs ( entity.components ) do
		if not com.FLAG_INTERNAL and isInstance ( com, typeId ) then
			collection[ com ] = true
		end
	end
	for child in pairs ( entity.children ) do
		collectComponent ( child, typeId, collection )
	end
end

local function collectEntityGroup ( group, collection )
	if isEditorEntity ( group ) then return end
	collection[ group ] = true 
	for child in pairs ( group.childGroups ) do
		collectEntityGroup ( child, collection )
	end
end

function Scene:collectEntityGroups ()
	local collection = {}	
	for i, group in ipairs ( self.rootGroups ) do
		collectEntityGroup ( group, collection )
	end
	return collection
end

function Scene:collectComponents ( typeId )
	local collection = {}	
	for a in pairs ( self.entities ) do
		collectComponent ( a, typeId, collection )
	end
	return collection
end

function Scene:deviceToContext ( x, y )
	return self:getMainRenderContext ():deviceToContext ( x, y )
end

function Scene:contextToDevice ( x, y )
	return self:getMainRenderContext ():contextToDevice ( x, y )
end

--------------------------------------------------------------------
--Debug
--------------------------------------------------------------------
function Scene:isEditorScene ()
	return self.FLAG_EDITOR_SCENE
end

function Scene:getDebugPropPartition ()
	return self.debugPropPartition
end

function Scene:getDebugDrawQueue ()
	return self.debugDrawQueue
end

function Scene:addDebugProp ( prop )
	self.debugPropPartition:insertProp ( prop )
end

function Scene:removeDebugProp ( prop )
	self.debugPropPartition:removeProp ( prop )
end

return Scene