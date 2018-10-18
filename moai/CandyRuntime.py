import os
import os.path
import logging
import json

from core              import *
from moai.MOAIRuntime \
	import \
	MOAIRuntime, MOAILuaDelegate, LuaTableProxy, _G, _LuaTable, _LuaObject, \
	_CANDY


signals.register ( 'candy.init' )
##----------------------------------------------------------------##
# _CANDY = LuaTableProxy( None )
_CANDY_EDIT = LuaTableProxy( None )

_CANDY_GAME_CONFIG_NAME = 'game_config.json'

def isCandyInstance(obj, name):
	if isinstance( obj, _LuaObject ):
		clas = _CANDY[name]
		assert clas
		return  _CANDY.isInstance( obj, clas )
	else:
		return False

def isCandySubInstance(obj, name):
	if isinstance( obj, _LuaObject ) or isinstance( obj, _LuaTable ):
		# return _CANDY.isSubclassInstance(obj, name)
		clas = _CANDY[name]
		assert clas
		return _CANDY.isSubclass(_CANDY.getClass(obj), clas)
	else:
		return False

def getCandyClassName(obj):
	if isinstance( obj, _LuaTable ):
		clas = obj.__class
		if clas: return clas.__name
	return None
	
##----------------------------------------------------------------##
class CandyRuntime( EditorModule ):
	
	def getDependency(self):
		# return [ 'moai', 'game_preview', 'script_library' ]
		return [ 'moai' ]

	def getName(self):
		return 'candy'

	def onLoad(self):
		self.affirmConfigFile()
		self.runtime  = self.getManager().affirmModule( 'moai' )

		self.setupLuaModule()		

		signals.connect( 'project.load', self.onProjectLoaded )
		signals.connect( 'moai.reset', self.onMoaiReset )
		signals.connect( 'moai.ready', self.onMoaiReady )

		signals.connect( 'project.post_deploy', self.postDeploy )
		signals.connect( 'project.save',        self.onProjectSave )

		self.initCandy()

		print 'load CandyRuntime ok!'

	def affirmConfigFile( self ):
		proj = self.getProject()
		self.configPath = proj.getConfigPath( _CANDY_GAME_CONFIG_NAME )
		asetIndexPath = proj.getRelativePath( self.getAssetLibrary().assetIndexPath )

		if os.path.exists( self.configPath ):
			data = jsonHelper.loadJSON( self.configPath )
			#fix invalid field
			if data.get( 'asset_library', None ) != asetIndexPath: #fix assetlibrary path
				data['asset_library'] = asetIndexPath
				jsonHelper.trySaveJSON( data, self.configPath)
			return
		#create default config
		defaultConfigData = {
			"asset_library": asetIndexPath ,
			"texture_library": "env/config/texture_library.json",
			"layers" : [
				{ "name" : "default",
					"sort" : "priority_ascending",
					"clear": False
				 },
			]
		}
		jsonHelper.trySaveJSON( defaultConfigData, self.configPath )

	def onAppReady( self ):
		self.postInitCandy()
		# self.getModule( 'game_preview' ).updateView()

	def postDeploy( self, context ):
		configPath = context.getPath( 'game_config' )
		game = _CANDY.game
		data = json.loads( game.saveConfigToString( game ) )
		data[ 'asset_library'   ] = 'asset/asset_index'
		data[ 'texture_library' ] = context.meta.get( 'mock_texture_library', False )
		data[ 'script_library'  ] = context.meta.get( 'mock_script_library', False )
		jsonHelper.trySaveJSON( data, configPath, 'deploy game info' )

	def setupLuaModule( self ):
		# global _CANDY
		# global _CANDY_EDIT

		self.runtime.requireModule( 'candy_edit' )
		# _CANDY._setTarget( _G['candy'] )
		_CANDY_EDIT._setTarget( _G['candy_edit'] )
		# _CANDY.setBasePaths( self.getProject().getPath(), self.getProject().getAssetPath() )

	def syncAssetLibrary(self): #TODO:
		pass

	def initCandy(self):
		try:
			_CANDY.init(self.configPath, True)

			if not self.runtime.getRenderContext( 'game' ):
				self.runtime.createRenderContext( 'game' )
			self.runtime.changeRenderContext( 'game', 100, 100 )

			# self.runtime.runString("_stat('CandyRuntime.initCandy() after getRenderContext()', MOAISim.getActionMgr():getRoot())")

		except Exception, e:
			raise e

	def postInitCandy(self):
		try:
			# _CANDY.init(self.configPath, True)

			# print ("postInitCandy() _CANDY ok!")

			signals.emit( 'candy.init' )
		except Exception, e:
			raise e

	def onProjectLoaded(self,prj):
		self.syncAssetLibrary()

	def onProjectSave( self, prj ):
		game = _CANDY.game
		game.saveConfigToFile( game, self.configPath )

	def onMoaiReset(self):		
		self.setupLuaModule()

	def onMoaiReady( self ):
		self.initCandy()

	def getCandyEnv( self ):
		return _CANDY

	def getCandyEditEnv( self ):
		return _CANDY_EDIT

	def getLuaEnv( self ):
		return _G

	def getComponentTypeList( self ):
		pass

	def getEntityTypeList( self ):
		pass


##----------------------------------------------------------------##	
CandyRuntime().register()
