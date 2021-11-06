import os.path

from candy_editor.core import AssetManager, AssetLibrary, AssetCreator, app
from candy_editor.qt.dialogs import requestString, alertMessage, requestConfirm

from candy_editor.moai.MOAIRuntime import _CANDY

##----------------------------------------------------------------##
class StyleSheetAssetManager ( AssetManager ):
	def getName ( self ):
		return 'asset_manager.stylesheet'

	def acceptAssetFile ( self, filepath ):
		if not os.path.isfile ( filepath ): return False
		if not filepath.endswith ( '.stylesheet' ): return False
		return True

	def importAsset ( self, node, reload = False ):
		node.assetType = 'stylesheet'
		node.setObjectFile ( 'def', node.getFilePath () )
		return True

	def editAsset ( self, node ):
		editor = app.getModule ( 'candy.stylesheet_editor' )
		if not editor: 
			return alertMessage ( 'Editor not load', 'Style Editor not found!' )
		editor.setFocus ()
		editor.openAsset ( node )

##----------------------------------------------------------------##
class StyleSheetCreator ( AssetCreator ):

	def getAssetType ( self ):
		return 'stylesheet'

	def getLabel ( self ):
		return 'Style Sheet'

	def createAsset ( self, name, contextNode, assetType ):
		ext = '.stylesheet'
		filename = name + ext

		if contextNode.isType ( 'folder' ):
			nodepath = contextNode.getChildPath ( filename )
			print ( nodepath )
		else:
			nodepath = contextNode.getSiblingPath ( filename )

		fullpath = AssetLibrary.get ().getAbsPath ( nodepath )
		modelName = _CANDY.Model.findName ( 'StyleSheet' )
		assert ( modelName )
		_CANDY.createEmptySerialization ( fullpath, modelName )
		return nodepath


##----------------------------------------------------------------##
StyleSheetAssetManager ().register ()
StyleSheetCreator ().register ()

AssetLibrary.get ().setAssetIcon ('stylesheet', 'text')
