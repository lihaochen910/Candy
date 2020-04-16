from PyQt5 import QtCore
from PyQt5.QtCore import QPoint, QRect, qrand, QSize
from PyQt5.QtWidgets import QVBoxLayout, QFrame, QMenu, qApp, QApplication

from qt.controls.QToolWindowManager.QtViewPane import EDockingDirection, ESystemClassID
from qt.controls.QToolWindowManager.SandboxWindowing import QBaseTabPane


def findSubPanes ( pane, paneClassName, result ):
	for subPane in pane.getSubPanes ():
		if subPane.getPaneTitle () == paneClassName:
			result.append ( subPane )
		else:
			findSubPanes ( subPane, paneClassName, result )


class QTabPane ( QBaseTabPane ):

	def __init__ ( self ):
		super ().__init__ ()
		self.viewCreated = False
		self.pane = False

		self.setLayout ( QVBoxLayout () )
		self.setFrameStyle ( QFrame.StyledPanel | QFrame.Plain )
		self.layout ().setContentsMargins ( 0, 0, 0, 0 )
		self.customContextMenuRequested.connect ( self.showContextMenu )
		self.setAttribute ( QtCore.Qt.WA_DeleteOnClose )

	def showContextMenu ( self, point ):
		menu = QMenu ( self )
		menu.addAction ( "Close" ).triggered.connect ( self.close )
		menu.exec_ ( QPoint ( point.x (), point.y () ) )

	def closeEvent ( self, e ):
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

	def __init__ ( self, parent ):
		CTabPaneManager._instance = self
		self.parent = parent
		self.toolsDirty = False
		self.bLayoutLoaded = False
		self.panesHistory = { }
		self.panes = [ ]

	def __del__ ( self ):
		self.closeAllPanes ()
		CTabPaneManager._instance = None

	@staticmethod
	def get ():
		return CTabPaneManager._instance

	def saveLayout ( self ):
		pass

	def loadUserLayout ( self ):
		pass

	def loadLayout ( self, filePath ):
		pass

	def loadDefaultLayout ( self ):
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
		tabPane = self.createTabPane(paneClassName, title, nOverrideDockDirection, False)
		return tabPane if tabPane.pane else None

	def closeAllPanes ( self ):
		needsToDelete = False
		while len ( self.panes ) != 0:
			needsToDelete = True
			it = self.panes[ 0 ]
			it.close ()

		if needsToDelete:
			qApp.processEvents ()

	def findPaneByClass ( self, paneClassName ):
		tabPane = self.findTabPaneByClass ( paneClassName )
		if tabPane:
			return tabPane.pane
		else:
			return None

	def findPaneByTitle ( self, title ):
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

	def findAllPanelsByClass ( self, paneClassName ):
		from qt.controls.QToolWindowManager import CEditorMainWindow
		if not CEditorMainWindow.get ():
			return [ ]
		if not self.getToolManager ():
			return [ ]
		result = [ ]
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

	def openOrCreatePane ( self, paneClassName ):
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

		classDesc = None  # TODO:  IEditorClassFactory
		if not classDesc or classDesc.systemClassID () != ESystemClassID.ESYSTEM_CLASS_VIEWPANE:
			return None

		viewPaneClass = classDesc

		if viewPaneClass.singlePane ():
			for i in range ( 0, len ( self.panes ) ):
				pane = self.panes[ i ]
				if pane.className == paneClassName and pane.viewCreated:
					isToolAlreadyCreated = True
					break

		if not isToolAlreadyCreated:
			pane = QTabPane ()
			pane.setParent ( self.parent )
			self.panes.append ( pane )
			pane.className = paneClassName

		dockDir = EDockingDirection.DOCK_FLOAT

		contentWidget = None

		if not isToolAlreadyCreated:
			contentWidget = self.createPaneContents ( pane )
			if contentWidget:
				if not title:
					title = contentWidget.getPaneTitle ()
				dockDir = contentWidget.getDockingDirection ()
			elif not title:
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
			if contentWidget:
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
			referencePane = self.findTabPaneByTitle ( "Perspective" )
			if referencePane:
				toolArea = self.getToolManager ().areaOf ( referencePane )
				if toolArea:
					toolAreaTarget = QToolWindowAreaTarget.createByArea ( toolArea, toolAreaTarget.reference )
				else:
					toolAreaTarget = QToolWindowAreaTarget ( QToolWindowAreaReference.Floating )

		paneRect = QRect ( 0, 0, 800, 600 )
		if contentWidget:
			paneRect = contentWidget.getPaneRect ()
		if pane.title in self.panesHistory:
			paneHistory = self.panesHistory[ pane.title ]
			paneRect = paneHistory.rect

		maxRc = QRect ()
		minimumSize = QSize ()
		if contentWidget:
			minimumSize = contentWidget.getMinSize ()

		paneRect = paneRect.intersected ( maxRc )

		if paneRect.width () < 10:
			paneRect.setRight ( paneRect.left () + 10 )
		if paneRect.height () < 10:
			paneRect.setBottom ( paneRect.top () + 10 )

		pane.defaultSize = QSize ( paneRect.width (), paneRect.height () )
		pane.minimumSize = minimumSize

		toolPath = { }
		spawnLocationMap = { }  # GetIEditor()->GetPersonalizationManager()->GetState("SpawnLocation")

		if not self.layoutLoaded ():
			toolAreaTarget = QToolWindowAreaTarget ( QToolWindowAreaReference.Hidden )
		else:
			if spawnLocationMap.setdefault ( paneClassName, False ):
				toolPath = spawnLocationMap[ paneClassName ]
				if not toolPath.setdefault ( "geometry", False ):
					t = self.getToolManager ().targetFromPath ( toolPath[ "path" ] )
					if t.reference != QToolWindowAreaReference.Floating:
						toolAreaTarget = t

		self.getToolManager ().addToolWindow ( pane, toolAreaTarget )

		if toolAreaTarget.reference == QToolWindowAreaReference.Floating:
			alreadyPlaced = False
			if toolPath.setdefault ( "geometry", False ):
				alreadyPlaced = pane.window ().restoreGeometry ( toolPath[ "geometry" ] )
			if not alreadyPlaced:
				w = pane
				while not w.isWindow ():
					w = w.parentWidget ()
				i = 0
				w.move ( QPoint ( 32, 32 ) * (i + 1) )
				i = (i + 1) % 10
			self.onTabPaneMoved ( pane, True )

		self.toolsDirty = True

		if pane.pane:
			# from qt.controls.QToolWindowManager.QtViewPane import IPane
			# IPane::s_signalPaneCreated(pPane->m_pane)
			pass

		return pane

	def createObjectName ( self, title ):
		s = title
		result = s
		while self.findTabPaneByName ( result ):
			i = qrand ()
			result = "%s#%d" % (s, i)
		return result

	def getState ( self ):
		stateMap = {}
		for i in range(0, len(self.panes)):
			tool = self.panes[i]
			if self.getToolManager().areaOf(tool):
				toolData = {}
				toolData["class"] = tool.className
				if tool.pane:
					toolData[ "state" ] = tool.pane.getState()
				stateMap[tool.objectName()] == toolData

		from qt.controls.QToolWindowManager import CEditorMainWindow
		mainFrameWindow = CEditorMainWindow.get()
		while mainFrameWindow.parentWidget ():
			mainFrameWindow = mainFrameWindow.parentWidget ()

		mainWindowStateVar = CEditorMainWindow.get().saveState()
		mainWindowGeomVar = mainFrameWindow.saveGeometry()
		toolsLayoutVar = self.getToolManager().saveState()

		state = {
			"MainWindowGeometry": mainWindowStateVar,
			"MainWindowState": mainWindowStateVar,
			"ToolsLayout": toolsLayoutVar,
			"Windows": stateMap
		}
		return state

	def setState ( self, state ):
		notifyLock = self.getToolManager().getNotifyLock(self.layoutLoaded())
		mainWindowStateVar = state.get("MainWindowState")
		mainWindowGeomVar = state.get("MainWindowGeometry")
		toolsLayoutVar = state.get("ToolsLayout")
		openToolsMap = state.get("Windows") or state.get("OpenTools")

		if mainWindowStateVar:
			self.getToolManager().hide()

			if not self.getToolManager().toolWindows():
				self.getToolManager ().clear()

			for key, v in openToolsMap:
				className = v["class"]
				state = v["state"]

				pane = self.createTabPane(className, None)
				if pane:
					pane.setObjectName(key)
					if state and pane.pane:
						pane.pane.setState(state)

			self.getToolManager().restoreState(toolsLayoutVar)

			if self.layoutLoaded():
				from qt.controls.QToolWindowManager import CEditorMainWindow
				CEditorMainWindow.get ().restoreState(mainWindowStateVar)
				return

			from qt.controls.QToolWindowManager import CEditorMainWindow
			mainFrameWindow = CEditorMainWindow.get ()
			while mainFrameWindow.parentWidget():
				mainFrameWindow = mainFrameWindow.parentWidget()

			CEditorMainWindow.get ().restoreState ( mainWindowStateVar )
			mainFrameWindow.restoreGeometry(mainWindowGeomVar)
			if mainFrameWindow.windowState() == QtCore.Qt.WindowMaximized:
				desktop = QApplication.desktop()
				mainFrameWindow.setGeometry(desktop.availableGeometry(mainFrameWindow))

	def createContentInPanes ( self ):
		for i in range ( 0, len ( self.panes ) ):
			tool = self.panes[ i ]
			if not tool.viewCreated:
				self.createPaneContents ( tool )

	def createPaneContents ( self, tool ):
		tool.viewCreated = True

	def storeHistory ( self, tool ):
		paneHistory = SPaneHistory ()
		rc = tool.frameGeometry ()
		p = rc.topLeft ()

		paneHistory.rect = QRect ( p.x (), p.y (), p.x () + rc.width (), p.y () + rc.height () )
		paneHistory.dockDir = 0
		self.panesHistory[ tool.title ] = paneHistory

	def getToolManager ( self ):
		from qt.controls.QToolWindowManager import CEditorMainWindow
		return CEditorMainWindow.get ().getToolManager ()

	def findTabPane ( self, pane ):
		for tabPane in self.panes:
			if tabPane.pane == pane:
				return tabPane
		return None

	def focusTabPane ( self, pane ):
		topMostParent = pane
		parent = topMostParent.parentWidget ()
		while parent:
			topMostParent = parent
			parent = topMostParent.parentWidget ()
		topMostParent.setWindowState ( topMostParent.windowState () & ~QtCore.Qt.WindowMinimized )

		pane.setFocus ()
		pane.activateWindow ()
		self.getToolManager ().bringToFront ( pane )

	def closeTabPane ( self, tool ):
		deleted = self.panes.count ( tool ) != 0
		if tool and deleted:
			index = self.panes.index ( tool )
			del self.panes[ index ]
			self.getToolManager ().releaseToolWindow ( tool, True )
			return True
		return False

	def loadLayoutFromFile ( self, fullFilename ):
		pass

	def findTabPaneByName ( self, name ):
		tools = self.getToolManager ().toolWindows ()
		for tool in tools:
			toolPane = tool
			if toolPane and (not name or name == tool.objectName ()):
				return toolPane
		return None

	def findTabPanes ( self, name ):
		result = [ ]
		tools = self.getToolManager ().toolWindows ()
		for tool in tools:
			toolPane = tool
			if toolPane and (not name or name == tool.objectName ()):
				result.append ( toolPane )
		return result

	def findTabPaneByClass ( self, paneClassName ):
		from qt.controls.QToolWindowManager import CEditorMainWindow
		if not CEditorMainWindow.get ():
			return None
		if not self.getToolManager ():
			return None
		tools = self.findTabPanes ( None )
		for i in range ( 0, tools.count () ):
			tool = tools[ i ]
			if tool.className == paneClassName:
				return tool
		return None

	def findTabPaneByCategory ( self, paneCategory ):
		tools = self.findTabPanes ( None )
		for i in range ( 0, tools.count () ):
			tool = tools[ i ]
			if tool.category == paneCategory:
				return tool
		return None

	def findTabPaneByTitle ( self, title ):
		tools = self.findTabPanes ( None )
		for i in range ( 0, tools.count () ):
			tool = tools[ i ]
			if tool.title == title:
				return tool
		return None


class SPaneHistory:
	def __init__ ( self ):
		self.rect = QRect ()
		self.dockDir = 0
