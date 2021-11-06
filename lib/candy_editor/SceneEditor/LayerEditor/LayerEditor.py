##----------------------------------------------------------------##
from candy_editor.core import app
from candy_editor.core import signals

from candy_editor.qt.helpers.IconCache import getIcon
from candy_editor.qt.controls.GenericTreeWidget import GenericTreeWidget, GenericTreeFilter
from candy_editor.moai.MOAIRuntime import MOAILuaDelegate, _CANDY
from candy_editor.moai.CandyRuntime import isCandyInstance
from candy_editor.SceneEditor.SceneEditor import SceneEditorModule, getSceneSelectionManager
from candy_editor.qt.helpers import QColorF

##----------------------------------------------------------------##
from PyQt5 import QtGui


def _fixDuplicatedName ( names, name, id = None ):
	if id:
		testName = name + '_%d' % id
	else:
		id = 0
		testName = name
	#find duplicated name
	if testName in names:
		return _fixDuplicatedName ( names, name, id + 1)
	else:
		return testName

##----------------------------------------------------------------##
class LayerManager ( SceneEditorModule ):

	def __init__ ( self ):
		super ( LayerManager, self ).__init__ ()

	def getName ( self ):
		return 'layer_manager'

	def getDependency ( self ):
		return [ 'scene_editor', 'candy' ]

	def onLoad ( self ):
		#UI
		self.windowTitle = 'Layers'
		self.window = self.requestToolWindow ( 'LayerManager',
			title     = self.windowTitle,
			size      = (120,120),
			minSize   = (120,120),
			area      = 'empty'
		)

		#Components
		self.treeFilter = self.window.addWidget ( GenericTreeFilter (), expanding = False )
		self.tree = self.window.addWidget (
			LayerTreeWidget (
				self.window,
				multiple_selection = False,
				sorting            = False,
				editable           = True,
				drag_mode          = 'internal'
			)
		)
		self.tree.hasSoloLayer = False
		self.treeFilter.setTargetTree ( self.tree )

		self.tool = self.addToolBar ( 'layer_manager', self.window.addToolBar () )
		self.delegate = MOAILuaDelegate ( self )
		self.delegate.load ( self.getApp ().getPath ( 'lib/candy_editor/SceneEditor/LayerEditor/LayerEditor.lua' ) )

		self.addTool ( 'layer_manager/add',    label = 'add',  icon = 'add' )
		self.addTool ( 'layer_manager/remove', label = 'remove', icon = 'remove' )
		self.addTool ( 'layer_manager/up',     label = 'up', icon = 'arrow-up' )
		self.addTool ( 'layer_manager/down',   label = 'down', icon = 'arrow-down' )

		#SIGNALS
		signals.connect ( 'moai.clean', self.onMoaiClean )

	def onAppReady ( self ):
		self.tree.rebuild ()

	def onMoaiClean ( self ):
		self.tree.clear ()

	def onTool ( self, tool ):
		name = tool.name
		if name == 'add':
			layer = self.delegate.safeCall ( 'addLayer' )
			self.tree.addNode ( layer )
			self.tree.editNode ( layer )
			self.tree.selectNode ( layer )
			
		elif name == 'remove':
			for l in self.tree.getSelection ():
				self.delegate.safeCall ( 'removeLayer', l )
				self.tree.removeNode ( l )
		elif name == 'up':
			for l in self.tree.getSelection ():
				self.delegate.safeCall ( 'moveLayerUp', l )
				self.tree.rebuild ()
				self.tree.selectNode ( l )
				break
		elif name == 'down':
			for l in self.tree.getSelection ():
				self.delegate.safeCall ( 'moveLayerDown', l )
				self.tree.rebuild ()
				self.tree.selectNode ( l )
				break

	def changeLayerName ( self, layer, name ):
		layer.setName ( layer, name )

	def toggleHidden ( self, layer ):
		layer.setVisible ( layer, not layer.isVisible ( layer ) )
		self.tree.refreshNodeContent ( layer )
		signals.emit ( 'scene.update' )

	def toggleEditVisible ( self, layer ):
		layer.setEditorVisible ( layer, not layer.isEditorVisible ( layer ) )
		self.tree.refreshNodeContent ( layer )
		signals.emit ( 'scene.update' )

	def toggleLock ( self, layer ):
		layer.locked = not layer.locked
		self.tree.refreshNodeContent ( layer )
		signals.emit ( 'scene.update' )

	def toggleSolo ( self, layer ):
		solo = layer.isEditorSolo ( layer )
		if solo:
			self.tree.hasSoloLayer = False
			for l in _CANDY.game.layers.values ():
				if l.name == 'CANDY_EDITOR_LAYER' : continue
				if l != layer:
					l.editorSolo = False
			layer.setEditorSolo ( layer, False )
		else:
			self.tree.hasSoloLayer = True
			for l in _CANDY.game.layers.values ():
				if l.name == 'CANDY_EDITOR_LAYER' : continue
				if l != layer:
					l.editorSolo = 'hidden'
			layer.setEditorSolo ( layer, True )
		self.tree.refreshAllContent ()
		signals.emit ( 'scene.update' )
	

##----------------------------------------------------------------##
_BrushLayerHidden = QtGui.QBrush ( QColorF ( 0.6,0.6,0.6 ) )
_BrushLayerNormal = QtGui.QBrush ()
_BrushLayerSolo   = QtGui.QBrush ( QColorF ( 1,1,0 ) )

##----------------------------------------------------------------##
class LayerTreeWidget ( GenericTreeWidget ):
	def getHeaderInfo ( self ):
		return [ ('Name',150), ('View', 30), ('Edit',30), ('Solo',30), ('',-1) ]

	def getRootNode ( self ):
		return _CANDY.game

	def saveTreeStates ( self ):
		pass

	def loadTreeStates ( self ):
		pass

	def getNodeParent ( self, node ): # reimplemnt for target node	
		if isCandyInstance ( node, 'Game' ):
			return None
		return _CANDY.game

	def getNodeChildren ( self, node ):
		if isCandyInstance ( node, 'Game' ):
			result = []
			for item in node.layers.values ():
				if item.name == 'CANDY_EDITOR_LAYER': continue
				result.append ( item )
			return reversed ( result )
		return []

	def updateItemContent ( self, item, node, **option ):
		pal = self.palette ()
		defaultBrush = QColorF ( .8,.8,.8 )
		name = None
		if isCandyInstance ( node, 'Layer' ):
			style = defaultBrush
			item.setText ( 0, node.name )
			if node.default :
				item.setIcon ( 0, getIcon ('layer_default') )
			else:
				item.setIcon ( 0, getIcon ('layer') )

			if node.editorVisible:
				item.setIcon ( 1, getIcon ('ok') )
			else:
				item.setIcon ( 1, getIcon ('no'))
				style = _BrushLayerHidden

			if not node.locked:
				item.setIcon ( 2, getIcon ('ok') )
			else:
				item.setIcon ( 2, getIcon ('no'))
				
			if node.editorSolo == 'solo':
				item.setIcon ( 3, getIcon ('ok') )
				style = _BrushLayerSolo
			else:
				item.setIcon ( 3, getIcon (None) )
				if self.hasSoloLayer: style = _BrushLayerHidden

			item.setForeground ( 0, style )
		else:
			item.setText ( 0, '' )
			item.setIcon ( 0, getIcon ('normal') )
		
	def onItemSelectionChanged ( self ):
		selections = self.getSelection ()
		getSceneSelectionManager ().changeSelection ( selections )

	def onItemChanged ( self, item, col ):
		layer = self.getNodeByItem ( item )
		app.getModule ('layer_manager').changeLayerName ( layer, item.text (0) )

	def onClicked (self, item, col):
		if col == 1: #editor view toggle
			app.getModule ('layer_manager').toggleEditVisible ( self.getNodeByItem (item) )
		elif col == 2: #lock toggle
			app.getModule ('layer_manager').toggleLock ( self.getNodeByItem (item) )
		elif col == 3:
			app.getModule ('layer_manager').toggleSolo ( self.getNodeByItem (item) )

##----------------------------------------------------------------##
LayerManager ().register ()
