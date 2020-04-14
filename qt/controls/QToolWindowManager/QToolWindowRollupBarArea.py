from PyQt5 import QtGui, QtCore
from PyQt5.QtCore import QPoint, QSize, QRect, QCoreApplication, QEvent
from PyQt5.QtGui import QPixmap, QPainter, QMouseEvent
from PyQt5.QtWidgets import QTabWidget, QHBoxLayout, QLabel, QSizePolicy, QStyleOptionToolBar, QStyle, QAction, QMenu, \
	qApp

from qt.controls.QToolWindowManager.IToolWindowArea import IToolWindowArea
from qt.controls.QToolWindowManager.QRollupBar import QRollupBar
from qt.controls.QToolWindowManager.QToolWindowManagerCommon import *


class QDragger ( QLabel ):

	def __init__ ( self, parent ):
		super ().__init__ ( parent )
		self.setMinimumSize ( 1, 1 )
		self.setScaledContents ( False )

	def resizeEvent ( self, e: QtGui.QResizeEvent ) -> None:
		corner_img = QPixmap ( self.size () )
		corner_img.fill ( QtCore.Qt.transparent )
		option = QStyleOptionToolBar ()
		option.initFrom ( self.parentWidget () )
		option.features = QStyleOptionToolBar.Movable
		option.toolBarArea = QtCore.Qt.NoToolBarArea
		option.direction = QtCore.Qt.RightToLeft
		option.rect = corner_img.rect ()
		option.rect.setWidth ( option.rect.width () - 10 )
		option.rect.moveTo ( 5, 3 )
		painter = QPainter ( corner_img )
		painter.setOpacity ( 0.5 )
		self.parentWidget ().style ().drawPrimitive ( QStyle.PE_IndicatorToolBarHandle, option, painter,
		                                              self.parentWidget () )
		self.setPixmap ( corner_img )

		super ().resizeEvent ( e )

	def sizeHint ( self ) -> QtCore.QSize:
		w = self.width ()
		return QSize ( w, 8 )


class QToolWindowRollupBarArea ( QRollupBar, IToolWindowArea ):

	def __init__ ( self, manager, parent = None ):
		super ().__init__ ( parent )
		self.manager = manager
		self.tabDragCanStart = False
		self.areaDragCanStart = False
		self.topWidget = manager
		self.areaDragStart = QPoint ()
		self.areaDraggable = True

		self.setRollupsClosable ( True )
		self.rollupCloseRequested.connect ( self.closeRollup )
		currentLayout = self.layout ()
		if currentLayout:
			if self.manager.config.setdefault(QTWM_AREA_IMAGE_HANDLE,False):
				horizontalLayout = QHBoxLayout ()
				horizontalLayout.setSpacing ( 0 )
				horizontalLayout.addStretch ()
				self.topWidget = QLabel ( self )
				self.topWidget.setSizePolicy ( QSizePolicy.Minimum, QSizePolicy.Minimum )
				self.topWidget.setFixedHeight ( 16 )
				horizontalLayout.addWidget ( self.topWidget )
				currentLayout.insertLayout ( 0, horizontalLayout )
				corner_img = QPixmap ()
				corner_img.load(manager.config.setdefault(QTWM_DROPTARGET_COMBINE,":/QtDockLibrary/gfx/drag_handle.png"))
				self.topWidget.setPixmap ( corner_img )
			else:
				self.topWidget = QDragger ( self )
				self.topWidget.setSizePolicy ( QSizePolicy.Minimum, QSizePolicy.Minimum )
				self.topWidget.setFixedHeight ( 8 )
				currentLayout.insertWidget ( 0, self.topWidget )

			self.topWidget.setAttribute ( QtCore.Qt.WA_TranslucentBackground )
			self.topWidget.setCursor ( QtCore.Qt.OpenHandCursor )
			self.topWidget.installEventFilter ( self )

		self.setRollupsReorderable ( True )

	def addToolWindow ( self, toolWindow, index = -1 ):
		self.addToolWindows ( [ toolWindow ], index )

	def addToolWindows ( self, toolWindows, index = -1 ):
		for toolWindow in toolWindows:
			if index < 0:
				self.addWidget ( toolWindow )
			else:
				self.insertWidget ( toolWindow, index )

	def removeToolWindow ( self, toolWindow ):
		self.removeWidget ( toolWindow )

	def toolWindows ( self ):
		result = [ ]
		for i in range ( 0, self.count () ):
			result.append ( self.widget ( i ) )
		return result

	def saveState ( self ):
		result = { }
		result[ "type" ] = "rollup"
		objectNames = [ ]
		collapsedObjects = [ ]
		for i in range ( 0, self.count () ):
			name = self.widget ( i ).objectName ()
			if not name:
				print ( "cannot save state of tool window without object name" )
			else:
				frame = self.rollupAt ( i )
				if frame.collapsed:
					collapsedObjects.append ( name )
				objectNames.append ( name )
		result[ "objectNames" ] = objectNames
		result[ "collapsedObjects" ] = collapsedObjects
		return result

	def restoreState ( self, data, stateFormat ):
		collapsed = data[ "collapsedObjects" ]
		for objectNameValue in data[ "objectNames" ]:
			objectName = objectNameValue
			if not objectName:
				continue
			found = False
			for toolWindow in self.manager.toolWindows ():
				if toolWindow.objectName () == objectName:
					self.addToolWindow ( toolWindow )
					if objectName in collapsed:
						frame = self.rollupAt ( self.count () - 1 )
						frame.setCollapsed ( True )

					found = True
					break
			if not found:
				print ( "tool window with name '%s' not found" % objectName )

	def adjustDragVisuals ( self ):
		if self.count () == 1 and self.manager.isFloatingWrapper ( self.parentWidget () ):
			self.rollupAt ( 0 ).getDragHandler ().setHidden ( True )
		elif self.count () >= 1:
			self.rollupAt ( 0 ).getDragHandler ().setHidden ( False )

		if self.count () == 1:
			self.topWidget.setHidden ( True )
		else:
			self.topWidget.setHidden ( False )

		if self.manager.config.setdefault(QTWM_RETITLE_WRAPPER,True) and self.manager.isFloatingWrapper(
				self.parentWidget () ) and self.count () == 1:
			w = self.wrapper ()
			if w:
				w.getWidget ().setWindowTitle ( self.widget ( 0 ).windowTitle () )
		else:
			w = self.wrapper ()
			if w:
				w.getWidget ().setWindowTitle ( QCoreApplication.applicationName () )

	def getWidget ( self ):
		return self

	def switchAutoHide ( self, newValue ):
		return True

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
		return super ().indexOf ( w )

	def parentWidget ( self ):
		return QTabWidget.parentWidget ( self )

	def mapFromGlobal ( self, pos ):
		return QTabWidget.mapFromGlobal ( self, pos )

	def mapToGlobal ( self, pos ):
		return QTabWidget.mapToGlobal ( self )

	def setCurrentWidget ( self, w ):
		pass

	def mapCombineDropAreaFromGlobal ( self, pos ):
		return self.tabBar ().mapFromGlobal ( pos )

	def combineAreaRect ( self ):
		return self.getDropTarget ().rect ()

	def combineSubWidgetRect ( self, index ):
		rollup = self.rollupAt ( index )
		if rollup:
			newPos = rollup.geometry ()
			newPos.moveTop ( newPos.y () + self.getDropTarget ().pos ().y () )
			return newPos
		return QRect ()

	def subWidgetAt ( self, pos ):
		return self.rollupIndexAt ( pos )

	def areaType ( self ):
		return QTWMWrapperAreaType.watRollups

	def eventFilter ( self, o, e ):
		if self.isDragHandle(o) or o == self.topWidget:
			if e.type() == QEvent.MouseButtonPress:
				if o == self.topWidget:
					if self.areaDraggable:
						self.areaDragCanStart = True
						self.areaDragStart = e.pos()
				else:
					self.tabDragCanStart = True

				if self.manager.isMainWrapper(self.parentWidget()):
					self.areaDragCanStart = False
					if self.count() == 1:
						self.tabDragCanStart = False
			elif e.type() == QEvent.MouseButtonRelease:
				self.areaDragCanStart = False
				self.tabDragCanStart = False
			elif e.type() == QEvent.MouseMove:
				if self.tabDragCanStart:
					if self.rect().contains(self.mapFromGlobal(e.globalPos())):
						return super(QRollupBar, self).eventFilter(o, e)
					if qApp.mouseButtons() != QtCore.Qt.LeftButton:
						return super(QRollupBar, self).eventFilter(o, e)
					toolWindow = None
					for i in range(0, self.count()):
						if self.getDragHandleAt(i) == o:
							toolWindow = self.widget(i)
					self.tabDragCanStart = False
					releaseEvent = QMouseEvent(QEvent.MouseButtonRelease, e.pos(), QtCore.Qt.LeftButton, QtCore.Qt.LeftButton, 0)
					qApp.sendEvent(o, releaseEvent)
					self.manager.startDrag([toolWindow], self)
					self.releaseMouse()
				elif self.areaDragCanStart:
					if qApp.mouseButtons() != QtCore.Qt.LeftButton and not self.areaDragStart.isNull():
						toolWindows = []
						for i in range(0, self.count()):
							toolWindow = self.widget(i)
							toolWindows.append(toolWindow)
						releaseEvent = QMouseEvent ( QEvent.MouseButtonRelease, e.pos (), QtCore.Qt.LeftButton,
						                             QtCore.Qt.LeftButton, 0 )
						qApp.sendEvent ( o, releaseEvent )
						self.manager.startDrag ( toolWindows, self )
						self.releaseMouse ()
		super(QRollupBar, self).eventFilter(o, e)
		
	def closeRollup ( self, index ):
		self.manager.releaseToolWindow ( self.widget ( index ), True )

	def mouseReleaseEvent ( self, e ):
		if e.button () == QtCore.Qt.RightButton:
			if self.topWidget.rect ().contains ( e.pos () ):
				swap = QAction ( "Swap to Tabs", self )
				e.accept ()
				swap.triggered.connect ( self.swapToRollup )
				menu = QMenu ( self )
				menu.addAction ( swap )
				menu.exec_ ( self.mapToGlobal ( QPoint ( e.pos ().x (), e.pos ().y () + 10 ) ) )
		super ().mouseReleaseEvent ( e )

	def swapToRollup ( self ):
		self.manager.swapAreaType ( self, QTWMWrapperAreaType.watTabs )

	def setDraggable ( self, draggable ):
		self.areaDraggable = draggable
		if draggable:
			self.topWidget.setCursor ( QtCore.Qt.OpenHandCursor )
		else:
			self.topWidget.setCursor ( QtCore.Qt.ArrowCursor )
