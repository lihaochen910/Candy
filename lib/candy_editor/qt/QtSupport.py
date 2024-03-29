from PyQt5.QtCore import QEventLoop

from candy_editor.core import *

from candy_editor.qt.controls.Window import MainWindow
from candy_editor.qt.QtEditorModule import QtEditorModule
from candy_editor.qt.dialogs import *


_QT_SETTING_FILE = 'qt.ini'


##----------------------------------------------------------------##
class QtSupportEventFilter ( QObject ):

	def eventFilter ( self, obj, event ):
		e = event.type ()
		if e == QEvent.ApplicationActivate:
			signals.emitNow ( 'app.activate' )
		elif e == QEvent.ApplicationDeactivate:
			signals.emitNow ( 'app.deactivate' )
		return QObject.eventFilter ( self, obj, event )


##----------------------------------------------------------------##
class QtSupport ( QtEditorModule ):

	def __init__ ( self ):
		self.statusWindow = None

	def getName ( self ):
		return 'qt'

	def getDependency ( self ):
		return []

	def getBaseDependency ( self ):
		return []

	def setupStyle ( self ):
		# setup styles
		# QtWidgets.QApplication.setStyle(QtGui.QStyleFactory.create('Windows'))
		QtCore.QDir.setSearchPaths ( 'theme', [ self.getApp ().getPath ( 'resources/theme' ) ] )
		QtGui.QFontDatabase.addApplicationFont ( self.getApp ().getPath ( 'resources/MyriadPro-Regular.ttf' ) )
		try:
			# styleSheetName = 'CryEngineVStyleSheet.qss'
			styleSheetName = 'QtDarkOrange.qss'
			# styleSheetName = 'gii.qss'
			self.qtApp.setStyleSheet (
				open ( self.getApp ().getPath ( 'resources/theme/' + styleSheetName ) ).read ()
			)
		# self.qtApp.setFont(QtGui.QFont(self.getApp().getPath( 'resources/MyriadPro-Regular.ttf' )))
		except Exception as e:
			import logging
			logging.info ( 'style sheet not load', e )
			self.qtApp.setStyleSheet ( '''
				QWidget{
					font: 10pt;				
				}

				QMainWindow::Separator{
					width:4px;
					height:4px;
					border:1px solid #c9c9c9;
				}
				''' )

	def setupMainWindow ( self ):
		self.mainWindow = QtMainWindow ( None )
		self.mainWindow.setBaseSize ( 800, 600 )
		self.mainWindow.resize ( 800, 600 )
		self.mainWindow.setWindowTitle ( 'Candy - MainWindow' )
		self.mainWindowIcon = QtGui.QIcon ( self.getApp ().getPath ( 'resources/icons/appicon_2.png' ) )
		self.mainWindow.setWindowIcon ( self.mainWindowIcon )

		self.mainWindow.setFixedSize ( 0, 0 )
		self.mainWindow.show ()
		self.mainWindow.raise_ () #bring app to front
		self.mainWindow.hide ()
		self.mainWindow.module = self

		self.sharedMenuBar = QtWidgets.QMenuBar ( None )
		self.mainWindow.setMenuWidget ( self.sharedMenuBar )

		self.menu = self.addMenuBar ( 'main', self.sharedMenuBar )
		self.menu.addChild ( '&File' ).addChild ( [
			'System Status',
			'----',
			'Asset Editor|F2',
			'Scene Editor|F3',
			'Debug View|F9',
			'----',
			'Refresh Theme',
			'----',
			'E&xit',
		] )
		self.menu.addChild ( '&Edit' ).addChild ( [
			'Undo|Ctrl+Z',
			'Redo|Ctrl+Shift+Z',
		]
		)
		self.menu.addChild ( '&Find' )

	def getSharedMenubar ( self ):
		return self.sharedMenuBar

	def showSystemStatusWindow ( self ):
		if not self.statusWindow:
			self.statusWindow = self.requestSubWindow ( 'SystemStatus',
			                                            title = 'System Status',
			                                            size = (200, 200),
			                                            minSize = (200, 200)
			                                            )
			self.statusWindow.body = self.statusWindow.addWidgetFromFile (
				self.getApp ().getPath ( 'data/ui/SystemStatus.ui' )
			)
		self.statusWindow.show ()
		self.statusWindow.raise_ ()

	def setActiveWindow ( self, window ):
		self.qtApp.setActiveWindow ( window )

	def onLoad ( self ):
		self.qtApp = QtWidgets.QApplication ( [ '-graphicssystem', 'opengl' ] )
		self.qtSetting = QtCore.QSettings (
			self.getProject ().getConfigPath ( _QT_SETTING_FILE ),
			QtCore.QSettings.IniFormat
		)

		self.setupStyle ()
		self.setupMainWindow ()

		self.initialized = True
		self.running = False
		return True

	def onStart ( self ):
		eventFilter = QtSupportEventFilter ( self.qtApp )
		eventFilter.app = self
		self.qtApp.installEventFilter ( eventFilter )

	def needUpdate ( self ):
		return True

	def onUpdate ( self ):
		if not self.qtApp.hasPendingEvents (): return
		self.qtApp.processEvents ( QEventLoop.AllEvents, 4 )

	# self.qtApp.processEvents( QEventLoop.AllEvents )
	# self.qtApp.processEvents( QEventLoop.WaitForMoreEvents )

	def getMainWindow ( self ):
		return self.mainWindow

	def getQtSettingObject ( self ):
		return self.qtSetting

	def onStart ( self ):
		self.restoreWindowState ( self.mainWindow )
		self.qtApp.processEvents ( QEventLoop.AllEvents )

	def onStop ( self ):
		self.saveWindowState ( self.mainWindow )

	def onMenu ( self, node ):
		name = node.name
		if name == 'exit':
			self.getApp ().stop ()
		elif name == 'system_status':
			self.showSystemStatusWindow ()
		elif name == 'asset_editor':
			self.getModule ( 'asset_editor' ).setFocus ()
		elif name == 'scene_editor':
			self.getModule ( 'scene_editor' ).setFocus ()
		elif name == 'debug_view':
			self.getModule ( 'debug_view' ).setFocus ()
		elif name == 'refresh_theme':
			self.setupStyle ()
		elif name == 'copy':
			print ( 'copy' )
		elif name == 'paste':
			print ( 'paste' )
		elif name == 'cut':
			print ( 'cut' )

		elif name == 'undo':
			stack = EditorCommandRegistry.get ().getCommandStack ( 'scene_editor' )
			stack.undoCommand ()

		elif name == 'redo':
			stack = EditorCommandRegistry.get ().getCommandStack ( 'scene_editor' )
			stack.redoCommand ()


QtSupport ().register ()


##----------------------------------------------------------------##
class QtMainWindow ( MainWindow ):
	"""docstring for QtMainWindow"""

	def __init__ ( self, parent, *args ):
		super ( QtMainWindow, self ).__init__ ( parent, *args )

	def closeEvent ( self, event ):
		if self.module.alive:
			self.hide ()
			event.ignore ()
		else:
			pass


##----------------------------------------------------------------##
class QtGlobalModule ( QtEditorModule ):
	"""docstring for QtGlobalModule"""

	def getMainWindow ( self ):
		qt = self.getQtSupport ()
		return qt.getMainWindow ()

	def requestDockWindow ( self, id = None, **windowOption ):
		raise Exception ( 'only subwindow supported for globalModule' )

	def requestDocumentWindow ( self, id = None, **windowOption ):
		raise Exception ( 'only subwindow supported for globalModule' )

	def requestSubWindow ( self, id = None, **windowOption ):
		if not id: id = self.getName ()
		mainWindow = self.getMainWindow ()
		container = mainWindow.requestSubWindow ( id, **windowOption )
		# self.containers[id] = container
		return container
