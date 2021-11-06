import logging

# from candy_editor.qt.controls.QToolWindowManager import *
from candy_editor.qt.controls.ToolWindowManager import ToolWindowManager
from candy_editor.qt.helpers import restrainWidgetToScreen

from PyQt5 import QtCore, QtGui, uic, QtWidgets
from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import QMainWindow, QWidget, QDockWidget


def getWindowScreenId ( window ):
	desktop = QtWidgets.QApplication.desktop ()
	return desktop.screenNumber ( window )


def moveWindowToCenter ( window ):
	desktop = QtWidgets.QApplication.desktop ()
	geom = desktop.availableGeometry ( window )
	x = (geom.width () - window.width ()) / 2 + geom.x ()
	y = (geom.height () - window.height ()) / 2 + geom.y ()
	window.move ( x, y )


##----------------------------------------------------------------##
class MainWindow ( QMainWindow ):
	"""docstring for MainWindow"""

	def __init__ ( self, parent ):
		super ( MainWindow, self ).__init__ ( parent )
		self.setDocumentMode ( True )
		self.defaultToolBarIconSize = 16
		self.setUnifiedTitleAndToolBarOnMac ( False )
		self.setDockOptions (
			QtWidgets.QMainWindow.AllowNestedDocks | QtWidgets.QMainWindow.AllowTabbedDocks )
		# self.setTabPosition( Qt.AllDockWidgetAreas, QtGui.QTabWidget.North)
		font = QtGui.QFont ()
		font.setPointSize ( 11 )
		self.setFont ( font )
		self.setIconSize ( QtCore.QSize ( 16, 16 ) )
		self.setFocusPolicy ( Qt.WheelFocus )

		# toolConfig = {}
		# toolConfig[ QTWM_AREA_DOCUMENT_MODE ] = True
		# toolConfig[ QTWM_AREA_IMAGE_HANDLE ] = False
		# toolConfig[ QTWM_AREA_SHOW_DRAG_HANDLE ] = False
		# toolConfig[ QTWM_AREA_TABS_CLOSABLE ] = True
		# toolConfig[ QTWM_AREA_EMPTY_SPACE_DRAG ] = True
		# toolConfig[ QTWM_THUMBNAIL_TIMER_INTERVAL ] = 1000
		# toolConfig[ QTWM_TOOLTIP_OFFSET ] = QPoint ( 1, 20 )
		# toolConfig[ QTWM_AREA_TAB_ICONS ] = True
		# toolConfig[ QTWM_RELEASE_POLICY ] = QTWMReleaseCachingPolicy.rcpWidget
		# toolConfig[ QTWM_WRAPPERS_ARE_CHILDREN ] = False
		# toolConfig[ QTWM_RAISE_DELAY ] = 750
		# toolConfig[ QTWM_RETITLE_WRAPPER ] = True
		# toolConfig[ QTWM_SINGLE_TAB_FRAME ] = False
		# toolConfig[ QTWM_BRING_ALL_TO_FRONT ] = True
		# toolConfig[ QTWM_DROPTARGET_COMBINE ] = "resources/icons/QToolWindowManager/base_window.png"
		# toolConfig[ QTWM_DROPTARGET_TOP ] = "resources/icons/QToolWindowManager/dock_top.png"
		# toolConfig[ QTWM_DROPTARGET_BOTTOM ] = "resources/icons/QToolWindowManager/dock_bottom.png"
		# toolConfig[ QTWM_DROPTARGET_LEFT ] = "resources/icons/QToolWindowManager/dock_left.png"
		# toolConfig[ QTWM_DROPTARGET_RIGHT ] = "resources/icons/QToolWindowManager/dock_right.png"
		# toolConfig[ QTWM_DROPTARGET_SPLIT_LEFT ] = "resources/icons/QToolWindowManager/vsplit_left.png"
		# toolConfig[ QTWM_DROPTARGET_SPLIT_RIGHT ] = "resources/icons/QToolWindowManager/vsplit_right.png"
		# toolConfig[ QTWM_DROPTARGET_SPLIT_TOP ] = "resources/icons/QToolWindowManager/hsplit_top.png"
		# toolConfig[ QTWM_DROPTARGET_SPLIT_BOTTOM ] = "resources/icons/QToolWindowManager/hsplit_bottom.png"
		# toolConfig[ "sandboxMinimizeIcon" ] = QIcon ( "resources/icons/QToolWindowManager/window_minimize.ico" )
		# toolConfig[ "sandboxMaximizeIcon" ] = QIcon ( "resources/icons/QToolWindowManager/window_maximize.ico" )
		# toolConfig[ "sandboxRestoreIcon" ] = QIcon ( "resources/icons/QToolWindowManager/window_restore.ico" )
		# toolConfig[ "sandboxWindowCloseIcon" ] = QIcon ( "resources/icons/QToolWindowManager/window_close.ico" )
		# toolConfig[ QTWM_TAB_CLOSE_ICON ] = QIcon ( "resources/icons/QToolWindowManager/window_close.ico" )
		# toolConfig[ QTWM_SINGLE_TAB_FRAME_CLOSE_ICON ] = QIcon ( "resources/icons/QToolWindowManager/window_close.ico" )
		#
		# mgr = QToolWindowManager ( self, toolConfig )
		# self.setCentralWidget ( mgr )

		# self.centerTabWidget = QtGui.QTabWidget ( self )
		# self.toolWindowMgr = ToolWindowManager ( self )
		# self.centerTabWidget = self.toolWindowMgr.createArea ()
		# self.setCentralWidget ( self.centerTabWidget )

		# self.centerTabWidget.currentChanged.connect( self.onDocumentTabChanged )
		#
		# self.centerTabWidget.setDocumentMode(True)
		# self.centerTabWidget.setMovable(True)
		# self.centerTabWidget.setTabsClosable(True)
		# self.centerTabWidget.tabCloseRequested.connect( self.onTabCloseRequested )

		self.toolWindowMgr = ToolWindowManager ( self )
		self.setCentralWidget ( self.toolWindowMgr )

	def moveToCenter ( self ):
		moveWindowToCenter ( self )

	def ensureVisible ( self ):
		restrainWidgetToScreen ( self )

	def startTimer ( self, fps, trigger ):
		assert (hasattr ( trigger, '__call__' ))
		interval = 1000 / fps
		timer = QtCore.QTimer ( self )
		timer.timeout.connect ( trigger )
		timer.start ( interval )
		return timer

	def requestSubWindow ( self, id, **windowOption ):
		title = windowOption.get ( 'title', id )

		window = SubWindow ( self )
		window.setWindowTitle ( title )
		window.windowMode = 'sub'
		window.titleBase = title

		minSize = windowOption.get ( 'minSize', None )
		if minSize:
			window.setMinimumSize ( *minSize )
		# else:
		# 	window.setMinimumSize(20,20)

		maxSize = windowOption.get ( 'minSize', None )
		if maxSize:
			window.setMaximumSize ( *maxSize )

		size = windowOption.get ( 'size', None )
		if size:
			window.resize ( *size )
		return window

	def requestDocumentWindow ( self, id, **windowOption ):
		title = windowOption.get ( 'title', id )
		window = DocumentWindow ( self.centerTabWidget )
		# window = DocumentWindow( self.toolWindowMgr )
		# toolWindow = self.toolWindowMgr.addToolWindow( window, self.toolWindowMgr.EmptySpace )
		window.parentWindow = self
		window.setWindowTitle ( title )
		self.centerTabWidget.addTab ( window, title )

		window.windowMode = 'tab'
		window.titleBase = title

		minSize = windowOption.get ( 'minSize', None )
		if minSize:
			window.setMinimumSize ( *minSize )
		else:
			window.setMinimumSize ( 20, 20 )

		size = windowOption.get ( 'size', None )
		if size:
			window.resize ( *size )

		return window

	def requestDockWindow ( self, id, **dockOptions ):
		title = dockOptions.get ( 'title', id )
		dockArea = dockOptions.get ( 'dock', 'left' )

		if dockArea == 'left':
			dockArea = Qt.LeftDockWidgetArea
		elif dockArea == 'right':
			dockArea = Qt.RightDockWidgetArea
		elif dockArea == 'top':
			dockArea = Qt.TopDockWidgetArea
		elif dockArea == 'bottom':
			dockArea = Qt.BottomDockWidgetArea
		elif dockArea == 'main':
			dockArea = 'center'
		elif dockArea == 'float':
			dockArea = False
		elif dockArea:
			raise Exception ( 'unsupported dock area:%s' % dockArea )

		window = DockWindow ( self )
		# toolWindow = self.toolWindowMgr.addToolWindow( window, self.toolWindowMgr.EmptySpace )
		if title:
			window.setWindowTitle ( title )
		window.setObjectName ( '_dock_' + id )

		window.windowMode = 'dock'
		window.titleBase = title

		if dockOptions.get ( 'allowDock', True ):
			window.setAllowedAreas ( Qt.AllDockWidgetAreas )
		else:
			window.setAllowedAreas ( Qt.NoDockWidgetArea )
			dockArea = None

		if dockArea and dockArea != 'center':
			self.addDockWidget ( dockArea, window )
		elif dockArea == 'center':
			self.setCentralWidget ( window )
			window.setFeatures ( QtGui.QDockWidget.NoDockWidgetFeatures )
			window.hideTitleBar ()
		else:
			window.setFloating ( True )
		# window.setupCustomTitleBar()

		minSize = dockOptions.get ( 'minSize', None )
		if minSize:
			window.setMinimumSize ( *minSize )
		else:
			window.setMinimumSize ( 20, 20 )

		size = dockOptions.get ( 'size', None )
		if size:
			window.resize ( *size )

		if not dockOptions.get ( 'autohide', False ):
			window._useWindowFlags ()

		window.dockOptions = dockOptions

		return window

	def requestToolWindow ( self, id, **option ):
		window = DocumentWindow ( self.centralWidget () )
		title = option.get ( 'title', id )
		area = option.get ( 'area', 'main' )
		#
		# if area == 'left':
		# 	area = QToolWindowAreaReference.Left
		# elif area == 'right':
		# 	area = QToolWindowAreaReference.Right
		# elif area == 'top':
		# 	area = QToolWindowAreaReference.Top
		# elif area == 'bottom':
		# 	area = QToolWindowAreaReference.Bottom
		# elif area == 'htop':
		# 	area = QToolWindowAreaReference.HSplitTop
		# elif area == 'hbottom':
		# 	area = QToolWindowAreaReference.HSplitBottom
		# elif area == 'vleft':
		# 	area = QToolWindowAreaReference.VSplitLeft
		# elif area == 'vright':
		# 	area = QToolWindowAreaReference.VSplitRight
		# elif area == 'main':
		# 	area = QToolWindowAreaReference.Combine
		# elif area == 'float':
		# 	area = QToolWindowAreaReference.Floating
		# elif area:
		# 	raise Exception ( 'unsupported toolwindow area:%s' % area )

		if area == 'last':
			area = ToolWindowManager.LastUsedArea
		elif area == 'new' or area == 'float':
			area = ToolWindowManager.NewFloatingArea
		elif area == 'empty' or area == 'main':
			area = ToolWindowManager.EmptySpace
		elif area == 'none':
			area = ToolWindowManager.NoArea
		# elif area == 'add':
		# 	area = ToolWindowManager.AddTo
		# elif area == 'left':
		# 	area = ToolWindowManager.LeftOf
		# elif area == 'right':
		# 	area = ToolWindowManager.RightOf
		# elif area == 'top':
		# 	area = ToolWindowManager.TopOf
		# elif area == 'bottom':
		# 	area = ToolWindowManager.BottomOf
		elif area:
			raise Exception ( 'unsupported toolwindow area:%s' % area )

		if title:
			window.setWindowTitle ( title )
		window.setObjectName ( '_tool_' + id )

		minSize = option.get ( 'minSize', None )
		if minSize:
			window.setMinimumSize ( *minSize )
		else:
			window.setMinimumSize ( 20, 20 )

		size = option.get ( 'size', None )
		if size:
			window.resize ( *size )

		window.windowMode = 'tool'
		window.titleBase = title
		window.option = option

		self.centralWidget ().addToolWindow ( window, area )
		return window

	def onTabCloseRequested ( self, idx ):
		subwindow = self.centerTabWidget.widget ( idx )
		if subwindow.close ():
			self.centerTabWidget.removeTab ( idx )

	def requestToolBar ( self, name, **options ):
		toolbar = QtWidgets.QToolBar ()
		toolbar.setFloatable ( options.get ( 'floatable', False ) )
		toolbar.setMovable ( options.get ( 'movable', True ) )
		toolbar.setObjectName ( 'toolbar-%s' % name )
		iconSize = options.get ( 'icon_size', self.defaultToolBarIconSize )
		self.addToolBar ( toolbar )
		toolbar.setIconSize ( QtCore.QSize ( iconSize, iconSize ) )
		toolbar._icon_size = iconSize
		return toolbar

	def onDocumentTabChanged ( self, idx ):
		w = self.centerTabWidget.currentWidget ()
		if w: w.setFocus ()


##----------------------------------------------------------------##
class SubWindowMixin:

	def setDocumentName ( self, name ):
		self.documentName = name
		if name:
			title = '%s - %s' % (self.documentName, self.titleBase)
			self.setWindowTitle ( title )
		else:
			self.setWindowTitle ( self.titleBase )

	def setCallbackOnClose ( self, callback ):
		self.callbackOnClose = callback

	def setupUi ( self ):
		self.callbackOnClose = None

		self.container = self.createContainer ()

		self.mainLayout = QtWidgets.QVBoxLayout ( self.container )
		self.mainLayout.setSpacing ( 0 )
		self.mainLayout.setContentsMargins ( 0, 0, 0, 0 )
		self.mainLayout.setObjectName ( 'MainLayout' )

	def createContainer ( self ):
		container = QtWidgets.QWidget ( self )
		self.setWidget ( container )
		return container

	def addWidget ( self, widget, **layoutOption ):
		# widget.setParent(self)
		if layoutOption.get ( 'fixed', False ):
			widget.setSizePolicy (
				QtWidgets.QSizePolicy.Fixed,
				QtWidgets.QSizePolicy.Fixed
			)
		elif layoutOption.get ( 'expanding', True ):
			widget.setSizePolicy (
				QtWidgets.QSizePolicy.Expanding,
				QtWidgets.QSizePolicy.Expanding
			)
		self.mainLayout.addWidget ( widget )
		return widget

	def addWidgetFromFile ( self, uiFile, **layoutOption ):
		form = uic.loadUi ( uiFile )
		return self.addWidget ( form, **layoutOption )

	def moveToCenter ( self ):
		moveWindowToCenter ( self )

	def ensureVisible ( self ):
		restrainWidgetToScreen ( self )

	def onClose ( self ):
		if self.callbackOnClose:
			return self.callbackOnClose ()
		return True


##----------------------------------------------------------------##
class SubWindow ( QMainWindow, SubWindowMixin ):

	def __init__ ( self, parent ):
		super ( SubWindow, self ).__init__ ( parent )
		self.setupUi ()
		self.stayOnTop = False
		self.setFocusPolicy ( Qt.WheelFocus )

	def hideTitleBar ( self ):
		pass

	# emptyTitle=QtWidgets.QWidget()
	# self.setTitleBarWidget(emptyTitle)

	def createContainer ( self ):
		container = QtWidgets.QWidget ( self )
		self.setCentralWidget ( container )
		return container

	def startTimer ( self, fps, trigger ):
		assert (hasattr ( trigger, '__call__' ))
		interval = 1000 / fps
		timer = QtCore.QTimer ( self )
		timer.timeout.connect ( trigger )
		timer.start ( interval )
		return timer

	def focusOutEvent ( self, event ):
		pass

	def focusInEvent ( self, event ):
		pass

	def closeEvent ( self, event ):
		if self.onClose ():
			return super ( SubWindow, self ).closeEvent ( event )
		else:
			event.ignore ()


##----------------------------------------------------------------##
class DocumentWindow ( SubWindow ):

	def __init__ ( self, parent ):
		super ( DocumentWindow, self ).__init__ ( parent )
		self.toolWindowMgr = parent

	def show ( self, *args ):
		if hasattr ( self, "parentWindow" ) and self.parentWindow:
			tab = self.parentWindow.centerTabWidget
			idx = tab.indexOf ( self )
			if idx < 0:
				idx = tab.addTab ( self, self.windowTitle () )
		super ( DocumentWindow, self ).show ( *args )
		if hasattr ( self, "parentWindow" ) and self.parentWindow:
			tab = self.parentWindow.centerTabWidget
			tab.setCurrentIndex ( idx )
		# self.toolWindowMgr.addToolWindow( self, ToolWindowManager.EmptySpace )

	def setWindowTitle ( self, title ):
		super ( DocumentWindow, self ).setWindowTitle ( title )
		if hasattr ( self, "parentWindow" ) and self.parentWindow:
			tabParent = self.parentWindow.centerTabWidget
			idx = tabParent.indexOf ( self )
			tabParent.setTabText ( idx, title )

	def addToolBar ( self ):
		return self.addWidget ( QtWidgets.QToolBar (), expanding = False )


##----------------------------------------------------------------##
class DockWindowTitleBar ( QWidget ):
	"""docstring for DockWindowTitleBar"""

	def __init__ ( self, *args ):
		super ( DockWindowTitleBar, self ).__init__ ( *args )

	def sizeHint ( self ):
		return QtCore.QSize ( 20, 15 )

	def minimumSizeHint ( self ):
		return QtCore.QSize ( 20, 15 )


##----------------------------------------------------------------##
class DockWindow ( QDockWidget, SubWindowMixin ):
	"""docstring for DockWindow"""

	def __init__ ( self, parent ):
		super ( DockWindow, self ).__init__ ( parent )
		self.setupUi ()
		self.setupCustomTitleBar ()
		# self.topLevelChanged.connect( self.onTopLevelChanged )
		font = QtGui.QFont ()
		font.setPointSize ( 11 )
		self.setFont ( font )
		self.topLevel = False
		self.stayOnTop = False

	def setupCustomTitleBar ( self ):
		self.originTitleBar = self.titleBarWidget ()
		self.customTitleBar = DockWindowTitleBar ( self )
		self.customTitleBar = self.originTitleBar
		self.setTitleBarWidget ( self.customTitleBar )
		pass

	def _useWindowFlags ( self ):
		pass

	def setStayOnTop ( self, stayOnTop ):
		self.stayOnTop = stayOnTop
		if stayOnTop and self.topLevel:
			self.setWindowFlags ( Qt.Window | Qt.WindowStaysOnTopHint )

	def hideTitleBar ( self ):
		emptyTitle = QtWidgets.QWidget ()
		self.setTitleBarWidget ( emptyTitle )

	def startTimer ( self, fps, trigger ):
		assert (hasattr ( trigger, '__call__' ))
		interval = 1000 / fps
		timer = QtCore.QTimer ( self )
		timer.timeout.connect ( trigger )
		timer.start ( interval )
		return timer

	def onTopLevelChanged ( self, toplevel ):
		self.topLevel = toplevel
		if toplevel:
			self.setTitleBarWidget ( self.originTitleBar )
			flag = Qt.Window
			if self.stayOnTop:
				flag |= Qt.WindowStaysOnTopHint
			self.setWindowFlags ( flag )
			self.show ()
		else:
			self.setTitleBarWidget ( self.customTitleBar )
			pass

	def addToolBar ( self ):
		return self.addWidget ( QtWidgets.QToolBar (), expanding = False )

	def closeEvent ( self, event ):
		if self.onClose ():
			return super ( DockWindow, self ).closeEvent ( event )
		else:
			event.ignore ()
