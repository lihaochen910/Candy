import os.path
import logging
import subprocess
import shutil
import json

from candy_editor.core import *
from candy_editor.moai.MOAIRuntime import _CANDY

##----------------------------------------------------------------##
class ShaderAssetManager ( AssetManager ):
	def getName ( self ):
		return 'asset_manager.shader'

	def getMetaType ( self ):
		return 'script'

	def acceptAssetFile ( self, filePath ):
		if not os.path.isfile ( filePath ): return False
		name, ext = os.path.splitext ( filePath )
		if not ext in [ '.shader' ]: return False
		return True

	def importAsset ( self, node, reload = False ):
		node.assetType = 'shader'		
		node.setObjectFile ( 'def', node.getFilePath () )
		return True

	# def onRegister ( self ):
		#check builtin shaders
		
	# def editAsset (self, node):
	# 	editor = app.getModule ( 'framebuffer_editor' )
	# 	if not editor: 
	# 		return alertMessage ( 'Editor not load', 'shader Editor not found!' )
	# 	editor.openAsset ( node )

##----------------------------------------------------------------##
class ShaderAssetCreator ( AssetCreator ):

	def getAssetType ( self ):
		return 'shader'

	def getLabel ( self ):
		return 'Shader'

	def createAsset ( self, name, contextNode, assetType ):
		ext = '.shader'
		filename = name + ext
		if contextNode.isType ( 'folder' ):
			nodepath = contextNode.getChildPath ( filename )
		else:
			nodepath = contextNode.getSiblingPath ( filename )

		fullpath = AssetLibrary.get ().getAbsPath ( nodepath )
		
		_CANDY.createEmptySerialization ( fullpath, 'candy.Shader' )
		return nodepath



class ShaderScriptAssetManager ( AssetManager ):

	def getName ( self ):
		return 'asset_manager.shader_script'

	def getMetaType ( self ):
		return 'script'

	def acceptAssetFile ( self, filePath ):
		if not os.path.isfile ( filePath ): return False
		name, ext = os.path.splitext ( filePath )
		if not ext in [ '.vsh', '.fsh' ]: return False
		return True

	def importAsset ( self, node, reload = False ):
		name, ext = os.path.splitext ( node.getFilePath () )
		if ext == '.vsh':
			node.assetType = 'vsh'
		elif ext == '.fsh':
			node.assetType = 'fsh'
		node.setObjectFile ( 'src', node.getFilePath () )
		return True

##----------------------------------------------------------------##
ShaderAssetManager ().register ()
ShaderAssetCreator ().register ()

ShaderScriptAssetManager ().register ()

AssetLibrary.get ().setAssetIcon ( 'shader',  'shader' )
AssetLibrary.get ().setAssetIcon ( 'vsh',  'text-red' )
AssetLibrary.get ().setAssetIcon ( 'fsh',  'text-yellow' )
