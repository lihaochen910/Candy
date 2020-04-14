from PyQt5 import Qt, QtCore, QtWidgets
from PyQt5.QtCore import QPoint, QRect
from PyQt5.QtGui import QIcon, QPixmap, QPainter, QMouseEvent, QCursor
from PyQt5.QtWidgets import QLabel, QFrame, QTabWidget, QGridLayout, QPushButton, QSpacerItem, \
	QStyleOptionToolBar, QTabBar, QMenu, QAction
from qt.controls.QToolWindowManager.IToolWindowArea import *
from qt.controls.QToolWindowManager.QToolWindowManagerCommon import *
from qt.controls.QToolWindowManager.QToolWindowTabBar import QToolWindowTabBar


class QToolWindowSingleTabAreaFrame ( QFrame ):
	area = None
	reference = None
	index = 0
	geometry = QtCore.QRect ()

	def __init__ ( self, manager, parent ):
		super ().__init__ ( parent )
		self.layout = QGridLayout ( self )
		self.manager = manager
		self.closeButton = None
		self.caption = QLabel ( self )
		self.contents = None

		self.layout.setContentsMargins ( 0, 0, 0, 0 )
		self.layout.setSpacing ( 0 )

		self.caption.setAttribute ( QtCore.Qt.WA_TransparentForMouseEvents )
		self.caption.setSizePolicy ( Qt.QSizePolicy.Expanding, Qt.QSizePolicy.Expanding )

		self.layout.addWidget ( self.caption, 0, 0 )

		if self.manager.config.get ( QTWM_AREA_TABS_CLOSABLE ) or False:
			self.closeButton = QPushButton ( self )
			self.closeButton.setObjectName ( "closeButton" )
			self.closeButton.setFocusPolicy ( QtCore.Qt.NoFocus )
			self.closeButton.setIcon ( QtCore.Qt.NoFocus )
			self.closeButton.clicked.connect ( self.closeWidget )
			self.layout.addWidget ( self.closeButton, 0, 2 )
		else:
			self.layout.addItem ( QSpacerItem ( 0, 23, Qt.QSizePolicy.Minimum, Qt.QSizePolicy.Expanding ), 0, 1 )

		self.windowTitleChanged.connect ( self.caption.setText )
		self.layout.setColumnMinimumWidth ( 0, 1 )
		self.layout.setRowStretch ( 1, 1 )

	def __del__ ( self ):
		pass

	def setContents ( self, widget ):
		if self.contents:
			self.layout.removeWidget ( self.contents )
		if widget:
			self.layout.addWidget ( widget, 1, 0, 1, 2 )
			widget.show ()
			self.setObjectName ( widget.objectName () )
			self.setWindowIcon ( widget.windowIcon () )
			self.setWindowTitle ( widget.windowTitle () )
			widget.windowTitleChanged.connect ( self.setWindowTitle )
			widget.windowIconChanged.connect ( self.setWindowIcon )
		self.contents = widget

	def setCloseButtonVisible ( self, bVisible ):
		if bVisible:
			self.closeButton.setIcon ( self.getCloseButtonIcon () )
			self.closeButton.blockSignals ( False )
		else:
			self.closeButton.setIcon ( QIcon () )
			self.closeButton.blockSignals ( True )

	def closeWidget ( self ):
		self.manager.releaseToolWindow ( self.contents, True )

	def closeEvent ( self, e ):
		if self.contents:
			e.setAccepted ( self.contents.close () )
			if e.isAccepted ():
				self.closeWidget ()

	def getCloseButtonIcon ( self ):
		return getIcon ( self.manager.config, QTWM_SINGLE_TAB_FRAME_CLOSE_ICON,
		                 QIcon ( ":/QtDockLibrary/gfx/close.png" ) )


class QToolWindowArea ( QTabWidget, IToolWindowArea ):
	area = None
	reference = None
	index = 0
	geometry = QtCore.QRect ()

	def __init__ ( self, manager, parent = None ):
		super(QToolWindowArea, self).__init__(parent)
		self.manager = manager
		self.tabDragCanStart = False
		self.areaDragCanStart = False
		self.setTabBar ( QToolWindowTabBar ( self ) )
		self.setMovable ( True )
		self.setTabShape ( QTabWidget.Rounded )
		self.setDocumentMode ( self.manager.config.get ( QTWM_AREA_DOCUMENT_MODE ) or True )
		self.useCustomTabCloseButton = self.manager.config.get ( QTWM_AREA_TABS_CLOSABLE ) or False
		self.setTabsClosable (
			self.manager.config.get ( QTWM_AREA_TABS_CLOSABLE ) or False and not self.useCustomTabCloseButton )
		self.setTabPosition ( self.manager.config.get ( QTWM_AREA_TAB_POSITION ) or QTabWidget.North )

		self.tabBar ().setSizePolicy ( Qt.QSizePolicy.Expanding, Qt.QSizePolicy.Preferred )
		self.setFocusPolicy ( QtCore.Qt.StrongFocus )

		areaUseImageHandle = self.manager.config.get ( QTWM_AREA_IMAGE_HANDLE ) or False
		self.tabFrame = QToolWindowSingleTabAreaFrame ( manager, self )
		self.tabFrame.hide ()

		if self.manager.config.setdefault(QTWM_AREA_SHOW_DRAG_HANDLE, False):
			corner = QLabel ( self )
			corner.setSizePolicy ( Qt.QSizePolicy.Preferred, Qt.QSizePolicy.Expanding )
			corner.setAttribute ( QtCore.Qt.WA_TranslucentBackground )
			self.setCornerWidget ( corner )
			if areaUseImageHandle:
				corner_img = QPixmap ()
				corner_img.load (
					self.manager.config.setdefault(QTWM_DROPTARGET_COMBINE, ":/QtDockLibrary/gfx/drag_handle.png"))
				corner.setPixmap ( corner_img )
			else:
				corner.setFixedHeight ( 8 )
				corner_img = QPixmap ( corner.size () )
				corner_img.fill ( QtCore.Qt.transparent )

				option = QStyleOptionToolBar ()
				option.initFrom ( self.tabBar () )
				option.state |= Qt.QStyle.State_Horizontal
				option.lineWidth = self.tabBar ().style ().pixelMetric ( Qt.QStyle.PM_ToolBarFrameWidth, 0,
				                                                         self.tabBar () )
				option.features = QStyleOptionToolBar.Movable
				option.toolBarArea = QtCore.Qt.NoToolBarArea
				option.direction = QtCore.Qt.RightToLeft
				option.rect = corner_img.rect ()
				option.rect.moveTo ( 0, 0 )

				painter = QPainter ( corner_img )
				self.tabBar ().style ().drawPrimitive ( Qt.QStyle.PE_IndicatorToolBarHandle, option, painter, corner )
				corner.setPixmap ( corner_img )
			corner.setCursor ( QtCore.Qt.OpenHandCursor )
			corner.installEventFilter ( self )

		self.tabBar ().installEventFilter ( self )
		self.tabFrame.installEventFilter ( self )
		self.tabFrame.caption.installEventFilter ( self )

		self.tabBar ().setContextMenuPolicy ( QtCore.Qt.CustomContextMenu )
		self.setContextMenuPolicy ( QtCore.Qt.CustomContextMenu )
		self.customContextMenuRequested.connect ( self.showContextMenu )
		self.tabBar ().customContextMenuRequested.connect ( self.showContextMenu )
		self.tabBar ().tabCloseRequested.connect ( self.closeTab )

	def __del__ ( self ):
		if self.manager:
			self.manager.removeArea ( self )
			self.manager = None

	def addToolWindow ( self, toolWindow, index = -1 ):
		self.addToolWindows ( [ toolWindow ], index )

	def addToolWindows ( self, toolWindows, index = -1 ):
		newIndex = index
		for toolWindow in toolWindows:
			if self.manager.config.setdefault( QTWM_AREA_TAB_ICONS , False):
				if index < 0:
					newIndex = self.addTab ( toolWindow, toolWindow.windowIcon (), toolWindow.windowTitle () )
				else:
					newIndex = self.insertTab ( newIndex, toolWindow, toolWindow.windowIcon (),
					                            toolWindow.windowTitle () )
			else:
				if index < 0:
					newIndex = self.addTab ( toolWindow, toolWindow.windowTitle () )
				else:
					newIndex = self.insertTab ( newIndex, toolWindow, toolWindow.windowIcon (),
					                            toolWindow.windowTitle () ) + 1

			if self.useCustomTabCloseButton:
				self.tabBar ().setTabButton ( newIndex, QTabBar.RightSide, self.createCloseButton () )

			def onWindowTitleChanged ( title ):
				index = self.indexOf ( toolWindow )
				if index >= 0:
					self.setTabText ( index, title )
				if self.count () == 1:
					self.setWindowTitle ( title )

			def onWindowIconChanged ( icon ):
				index = self.indexOf ( toolWindow )
				if index >= 0:
					self.setTabIcon ( index, icon )
				if self.count () == 1:
					self.setWindowIcon ( icon )

			toolWindow.windowTitleChanged.connect ( onWindowTitleChanged )
			toolWindow.windowIconChanged.connect ( onWindowIconChanged )

		self.setCurrentWidget ( toolWindows[ 0 ] )

	def removeToolWindow ( self, toolWindow ):
		toolWindow.disconnect ( self )
		i = self.indexOf ( toolWindow )
		if i != -1:
			self.removeTab ( i )
		elif self.tabFrame.contents == toolWindow:
			i = self.indexOf ( self.tabFrame )
			if i != -1:
				self.removeTab ( i )
			self.tabFrame.setContents ( None )

	def toolWindows ( self ):
		result = [ ]
		for i in range ( 0, self.count () ):
			w = self.width ( i )
			if w == self.tabFrame:
				w = self.tabFrame.contents
			result.append ( w )
		return result

	def saveState ( self ):
		result = { }
		result[ "type" ] = "area"
		result[ "currentIndex" ] = self.currentIndex ()
		objectNames = [ ]
		for i in range ( 0, self.count () ):
			name = self.width ( i ).objectName ()
			if not name:
				print ( "cannot save state of tool window without object name" )
			else:
				objectNames.append ( name )
		result[ "objectNames" ] = objectNames
		return result

	def restoreState ( self, data, stateFormat ):
		for objectNameValue in data[ "objectNames" ]:
			objectName = objectNameValue
			if not objectName:
				continue
			found = False
			for toolWindow in self.manager.toolWindows:
				if toolWindow.objectName == objectName:
					self.addToolWindow ( toolWindow )
					found = True
					break
			if not found:
				print ( "tool window with name '%s' not found" % objectName )

		self.setCurrentIndex ( data[ "currentIndex" ] )

	def adjustDragVisuals ( self ):
		if self.manager.config.setdefault(QTWM_SINGLE_TAB_FRAME,True):
			self.tabBar ().setAutoHide ( True )
			showTabFrame = self.shouldShowSingleTabFrame ()

			if showTabFrame and self.indexOf ( self.tabFrame ) == -1:
				w = self.width ( 0 )
				self.removeToolWindow ( w )
				self.tabFrame.setContents ( w )
				self.addToolWindow ( self.tabFrame )
			elif not showTabFrame and self.indexOf ( self.tabFrame ) != -1:
				w = self.tabFrame.contents
				self.tabFrame.setContents ( None )
				self.addToolWindow ( w, self.indexOf ( self.tabFrame ) )
				self.removeToolWindow ( self.tabFrame )

		if self.manager.isMainWrapper ( self.parentWidget () ) and self.count () > 1 and self.manager.config[
			QTWM_AREA_SHOW_DRAG_HANDLE ] or False:
			self.cornerWidget ().show ()

		bMainWidget = self.manager.isMainWrapper ( self.parentWidget () )
		if self.manager.config.setdefault(QTWM_SINGLE_TAB_FRAME,True) and self.count() == 1 and self.manager.config[
			QTWM_AREA_TABS_CLOSABLE ] or False:
			self.tabFrame.setCloseButtonVisible ( not bMainWidget )
		elif bMainWidget and self.count () == 1:
			if self.useCustomTabCloseButton:
				self.tabBar ().setTabButton ( 0, QTabBar.RightSide, None )
			else:
				self.setTabsClosable ( False )
		elif self.useCustomTabCloseButton:
			for i in range ( 0, self.tabBar ().count () ):
				if not self.tabBar ().tabButton ( i, QTabBar.RightSide ):
					self.tabBar ().setTabButton ( i, QTabBar.RightSide, self.createCloseButton () )

		else:
			self.setTabsClosable ( self.manager.config.setdefault( QTWM_AREA_TABS_CLOSABLE, False) )

		if self.manager.config.setdefault(QTWM_RETITLE_WRAPPER,True) and self.manager.isFloatingWrapper(
				self.parentWidget () ) and self.count () == 1:
			w = self.wrapper ()
			if w:
				w.getWidget ().setWindowTitle ( self.width ( 0 ).windowTitle () )
		else:
			w = self.wrapper ()
			if w:
				w.getWidget ().setWindowTitle ( QCoreApplication.applicationName () )

	def getWidget ( self ):
		return self

	def switchAutoHide ( self, newValue ):
		result = self.tabBar ().autoHide ()
		self.tabBar ().setAutoHide ( newValue )
		return result

	def tabBar ( self ):
		return QTabWidget.tabBar ( self )

	def palette ( self ):
		return QTabWidget.palette ( self )

	def clear ( self ):
		QTabWidget.clear ( self )

	def rect ( self ):
		return QTabWidget.rect ( self )

	def size ( self ):
		return QTabWidget.size ( self )

	def count ( self ):
		return QTabWidget.count ( self )

	def widget ( self, index ):
		return QTabWidget.widget ( self, index )

	def deleteLater ( self, index ):
		QTabWidget.deleteLater ( self )

	def width ( self ):
		return QTabWidget.width ( self )

	def height ( self ):
		return QTabWidget.height ( self )

	def geometry ( self ):
		return QTabWidget.geometry ( self )

	def hide ( self ):
		QTabWidget.hide ( self )

	def parent ( self ):
		return QTabWidget.parent ( self )

	def setParent ( self, parent ):
		QTabWidget.setParent ( self, parent )

	def indexOf ( self, w ):
		if w == self.tabFrame.contents:
			w = self.tabFrame.contents
		return super ().indexOf ( w )

	def parentWidget ( self ):
		return QTabWidget.parentWidget ( self )

	def mapFromGlobal ( self, pos ):
		return QTabWidget.mapFromGlobal ( self, pos )

	def mapToGlobal ( self, pos ):
		return QTabWidget.mapToGlobal ( self )

	def setCurrentWidget ( self, w ):
		if w == self.tabFrame.contents:
			super ().setCurrentWidget ( self.tabFrame )
		return super ().setCurrentWidget ( w )

	def mapCombineDropAreaFromGlobal ( self, pos ):
		self.tabBar ().mapFromGlobal ( pos )

	def combineAreaRect ( self ):
		if self.widget ( 0 ) == self.tabFrame:
			return self.tabFrame.caption.rect ()
		if self.tabPosition () == QTabWidget.West or \
				self.tabPosition () == QTabWidget.East:
			return QRect ( 0, 0, self.tabBar ().width (), self.height () )
		elif self.tabPosition () == QTabWidget.North or \
				self.tabPosition () == QTabWidget.South:
			return QRect ( 0, 0, self.width (), self.tabBar ().height () )
		return QRect ( 0, 0, self.width (), self.tabBar ().height () )

	def combineSubWidgetRect ( self, index ):
		pass

	def subWidgetAt ( self, pos ):
		pass

	def areaType ( self ):
		pass

	def eventFilter ( self, o, e ):
		if o == self.tabBar () or o == self.cornerWidget () or o == self.tabFrame or o == self.tabFrame.caption:
			if e.type () == Qt.QEvent.MouseButtonPress:
				self.areaDragCanStart = False
				self.tabDragCanStart = False

				if (o == self.tabFrame and self.tabFrame.caption.rect ().contains (
						e.pos () )) or o == self.tabFrame.caption or (
						o == self.tabBar () and self.tabBar ().tabAt ( e.pos () ) >= 0):
					self.tabDragCanStart = True
				elif self.manager.config.setdefault(QTWM_AREA_SHOW_DRAG_HANDLE,False) and (
						o == self.cornerWidget () or (o == self.tabBar () and self.cornerWidget ().isVisible ()) and
						self.manager.config.setdefault( QTWM_AREA_EMPTY_SPACE_DRAG,False)):
					self.tabDragCanStart = True

				if self.manager.isMainWrapper ( self.parentWidget () ):
					self.areaDragCanStart = False
					if self.count () == 1:
						self.tabDragCanStart = False
			elif e.type () == Qt.QEvent.MouseMove:
				if self.tabDragCanStart:
					if self.tabBar ().rect ().contains ( e.pos () ) or (self.manager.config[
						                                                    QTWM_AREA_SHOW_DRAG_HANDLE ] or False and self.cornerWidget ().rect ().contains (
							e.pos () )):
						return False
					if not e.buttons () & QtCore.Qt.LeftButton:
						return False
					toolWindow = self.currentWidget ()
					if toolWindow == self.tabFrame:
						toolWindow = self.tabFrame.contents
					if not toolWindow:
						return False
					self.tabDragCanStart = False
					releaseEvent = QMouseEvent ( Qt.QEvent.MouseButtonRelease, e.pos (), QtCore.Qt.LeftButton,
					                             QtCore.Qt.LeftButton, 0 )
					qApp ().sendEvent ( self.tabBar (), releaseEvent )
					self.manager.startDrag ( [ toolWindow ], self )
					self.releaseMouse ()
				elif self.areaDragCanStart:
					if e.buttons () & QtCore.Qt.LeftButton and not (self.manager.config[
						                                                QTWM_AREA_SHOW_DRAG_HANDLE ] or False and self.cornerWidget ().rect ().contains (
							self.mapFromGlobal ( QCursor.pos () ) )):
						toolWindows = [ ]
						for i in range ( 0, self.count () ):
							toolWindow = self.width ( i )
							if toolWindow == self.tabFrame:
								toolWindow = self.tabFrame.contents
							toolWindows.append ( toolWindow )
						self.areaDragCanStart = False
						releaseEvent = QMouseEvent ( Qt.QEvent.MouseButtonRelease, e.pos (), QtCore.Qt.LeftButton,
						                             QtCore.Qt.LeftButton, 0 )
						if self.cornerWidget ():
							qApp ().sendEvent ( self.cornerWidget (), releaseEvent )
						self.manager.startDrag ( toolWindows, self )
						self.releaseMouse ()

		return super ().eventFilter ( o, e )

	def shouldShowSingleTabFrame ( self ):
		if self.manager.config.setdefault(QTWM_SINGLE_TAB_FRAME,True):
			return False
		c = self.count ()
		if c != 1:
			return False

		if self.manager.isFloatingWrapper ( self.parentWidget () ):
			return False

		return True

	def event ( self, event ):
		if self.areaDragCanStart and event.type () == Qt.QEvent.MouseButtonRelease and not self.manager.config[
			QTWM_AREA_SHOW_DRAG_HANDLE ] or False:
			floatingWrapper = False
			wrapper = self.wrapper ()
			if wrapper and self.manager.isFloatingWrapper ( wrapper.getWidget () ):
				floatingWrapper = True

			if not floatingWrapper and self.currentWidget () and not self.currentWidget ().rect ().contains (
					self.currentWidget ().mapFromGlobal ( QCursor.pos () ) ):
				self.areaDragCanStart = True
		elif event.type() == Qt.QEvent.MouseMove and not self.manager.config.setdefault(QTWM_AREA_SHOW_DRAG_HANDLE,False):
			if self.areaDragCanStart:
				if event.buttons () & QtCore.Qt.LeftButton:
					toolWindows = [ ]
					for i in range ( 0, self.count () ):
						toolWindow = self.widget ( i )
						if toolWindow == self.tabFrame:
							toolWindow = self.tabFrame.contents
						toolWindows.append ( toolWindow )
					self.areaDragCanStart = False
					self.manager.startDrag ( toolWindow, self )
					self.releaseMouse ()

		return super ().event ( event )

	def tabCloseButtonClicked ( self ):
		index = -1
		o = self.sender ()
		for i in range ( 0, self.count () ):
			if o == self.tabBar ().tabButton ( i, QTabBar.RightSide ):
				index = i

		if index != -1:
			self.tabBar ().tabCloseRequested ( index )

	def closeTab ( self, index ):
		self.manager.releaseToolWindow ( self.widget ( index ), True )

	def showContextMenu ( self, point ):
		if point.isNull () or (self.manager.isMainWrapper ( self.parentWidget () ) and self.tabBar ().count () <= 1):
			return

		singleTabFrame = self.currentWidget ()

		if singleTabFrame and singleTabFrame.caption and singleTabFrame.caption.contentsRect ().contains (
				point ) and not self.manager.isMainWrapper ( self.parentWidget () ):
			menu = QMenu ( self )
			menu.addAction ( "Close" ).triggered.connect ( lambda self, singleTabFrame: singleTabFrame.close () )
			menu.exec ( self.mapToGlobal ( QPoint ( point.x (), point.y () ) ) )
			return

		tabIndex = self.tabBar ().tabAt ( point )
		if tabIndex >= 0:
			menu = QMenu ( self )
			menu.addAction ( "Close" ).triggered.connect ( lambda self, tabIndex: self.closeTab ( tabIndex ) )
			menu.exec ( self.mapToGlobal ( QPoint ( point.x (), point.y () ) ) )

	def swapToRollup ( self ):
		self.manager.swapAreaType ( self, QTWMWrapperAreaType.watRollups )

	def createCloseButton ( self ):
		result = QPushButton ( self )
		result.setIcon (
			getIcon ( self.manager.config.setdefault( QTWM_TAB_CLOSE_ICON,QIcon ( ":/QtDockLibrary/gfx/close.png" )) ) )
		result.clicked.connect ( self.tabCloseButtonClicked )
		return result

	def mouseReleaseEvent ( self, e ):
		if self.manager.config.setdefault(QTWM_SUPPORT_SIMPLE_TOOLS,False):
			if e.button () == QtCore.Qt.RightButton:
				p = self.tabBar ().rect ().height ()

				tabIndex = self.tabBar ().tabAt ( e.pos () )
				if tabIndex == -1 and e.pos ().y () >= 0 and e.pos ().y () <= p:
					swap = QAction ( "Swap to Rollups", self )
					e.accept ()
					swap.triggered.connect ( self.swapToRollup )
					menu = QMenu ( self )
					menu.addAction ( swap )
					menu.exec ( self.tabBar ().mapToGlobal ( QPoint ( e.pos ().x (), e.pos ().y () + 10 ) ) )

		super ().mouseReleaseEvent ( e )
