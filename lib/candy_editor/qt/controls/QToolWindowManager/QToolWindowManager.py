# Copyright 2001-2019 Crytek GmbH / Crytek Group. All rights reserved.
from PyQt5.QtCore import Qt, QObject, QTimer, QRect, QPoint, QByteArray, pyqtSignal, qWarning, QEvent, QSize
from PyQt5.QtGui import QIcon, QMouseEvent
from PyQt5.QtWidgets import QLabel, QTabBar, QRubberBand, QVBoxLayout, QSplitter, QWidget, QSizePolicy, QApplication, QMainWindow, \
	QPushButton

from .QToolWindowManagerCommon import *
from .QCustomWindowFrame import QCustomTitleBar, QCustomWindowFrame
from .QToolWindowArea import QToolWindowArea
from .QToolWindowRollupBarArea import QToolWindowRollupBarArea
from .QToolWindowWrapper import QToolWindowWrapper
from .QToolWindowDragHandlerDropTargets import QToolWindowDragHandlerDropTargets


class QToolWindowAreaReference:
	Top = 0
	Bottom = 1
	Left = 2
	Right = 3
	HSplitTop = 4
	HSplitBottom = 5
	VSplitLeft = 6
	VSplitRight = 7
	Combine = 8
	Floating = 9
	Drag = 10
	Hidden = 11


	def __init__ ( self, eType = None ):
		self.type = eType or QToolWindowAreaReference.Combine

	@staticmethod
	def isOuter ( eType ) -> bool:
		return eType <= QToolWindowAreaReference.Right

	@staticmethod
	def requiresSplit ( eType ) -> bool:
		return eType < QToolWindowAreaReference.Combine

	@staticmethod
	def splitOrientation ( eType ):
		if eType == QToolWindowAreaReference.Top or \
				eType == QToolWindowAreaReference.Bottom or \
				eType == QToolWindowAreaReference.HSplitTop or \
				eType == QToolWindowAreaReference.HSplitBottom:
			return QtCore.Qt.Vertical
		if eType == QToolWindowAreaReference.Left or \
				eType == QToolWindowAreaReference.Right or \
				eType == QToolWindowAreaReference.VSplitLeft or \
				eType == QToolWindowAreaReference.VSplitRight:
			return QtCore.Qt.Horizontal
		if eType == QToolWindowAreaReference.Combine or \
				eType == QToolWindowAreaReference.Floating or \
				eType == QToolWindowAreaReference.Hidden:
			return 0


class QToolWindowAreaTarget:

	def __init__ ( self, reference = QToolWindowAreaReference.Combine, index = -1, geometry = QRect () ):
		self.area = None
		self.reference = reference
		self.index = index
		self.geometry = geometry

	@staticmethod
	def createByArea ( area, reference, index = -1, geometry = QRect () ):
		target = QToolWindowAreaTarget ( reference, index, geometry )
		target.area = area
		return target


class QToolWindowManagerClassFactory ( QObject ):

	def createArea ( self, manager, parent, areaType ) -> QToolWindowArea:
		"""Summary line.

		Args:
			manager (QToolWindowManager): Description of param1
			parent (QWidget): Description of param2
			areaType (QTWMWrapperAreaType): Description of param2

	    Returns:
	        IToolWindowArea: Description of return value
	    """
		if manager.config.setdefault ( QTWM_SUPPORT_SIMPLE_TOOLS, False ) and areaType == QTWMWrapperAreaType.watRollups:
			return QToolWindowRollupBarArea ( manager, parent )
		else:
			return QToolWindowArea ( manager, parent )

	def createWrapper ( self, manager ):
		"""Summary line.

		Args:
			manager (QToolWindowManager): Description of param1

	    Returns:
	        QToolWindowWrapper: Description of return value
	    """
		return QToolWindowWrapper ( manager, QtCore.Qt.Tool )
		# return QToolWindowWrapper ( manager, Qt.CustomizeWindowHint | Qt.FramelessWindowHint )

	def createDragHandler ( self, manager ):
		"""Summary line.

		Args:
			manager (QToolWindowManager): Description of param1

	    Returns:
	        QToolWindowDragHandlerDropTargets: Description of return value
	    """
		return QToolWindowDragHandlerDropTargets ( manager )

	def createSplitter ( self, manager ):
		"""Summary line.

		Args:
			manager (QToolWindowManager): Description of param1

	    Returns:
	        QSplitter: Description of return value
	    """
		splitter = None
		if manager.config.setdefault ( QTWM_PRESERVE_SPLITTER_SIZES, True ):
			splitter = QSizePreservingSplitter ()
		else:
			splitter = QSplitter ()
		splitter.setChildrenCollapsible ( False )
		return splitter


class QTWMNotifyLock:

	def __init__ ( self, parent, allowNotify = True ):
		self.parent = parent
		self.notify = allowNotify
		self.parent.suspendLayoutNotifications ()

	def __del__ ( self ):
		self.parent.resumeLayoutNotifications ()
		if self.notify:
			self.parent.notifyLayoutChange ()


class QToolWindowManager ( QWidget ):
	toolWindowVisibilityChanged = pyqtSignal ( QWidget, bool )
	layoutChanged = pyqtSignal ()
	updateTrackingTooltip = pyqtSignal ( str, QPoint )

	def __init__ ( self, parent, config, factory = None ):
		super ( QToolWindowManager, self ).__init__ ( parent )
		self.factory = factory if factory != None else QToolWindowManagerClassFactory ()
		self.dragHandler = None
		self.config = config
		self.closingWindow = 0

		self.areas = []
		self.wrappers = []
		self.toolWindows = []
		self.toolWindowsTypes = {}
		self.draggedToolWindows = []
		self.layoutChangeNotifyLocks = 0

		if self.factory.parent () == None:
			self.factory.setParent ( self )

		self.mainWrapper = QToolWindowWrapper ( self, QtCore.Qt.FramelessWindowHint )
		self.mainWrapper.getWidget ().setObjectName ( 'mainWrapper' )
		self.setLayout ( QVBoxLayout ( self ) )
		self.layout ().setContentsMargins ( 2, 2, 2, 2 )
		self.layout ().setSpacing ( 0 )
		self.layout ().addWidget ( self.mainWrapper.getWidget () )
		self.lastArea = self.createArea ()
		self.draggedWrapper = None
		self.draggedArea = None
		self.resizedWrapper = None
		self.mainWrapper.setContents ( self.lastArea.getWidget () )

		self.dragHandler = self.createDragHandler ()
		self.dragIndicator = QLabel ( None, Qt.ToolTip )  # 使用QLabel来显示拖拽的提示
		self.dragIndicator.setAttribute ( Qt.WA_ShowWithoutActivating )

		self.preview = QRubberBand ( QRubberBand.Rectangle )
		self.preview.hide ()

		self.raiseTimer = QTimer ( self )
		self.raiseTimer.timeout.connect ( self.raiseCurrentArea )
		self.setSizePolicy ( QSizePolicy.Expanding, QSizePolicy.Expanding )

		qApp.installEventFilter ( self )

	def __del__ ( self ):
		self.suspendLayoutNotifications ()
		while len ( self.areas ) != 0:
			a = self.areas[ 0 ]
			a.setParent ( None )
			self.areas.remove ( a )

		while len ( self.wrappers ) != 0:
			w = self.wrappers[ 0 ]
			w.setParent ( None )
			self.areas.remove ( w )

		del self.dragHandler
		del self.mainWrapper

	def empty ( self ) -> bool:
		return len ( self.areas ) == 0

	def removeArea ( self, area ):
		"""Summary line.

		Args:
			area (QToolWindowArea): Description of param1

	    Returns:
	        QToolWindowArea: Description of return value
	    """
		# print ( "[QToolWindowManager] removeArea %s" % area )
		if area in self.areas:
			self.areas.remove ( area )
		if self.lastArea == area:
			self.lastArea = None

	def removeWrapper ( self, wrapper ):
		"""Summary line.

		Args:
			wrapper (QToolWindowWrapper): Description of param1
	    """
		if self.ownsWrapper ( wrapper ):
			self.wrappers.remove ( wrapper )

	def ownsArea ( self, area ) -> bool:
		"""Summary line.

		Args:
			area (QToolWindowArea): Description of param1

	    Returns:
	        bool: Description of return value
	    """
		return area in self.areas

	def ownsWrapper ( self, wrapper ) -> bool:
		"""Summary line.

		Args:
			wrapper (QToolWindowWrapper): Description of param1

	    Returns:
	        bool: Description of return value
	    """
		return wrapper in self.wrappers

	def ownsToolWindow ( self, toolWindow ) -> bool:
		"""Summary line.

		Args:
			wrapper (QToolWindowWrapper): Description of param1

	    Returns:
	        bool: Description of return value
	    """
		return toolWindow in self.toolWindows

	def startDrag ( self, toolWindows, area ):
		if self.dragInProgress ():
			qWarning ( 'ToolWindowManager::execDrag: drag is already in progress' )
			return
		if len ( toolWindows ) == 0:
			return
		# print ( "[QToolWindowManager] startDrag", toolWindows )
		self.dragHandler.startDrag ()
		self.draggedToolWindows = toolWindows
		self.draggedArea = area
		self.lastArea = None

		# floatingGeometry = QRect ( QCursor.pos (), area.size () )
		# self.moveToolWindows ( toolWindows, area, QToolWindowAreaReference.Drag, -1, floatingGeometry )

		self.dragIndicator.setPixmap ( self.generateDragPixmap ( toolWindows ) )
		self.updateDragPosition ()
		self.dragIndicator.show ()

	def startDragWrapper ( self, wrapper ):
		self.dragHandler.startDrag ()
		self.draggedWrapper = wrapper
		self.lastArea = None
		self.updateDragPosition ()

	def startResize ( self, wrapper ):
		self.resizedWrapper = wrapper

	def generateDragPixmap ( self, toolWindows ):
		'''
		生成一个QTabBar的快照
		'''
		widget = QTabBar ()
		widget.setDocumentMode ( True )
		for toolWindow in toolWindows:
			widget.addTab ( toolWindow.windowIcon (), toolWindow.windowTitle () )
		#if QT_VERSION >= 0x050000 # Qt5
			return widget.grab ()
		#else #Qt4
		# return QtGui.QPixmap.grabWidget( widget )
		#endif

	def addToolWindowTarget ( self, toolWindow, target, toolType = QTWMToolType.ttStandard ):
		self.insertToToolTypes ( toolWindow, toolType )
		self.addToolWindow ( toolWindow, target.area, target.reference, target.index, target.geometry )

	def addToolWindow ( self, toolWindow, area = None, reference = QToolWindowAreaReference.Combine, index = -1,
	                    geometry = QRect () ):
		self.addToolWindows ( [ toolWindow ], area, reference, index, geometry )

	def addToolWindowsTarget ( self, toolWindows, target, toolType ):
		for toolWindow in toolWindows:
			self.insertToToolTypes ( toolWindow, toolType )
		self.addToolWindows ( toolWindows, target.area, target.reference, target.index, target.geometry )

	def addToolWindows ( self, toolWindows, area = None, reference = QToolWindowAreaReference.Combine, index = -1,
	                     geometry = QRect () ):
		for toolWindow in toolWindows:
			if not self.ownsToolWindow ( toolWindow ):
				toolWindow.hide ()
				toolWindow.setParent ( None )
				toolWindow.installEventFilter ( self )
				self.insertToToolTypes ( toolWindow, QTWMToolType.ttStandard )
				self.toolWindows.append ( toolWindow )

				# from qt.controls.QToolWindowManager.QToolTabManager import QTabPane
				#
				# if isinstance ( toolWindow, QTabPane ):
				# 	print ( "[QToolWindowManager] addToolWindow: QTabPane %s" % toolWindow.pane )
				# else:
				# 	print ( "[QToolWindowManager] addToolWindow: %s" % toolWindow )
		self.moveToolWindows ( toolWindows, area, reference, index, geometry )

	def moveToolWindowTarget ( self, toolWindow, target, toolType = QTWMToolType.ttStandard ):
		self.insertToToolTypes ( toolWindow, toolType )
		self.addToolWindow ( toolWindow, target.area, target.reference, target.index, target.geometry )

	def moveToolWindow ( self, toolWindow, area = None, reference = QToolWindowAreaReference.Combine, index = -1,
	                     geometry = QRect () ):
		self.moveToolWindows ( [ toolWindow ], area, reference, index, geometry )

	def moveToolWindowsTarget ( self, toolWindows, target, toolType = QTWMToolType.ttStandard ):
		for toolWindow in toolWindows:
			self.insertToToolTypes ( toolWindow, toolType )
		self.addToolWindows ( toolWindows, target.area, target.reference, target.index, target.geometry )

	def moveToolWindows ( self, toolWindows, area = None, reference = QToolWindowAreaReference.Combine, index = -1,
	                      geometry = None ):

		# qWarning ( "moveToolWindows %s" % toolWindows )

		# If no area find one
		if area == None:
			if self.lastArea != None:
				area = self.lastArea
			elif len ( self.areas ) != 0:
				area = self.areas[ 0 ]
			else:
				qWarning ( "lastArea is None, and areas is 0, self.createArea ()" )
				area = self.createArea ()
				self.lastArea = area
				self.mainWrapper.setContents ( self.lastArea.getWidget () )

		dragOffset = QPoint ()
		# Get the current mouse position and offset from the area before we remove the tool windows from it
		if area != None and reference == QToolWindowAreaReference.Drag:
			widgetPos = area.mapToGlobal ( area.rect ().topLeft () )
			dragOffset = widgetPos - QCursor.pos ()

		wrapper = None
		currentAreaIsSimple = True

		for toolWindow in toolWindows:
			# when iterating over the tool windows, we will figure out if the current one is actually roll-ups and not tabs
			currentArea = findClosestParent ( toolWindow, [ QToolWindowArea, QToolWindowRollupBarArea ] )
			if currentAreaIsSimple and currentArea != None and currentArea.areaType () == QTWMWrapperAreaType.watTabs:
				currentAreaIsSimple = False
			self.releaseToolWindow ( toolWindow, False )

		if reference == QToolWindowAreaReference.Top or \
				reference == QToolWindowAreaReference.Bottom or \
				reference == QToolWindowAreaReference.Left or \
				reference == QToolWindowAreaReference.Right:
			area = cast ( self.splitArea ( self.getFurthestParentArea ( area.getWidget () ).getWidget (), reference ), [ QToolWindowArea, QToolWindowRollupBarArea ] )
		elif reference == QToolWindowAreaReference.HSplitTop or \
				reference == QToolWindowAreaReference.HSplitBottom or \
				reference == QToolWindowAreaReference.VSplitLeft or \
				reference == QToolWindowAreaReference.VSplitRight:
			area = cast ( self.splitArea ( area.getWidget (), reference ), [ QToolWindowArea, QToolWindowRollupBarArea ] )
		elif reference == QToolWindowAreaReference.Floating or \
				reference == QToolWindowAreaReference.Drag:
			# when dragging we will try to determine target are type, from window types.
			areaType = QTWMWrapperAreaType.watTabs
			if len ( toolWindows ) > 1:
				if currentAreaIsSimple:
					areaType = QTWMWrapperAreaType.watRollups
			elif self.toolWindowsTypes[ toolWindows[ 0 ] ] == QTWMToolType.ttSimple:
				areaType = QTWMWrapperAreaType.watRollups

			# create new window
			area = self.createArea ( areaType )
			wrapper = self.createWrapper ()
			wrapper.setContents ( area.getWidget () )
			# wrapper.move ( QCursor.pos () )
			wrapper.getWidget ().show ()
			# wrapper.getWidget ().grabMouse ()

			# qWarning ( "[QToolWindowManager] moveToolWindows create new window reference: %s area's wrapper: %s" % (
			# self.getAreaReferenceString ( reference ), area.wrapper ()) )\\\

			if geometry != None: # we have geometry, apply the mouse offset
				# If we have a title bar we want to move the mouse to half the height of it
				titleBar = wrapper.getWidget ().findChild ( QCustomTitleBar )
				if titleBar:
					dragOffset.setY ( -titleBar.height () / 2 )
				# apply the mouse offset to the current rect
				geometry.moveTopLeft ( geometry.topLeft () + dragOffset )
				wrapper.getWidget ().setGeometry ( geometry )
				wrapper.getWidget ().move ( QCursor.pos () )
				if titleBar:
					currentTitle = titleBar.caption.text ()
					if len ( toolWindows ) > 0:
						titleBar.caption.setText ( toolWindows[ 0 ].windowTitle () )
					wrapper.getWidget ().move (
						- ( titleBar.caption.mapToGlobal ( titleBar.caption.rect ().topLeft () ) - wrapper.mapToGlobal ( wrapper.rect ().topLeft () ) )
						+ QPoint ( -titleBar.caption.fontMetrics ().boundingRect ( titleBar.caption.text () ).width () / 2, -titleBar.caption.height () / 2 )
						+ wrapper.pos ()
					)
					titleBar.caption.setText ( currentTitle )
			else: # with no present geometry we just create a new one
				wrapper.getWidget ().setGeometry ( QRect ( QPoint ( 0, 0 ), toolWindows[ 0 ].sizeHint () ) )
				wrapper.getWidget ().move ( QCursor.pos () )

			# when create new wrapper, we should transfer mouse-event to wrapper's titleBar for we can continue move.
			if reference == QToolWindowAreaReference.Drag:
				titleBar = wrapper.getWidget ().findChild ( QCustomTitleBar )
				if titleBar:
					# set flag for titleBar releaseMouse
					titleBar.createFromDraging = True
					startDragEvent = QMouseEvent ( QEvent.MouseButtonPress, QCursor.pos (), QtCore.Qt.LeftButton,
					                               QtCore.Qt.LeftButton, QtCore.Qt.NoModifier )
					qApp.sendEvent ( titleBar, startDragEvent )
					titleBar.grabMouse ()

		if reference != QToolWindowAreaReference.Hidden:
			area.addToolWindows ( toolWindows, index )
			self.lastArea = area

		# This will remove the previous area the tool windows where attached to
		self.simplifyLayout ()
		for toolWindow in toolWindows:
			self.toolWindowVisibilityChanged.emit ( toolWindow, toolWindow.parent () != None )
		self.notifyLayoutChange ()

		if reference == QToolWindowAreaReference.Drag and wrapper != None:
			self.draggedWrapper = wrapper
			# start the drag on the new wrapper, will end up calling QToolWindowManager::startDrag(IToolWindowWrapper* wrapper)
			wrapper.startDrag ()

	def getAreaReferenceString ( self, reference ):
		# Top = 0
		# Bottom = 1
		# Left = 2
		# Right = 3
		# HSplitTop = 4
		# HSplitBottom = 5
		# VSplitLeft = 6
		# VSplitRight = 7
		# Combine = 8
		# Floating = 9
		# Drag = 10
		# Hidden = 11
		if reference == QToolWindowAreaReference.Top:
			return "Top"
		elif reference == QToolWindowAreaReference.Bottom:
			return "Bottom"
		elif reference == QToolWindowAreaReference.Left:
			return "Left"
		elif reference == QToolWindowAreaReference.Right:
			return "Right"
		elif reference == QToolWindowAreaReference.HSplitTop:
			return "HSplitTop"
		elif reference == QToolWindowAreaReference.HSplitBottom:
			return "HSplitBottom"
		elif reference == QToolWindowAreaReference.VSplitLeft:
			return "VSplitLeft"
		elif reference == QToolWindowAreaReference.VSplitRight:
			return "VSplitRight"
		elif reference == QToolWindowAreaReference.Combine:
			return "Combine"
		elif reference == QToolWindowAreaReference.Floating:
			return "Floating"
		elif reference == QToolWindowAreaReference.Drag:
			return "Drag"
		elif reference == QToolWindowAreaReference.Hidden:
			return "Hidden"

	def releaseToolWindow ( self, toolWindow, allowClose = False ) -> bool:
		# No parent, so can't possibly be inside an IToolWindowArea
		if toolWindow.parentWidget () == None:
			# qWarning ( "[QToolWindowManager] releaseToolWindow %s, but toolWindow.parentWidget () == None" % toolWindow )
			return False

		if not self.ownsToolWindow ( toolWindow ):
			qWarning ( "Unknown tool window %s" % toolWindow )
			return False

		previousTabWidget = findClosestParent ( toolWindow, [ QToolWindowArea, QToolWindowRollupBarArea ] )
		if previousTabWidget is None:
			qWarning ( "[QToolWindowManager] cannot find area for tool window %s" % toolWindow )
			return False

		if allowClose:
			releasePolicy = self.config.setdefault ( QTWM_RELEASE_POLICY, QTWMReleaseCachingPolicy.rcpWidget )
			if releasePolicy == QTWMReleaseCachingPolicy.rcpKeep:
				self.moveToolWindow ( toolWindow, None, QToolWindowAreaReference.Hidden )
				if self.config.setdefault ( QTWM_ALWAYS_CLOSE_WIDGETS, True ) and not self.tryCloseToolWindow ( toolWindow ):
					return False
			elif releasePolicy == QTWMReleaseCachingPolicy.rcpWidget:
				if not toolWindow.testAttribute ( QtCore.Qt.WA_DeleteOnClose ):
					if self.config.setdefault ( QTWM_ALWAYS_CLOSE_WIDGETS, True ) and not self.tryCloseToolWindow (
							toolWindow ):
						return False
					self.moveToolWindow ( toolWindow, None, QToolWindowAreaReference.Hidden )
			elif releasePolicy == QTWMReleaseCachingPolicy.rcpForget or releasePolicy == QTWMReleaseCachingPolicy.rcpDelete:
				if not self.tryCloseToolWindow ( toolWindow ):
					return False
				self.moveToolWindow ( toolWindow, None, QToolWindowAreaReference.Hidden )
				self.toolWindows.remove ( toolWindow )

				if releasePolicy == QTWMReleaseCachingPolicy.rcpDelete:
					toolWindow.deleteLater ()
				return True

		previousTabWidget.removeToolWindow ( toolWindow )

		if allowClose:
			self.simplifyLayout ()
		else:
			previousTabWidget.adjustDragVisuals ()

		toolWindow.hide ()
		toolWindow.setParent ( None )
		return True

	def releaseToolWindows ( self, toolWindows, allowClose = False ) -> bool:
		# print ( "[QToolWindowManager] releaseToolWindows", toolWindows )
		result = True
		for i in range ( len ( toolWindows ) - 1, -1, -1 ):
		# for toolWindow in toolWindows:
			# if i >= 0 and i < len ( toolWindows ):
			result &= self.releaseToolWindow ( toolWindows[ i ], allowClose )
		# while len ( toolWindows ) != 0:
		# 	result &= self.releaseToolWindow ( toolWindows[ 0 ], allowClose )
		return result

	def areaOf ( self, toolWindow ) -> QToolWindowArea:
		area = findClosestParent ( toolWindow, [ QToolWindowArea, QToolWindowRollupBarArea ] )
		# print ( "[QToolWindowManager] areaOf %s is %s" % ( toolWindow, area ) )
		return area

	def swapAreaType ( self, oldArea, areaType = QTWMWrapperAreaType.watTabs ):
		from QToolWindowManager.QToolWindowWrapper import QToolWindowWrapper
		from QToolWindowManager.QToolWindowCustomWrapper import QToolWindowCustomWrapper
		targetWrapper = findClosestParent ( oldArea.getWidget (), [ QToolWindowWrapper, QToolWindowCustomWrapper ] )
		parentSplitter = cast ( oldArea.parentWidget (), QSplitter )
		newArea = self.createArea ( areaType )

		if parentSplitter is None and targetWrapper is None:
			qWarning ( "[QToolWindowManager] Could not determine area parent" )
			return

		newArea.addToolWindow ( oldArea.toolWindows () )
		if parentSplitter != None:
			targetIndex = parentSplitter.indexOf ( oldArea.getWidget () )
			parentSplitter.insertWidget ( targetIndex, newArea.getWidget () )
		else:
			targetWrapper.setContents ( newArea.getWidget () )

		if self.lastArea == oldArea:
			self.lastArea = newArea

		oldAreaIndex = self.areas.index ( oldArea )
		self.areas.remove ( oldArea )
		self.areas.insert ( oldAreaIndex, newArea )
		oldArea.getWidget ().setParent ( None )
		newArea.adjustDragVisuals ()

	def isWrapper ( self, w ) -> bool:
		if w is None:
			return False
		from .QToolWindowWrapper import QToolWindowWrapper
		from .QToolWindowCustomWrapper import QToolWindowCustomWrapper
		return cast ( w, [ QToolWindowWrapper, QToolWindowCustomWrapper ] ) or (
				not cast ( w, QSplitter ) and cast ( w.parentWidget (), [ QToolWindowWrapper, QToolWindowCustomWrapper ] ) )

	def isMainWrapper ( self, w ) -> bool:
		from .QToolWindowWrapper import QToolWindowWrapper
		from .QToolWindowCustomWrapper import QToolWindowCustomWrapper
		return self.isWrapper ( w ) and ( cast ( w, [ QToolWindowWrapper, QToolWindowCustomWrapper ] ) == self.mainWrapper or cast ( w.parentWidget (), [ QToolWindowWrapper, QToolWindowCustomWrapper ] ) == self.mainWrapper )

	def isFloatingWrapper ( self, w ) -> bool:
		if not self.isWrapper ( w ):
			return False
		from .QToolWindowWrapper import QToolWindowWrapper
		from .QToolWindowCustomWrapper import QToolWindowCustomWrapper
		if cast ( w, [ QToolWindowWrapper, QToolWindowCustomWrapper ] ) and cast ( w, [ QToolWindowWrapper, QToolWindowCustomWrapper ] ) != self.mainWrapper:
			return True
		return not cast ( w, QSplitter ) and cast ( w.parentWidget (),
		                                                        [ QToolWindowWrapper, QToolWindowCustomWrapper ] ) and cast ( w.parentWidget (), [ QToolWindowWrapper, QToolWindowCustomWrapper ] ) != self.mainWrapper

	def saveState ( self ):
		result = {}
		result[ "toolWindowManagerStateFormat" ] = 2
		if self.mainWrapper.getContents () and self.mainWrapper.getContents ().metaObject ():
			result[ "mainWrapper" ] = self.saveWrapperState ( self.mainWrapper )

		floatingWindowsData = []
		for wrapper in self.wrappers:
			if wrapper.getWidget ().isWindow () and wrapper.getContents () and wrapper.getContents ().metaObject ():
				m = self.saveWrapperState ( wrapper )
				if len ( m ) != 0:
					floatingWindowsData.append ( m )

		result[ "floatingWindows" ] = floatingWindowsData
		return result

	def restoreState ( self, data ):
		if data is None:
			return
		stateFormat = data[ "toolWindowManagerStateFormat" ]
		if stateFormat != 1 and stateFormat != 2:
			qWarning ( "state format is not recognized" )
			return

		self.suspendLayoutNotifications ()
		self.mainWrapper.getWidget ().hide ()
		for wrapper in self.wrappers:
			wrapper.getWidget ().hide ()
		self.moveToolWindow ( self.toolWindows, None, QToolWindowAreaReference.Hidden )
		self.simplifyLayout ( True )
		self.mainWrapper.setContents ( None )
		self.restoreWrapperState ( data[ "mainWrapper" ], stateFormat, self.mainWrapper )
		for windowData in data[ "floatingWindows" ]:
			self.restoreWrapperState ( windowData, stateFormat )
		self.simplifyLayout ()
		for toolWindow in self.toolWindows:
			self.toolWindowVisibilityChanged.emit ( toolWindow, toolWindow.parentWidget () != None )
		self.resumeLayoutNotifications ()
		self.notifyLayoutChange ()

	def isAnyWindowActive ( self ) -> bool:
		for tool in self.toolWindows:
			if tool.isAnyWindowActive ():
				return True
		return False

	def updateDragPosition ( self ):
		# if self.draggedWrapper == None:
		# 	return
		if not self.dragInProgress (): return
		if not QApplication.mouseButtons () & Qt.LeftButton :
			self.finishDrag ()
			return

		# print ( "[QToolWindowManager] updateDragPosition" )

		# self.draggedWrapper.getWidget ().raise_ ()
		pos = QCursor.pos ()
		self.dragIndicator.move ( pos + QPoint ( 1, 1 ) )

		# hoveredWindow = windowBelow ( self.draggedWrapper.getWidget () )
		hoveredWindow = QApplication.topLevelAt( pos )
		# if hoveredWindow != None and hoveredWindow != self.draggedWrapper.window ():
		if hoveredWindow != None:
			handlerWidget = hoveredWindow.childAt ( hoveredWindow.mapFromGlobal ( QCursor.pos () ) )
			if handlerWidget != None and not self.dragHandler.isHandlerWidget ( handlerWidget ):
				area = self.getClosestParentArea ( handlerWidget )
				if area != None and self.lastArea != area:
					self.dragHandler.switchedArea ( self.lastArea, area )
					self.lastArea = area
					delayTime = self.config.setdefault ( QTWM_RAISE_DELAY, 500 )
					self.raiseTimer.stop ()
					if delayTime > 0:
						self.raiseTimer.start ( delayTime )

		target = self.dragHandler.getTargetFromPosition ( self.lastArea )
		if self.lastArea != None and target.reference != QToolWindowAreaReference.Floating:
			if QToolWindowAreaReference.isOuter ( target.reference ):
				from QToolWindowManager.QToolWindowCustomWrapper import QToolWindowCustomWrapper
				previewArea = findClosestParent ( self.lastArea.getWidget (), [ QToolWindowWrapper, QToolWindowCustomWrapper ] )
				previewAreaContents = previewArea.getContents ()
				self.preview.setParent ( previewArea.getWidget () )
				self.preview.setGeometry (
					self.dragHandler.getRectFromCursorPos ( previewAreaContents, self.lastArea ).translated (
						previewAreaContents.pos () ) )
			else:
				previewArea = self.lastArea.getWidget ()
				self.preview.setParent ( previewArea )
				self.preview.setGeometry ( self.dragHandler.getRectFromCursorPos ( previewArea, self.lastArea ) )

			self.preview.show ()
		else:
			self.preview.hide ()

		self.updateTrackingTooltip.emit ( self.textForPosition ( target.reference ),
		                                  QCursor.pos () + self.config.setdefault ( QTWM_TOOLTIP_OFFSET, QPoint ( 1, 20 ) ) )

	def finishDrag ( self ):
		if not self.dragInProgress ():
			qWarning( 'unexpected finishDrag' )
			return

		target = self.dragHandler.finishDrag ( self.draggedToolWindows, None, self.lastArea )
		self.lastArea = None

		area = self.draggedArea
		self.draggedArea = None
		self.raiseTimer.stop ()
		self.preview.setParent ( None )
		self.preview.hide ()

		contents = area
		toolWindows = self.draggedToolWindows

		if target.reference != QToolWindowAreaReference.Floating:
			contents = area

			if target.reference == QToolWindowAreaReference.Top or \
					target.reference == QToolWindowAreaReference.Bottom or \
					target.reference == QToolWindowAreaReference.Left or \
					target.reference == QToolWindowAreaReference.Right:
				self.splitArea ( self.getFurthestParentArea ( target.area.getWidget () ).getWidget (), target.reference, contents )
			elif target.reference == QToolWindowAreaReference.HSplitTop or \
					target.reference == QToolWindowAreaReference.HSplitBottom or \
					target.reference == QToolWindowAreaReference.VSplitLeft or \
					target.reference == QToolWindowAreaReference.VSplitRight:
				self.splitArea ( target.area.getWidget (), target.reference, contents )
			elif target.reference == QToolWindowAreaReference.Combine:
				self.moveToolWindowsTarget ( toolWindows, target )

			# wrapper.getWidget ().close ()
			self.simplifyLayout ()

		if target.reference != QToolWindowAreaReference.Combine:
			for w in toolWindows:
				self.toolWindowVisibilityChanged.emit ( w, True )

		if target.reference != QToolWindowAreaReference.Floating:
			self.notifyLayoutChange ()

		if target.reference == QToolWindowAreaReference.Floating:
			self.moveToolWindowsTarget ( toolWindows, target )

		self.updateTrackingTooltip.emit ( "", QPoint () )

		self.dragIndicator.hide ()
		self.draggedToolWindows = []

	def finishWrapperDrag ( self ):
		target = self.dragHandler.finishDrag ( self.draggedToolWindows, None, self.lastArea )
		self.lastArea = None

		wrapper = self.draggedWrapper
		self.draggedWrapper = None
		self.raiseTimer.stop ()
		self.preview.setParent ( None )
		self.preview.hide ()

		if wrapper is None:
			qWarning ( "[QToolWindowManager] finishWrapperDrag wrapper == None." )
			return

		# print ( "[QToolWindowManager] finishWrapperDrag %s %s" % ( self.draggedWrapper, self.draggedToolWindows ) )

		contents = wrapper.getContents ()
		toolWindows = []
		contentsWidgets = contents.findChildren ( QWidget )
		contentsWidgets.append ( contents )

		for w in contentsWidgets:
			area = cast ( w, [ QToolWindowArea, QToolWindowRollupBarArea ] )
			if area != None and self.ownsArea ( area ):
				toolWindows += area.toolWindows ()

		if target.reference != QToolWindowAreaReference.Floating:
			contents = wrapper.getContents ()
			wrapper.setContents ( None )

			if target.reference == QToolWindowAreaReference.Top or \
					target.reference == QToolWindowAreaReference.Bottom or \
					target.reference == QToolWindowAreaReference.Left or \
					target.reference == QToolWindowAreaReference.Right:
				self.splitArea ( self.getFurthestParentArea ( target.area.getWidget () ).getWidget (), target.reference,
				                 contents )
			elif target.reference == QToolWindowAreaReference.HSplitTop or \
					target.reference == QToolWindowAreaReference.HSplitBottom or \
					target.reference == QToolWindowAreaReference.VSplitLeft or \
					target.reference == QToolWindowAreaReference.VSplitRight:
				self.splitArea ( target.area.getWidget (), target.reference, contents )
			elif target.reference == QToolWindowAreaReference.Combine:
				self.moveToolWindowsTarget ( toolWindows, target )

			wrapper.getWidget ().close ()
			self.simplifyLayout ()

		if target.reference != QToolWindowAreaReference.Combine:
			for w in toolWindows:
				self.toolWindowVisibilityChanged.emit ( w, True )

		if target.reference != QToolWindowAreaReference.Floating:
			self.notifyLayoutChange ()

		self.updateTrackingTooltip.emit ( "", QPoint () )

	def finishWrapperResize ( self ):
		toolWindows = []
		contents = self.resizedWrapper.getContents ()
		contentsWidgets = contents.findChildren ( QWidget )
		contentsWidgets.append ( contents )

		for w in contentsWidgets:
			area = cast ( w, [ QToolWindowArea, QToolWindowRollupBarArea ] )
			if area and self.ownsArea ( area ):
				toolWindows.append ( area.toolWindows () )

		for w in toolWindows:
			self.toolWindowVisibilityChanged.emit ( w, True )

		self.resizedWrapper = None

	def saveWrapperState ( self, wrapper ):
		if wrapper.getContents () == None:
			qWarning ( "[QToolWindowManager] saveWrapperState Empty top level wrapper." )
			return {}

		result = {}
		result[ "geometry" ] = wrapper.getWidget ().saveGeometry ().toBase64 ()
		result[ "name" ] = wrapper.getWidget ().objectName ()

		obj = wrapper.getContents ()
		if cast ( obj, QSplitter ):
			result[ "splitter" ] = self.saveSplitterState ( obj )
			return result

		if isinstance ( obj, QToolWindowArea ):
			result[ "area" ] = obj.saveState ()
			return result

		qWarning ( "[QToolWindowManager] saveWrapperState Couldn't find valid child widget" )
		return {}

	def restoreWrapperState ( self, data, stateFormat, wrapper = None ):
		newContents = None

		if wrapper and data[ "name" ]:
			wrapper.getWidget ().setObjectName ( data[ "name" ] )

		if data[ "splitter" ]:
			newContents = self.restoreSplitterState ( data[ "splitter" ], stateFormat )
		elif data[ "area" ]:
			areaType = QTWMWrapperAreaType.watTabs
			if data[ "area" ][ "type" ] and data[ "area" ][ "type" ] == "rollup":
				areaType = QTWMWrapperAreaType.watRollups

			area = self.createArea ( areaType )
			area.restoreState ( data[ "area" ], stateFormat )
			if area.count () > 0:
				newContents = area.getWidget ()
			else:
				area.deleteLater ()

		if not wrapper:
			if newContents:
				wrapper = self.createWrapper ()
				if data[ "name" ]:
					wrapper.getWidget ().setObjectName ( data[ "name" ] )
			else:
				return None

		wrapper.setContents ( newContents )

		if stateFormat == 1:
			if data[ "geometry" ]:
				if not wrapper.getWidget ().restoreGeometry ( data[ "geometry" ] ):
					print ( "Failed to restore wrapper geometry" )
		elif stateFormat == 2:
			if data[ "geometry" ]:
				if not wrapper.getWidget ().restoreGeometry ( QByteArray.fromBase64 ( data[ "geometry" ] ) ):
					print ( "Failed to restore wrapper geometry" )
		else:
			print ( "Unknown state format" )

		if data[ "geometry" ]:
			wrapper.getWidget ().show ()

		return wrapper

	def saveSplitterState ( self, splitter ):
		result = {}
		result[ "state" ] = splitter.saveState ().toBase64 ()
		result[ "type" ] = "splitter"
		items = []
		for i in range ( splitter.count () ):
			item = splitter.widget ( i )
			itemValue = {}
			area = item
			if area != None:
				itemValue = area.saveState ()
			else:
				childSplitter = item
				if childSplitter:
					itemValue = self.saveSplitterState ( childSplitter )
				else:
					qWarning ( "[QToolWindowManager] saveSplitterState Unknown splitter item" )
			items.append ( itemValue )
		result[ "items" ] = items
		return result

	def restoreSplitterState ( self, data, stateFormat ):
		if len ( data[ "items" ] ) < 2:
			print ( "Invalid splitter encountered" )
			if len ( data[ "items" ] ) == 0:
				return None

		splitter = self.createSplitter ()

		for itemData in data[ "items" ]:
			itemValue = itemData
			itemType = itemValue[ "type" ]
			if itemType == "splitter":
				w = self.restoreSplitterState ( itemValue, stateFormat )
				if w:
					splitter.addWidget ( w )
			elif itemType == "area":
				area = self.createArea ()
				area.restoreState ( itemValue, stateFormat )
				splitter.addWidget ( area.getWidget () )
			elif itemType == "rollup":
				area = self.createArea ()
				area.restoreState ( itemValue, stateFormat )
				splitter.addWidget ( area.getWidget () )
			else:
				print ( "Unknown item type" )

		if stateFormat == 1:
			if data[ "state" ]:
				if not splitter.restoreState ( data[ "state" ] ):
					print ( "Failed to restore splitter state" )
		elif stateFormat == 2:
			if data[ "state" ]:
				if not splitter.restoreState ( QByteArray.fromBase64 ( data[ "state" ] ) ):
					print ( "Failed to restore splitter state" )

		else:
			print ( "Unknown state format" )

		return splitter

	def resizeSplitter ( self, widget, sizes ):
		s = cast ( widget, QSplitter )
		if s == None:
			s = findClosestParent ( widget, QSplitter )
		if s == None:
			qWarning ( "Could not find a matching splitter!" )
			return

		scaleFactor = s.width () if s.orientation () == QtCore.Qt.Horizontal else s.height ()

		for i in range ( 0, len ( sizes ) ):
			sizes[ i ] *= scaleFactor

		s.setSizes ( sizes )

	def createArea ( self, areaType = QTWMWrapperAreaType.watTabs ):
		# qWarning ( "[QToolWindowManager] createArea %s" % areaType )
		a = self.factory.createArea ( self, None, areaType )
		self.lastArea = a
		self.areas.append ( a )
		return a

	def createWrapper ( self ):
		w = self.factory.createWrapper ( self )
		name = None
		while True:
			i = QtCore.qrand ()
			name = "wrapper#%s" % i
			for w2 in self.wrappers:
				if name == w2.getWidget ().objectName ():
					continue
			break
		w.getWidget ().setObjectName ( name )
		self.wrappers.append ( w )
		return w

	def getNotifyLock ( self, allowNotify = True ):
		return QTWMNotifyLock ( self, allowNotify )

	def hide ( self ):
		self.mainWrapper.getWidget ().hide ()

	def show ( self ):
		self.mainWrapper.getWidget ().show ()

	def clear ( self ):
		self.releaseToolWindows ( self.toolWindows, True )
		if len ( self.areas ) != 0:
			self.lastArea = self.areas[ 0 ]
		else:
			self.lastArea = None

	def bringAllToFront ( self ):
		# TODO: Win64 / OSX
		from QToolWindowManager.QToolWindowCustomWrapper import QToolWindowCustomWrapper
		list = qApp.topLevelWidgets ()
		for w in list:
			if w != None and not w.windowState ().testFlag ( QtCore.Qt.WindowMinimized ) and ( isinstance ( w, QToolWindowWrapper ) or isinstance ( w, QToolWindowCustomWrapper ) or isinstance ( w, QCustomWindowFrame ) ):
				w.show ()
				w.raise_ ()

	def bringToFront ( self, toolWindow ):
		area = self.areaOf ( toolWindow )
		if not area:
			return
		while area.indexOf ( toolWindow ) == -1:
			toolWindow = toolWindow.parentWidget ()
		area.setCurrentWidget ( toolWindow )

		window = area.getWidget ().window ()
		window.setWindowState ( window.windowState () & ~QtCore.Qt.WindowMinimized )
		window.show ()
		window.raise_ ()
		window.activateWindow ()

		toolWindow.setFocus ()

	def getToolPath ( self, toolWindow ):
		w = toolWindow
		result = ''
		pw = w.parentWidget ()
		while pw:
			if isinstance ( pw, QSplitter ):
				orientation = None
				if pw.orientation () == QtCore.Qt.Horizontal:
					orientation = 'h'
				else:
					orientation = 'v'
				result += "/%c/%d" % (orientation, pw.indexOf ( w ))
			elif isinstance ( pw, QToolWindowWrapper ):
				result += toolWindow.window ().objectName ()
				break
			w = pw
			pw = w.parentWidget ()
		return result

	def targetFromPath ( self, toolPath ) -> QToolWindowAreaTarget:
		for w in self.areas:
			if w.count () < 0 and self.getToolPath ( w.widget ( 0 ) ) == toolPath:
				return QToolWindowAreaTarget.createByArea ( w, QToolWindowAreaReference.Combine )
		return QToolWindowAreaTarget ( QToolWindowAreaReference.Floating )

	def eventFilter ( self, o, e ):
		"""Summary line.

		Args:
			o (QObject): Description of param1
			e (QEvent): Description of param2
	    """
		if o == qApp:
			if e.type () == QEvent.ApplicationActivate and (
					self.config.setdefault ( QTWM_WRAPPERS_ARE_CHILDREN, False )) and (
					self.config.setdefault ( QTWM_BRING_ALL_TO_FRONT, True )):
				self.bringAllToFront ()
			return False

		if e.type () == 16: # event Destroy
			w = cast ( o, QWidget )
			if not self.closingWindow and self.ownsToolWindow ( w ) and w.isVisible ():
				self.releaseToolWindow ( w, True )
				return False

		# if self.draggedWrapper and o == self.draggedWrapper:
		# 	if e.type () == QEvent.MouseMove:
		# 		qWarning ( "Manager eventFilter: send MouseMove" )
		# 		qApp.sendEvent ( self.draggedWrapper, e )

		# print ( "QToolWindowManager::eventFilter", type ( o ), EventTypes ().as_string ( e.type () ) )

		# if self.draggedWrapper and o == self.draggedWrapper:
		# 	if e.type () == QEvent.MouseButtonRelease:
		# 		qWarning ( f"Manager eventFilter: send MouseButtonRelease {self.draggedWrapper}" )

		# if e.type () == Qt.QEvent.Destroy:
		# 	if not self.closingWindow and self.ownsToolWindow ( w ) and w.isVisible ():
		# 		self.releaseToolWindow ( w, True )
		# 		return False

		return super ().eventFilter ( o, e )

	def event ( self, e ):
		if e.type () == QEvent.StyleChange:
			if self.parentWidget () and self.parentWidget ().styleSheet () != self.styleSheet ():
				self.setStyleSheet ( self.parentWidget ().styleSheet () )

		return super ().event ( e )

	def tryCloseToolWindow ( self, toolWindow ):
		self.closingWindow += 1
		result = True

		if not toolWindow.close ():
			qWarning ( "Widget could not be closed" )
			result = False

		self.closingWindow -= 1
		return result

	def createSplitter ( self ) -> QSplitter:
		return self.factory.createSplitter ( self )

	def splitArea ( self, area, reference, insertWidget = None ):
		from .QToolWindowWrapper import QToolWindowWrapper
		from .QToolWindowCustomWrapper import QToolWindowCustomWrapper

		residingWidget = insertWidget
		if residingWidget == None:
			residingWidget = self.createArea ().getWidget ()

		if not QToolWindowAreaReference.requiresSplit ( reference ):
			qWarning ( "Invalid reference for area split" )
			return None

		forceOuter = QToolWindowAreaReference.isOuter ( reference )
		reference = reference & 0x3
		parentSplitter = None
		targetWrapper = findClosestParent ( area, [ QToolWindowWrapper, QToolWindowCustomWrapper ] )
		if not forceOuter:
			parentSplitter = cast ( area.parentWidget (), QSplitter )
		if parentSplitter == None and targetWrapper == None:
			qWarning ( "Could not determine area parent" )
			return None
		useParentSplitter = False
		targetIndex = 0
		parentSizes = [ QSize () ]
		if parentSplitter != None:
			parentSizes = parentSplitter.sizes ()
			targetIndex += parentSplitter.indexOf ( area )
			useParentSplitter = parentSplitter.orientation () == QToolWindowAreaReference.splitOrientation ( reference )

		if useParentSplitter:
			origIndex = targetIndex
			targetIndex += reference & 0x1
			newSizes = self.dragHandler.getSplitSizes ( parentSizes[ origIndex ] )
			parentSizes[ origIndex ] = newSizes.oldSize
			parentSizes.insert ( targetIndex, newSizes.newSize )
			parentSplitter.insertWidget ( targetIndex, residingWidget )
			parentSplitter.setSizes ( parentSizes )
			return residingWidget

		splitter = self.createSplitter ()
		splitter.setOrientation ( QToolWindowAreaReference.splitOrientation ( reference ) )

		if forceOuter or area == targetWrapper.getContents ():
			firstChild = targetWrapper.getContents ()
			targetWrapper.setContents ( None )
			splitter.addWidget ( firstChild )
		else:
			area.hide ()
			area.setParent ( None )
			splitter.addWidget ( area )
			area.show ()

		splitter.insertWidget ( reference & 0x1, residingWidget )
		if parentSplitter != None:
			parentSplitter.insertWidget ( targetIndex, splitter )
			parentSplitter.setSizes ( parentSizes )
		else:
			targetWrapper.setContents ( splitter )

		sizes = []
		baseSize = splitter.height () if splitter.orientation () == QtCore.Qt.Vertical else splitter.width ()
		newSizes = self.dragHandler.getSplitSizes ( baseSize )
		sizes.append ( newSizes.oldSize )
		sizes.insert ( reference & 0x1, newSizes.newSize )
		splitter.setSizes ( sizes )

		contentsWidgets = residingWidget.findChildren ( QWidget )
		for w in contentsWidgets:
			qApp.sendEvent ( w, QEvent ( QEvent.ParentChange ) )

		return residingWidget

	def getClosestParentArea ( self, widget ):
		area = findClosestParent ( widget, [ QToolWindowArea, QToolWindowRollupBarArea ] )
		while area != None and not self.ownsArea ( area ):
			area = findClosestParent ( area.getWidget ().parentWidget (), [ QToolWindowArea, QToolWindowRollupBarArea ] )

		# qWarning ( "[QToolWindowManager] getClosestParentArea %s is %s" % ( widget, area ) )

		return area

	def getFurthestParentArea ( self, widget ):
		area = findClosestParent ( widget, [ QToolWindowArea, QToolWindowRollupBarArea ] )
		previousArea = area
		while area != None and not self.ownsArea ( area ):
			area = findClosestParent ( area.getWidget ().parentWidget (), [ QToolWindowArea, QToolWindowRollupBarArea ] )

			if area == None:
				return previousArea
			else:
				previousArea = area

		# qWarning ( "getFurthestParentArea %s is %s" % ( widget, area ) )

		return area

	def textForPosition ( self, reference ):
		texts = [
			"Place at top of window",
			"Place at bottom of window",
			"Place on left side of window",
			"Place on right side of window",
			"Split horizontally, place above",
			"Split horizontally, place below",
			"Split vertically, place left",
			"Split vertically, place right",
			"Add to tab list",
			""
		]
		return texts[ reference ]

	def simplifyLayout ( self, clearMain = False ):
		from .QToolWindowWrapper import QToolWindowWrapper
		from .QToolWindowCustomWrapper import QToolWindowCustomWrapper

		self.suspendLayoutNotifications ()
		madeChanges = True # Some layout changes may require multiple iterations to fully simplify.

		while madeChanges:
			madeChanges = False
			areasToRemove = []
			for area in self.areas:
				# remove empty areas (if this is only area in main wrapper, only remove it when we explicitly ask for that)
				if area.count () == 0 and ( clearMain or cast ( area.parent (), [ QToolWindowWrapper, QToolWindowCustomWrapper ] ) != self.mainWrapper ):
					areasToRemove.append ( area )
					madeChanges = True

				s = cast ( area.parentWidget (), QSplitter )
				while s != None and s.parentWidget () != None:
					sp_s = cast ( s.parentWidget (), QSplitter )
					sp_w = cast ( s.parentWidget (), [ QToolWindowWrapper, QToolWindowCustomWrapper ] )
					sw = findClosestParent ( s, [ QToolWindowWrapper, QToolWindowCustomWrapper ] )

					# If splitter only contains one object, replace the splitter with the contained object
					if s.count () == 1:
						if sp_s != None:
							index = sp_s.indexOf ( s )
							sizes = sp_s.sizes ()
							sp_s.insertWidget ( index, s.widget ( 0 ) )
							s.hide ()
							s.setParent ( None )
							s.deleteLater ()
							sp_s.setSizes ( sizes )
							madeChanges = True
						elif sp_w != None:
							sp_w.setContents ( s.widget ( 0 ) )
							s.setParent ( None )
							s.deleteLater ()
							madeChanges = True
						else:
							qWarning ( "Unexpected splitter parent" )

					# If splitter's parent is also a splitter, and both have same orientation, replace splitter with contents
					elif sp_s != None and s.orientation () == sp_s.orientation ():
						index = sp_s.indexOf ( s )
						newSizes = sp_s.sizes ()
						oldSizes = s.sizes ()
						newSum = newSizes[ index ]
						oldSum = 0
						for i in oldSizes:
							oldSum += i
						for i in range ( len ( oldSizes ) - 1, -1, -1 ):
							sp_s.insertWidget ( index, s.widget ( i ) )
							newSizes.insert ( index, oldSizes[ i ] / oldSum * newSum )
						s.hide ()
						s.setParent ( None )
						s.deleteLater ()
						sp_s.setSizes ( newSizes )
						madeChanges = True

					s = sp_s

			for area in areasToRemove:
				area.hide ()
				aw = cast ( area.parentWidget (), [ QToolWindowWrapper, QToolWindowCustomWrapper ] )
				if aw != None:
					aw.setContents ( None )

				area.setParent ( None )
				self.areas.remove ( area )
				area.deleteLater ()

		wrappersToRemove = []
		for wrapper in self.wrappers:
			if wrapper.getWidget ().isWindow () and wrapper.getContents () == None:
				wrappersToRemove.append ( wrapper )

		for wrapper in wrappersToRemove:
			self.wrappers.remove ( wrapper )
			wrapper.hide ()
			wrapper.deferDeletion ()

		for area in self.areas:
			area.adjustDragVisuals ()

		self.resumeLayoutNotifications ()
		self.notifyLayoutChange ()

	def dragInProgress( self ):
		'''
		指示当前是否正处于拖拽状态
		'''
		return len ( self.draggedToolWindows ) > 0

	def createDragHandler ( self ):
		if self.dragHandler != None:
			del self.dragHandler
		return self.factory.createDragHandler ( self )

	def suspendLayoutNotifications ( self ):
		self.layoutChangeNotifyLocks += 1

	def resumeLayoutNotifications ( self ):
		if self.layoutChangeNotifyLocks > 0:
			self.layoutChangeNotifyLocks -= 1

	def notifyLayoutChange ( self ):
		if self.layoutChangeNotifyLocks == 0:
			QtCore.QMetaObject.invokeMethod ( self, 'layoutChanged', QtCore.Qt.QueuedConnection )

	def insertToToolTypes ( self, tool, toolType ):
		if tool not in self.toolWindowsTypes:
			self.toolWindowsTypes[ tool ] = toolType

	def raiseCurrentArea ( self ):
		if self.lastArea:
			w = self.lastArea.getWidget ()
			while w.parentWidget () and not w.isWindow ():
				w = w.parentWidget ()
			w.raise_ ()
			self.updateDragPosition ()
		self.raiseTimer.stop ()


class QSizePreservingSplitter ( QSplitter ):

	def __init__ ( self, parent = None ):
		super ( QSizePreservingSplitter, self ).__init__ ( parent )

	def childEvent ( self, c ):
		"""Summary line.
		Args:
			c (QChildEvent): Description of param1
	    """
		if c.type () == QEvent.ChildRemoved:
			l = self.sizes ()
			i = self.indexOf ( cast ( c.child (), QWidget ) )
			if i != -1 and len ( l ) > 1:
				s = l[ i ] + self.handleWidth ()
				if i == 0:
					l[ 1 ] = l[ 1 ] + s
				else:
					l[ i - 1 ] = l[ i - 1 ] + s
				l.pop ( i )
				super ().childEvent ( c )
				self.setSizes ( l )
			else:
				super ( QSizePreservingSplitter, self ).childEvent ( c )
		else:
			super ( QSizePreservingSplitter, self ).childEvent ( c )


#TEST
if __name__ == '__main__':
	import sys
	app = QApplication ( sys.argv )
	app.setStyleSheet (
		open ( '/Users/Kanbaru/GitWorkspace/CandyEditor/resources/theme/CryEngineVStyleSheet.qss' ).read ()
	)

	class Test ( QMainWindow ):
		def __init__ ( self, *args ):
			super ( Test, self ).__init__ ( *args )

			toolConfig = {}
			toolConfig[ QTWM_AREA_DOCUMENT_MODE ] = True
			toolConfig[ QTWM_AREA_IMAGE_HANDLE ] = False
			toolConfig[ QTWM_AREA_SHOW_DRAG_HANDLE ] = False
			toolConfig[ QTWM_AREA_TABS_CLOSABLE ] = False
			toolConfig[ QTWM_AREA_EMPTY_SPACE_DRAG ] = True
			toolConfig[ QTWM_THUMBNAIL_TIMER_INTERVAL ] = 1000
			toolConfig[ QTWM_TOOLTIP_OFFSET ] = QPoint ( 1, 20 )
			toolConfig[ QTWM_AREA_TAB_ICONS ] = True
			toolConfig[ QTWM_RELEASE_POLICY ] = QTWMReleaseCachingPolicy.rcpWidget
			toolConfig[ QTWM_WRAPPERS_ARE_CHILDREN ] = False
			toolConfig[ QTWM_RAISE_DELAY ] = 750
			toolConfig[ QTWM_RETITLE_WRAPPER ] = True
			toolConfig[ QTWM_SINGLE_TAB_FRAME ] = False
			toolConfig[ QTWM_BRING_ALL_TO_FRONT ] = True
			toolConfig[ "sandboxMinimizeIcon" ] = QIcon ( "./resources/icons/window_minimize.ico" )
			toolConfig[ "sandboxMaximizeIcon" ] = QIcon ( "./resources/icons/window_maximize.ico" )
			toolConfig[ "sandboxRestoreIcon" ] = QIcon ( "./resources/icons/window_restore.ico" )
			toolConfig[ "sandboxWindowCloseIcon" ] = QIcon ( "./resources/icons/window_close.ico" )
			toolConfig[ QTWM_TAB_CLOSE_ICON ] = QIcon ( "./resources/icons/window_close.ico" )
			toolConfig[ QTWM_SINGLE_TAB_FRAME_CLOSE_ICON ] = QIcon ( "./resources/icons/window_close.ico" )

			from QToolWindowManager.QMainFrame import CToolWindowManagerClassFactory
			mgr = QToolWindowManager ( self, toolConfig, CToolWindowManagerClassFactory () )
			self.setCentralWidget ( mgr )

			widget = QPushButton ( 'hello' )
			widget.setWindowTitle ( 'hello' )
			widget.setObjectName ( 'hello' )
			mgr.addToolWindow ( widget, None, QToolWindowAreaReference.Floating )

			widget = QPushButton( 'world' )
			widget.setWindowTitle( 'world' )
			widget.setObjectName( 'world' )
			mgr.addToolWindow ( widget, None, QToolWindowAreaReference.Top )

			widget = QPushButton( 'happy' )
			widget.setWindowTitle( 'happy' )
			widget.setObjectName( 'happy' )
			mgr.addToolWindow ( widget, None, QToolWindowAreaReference.Floating )

			widget = QPushButton( 'goodness' )
			widget.setWindowTitle( 'goodness' )
			widget.setObjectName( 'goodness' )
			mgr.addToolWindow ( widget, None, QToolWindowAreaReference.Floating )

			# result = mgr.saveState ()
			# for w in mgr.toolWindows:
			# 	mgr.moveToolWindow ( w, None, QToolWindowAreaReference.Combine )
			# mgr.restoreState ( result )
			# area = mgr.areaOf ( widget )
			# mgr.hideToolWindow ( widget )
			# area.addToolWindow ( widget )

	window = Test ()
	window.show ()
	window.raise_ ()
	app.exec_ ()
