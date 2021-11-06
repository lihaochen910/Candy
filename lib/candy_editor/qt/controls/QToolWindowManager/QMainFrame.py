from PyQt5.QtCore import QTimer, QPoint, QRect, QMetaObject, Qt
from PyQt5.QtWidgets import QMainWindow, QTabWidget, QApplication, QMenuBar

from .QToolTabManager import CTabPaneManager
from .QToolWindowManager import QToolWindowManager, QToolWindowManagerClassFactory
from .QToolWindowManagerCommon import *
from .QToolWindowRollupBarArea import QToolWindowRollupBarArea
from .QTrackingTooltip import QTrackingTooltip
from .QtViewPane import EDockingDirection
from .SandboxWindowing import *


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


class CEditorMainFrame ( QMainWindow ):

	def __init__ ( self, parent ):
		super ( CEditorMainFrame, self ).__init__ ( parent )

		# TODO: 初始化关卡编辑器
		# from qt.controls.EditorCommon.MainWindow import CObjectCreateToolPanel
		# self.levelEditor = CObjectCreateToolPanel ()
		# self.levelEditor.initialize ()

		CEditorMainFrame._instance = self

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

		toolConfig = {}
		toolConfig[ QTWM_AREA_DOCUMENT_MODE ] = False
		toolConfig[ QTWM_AREA_IMAGE_HANDLE ] = False
		toolConfig[ QTWM_AREA_SHOW_DRAG_HANDLE ] = False
		toolConfig[ QTWM_AREA_TABS_CLOSABLE ] = False
		# toolConfig[ QTWM_AREA_TAB_POSITION ] =
		toolConfig[ QTWM_AREA_EMPTY_SPACE_DRAG ] = True
		toolConfig[ QTWM_THUMBNAIL_TIMER_INTERVAL ] = 1000
		toolConfig[ QTWM_TOOLTIP_OFFSET ] = QPoint ( 1, 20 )
		toolConfig[ QTWM_AREA_TAB_ICONS ] = True
		toolConfig[ QTWM_RELEASE_POLICY ] = QTWMReleaseCachingPolicy.rcpWidget
		toolConfig[ QTWM_WRAPPERS_ARE_CHILDREN ] = False
		toolConfig[ QTWM_RAISE_DELAY ] = 750
		toolConfig[ QTWM_RETITLE_WRAPPER ] = True
		toolConfig[ QTWM_SINGLE_TAB_FRAME ] = True
		toolConfig[ QTWM_BRING_ALL_TO_FRONT ] = True
		toolConfig[ SANDBOX_WRAPPER_MINIMIZE_ICON ] = QIcon ( "./resources/icons/window_minimize.ico" )
		toolConfig[ SANDBOX_WRAPPER_MAXIMIZE_ICON ] = QIcon ( "./resources/icons/window_maximize.ico" )
		toolConfig[ SANDBOX_WRAPPER_RESTORE_ICON ] = QIcon ( "./resources/icons/window_restore.ico" )
		toolConfig[ SANDBOX_WRAPPER_CLOSE_ICON ] = QIcon ( "./resources/icons/window_close.ico" )
		toolConfig[ QTWM_TAB_CLOSE_ICON ] = QIcon ( "./resources/icons/window_close.ico" )
		toolConfig[ QTWM_SINGLE_TAB_FRAME_CLOSE_ICON ] = QIcon ( "./resources/icons/window_close.ico" )

		classFactory = CToolWindowManagerClassFactory ()
		self.toolManager = QToolWindowManager ( self, toolConfig, classFactory )

		# TODO: save editor config
		# from .CDockableContainer import s_dockingFactory
		# s_dockingFactory = classFactory

		registerMainWindow ( self )
		self.toolManager.updateTrackingTooltip.connect ( lambda str, p: QTrackingTooltip.showTextTooltip ( str, p ) )
		self.toolManager.toolWindowVisibilityChanged.connect ( lambda w, visible: s_pToolTabManager.onTabPaneMoved ( w, visible ) )
		# self.layoutChangedConnection = self.toolManager.layoutChanged.connect()

		mainDockArea = self.toolManager
		self.setCentralWidget ( mainDockArea )

		self.updateWindowTitle ()

		self.setWindowIcon ( QIcon ( "./resources/icons/appicon.png" ) )
		qApp.setWindowIcon ( QIcon ( "./resources/icons/appicon_2.png" ) )

		mainWindow = QSandboxWindow.wrapWidget ( self, self.toolManager )
		# mainWindow.setObjectName ( "mainWindow" )
		mainWindow.setObjectName ( "QSandboxWindow" )
		mainWindow.show ()

		self.mainWindow = mainWindow

		self.setFocusPolicy ( QtCore.Qt.StrongFocus )

	def __del__ ( self ):
		# print ( "CEditorMainWindow.__del__" )
		pass

	def setupUI ( self ):
		if not self.objectName ():
			# self.setObjectName ( "MainWindow" )
			self.setObjectName ( "CEditorMainFrame" )
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
		self.initActions ()
		self.initMenus ()
		self.initMenuBar ()
		self.initLayout ()

		from candy_editor.qt.controls.EditorCommon.IEditor import getIEditor, EEditorNotifyEvent
		getIEditor ().notify ( EEditorNotifyEvent.Notify_OnMainFrameInitialized )

	@staticmethod
	def get ():
		""" Get single instance

			Returns:
				CEditorMainFrame
	    """
		return CEditorMainFrame._instance

	def getToolManager ( self ) -> QToolWindowManager:
		return self.toolManager

	def isClosing ( self ) -> bool:
		return self.closing

	def onIdleCallback ( self ):
		global s_pToolTabManager
		s_pToolTabManager.onIdle ()

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
		CTabPaneManager.get ().layoutLoaded ()

		# self.getToolManager ().addToolWindow ( CObjectCreateToolPanel () )

		# CTabPaneManager.get ().createPane ( "ViewportClass_Perspective", "Perspective", EDockingDirection.DOCK_TOP )
		CTabPaneManager.get ().createPane ( "LevelEditor", "Perspective", EDockingDirection.DOCK_TOP )
		CTabPaneManager.get ().createPane ( "ObjectCreateToolPanel", "ObjectCreateTool", EDockingDirection.DOCK_BOTTOM )

	def createToolsMenu ( self ):
		pass

	def initActions ( self ):
		pass

	def initLayout ( self ):
		bLayoutLoaded = CTabPaneManager.get ().loadUserLayout ()
		if not bLayoutLoaded:
			bLayoutLoaded = CTabPaneManager.get ().loadDefaultLayout ()

		if not bLayoutLoaded:
			self.setDefaultLayout ()

	def initMenus ( self ):
		pass

	def initMenuBar ( self ):
		pass

	def beforeClose ( self ):
		return True

	def closeEvent ( self, e ):
		print ( "sandbox_closeevent" )
		if self.beforeClose ():
			qApp.exit ()
		else:
			e.ignore ()
		super ().closeEvent ( e )

	def saveConfig ( self ):
		pass

	def event ( self, e ):
		scale = self.devicePixelRatioF ()
		# if ( e.type () == QEvent.ScreenChangeInternal or e.type () == QEvent.PlatformSurface) and scale != self.devicePixelRatioF ():
		if e.type () == QEvent.PlatformSurface and scale != self.devicePixelRatioF ():
			super ().restoreState ( QMainWindow.saveState () )
			scale = self.devicePixelRatioF ()

		if e.type () == QEvent.KeyPress and e.key () == Qt.Key_S:
			self.toolManagerData = self.getToolManager ().saveState ()
			e.accept ()

			# import json
			# print ( json.dumps ( self.toolManagerData ) )
			import yaml
			print ( yaml.dump ( self.toolManagerData ) )

		if e.type () == QEvent.KeyPress and e.key () == Qt.Key_P:
			self.getToolManager ().restoreState ( self.toolManagerData )
			e.accept ()

		# TODO: 处理快捷键
		return super ().event ( e )


if __name__ == '__main__':
	import sys

	app = QApplication ( sys.argv )
	window = CEditorMainFrame ()
	window.postLoad ()
	window.show ()
	window.raise_ ()
	app.exec_ ()
