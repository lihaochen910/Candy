from abc import abstractmethod

from candy_editor.core import EditorModule
from candy_editor.qt.controls.Menu import MenuManager
from candy_editor.qt.controls.ToolBar import ToolBarManager, ToolBarItem

from PyQt5 import QtGui, QtWidgets
from PyQt5.QtCore import Qt

##----------------------------------------------------------------##
_QT_SETTING_FILE = 'qt.ini'


##----------------------------------------------------------------##
class QtEditorModule ( EditorModule ):

	@abstractmethod
	def getMainWindow ( self ):
		return None

	def getModuleWindow ( self ):
		return None

	# def getDependency(self):
	#     return self._dependency

	def getBaseDependency ( self ):
		return [ 'qt' ]

	def getQtSupport ( self ):
		return self.getModule ( 'qt' )

	def getQApplication ( self ):
		qt = self.getModule ( 'qt' )
		return qt.qtApp

	def addShortcut ( self, context, keySeq, target, *args, **option ):
		contextWindow = None
		shortcutContext = None

		if context == 'main':
			contextWindow = self.getMainWindow ()
			shortcutContext = Qt.WidgetWithChildrenShortcut
		elif context == 'module':
			contextWindow = self.getModuleWindow ()
			shortcutContext = Qt.WidgetWithChildrenShortcut
		elif context == 'app':
			contextWindow = self.getMainWindow ()
			shortcutContext = Qt.ApplicationShortcut
		elif isinstance ( context, QtWidgets.QWidget ):
			contextWindow = context
			shortcutContext = Qt.WidgetWithChildrenShortcut

		action = QtWidgets.QAction ( contextWindow )
		action.setShortcut ( QtGui.QKeySequence ( keySeq ) )
		action.setShortcutContext ( shortcutContext )
		contextWindow.addAction ( action )

		if isinstance ( target, str ):  # command
			def onAction ():
				self.doCommand ( target, **option )

			action.triggered.connect ( onAction )
		elif isinstance ( target, QtWidgets.QAction ):
			def onAction ():
				target.trigger ()

			action.triggered.connect ( onAction )
		elif isinstance ( target, ToolBarItem ):
			def onAction ():
				target.trigger ()

			action.triggered.connect ( onAction )
		else:  # callable
			def onAction ():
				target ( *args, **option )

			action.triggered.connect ( onAction )

		return action

	def requestDockWindow ( self, id = None, **windowOption ):
		if not id: id = self.getName ()
		mainWindow = self.getMainWindow ()
		container = mainWindow.requestDockWindow ( id, **windowOption )
		# self.containers[id] = container
		self.retain ( container )
		return container

	def requestSubWindow ( self, id = None, **windowOption ):
		if not id: id = self.getName ()
		mainWindow = self.getMainWindow ()
		container = mainWindow.requestSubWindow ( id, **windowOption )
		# self.containers[id] = container
		self.retain ( container )
		return container

	def requestDocumentWindow ( self, id = None, **windowOption ):
		if not id: id = self.getName ()
		mainWindow = self.getMainWindow ()
		container = mainWindow.requestDocumentWindow ( id, **windowOption )
		# self.containers[id] = container
		self.retain ( container )
		return container

	def requestToolWindow ( self, id = None, **windowOption ):
		if not id: id = self.getName ()
		mainWindow = self.getMainWindow ()
		container = mainWindow.requestToolWindow ( id, **windowOption )
		# self.containers[id] = container
		self.retain ( container )
		return container

	def setFocus ( self ):
		self.onSetFocus ()

	def setActiveWindow ( self, window ):
		qt = self.getQtSupport ()
		qt.qtApp.setActiveWindow ( window )

	# CONFIG
	def getQtSettingObject ( self ):
		return self.getQtSupport ().getQtSettingObject ()

	def setQtSetting ( self, name, value ):
		name = 'modules/%s/%s' % (self.getName (), name)
		self.setGlobalQtSetting ( name, value )

	def getQtSetting ( self, name, default = None ):
		name = 'modules/%s/%s' % (self.getName (), name)
		return self.getGlobalQtSetting ( name, default )

	def setGlobalQtSetting ( self, name, value, **kwarg ):
		setting = self.getQtSettingObject ()
		setting.setValue ( name, value )
		setting.sync ()

	def getGlobalQtSetting ( self, name, default = None, **kwarg ):
		setting = self.getQtSettingObject ()
		v = setting.value ( name )
		if v is None: return default
		return v

	# MENU CONTROL
	def addMenuBar ( self, name, menubar ):
		node = MenuManager.get ().addMenuBar ( name, menubar, self )
		self.retain ( node )
		return node

	def addMenu ( self, path, option = None ):
		node = MenuManager.get ().addMenu ( path, option, self )
		self.retain ( node )
		return node

	def addMenuItem ( self, path, option = None ):
		node = MenuManager.get ().addMenuItem ( path, option, self )
		self.retain ( node )
		return node

	def findMenu ( self, path ):
		node = MenuManager.get ().find ( path )
		return node

	def disableMenu ( self, path ):
		self.enableMenu ( path, False )

	def enableMenu ( self, path, enabled = True ):
		node = self.findMenu ( path )
		if not node:
			raise Exception ( 'Menuitem not found:' + path )
		node.setEnabled ( enabled )

	def checkMenu ( self, path, checked = True ):
		node = self.findMenu ( path )
		if not node:
			raise Exception ( 'Menuitem not found:' + path )
		node.setValue ( checked )

	# TOOLBar control
	def addToolBar ( self, name, toolbar, **option ):
		owner = option.get ( 'owner', self )
		if option.get ( 'owner', None ): del option[ 'owner' ]
		node = ToolBarManager.get ().addToolBar ( name, toolbar, owner, **option )
		self.retain ( node )
		return node

	def addTool ( self, path, **option ):
		owner = option.get ( 'owner', self )
		if option.get ( 'owner', None ): del option[ 'owner' ]
		node = ToolBarManager.get ().addTool ( path, option, owner )
		self.retain ( node )
		return node

	def findTool ( self, path ):
		node = ToolBarManager.get ().find ( path )
		return node

	def disableTool ( self, path ):
		self.enableTool ( path, False )

	def enableTool ( self, path, enabled = True ):
		node = self.findTool ( path )
		if not node:
			raise Exception ( 'tool/toolbar not found:' + path )
		node.setEnabled ( enabled )

	def checkTool ( self, path, checked = True ):
		node = self.findTool ( path )
		if not node:
			raise Exception ( 'tool/toolbar not found:' + path )
		node.setValue ( checked )

	# WINDOW STATE
	def restoreWindowState ( self, window, name = None ):
		if not name:
			name = window.objectName () or 'window'
		fullname = self.getName () + '_' + name
		geodata = self.getQtSetting ( 'geom_' + fullname )
		if geodata:
			window.restoreGeometry ( geodata )
		if hasattr ( window, 'restoreState' ):
			statedata = self.getQtSetting ( 'state_' + fullname )
			if statedata:
				window.restoreState ( statedata )

	def saveWindowState ( self, window, name = None ):
		if not name:
			name = window.objectName () or 'window'
		fullname = self.getName () + '_' + name
		self.setQtSetting ( 'geom_' + fullname, window.saveGeometry () )
		if hasattr ( window, 'saveState' ):
			self.setQtSetting ( 'state_' + fullname, window.saveState () )

	def onMenu ( self, menuItem ):
		pass

	def onTool ( self, toolItem ):
		pass

	def onSetFocus ( self ):
		pass
