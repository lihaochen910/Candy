import json

from PyQt5.QtCore     import QSize

from candy_editor.core import *
from candy_editor.qt.helpers.IconCache          import getIcon
from candy_editor.qt.controls.GenericTreeWidget import GenericTreeWidget, GenericTreeFilter
from candy_editor.qt.controls.GenericListWidget import GenericListWidget

from .AssetFilterWidget import *


CANDY_MIME_ASSET_LIST  = 'application/candy.asset-list'

##----------------------------------------------------------------##
def _getModulePath ( path ):
	import os.path
	return os.path.dirname ( __file__ ) + '/' + path

##----------------------------------------------------------------##
class AssetFolderTreeFilter ( GenericTreeFilter ):
	pass

##----------------------------------------------------------------##
#TODO: allow sort by other column
class AssetTreeItem ( QtWidgets.QTreeWidgetItem ):

	def __lt__ ( self, other ):
		node0 = self.node
		node1 = hasattr ( other, 'node' ) and other.node or None
		if not node0:
			return False
		if not node1:
			return True
		tree = self.treeWidget ()

		# if not tree:
		# 	col = 0
		# else:
		# 	col = tree.sortColumn ()
		t0 = node0.getType ()
		t1 = node1.getType ()
		if t1 != t0:
			if tree.sortOrder () == 0:
				if t0 == 'folder': return True
				if t1 == 'folder': return False
			else:
				if t0 == 'folder': return False
				if t1 == 'folder': return True
		return super ( AssetTreeItem, self ).__lt__ ( other )
		# return node0.getName ().lower ()<node1.getName ().lower ()

##----------------------------------------------------------------##
class AssetFolderTreeView ( GenericTreeWidget ):

	def __init__ ( self, *args, **option ):
		option[ 'show_root' ] = True
		super ( AssetFolderTreeView, self ).__init__ ( *args, **option )
		self.refreshingSelection = False
		self.setHeaderHidden ( True )

	def saveTreeStates ( self ):
		for node, item in self.nodeDict.items ():
			node.setProperty ( 'expanded', item.isExpanded () )

	def loadTreeStates ( self ):
		for node, item in self.nodeDict.items ():
			item.setExpanded ( node.getProperty ( 'expanded', False ) )
		self.getItemByNode ( self.getRootNode () ).setExpanded ( True )
		
	def getRootNode ( self ):
		return app.getAssetLibrary ().getRootNode ()

	def getNodeParent ( self, node ): # reimplemnt for target node
		return node.getParent ()

	def getNodeChildren ( self, node ):
		result = []
		for node in node.getChildren ():
			if node.getProperty ( 'hidden', False ): continue
			if not node.getGroupType () in ( 'folder', 'package' ) :continue
			result.append ( node )
		return result

	def createItem ( self, node ):
		return AssetTreeItem ()

	def updateItemContent ( self, item, node, **option ):
		assetType = node.getType ()
		item.setText ( 0, node.getName () )
		iconName = app.getAssetLibrary ().getAssetIcon ( assetType )
		item.setIcon ( 0, getIcon ( iconName,'normal' ) )

	def onClipboardCopy ( self ):
		clip = QtWidgets.QApplication.clipboard ()
		out = None
		for node in self.getSelection ():
			if out:
				out += "\n"
			else:
				out = ""
			out += node.getNodePath ()
		clip.setText ( out )
		return True

	def getHeaderInfo ( self ):
		return [  ( 'Name',120 ) ]

	def _updateItem ( self, node, updateLog=None, **option ):
		super ( AssetFolderTreeView, self )._updateItem ( node, updateLog, **option )

		if option.get ( 'updateDependency',False ):
			for dep in node.dependency:
				self._updateItem ( dep, updateLog, **option )

	def onClicked ( self, item, col ):
		pass

	def onItemActivated ( self, item, col ):
		node = item.node
		self.owner.onActivateNode ( node, 'tree' )

	def onItemSelectionChanged ( self ):
		self.owner.onTreeSelectionChanged ()
		# if self.refreshingSelection: return
		# items = self.selectedItems ()
		# if items:
		# 	selections = [item.node for item in items]
		# 	getAssetSelectionManager ().changeSelection ( selections )
		# else:
		# 	getAssetSelectionManager ().changeSelection ( None )

	def onDeletePressed ( self ):
		self.owner.onTreeRequestDelete ()
		

##----------------------------------------------------------------##

class AssetListItemDelegate ( QtWidgets.QStyledItemDelegate ):
	pass
	# def initStyleOption ( self, option, index ):
	# 	# let the base class initStyleOption fill option with the default values
	# 	super ( AssetListItemDelegate, self ).initStyleOption ( option, index )
	# 	# override what you need to change in option
	# 	if option.state & QStyle.State_Selected:
	# 		# option.state &= ~ QStyle.State_Selected
	# 		option.backgroundBrush = QBrush ( QColor ( 100, 200, 100, 200 ) )
		
##----------------------------------------------------------------##
class AssetBrowserIconListWidget ( GenericListWidget ):

	def __init__ ( self, *args, **option ):
		option[ 'mode' ] = 'icon'
		option[ 'drag_mode' ] = 'all'
		option[ 'multiple_selection' ] = True
		super ( AssetBrowserIconListWidget, self ).__init__ ( *args, **option )
		self.setObjectName ( 'AssetBrowserList' )
		self.setWrapping ( True )
		self.setLayoutMode ( QtWidgets.QListView.Batched )
		self.setResizeMode ( QtWidgets.QListView.Adjust  )
		self.setHorizontalScrollMode ( QtWidgets.QAbstractItemView.ScrollPerPixel )
		self.setVerticalScrollMode ( QtWidgets.QAbstractItemView.ScrollPerPixel )
		self.setMovement ( QtWidgets.QListView.Snap )
		self.setTextElideMode ( Qt.ElideRight )
		
		self.thumbnailIconSize =  ( 80, 80 )
		# self.setIconSize ( QtCore.QSize ( 32, 32 ) )
		self.setItemDelegate ( AssetListItemDelegate ( self ) )
		
		self.setIconSize ( QtCore.QSize ( 120, 130 ) )
		self.setGridSize ( QtCore.QSize ( 120, 130 ) )
		self.setWordWrap ( True )


	def getItemFlags ( self, node ):
		return {}

	def getDefaultOptions ( self ):
		return None

	def getNodes ( self ):
		return self.owner.getAssetsInList ()

	def updateItemContent ( self, item, node, **option ):
		rawName = node.getName ()
		dotIdx = rawName.find ( '.' )
		if dotIdx > 0:
			name = rawName[ 0:dotIdx ]
			ext  = rawName[ dotIdx: ]
			item.setText ( name + '\n' + ext )
		else:
			item.setText ( rawName )
		thumbnailIcon = self.owner.getAssetThumbnailIcon ( node, self.thumbnailIconSize )
		if not thumbnailIcon:
			thumbnailIcon = getIcon ( 'thumbnail/%s' % node.getType (), 'thumbnail/default' )

		item.setIcon ( thumbnailIcon )
		item.setSizeHint ( QtCore.QSize ( 120, 130 ) )
		# item.setTextAlignment ( Qt.AlignLeft | Qt.AlignVCenter )
		item.setTextAlignment ( Qt.AlignCenter | Qt.AlignVCenter )
		item.setToolTip ( node.getPath () )

	def onItemSelectionChanged ( self ):
		self.owner.onListSelectionChanged ()

	def onItemActivated ( self, item ):
		node = item.node
		self.owner.onActivateNode ( node, 'list' )

	def mimeData ( self, items ):
		data = QtCore.QMimeData ()
		output = []
		for item in items:
			asset = item.node
			output.append ( asset.getPath () )
		assetListData = json.dumps ( output ).encode ( 'utf-8' )
		data.setData ( CANDY_MIME_ASSET_LIST, assetListData )
		return data

	def onDeletePressed ( self ):
		self.owner.onListRequestDelete ()

	def onClipboardCopy ( self ):
		clip = QtWidgets.QApplication.clipboard ()
		out = None
		for node in self.getSelection ():
			if out:
				out += "\n"
			else:
				out = ""
			out += node.getNodePath ()
		clip.setText ( out )
		return True


##----------------------------------------------------------------##
class AssetBrowserDetailListWidget ( GenericTreeWidget ):

	def __init__ ( self, *args, **option ):
		option[ 'drag_mode' ] = 'all'
		super ( AssetBrowserDetailListWidget, self ).__init__ ( *args, **option )

	def getHeaderInfo ( self ):
		return [  ( 'Name',150 ),  ( 'Type', 80 ),  ( 'Desc', 50 ) ]

	def getRootNode ( self ):
		return self.owner

	def getNodeParent ( self, node ): # reimplemnt for target node	
		if node == self.owner: return None
		return self.owner

	def getNodeChildren ( self, node ):
		if node == self.owner:
			return self.owner.getAssetsInList ()
		else:
			return []

	def createItem ( self, node ):
		return AssetTreeItem ()
		
	def updateItemContent ( self, item, node, **option ):
		if node == self.owner: return 
		assetType = node.getType ()
		item.setText ( 0, node.getName () )
		iconName = app.getAssetLibrary ().getAssetIcon ( assetType )
		item.setIcon ( 0, getIcon ( iconName,'normal' ) )
		item.setText ( 1, assetType )

	def mimeData ( self, items ):
		data = QtCore.QMimeData ()
		output = []
		for item in items:
			asset = item.node
			output.append ( asset.getPath () )
		assetListData = json.dumps ( output ).encode ( 'utf-8' )
		data.setData ( CANDY_MIME_ASSET_LIST, assetListData )
		return data

	def onItemSelectionChanged ( self ):
		self.owner.onListSelectionChanged ()

	def onItemActivated ( self, item, index ):
		node = item.node
		self.owner.onActivateNode ( node, 'list' )

##----------------------------------------------------------------##
class AssetBrowserTagFilterWidget ( AssetFilterWidget ):

	def __init__ ( self, *args, **kwargs ):
		super ( AssetBrowserTagFilterWidget, self ).__init__ ( *args, **kwargs )
		self.filterChanged.connect ( self.onFilterChanged )
	
	def onFilterChanged ( self ):
		self.owner.updateTagFilter ()

	# def onActionAdd ( self ):
	# 	pass

	# def onActionLock ( self ):
	# 	pass
		
	# def onActionEdit ( self ):
	# 	pass
		
	# def onActionDelete ( self ):
	# 	pass
		

##----------------------------------------------------------------##
class AssetBrowserStatusBar ( QtWidgets.QFrame ):

	def __init__ ( self, *args, **kwargs ):
		super ( AssetBrowserStatusBar, self ).__init__ ( *args, **kwargs )
		self.setObjectName ( 'AssetBrowserStatusBar' )
		layout = QtWidgets.QVBoxLayout ( self )
		layout.setSpacing ( 1 )
		layout.setContentsMargins ( 0,0,0,0 )

		self.textStatus = ElidedLabel ( self )
		self.tagsBar = AssetBrowserStatusBarTag ( self )
		layout.addWidget ( self.tagsBar )
		layout.addWidget ( self.textStatus )
		self.tagsBar.buttonEdit.clicked.connect ( self.onButtonEditTags )

	def onButtonEditTags ( self ):
		self.owner.editAssetTags ()

	def setText ( self, text ):
		self.textStatus.setText ( text )

	def setTags ( self, text ):
		self.tagsBar.setText ( text )

##----------------------------------------------------------------##
class AssetBrowserStatusBarTag ( QtWidgets.QFrame ):

	def __init__ ( self, *args, **kwargs ):
		super ( AssetBrowserStatusBarTag, self ).__init__ ( *args, **kwargs )
		self.setObjectName ( 'AssetBrowserStatusTagBar' )
		layout = QtWidgets.QHBoxLayout ( self )
		layout.setSpacing ( 2 )
		layout.setContentsMargins ( 0,0,0,0 )
		self.textTags = QtWidgets.QLabel ( self )
		self.textTags.setSizePolicy ( QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Fixed )
		self.buttonEdit = QtWidgets.QToolButton ( self )
		self.buttonEdit.setIconSize ( QSize ( 12,12 ) )
		self.buttonEdit.setIcon ( getIcon ( 'tag-2' ) )
		layout.addWidget ( self.buttonEdit )
		layout.addWidget ( self.textTags )

	def setText ( self, text ):
		self.textTags.setText ( text )

##----------------------------------------------------------------##
class AssetBrowserNavigatorCrumbBar ( QtWidgets.QWidget ):
	pass

##----------------------------------------------------------------##
class AssetBrowserNavigator ( QtWidgets.QWidget ):

	def __init__ ( self, *args, **kwargs ):
		super ( AssetBrowserNavigator, self ).__init__ ( *args, **kwargs )
		layout = QtWidgets.QHBoxLayout ( self )
		layout.setSpacing ( 1 )
		layout.setContentsMargins ( 0,0,0,0 )
		self.buttonUpper    = QtWidgets.QToolButton ()
		self.buttonForward  = QtWidgets.QToolButton ()
		self.buttonBackward = QtWidgets.QToolButton ()
		self.buttonUpper.setIconSize ( QSize ( 16, 16 )  )
		self.buttonForward.setIconSize ( QSize ( 16, 16 )  )
		self.buttonBackward.setIconSize ( QSize ( 16, 16 )  )
		self.buttonUpper.setIcon ( getIcon ( 'upper_folder' ) )
		self.buttonForward.setIcon ( getIcon ( 'history_forward' ) )
		self.buttonBackward.setIcon ( getIcon ( 'history_backward' ) )
		layout.addWidget ( self.buttonUpper )
		layout.addSpacing ( 10 )
		layout.addWidget ( self.buttonBackward )
		layout.addWidget ( self.buttonForward )
		self.buttonUpper.clicked.connect ( self.onGoUpperLevel )
		self.buttonForward.clicked.connect ( self.onHistoryForward )
		self.buttonBackward.clicked.connect ( self.onHistoryBackward )

		self.crumbBar = AssetBrowserNavigatorCrumbBar ()
		layout.addWidget ( self.crumbBar )
		self.crumbBar.setSizePolicy ( QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Expanding )
		self.setFixedHeight ( 20 )

	def onHistoryForward ( self ):
		self.owner.forwardHistory ()

	def onGoUpperLevel ( self ):
		self.owner.goUpperLevel ()

	def onHistoryBackward ( self ):
		self.owner.backwardHistory ()


##----------------------------------------------------------------##
class AssetFilterTreeFilter ( GenericTreeFilter ):
	pass

##----------------------------------------------------------------##
#TODO: allow sort by other column
class AssetFilterTreeItem ( QtWidgets.QTreeWidgetItem ):

	def __lt__ ( self, other ):
		node0 = self.node
		node1 = hasattr ( other, 'node' ) and other.node or None
		if not node1:
			return True
		tree = self.treeWidget ()

		t0 = node0.getType ()
		t1 = node1.getType ()
		if t1!=t0:			
			if tree.sortOrder () == 0:
				if t0 == 'group': return True
				if t1 == 'group': return False
			else:
				if t0 == 'group': return False
				if t1 == 'group': return True
		return super ( AssetFilterTreeItem, self ).__lt__ ( other )
		# return node0.getName ().lower ()<node1.getName ().lower ()

##----------------------------------------------------------------##
class AssetFilterTreeView ( GenericTreeWidget ):

	def __init__ ( self, *args, **option ):
		option[ 'show_root' ] = False
		option[ 'editable'  ] = True

		super ( AssetFilterTreeView, self ).__init__ ( *args, **option )
		self.setHeaderHidden ( True )

	def saveTreeStates ( self ):
		pass

	def loadTreeStates ( self ):
		pass
		
	def getRootNode ( self ):
		return self.owner.getFilterRootGroup ()

	def getNodeParent ( self, node ): # reimplemnt for target node
		return node.getParent ()

	def getNodeChildren ( self, node ):
		result = []
		for node in node.getChildren ():
			result.append ( node )
		return result

	def createItem ( self, node ):
		return AssetFilterTreeItem ()

	def updateItemContent ( self, item, node, **option ):
		t = node.getType ()
		item.setText ( 0, node.getName () )
		if t == 'group':
			item.setIcon ( 0, getIcon ( 'folder-tag' ) )
		else:
			item.setIcon ( 0, getIcon ( 'asset-filter' ) )

	def getHeaderInfo ( self ):
		return [  ( 'Name',120 ) ]

	def onClicked ( self, item, col ):
		pass

	def onItemSelectionChanged ( self ):
		for f in self.getSelection ():
			self.owner.setAssetFilter ( f )

	def onItemChanged ( self, item, col ):
		node = self.getNodeByItem ( item )
		self.owner.renameFilter ( node, item.text ( 0 ) )
		
	def onDeletePressed ( self ):
		for f in self.getSelection ():
			self.owner.onAsseotFilterRequestDelete ( f )
