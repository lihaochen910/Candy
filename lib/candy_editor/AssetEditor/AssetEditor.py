from candy_editor.core import *
from candy_editor.core.selection import SelectionManager

from candy_editor.qt.helpers.IconCache import getIcon
from candy_editor.qt.controls.Window import MainWindow
from candy_editor.qt.controls.Menu import MenuManager
from candy_editor.qt import TopEditorModule
from candy_editor.qt.TopEditorModule import SubEditorModule

from util import FileWatcher

# from SearchView import requestSearchView, registerSearchEnumerator


##----------------------------------------------------------------##
class AssetEditorModule ( SubEditorModule ):

	def getParentModuleId ( self ):
		return 'asset_editor'

	def getSceneEditor ( self ):
		return self.getParentModule ()


##----------------------------------------------------------------##
class AssetEditor ( TopEditorModule ):

	name = 'asset_editor'
	dependency = [ 'qt' ]

	def getWindowTitle ( self ):
		return 'Asset Editor'

	def getSelectionGroup ( self ):
		return 'asset'

	def onSetupMainWindow ( self, window ):
		self.mainToolBar = self.addToolBar ( 'asset', self.mainWindow.requestToolBar ( 'main' ) )
		# window.setMenuWidget(self.getQtSupport().getSharedMenubar())
		####
		self.addMenu ( 'main/asset', { 'label': '&Asset' } )
		self.addMenuItem (
			'main/asset/reset_all_asset',
			dict ( label = 'Reset Asset Library' )
		)
		self.addMenuItem (
			'main/asset/clear_free_meta',
			dict ( label = 'Clear Metadata' )
		)

	def onLoad ( self ):
		self.projectScanScheduled = False
		self.projectScanTimer = self.mainWindow.startTimer ( 10, self.checkProjectScan )
		signals.connect ( 'app.start', self.postStart )

	# registerSearchEnumerator( assetSearchEnumerator )
	# registerSearchEnumerator( assetFolderSearchEnumerator )

	def postStart ( self ):
		# self.mainWindow.show()
		# self.mainWindow.raise_()
		pass

	def checkProjectScan ( self ):
		lib = self.getAssetLibrary ()
		if lib.projectScanScheduled:
			lib.scanProject ()

	def onMenu ( self, node ):
		name = node.name
		if name == 'reset_all_asset':
			self.getAssetLibrary ().reset ()
		elif name == 'clear_free_meta':
			self.getAssetLibrary ().clearFreeMetaData ()

	def onTool ( self, tool ):
		pass


##----------------------------------------------------------------##
def getAssetSelectionManager ():
	return app.getModule ( 'asset_editor' ).selectionManager


##----------------------------------------------------------------##
def assetSearchEnumerator ( typeId, context, option ):
	if not context in [ 'all', 'asset' ]: return
	result = []
	lib = AssetLibrary.get ()
	for node in AssetLibrary.get ().enumerateAsset ( typeId ):
		assetType = node.getType ()
		iconName = lib.getAssetIcon ( assetType ) or 'normal'
		entry = (node, node.getNodePath (), node.getType (), iconName)
		result.append ( entry )
	return result


##----------------------------------------------------------------##
def assetFolderSearchEnumerator ( typeId, context, option ):
	if not context in [ 'asset_folder' ]: return
	result = []
	lib = AssetLibrary.get ()
	for node in AssetLibrary.get ().enumerateAsset ( typeId ):
		if not node.getGroupType () in ('folder', 'package'): continue
		assetType = node.getType ()
		iconName = lib.getAssetIcon ( assetType ) or 'normal'
		entry = (node, node.getNodePath (), node.getType (), iconName)
		result.append ( entry )
	return result


# AssetEditor ().register ()
