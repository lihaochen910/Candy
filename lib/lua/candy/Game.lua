-- import
local SignalModule = require 'candy.signal'
local GlobalManagerModule = require 'candy.GlobalManager'
local TaskModule = require 'candy.task.Task'
local RenderManagerModule = require 'candy.RenderManager'
local GameRenderContext = require 'candy.GameRenderContext'
local RenderTargetModule = require 'candy.RenderTarget'
local InputDeviceModule = require 'candy.input.InputDevice'
local Layer = require 'candy.Layer'
local SceneSession = require 'candy.SceneSession'
local MOAIHelpersModule = require 'candy.helper.MOAIHelpers'
local JsonHelperModule = require 'candy.helper.JSONHelper'
local AssetLibraryModule = require 'candy.AssetLibrary'
local TextureModule = require 'candy.asset.Texture'
local AsyncTextureLoadTaskModule = require 'candy.task.AsyncTextureLoadTask'

SignalModule.registerGlobalSignals {
	'msg',
	'app.start',
	'app.resume',
	'app.end',
	'app.focus_change',
	"app.env_change",
	"app.overlay.on",
	"app.overlay.off",

	'game.init',
	'game.start',
	"game.ready",
	'game.pause',
	'game.resume',
	'game.stop',
	-- 'game.update',

	"scene_root.pause",
	"scene_root.resume",

	'asset.init',
	"asset.script_modified",

	'gfx.resize',
	'device.resize',
	"gfx.context_ready",
	"gfx.render_manager_ready",
	"gfx.pre_sync_render_state",
	"gfx.post_sync_render_state",
	"gfx.performance_profile.change",

	'mainscene.schedule_open',
	'mainscene.open',
	'mainscene.start',
	'mainscene.stop',
	'mainscene.close',

	'scene.schedule_open',
	'scene.open',
	'scene.start',
	'scene.stop',
	'scene.close',
	'scene.init',
	'scene.update',
	'scene.clear',

	"scene_session.add",
	"scene_session.remove",

	'layer.update',
	'layer.add',
	'layer.remove',

	'game_config.save',
	'game_config.load',

	'locale.change',

	"input.joystick.add",
	"input.joystick.remove",
	"input.joystick.assign",
	"input.mouse.mode_change",
	"input.source.change",
	"input.mapping.change",

	"ui.resize", --- UIComponent: Resize Event
	"ui.theme_changed", --- UIComponent: Theme changed Event
	"ui.style_changed", --- UIComponent: Style changed Event
	"ui.enabled_changed", --- UIComponent: Enabled changed Event
	"ui.focus_in", --- UIComponent: FocusIn Event
	"ui.focus_out", --- UIComponent: FocusOut Event
	"ui.click", --- Button: Click Event
	"ui.cancel", --- Button: Click Event
	"ui.selected_changed", --- Button: Selected changed Event
	"ui.down", --- Button: down Event
	"ui.up", --- Button: up Event
	"ui.value_changed", --- Slider: value changed Event
	"ui.stick_changed", --- Joystick: Event type when you change the position of the stick
	"ui.msg_show", --- MsgBox: msgShow Event
	"ui.msg_hide", --- MsgBox: msgHide Event
	"ui.msg_end", --- MsgBox: msgEnd Event
	"ui.spool_stop", --- MsgBox: spoolStop Event
	"ui.item_changed", --- ListBox: selectedChanged
	"ui.item_enter", --- ListBox: enter
	"ui.item_click", --- ListBox: itemClick
	"ui.scroll", --- ScrollGroup: scroll
	"ui.validate_all_complete", --- LayoutMgr: validateAll
	"ui.touch_down",
	"ui.touch_up",
	"ui.touch_move",
	"ui.touch_cancel",
	"ui.viewmapping.change"
}

local _SimLoopFlagNames = {
	force_step = MOAISim.SIM_LOOP_FORCE_STEP,
	allow_boost = MOAISim.SIM_LOOP_ALLOW_BOOST,
	allow_spin = MOAISim.SIM_LOOP_ALLOW_SPIN,
	no_deficit = MOAISim.SIM_LOOP_NO_DEFICIT,
	no_surplus = MOAISim.SIM_LOOP_NO_SURPLUS,
	allow_soak = MOAISim.SIM_LOOP_ALLOW_SOAK,
	long_delay = MOAISim.SIM_LOOP_LONG_DELAY
}

local _defaultSystemOption = {
	long_delay_threshold = 40,
	update_rate = 60,
	gc_stepmul = 100,
	boost_threshold = 5,
	cpu_budget = 2,
	gc_step = 20,
	gc_step_limit = 0,
	render_rate = 60,
	gc_pause = 150,
	loop_flags = {}
}

---@class Game
local Game = CLASS: Game ()

function Game:__init ()
	self.overridedOption = {}
	self.initialized = false
	self.boostLoadLock = 0
	self.graphicsInitialized = false
	self.started = false
	self.focused = false
	self.currentRenderContext = 'game'
	self.syncingRenderState = true

	self.prevUpdateTime = 0
	self.prevClock = 0
	self.timer = false
	self.forceStep = false
	self.loopFlags = 0
	self.skipFrame = false
	self.skippedFrame = 0
	self.pendingCall = {}

	self.editorMode = false

	self.userObjects = {}
	self.userConfig = {}

	self.scenes = {}
	self.namedSceneMap = {}
	self.sceneSessions = {}
	self.sceneSessionCount = 0
	self.sceneSessionMap = {}

	self.layers = {}
	self.gfx = { w = 640, h = 480, viewportRect = { 0, 0, 640, 480 } }
	local l = self:addLayer ( 'main' )
	l.default = true
	self.defaultLayer = l

	self.showSystemCursorReasons = {}

	self.time = 0
	self.frame = 0

	self.globalManagers = {}
	self.renderManager = RenderManagerModule.RenderManager () ---@type RenderManager
	self.preRenderTable = {}
	self.postRenderTable = {}

	self.fullscreen = false
	self.fullscreenScale = 1

	self.throttleFactors = {}

	self.boostLoading = false
end

function Game:loadConfig ( path, fromEditor, extra )
	extra = extra or {}
	_stat ( 'loading game config from :', path )
	local data = self:loadJSONData ( path )
	if not data then
		_error ( 'game configuration not parsed:', path )
		return
	end

	return self:init ( data, fromEditor, extra )
end

function Game:init ( config, fromEditor, extra )
	self.taskManager = TaskModule.getTaskManager ()

	assert ( not self.initialized )

	self.title = 'Game'

	self:initGraphics ( config, fromEditor )
	self:initSim ( config, fromEditor )
	self:initLayers ( { layers = {} }, fromEditor )
	self:initSubSystems ( config, fromEditor )
	self:initAsset ( config, fromEditor )

	---@type SceneSession
	self.mainSceneSession 		= self:affirmSceneSession ( 'main' )
	self.mainSceneSession.main 	= true

	---@type Scene
	self.mainScene        		= self.mainSceneSession:getScene ()
	self.mainScene.main 		= true

	self.initialized = true
end

function Game:initSim ( config, fromEditor )
	self.time = 0
	self.throttle = 1
	self.isPaused = false
	self.timer = MOAITimer.new ()
	self.timer:setMode ( MOAITimer.CONTINUE )
		
	local yield = coroutine.yield
	self.rootUpdateCoroutine = MOAICoroutine.new ()
	self.rootUpdateCoroutine:run ( function ()
		local onRootUpdate = self.onRootUpdate
		while true do
			local dt = yield ()
			onRootUpdate ( self, dt ) --delta time get passed in
		end
	end )

	 --_warn( "affirm MOAISim.getActionMgr()", MOAISim.getActionMgr() )
	 --_warn( "affirm MOAIActionMgr", MOAIActionMgr )
	 --_warn( "affirm actionRoot", MOAIActionMgr.getRoot() )
	 --_warn( "affirm actionRoot eventListener", MOAIActionMgr.getRoot().setListener )

	-- _info ( inspect ( getmetatable( MOAIActionMgr.getRoot().getRoot() ) ) )

	self.actionRoot = MOAIAction.new ()
	self.actionRoot:setAutoStop ( false )
	self.actionRoot:start ()
	-- self.actionRoot = MOAIActionMgr.getRoot ()
	self.actionRoot:setListener ( MOAIAction.EVENT_ACTION_PRE_UPDATE, function ()
		return self:preRootUpdate ()
	end )
	

	local sysRoot = MOAISim.getActionMgr ():getRoot ()
	sysRoot:setListener ( MOAIAction.EVENT_ACTION_PRE_UPDATE, function ()
		return self:preSysRootUpdate ()
	end )
	self.sysActionRoot = sysRoot

	self.sceneActionRoot = MOAICoroutine.new ()
	self.sceneActionRoot:setDefaultParent ( true )
	self.sceneActionRoot:run ( function ()
		local onSceneRootUpdate = self.onSceneRootUpdate

		while true do
			local dt = yield ()
			onSceneRootUpdate ( self, dt )
		end
	end)

	self.timer:attach ( self.actionRoot )
	self.rootUpdateCoroutine:attach ( self.timer )
	self.sceneActionRoot:attach ( self.timer )
	MOAINodeMgr.setMaxIterations ( 1 )

	self.actionRoot:setListener ( MOAIAction.EVENT_ACTION_POST_UPDATE, function ()
		return self:postRootUpdate ()
	end )
	
	self.actionRoot:pause ( true )
	self:setThrottle ( 1 )

	-------Setup Callbacks
	MOAISim.setListener ( MOAISim.EVENT_FOCUS_GET,
		function ()
			self:onFocusChanged ( true )
		end )

	MOAISim.setListener ( MOAISim.EVENT_FOCUS_LOST,
		function ()
			self:onFocusChanged ( false )
		end )

	MOAIGfxMgr.setListener ( MOAIGfxMgr.EVENT_RESIZE,
		function ( width, height ) return self:onResize ( width, height ) end )

	local systemOption = self.systemOption or {}
	local function _getSystemOption ( key, default )
		local v = systemOption[ key ]

		if v == nil then
			if default == nil then
				return _defaultSystemOption[ key ]
			else
				return default
			end
		end

		return v
	end

	-------
	MOAISim.clearLoopFlags ()

	local loopFlagNames = _getSystemOption ( "loop_flags" )
	local loopFlags = 0
	-- local bor = bit.bor

	for i, n in ipairs ( loopFlagNames ) do
		local v = _SimLoopFlagNames[ n ]

		if v then
			-- loopFlags = bor ( loopFlags, v )
			loopFlags = loopFlags + v
		end
	end

	self.initialLoopFlags = loopFlags
	self:setLoopFlags ( loopFlags )

	MOAISim.setLongDelayThreshold ( _getSystemOption ( "long_delay_threshold", 10 ) )
	MOAISim.setBoostThreshold ( _getSystemOption ( "boost_threshold", 2 ) )
	MOAISim.setCpuBudget ( _getSystemOption ( "cpu_budget", 2 ) )
	MOAISim.setGCStep ( _getSystemOption ( "cpu_budget", 15 ) )
	-- MOAISim.setGCStepLimit ( _getSystemOption ( "gc_step_limit", 0 ) )
	self:setUpdateRate ( _getSystemOption ( "update_rate", 60 ) )
	MOAISim.setLoopFlags (
		0
		-- + MOAISim.LOOP_FLAGS_MULTISTEP
		-- + MOAISim.LOOP_FLAGS_DEFAULT
		-- + MOAISim.LOOP_FLAGS_SOAK
		+ MOAISim.SIM_LOOP_ALLOW_SPIN
		+ MOAISim.SIM_LOOP_ALLOW_BOOST
		-- + MOAISim.SIM_LOOP_ALLOW_SOAK
		-- + MOAISim.SIM_LOOP_NO_DEFICIT
		-- + MOAISim.SIM_LOOP_NO_SURPLUS
	)
	-- MOAISim.setStepMultiplier ( 1 )

	if fromEditor then
		collectgarbage ( "setpause", 150 )
		collectgarbage ( "setstepmul", 200 )
	else
		collectgarbage ( "setpause", 80 )
		collectgarbage ( "setstepmul", 100 )
	end

	-- self:setGCStepLimit ( 100 )

	--_stat("Game:initSim() ok!")
	-- _stat("Game:getActionRoot() = ", self.actionRoot)
end

function Game:initGraphics ( option, fromEditor )
	self.graphicsOption = option[ 'graphics' ] or {}

	self.deviceRenderTarget = RenderTargetModule.DeviceRenderTarget ( MOAIGfxMgr.getFrameBuffer (), 1, 1 )
	self.deviceRenderTarget:setDebugName ( "rawDeviceRT" )

	-- self.mainRenderTarget = RenderTargetModule.RenderTarget ()
	-- self.mainRenderTarget:setFrameBuffer ( self.deviceRenderTarget:getFrameBuffer () )
	-- self.mainRenderTarget:setParent ( self.deviceRenderTarget )
	-- self.mainRenderTarget:setMode ( 'relative' )

	local gfxOption = self.graphicsOption
	-- local w, h = MOAIEnvironment.horizontalResolution, MOAIEnvironment.verticalResolution
	local w = gfxOption.device_width or 0
	local h = gfxOption.device_height or 0

	_log ( 'Init Graphics Resolution', w, h )

	if w * h == 0 then
		w, h = MOAIHelpersModule.getDeviceResolution ()
	end

	if w * h == 0 then
		_warn ( "no device size specified!" )
		w = 640
		h = 480
	end

	self.targetDeviceWidth = w
	self.targetDeviceHeight = h

	self.deviceRenderTarget:setPixelSize ( w, h )

	self.width = self.overridedOption[ 'width' ] or gfxOption[ 'width' ] or w
	self.height = self.overridedOption[ 'height' ] or  gfxOption[ 'height' ] or h
	self.initialFullscreen = gfxOption[ 'fullscreen' ] or false

	-- self.viewportMode = gfxOption[ 'viewport_mode' ] or 'fit'

	-- self.mainRenderTarget:setAspectRatio ( self.width / self.height )
	-- self.mainRenderTarget:setKeepAspect ( true )
	-- self.mainRenderTarget:setFixedScale ( self.width, self.height )

	_stat ( "setting up window callbacks" )
	MOAISim.setListener ( MOAISim.EVENT_FOCUS_GET, function ()
		self:onFocusChanged ( true )
	end )
	MOAISim.setListener ( MOAISim.EVENT_FOCUS_LOST, function ()
		self:onFocusChanged ( false )
	end )
	MOAIGfxMgr.setListener ( MOAIGfxMgr.EVENT_RESIZE, function ( width, height )
		return self:onDeviceResize ( width, height )
	end )
	MOAIGfxMgr.setListener ( MOAIGfxMgr.EVENT_CONTEXT_DETECT, function ()
		return self:onGraphicsContextDetected ()
	end )
	-- MOAIRenderMgr.setListener ( MOAIRenderMgr.EVENT_PRE_SYNC_RENDER_STATE, function ()
	-- 	return self:preSyncRenderState ()
	-- end )
	-- MOAIRenderMgr.setListener ( MOAIRenderMgr.EVENT_POST_SYNC_RENDER_STATE, function ()
	-- 	return self:postSyncRenderState ()
	-- end )

	self.focused = true

	if not fromEditor then
		MOAISim.openWindow ( self.title, self.width, self.height )
		if self.initialFullscreen then
			MOAISim.enterFullscreenMode ()
		end
	end

	self.renderManager:onInit()

	-- baseClear用于
	local baseClearRenderPass = RenderManagerModule.createTableRenderLayer ()

	if fromEditor then
		baseClearRenderPass:setClearColor ( 0.1, 0.1, 0.1, 1 )
	else
		baseClearRenderPass:setClearColor ( 0, 0, 0, 1 )
	end

	if self:getPlatformType () == "console" then
		baseClearRenderPass:setClearMode ( assert ( MOAILayer.CLEAR_ONCE_TRIPLE ) )
	else
		baseClearRenderPass:setClearMode ( MOAILayer.CLEAR_ALWAYS )
	end

	baseClearRenderPass:setFrameBuffer ( MOAIGfxMgr.getFrameBuffer () )

	self.baseClearRenderPass = baseClearRenderPass
	self.graphicsInitialized = true

	self:showSystemCursor ()

	self.gameRenderContext = GameRenderContext () ---@type GameRenderContext
	self.gameRenderContext:setContentSize ( self.width, self.height )
	self.gameRenderContext:setSize ( self.width, self.height )

	if self.scaleFramebuffer then
		self.gameRenderContext:setOutputMode ( "scaled" )
	else
		self.gameRenderContext:setOutputMode ( "direct" )
	end

	self.renderManager:registerContext ( "game", self.gameRenderContext )

	if fromEditor then
		self:onGraphicsContextDetected ()
	elseif self.graphicsContextReady then
		return self:onRenderManagerReady ()
	end

	if self.pendingResize then
		_stat ( "send pending resize" )
		local pendingResize = self.pendingResize
		self.pendingResize = nil
		self:onDeviceResize ( unpack ( pendingResize ) )
	end
end

function Game:initSubSystems ( config, fromEditor )
	--make inputs work
	_stat ( 'init input handlers' )
	InputDeviceModule.initDefaultInputEventHandlers ()

	--audio
	_stat ( 'init audio' )
	-- self.audioOption = table.simplecopy( DefaultAudioOption )
	-- if config['audio'] then
	-- 	table.extend( self.audioOption, config['audio'] )
	-- end
	-- local audioManager = AudioManager.get()
	-- if not audioManager then
	-- 	error( 'no audio manager registered' )
	-- end

	-- if not audioManager:init( self.audioOption ) then
	-- 	error( 'failed to initialize audio system' )
	-- end
	candy.audio.init ()

	--physics
	-- _stat( 'init physics' )
	--config for default physics world
	-- self.physicsOption = table.simplecopy( DefaultPhysicsWorldOption )
	-- if config['physics'] then
	-- 	table.extend( self.physicsOption, config['physics'] )
	-- end

	--
	self.globalManagers = GlobalManagerModule.getGlobalManagerRegistry ()
	for i, manager in ipairs ( self.globalManagers ) do
		manager:onInit ( self )
	end

	local managerConfigs = config[ 'global_managers' ] or {}
	for i, manager in ipairs ( self.globalManagers ) do
		local key = manager:getKey ()
		local managerConfig = managerConfigs[ key ] or {}
		manager:loadConfig ( managerConfig )
	end

	--input
	_stat ( 'init input' )
	self.inputOption = table.simplecopy ( InputDeviceModule.DefaultInputOption )
	getDefaultInputDevice ().allowTouchSimulation = self.inputOption[ 'allowTouchSimulation' ]

	self:initDefaultInputCommand ()
end

function Game:initDefaultInputCommand ()
	local keyUIMapping = {
		up = { "up" },
		down = { "down" },
		left = { "left" },
		right = { "right" },
		cancel = { "escape" },
		confirm = { "space", "enter", "return" }
	}
	local joyUIMapping = {
		up = { "up", "L-up" },
		down = { "down", "L-down" },
		left = { "left", "L-left" },
		right = { "right", "L-right" },
		cancel = { "b" },
		confirm = { "x", "a" }
	}
	local defaultUIMappingConfig = {
		mappings = {
			keyboard = keyUIMapping,
			joystick = joyUIMapping
		}
	}
	local defaultUIMapping = candy.getInputCommandMappingManager ():affirmMapping ( "defaultUI" )
	defaultUIMapping:load ( defaultUIMappingConfig )
end

function Game:initLayers ( config, fromEditor )
	--load layers
	_stat ( '...setting up layers' )
	for i, data in ipairs ( config['layers'] or {} ) do
		local layer
		if data[ 'default' ] then
			layer = self.defaultLayer
			layer.name = data[ 'name' ]
		else
			layer = self:addLayer ( data[ 'name' ] )
		end
		
		layer:setSortMode ( data[ 'sort' ] )
		layer:setVisible ( data[ 'visible' ] ~= false )
		layer:setEditorVisible ( data[ 'editor_visible' ] ~= false )
		layer.parallax = data[ 'parallax' ] or { 1, 1 }
		layer.priority = i
		layer:setLocked ( data[ 'locked' ] )
	end

	if not self.defaultLayer then
		_stat ( 'no layers define, create default layer.' )
		self.defaultLayer = self:addLayer ( 'default' )
	end

	table.sort ( self.layers,
		function ( a, b )
			local pa = a.priority or 0
			local pb = b.priority or 0
			return pa < pb
		end )
	
	if fromEditor then
		local layer = self:addLayer ( 'CANDY_EDITOR_LAYER' )
		layer.sortMode = 'priority_ascending'
		layer.priority = 1000000
	end
end

function Game:initAsset ( config, fromEditor )
	self.assetLibraryIndex   = config[ 'asset_library' ]
	self.textureLibraryIndex = config[ 'texture_library' ]
	self.assetTagGroupList = config.asset_tag_groups or {}

	--misc
	AsyncTextureLoadTaskModule.setTextureThreadTaskGroupSize ( 10 )

	for i, tag in ipairs ( self.assetTagGroupList ) do
		registerAssetTagGroup ( tag )
	end

	--assetlibrary
	_stat ( '...loading asset library' )
	io.stdout:setvbuf ( "no" )

	if self.assetLibraryIndex then
		if not MOAIFileSystem.checkFileExists ( self.assetLibraryIndex ) and fromEditor then
			--create empty asset-json
			_error ( 'no asset table, create empty' )
			JsonHelperModule.saveJSONFile ( {}, self.assetLibraryIndex )
		end

		if not AssetLibraryModule.loadAssetLibrary ( self.assetLibraryIndex, not fromEditor ) then
			error ( 'failed loading asset library' )
		end
	end
	
	if self.textureLibraryIndex then
		TextureModule.loadTextureLibrary ( self.textureLibraryIndex )
	else
		TextureModule.initTextureLibrary ( nil )
	end
	
	--scriptlibrary
	-- _stat( '...loading game modules' )
	-- loadAllGameModules( config['script_library'] or false )

	SignalModule.emitSignal ( 'asset.init' )
end

function Game:getPlatformType ()
	-- TODO: getPlatformSupport
	return 'Desktop'
end


--------------------------------------------------------------------
-- Graphics related
--------------------------------------------------------------------
function Game:setDeviceSize ( w, h )
	_stat ( 'device.resize', w, h )
	self.deviceRenderTarget:setPixelSize ( w, h )
	SignalModule.emitSignal ( 'device.resize', self.width, self.height )
end

function Game:getDeviceResolution ()
	return self.deviceRenderTarget:getPixelSize ()
end

function Game:getTargetDeviceResolution ()
	return self.targetDeviceWidth, self.targetDeviceHeight
end

--- Get the scale( conent size ) of the main viewport
---@return float,float width, height
function Game:getViewportScale ()
	return self.width, self.height
end

function Game:getViewportRect ()
	return self.mainRenderTarget:getAbsPixelRect ()
end

function Game:getDeviceRenderTarget ()
	return self.deviceRenderTarget
end

function Game:getMainRenderTarget ()
	return self.gameRenderContext:getRenderTarget ()
end

function Game:onDeviceResize ( w, h )
	self:callOnSyncingRenderState ( function ()
		if not self.graphicsInitialized then
			self.pendingResize = { w, h }
			return
		end

		_log ( "device resize", w, h )
		self:setDeviceSize ( w, h )
		self:clearDeviceBufferBase ()
	end )
end

function Game:onRenderManagerReady ()
	self.renderManager:onContextReady ()
	self.gameRenderContext:makeCurrent ()
end

function Game:onFocusChanged ( focused )
	self.focused = focused or false
	SignalModule.emitSignal ( 'app.focus_change', self.focused )
end

function Game:onGraphicsContextDetected ()
	_stat ( "system graphics context ready!" )
	SignalModule.emitGlobalSignal ( "gfx.context_ready" )

	self.graphicsContextReady = true

	if self.graphicsInitialized then
		return self:onRenderManagerReady ()
	end
end

function Game:isSyncingRenderState ()
	local async = false --MOAIRenderMgr.isAsync ()
	if async then
		return self.syncingRenderState
	else
		return true
	end
end

function Game:callOnSyncingRenderState ( f, ... )
	if self:isSyncingRenderState () then
		return f ( ... )
	else
		return RenderManagerModule.getRenderManager ():addPostSyncRenderCall ( f, ... )
	end
end

function Game:preSyncRenderState ()
	local async = false --MOAIRenderMgr.isAsync ()
	if async then
		self.taskManager:onUpdate ()
		self:postRender ()
	end

	self.syncingRenderState = true

	SignalModule.emitGlobalSignal ( "gfx.pre_sync_render_state" )
end

function Game:postSyncRenderState ()
	SignalModule.emitGlobalSignal ( "gfx.post_sync_render_state" )
	self:updateSceneSessions ()
	self.syncingRenderState = false
end

function Game:preSyncRender ()
	self:preSyncRenderState ()
end

function Game:postRender ()
	self:postSyncRenderState ()
end

function Game:getOutputScale ()
	if self.fullscreen then
		return 1 / self.fullscreenScale
	else
		return 1
	end
end

function Game:setFullscreenScale ( scl )
	self.fullscreenScale = scl
	self:updateFullscreenScale ()
end

function Game:updateFullscreenScale ()
	local scl = 1

	if self.fullscreen then
		scl = self.fullscreenScale
	end

	if self:getMainRenderContext () then
		self:getMainRenderContext ():setOutputScale ( scl )
		self:clearDeviceBufferBase ()
		getUICursorManager ():updateViewport ()
	end
end

function Game:setFullscreen ( fullscreen )
	if not self.graphicsInitialized then
		return
	end

	if fullscreen then
		self:enterFullscreenMode ()
	else
		self:exitFullscreenMode ()
	end
end

function Game:isFullscreenMode ()
	return self.fullscreen
end

function Game:enterFullscreenMode ()
	if self.fullscreen then
		return
	end

	if self:isEditorMode () then
		return
	end

	MOAISim.enterFullscreenMode ()

	self.fullscreen = true
	self:updateFullscreenScale ()
end

function Game:exitFullscreenMode ()
	if not self.fullscreen then
		return
	end

	if self:isEditorMode () then
		return
	end

	MOAISim.exitFullscreenMode ()

	self.fullscreen = false
	self:updateFullscreenScale ()
end

--------------------------------------------------------------------
-- Game config
--------------------------------------------------------------------
function Game:saveConfigToTable ()
	--save layer configs
	local layerConfigs = {}
	for i, l in pairs ( self.layers ) do
		if l.name ~= 'CANDY_EDITOR_LAYER' then
			layerConfigs[ i ] = {
				name    = l.name,
				sort    = l.sortMode,
				visible = l.visible,
				default = l.default,
				locked  = l.locked,
				parallax = l.parallax,
				editor_visible = l.editorVisible,
			}
		end
	end

	--save global manager configs
	local globalManagerConfigs = {}
	for i, manager in ipairs ( GlobalManagerModule.getGlobalManagerRegistry () ) do
	    local key = manager:getKey ()
	    local data = manager:saveConfig ()
	    if data then
	        globalManagerConfigs[ key ] = data
	    end
	end

	local data = {
		name        	= self.name,
		version        	= self.version,
		title        	= self.title,

		asset_library 	= self.assetLibraryIndex,
		texture_library = self.textureLibraryIndex,

		graphics    	= self.graphicsOption,
		physics        	= self.physicsOption,
		audio        	= self.audioOption,
		input        	= self.inputOption,
		layers        	= layerConfigs,

		scenes        	= self.namedSceneMap,
		entry_scene    	= self.entryScene,

		-- palettes        = self.paletteLibrary:save(),
		global_managers = globalManagerConfigs,
		-- global_objects = self.globalObjectLibrary:save(),
	}
	SignalModule.emitSignal ( 'game_config.save', data )
	return data
end

function Game:saveConfigToString ()
	local data = self:saveConfigToTable ()
	return encodeJSON ( data )
end

function Game:saveConfigToFile ( path )
	local data = self:saveConfigToTable ()
	return self:saveJSONData ( data, path, 'game config' )
end

function Game:saveJSONData ( data, path, dataInfo )
	dataInfo = dataInfo or 'json'
	local output = encodeJSON ( data )
	local file = io.open ( path, 'w' )
	if file then
		file:write ( output )
		file:close ()
		_stat ( dataInfo, 'saved to', path )
	else
		_error ( 'can not save ', dataInfo, 'to', path )
	end
end

function Game:loadJSONData ( path, dataInfo )
	local file = io.open ( path, 'rb' )
	if file then
		local str = file:read ( '*a' )
		-- local str = MOAIDataBuffer.inflate( str )
		local data = MOAIJsonParser.decode ( str )
		if data then
			_stat ( dataInfo, 'loaded from', path )
			return data
		end
		_error ( 'invalid json data for ', dataInfo, 'at', path )
	else
		_error ( 'file not found for ', dataInfo, 'at', path )
	end
end

--------------------------------------------------------------------
-- Update related
--------------------------------------------------------------------
function Game:preRootUpdate ()
	local t = MOAISim.getDeviceTime ()
	self.prevClock = t
	self._preUpdateClock = MOAISim.getDeviceTime ()
end

function Game:preSysRootUpdate ()
	local f = self.updateSystemGlobalManagerFunc
	if f then f () end
end

function Game:onRootUpdate ( delta )
	self.time = self.time + delta
	self.frame = self.frame + 1

	local skipFrame = self.skipFrame
	if skipFrame then
		self.skippedFrame = self.skippedFrame + 1

		if skipFrame < self.skippedFrame then
			self.skippedFrame = 0
			MOAIRenderMgr.setRenderDisabled ( false )
		else
			MOAIRenderMgr.setRenderDisabled ( true )
		end
	end

	self.updateGlobalManagerFunc ( delta )

	if self.frame ~= 0 then
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
	end
end

function Game:onSceneRootUpdate ( delta )
	local async = false --MOAIRenderMgr.isAsync ()
	if not async then
		self:updateSceneSessions ( delta )
	end
end

function Game:postRootUpdate ()
	local t1 = MOAISim.getDeviceTime ()
	self.prevUpdateTime = t1 - self._preUpdateClock
end

function Game:setUpdateRate ( rate )
	self.updateRate = rate
	self.updateStep = 1 / rate
	MOAISim.setStep ( self.updateStep )
end

function Game:setStep ( step, stepMul )
	if step then MOAISim.setStep ( step ) end
	if stepMul then MOAISim.setStepMultiplier ( stepMul ) end
end

function Game:setThrottleFactor ( key, factor )
	local tt = type ( factor )
	assert ( tt == "number" or tt == "nil" )
	self.throttleFactors[ key ] = factor
	self:updateThrottle ()
end

function Game:getThrottleFactor ( key )
	return self.throttleFactors[ key ]
end

function Game:setThrottle ( v )
	self.baseThrottle = v
	self:updateThrottle ()
end

function Game:getActualThrottle ()
	return self.throttle
end

function Game:updateThrottle ()
	local totalFactor = 1

	for key, factor in pairs ( self.throttleFactors ) do
		if factor then
			totalFactor = totalFactor * factor
		end
	end

	self.throttle = self.baseThrottle * totalFactor

	return self.actionRoot:throttle ( self.throttle )
end

function Game:setLoopFlags ( flags )
	MOAISim.clearLoopFlags ()
	self.loopFlags = flags
	return MOAISim.setLoopFlags ( flags )
end

--------------------------------------------------------------------
-- Action related
--------------------------------------------------------------------
function Game:start ()
	assert ( not self.started )
	--_stat ( 'game start' )
	self.started = true

	local updatingGlobalManagers = {}
	local updatingSystemGlobalManagers = {}

	for i, manager in ipairs ( self.globalManagers ) do
		manager:onStart ( self )

		if manager.onUpdate then
			manager.onUpdate = manager.onUpdate
			table.insert ( updatingGlobalManagers, manager )
		end

		if manager.onSysUpdate then
			manager.onSysUpdate = manager.onSysUpdate
			table.insert ( updatingSystemGlobalManagers, manager )
		end
	end

	local async = false --MOAIRenderMgr.isAsync ()
	local updatingGlobalManagersCount = #updatingGlobalManagers

	function self.updateGlobalManagerFunc ( dt )
		for i = 1, updatingGlobalManagersCount do
			updatingGlobalManagers[ i ]:onUpdate ( self, dt )
		end
	end

	local updatingSystemGlobalManagersCount = #updatingSystemGlobalManagers

	function self.updateSystemGlobalManagerFunc ()
		for i = 1, updatingSystemGlobalManagersCount do
			updatingSystemGlobalManagers[ i ]:onSysUpdate ( self )
		end

		if not async then
			self.taskManager:onUpdate ()
		end
	end

	self.paused = false

	for i, session in ipairs ( self.sceneSessions ) do
		session:start ()
	end

	if self.paused then
		SignalModule.emitSignal ( 'game.resume', self )
	else
		SignalModule.emitSignal ( 'game.start', self )
	end

	_stat ( 'game started' )

	self:getActionRoot ():pause ( false )

	for i, manager in ipairs ( self.globalManagers ) do
		manager:postStart ( self )
	end

	MOAIEnvironment.setListener ( MOAIEnvironment.EVENT_VALUE_CHANGED, function ( key, value )
		return self:onEnvChange ( key, value )
	end )
	self:resetSimTime ()
end

function Game:resume ()
	if not self.paused then
		return
	end

	self.paused = false
	self.actionRoot:pause ( false )
	SignalModule.emitSignal ( "game.resume", self )
end

function Game:pause ( p )
	if p == false then return self.resume () end
	if self.paused then return end 
	self.paused = true
	self.actionRoot:pause ()
	SignalModule.emitSignal ( 'game.pause', self )
end

function Game:resumeSceneRoot ( p )
	if not self.scenePaused then
		return
	end

	self.scenePaused = false
	self.sceneActionRoot:pause ( false )
	SignalModule.emitSignal ( "scene_root.resume", self )
end

function Game:pauseSceneRoot ( p )
	if p == false then
		return self:resumeSceneRoot ()
	end

	if self.scenePaused then
		return
	end

	self.scenePaused = true

	self.sceneActionRoot:pause ( true )
	SignalModule.emitSignal ( "scene_root.pause", self )
end

function Game:stop ()
	_stat ( 'game stop' )

	for i, manager in ipairs ( self.globalManagers ) do
		manager:onStop ( self )
	end

	for i, session in ipairs ( self.sceneSessions ) do
		session:stop ()
		session:clear ( true )
	end

	self:resetClock ()
	SignalModule.emitSignal ( 'game.stop', self )
	_stat ( 'game stopped' )

	self.started = false
end

function Game:stopApplication ()
	MOAISim.stop ()
end

function Game:isPaused ()
	return self.paused
end

function Game:getTime ()
	return self.time
end

function Game:getFrame ()
	return self.frame
end

function Game:resetClock ()
	self.time = 0
end

function Game:resetSimTime ()
	MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_RESET_CLOCK )
end

function Game:getActionRoot ()
	return self.actionRoot
end

function Game:getSceneActionRoot ()
	return self.sceneActionRoot
end

function Game:addCoroutine ( func, ... )
	local routine = MOAICoroutine.new ()
	routine:run ( func, ... )
	routine:attach ( self:getActionRoot () )
	return routine
end

function Game:callNextFrame ( f, ... )
	local t = {
		func = f,
		...
	}
	table.insert ( self.pendingCall, t )
end

---
-- Run the specified function in a loop in a coroutine, forever.
-- If there is a return value of a function of argument, the loop is terminated.
---@param func Target function.
---@param ... Arguments to be passed to the function.
---@return MOAICoroutine object
function Game:callLoop ( func, ... )
	local thread = MOAICoroutine.new ()
    local args = { ... }
    thread:run (
		function ()
			while true do
				if func ( unpack ( args ) ) then
					break
				end
				coroutine.yield ()
			end
		end
    )
	thread:attach ( self:getActionRoot () )
    return thread
end

--------------------------------------------------------------------
-- Layer Control
--------------------------------------------------------------------
function Game:addLayer ( name, addPos )
	addPos = addPos or 'last'
	local l = Layer ( name )
	
	if addPos == 'last' then
		local s = #self.layers
		local last = s > 0 and self.layers[ s ]
		if last and last.name == 'CANDY_EDITOR_LAYER' then
			table.insert ( self.layers, s, l )
		else
			table.insert ( self.layers, l )
		end
	else
		table.insert ( self.layers, 1, l )
	end

	_log ( "Game:addLayer()", l.name )

	return l
end

function Game:removeLayer ( layer )
	local i = table.index ( self.layers, layer )
	if not i then return end
	table.remove ( self.layers, i )
end

function Game:getLayer ( name )
	for i, l in ipairs ( self.layers ) do
		if l.name == name then return l end
	end
	return nil
end

function Game:getLayers ()
	return self.layers
end

--------------------------------------------------------------------
-- MOAISim callback
--------------------------------------------------------------------
function Game:onFocusChanged ( focused )
	self.focused = focused or false
	SignalModule.emitSignal ( 'app.focus_change', self.focused )
end

function Game:onResize ( w, h )
	if not self.graphicsInitialized then
		self.pendingResize = { w, h }
		return
	end	
	 self:setDeviceSize ( w, h )
end

--------------------------------------------------------------------
-- Scene Sessions
--------------------------------------------------------------------
function Game:getSceneSession ( key )
	return self.sceneSessionMap[ key ]
end

function Game:affirmSceneSession ( key )
	local session = self.sceneSessionMap[ key ]
	if not session then
		session = SceneSession ()
		session.name = key
		self.sceneSessionMap[ key ] = session
		table.insert ( self.sceneSessions, session )
		self.sceneSessionCount = #self.sceneSessions

		if self.initialized then
			session:init ()
		end
		if self.started then
			session:start ()
		end

		SignalModule.emitGlobalSignal ( "scene_session.add", key )
	end
	return session
end

function Game:getScene ( key )
	local session = self:getSceneSession ( key )
	return session and session:getScene ()
end

function Game:getMainSceneSession ()
	return self.mainSceneSession
end

function Game:removeSceneSession ( key )
	local session = self:getSceneSession ( key )
	if not session then
		_error ( 'no scene session found', key )
		return false
	end
	session:stop ()
	session:clear ()
	self.sceneSessionMap[ key ] = nil

	SignalModule.emitGlobalSignal ( "scene_session.remove", key )

	local idx = table.index ( self.sceneSessions, session )
	table.remove ( self.sceneSessions, idx )
	self.sceneSessionCount = #self.sceneSessions
	return true
end

function Game:updateSceneSessions ( delta )
	local sessions = self.sceneSessions

	for i = 1, self.sceneSessionCount do
		sessions[ i ]:update ( delta )
	end
end

--------------------------------------------------------------------
-- Scene
--------------------------------------------------------------------
function Game:openScene ( id, additive, arguments, autostart )
	local scnPath = self.namedSceneMap[ id ]
	if not scnPath then
		return _error ( 'scene not defined', id )
	end
	return self:openSceneByPath ( scnPath, additive, arguments, autostart )
end

function Game:openSceneByPath ( scnPath, additive, arguments, autostart )
	return self:getMainSceneSession ():openSceneByPath ( scnPath, additive, arguments, autostart )
end

function Game:getMainScene ()
	return self.mainScene
end

function Game:reopenMainScene ()
	return self:getMainSceneSession ():reopenScene ()
end

function Game:scheduleReopenMainScene ()
	return self:getMainSceneSession ():scheduleReopenScene ()
end

function Game:createNewSceneAndOpen ()
	-- self.mainScene = Scene ()
	-- emitGlobalSignal ( 'scene.open', self.mainScene, nil )
	-- emitGlobalSignal ( 'mainscene.open', self.mainScene, nil )
end

--------------------------------------------------------------------
-- Context Related
--------------------------------------------------------------------
function Game:getMainRenderContext ()
	return self.gameRenderContext
end

function Game:clearDeviceBufferBase ()
	if self.baseClearRenderPass then
		if self:getPlatformType () == "console" then
			_log ( "clearing device buffer" )
			self.baseClearRenderPass:setClearMode ( assert ( MOAILayer.CLEAR_ONCE_TRIPLE ) )
		else
			self.baseClearRenderPass:setClearMode ( MOAILayer.CLEAR_ALWAYS )
		end
	end
end

function Game:setCurrentRenderContext ( key )
	self.currentRenderContext = key or "game"
end

function Game:getCurrentRenderContext ()
	return self.currentRenderContext or "game"
end

function Game:isEditorMode ()
	return self.editorMode
end

--------------------------------------------------------------------
-- Cursor
--------------------------------------------------------------------
function Game:hideCursor ( reason )
	return getUICursorManager ():hide ( reason )
end

function Game:showCursor ( reason )
	if MOAIEnvironment.osBrand == "NS" then
		return
	end

	return getUICursorManager():show ( reason )
end

function Game:hideSystemCursor ( reason )
	reason = reason or "default"
	self.showSystemCursorReasons[ reason ] = nil

	if not next ( self.showSystemCursorReasons ) then
		MOAISim.hideCursor ()
	end
end

function Game:showSystemCursor ( reason )
	reason = reason or "default"
	self.showSystemCursorReasons[ reason ] = true
	MOAISim.showCursor ()
end

function Game:isRelativeMouseMode ()
	return self.relativeMouseMode
end

function Game:setRelativeMouseMode ( enabled )
	if MOAISim.setRelativeMouseMode then
		self.relativeMouseMode = enabled ~= false
		MOAISim.setRelativeMouseMode ( self.relativeMouseMode )
		getUICursorManager():setRelativeMouseMode ( self.relativeMouseMode )
		SignalModule.emitGlobalSignal ( "input.mouse.mode_change", self.relativeMouseMode )
	else
		_error ( "realtiveMouseMode not supported" )
		self.realtiveMouseMode = false
	end
end

--------------------------------------------------------------------
-- UserObject
--------------------------------------------------------------------
function Game:getUserObject ( key, default )
	local v = self.userObjects[ key ]

	if v == nil then
		return default
	end

	return v
end

function Game:setUserObject ( key, v )
	self.userObjects[ key ] = v
end

function Game:getUserConfig ( key, default )
	local v = self.userConfig[ key ]

	if v == nil then
		return default
	end

	return v
end

function Game:setUserConfig ( key, v )
	self.userConfig[ key ] = v
end

--------------------------------------------------------------------
-- Other
--------------------------------------------------------------------
function Game:setGCStep ( step )
	return MOAISim.setGCStep ( step )
end

function Game:setGCStepLimit ( limit )
	return MOAISim.setGCStepLimit ( limit )
end

function Game:addGCExtraStep ( step )
	return MOAISim.addGCExtraStep ( step )
end

function Game:collectgarbage ( ... )
	collectgarbage ( ... )
end

function Game:startBoostLoading ()
	self.boostLoadLock = self.boostLoadLock + 1
	_log ( "boost loading", self.boostLoadLock )
	local boosting = self.boostLoadLock > 0
	if not self.boostLoading then
		self.boostLoading = true
		if MOAIAppNX then
			MOAIAppNX.setCpuBoostMode ( assert ( MOAIAppNX.CPU_BOOST_MODE_FASTLOAD ) )
		end
	end
end

function Game:stopBoostLoading ()
	self.boostLoadLock = self.boostLoadLock - 1
	_log ( "boost loading", self.boostLoadLock )
end

return Game