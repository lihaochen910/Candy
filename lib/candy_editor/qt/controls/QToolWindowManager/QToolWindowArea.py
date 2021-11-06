from PyQt5 import Qt
from PyQt5.QtCore import QPoint, QRect, qWarning, QEvent
from PyQt5.QtGui import QIcon, QPixmap, QPainter, QMouseEvent
from PyQt5.QtWidgets import QLabel, QFrame, QTabWidget, QGridLayout, QPushButton, QSpacerItem, \
	QStyleOptionToolBar, QTabBar, QMenu, QAction, QSizePolicy

from .QToolWindowManagerCommon import *
from .QToolWindowTabBar import QToolWindowTabBar


class QToolWindowSingleTabAreaFrame ( QFrame ):

	def __init__ ( self, manager, parent ):
		super ( QToolWindowSingleTabAreaFrame, self ).__init__ ( parent )
		self.area = None
		self.reference = None
		self.index = 0
		self.contents = None
		self.geometry = QRect ()
		self.layout = QGridLayout ( self )
		self.manager = manager
		self.closeButton = None
		self.caption = QLabel ( self )

		self.layout.setContentsMargins ( 0, 0, 0, 0 )
		self.layout.setSpacing ( 0 )

		self.caption.setAttribute ( QtCore.Qt.WA_TransparentForMouseEvents )
		self.caption.setSizePolicy ( QSizePolicy.Expanding, QSizePolicy.Preferred )

		self.layout.addWidget ( self.caption, 0, 0 )

		if self.manager.config.setdefault ( QTWM_AREA_TABS_CLOSABLE, False ):
			self.closeButton = QPushButton ( self )
			self.closeButton.setObjectName ( "closeButton" )
			self.closeButton.setFocusPolicy ( QtCore.Qt.NoFocus )
			self.closeButton.setIcon ( self.getCloseButtonIcon () )
			self.closeButton.clicked.connect ( self.closeWidget )
			self.layout.addWidget ( self.closeButton, 0, 2 )
		else:
			self.layout.addItem ( QSpacerItem ( 0, 23, QSizePolicy.Minimum, QSizePolicy.Expanding ), 0, 1 )

		self.windowTitleChanged.connect ( self.caption.setText )
		self.layout.setColumnMinimumWidth ( 0, 1 )
		self.layout.setRowStretch ( 1, 1 )

	def __del__ ( self ):
		pass

	def setContents ( self, widget ):
		if self.contents != None:
			self.layout.removeWidget ( self.contents )

		if widget != None:
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
		if self.contents != None:
			e.setAccepted ( self.contents.close () )
			if e.isAccepted ():
				self.closeWidget ()

	def getCloseButtonIcon ( self ):
		return getIcon ( self.manager.config, QTWM_SINGLE_TAB_FRAME_CLOSE_ICON,
		                 QIcon ( "./resources/icons/QToolWindowManager/close.png" ) )


class QToolWindowArea ( QTabWidget ):

	def __init__ ( self, manager, parent = None ):
		QTabWidget.__init__ ( self, parent )
		self.manager = manager
		self.area = None
		self.reference = None
		self.index = 0
		self.dragCanStart = False
		self.tabDragCanStart = False
		self.areaDragCanStart = False
		self.setTabBar ( QToolWindowTabBar ( self ) )
		self.setMovable ( True )
		self.setTabShape ( QTabWidget.Rounded )
		self.setDocumentMode ( self.manager.config.setdefault ( QTWM_AREA_DOCUMENT_MODE, True ) )
		self.useCustomTabCloseButton = self.manager.config.setdefault ( QTWM_AREA_TABS_CLOSABLE, False )
		self.useTableFrame = self.manager.config.setdefault ( QTWM_AREA_USE_TAB_FRAME, False )
		self.setTabsClosable ( self.manager.config.setdefault ( QTWM_AREA_TABS_CLOSABLE, False ) and not self.useCustomTabCloseButton )
		self.setTabPosition ( self.manager.config.setdefault ( QTWM_AREA_TAB_POSITION, QTabWidget.North ) )
		# self.setLayoutDirection ( QtCore.Qt.LeftToRight )

		self.tabBar ().setSizePolicy ( QSizePolicy.Expanding, QSizePolicy.Preferred )
		self.setFocusPolicy ( QtCore.Qt.StrongFocus )

		areaUseImageHandle = self.manager.config.setdefault ( QTWM_AREA_IMAGE_HANDLE, False )
		if self.useTableFrame:
			self.tabFrame = QToolWindowSingleTabAreaFrame ( manager, self )
			self.tabFrame.hide ()
			self.tabFrame.installEventFilter ( self )
			self.tabFrame.caption.installEventFilter ( self )

		if self.manager.config.setdefault ( QTWM_AREA_SHOW_DRAG_HANDLE, False ):
			corner = QLabel ( self )
			corner.setSizePolicy ( QSizePolicy.Preferred, QSizePolicy.Expanding )
			corner.setAttribute ( QtCore.Qt.WA_TranslucentBackground )
			self.setCornerWidget ( corner )
			if areaUseImageHandle:
				corner_img = QPixmap ()
				corner_img.load ( self.manager.config.setdefault ( QTWM_DROPTARGET_COMBINE, "./resources/drag_handle.png" ) )
				corner.setPixmap ( corner_img )
			else:
				corner.setFixedHeight ( 8 )
				corner_img = QPixmap ( corner.size () )
				corner_img.fill ( QtCore.Qt.transparent )

				option = QStyleOptionToolBar ()
				option.initFrom ( self.tabBar () )
				option.state |= Qt.QStyle.State_Horizontal
				option.lineWidth = self.tabBar ().style ().pixelMetric ( Qt.QStyle.PM_ToolBarFrameWidth, None,
				                                                         self.tabBar () )
				option.features = QStyleOptionToolBar.Movable
				option.toolBarArea = QtCore.Qt.NoToolBarArea
				option.direction = QtCore.Qt.RightToLeft
				option.rect = corner_img.rect ()
				option.rect.moveTo ( 0, 0 )

				painter = QPainter ( corner_img )
				self.tabBar ().style ().drawPrimitive ( Qt.QStyle.PE_IndicatorToolBarHandle, option, painter, corner )
				painter.end ()
				corner.setPixmap ( corner_img )
			corner.setCursor ( QtCore.Qt.OpenHandCursor )
			corner.installEventFilter ( self )

		self.tabBar ().installEventFilter ( self )
		self.tabBar ().setContextMenuPolicy ( QtCore.Qt.CustomContextMenu )
		self.setContextMenuPolicy ( QtCore.Qt.CustomContextMenu )
		self.customContextMenuRequested.connect ( self.showContextMenu )
		self.tabBar ().customContextMenuRequested.connect ( self.showContextMenu )
		self.tabBar ().tabCloseRequested.connect ( self.closeTab )

	def __del__ ( self ):
		if self.manager != None:
			self.manager.removeArea ( self )
			self.manager = None

	def areaType ( self ):
		return QTWMWrapperAreaType.watTabs

	def addToolWindow ( self, toolWindow, index = -1 ):
		self.addToolWindows ( [ toolWindow ], index )

	def addToolWindows ( self, toolWindows, index = -1 ):
		# print ( "[QToolWindowArea] addToolWindows ready. %s" % toolWindows )
		newIndex = index
		for toolWindow in toolWindows:

			# from qt.controls.QToolWindowManager.QToolTabManager import QTabPane
			# from qt.controls.QToolWindowManager.SandboxWindowing import QToolsMenuWindowSingleTabAreaFrame
			# if isinstance ( toolWindow, QTabPane ):
			# 	print ( "[QToolWindowArea] addToolWindow: QTabPane %s" % toolWindow.pane )
			# elif isinstance ( toolWindow, QToolsMenuWindowSingleTabAreaFrame ):
			# 	print ( "[QToolWindowArea] addToolWindow: QToolsMenuWindowSingleTabAreaFrame %s" % toolWindow.contents )
			# 	# toolWindow.cause_a_exception ()
			# else:
			# 	print ( "[QToolWindowArea] addToolWindow: %s" % toolWindow )

			if self.manager.config.setdefault ( QTWM_AREA_TAB_ICONS, False ):
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
				iindex = self.indexOf ( toolWindow )
				if iindex >= 0:
					self.setTabText ( iindex, title )
				if self.count () == 1:
					self.setWindowTitle ( title )

			def onWindowIconChanged ( icon ):
				iiindex = self.indexOf ( toolWindow )
				if iiindex >= 0:
					self.setTabIcon ( iiindex, icon )
				if self.count () == 1:
					self.setWindowIcon ( icon )

			toolWindow.windowTitleChanged.connect ( onWindowTitleChanged )
			toolWindow.windowIconChanged.connect ( onWindowIconChanged )

		self.setCurrentWidget ( toolWindows[ 0 ] )

	def removeToolWindow ( self, toolWindow ):
		toolWindow.disconnect ()
		i = self.indexOf ( toolWindow )
		if i != -1:
			self.removeTab ( i )
		elif self.useTableFrame and self.tabFrame.contents == toolWindow:
			i = self.indexOf ( self.tabFrame )
			if i != -1:
				self.removeTab ( i )
			self.tabFrame.setContents ( None )

	def toolWindows ( self ):
		result = []
		for i in range ( 0, self.count () ):
			w = self.widget ( i )
			if self.useTableFrame and w == self.tabFrame:
				w = self.tabFrame.contents
			result.append ( w )
		return result

	def saveState ( self ):
		result = {}
		result[ "type" ] = "area"
		result[ "currentIndex" ] = self.currentIndex ()
		objectNames = []
		for i in range ( self.count () ):
			name = self.widget ( i ).objectName ()
			if not name:
				qWarning ( "[QToolWindowArea] saveState cannot save state of tool window without object name" )
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
				if toolWindow.objectName () == objectName:
					self.addToolWindow ( toolWindow )
					found = True
					break
			if not found:
				qWarning ( "[QToolWindowArea] restoreState tool window with name '%s' not found" % objectName )

		self.setCurrentIndex ( data[ "currentIndex" ] )

	def adjustDragVisuals ( self ):
		if self.manager.config.setdefault ( QTWM_SINGLE_TAB_FRAME, False ):
			self.tabBar ().setAutoHide ( True )
			showTabFrame = self.shouldShowSingleTabFrame ()

			if showTabFrame and self.indexOf ( self.tabFrame ) == -1:
				# Enable the single tab frame
				# qWarning ( "[QToolWindowArea] Enable the single tab frame" )
				w = self.widget ( 0 )
				self.removeToolWindow ( w )
				self.tabFrame.setContents ( w )
				self.addToolWindow ( self.tabFrame )
			elif not showTabFrame and self.indexOf ( self.tabFrame ) != -1:
				# Show the multiple tabs
				# qWarning ( "[QToolWindowArea] Show the multiple tabs" )
				w = self.tabFrame.contents
				self.tabFrame.setContents ( None )
				self.addToolWindow ( w, self.indexOf ( self.tabFrame ) )
				self.removeToolWindow ( self.tabFrame )

		if not self.manager.isMainWrapper ( self.parentWidget () ) and self.count () > 1 and self.manager.config.setdefault (
			QTWM_AREA_SHOW_DRAG_HANDLE, False ):
			self.cornerWidget ().show ()

		bMainWidget = self.manager.isMainWrapper ( self.parentWidget () )
		if self.manager.config.setdefault ( QTWM_SINGLE_TAB_FRAME, True ) and self.count () == 1 and \
				self.manager.config.setdefault (
					QTWM_AREA_TABS_CLOSABLE, False ):
			# Instead of multiple tabs, the single tab frame is visible. So we need to toggle the visibility
			# of its close button. The close button is hidden, when the tab frame is the only widget in
			# its tool window wrapper.
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
			self.setTabsClosable ( self.manager.config.setdefault ( QTWM_AREA_TABS_CLOSABLE, False ) )

		if self.manager.config.setdefault ( QTWM_RETITLE_WRAPPER, True ) and self.manager.isFloatingWrapper (
				self.parentWidget () ) and self.count () == 1:
			w = self.wrapper ()
			if w:
				w.getWidget ().setWindowTitle ( self.widget ( 0 ).windowTitle () )
		else:
			w = self.wrapper ()
			if w:
				w.getWidget ().setWindowTitle ( qApp.applicationName () )

	def getWidget ( self ):
		return self

	def wrapper ( self ):
		from .QToolWindowWrapper import QToolWindowWrapper
		from .QToolWindowCustomWrapper import QToolWindowCustomWrapper
		w = findClosestParent ( self.getWidget (), [ QToolWindowWrapper, QToolWindowCustomWrapper ] )
		# print ( "[QToolWindowArea] wrapper: %s" % w )
		return w

	def switchAutoHide ( self, newValue ):
		result = self.tabBar ().autoHide ()
		self.tabBar ().setAutoHide ( newValue )
		return result

	def indexOf ( self, w ):
		if self.useTableFrame and w == self.tabFrame.contents:
			w = self.tabFrame
		return QTabWidget.indexOf ( self, w )

	def setCurrentWidget ( self, w ):
		if self.useTableFrame and w == self.tabFrame.contents:
			QTabWidget.setCurrentWidget ( self, self.tabFrame )
		else:
			QTabWidget.setCurrentWidget ( self, w )

	def mapCombineDropAreaFromGlobal ( self, pos: QPoint ):
		return self.tabBar ().mapFromGlobal ( pos )

	def combineAreaRect ( self ):
		if self.useTableFrame and self.widget ( 0 ) == self.tabFrame:
			return self.tabFrame.caption.rect ()
		if self.tabPosition () == QTabWidget.West or \
				self.tabPosition () == QTabWidget.East:
			return QRect ( 0, 0, self.tabBar ().width (), self.height () )
		elif self.tabPosition () == QTabWidget.North or \
				self.tabPosition () == QTabWidget.South:
			return QRect ( 0, 0, self.width (), self.tabBar ().height () )
		return QRect ( 0, 0, self.width (), self.tabBar ().height () )

	def combineSubWidgetRect ( self, index: int ):
		return self.tabBar ().tabRect ( index )

	def subWidgetAt ( self, pos: QPoint ):
		return self.tabBar ().tabAt ( pos )

	def mousePressEvent( self, e ):
		if e.buttons () == QtCore.Qt.LeftButton:
			self.dragCanStart = True

	def mouseReleaseEvent( self, e ):
		self.dragCanStart = False
		self.manager.updateDragPosition ()

		# if self.manager.config.setdefault ( QTWM_SUPPORT_SIMPLE_TOOLS, False ):
		# 	if e.button () == QtCore.Qt.RightButton:
		# 		p = self.tabBar ().rect ().height ()
		#
		# 		tabIndex = self.tabBar ().tabAt ( e.pos () )
		# 		if tabIndex == -1 and e.pos ().y () >= 0 and e.pos ().y () <= p:
		# 			swap = QAction ( "Swap to Rollups", self )
		# 			e.accept ()
		# 			swap.triggered.connect ( self.swapToRollup )
		# 			menu = QMenu ( self )
		# 			menu.addAction ( swap )
		# 			menu.exec ( self.tabBar ().mapToGlobal ( QPoint ( e.pos ().x (), e.pos ().y () + 10 ) ) )
		#
		# QTabWidget.mouseReleaseEvent ( self, e )

	def mouseMoveEvent( self, e ):
		self.check_mouse_move( e )

	def eventFilter ( self, o, e ):
		if o == self.tabBar () or o == self.cornerWidget () or o == self.tabFrame or o == self.tabFrame.caption:

			# debug msg
			# if e.type () == Qt.QEvent.MouseButtonPress or e.type () == Qt.QEvent.MouseMove:
			# 	if o == self.tabBar ():
			# 		qWarning ( "eventFilter o == self.tabBar ()" )
			# 	elif o == self.cornerWidget ():
			# 		qWarning ( "eventFilter o == self.cornerWidget ()" )
			# 	elif o == self.tabFrame:
			# 		qWarning ( "eventFilter o == self.tabFrame" )
			# 	elif o == self.tabFrame.caption:
			# 		qWarning ( "eventFilter o == self.tabFrame.caption" )

			if e.type () == QEvent.MouseButtonPress and e.buttons () == QtCore.Qt.LeftButton:

				self.areaDragCanStart = False
				self.tabDragCanStart = False
	# if ((pObject == m_pTabFrame & & m_pTabFrame->m_pCaption->rect().contains ( me->pos())) | | pObject == m_pTabFrame->m_pCaption | | (pObject == tabBar() & & tabBar()->tabAt(static_cast < QMouseEvent * > (pEvent)->pos()) >= 0))

				if ( self.useTableFrame and o == self.tabFrame and self.tabFrame.caption.rect ().contains ( e.pos () ) )\
						or ( self.useTableFrame and o == self.tabFrame.caption ) \
						or ( o == self.tabBar () and self.tabBar ().tabAt ( e.pos () ) >= 0 ):
					self.tabDragCanStart = True
					# qWarning ( "[QToolWindowArea] eventFilter: tabDragCanStart = true" )
				elif self.manager.config.setdefault ( QTWM_AREA_SHOW_DRAG_HANDLE, False ) and (
						o == self.cornerWidget () or ( o == self.tabBar () and self.cornerWidget ().isVisible () and
						self.manager.config.setdefault ( QTWM_AREA_EMPTY_SPACE_DRAG, False ) ) ):
					self.areaDragCanStart = True
					# qWarning ( "[QToolWindowArea] eventFilter: areaDragCanStart = true" )
				# MyCode
				else:
					self.dragCanStart = True
					# qWarning ( "[QToolWindowArea] eventFilter: dragCanStart = true" )

				if self.manager.isMainWrapper ( self.parentWidget () ):
					self.areaDragCanStart = False
					if self.count () == 1:
						self.tabDragCanStart = False

			elif e.type () == QEvent.MouseButtonRelease:
				self.tabDragCanStart = False
				self.dragCanStart = False
				self.areaDragCanStart = False
				self.manager.updateDragPosition ()
				# qWarning ( "[QToolWindowArea] eventFilter: MouseButtonRelease" )

			elif e.type () == QEvent.MouseMove:
				self.manager.updateDragPosition ()

				if self.tabDragCanStart:
					if self.tabBar ().rect ().contains ( e.pos () ) \
							or ( self.manager.config.setdefault ( QTWM_AREA_SHOW_DRAG_HANDLE, False ) and self.cornerWidget ().rect ().contains ( e.pos () ) ):
						return False

					if e.buttons () != QtCore.Qt.LeftButton:
						return False

					# qWarning ( "[QToolWindowArea] eventFilter: tabDragCanStart." )

					toolWindow = self.currentWidget ()
					if self.useTableFrame and cast ( toolWindow, QToolWindowSingleTabAreaFrame ) == self.tabFrame:
						toolWindow = self.tabFrame.contents

					if not ( toolWindow and self.manager.ownsToolWindow ( toolWindow ) ):
						return False

					self.tabDragCanStart = False
					# qWarning ( "[QToolWindowArea] eventFilter: tabDragCanStart = false" )

					# stop internal tab drag in QTabBar
					releaseEvent = QMouseEvent ( QEvent.MouseButtonRelease, e.pos (), QtCore.Qt.LeftButton,
					                             QtCore.Qt.LeftButton, QtCore.Qt.NoModifier )
					qApp.sendEvent ( self.tabBar (), releaseEvent )

					self.manager.startDrag ( [ toolWindow ], self )

				elif self.areaDragCanStart:
					if qApp.mouseButtons () == QtCore.Qt.LeftButton \
							and not ( self.manager.config.setdefault ( QTWM_AREA_SHOW_DRAG_HANDLE, False ) and self.cornerWidget ().rect ().contains (
						self.mapFromGlobal ( QCursor.pos () ) ) ):

						# qWarning ( "[QToolWindowArea] eventFilter: areaDragCanStart." )

						toolWindows = []
						for i in range ( 0, self.count () ):
							toolWindow = self.widget ( i )
							if self.useTableFrame and cast ( toolWindow, QToolWindowSingleTabAreaFrame ) == self.tabFrame:
								toolWindow = self.tabFrame.contents
							toolWindows.append ( toolWindow )

						self.areaDragCanStart = False
						# qWarning ( "[QToolWindowArea] eventFilter: areaDragCanStart = false" )

						if self.cornerWidget () != None:
							releaseEvent = QMouseEvent ( Qt.QEvent.MouseButtonRelease, e.pos (), QtCore.Qt.LeftButton,
							                             QtCore.Qt.LeftButton, QtCore.Qt.NoModifier )
							qApp.sendEvent ( self.cornerWidget (), releaseEvent )
						self.manager.startDrag ( toolWindows, self )
						self.releaseMouse ()

				elif self.dragCanStart:
					self.check_mouse_move ( e )

		return QTabWidget.eventFilter ( self, o, e )

	# MyCode
	def check_mouse_move ( self, e ):
		self.manager.updateDragPosition ()
		if e.buttons () == QtCore.Qt.LeftButton \
		and	not self.rect ().contains ( self.mapFromGlobal ( QCursor.pos () ) ) \
		and	self.dragCanStart:
			self.dragCanStart = False
			toolWindows = []
			for i in range ( self.count () ):
				toolWindow = self.widget ( i )
				if self.manager.ownsToolWindow ( toolWindow ):
					toolWindows.append ( toolWindow )
				else:
					qWarning ( "tab widget contains unmanaged widget" )
			self.manager.startDrag ( toolWindows, self )

	def shouldShowSingleTabFrame ( self ):
		if self.manager.config.setdefault ( QTWM_SINGLE_TAB_FRAME, True ):
			return False
		c = self.count ()
		if c != 1:
			return False

		if self.manager.isFloatingWrapper ( self.parentWidget () ):
			return False

		return True

	# def event ( self, event ):
	# 	if not self.areaDragCanStart and event.type () == QEvent.MouseButtonPress and not self.manager.config.setdefault (
	# 		QTWM_AREA_SHOW_DRAG_HANDLE, False ):
	# 		floatingWrapper = False
	# 		wrapper = self.wrapper ()
	# 		if wrapper and self.manager.isFloatingWrapper ( wrapper.getWidget () ):
	# 			floatingWrapper = True
	#
	# 		if not floatingWrapper and self.currentWidget () and not self.currentWidget ().rect ().contains (
	# 				self.currentWidget ().mapFromGlobal ( QCursor.pos () ) ):
	# 			self.areaDragCanStart = True
	# 			qWarning ( "[QToolWindowArea] event: areaDragCanStart = true" )
	# 	elif event.type () == QEvent.MouseMove and not self.manager.config.setdefault ( QTWM_AREA_SHOW_DRAG_HANDLE,
	# 	                                                                                   False ):
	# 		if self.areaDragCanStart:
	# 			if qApp.mouseButtons () == QtCore.Qt.LeftButton:
	# 				toolWindows = []
	# 				for i in range ( 0, self.count () ):
	# 					toolWindow = self.widget ( i )
	# 					if cast ( toolWindow, QToolWindowSingleTabAreaFrame ) == self.tabFrame:
	# 						toolWindow = self.tabFrame.contents
	# 					toolWindows.append ( toolWindow )
	# 				self.areaDragCanStart = False
	# 				qWarning ( "[QToolWindowArea] event: areaDragCanStart = false" )
	# 				self.manager.startDrag ( toolWindows, self )
	# 				self.releaseMouse ()
	#
	# 	return QTabWidget.event ( self, event )

	def tabCloseButtonClicked ( self ):
		index = -1
		o = self.sender ()
		for i in range ( 0, self.count () ):
			if o == self.tabBar ().tabButton ( i, QTabBar.RightSide ):
				index = i
				break

		if index != -1:
			self.tabBar ().tabCloseRequested ( index )

	def closeTab ( self, index: int ):
		print ( "[QToolWindowArea] closeTab", index )
		self.manager.releaseToolWindow ( self.widget ( index ), True )

	def showContextMenu ( self, point: QPoint ):
		if point.isNull () or ( self.manager.isMainWrapper ( self.parentWidget () ) and self.tabBar ().count () <= 1 ):
			return

		singleTabFrame = cast ( self.currentWidget (), QToolWindowSingleTabAreaFrame )

		if singleTabFrame and singleTabFrame.caption and singleTabFrame.caption.contentsRect ().contains (
				point ) and not self.manager.isMainWrapper ( self.parentWidget () ):
			menu = QMenu ( self )
			menu.addAction ( "Close" ).triggered.connect ( lambda b: singleTabFrame.close () )
			menu.exec ( self.mapToGlobal ( QPoint ( point.x (), point.y () ) ) )
			return

		tabIndex = self.tabBar ().tabAt ( point )
		if tabIndex >= 0:
			def closeTab ():
				self.closeTab ( tabIndex )
			menu = QMenu ( self )
			menu.addAction ( "Close" ).triggered.connect ( lambda b: closeTab () )
			menu.exec ( self.mapToGlobal ( QPoint ( point.x (), point.y () ) ) )

	def swapToRollup ( self ):
		self.manager.swapAreaType ( self, QTWMWrapperAreaType.watRollups )

	def createCloseButton ( self ):
		result = QPushButton ( self )
		result.setIcon (
			getIcon ( self.manager.config, QTWM_TAB_CLOSE_ICON, QIcon ( "./resources/icons/QToolWindowManager/close.png" ) ) )
		result.clicked.connect ( self.tabCloseButtonClicked )
		return result
