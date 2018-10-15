import os.path

from core import AssetManager

class ImageAssetManager( AssetManager ):
	def getName(self):
		return 'asset_manager.image'

	def acceptAssetFile(self, filepath):
		if not os.path.isfile(filepath): return False		
		name,ext = os.path.splitext(filepath)
		return ext in [ '.png','.jpg','.jpeg','.bmp','.psd' ]

	def importAsset(self, node, option=None):
		node.assetType = 'image'
		return True

ImageAssetManager().register()
