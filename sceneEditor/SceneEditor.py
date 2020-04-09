from core           import app, signals, EditorCommandStack, RemoteCommand
from core.asset     import AssetLibrary
from core.selection import SelectionManager, getSelectionManager

from qt.controls.Window import MainWindow
from qt.controls.Menu   import MenuManager
from qt.TopEditorModule import TopEditorModule, SubEditorModule
from qt.dialogs import *

from moai.MOAIRuntime import _CANDY

# from qt.IconCache                  import getIcon
# from qt.controls.GenericTreeWidget import GenericTreeWidget
from core.signals import register
##----------------------------------------------------------------##
class SceneEditorModule( SubEditorModule ):
	def getParentModuleId( self ):
		return 'scene_editor'

	def getSceneEditor( self ):
		return self.getParentModule()

	def getSceneToolManager( self ):
		return self.getModule( 'scene_tool_manager' )

	def changeSceneTool( self, toolId ):
		self.getSceneToolManager().changeTool( toolId )

	def getAssetSelection( self ):
		return getSelectionManager( 'asset' ).getSelection()

_CANDY_EDITOR_DEFAULT_SCENE_SESSION_KEY = "editor"
_CANDY_EDITOR_DEFAULT_SCENE_SESSION = False
##----------------------------------------------------------------##
class SceneEditor( TopEditorModule ):
	name       = 'scene_editor'
	dependency = ['qt', 'moai']

	def getSelectionGroup( self ):
		return 'scene'

	def getWindowTitle( self ):
		return 'Scene Editor'

	def onSetupMainWindow( self, window ):
		self.mainToolBar = self.addToolBar( 'scene', self.mainWindow.requestToolBar( 'main' ) )		
		window.setMenuWidget( self.getQtSupport().getSharedMenubar() )
		window.setWindowIcon( self.getQtSupport().mainWindowIcon )
		# from PyQt5.QtCore import Qt
		# window.setWindowFlags(Qt.FramelessWindowHint)
		#menu
		self.menu = self.addMenu( 'main/scene', dict( label = 'Scene' ) )

		self.menu.addChild([
			{'name': 'new_scene', 'label': 'New Scene'},
			{'name': 'open_scene', 'label': 'Open Scene'},
			'----',
			{'name': 'start_scene', 'label': 'Start Scene Tick'},
			{'name': 'pause_scene', 'label': 'Pause Scene'},
			{'name': 'stop_scene', 'label': 'Stop Scene'},
			'----',
			{'name': 'toggle_scene_view_window', 'label': 'Show Scene View', 'shortcut': 'f4'},
		], self)

	def onLoad( self ):
		self.sceneView = self.getModule('scene_view')
		self.runtime = self.getModule('moai')

		signals.connect( 'app.start', self.postStart )
		return True

	def postStart( self ):
		self.mainWindow.show()

	def onMenu(self, node):
		name = node.name
		if name == 'new_scene':
			self.createNewSceneAndOpen()
		elif name == 'open_scene':
			#TODO
			pass
		elif name == 'start_scene':
			# self.startPreview()
			self.runtime.runString("candy.game:getMainSceneSession():start()")
			pass
		elif name == 'stop_scene':
			# self.stopPreview()
			self.runtime.runString("candy.game:getMainSceneSession():stop()")
			pass
		elif name == 'pause_scene':
			# self.pausePreview()
			self.runtime.runString("candy.game:getMainSceneSession():pause(true)")
			pass
		elif name == 'toggle_scene_view_window':
			self.sceneView.window.show()
			# self.sceneView.window.setFocus()

	def onTool( self, tool ):
		name = tool.name
		# if name == 'run':
		# 	from gii.core.tools import RunHost
		# 	RunHost.run( 'main' )
		#
		# elif name == 'deploy':
		# 	deployManager = self.getModule('deploy_manager')
		# 	if deployManager:
		# 		deployManager.setFocus()

	def createNewSceneAndOpen(self):
		self.getModule('asset_browser').createAsset('scene')
		nodePath = self.getModule('asset_browser').newCreateNodePath
		node = AssetLibrary.get().initAssetNode(nodePath)
		self.getModule('sceneoutliner_editor').openScene(node)


##----------------------------------------------------------------##
def getSceneSelectionManager():
	return app.getModule('scene_editor').selectionManager

##----------------------------------------------------------------##
class RemoteCommandRunGame( RemoteCommand ):
	name = 'run_game'
	# def run( self, target = None, *args ):
	# 	from core.tools import RunHost
	# 	RunHost.run( 'main' )


##----------------------------------------------------------------##
register( 'scene.pre_open' )
register( 'scene.update' )
register( 'scene.clear' )
register( 'scene.save' )
register( 'scene.saved' )
register( 'scene.open' )
register( 'scene.close' )
register( 'scene.change' ) #Scene is changed during preview

register( 'scene.modified' )

register( 'actor.added' )
register( 'actor.removed' )
register( 'actor.modified' )
register( 'actor.renamed' )
register( 'actor.visible_changed' )
register( 'actor.pickable_changed' )

# register( 'prefab.unlink' )
# register( 'prefab.relink' )
# register( 'prefab.push' )
# register( 'prefab.pull' )
#
# register( 'proto.unlink' )
# register( 'proto.relink' )

register( 'component.added' )
register( 'component.removed' )

# register( 'animator.start' )
# register( 'animator.stop' )

register( 'scene_tool.change' )
register( 'scene_tool_category.update' )
# register( 'external_player.start' )
# register( 'external_player.stop' )

SceneEditor ().register ()