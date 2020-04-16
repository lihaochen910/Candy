from PyQt5 import QtCore
from PyQt5.QtCore import QEvent, QTimer, QPoint, QRect, QMetaObject
from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import QMainWindow, qApp, QTabWidget, QApplication, QWidget, QMenuBar

from qt.controls.QToolWindowManager.QToolTabManager import CTabPaneManager
from qt.controls.QToolWindowManager.QToolWindowManager import QToolWindowManager, QToolWindowManagerClassFactory
from qt.controls.QToolWindowManager.QToolWindowManagerCommon import *
from qt.controls.QToolWindowManager.QToolWindowRollupBarArea import QToolWindowRollupBarArea
from qt.controls.QToolWindowManager.QTrackingTooltip import QTrackingTooltip
from qt.controls.QToolWindowManager.SandboxWindowing import *

s_pToolTabManager = None  # CTabPaneManager
s_pWidgetGlobalActionRegistry = None  # CWidgetsGlobalActionRegistry


class CToolWindowManagerClassFactory ( QToolWindowManagerClassFactory ):

	def createWrapper ( self, manager ):
		return QSandboxWrapper ( manager )

	def createSplitter ( self, manager ):
		return QNotifierSplitter ()

	def createArea ( self, manager, parent = None, areaType = QTWMWrapperAreaType.watTabs ):
		if manager.config.setdefault ( QTWM_SUPPORT_SIMPLE_TOOLS,
		                               False ) and areaType == QTWMWrapperAreaType.watRollups:
			return QToolWindowRollupBarArea ( manager, parent )
		else:
			return QToolsMenuToolWindowArea ( manager, parent )


class CEditorMainWindow ( QMainWindow ):

	def __init__ ( self, parent ):
		super ().__init__ ( parent )

		# TODO: 初始化关卡编辑器

		CEditorMainWindow._instance = self

		self.setupUI ()

		# TODO: 初始化CEditorMainWindow图标以及菜单选项
		global s_pToolTabManager
		s_pToolTabManager = CTabPaneManager ( self )

		self.setAttribute ( QtCore.Qt.WA_DeleteOnClose, True )

		QTimer.singleShot ( 0, self.onIdleCallback )
		QTimer.singleShot ( 500, self.onBackgroundUpdateTimer )

		self.setCorner ( QtCore.Qt.TopRightCorner, QtCore.Qt.RightDockWidgetArea )
		self.setCorner ( QtCore.Qt.BottomRightCorner, QtCore.Qt.RightDockWidgetArea )

		self.setTabPosition ( QtCore.Qt.RightDockWidgetArea, QTabWidget.East )

		self.setDockOptions ( QMainWindow.AnimatedDocks | QMainWindow.AllowNestedDocks | QMainWindow.AllowTabbedDocks )

		toolConfig = { }
		toolConfig[ QTWM_AREA_DOCUMENT_MODE ] = False
		toolConfig[ QTWM_AREA_IMAGE_HANDLE ] = True
		toolConfig[ QTWM_AREA_SHOW_DRAG_HANDLE ] = False
		toolConfig[ QTWM_AREA_TABS_CLOSABLE ] = False
		toolConfig[ QTWM_AREA_EMPTY_SPACE_DRAG ] = True
		toolConfig[ QTWM_THUMBNAIL_TIMER_INTERVAL ] = 1000
		toolConfig[ QTWM_TOOLTIP_OFFSET ] = QPoint ( 1, 20 )
		toolConfig[ QTWM_AREA_TAB_ICONS ] = False
		toolConfig[ QTWM_RELEASE_POLICY ] = QTWMReleaseCachingPolicy.rcpWidget
		# toolConfig[ QTWM_WRAPPERS_ARE_CHILDREN ] = not gEditorGeneralPreferences.showWindowsInTaskbar
		toolConfig[ QTWM_RAISE_DELAY ] = 1000
		toolConfig[ QTWM_RETITLE_WRAPPER ] = True
		toolConfig[ QTWM_SINGLE_TAB_FRAME ] = True
		toolConfig[ QTWM_BRING_ALL_TO_FRONT ] = True
		toolConfig[ SANDBOX_WRAPPER_MINIMIZE_ICON ] = QIcon ( "icons:Window/Window_Minimize.ico" )
		toolConfig[ SANDBOX_WRAPPER_MAXIMIZE_ICON ] = QIcon ( "icons:window_maximize.ico" )
		toolConfig[ SANDBOX_WRAPPER_RESTORE_ICON ] = QIcon ( "icons:Window/Window_Restore.ico" )
		toolConfig[ SANDBOX_WRAPPER_CLOSE_ICON ] = QIcon ( "icons:Window/Window_Close.ico" )
		toolConfig[ QTWM_TAB_CLOSE_ICON ] = QIcon ( "icons:Window/Window_Close.ico" )
		toolConfig[ QTWM_SINGLE_TAB_FRAME_CLOSE_ICON ] = QIcon ( "icons:Window/Window_Close.ico" )

		classFactory = CToolWindowManagerClassFactory ()
		self.toolManager = QToolWindowManager ( self, toolConfig, classFactory )

		# TODO: save editor config
		# from .CDockableContainer import s_dockingFactory
		# s_dockingFactory = classFactory

		registerMainWindow ( self )
		self.toolManager.updateTrackingTooltip.connect ( lambda str, p: QTrackingTooltip.showTextTooltip ( str, p ) )
		self.toolManager.toolWindowVisibilityChanged.connect (
			lambda str, p: QTrackingTooltip.showTextTooltip ( str, p ) )
		# self.layoutChangedConnection = self.toolManager.layoutChanged.connect()

		mainDockArea = self.toolManager
		self.setCentralWidget ( mainDockArea )

		self.updateWindowTitle ()

		self.setWindowIcon ( QIcon ( "icons:editor_icon.ico" ) )
		qApp.setWindowIcon ( self.windowIcon () )

		mainWindow = QSandboxWindow.wrapWidget ( self, self.toolManager )
		mainWindow.setObjectName ( "mainWindow" )
		mainWindow.show ()

		self.mainWindow = mainWindow

		self.setFocusPolicy ( QtCore.Qt.StrongFocus )

	def __del__ ( self ):
		print ( "CEditorMainWindow.__del__" )

	def setupUI ( self ):
		if not self.objectName ():
			self.setObjectName ( "MainWindow" )
		self.resize ( 1172, 817 )

		centralwidget = QWidget ( self )
		self.setCentralWidget ( centralwidget )

		menubar = QMenuBar ( self )
		menubar.setObjectName ( "menubar" )
		menubar.setGeometry ( QRect ( 0, 0, 1172, 21 ) )
		self.setMenuBar ( menubar )

		# TODO: CMenu

		QMetaObject.connectSlotsByName ( self )

	def postLoad ( self ):
		pass

	@staticmethod
	def get ():
		return CEditorMainWindow._instance

	def getToolManager ( self ):
		return self.toolManager

	def isClosing ( self ):
		return self.closing

	def onIdleCallback ( self ):
		pass

	def onBackgroundUpdateTimer ( self ):
		pass

	def updateWindowTitle ( self, levelPath = None ):
		v = '0.1'  # TODO: GetIEditorImpl()->GetFileVersion()
		game = ''  # TODO: QtUtil::ToQString(gEnv->pSystem->GetIProjectManager()->GetCurrentProjectName())
		title = "Candy Sandbox - Build %s - Project '%s'" % (v, game)

		if levelPath:
			title += levelPath

		self.setWindowTitle ( title )

	def setDefaultLayout ( self ):
		pass

	def createToolsMenu ( self ):
		pass

	def initActions ( self ):
		pass

	def initLayout ( self ):
		pass

	def initMenus ( self ):
		pass

	def initMenuBar ( self ):
		pass

	def beforeClose ( self ):
		return True

	def closeEvent ( self, e ):
		print ( "sandbox_close" )
		if self.beforeClose ():
			qApp.exit ()
		else:
			e.ignore ()

	def saveConfig ( self ):
		pass

	def event ( self, e ):
		scale = self.devicePixelRatioF ()
		# if ( e.type () == QEvent.ScreenChangeInternal or e.type () == QEvent.PlatformSurface) and scale != self.devicePixelRatioF ():
		if e.type () == QEvent.PlatformSurface and scale != self.devicePixelRatioF ():
			QMainWindow.restoreState ( self, QMainWindow.saveState () )
			scale = self.devicePixelRatioF ()

		# TODO: 处理快捷键
		return super ().event ( e )


if __name__ == '__main__':
	import sys

	app = QApplication ( sys.argv )
	window = CEditorMainWindow ()
	window.postLoad ()
	window.show ()
	window.raise_ ()
	app.exec_ ()
