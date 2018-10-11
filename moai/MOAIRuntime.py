import logging
from core import signals, EditorModule, RemoteCommand, app
from core.helpers import printTraceBack

from AKU import getAKU, _LuaTable, _LuaThread, _LuaObject, _LuaFunction

from LuaTableProxy import LuaTableProxy

from MOAIInputDevice import MOAIInputDevice

##----------------------------------------------------------------##
_G              = LuaTableProxy( None )
_CANDY          = LuaTableProxy( None )
_CANDY_EDITOR   = LuaTableProxy( None )

signals.register( 'lua.msg' )
signals.register( 'moai.clean' )
signals.register( 'moai.reset' )
signals.register( 'moai.ready' )

##----------------------------------------------------------------##
import LuaBridge

##----------------------------------------------------------------##
## MOAIRuntime
##----------------------------------------------------------------##
class MOAIRuntime( EditorModule ):
	_singleton=None

	@staticmethod
	def get():
		return MOAIRuntime._singleton

	def __init__(self):
		assert not MOAIRuntime._singleton
		MOAIRuntime._singleton = self
		super(MOAIRuntime, self).__init__()		

		self.paused            = False
		self.GLContextReady    = False
		
		self.luaModules        = []
		self.luaDelegates      = {}

		self.inputDevices      = {}
		self.lastInputDeviceId = 0

	def getName(self):
		return 'moai'

	def getDependency(self):
		return []	

	##----------------------------------------------------------------##
	def getLuaEnv( self ):
		return _G

	def getRuntimeEnv( self ):
		return _CANDY

	#-------Context Control
	def initContext(self):
		global _G
		global _CANDY
		global _C

		self.luaModules        = []

		self.inputDevices      = {}
		self.lastInputDeviceId = 0
		
		aku = getAKU()
		self.GLContextReady = False

		aku.resetContext()

		aku.setInputConfigurationName('CANDY')

		#inject python env
		lua = aku.getLuaRuntime()
		_G._setTarget( lua.globals() )

		_G['CANDY_PYTHON_BRIDGE']            = LuaBridge
		_G['CANDY_DATA_PATH']                = self.getApp().getPath('resources')

		_G['CANDY_LIB_LUA_PATH']              = self.getApp().getPath('lua')
		_G['CANDY_PROJECT_ENV_LUA_PATH']     = self.getProject().getEnvLibPath( 'lua' )
		_G['CANDY_PROJECT_ASSET_PATH']       = self.getProject().getAssetPath()
		_G['CANDY_PROJECT_SCRIPT_LIB_PATH']  = self.getProject().getScriptLibPath()

		_G.MOAIEnvironment.horizontalResolution = 1920
		_G.MOAIEnvironment.verticalResolution = 1080

		logging.info( 'loading moai lua runtime' )
		aku.runScript(
			self.getApp().getPath( 'moai/MOAIInterfaces.lua' )
		)

		logging.info('loading project script lib')
		self.setWorkingDirectory(self.getProject().getScriptLibPath())
		aku.runScript(
			self.getProject().getScriptLibPath('main.lua')
		)

		# init candy editor lua module
		logging.info('loading candy editor lua module')
		aku.runScript(
			self.getApp().getPath( 'lua/init.lua' )
		)

		_CANDY._setTarget( _G['candy'] )
		_CANDY_EDITOR._setTarget( _G['candy_editor'] )

		assert _CANDY, "Failed loading Candy Lua Runtime!"
		assert _CANDY_EDITOR, "Failed loading CandyEditor Lua Module! Check ./lua/candy_editor"
		#finish loading lua bridge
		
		self.AKUReady      = True
		self.RunningScript = False
		self.paused        = False
		self.GLContextInitializer = None
		
		# getAKU().setFuncOpenWindow( self.onOpenWindow )
		print('MOAIRuntime initContext() ok.')

	def initGLContext( self ):
		if self.GLContextReady: return True
		logging.info('init GL context')
		from qt.controls.GLWidget import GLWidget
		GLWidget.getSharedWidget().makeCurrent()
		# if not self.GLContextInitializer: 
		# 	logging.warn( 'no GL initializer found' )
		# 	return False
		# logging.info( 'initialize GL context' )
		# self.GLContextInitializer()
		# signals.emitNow( 'moai.context.init' )
		getAKU().detectGfxContext()
		self.GLContextReady = True
		return True

	# def setGLContextInitializer( self, func ):
	# 	self.GLContextInitializer = func

	def onStart( self ):
		pass

	def reset(self):
		if not self.AKUReady: return
		self.cleanLuaReferences()
		self.initContext()
		self.setWorkingDirectory( self.getProject().getPath() )
		signals.emitNow( 'moai.reset' )
		signals.emitNow( 'moai.ready' )

	def onOpenWindow( self, title, w, h ):
		raise Exception( 'No GL context provided.' )

	#------Manual Control For MOAI Module
	#TODO: move function below into bridge module
	def stepSim(self, step):
		# _CANDY.stepSim(step)
		_G.MOAISim.stepSim(step)
		
	def setBufferSize(self, w,h):
		#for setting edit canvas size (without sending resize event)
		# _CANDY.setBufferSize(w,h)
		_G.MOAISim.setBufferSize(w, h)

	def manualRenderAll(self):
		if not self.GLContextReady: return
		# _CANDY.manualRenderAll()
		_G.MOAISim.renderFrameBuffer(_G.MOAIGfxMgr.getFrameBuffer())

	def getRenderContext(self, key):
		return _CANDY_EDITOR.getRenderContext(key)

	def changeRenderContext(self, contextId, w, h ):
		_CANDY_EDITOR.changeRenderContext( contextId or False, w or False, h or False )

	def createRenderContext( self, key, clearColor = (0,0,0,0) ):
		_CANDY_EDITOR.createRenderContext( key, *clearColor )

	#### Delegate Related
	def loadLuaDelegate( self, scriptPath , owner = None, **option ):
		if not option.get('forceReload', False): #find in cache first
			delegate = self.luaDelegates.get( scriptPath )
			if delegate: return delegate
		delegate = MOAILuaDelegate( owner )
		delegate.load( scriptPath )
		self.luaDelegates[ scriptPath ] = delegate
		return delegate

	def loadLuaWithEnv( self, file, env = None, **option ):
		try:
			if env:
				assert isinstance( env, dict )
			return _CANDY_EDITOR.loadLuaWithEnv( file, env, option.get( 'isdelegate', False ) )
		except Exception, e:
			logging.error( 'error loading lua:\n' + str(e) )

	####  LuaModule Related
	def registerLuaModule(self, m):
		self.luaModules.append(m)
		# registerModule(m)
	
	#clean holded lua object(this is CRITICAL!!!)
	def cleanLuaReferences(self):
		logging.info('clean lua reference')
		#clear lua module
		# for m in self.luaModules:
		# 	unregisterModule(m)

		# bridge.clearSignalConnections()
		# bridge.clearLuaRegisteredSignals()

		#clear lua object inside introspector
		introspector=self.getModule('introspector')
		if introspector:
			instances = introspector.getInstances()
			for ins in instances:
				if isinstance(ins.target,(_LuaTable, _LuaObject, _LuaThread, _LuaFunction)):
					ins.clear()

		signals.emitNow('moai.clean')

	#General Control
	def setWorkingDirectory(self, path):
		logging.info('change moai working path:' + path )
		getAKU().setWorkingDirectory(path)

	def pause(self, paused=True):
		self.paused=paused
		getAKU().pause(self.paused)

	def resume(self):
		self.pause(False)
	
	def execConsole(self, command):
		# logging.info('execConsole: ' + command)
		self.runString(command)

	def updateAKU(self):
		if not self.AKUReady: return False
		if self.paused: return False	
		try:
			getAKU().update()
		except MOAIException as e:
			self.handleException(e)
			return False
		return True

	def renderAKU(self):
		if not self.AKUReady: return False
		try:
			getAKU().render()
		except MOAIException as e:
			self.handleException(e)
			return False
		return True

	def runScript(self,src):		
		self.RunningScript = src
		if not src: return
		try:
			getAKU().runScript(src)
		except MOAIException as e:
			self.handleException(e)
			return False
		return True

	def runString(self,string):		
		try:
			getAKU().runString(string)
		except MOAIException as e:
			self.handleException(e)
			return False
		return True

	def requireModule( self, modulename ):
		return self.runString( 'require "%s"' % modulename )

	def handleException(self,e):
		code = e.code
		if code=='TERMINATE':
			self.AKUReady      = False
			self.RunningScript = False
		else:
			logging.error( 'error loading lua:\n' + str(e) )

	#Input Device Management
	def getInputDevice(self, name):
		return self.inputDevices.get(name,None)

	def addInputDevice(self, name):
		device = MOAIInputDevice(name, self.lastInputDeviceId)
		self.inputDevices[name] = device
		self.lastInputDeviceId += 1

		getAKU().reserveInputDevices(self.lastInputDeviceId)
		for inputDevice in self.inputDevices.values():
			inputDevice.onRegister()
		return device

	def addDefaultInputDevice( self, name='device' ):
		logging.info( 'add input device: ' + str( name ) )
		device = self.addInputDevice(name)
		device.addSensor('touch',       'touch')
		device.addSensor('pointer',     'pointer')
		device.addSensor('keyboard',    'keyboard')
		device.addSensor('mouseLeft',   'button')
		device.addSensor('mouseRight',  'button')
		device.addSensor('mouseMiddle', 'button')
		device.addSensor('level',       'level')
		device.addSensor('compass',     'compass')
		for i in range( 0, 4 ):
			device.addJoystickSensors( i + 1 )
		return device

	#----------
	def onLoad(self):
		self.AKUReady = False
		signals.tryConnect ( 'console.exec', self.execConsole )
		self.initContext()
		self.setWorkingDirectory( self.getProject().getPath() )
		self.initGLContext()
		# scriptInit = self.getProject().getScriptLibPath( 'main.lua' )
		# import os
		# if os.path.exists( scriptInit ):
		# 	getAKU().runScript( scriptInit )

		print('load MOAIRuntime ok!')

	def onUnload(self):
		# self.cleanLuaReferences()
		self.AKUReady   = False
		pass



##----------------------------------------------------------------##
## Delegate
##----------------------------------------------------------------##
class MOAILuaDelegate(object):
	def __init__(self, owner=None, **option):
		self.scriptPath   = None
		self.scriptEnv    = None
		self.owner        = owner
		self.name         = option.get( 'name', None )

		self.extraSymbols = {}
		self.clearLua()
		signals.connect('moai.clean', self.clearLua)
		if option.get( 'autoReload', True ):
			signals.connect('moai.reset', self.reload)

	def load( self, scriptPath, scriptEnv = None ):
		self.scriptPath = scriptPath
		self.scriptEnv  = scriptEnv
		runtime = MOAIRuntime.get()
		try:
			env = {
				'_owner'      : self.owner,
				'_delegate'   : self
			}
			if self.scriptEnv:
				env.update( self.scriptEnv )
			if self.name:
				env['_NAME'] = env.name
			self.luaEnv = runtime.loadLuaWithEnv( scriptPath, env, isdelegate = True )
		except Exception, e:
			logging.exception( e )

	def reload(self):
		if self.scriptPath: 
			self.load( self.scriptPath, self.scriptEnv )
			for k,v in self.extraSymbols.items():
				self.setEnv(k,v)

	def setEnv(self, name ,value, autoReload = True):
		if autoReload : self.extraSymbols[name] = value
		self.luaEnv[name] = value

	def getEnv(self, name, defaultValue = None):
		v = self.luaEnv[name]
		if v is None : return defaultValue
		return v

	def safeCall(self, method, *args):
		if not self.luaEnv:
			printTraceBack()
			logging.error( 'trying call a empty lua delegate, owned by %s' % repr( self.owner ) )
			return
		m = self.luaEnv[method]
		if not m: return
		try:
			return m(*args)
		except Exception, e:
			# logging.exception( e )
			print e
	
	def safeCallMethod( self, objId, methodName, *args ):
		if not self.luaEnv: 
			printTraceBack()
			logging.error( 'trying call a empty lua delegate, owned by %s' % repr( self.owner ) )
			return
		obj = self.luaEnv[objId]
		if not obj: return
		method = obj[methodName]
		if not method: return
		try:
			return method( obj, *args )
		except Exception, e:
			# logging.exception( e )
			print e

	def call(self, method, *args):
		m = self.luaEnv[method]
		return m(*args)

	def callMethod( self, objId, methodName, *args ):
		obj = self.luaEnv[objId]
		method = obj[methodName]
		return method( obj, *args )

	def clearLua(self):
		self.luaEnv=None


##----------------------------------------------------------------##
## Exception
##----------------------------------------------------------------##
class MOAIException(Exception):
	def __init__(self, code):
		self.args=(code,)
		self.code=code


MOAIRuntime().register()


##----------------------------------------------------------------##
class RemoteCommandEvalScript( RemoteCommand ):
	name = 'eval'
	def run( self, *args ):
		if len( args ) >= 1:
			s = ' '.join( args )
			runtime = app.getModule( 'moai' )
			print '> ' + s
			runtime.runString( s )
