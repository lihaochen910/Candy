from PyQt5 import QtCore
from PyQt5.QtCore import QPoint, QRect, qrand, QSize, Qt, qWarning
from PyQt5.QtWidgets import QVBoxLayout, QFrame, QMenu, qApp, QApplication, QWidget

from .QtViewPane import EDockingDirection, ESystemClassID


def findSubPanes ( pane, paneClassName, result ):
	for subPane in pane.getSubPanes ():
		if subPane.getPaneTitle () == paneClassName:
			result.append ( subPane )
		else:
			findSubPanes ( subPane, paneClassName, result )


class QPlatformHostPane ( QWidget ):
	""" The QPlatformHostPane class provides an API to use native platform windows in Qt applications.

	You cannot change the parent widget of the QPlatformHostPane instance
    after the native window has been created, i.e. do not call
    QWidget.setParent or move the QPlatformHostPane into a different layout.

	Attributes:
		viewCreated: bool
		pane: IPane
    """

	def __init__ ( self ):
		super ().__init__ ()
		self.hwnd = None
		self.ownHWND = False
		self.defaultSize = QSize ()
		self.minimumSize = QSize ()
		self.setAttribute ( Qt.WA_NoBackground )
		self.setAttribute ( Qt.WA_NoSystemBackground )
		self.setDisabled ( True )

	def setWindow ( self, nativeWindowHandle, bOwnWindow ):
		""" Sets the native window to a window.

			If a window is not a child
		    window of this widget, then it is reparented to become one. If a window
		    is not a child window (i.e. WS_OVERLAPPED is set), then this function does nothing.

			Args:
				nativeWindowHandle: Any
				bOwnWindow: bool

			Returns:
				None
	    """
		if self.hwnd and self.ownHWND:
			# TODO: Destroy native window
			pass
		self.hwnd = nativeWindowHandle
		self.ownHWND = bOwnWindow

	def window ( self ):
		return self.hwnd

	def sizeHint ( self ):
		return self.defaultSize

	def minimumSizeHint ( self ):
		return self.minimumSize


class QBaseTabPane ( QFrame ):
	""" QBaseTabPane and QMFCPaneHost are used to recognize when a widget is :

	1) A qt widget, in this case a specialized QMenu is set based on the IPane GetPaneMenu() function
	2) A LEGACY Mfc widget, in this case a default help menu is set
	This classes are defined here and inherited in other modules, namely Sandbox and MFC.

	Attributes:
		title (string): string
		category: string
		class_: string
		viewCreated: bool
		pane: IPane
		defaultSize: QSize
		minimumSize: QSize
    """

	def __init__ ( self ):
		super ( QBaseTabPane, self ).__init__ ()
		self.title = ''
		self.category = ''
		self.class_ = ''
		self.viewCreated = False
		self.pane = None
		self.defaultSize = QSize ()
		self.minimumSize = QSize ()


class QTabPane ( QBaseTabPane ):
	""" Internal class for IPane management.

	Attributes:
		viewCreated: bool
		pane: IPane
    """

	def __init__ ( self ):
		super ( QTabPane, self ).__init__ ()
		self.viewCreated = False
		self.pane = None

		self.setLayout ( QVBoxLayout () )
		self.setFrameStyle ( QFrame.StyledPanel | QFrame.Plain )
		self.layout ().setContentsMargins ( 0, 0, 0, 0 )
		self.customContextMenuRequested.connect ( self.showContextMenu )
		self.setAttribute ( QtCore.Qt.WA_DeleteOnClose )

	def __del__ ( self ):
		self.cause_a_exception ()

	def showContextMenu ( self, point ):
		menu = QMenu ( self )
		menu.addAction ( "Close" ).triggered.connect ( self.close )
		menu.exec_ ( QPoint ( point.x (), point.y () ) )

	def closeEvent ( self, e ):
		# print ( "[QTabPane] closeEvent", self.pane )
		if self.pane:
			isClosed = self.pane.getWidget ().close ()
			e.setAccepted ( isClosed )
			if isClosed:
				CTabPaneManager.get ().closeTabPane ( self )

		# elif self.mfcWnd:

	def sizeHint ( self ):
		return self.defaultSize

	def minimumSizeHint ( self ):
		return super ().minimumSizeHint ()

	def focusInEvent ( self, e ):
		if self.pane and self.pane.getWidget ():
			widget = self.pane.getWidget ()
			widget.setFocus ()


class CTabPaneManager:
	_instance = None

	def __init__ ( self, parent ):
		CTabPaneManager._instance = self
		self.parent = parent
		self.toolsDirty = False
		self.bLayoutLoaded = False
		self.panesHistory = {}
		self.panes = []

	def __del__ ( self ):
		self.closeAllPanes ()
		CTabPaneManager._instance = None

	@staticmethod
	def get ():
		return CTabPaneManager._instance

	def saveLayout ( self ):
		import yaml
		yaml.dump ( self.getState () )
		pass

	def loadUserLayout ( self ):
		# TODO: loadUserLayout from local
		pass

	def loadLayout ( self, filePath ):
		pass

	def loadDefaultLayout ( self ):
		# TODO: loadDefaultLayout from local
		pass

	def saveLayoutToFile ( self, fullFilename ):
		pass

	def getUserLayouts ( self ):
		pass

	def getProjectLayouts ( self ):
		pass

	def getAppLayouts ( self ):
		pass

	def createPane ( self, paneClassName, title = None, nOverrideDockDirection = -1 ):
		tabPane = self.createTabPane ( paneClassName, title, nOverrideDockDirection, False )
		return tabPane if tabPane.pane else None

	def closeAllPanes ( self ):
		needsToDelete = False
		while len ( self.panes ) != 0:
			needsToDelete = True
			it = self.panes[ 0 ]
			it.close ()

		if needsToDelete:
			qApp.processEvents ()

	def findPaneByClass ( self, paneClassName: str ):
		tabPane = self.findTabPaneByClass ( paneClassName )
		if tabPane:
			return tabPane.pane
		else:
			return None

	def findPaneByTitle ( self, title: str ):
		tabPane = self.findTabPaneByTitle ( title )
		if tabPane:
			return tabPane.pane
		else:
			return None

	def findPane ( self, predicate ):
		tools = self.findTabPanes ( None )
		for i in range ( 0, tools.count () ):
			tool = tools[ i ]
			if tool.pane and predicate ( tool.pane, tool.className ):
				return tool.pane
		return None

	def findAllPanelsByClass ( self, paneClassName: str ):
		from qt.controls.QToolWindowManager import CEditorMainFrame
		if not CEditorMainFrame.get ():
			return []
		if not self.getToolManager ():
			return []
		result = []
		tools = self.findTabPanes ( None )
		for i in range ( 0, tools.count () ):
			tool = tools[ i ]
			if tool.className == paneClassName:
				result.append ( tool.pane )
			elif tool.pane:
				findSubPanes ( tool.pane, paneClassName, result )
		return result

	def bringToFront ( self, pane ):
		tabPane = self.findTabPane ( pane )
		if tabPane:
			self.getToolManager ().bringToFront ( tabPane )

	def openOrCreatePane ( self, paneClassName: str ):
		tool = self.findPaneByClass ( paneClassName )
		if not tool:
			tool = self.createPane ( paneClassName )
		if not tool:
			return None
		self.focusTabPane ( tool )
		return tool.pane

	def onIdle ( self ):
		if self.toolsDirty:
			self.createContentInPanes ()
			self.toolsDirty = False

	def layoutLoaded ( self ):
		self.bLayoutLoaded = True

	def onTabPaneMoved ( self, tabPane, visible ):
		if visible:
			# TODO: save Personalization State
			pass

	def createTabPane ( self, paneClassName, title = None, nOverrideDockDirection = -1,
	                    bLoadLayoutPersonalization = False ):
		pane = None
		isToolAlreadyCreated = False

		from candy_editor.qt.controls.EditorCommon.IEditor import getIEditor
		classDesc = getIEditor ().getClassFactory ().findClass ( paneClassName )
		if classDesc is None or classDesc.systemClassID () != ESystemClassID.ESYSTEM_CLASS_VIEWPANE:
			qWarning ( "CTabPaneManager::createTabPane return None %s pane class not found." % paneClassName )
			return None

		viewPaneClass = classDesc

		if viewPaneClass.singlePane ():
			for i in range ( 0, len ( self.panes ) ):
				pane = self.panes[ i ]
				if pane.class_ == paneClassName and pane.viewCreated:
					isToolAlreadyCreated = True
					break

		if not isToolAlreadyCreated:
			# print ( "CTabPaneManager.createTabPane create QTabPane for", paneClassName )
			pane = QTabPane ()
			pane.setParent ( self.parent )
			pane.class_ = paneClassName
			self.panes.append ( pane )

		dockDir = EDockingDirection.DOCK_FLOAT

		contentWidget = None

		if not isToolAlreadyCreated:
			contentWidget = self.createPaneContents ( pane )
			if contentWidget != None:
				if title == None:
					title = contentWidget.getPaneTitle ()
				dockDir = contentWidget.getDockingDirection ()
			elif title == None:
				title = viewPaneClass.getPaneTitle ()

			pane.title = title
			pane.setObjectName ( self.createObjectName ( title ) )
			pane.setWindowTitle ( title )
			pane.category = viewPaneClass.category ()

			if contentWidget:
				contentWidget.initialize ()
				if bLoadLayoutPersonalization:
					contentWidget.loadLayoutPersonalization ()
		else:
			contentWidget = pane.pane
			if contentWidget != None:
				dockDir = contentWidget.getDockingDirection ()

		bDockDirection = False

		from qt.controls.QToolWindowManager import QToolWindowAreaReference, QToolWindowAreaTarget
		toolAreaTarget = QToolWindowAreaTarget ( QToolWindowAreaReference.Floating )

		if nOverrideDockDirection != -1:
			dockDir = nOverrideDockDirection

		if dockDir == EDockingDirection.DOCK_DEFAULT:
			toolAreaTarget = QToolWindowAreaTarget ( QToolWindowAreaReference.Floating )
		elif dockDir == EDockingDirection.DOCK_TOP:
			toolAreaTarget = QToolWindowAreaTarget ( QToolWindowAreaReference.HSplitTop )
			bDockDirection = True
		elif dockDir == EDockingDirection.DOCK_BOTTOM:
			toolAreaTarget = QToolWindowAreaTarget ( QToolWindowAreaReference.HSplitBottom )
			bDockDirection = True
		elif dockDir == EDockingDirection.DOCK_LEFT:
			toolAreaTarget = QToolWindowAreaTarget ( QToolWindowAreaReference.VSplitLeft )
			bDockDirection = True
		elif dockDir == EDockingDirection.DOCK_RIGHT:
			toolAreaTarget = QToolWindowAreaTarget ( QToolWindowAreaReference.VSplitRight )
			bDockDirection = True
		elif dockDir == EDockingDirection.DOCK_FLOAT:
			toolAreaTarget = QToolWindowAreaTarget ( QToolWindowAreaReference.Floating )

		if bDockDirection:
			referencePane = self.findTabPaneByTitle ( "Perspective" ) # FIXME: No Perspective Pane
			if referencePane != None:
				toolArea = self.getToolManager ().areaOf ( referencePane )
				if toolArea != None:
					toolAreaTarget = QToolWindowAreaTarget.createByArea ( toolArea, toolAreaTarget.reference )
				else:
					toolAreaTarget = QToolWindowAreaTarget ( QToolWindowAreaReference.Floating )

		paneRect = QRect ( 0, 0, 800, 600 )
		if contentWidget != None:
			paneRect = contentWidget.getPaneRect ()
		if pane.title in self.panesHistory:
			paneHistory = self.panesHistory[ pane.title ]
			paneRect = paneHistory.rect

		maxRc = qApp.desktop ().screenGeometry ()

		minimumSize = QSize ()
		if contentWidget != None:
			minimumSize = contentWidget.getMinSize ()

		paneRect = paneRect.intersected ( maxRc )

		if paneRect.width () < 10:
			paneRect.setRight ( paneRect.left () + 10 )
		if paneRect.height () < 10:
			paneRect.setBottom ( paneRect.top () + 10 )

		pane.defaultSize = QSize ( paneRect.width (), paneRect.height () )
		pane.minimumSize = minimumSize

		toolPath = {}
		spawnLocationMap = {}  # GetIEditor()->GetPersonalizationManager()->GetState("SpawnLocation")

		if not self.bLayoutLoaded:
			toolAreaTarget = QToolWindowAreaTarget ( QToolWindowAreaReference.Hidden )
		else:
			if spawnLocationMap.setdefault ( paneClassName, False ):
				toolPath = spawnLocationMap[ paneClassName ]
				if not toolPath.setdefault ( "geometry", False ):
					t = self.getToolManager ().targetFromPath ( toolPath[ "path" ] )
					if t.reference != QToolWindowAreaReference.Floating:
						toolAreaTarget = t

		self.getToolManager ().addToolWindowTarget ( pane, toolAreaTarget )

		if toolAreaTarget.reference == QToolWindowAreaReference.Floating:
			alreadyPlaced = False
			if toolPath.setdefault ( "geometry", False ):
				alreadyPlaced = pane.window ().restoreGeometry ( toolPath[ "geometry" ] )
			if not alreadyPlaced:
				w = pane
				while not w.isWindow ():
					w = w.parentWidget ()
				i = 0
				w.move ( QPoint ( 32, 32 ) * ( i + 1 ) )
				i = ( i + 1 ) % 10
			self.onTabPaneMoved ( pane, True )

		self.toolsDirty = True

		if pane.pane != None:
			# from qt.controls.QToolWindowManager.QtViewPane import IPane
			pane.pane.signalPaneCreated.emit ( pane.pane )

		return pane

	def createObjectName ( self, title: str ) -> str:
		s = title
		result = s
		while self.findTabPaneByName ( result ):
			i = qrand ()
			result = "%s#%d" % (s, i)
		return result

	def getState ( self ):
		stateMap = {}
		for i in range ( 0, len ( self.panes ) ):
			tool = self.panes[ i ]
			if self.getToolManager ().areaOf ( tool ):
				toolData = {}
				toolData[ "class" ] = tool.className
				if tool.pane:
					toolData[ "state" ] = tool.pane.getState ()
				stateMap[ tool.objectName () ] == toolData

		from qt.controls.QToolWindowManager import CEditorMainFrame
		mainFrameWindow = CEditorMainFrame.get ()
		while mainFrameWindow.parentWidget ():
			mainFrameWindow = mainFrameWindow.parentWidget ()

		mainWindowStateVar = CEditorMainFrame.get ().saveState ()
		mainWindowGeomVar = mainFrameWindow.saveGeometry ()
		toolsLayoutVar = self.getToolManager ().saveState ()

		state = {
			"MainWindowGeometry": mainWindowStateVar,
			"MainWindowState": mainWindowStateVar,
			"ToolsLayout": toolsLayoutVar,
			"Windows": stateMap
		}
		return state

	def setState ( self, state ):
		notifyLock = self.getToolManager ().getNotifyLock ( self.layoutLoaded () )
		mainWindowStateVar = state.get ( "MainWindowState" )
		mainWindowGeomVar = state.get ( "MainWindowGeometry" )
		toolsLayoutVar = state.get ( "ToolsLayout" )
		openToolsMap = state.get ( "Windows" ) or state.get ( "OpenTools" )

		if mainWindowStateVar:
			self.getToolManager ().hide ()

			if not self.getToolManager ().toolWindows ():
				self.getToolManager ().clear ()

			for key, v in openToolsMap:
				className = v[ "class" ]
				state = v[ "state" ]

				pane = self.createTabPane ( className, None )
				if pane:
					pane.setObjectName ( key )
					if state and pane.pane:
						pane.pane.setState ( state )

			self.getToolManager ().restoreState ( toolsLayoutVar )

			if self.layoutLoaded ():
				from qt.controls.QToolWindowManager import CEditorMainFrame
				CEditorMainFrame.get ().restoreState ( mainWindowStateVar )
				return

			from qt.controls.QToolWindowManager import CEditorMainFrame
			mainFrameWindow = CEditorMainFrame.get ()
			while mainFrameWindow.parentWidget ():
				mainFrameWindow = mainFrameWindow.parentWidget ()

			CEditorMainFrame.get ().restoreState ( mainWindowStateVar )
			mainFrameWindow.restoreGeometry ( mainWindowGeomVar )
			if mainFrameWindow.windowState () == QtCore.Qt.WindowMaximized:
				desktop = QApplication.desktop ()
				mainFrameWindow.setGeometry ( desktop.availableGeometry ( mainFrameWindow ) )

	def createContentInPanes ( self ):
		for i in range ( 0, len ( self.panes ) ):
			tool = self.panes[ i ]
			if not tool.viewCreated:
				self.createPaneContents ( tool )

	def createPaneContents ( self, tool: QTabPane ):
		""" Create QTabPane Contents

			Args:
				tool (QTabPane)

			Returns:
				CEditor
	    """
		tool.viewCreated = True

		from qt.controls.EditorCommon.IEditor import getIEditor
		classDesc = getIEditor ().getClassFactory ().findClass ( tool.class_ )
		if classDesc == None or classDesc.systemClassID () != ESystemClassID.ESYSTEM_CLASS_VIEWPANE:
			qWarning ( "QToolTabManager.createPaneContents ClassDesc not found %s" % tool.class_ )
			return None

		pane = classDesc.createPane ()

		if pane != None:
			contentWidget = pane.getWidget ()
			tool.layout ().addWidget ( contentWidget )
			tool.pane = pane

			print ( "[QToolTabManager] createPaneContents tool: %s tool.pane: %s contentWidget: %s" % ( tool, tool.pane, contentWidget ) )

			contentWidget.windowTitleChanged.connect ( tool.setWindowTitle )
			contentWidget.windowIconChanged.connect ( tool.setWindowIcon )

		else:
			# TODO: QWinHostPane platform native window
			hostWidget = QPlatformHostPane ()
			qWarning ( 'QToolTabManager.createPaneContents native host window not impl.' )
			pass

		return pane

	def storeHistory ( self, tool ):
		paneHistory = SPaneHistory ()
		rc = tool.frameGeometry ()
		p = rc.topLeft ()

		paneHistory.rect = QRect ( p.x (), p.y (), p.x () + rc.width (), p.y () + rc.height () )
		paneHistory.dockDir = 0
		self.panesHistory[ tool.title ] = paneHistory

	def getToolManager ( self ):
		""" Get QToolWindowManager

			Returns:
				QToolWindowManager
	    """
		from qt.controls.QToolWindowManager import CEditorMainFrame
		return CEditorMainFrame.get ().getToolManager ()

	def findTabPane ( self, pane ):
		""" Get QToolWindowManager

			Args:
				pane (CEditor)

			Returns:
				QTabPane
	    """
		for tabPane in self.panes:
			if tabPane.pane == pane:
				return tabPane
		return None

	def focusTabPane ( self, pane ):
		topMostParent = pane

		parent = topMostParent.parentWidget ()
		while parent != None:
			topMostParent = parent
			parent = topMostParent.parentWidget ()

		topMostParent.setWindowState ( ( topMostParent.windowState () & ~QtCore.Qt.WindowMinimized ) | Qt.WindowActive )

		pane.setFocus ()
		pane.activateWindow ()
		self.getToolManager ().bringToFront ( pane )

	def closeTabPane ( self, tool ) -> bool:
		deleted = self.panes.count ( tool ) != 0
		if tool != None and deleted:
			index = self.panes.index ( tool )
			self.getToolManager ().releaseToolWindow ( tool, True )
			del self.panes[ index ]
			return True
		return False

	def loadLayoutFromFile ( self, fullFilename ):
		pass

	def findTabPaneByName ( self, name: str ):
		tools = self.getToolManager ().toolWindows
		for tool in tools:
			toolPane = tool
			if toolPane != None and (not name or name == tool.objectName ()):
				return toolPane
		return None

	def findTabPanes ( self, name: str ):
		result = []
		tools = self.getToolManager ().toolWindows
		for tool in tools:
			toolPane = tool
			if toolPane != None and (not name or name == tool.objectName ()):
				result.append ( toolPane )
		return result

	def findTabPaneByClass ( self, paneClassName: str ):
		from qt.controls.QToolWindowManager import CEditorMainFrame
		if not CEditorMainFrame.get ():
			return None
		if not self.getToolManager ():
			return None
		tools = self.findTabPanes ( None )
		for i in range ( 0, len ( tools ) ):
			tool = tools[ i ]
			if tool.className == paneClassName:
				return tool
		return None

	def findTabPaneByCategory ( self, paneCategory: str ):
		tools = self.findTabPanes ( None )
		for i in range ( 0, len ( tools ) ):
			tool = tools[ i ]
			if tool.category == paneCategory:
				return tool
		return None

	def findTabPaneByTitle ( self, title: str ):
		tools = self.findTabPanes ( None )
		for i in range ( 0, len ( tools ) ):
			tool = tools[ i ]
			if tool.title == title:
				return tool
		return None


class SPaneHistory:
	def __init__ ( self ):
		self.rect = QRect ()
		self.dockDir = 0
