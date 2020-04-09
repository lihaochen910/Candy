import random
##----------------------------------------------------------------##
from core        import app, signals ,printTraceBack
from core.model  import *

from qt          import QtEditorModule

from qt.helpers.IconCache                  import getIcon
from qt.dialogs                    import alertMessage, requestConfirm, requestString
from qt.controls.GenericTreeWidget import GenericTreeWidget, GenericTreeFilter
from qt.helpers                    import makeBrush, makeFont

from moai.MOAIRuntime import MOAILuaDelegate, _CANDY
from .SceneEditor      import SceneEditorModule

from qt.controls.SearchView       import requestSearchView, registerSearchEnumerator

##----------------------------------------------------------------##
from PyQt5           import QtCore, QtGui, uic, QtWidgets
from PyQt5.QtCore    import Qt, QObject
from PyQt5.QtWidgets import QApplication, QStyle
from PyQt5.QtGui     import QBrush, QColor, QPen, QIcon, QPalette

##----------------------------------------------------------------##
from moai.CandyRuntime import _CANDY, isCandyInstance
##----------------------------------------------------------------##

CANDY_MIME_ACTOR_DATA = 'application/candy.actor-data'


_brushAnimatable = makeBrush( color = '#5f3d26' )
_fontAnimatable  = makeFont( bold = True, italic = True )
##----------------------------------------------------------------##
class SceneOutlinerEditor( SceneEditorModule ):
	def __init__(self):
		super( SceneOutlinerEditor, self ).__init__()
		self.sceneDirty = False
		self.activeSceneNode  = None
		self.refreshScheduled = False
		self.previewing       = False
		self.workspaceState   = None
		
	def getName( self ):
		return 'sceneoutliner_editor'

	def getDependency( self ):
		# return [ 'scene_editor', 'mock' ]
		return [ 'scene_editor', 'moai', 'candy' ]

	def onLoad( self ):
		#UI
		self.windowTitle = 'Scene Outliner'
		self.container = self.requestDockWindow( 'SceneOutlinerEditor',
			title     = 'Scene Outliner',
			size      = (200,200),
			minSize   = (200,200),
			dock      = 'left'
			)

		#Components
		self.treeFilter = self.container.addWidget(
			GenericTreeFilter(
				self.container
			),
			expanding = False
		)
		self.tree = self.container.addWidget( 
				SceneGraphTreeWidget( 
					self.container,
					sorting  = True,
					editable = True,
					multiple_selection = True,
					drag_mode = 'internal'
				)
			)
		self.treeFilter.setTargetTree( self.tree )
		self.tree.module = self
		self.tool = self.addToolBar( 'scene_outliner', self.container.addToolBar() )
		self.delegate = MOAILuaDelegate( self )
		# self.delegate.load( getModulePath( 'SceneGraphEditor.lua' ) )
		self.delegate.load( self.getApp().getPath( 'lua/candy_editor/SceneOutlinerEditor.lua' ) )

		self.actorCreatorMenu=self.addMenu(
			'main/scene/actor_create',
			{ 'label':'Create Actor' }
			)

		self.componentCreatorMenu=self.addMenu(
			'main/scene/component_create',
			{ 'label':'Create Component' }
			)


		#menu
		# self.addMenuItem( 'main/file/open_scene',
		# 	dict( label = 'Open Scene', shortcut = 'ctrl+shift+o' )
		# 	)
		#
		# self.addMenuItem( 'main/file/close_scene',
		# 	dict( label = 'Close Scene', shortcut = 'Ctrl+W' )
		# 	)
		self.addMenuItem( 'main/scene/save_scene',
			dict( label = 'Save', shortcut = 'Ctrl+S' )
			)
		self.addMenuItem( 'main/scene/locate_scene_asset',
			dict( label = 'Locate Scene Asset' )
			)

		self.addMenu( 'main/scene/----' )
		
		self.addMenu( 'component_context', dict( label = 'Selected Component' ) )
		self.addMenuItem( 'component_context/remove_component', 
			dict( label = 'Remove' )
			)

		self.addMenuItem( 'component_context/----' )
		
		self.addMenuItem( 'component_context/copy_component', 
			dict( label = 'Copy' )
			)
		self.addMenuItem( 'component_context/paste_component', 
			dict( label = 'Paste Component Here' )
			)
		self.addMenuItem( 'component_context/----' )
		
		self.addMenuItem( 'component_context/move_component_up', 
			dict( label = 'Move Up' )
			)

		self.addMenuItem( 'component_context/move_component_down', 
			dict( label = 'Move Down' )
			)

		self.addMenuItem( 'component_context/----' )
		self.addMenuItem( 'component_context/edit_component_alias', 
			dict( label = 'Edit Alias' )
			)

		self.addMenu( 'main/actor', dict( label = 'Actor' ) )
		self.addMenuItem( 'main/actor/add_empty_actor',    dict( label = 'Create Empty', shortcut = 'ctrl+alt+N' ) )
		self.addMenuItem( 'main/actor/add_actor',          dict( label = 'Create',       shortcut = 'ctrl+shift+N' ) )
		self.addMenuItem( 'main/actor/----' )
		self.addMenuItem( 'main/actor/group_entity',        dict( label = 'Group Entites',    shortcut = 'ctrl+G' ) )
		self.addMenuItem( 'main/actor/create_group',        dict( label = 'Create Empty Group',    shortcut = 'ctrl+shift+G' ) )
		self.addMenuItem( 'main/actor/----' )
		self.addMenuItem( 'main/actor/load_prefab',         dict( label = 'Load Prefab', shortcut = 'ctrl+alt+shift+N' ) )
		self.addMenuItem( 'main/actor/load_prefab_in_container', dict( label = 'Load Prefab In Container', shortcut = 'ctrl+shift+=' ) )
		self.addMenuItem( 'main/actor/----' )
		self.addMenuItem( 'main/actor/remove_actor',       dict( label = 'Remove'  ) )
		self.addMenuItem( 'main/actor/clone_actor',        dict( label = 'Clone',  shortcut = 'ctrl+d' ) )
		self.addMenuItem( 'main/actor/----' )
		self.addMenuItem( 'main/actor/add_component',       dict( label = 'Add Component', shortcut = 'ctrl+alt+=' ) )
		self.addMenuItem( 'main/actor/assign_layer',        dict( label = 'Assign Layer', shortcut = 'ctrl+alt+L' ) )
		self.addMenuItem( 'main/actor/toggle_visibility',   dict( label = 'Toggle Visibility', shortcut = 'ctrl+/' ) )
		self.addMenuItem( 'main/actor/freeze_entity_pivot', dict( label = 'Freeze Pivot' ) )

		self.addMenuItem( 'main/actor/----' )
		self.addMenuItem( 'main/find/find_actor', dict( label = 'Find In Scene', shortcut = 'ctrl+f' ) )
		self.addMenuItem( 'main/find/find_actor_in_group', dict( label = 'Find In Group', shortcut = 'ctrl+shift+f' ) )
		self.addMenuItem( 'main/find/find_actor_group', dict( label = 'Find Group', shortcut = 'ctrl+alt+f' ) )

		#Toolbars
		self.addTool( 'scene_outliner/select_scene',    label ='Select Scene', icon = 'settings' )
		self.addTool( 'scene_outliner/----'  )
		self.addTool( 'scene_outliner/create_group',    label ='+ Group', icon = 'add_folder' )
		# self.addTool( 'scene_outliner/----'  )
		# self.addTool( 'scene_outliner/make_proto',    label = 'Convert To Proto', icon = 'proto_make' )
		# self.addTool( 'scene_outliner/create_proto_instance',    label = 'Create Proto Instance', icon = 'proto_instantiate' )
		# self.addTool( 'scene_outliner/create_proto_container',    label = 'Create Proto Container', icon = 'proto_container' )
		self.addTool( 'scene_outliner/----'  )
		self.addTool( 'scene_outliner/fold_all',    label = 'F' )
		self.addTool( 'scene_outliner/unfold_all',  label = 'U' )
		self.addTool( 'scene_outliner/refresh_tree',  label = 'R' )
		# self.addTool( 'scene_outliner/load_prefab', label = '+ P' )
		# self.addTool( 'scene_outliner/save_prefab', label = '>>P' )

		self.addTool( 'scene/refresh', label = 'refresh', icon='refresh' )

		#SIGNALS
		signals.connect( 'moai.clean',        self.onMoaiClean        )

		signals.connect( 'scene.clear',       self.onSceneClear       )
		signals.connect( 'scene.change',      self.onSceneChange      )

		signals.connect( 'selection.changed', self.onSelectionChanged )
		signals.connect( 'selection.hint',    self.onSelectionHint    )

		signals.connect( 'preview.start',     self.onPreviewStart     )
		signals.connect( 'preview.stop' ,     self.onPreviewStop      )

		# signals.connect( 'animator.start',     self.onAnimatorStart     )
		# signals.connect( 'animator.stop' ,     self.onAnimatorStop      )

		signals.connect( 'actor.added', self.onActorAdded)
		signals.connect( 'actor.removed', self.onActorRemoved)
		signals.connect( 'actor.renamed', self.onActorRenamed)
		signals.connect( 'actor.modified', self.onActorModified)
		signals.connect( 'actor.visible_changed', self.onActorVisibleChanged)
		signals.connect( 'actor.pickable_changed', self.onActorPickableChanged)


		# signals.connect( 'prefab.unlink',     self.onPrefabUnlink    )
		# signals.connect( 'prefab.relink',     self.onPrefabRelink    )
		# signals.connect( 'proto.unlink',      self.onPrefabUnlink    )
		# signals.connect( 'proto.relink',      self.onPrefabRelink    )

		signals.connect( 'app.ready', self.postAppReady )


		signals.connect( 'component.added',   self.onComponentAdded   )
		signals.connect( 'component.removed', self.onComponentRemoved )

		signals.connect( 'project.presave',   self.preProjectSave )

		registerSearchEnumerator( sceneObjectSearchEnumerator )
		registerSearchEnumerator( entityNameSearchEnumerator )
		registerSearchEnumerator( componentNameSearchEnumerator )
		registerSearchEnumerator( layerNameSearchEnumerator )

	def onStart( self ):
		self.refreshCreatorMenu()

	def postAppReady( self ):
		self.openPreviousScene()

	def openPreviousScene( self ):
		previousScene = self.getConfig( 'previous_scene', None )
		if previousScene:
			node = self.getAssetLibrary().getAssetNode( previousScene )
			if node:
				node.edit()

	def onStop( self ):
		if self.activeSceneNode:
			self.setConfig( 'previous_scene', self.activeSceneNode.getNodePath() )
		else:
			self.setConfig( 'previous_scene', False )

	def onSetFocus( self ):
		self.container.show()
		self.container.raise_()
		self.container.setFocus()

	def getActiveScene( self ):
		return self.delegate.safeCallMethod( 'editor', 'getScene' )

	def getActiveSceneRootGroup( self ):
		scene = self.delegate.safeCallMethod( 'editor', 'getScene' )
		if scene:
			return scene.rootGroup
		else:
			return None


	def openScene( self, node, protoNode = None ):
		if self.activeSceneNode == node:			
			if self.getModule('scene_view'):
				self.getModule('scene_view').setFocus()

			if protoNode:
				self.delegate.safeCallMethod( 'editor', 'locateProto', protoNode.getPath() )
				if self.getModule('scene_view'):
					self.getModule('scene_view').focusSelection()
				
		else:
			if not self.closeScene(): return
			if self.getModule('scene_view'):
				self.getModule('scene_view').makeCanvasCurrent()
			self.activeSceneNode = node
			signals.emitNow( 'scene.pre_open', node )
			scene = self.delegate.safeCallMethod( 'editor', 'openScene', node.getPath() )
			if not scene:
				#todo: raise something
				alertMessage( 'error', 
					'%s\n\nfailed to open scene, see console for detailed information.' % node.getPath() )
				return False
			signals.emitNow( 'scene.open', self.activeSceneNode, scene )
			self.setFocus()
			self.editingProtoNode = protoNode		
			self.loadWorkspaceState( False )
			self.delegate.safeCallMethod( 'editor', 'postOpenScene' )

	def closeScene( self ):
		if not self.activeSceneNode: return True
		if self.sceneDirty:
			res = requestConfirm( 'scene modified!', 'save scene before close?' )
			if res == True:   #save
				self.saveScene()
			elif res == None: #cancel
				return
			elif res == False: #no save
				pass

		self.markSceneDirty( False )
		self.tree.clear()
		self.getApp().clearCommandStack( 'scene_editor' )
		self.getSelectionManager().removeSelection( self.getActiveScene() )
		signals.emitNow( 'scene.close', self.activeSceneNode )
		self.delegate.safeCallMethod( 'editor', 'closeScene' )		
		self.activeSceneNode = None
		return True

	def onSceneClear( self ):
		# self.tree.clear()
		pass

	def markSceneDirty( self, dirty = True ):
		if not self.previewing:
			self.sceneDirty = dirty


	def saveWorkspaceState( self ):
		self.retainWorkspaceState()
		treeFoldState      = self.workspaceState['tree_state']
		containerFoldState = self.workspaceState['container_state']
		entityLockState    = self.workspaceState['entity_lock_state']
		self.activeSceneNode.setMetaData( 'tree_state', treeFoldState )
		self.activeSceneNode.setMetaData( 'container_state', containerFoldState )
		self.activeSceneNode.setMetaData( 'entity_lock_state', entityLockState )

	def loadWorkspaceState( self, restoreState = True ):
		treeFoldState      = self.activeSceneNode.getMetaData( 'tree_state', None )		
		containerFoldState = self.activeSceneNode.getMetaData( 'container_state', None )		
		entityLockState    = self.activeSceneNode.getMetaData( 'entity_lock_state', None )	
		self.workspaceState = {
			'tree_state'        : treeFoldState,
			'container_state'   : containerFoldState,
			'entity_lock_state' : entityLockState
		}		
		if restoreState: self.restoreWorkspaceState()

	def retainWorkspaceState( self ):
		#tree node foldstate
		treeFoldState =  self.tree.saveFoldState()
		#save introspector foldstate
		introspectorFoldState = self.delegate.safeCallMethod( 'editor', 'saveIntrospectorFoldState' )
		entityLockState = self.delegate.safeCallMethod( 'editor', 'saveEntityLockState' )

		self.workspaceState = {
			'tree_state'        : treeFoldState,
			'container_state'   : introspectorFoldState,
			'entity_lock_state' : entityLockState
		}

	def restoreWorkspaceState( self ):
		if not self.workspaceState: return
		treeState = self.workspaceState.get( 'tree_state', None )
		if treeState:
			self.tree.loadFoldState( treeState )	
		
		containerState = self.workspaceState.get( 'container_state', None )
		if containerState:
			self.delegate.safeCallMethod( 'editor', 'loadIntrospectorFoldState', containerState )
		
		lockState = self.workspaceState.get( 'entity_lock_state', None )
		if lockState:
			self.delegate.safeCallMethod( 'editor', 'loadEntityLockState', lockState )


	def onSceneChange( self ):
		self.tree.hide()
		self.tree.rebuild()
		self.restoreWorkspaceState()
		self.tree.refreshAllContent()
		self.tree.verticalScrollBar().setValue( 0 )
		self.tree.show()
		# if self.editingProtoNode:
		# 	self.delegate.safeCallMethod( 'editor', 'locateProto', self.editingProtoNode.getPath() )
		# 	self.editingProtoNode = None
		# 	if self.getModule('scene_view'):
		# 			self.getModule('scene_view').focusSelection()
		
	def saveScene( self ):
		if not self.activeSceneNode: return
		self.markSceneDirty( False )
		signals.emitNow( 'scene.save' )
		self.delegate.safeCallMethod( 'editor', 'saveScene', self.activeSceneNode.getAbsFilePath() )
		signals.emitNow( 'scene.saved' )
		self.saveWorkspaceState()

	def refreshScene( self ):
		if not self.activeSceneNode: return
		if self.previewing: return
		self.refreshScheduled = False
		node = self.activeSceneNode
		self.retainWorkspaceState()
		if self.delegate.safeCallMethod( 'editor', 'refreshScene' ):
			self.restoreWorkspaceState()
		self.refreshCreatorMenu()

	def scheduleRefreshScene( self ):
		if not self.activeSceneNode: return
		self.refreshScheduled = True

	def refreshCreatorMenu( self ):
		def addActorMenuItem( name ):
			if name == '----': 
				self.actorCreatorMenu.addChild('----')
				return
			self.actorCreatorMenu.addChild({
					'name'     : 'create_actor_'+name,
					'label'    : name,
					'command'  : 'scene_editor/create_actor',
					'command_args' : dict( name = name )
				})

		def addComponentMenuItem( name ):
			if name == '----': 
				self.componentCreatorMenu.addChild( '----' )
				return
			self.componentCreatorMenu.addChild({
					'name'     : 'create_component_'+name,
					'label'    : name,
					'command'  : 'scene_editor/create_component',
					'command_args' : dict( name = name )
				})

		self.actorCreatorMenu.clear()
		self.componentCreatorMenu.clear()

		registry = _CANDY.getActorRegistry()
		#actor
		keys = sorted( registry.keys() )
		addActorMenuItem( 'Actor' )
		addActorMenuItem( '----' )
		for actorName in sorted( registry.keys() ):
			if actorName!='Actor': addActorMenuItem( actorName )

		#component
		registry = _CANDY.getComponentRegistry()
		for comName in sorted( registry.keys() ):
			addComponentMenuItem( comName )

	def needUpdate( self ):
		return True
		
	def onUpdate( self ):
		if self.refreshScheduled:
			self.refreshScene()

	def preProjectSave( self, prj ):
		if self.activeSceneNode:
			_CANDY.game.previewingScene = self.activeSceneNode.getNodePath()

	def onMoaiClean( self ):
		self.tree.clear()

	def onTool( self, tool ):
		name = tool.name
		
		if name == 'fold_all':
			self.tree.foldAllItems()

		elif name == 'unfold_all':
			self.tree.expandAllItems()

		elif name == 'refresh_tree':
			self.tree.rebuild()

		elif name == 'refresh':
			self.scheduleRefreshScene()

		elif name == 'make_proto':
			self.makeProto()

		elif name == 'create_proto_instance':
			requestSearchView( 
				info    = 'select a proto to instantiate',
				context = 'asset',
				type    = 'proto',
				on_selection = 
					lambda obj: 
						self.doCommand( 'scene_editor/create_proto_instance', proto = obj.getNodePath() )
				)

		elif name == 'create_proto_container':
			requestSearchView( 
				info    = 'select a proto to create contained instance',
				context = 'asset',
				type    = 'proto',
				on_selection = 
					lambda obj: 
						self.doCommand( 'scene_editor/create_proto_container', proto = obj.getNodePath() )
				)

		elif name == 'create_group':
			self.doCommand( 'scene_editor/actor_group_create' )

		elif name == 'group_entity':
			self.doCommand( 'scene_editor/group_entities' )
		
		elif name == 'select_scene':
			self.doCommand( 'scene_editor/select_scene' )
			

	def onMenu( self, menu ):
		name = menu.name
		if name == 'close_scene':
			if self.previewing:
				alertMessage( 'Warning', 'Stop previewing before closing scene' )
				return
			self.closeScene()

		elif name == 'open_scene':
			if self.previewing:
				alertMessage( 'Warning', 'Stop previewing before opening scene' )
				return
			requestSearchView( 
				info    = 'select scene to open',
				context = 'asset',
				type    = 'scene',
				on_selection = self.openScene
				)
			
		elif name == 'save_scene':
			if self.previewing:
				alertMessage( 'Warning', 'Stop previewing before saving' )
				return
			self.saveScene()

		elif name == 'locate_scene_asset':
			if self.activeSceneNode:
				assetBrowser = self.getModule( 'asset_browser' )
				if assetBrowser:
					assetBrowser.selectAsset( self.activeSceneNode )

		elif name == 'add_actor':
			requestSearchView( 
				info    = 'select actor type to create',
				context = 'actor_creation',
				on_selection = lambda obj: 
					self.doCommand( 'scene_editor/create_actor', name = obj )
				)

		elif name == 'add_component':
			requestSearchView( 
				info    = 'select component type to create',
				context = 'component_creation',
				on_selection = lambda obj: 
					self.doCommand( 'scene_editor/create_component', name = obj )
				)

		elif name == 'add_empty_actor':
			self.doCommand( 'scene_editor/create_actor', name = 'Actor' )

		elif name == 'load_prefab':
			requestSearchView( 
				info    = 'select a perfab node to instantiate',
				context = 'asset',
				type    = 'prefab',
				on_selection = 
					lambda obj: 
						self.doCommand( 'scene_editor/create_prefab_entity', prefab = obj.getNodePath() )
				)

		elif name == 'load_prefab_in_container':
			requestSearchView( 
				info    = 'select a perfab node to instantiate( PefabContainer )',
				context = 'asset',
				type    = 'prefab',
				on_selection = 
					lambda obj: 
						self.doCommand( 'scene_editor/create_prefab_container', prefab = obj.getNodePath() )
				)

		elif name == 'remove_actor':
			self.doCommand( 'scene_editor/remove_actor' )

		elif name == 'clone_actor':
			self.doCommand( 'scene_editor/clone_actor' )

		elif name == 'find_actor':
			requestSearchView( 
				info    = 'search for actor in current scene',
				context = 'scene',
				type    = 'actor',
				on_selection = lambda x: self.selectActor(x, focus_tree = True) ,
				on_test      = self.selectActor
				)

		elif name == 'find_actor_in_group':
			requestSearchView( 
				info    = 'search for actor in current entity group',
				context = 'scene',
				type    = 'actor_in_group',
				on_selection = lambda x: self.selectActor(x, focus_tree = True) ,
				on_test      = self.selectActor
				)

		elif name == 'find_actor_group':
			requestSearchView( 
				info    = 'search for group in current scene',
				context = 'scene',
				type    = 'group',
				on_selection = lambda x: self.selectActor(x, focus_tree = True) ,
				on_test      = self.selectActor
				)

		elif name == 'create_group':
			self.doCommand( 'scene_editor/actor_group_create' )

		elif name == 'remove_component':
			context = menu.getContext()
			if context:
				self.doCommand( 'scene_editor/remove_component', target = context )

		elif name == 'copy_component':
			context = menu.getContext()
			if context:
				self.doCommand( 'scene_editor/copy_component', target = context )

		elif name == 'edit_component_alias':
			context = menu.getContext()
			if context:
				oldAlias = context._alias or ''
				alias = requestString( 'Edit Alias', 'Enter Alias:', oldAlias )
				if alias != None:
					if not alias: alias = False
					self.doCommand( 'scene_editor/rename_component', target = context, alias = alias )

		elif name == 'assign_layer':
			if not self.tree.getSelection(): return
			requestSearchView( 
				info    = 'select layer to assign',
				context = 'scene_layer',
				type    = _CANDY.Actor,
				on_selection = self.assignActorLayer
				)

		elif name == 'toggle_visibility':
			self.doCommand( 'scene_editor/toggle_actor_visibility' )

		elif name == 'freeze_entity_pivot':
			self.doCommand( 'scene_editor/freeze_actor_pivot' )


	def onSelectionChanged( self, selection, key ):
		if key != 'scene': return
		if self.tree.syncSelection:
			self.tree.blockSignals( True )
			self.tree.selectNode( None )
			for e in selection:
				self.tree.selectNode( e, add = True)
			self.tree.blockSignals( False )

	def selectActor(self, target, **option):
		if option.get( 'focus_tree', False ):
			self.tree.setFocus()
		self.changeSelection( target )

	##----------------------------------------------------------------##
	def renameActor(self, target, name):
		#TODO:command pattern
		target.setName( target, name )
		signals.emit( 'actor.modified', target )

	def addActorNode(self, actor):
		self.tree.addNode( actor, expanded = False )
		self.tree.setNodeExpanded( actor, False )

	def removeActorNode(self, actor):
		self.tree.removeNode( actor )

	def assignActorLayer(self, layerName):
		#TODO:command pattern
		if not layerName: return
		self.doCommand( 'scene_editor/assign_layer', target = layerName )

	def onSelectionHint( self, selection ):
		if selection._actor:
			self.changeSelection( selection._actor )
		else:
			self.changeSelection( selection )

	def onPreviewStart( self ):
		if not self.activeSceneNode: return
		self.retainWorkspaceState()
		self.delegate.safeCallMethod( 'editor', 'retainScene' )
		self.delegate.safeCallMethod( 'editor', 'startScenePreview' )
		self.previewing = True

	def onPreviewStop( self ):
		if not self.activeSceneNode: return
		self.changeSelection( None )
		self.tree.clear()
		self.delegate.safeCallMethod( 'editor', 'stopScenePreview' )
		self.previewing = False
		if self.delegate.safeCallMethod( 'editor', 'restoreScene' ):
			self.restoreWorkspaceState()

	def onAnimatorStart( self ):
		self.retainWorkspaceState()
		self.delegate.safeCallMethod( 'editor', 'retainScene' )

	def onAnimatorStop( self ):
		self.tree.clear()
		self.delegate.safeCallMethod( 'editor', 'clearScene' )
		if self.delegate.safeCallMethod( 'editor', 'restoreScene' ):
			self.restoreWorkspaceState()

	##----------------------------------------------------------------##
	def updateActorPriority( self ):
		if not self.activeSceneNode: return
		self.markSceneDirty()

	def onActorRenamed(self, actor, newName):
		self.tree.refreshNodeContent( actor )
		self.markSceneDirty()

	def onActorVisibleChanged(self, actor):
		self.tree.refreshNodeContent( actor )

	def onActorPickableChanged(self, actor):
		self.tree.refreshNodeContent( actor )

	def onActorAdded(self, actor, context = None):
		if context == 'new':
			self.setFocus()
			pnode = actor.parent
			if pnode:
				self.tree.setNodeExpanded( pnode, True )
			self.tree.setFocus()
			# self.tree.editNode(actor)
			self.tree.selectNode(actor)
		signals.emit( 'scene.update' )
		self.markSceneDirty()

	def onActorRemoved(self, actor):
		signals.emit( 'scene.update' )
		self.markSceneDirty()

	def onActorModified(self, actor, context = None):
		self.markSceneDirty()

	##----------------------------------------------------------------##
	def onComponentAdded( self, com, actor ):
		signals.emit( 'scene.update' )
		self.markSceneDirty()


	def onComponentRemoved( self, com, actor ):
		signals.emit( 'scene.update' )
		self.markSceneDirty()


	##----------------------------------------------------------------##
	def onPrefabUnlink( self, actor ):
		self.tree.refreshNodeContent( actor, updateChildren = True )

	def onPrefabRelink( self, actor ):
		self.tree.refreshNodeContent( actor, updateChildren = True )

	def createPrefab( self, targetPrefab ):
		selection = self.getSelection()
		if not selection: return
		if len( selection ) > 1:
			return alertMessage( 'multiple entities cannot be converted into prefab' )
		target = selection[0]
		self.doCommand( 'scene_editor/create_prefab', 
			entity = target, 
			prefab = targetPrefab.getNodePath(),
			file   = targetPrefab.getAbsFilePath()
		)

	def makeProto( self ):
		selection = self.getSelection()
		if not selection: return
		if len( selection ) > 1:
			return alertMessage( 'multiple entities cannot be converted into Proto' )
		target = selection[0]
		if not target: return
		if requestConfirm( 'convert proto', 'Convert this Entity into Proto?' ):
			self.doCommand( 'scene_editor/make_proto', 
				entity = target
			)
			self.tree.refreshNodeContent( target )

	def createProtoInstance( self ):
		pass


	##----------------------------------------------------------------##
	def onCopyActor(self):
		entityGroupData = self.delegate.callMethod( 'editor', 'makeSceneSelectionCopyData' )
		if not entityGroupData: return False
		clip = QtWidgets.QApplication.clipboard()
		mime = QtCore.QMimeData()
		text = ''
		for s in self.getSelection():
			if text == '':
				text = text + s.name
			else:
				text = text + '\n' + s.name
		mime.setText( text )
		mime.setData( CANDY_MIME_ACTOR_DATA, entityGroupData.encode('utf-8') )
		clip.setMimeData( mime )
		return True

	def onPasteActor( self ):
		clip = QtWidgets.QApplication.clipboard()
		mime = clip.mimeData()
		if mime.hasFormat( CANDY_MIME_ACTOR_DATA ):
			data = mime.data( CANDY_MIME_ACTOR_DATA )
			self.doCommand( 'scene_editor/paste_actor',
				data = str(data).decode('utf-8')
			)

	##----------------------------------------------------------------##
	def onCopyComponent( self ):
		entityGroupData = self.delegate.callMethod( 'editor', 'makeActorCopyData' )
		if not entityGroupData: return False
		clip = QtWidgets.QApplication.clipboard()
		mime = QtCore.QMimeData()
		text = ''
		for s in self.getSelection():
			if text == '':
				text = text + s.name
			else:
				text = text + '\n' + s.name
		mime.setText( text )
		mime.setData( CANDY_MIME_ACTOR_DATA, str(entityGroupData) )
		clip.setMimeData( mime )
		return True

	def onPasteComponent( self ):
		clip = QtWidgets.QApplication.clipboard()
		mime = clip.mimeData()
		if mime.hasFormat( CANDY_MIME_ACTOR_DATA ):
			data = mime.data( CANDY_MIME_ACTOR_DATA )
			self.doCommand( 'scene_editor/paste_actor',
				data = str(data)
			)

##----------------------------------------------------------------##
def _sortEntity( a, b ):
	return b._priority - a._priority

# _BrushEntityNormal = QtGui.QBrush()
# _BrushEntityLocked = QtGui.QBrush( QColorF( 0.6,0.6,0.6 ) )
# _BrushEntityHidden = QtGui.QBrush( QColorF( 1,1,0 ) )
# _BrushEntityPrefab = QtGui.QBrush( QColorF( .5,.5,1 ) )


class SceneGraphTreeItemDelegate( QtWidgets.QStyledItemDelegate ):
	_textBrush      = QBrush( QColor( '#dd5200' ) )
	_textPen        = QPen( QColor( '#dddddd' ) )
	_textPenGroup   = QPen( QColor( '#ada993' ) )
	_backgroundBrushHovered  = QBrush( QColor( '#454768' ) )
	_backgroundBrushSelected = QBrush( QColor( '#515c84' ) )
	
	def paint(self, painter, option, index):
		painter.save()
		index0 = index.sibling( index.row(), 0 )
		utype = index0.data( Qt.UserRole )

		# # set background color
		if option.state & QStyle.State_Selected:
			painter.setPen  ( Qt.NoPen )
			painter.setBrush( SceneGraphTreeItemDelegate._backgroundBrushSelected )
			painter.drawRect(option.rect)
		elif option.state & QStyle.State_MouseOver:
			painter.setPen  ( Qt.NoPen )
			painter.setBrush( SceneGraphTreeItemDelegate._backgroundBrushHovered )
			painter.drawRect(option.rect)

		rect = option.rect
		icon = QIcon( index.data( Qt.DecorationRole) )
		rect.adjust( 5, 0, 0, 0 )
		if icon and not icon.isNull():
			icon.paint( painter, rect, Qt.AlignLeft )
			rect.adjust( 22, 0, 0, 0 )
		text = index.data(Qt.DisplayRole)
		if utype == 1: #GROUP
			painter.setPen( SceneGraphTreeItemDelegate._textPenGroup )
		else:
			painter.setPen( SceneGraphTreeItemDelegate._textPen )
		painter.drawText( rect, Qt.AlignLeft | Qt.AlignVCenter, text )
		painter.restore()


class ReadonlySceneGraphTreeItemDelegate( SceneGraphTreeItemDelegate ):
	def createEditor( *args ):
		return None

##----------------------------------------------------------------##
class SceneGraphTreeWidget( GenericTreeWidget ):
	def __init__( self, *args, **kwargs ):
		super( SceneGraphTreeWidget, self ).__init__( *args, **kwargs )
		self.syncSelection = True
		self.adjustingRange = False
		self.verticalScrollBar().rangeChanged.connect( self.onScrollRangeChanged )
		self.setIndentation( 13 )

	def getHeaderInfo( self ):
		# return [('Name',240), ('V',27 ), ('L',27 ), ( 'Layer', -1 ) ]
		return [('V',60), ('Name',240), ('L',30), ( 'Layer', -1 ) ]

	def getReadonlyItemDelegate( self ):
		return ReadonlySceneGraphTreeItemDelegate( self )

	def getDefaultItemDelegate( self ):
		return SceneGraphTreeItemDelegate( self )

	def getRootNode( self ):
		return self.module.getActiveSceneRootGroup()

	def saveFoldState( self ):
		#TODO: other state?
		result = {}
		for node, item in self.nodeDict.items():
			if not item: continue
			guid     = node['__guid']
			expanded = item.isExpanded()
			result[ guid ] = { 'expanded': expanded }
		return result

	def loadFoldState( self, data ):
		for node, item in self.nodeDict.items():
			if not item: continue
			guid  = node['__guid']
			state = data.get( guid )
			if state:
				item.setExpanded( state['expanded'] )

	def saveTreeStates( self ):
		pass

	def loadTreeStates( self ):
		pass

	def getNodeParent( self, actorNode ): # reimplemnt for target node
		parentNode = _CANDY.Actor.getParentOrGroup( actorNode )
		if parentNode and not parentNode.FLAG_EDITOR_OBJECT :
			return parentNode
		return None

	def getNodeChildren( self, node ):
		if isCandyInstance( node, 'ActorGroup' ):
			output = []
			#groups
			for group in node.childGroups:
				output.append( group )
			#actors
			for actor in node.actors:
				if ( not actor.parent ) and ( not ( actor.FLAG_EDITOR_OBJECT or actor.FLAG_INTERNAL ) ):
					output.append( actor )
			# output = sorted( output, cmp = _sortEntity )
			return output

		else: #actor
			output = []
			for actor in node.children:
				if not ( actor.FLAG_EDITOR_OBJECT or actor.FLAG_INTERNAL ):
					output.append( actor )
			# output = sorted( output, cmp = _sortEntity )
			return output

	def compareNodes( self, node1, node2 ):
		return node1._priority >= node2._priority

	def createItem( self, node ):
		return SceneGraphTreeItem()

	def updateHeaderItem( self, item, col, info ):
		if info[0] == 'V':
			item.setText( col, '')
			item.setIcon( col, getIcon( 'entity_vis' ) )
		elif info[0] == 'L':
			item.setText( col, '')
			item.setIcon( col, getIcon( 'entity_lock' ) )

	def updateItemContent( self, item, node, **option ):
		name = None
		item.setData( 1, Qt.UserRole, 0 )

		if isCandyInstance( node, 'ActorGroup' ):
			item.setText( 1, node.name or '<unnamed>' )
			item.setIcon( 1, getIcon('actor_group') )
			if node.isLocalVisible( node ):
				item.setIcon( 0, getIcon( 'entity_vis' ) )
			else:
				item.setIcon( 0, getIcon( 'entity_invis' ) )

			if node.isLocalEditLocked( node ):
				item.setIcon( 2, getIcon( 'entity_lock' ) )
			else:
				item.setIcon( 2, getIcon( 'entity_nolock' ) )
			item.setData( 1, Qt.UserRole, 1 )

		elif isCandyInstance( node, 'Actor' ):
			if node['FLAG_PROTO_SOURCE']:
				item.setIcon( 1, getIcon('proto') )
			elif node['PROTO_INSTANCE_STATE']:
				item.setIcon( 1, getIcon('instance') )
			# elif node['__proto_history']:
			# 	item.setIcon( 0, getIcon('instance-sub') )
			# elif isCandyInstance( node, 'ProtoContainer' ):
			# 	item.setIcon( 0, getIcon('instance-container') )
			else:
				item.setIcon( 1, getIcon('obj') )
			item.setText( 1, node.name or '<unnamed>' )
	
			layerName = node.getLayer( node )
			if isinstance( layerName, tuple ):
				item.setText( 3, '????' )
			else:
				item.setText( 3, layerName )
			# item.setText( 2, node.getClassName( node ) )
			# item.setFont( 0, _fontAnimatable )
			if node.isLocalVisible( node ):
				item.setIcon( 0, getIcon( 'entity_vis' ) )
			else:
				item.setIcon( 0, getIcon( 'entity_invis' ) )

			# if _CANDY.Actor.isLocalEditLocked( node ):
			# 	item.setIcon( 2, getIcon( 'entity_lock' ) )
			# else:
			# 	item.setIcon( 2, getIcon( 'entity_nolock' ) )
		
	def onItemSelectionChanged(self):
		if not self.syncSelection: return
		items = self.selectedItems()
		if items:
			selections=[item.node for item in items]
			self.module.changeSelection(selections)
		else:
			self.module.changeSelection(None)

	def dropEvent( self, ev ):		
		p = self.dropIndicatorPosition()
		pos = False
		if p == QtWidgets.QAbstractItemView.OnItem: #reparent
			pos = 'on'
		elif p == QtWidgets.QAbstractItemView.AboveItem:
			pos = 'above'
		elif p == QtWidgets.QAbstractItemView.BelowItem:
			pos = 'below'
		else:
			pos = 'viewport'

		target = self.itemAt( ev.pos() )
		ok = False
		if pos == 'on':
			ok = self.module.doCommand( 'scene_editor/reparent_actor', target = target.node )
		elif pos == 'viewport':
			ok = self.module.doCommand( 'scene_editor/reparent_actor', target = 'root' )
		elif pos == 'above' or pos == 'below':
			ok = self.module.doCommand( 'scene_editor/reparent_actor', target = target.node, mode = 'sibling' )

		if ok:
			super( GenericTreeWidget, self ).dropEvent( ev )
		else:
			ev.setDropAction( Qt.IgnoreAction )

	def onDeletePressed( self ):
		self.syncSelection = False
		item0 = self.currentItem()
		item1 = self.itemBelow( item0 )
		self.module.doCommand( 'scene_editor/remove_actor' )
		if item1:
			self.setFocusedItem( item1 )
		self.syncSelection = True
		self.onItemSelectionChanged()

	def onItemChanged( self, item, col ):
		self.module.renameActor(item.node, item.text(1))

	def onClipboardCopy( self ):
		self.module.onCopyActor()
		return True

	def onClipboardPaste( self ):
		self.module.onPasteActor()
		return True

	def onScrollRangeChanged( self, min, max ):
		if self.adjustingRange: return
		self.adjustingRange = True
		pageStep = self.verticalScrollBar().pageStep()
		self.verticalScrollBar().setRange( min, max + 2 )
		self.adjustingRange = False

	def mousePressEvent( self, ev ):
		if ev.button() == Qt.LeftButton:
			item = self.itemAt( ev.pos() )
			if item:
				col = self.columnAt( ev.pos().x() )
				if col == 2:
					node = self.getNodeByItem( item )
					self.module.doCommand( 'scene_editor/toggle_actor_lock', target = node )
					return
		elif ev.button() == Qt.RightButton:
			item = self.itemAt(ev.pos())
			if item:
				col = self.columnAt( ev.pos().x() )
				if col == 0:
					node = self.getNodeByItem( item )
					self.module.doCommand( 'scene_editor/toggle_actor_visibility', target = node )
					return
			
		return super( SceneGraphTreeWidget, self ).mousePressEvent( ev )


##----------------------------------------------------------------##
#TODO: allow sort by other column
class SceneGraphTreeItem( QtWidgets.QTreeWidgetItem ):
	def __lt__(self, other):
		node0 = self.node
		node1 = hasattr(other, 'node') and other.node or None
		if not node1:
			return True
		if not node0:
			return False
		tree = self.treeWidget()
		group0 = isCandyInstance( node0, 'ActorGroup' )
		group1 = isCandyInstance( node1, 'ActorGroup' )
		if group0 != group1:
			if tree.sortOrder() == 0:
				if group0: return True
				if group1: return False
			else:
				if group0: return False
				if group1: return True
		proto0 = node0[ 'FLAG_PROTO_SOURCE' ]
		proto1 = node1[ 'FLAG_PROTO_SOURCE' ]
		if proto0 != proto1:
			if tree.sortOrder() == 0:
				if proto0: return True
				if proto1: return False
			else:
				if proto0: return False
				if proto1: return True
		return super( SceneGraphTreeItem, self ).__lt__( other )

##----------------------------------------------------------------##
SceneOutlinerEditor().register()

##----------------------------------------------------------------##
def sceneObjectSearchEnumerator( typeId, context, option ):
	if not context in ['scene', 'all']: return None
	modelMgr = ModelManager.get()
	objects = modelMgr.enumerateObjects( typeId, context, option )
	if not objects: return None
	result = []
	for obj in objects:
		name     = modelMgr.getObjectRepr( obj )
		typeName = modelMgr.getObjectTypeRepr( obj )
		entry = ( obj, name, typeName, None )
		result.append( entry )
	return result

def entityNameSearchEnumerator( typeId, context, option ):
	if not context in [ 'actor_creation' ] : return None
	registry = _CANDY.getActorRegistry()
	result = []
	for name in sorted( registry.keys() ):
		entry = ( name, name, 'Actor', None )
		result.append( entry )
	return result

def componentNameSearchEnumerator( typeId, context, option ):
	if not context in [ 'component_creation' ] : return None
	registry = _CANDY.getComponentRegistry()
	result = []
	for name in sorted( registry.keys() ):
		entry = ( name, name, 'Actor', None )
		result.append( entry )
	return result
		
def layerNameSearchEnumerator( typeId, context, option ):
	if not context in [ 'scene_layer' ] : return None
	layers = _CANDY.game.layers
	result = []
	for l in sorted( layers.values() ):
		name = l.name
		if name == 'CANDY_EDITOR_LAYER': continue
		entry = ( name, name, 'Layer', None )
		result.append( entry )
	return result
