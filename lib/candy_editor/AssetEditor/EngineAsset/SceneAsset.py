import os.path
import json
from candy_editor.core import *
from candy_editor.moai.MOAIRuntime import _CANDY
from candy_editor.qt.dialogs import alertMessage

class SceneAssetManager ( AssetManager ):

	def getName ( self ):
		return 'asset_manager.scene'

	def acceptAssetFile ( self, filePath ):
		if os.path.isfile ( filePath ):
			name, ext = os.path.splitext ( filePath )
			if not ext in ['.scene']: return False
			data = jsonHelper.tryLoadJSON ( filePath )
			return data and data.get ( '_assetType', None ) == 'scene'
		if os.path.isdir ( filePath ):
			name, ext = os.path.splitext ( filePath )
			if not ext in [ '.scene' ]: return False
			return True

	def importAsset ( self, node, reload = False ):
		node.assetType = 'scene'
		node.setObjectFile ( 'def', node.getFilePath () )
		node.groupType = 'package'
		#scan proto nodes
		data = jsonHelper.tryLoadJSON ( node.getFilePath () )
		# protoInfos = data.get ( 'protos', None )
		# if protoInfos:
		# 	for protoInfo in protoInfos:
		# 		name  =  protoInfo[ 'name' ]
		# 		protoNode = node.affirmChildNode ( name, 'proto', manager = self )
		# 		protoNode.setObjectFile ( 'def', protoNode.getCacheFile ( 'data' ) )
		# 		fp = file ( protoNode.getAbsCacheFile ( 'data' ), 'w' )
		# 		serialized = protoInfo['serialized']
		# 		fp.write ( base64.b64decode ( serialized ) )
		# 		fp.close ()
				#extract data and
		return True

	def editAsset ( self, node ):
		editor = app.getModule ( 'sceneoutliner_editor' )
		if not editor:
			return alertMessage ( 'Editor not load', 'Scene Outliner Editor not found!' )
		if node.assetType == 'scene':
			editor.openScene ( node )
		elif node.assetType == 'proto':
			scnNode = node.getParent ()
			editor.openScene ( scnNode, node )
		else:
			return

##----------------------------------------------------------------##
class SceneCreator ( AssetCreator ):

	def getAssetType ( self ):
		return 'scene'

	def getLabel ( self ):
		return 'Scene'

	def createAsset ( self, name, contextNode, assetType ):
		ext = '.scene'
		filename = name + ext
		if contextNode.isType ( 'folder' ):
			nodepath = contextNode.getChildPath ( filename )
		else:
			nodepath = contextNode.getSiblingPath ( filename )

		fullpath = AssetLibrary.get ().getAbsPath ( nodepath )
		data = {
			'_assetType': 'scene', #checksum
			'map': {},
			'entities': []
		}
		if os.path.exists ( fullpath ):
			raise Exception ( 'File already exist:%s' % fullpath )
		fp = open ( fullpath,'w' )
		json.dump ( data, fp, sort_keys=True, indent=2 )
		fp.close ()
		# _CANDY.serializeSceneToFile ( _CANDY.Scene (), fullpath )
		return nodepath

##----------------------------------------------------------------##
SceneAssetManager ().register ()
SceneCreator ().register ()

AssetLibrary.get ().setAssetIcon ( 'scene', 'scene' )
# AssetLibrary.get ().setAssetIcon ( 'proto', 'proto' )
