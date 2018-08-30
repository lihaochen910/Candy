from core           import app, signals, EditorCommandStack, RemoteCommand
from core.selection import SelectionManager, getSelectionManager

from qt.controls.Window import MainWindow
from qt.controls.Menu   import MenuManager
from qt.TopEditorModule import TopEditorModule, SubEditorModule

# from qt.IconCache                  import getIcon
# from qt.controls.GenericTreeWidget import GenericTreeWidget
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


##----------------------------------------------------------------##
class SceneEditor( TopEditorModule ):
	name       = 'scene_editor'
	dependency = ['qt']

	def getSelectionGroup( self ):
		return 'scene'

	def getWindowTitle( self ):
		return 'Scene Editor'

	def onSetupMainWindow( self, window ):
		self.mainToolBar = self.addToolBar( 'scene', self.mainWindow.requestToolBar( 'main' ) )		
		window.setMenuWidget( self.getQtSupport().getSharedMenubar() )
		window.setWindowIcon( self.getQtSupport().mainWindowIcon )
		# from PyQt4.QtCore import Qt
		# window.setWindowFlags(Qt.FramelessWindowHint)
		#menu
		self.addMenu( 'main/scene', dict( label = 'Scene' ) )

	def onLoad( self ):
		signals.connect( 'app.start', self.postStart )
		return True

	def postStart( self ):
		self.mainWindow.show()

	def onMenu(self, node):
		name = node.name
		if name == 'open_scene':
			#TODO
			pass

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

##----------------------------------------------------------------##
def getSceneSelectionManager():
	return app.getModule('scene_editor').selectionManager

##----------------------------------------------------------------##
class RemoteCommandRunGame( RemoteCommand ):
	name = 'run_game'
	# def run( self, target = None, *args ):
	# 	from core.tools import RunHost
	# 	RunHost.run( 'main' )

