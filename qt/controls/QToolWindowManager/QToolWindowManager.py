# Copyright 2001-2019 Crytek GmbH / Crytek Group. All rights reserved.
from enum import Enum
from PyQt5 import Qt, QtCore
from PyQt5.QtCore import QTimer, QRect, QPoint, QByteArray, pyqtSignal
from PyQt5.QtGui import QCursor
from PyQt5.QtWidgets import QRubberBand, QVBoxLayout, QSplitter, QWidget, qApp

from qt.controls.QToolWindowManager.QToolWindowManagerCommon import *
from qt.controls.QToolWindowManager.QCustomWindowFrame import QCustomTitleBar
from qt.controls.QToolWindowManager.QToolWindowArea import QToolWindowArea
from qt.controls.QToolWindowManager.QToolWindowRollupBarArea import QToolWindowRollupBarArea
from qt.controls.QToolWindowManager.QToolWindowWrapper import QToolWindowWrapper
from qt.controls.QToolWindowManager.QToolWindowDragHandlerDropTargets import QToolWindowDragHandlerDropTargets


class QToolWindowAreaReference:
	class Type ( Enum ):
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

	def __init__ ( self, eType ):
		self.type = eType or QToolWindowAreaReference.Type.Combine

	def isOuter ( self ):
		return self.type <= QToolWindowAreaReference.Type.Right

	def requiresSplit ( self ):
		return self.type < QToolWindowAreaReference.Type.Combine

	def splitOrientation ( self ):
		if self.type == QToolWindowAreaReference.Type.Top or \
				self.type == QToolWindowAreaReference.Type.Bottom or \
				self.type == QToolWindowAreaReference.Type.HSplitTop or \
				self.type == QToolWindowAreaReference.Type.HSplitBottom:
			return QtCore.Qt.Vertical
		if self.type == QToolWindowAreaReference.Type.Left or \
				self.type == QToolWindowAreaReference.Type.Right or \
				self.type == QToolWindowAreaReference.Type.VSplitLeft or \
				self.type == QToolWindowAreaReference.Type.VSplitRight:
			return QtCore.Qt.Horizontal
		if self.type == QToolWindowAreaReference.Type.Combine or \
				self.type == QToolWindowAreaReference.Type.Floating or \
				self.type == QToolWindowAreaReference.Type.Hidden:
			return 0


class QToolWindowAreaTarget:

	def __init__ ( self, area, reference, index = -1, geometry = QRect () ):
		self.area = area
		self.reference = reference
		self.index = index
		self.geometry = geometry


class QToolWindowManagerClassFactory ( QtCore.QObject ):

	def createArea ( self, manager, parent, areaType ):
		"""Summary line.

		Args:
			manager (QToolWindowManager): Description of param1
			parent (QWidget): Description of param2
			areaType (QTWMWrapperAreaType): Description of param2

	    Returns:
	        QToolWindowArea: Description of return value
	    """
		if manager.config.value ( QTWM_SUPPORT_SIMPLE_TOOLS,
		                          False ) and areaType == QTWMWrapperAreaType.watRollups:
			return QToolWindowRollupBarArea ( manager, parent )
		else:
			return QToolWindowArea ( manager, parent )

	def createWrapper ( self, manager ):
		return QToolWindowWrapper ( manager, QtCore.Qt.Tool )

	def createDragHandler ( self, manager ):
		return QToolWindowDragHandlerDropTargets ( manager )

	def createSplitter ( self, manager ):
		splitter = None
		if manager.config.value ( QToolWindowManagerCommon.QTWM_PRESERVE_SPLITTER_SIZES,
		                          True ):
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
	areas = [ ]
	wrappers = [ ]
	toolWindows = [ ]
	toolWindowsTypes = { }
	draggedToolWindows = [ ]
	layoutChangeNotifyLocks = 0
	toolWindowVisibilityChanged = pyqtSignal ( QWidget, bool )
	layoutChanged = pyqtSignal ()
	updateTrackingTooltip = pyqtSignal ( str, QPoint )

	def __init__ ( self, parent, config, factory = None ):
		super ().__init__ ( parent )
		self.factory = factory or QToolWindowManagerClassFactory ()
		self.dragHandler = None
		self.config = config
		self.closingWindow = 0

		if self.factory.parent () != None:
			self.factory.setParent ( self )

		self.mainWrapper = QToolWindowWrapper ( self )
		self.mainWrapper.getWidget ().setObjectName ( 'mainWrapper' )
		self.setLayout ( QVBoxLayout ( self ) )
		self.layout ().setContentsMargins ( 2, 2, 2, 2 )
		self.layout ().setSpacing ( 0 )
		self.layout ().addWidget ( self.mainWrapper.getWidget () )
		self.lastArea = self.createArea ()
		self.draggedWrapper = None
		self.resizedWrapper = None
		self.mainWrapper.setContents ( self.lastArea.getWidget () )

		self.dragHandler = self.createDragHandler ()

		self.preview = QRubberBand ( QRubberBand.Rectangle )
		self.preview.hide ()

		self.raiseTimer = QTimer ( self )
		self.raiseTimer.timeout.connect ( self.raiseCurrentArea )
		self.setSizePolicy ( Qt.QSizePolicy.Expanding, Qt.QSizePolicy.Expanding )

		QtCore.QCoreApplication.instance ().installEventFilter ( self )

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

	def empty ( self ):
		return len ( self.areas ) == 0

	def removeArea ( self, area ):
		self.areas.remove ( area )
		if self.lastArea == area:
			self.lastArea = None

	def removeWrapper ( self, wrapper ):
		self.wrappers.remove ( wrapper )

	def ownsArea ( self, area ):
		return self.areas.contains ( area )

	def ownsWrapper ( self, wrapper ):
		return self.wrappers.contains ( wrapper )

	def ownsToolWindow ( self, toolWindow ):
		return self.toolWindows.contains ( toolWindow )

	def startDrag ( self, toolWindows, area ):
		if len ( toolWindows ) == 0:
			return
		self.dragHandler.startDrag ()
		self.draggedToolWindows = toolWindows

		floatingGeometry = QRect ( QCursor.pos (), area.size () )
		self.moveToolWindows ( toolWindows, area, QToolWindowAreaReference.Type.Drag, -1, floatingGeometry )

	def startDragWrapper ( self, wrapper ):
		self.dragHandler.startDrag ()
		self.draggedWrapper = wrapper
		self.lastArea = None
		self.updateDragPosition ()

	def startResize ( self, wrapper ):
		self.resizedWrapper = wrapper

	def addToolWindowTarget ( self, toolWindow, target, toolType ):
		self.insertToToolTypes ( toolWindow, toolType )
		self.addToolWindow ( toolWindow, target.area, target.reference, target.index, target.geometry )

	def addToolWindow ( self, toolWindow, area = None, reference = QToolWindowAreaReference.Type.Combine, index = -1,
	                    geometry = QRect () ):
		self.addToolWindows ( [ toolWindow ], area, reference, index, geometry )

	def addToolWindowsTarget ( self, toolWindows, target, toolType ):
		for toolWindow in toolWindows:
			self.insertToToolTypes ( toolWindow, toolType )
		self.addToolWindows ( toolWindows, target.area, target.reference, target.index, target.geometry )

	def addToolWindows ( self, toolWindows, area = None, reference = QToolWindowAreaReference.Type.Combine, index = -1,
	                     geometry = QRect () ):
		for toolWindow in toolWindows:
			if self.ownsToolWindow ( toolWindow ):
				toolWindow.hide ()
				toolWindow.setParent ( None )
				toolWindow.installEventFilter ( self )
				self.insertToToolTypes ( toolWindow, QTWMToolType.ttStandard )
				self.toolWindows.append ( toolWindow )
		self.moveToolWindow ( toolWindows, area, reference, index, geometry )

	def moveToolWindowTarget ( self, toolWindow, target, toolType ):
		self.insertToToolTypes ( toolWindow, toolType )
		self.addToolWindow ( toolWindow, target.area, target.reference, target.index, target.geometry )

	def moveToolWindow ( self, toolWindow, area = None, reference = QToolWindowAreaReference.Type.Combine, index = -1,
	                     geometry = QRect () ):
		self.moveToolWindows ( [ toolWindow ], area, reference, index, geometry )

	def moveToolWindowsTarget ( self, toolWindows, target, toolType ):
		for toolWindow in toolWindows:
			self.insertToToolTypes ( toolWindow, toolType )
		self.addToolWindows ( toolWindows, target.area, target.reference, target.index, target.geometry )

	def moveToolWindows ( self, toolWindows, area = None, reference = QToolWindowAreaReference.Type.Combine, index = -1,
	                      geometry = QRect () ):
		if area == None:
			if self.lastArea:
				area = self.lastArea
			elif len ( self.areas ) != 0:
				area = self.areas[ 0 ]
			else:
				area = self.lastArea = self.createArea ()
				self.mainWrapper.setContents ( self.lastArea.getWidget () )

		dragOffset = QPoint ()
		if area and reference == QToolWindowAreaReference.Type.Drag:
			widgetPos = area.mapToGlobal ( area.rect ().topLeft () )
			dragOffset = widgetPos - QCursor.pos ()

		wrapper = None
		currentAreaIsSimple = True

		for toolWindow in toolWindows:
			currentArea = findClosestParent ( toolWindow, QToolWindowArea )
			if currentAreaIsSimple and currentArea and currentArea.areaType () == QTWMWrapperAreaType.watTabs:
				currentAreaIsSimple = False
			self.releaseToolWindow ( toolWindow, False )

		if reference == QToolWindowAreaReference.Type.Top or \
				reference == QToolWindowAreaReference.Type.Bottom or \
				reference == QToolWindowAreaReference.Type.Left or \
				reference == QToolWindowAreaReference.Type.Right:
			area = self.splitArea ( self.getFurthestParentArea ( area.getWidget () ).getWidget (), reference )
		elif reference == QToolWindowAreaReference.Type.HSplitTop or \
				reference == QToolWindowAreaReference.Type.HSplitBottom or \
				reference == QToolWindowAreaReference.Type.VSplitLeft or \
				reference == QToolWindowAreaReference.Type.VSplitRight:
			area = self.splitArea ( area.getWidget (), reference )
		elif reference == QToolWindowAreaReference.Type.Floating or \
				reference == QToolWindowAreaReference.Type.Drag:
			areaType = QTWMWrapperAreaType.watTabs
			if len ( toolWindows ) > 1:
				if currentAreaIsSimple:
					areaType = QTWMWrapperAreaType.watRollups
			elif self.toolWindowsTypes[ toolWindows[ 0 ] ] == QTWMToolType.ttSimple:
				areaType = QTWMWrapperAreaType.watRollups

			area = self.createArea ( areaType )
			wrapper = self.createWrapper ()
			wrapper.setContents ( area.getWidget () )
			wrapper.getWidget ().show ()

			if geometry != QRect ():
				titleBar = wrapper.getWidget ().findChild ( QCustomTitleBar )
				if titleBar:
					dragOffset.setY ( -titleBar.height () / 2 )
				geometry.moveTopLeft ( geometry.topLeft () + dragOffset )
				wrapper.getWidget ().setGeometry ( geometry )
			else:
				wrapper.getWidget ().setGeometry ( QRect ( QPoint ( 0, 0 ), toolWindows[ 0 ].sizeHint () ) )
				wrapper.getWidget ().move ( QCursor.pos () )

		if reference != QToolWindowAreaReference.Type.Hidden:
			area.addToolWindows ( toolWindows, index )
			self.lastArea = area

		self.simplifyLayout ()
		for toolWindow in toolWindows:
			self.toolWindowVisibilityChanged.emit ( toolWindow, toolWindow.parent () != None )
		self.notifyLayoutChange ()

		if reference != QToolWindowAreaReference.Type.Drag and wrapper:
			self.draggedWrapper = wrapper
			wrapper.startDrag ()

	def releaseToolWindow ( self, toolWindow, allowClose = False ):
		if not toolWindow.parentWidget ():
			return False

		if not self.ownsToolWindow ( toolWindow ):
			print ( "Unknown tool window" )
			return False

		previousTabWidget = findClosestParent ( toolWindow, QToolWindowArea )
		if not previousTabWidget:
			print ( "cannot find tab widget for tool window" )
			return False
		if allowClose:
			releasePolicy = self.config.get ( QTWM_RELEASE_POLICY ) or QTWMReleaseCachingPolicy.rcpWidget
			if releasePolicy == QTWMReleaseCachingPolicy.rcpKeep:
				self.moveToolWindow ( toolWindow, None, QToolWindowAreaReference.Type.Hidden )
				if self.config.get ( QTWM_ALWAYS_CLOSE_WIDGETS ) or True and not self.tryCloseToolWindow ( toolWindow ):
					return False
			if releasePolicy == QTWMReleaseCachingPolicy.rcpWidget:
				if not toolWindow.testAttribute ( QtCore.Qt.WA_DeleteOnClose ):
					if self.config.get ( QTWM_ALWAYS_CLOSE_WIDGETS ) or True and not self.tryCloseToolWindow (
							toolWindow ):
						return False
					self.moveToolWindow ( toolWindow, None, QToolWindowAreaReference.Type.Hidden )
			if releasePolicy == QTWMReleaseCachingPolicy.rcpForget or releasePolicy == QTWMReleaseCachingPolicy.rcpDelete:
				if not self.tryCloseToolWindow ( toolWindow ):
					return False
				self.moveToolWindow ( toolWindow, None, QToolWindowAreaReference.Type.Hidden )
				self.toolWindows.remove ( toolWindow )

				if releasePolicy == QTWMReleaseCachingPolicy.rcpDelete:
					toolWindow.deleteLater ()
				return True

		if allowClose:
			self.simplifyLayout ()
		else:
			previousTabWidget.adjustDragVisuals ()

		toolWindow.hide ()
		toolWindow.setParent ( None )
		return True

	def releaseToolWindows ( self, toolWindows, allowClose = False ):
		result = True
		while len ( self.toolWindows ) != 0:
			result &= self.releaseToolWindow ( toolWindows[ 0 ], allowClose )
		return result

	def areaOf ( self, toolWindow ):
		return findClosestParent ( toolWindow, QToolWindowArea )

	def swapAreaType ( self, oldArea, areaType = QTWMWrapperAreaType.watTabs ):
		parentSplitter = None
		targetWrapper = findClosestParent ( oldArea.getWidget (), QToolWindowWrapper )
		parentSplitter = oldArea.parentWidget ()
		newArea = self.createArea ( areaType )

		if not parentSplitter and not targetWrapper:
			print ( "Could not determine area parent" )
			return

		newArea.addToolWindow ( oldArea.toolWindows )
		if parentSplitter:
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

	def isWrapper ( self, w ):
		if w == None:
			return False
		return isinstance ( w, QToolWindowWrapper ) or (
				not isinstance ( w, QSplitter ) and isinstance ( w.parentWidget (), QToolWindowWrapper ))

	def isMainWrapper ( self, w ):
		return self.isWrapper ( w ) and (w == self.mainWrapper or w.parentWidget () == self.mainWrapper)

	def isFloatingWrapper ( self, w ):
		if not self.isWrapper ( w ):
			return False
		if isinstance ( w, QToolWindowWrapper ) and w != self.mainWrapper:
			return True
		return not isinstance ( w, QSplitter ) and isinstance ( w.parentWidget (),
		                                                        QToolWindowWrapper ) and w.parentWidget () != self.mainWrapper

	def saveState ( self ):
		result = { }
		result[ "toolWindowManagerStateFormat" ] = 2
		if self.mainWrapper.getContents () and self.mainWrapper.getContents ().metaObject ():
			result[ "mainWrapper" ] = self.saveWrapperState ( self.mainWrapper )

		floatingWindowsData = [ ]
		for wrapper in self.wrappers:
			if wrapper.getWidget ().isWindow () and wrapper.getContents () and wrapper.getContents ().metaObject ():
				m = self.saveWrapperState ( wrapper )
				if len ( m ) != 0:
					floatingWindowsData.append ( m )

		result[ "floatingWindows" ] = floatingWindowsData
		return result

	def restoreState ( self, data ):
		if not data:
			return
		stateFormat = data[ "toolWindowManagerStateFormat" ]
		if stateFormat != 1 and stateFormat != 2:
			print ( "state format is not recognized" )
			return

		self.suspendLayoutNotifications ()
		self.mainWrapper.getWidget ().hide ()
		for wrapper in self.wrappers:
			wrapper.getWidget ().hide ()
		self.moveToolWindowTarget ( self.toolWindows, None, QToolWindowAreaReference.Type.Hidden )
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

	def isAnyWindowActive ( self ):
		for tool in self.toolWindows:
			if tool.isAnyWindowActive ():
				return True
		return False

	def updateDragPosition ( self ):
		if not self.draggedWrapper:
			return

		self.draggedWrapper.getWidget ().raise_ ()

		hoveredWindow = windowBelow ( self.draggedWrapper.getWidget () )
		if hoveredWindow:
			# TODO:
			handlerWidget = hoveredWindow.childAt ( hoveredWindow.mapFromGlobal ( QCursor.pos () ) )
			if self.dragHandler.isHandlerWidget ( handlerWidget ):
				area = self.getClosestParentArea ( handlerWidget )
				if area and self.lastArea != area:
					self.dragHandler.switchedArea ( self.lastArea, area )
					self.lastArea = area
					delayTime = self.config.get ( QTWM_RAISE_DELAY ) or 500
					self.raiseTimer.stop ()
					if delayTime > 0:
						self.raiseTimer.start ( delayTime )
			return

		target = self.dragHandler.getTargetFromPosition ( self.lastArea )
		if self.lastArea and target.reference != QToolWindowAreaReference.Type.Floating:
			if target.reference.isOuter ():
				previewArea = findClosestParent ( self.lastArea.getWidget (), QToolWindowWrapper )
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
		                                  QCursor.pos () + self.config.get ( QTWM_TOOLTIP_OFFSET, QPoint ( 1, 20 ) ) )

	def finishWrapperDrag ( self ):
		target = self.dragHandler.finishDrag ( self.draggedToolWindows, None, self.lastArea )
		self.lastArea = None

		wrapper = self.draggedWrapper
		self.draggedWrapper = None
		self.raiseTimer.stop ()
		self.preview.setParent ( None )
		self.preview.hide ()

		contents = wrapper.getContents ()
		toolWindows = None
		contentsWidgets = contents.findChildren ()
		contentsWidgets.append ( contents )

		for w in contentsWidgets:
			area = w
			if area and self.ownsArea ( area ):
				toolWindows.append ( area.toolWindows )

		if target.reference != QToolWindowAreaReference.Type.Floating:
			contents = wrapper.getContents ()
			wrapper.setContents ( None )

			if target.reference == QToolWindowAreaReference.Type.Top or \
					target.reference == QToolWindowAreaReference.Type.Bottom or \
					target.reference == QToolWindowAreaReference.Type.Left or \
					target.reference == QToolWindowAreaReference.Type.Right:
				self.splitArea ( self.getFurthestParentArea ( target.area.getWidget () ).getWidget (), target.reference,
				                 contents )
			elif target.reference == QToolWindowAreaReference.Type.HSplitTop or \
					target.reference == QToolWindowAreaReference.Type.HSplitBottom or \
					target.reference == QToolWindowAreaReference.Type.VSplitLeft or \
					target.reference == QToolWindowAreaReference.Type.VSplitRight:
				self.splitArea ( target.area.getWidget (), target.reference, contents )
			elif target.reference == QToolWindowAreaReference.Type.Combine:
				self.moveToolWindows ( toolWindows, target )

			wrapper.getWidget ().close ()
			self.simplifyLayout ()

		if target.reference != QToolWindowAreaReference.Type.Combine:
			for w in toolWindows:
				self.toolWindowVisibilityChanged.emit ( w, True )

		if target.reference != QToolWindowAreaReference.Type.Floating:
			self.notifyLayoutChange ()

		self.updateTrackingTooltip.emit ( "", QPoint () )

	def finishWrapperResize ( self ):
		toolWindows = None
		contents = self.resizedWrapper.getContents ()
		contentsWidgets = contents.findChildren ()
		contentsWidgets.append ( contents )

		for w in contentsWidgets:
			area = w
			if area and self.ownsArea ( area ):
				toolWindows.append ( area.toolWindows )

		for w in toolWindows:
			self.toolWindowVisibilityChanged.emit ( w, True )

		self.resizedWrapper = None

	def saveWrapperState ( self, wrapper ):
		if not wrapper.getContents ():
			print ( "Empty top level wrapper" )
			return { }

		result = { }
		result[ "geometry" ] = wrapper.getWidget ().saveGeometry ().toBase64 ()
		result[ "name" ] = wrapper.getWidget ().objectName ()

		obj = wrapper.getContents ()
		if isinstance ( obj, QSplitter ):
			result[ "splitter" ] = self.saveSplitterState ( obj )
			return result
		if isinstance ( obj, QToolWindowArea ):
			result[ "area" ] = obj.saveState ()
			return result

		print ( "Couldn't find valid child widget" )
		return { }

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
		result = { }
		result[ "state" ] = splitter.saveState ().toBase64 ()
		result[ "type" ] = "splitter"
		items = [ ]
		for i in range ( 0, splitter.count () ):
			item = splitter.widget ( i )
			itemValue = { }
			area = item
			if area:
				itemValue = area.saveState ()
			else:
				childSplitter = item
				if childSplitter:
					itemValue = self.saveSplitterState ( childSplitter )
				else:
					print ( "Unknown splitter item" )
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
		s = widget
		if not s:
			s = findClosestParent ( widget, QSplitter )
		if not s:
			print ( "Could not find a matching splitter!" )
			return

		scaleFactor = 0
		if s.orientation () == QtCore.Qt.Horizontal:
			scaleFactor = s.width ()
		else:
			scaleFactor = s.height ()

		for i in range ( 0, len ( sizes ) ):
			sizes[ i ] *= scaleFactor

		s.setSizes ( sizes )

	def createArea ( self, areaType = QTWMWrapperAreaType.watTabs ):
		a = self.factory.createArea ( self, None, areaType )
		self.lastArea = a
		self.areas.append ( a )
		return a

	def createWrapper ( self ):
		w = self.factory.createWrapper ( self )
		name = None
		while True:
			i = QtCore.qrand ()
			name = "wrapper#" + str ( i )
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
		pass

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

	def targetFromPath ( self, toolPath ):
		for w in self.areas:
			if w.count () < 0 and self.getToolPath ( w.widget ( 0 ) ) == toolPath:
				return QToolWindowAreaTarget ( w, QToolWindowAreaReference.Type.Combine )
		return QToolWindowAreaTarget ( QToolWindowAreaReference.Type.Floating )

	def eventFilter ( self, o, e ):
		"""Summary line.

		Args:
			o (QObject): Description of param1
			e (QEvent): Description of param2
	    """
		if o == qApp:
			if e.type () == Qt.QEvent.ApplicationActivate and (
					self.config.get ( QTWM_WRAPPERS_ARE_CHILDREN ) or False) and (
					self.config.get ( QTWM_BRING_ALL_TO_FRONT ) or True):
				self.bringAllToFront ()
			return False

		w = o

		# if e.type () == Qt.QEvent.Destroy:
		# 	if not self.closingWindow and self.ownsToolWindow ( w ) and w.isVisible ():
		# 		self.releaseToolWindow ( w, True )
		# 		return False

		return super ().eventFilter ( o, e )

	def event ( self, e ):
		if e.type () == Qt.QEvent.StyleChange:
			if self.parentWidget () and self.parentWidget ().styleSheet () != self.styleSheet ():
				self.setStyleSheet ( self.parentWidget ().styleSheet () )

		return super ().event ( e )

	def tryCloseToolWindow ( self, toolWindow ):
		self.closingWindow += 1
		result = True

		if not toolWindow.close ():
			print ( "Widget could not be closed" )
			result = False

		self.closingWindow -= 1
		return result

	def createSplitter ( self ):
		return self.factory.createSplitter ( self )

	def splitArea ( self, area, reference, insertWidget = None ):
		residingWidget = insertWidget
		if not residingWidget:
			residingWidget = self.createArea ().getWidget ()

		if not reference.requiresSplit ():
			print ( "Invalid reference for area split" )
			return None

		forceOuter = reference.isOuter ()
		reference = reference & 0x3
		parentSplitter = None
		targetWrapper = findClosestParent ( area )
		if not forceOuter:
			parentSplitter = area.parentWidget ()
		if not parentSplitter and not targetWrapper:
			print ( "Could not determine area parent" )
			return None

		useParentSplitter = False
		targetIndex = 0
		parentSizes = [ ]
		if parentSplitter:
			parentSizes = parentSplitter.sizes ()
			targetIndex += parentSplitter.indexOf ( area )
			useParentSplitter = parentSplitter.orientation () == reference.splitOrientation ()

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
		splitter.setOrientation ( reference.splitOrientation () )

		if forceOuter or area == targetWrapper.getContents ():
			firstChild = targetWrapper.getContents ()
			targetWrapper.setContents ( None )
			splitter.addWidget ( firstChild )
		else:
			area.hide ()
			area.setParent ()
			splitter.addWidget ( area )
			area.show ()

		splitter.insertWidget ( reference & 0x1, residingWidget )
		if parentSplitter:
			parentSplitter.insertWidget ( targetIndex, splitter )
			parentSplitter.setSizes ( parentSizes )
		else:
			targetWrapper.setContents ( splitter )

		sizes = [ ]
		baseSize = 0
		if splitter.orientation () == QtCore.Qt.Vertical:
			baseSize = splitter.height ()
		else:
			baseSize = splitter.width ()
		newSizes = self.dragHandler.getSplitSizes ( baseSize )
		sizes.append ( newSizes.oldSize )
		sizes.insert ( reference & 0x1, newSizes.newSize )
		splitter.setSizes ( sizes )

		contentsWidgets = residingWidget.findChildren ()
		for w in contentsWidgets:
			qApp ().sendEvent ( w, QtCore.QEvent.ParentChange )

		return residingWidget

	def getClosestParentArea ( self, widget ):
		area = findClosestParent ( widget, QToolWindowArea )
		while area and not self.ownsArea ( area ):
			area = findClosestParent ( area.getWidget ().parentWidget (), QToolWindowArea )

		return area

	def getFurthestParentArea ( self, widget ):
		area = findClosestParent ( widget, QToolWindowArea )
		previousArea = area
		while area and self.ownsArea ( area ):
			area = findClosestParent ( area.getWidget ().parentWidget (), QToolWindowArea )

			if not area:
				return previousArea
			else:
				previousArea = area

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
		self.suspendLayoutNotifications ()
		madeChanges = False

		while madeChanges:
			areasToRemove = [ ]
			for area in self.areas:
				if area.count () == 0 and (clearMain or area.parent () != self.mainWrapper):
					areasToRemove.append ( area )
					madeChanges = True
				s = area.parentWidget ()
				while s and s.parentWidget ():
					sp = s.parentWidget ()
					sw = findClosestParent ( s )
					if s.count () == 1:
						if isinstance ( sp, QSplitter ):
							index = sp.indexOf ( s )
							sizes = sp.sizes ()
							sp.insertWidget ( index, s.widget ( 0 ) )
							s.hide ()
							s.setParent ()
							s.deleteLater ()
							sp.setSizes ( sizes )
							madeChanges = True
						elif isinstance ( sp, QToolWindowWrapper ):
							sp.setContents ( s.widget ( 0 ) )
							s.setParent ()
							s.deleteLater ()
							madeChanges = True
						else:
							print ( "Unexpected splitter parent" )

					elif s.orientation () == sp.orientation ():
						index = sp.indexOf ( s )
						newSizes = sp.sizes ()
						oldSizes = s.sizes ()
						newSum = newSizes[ index ]
						oldSum = 0
						for i in oldSizes:
							oldSum += i
						for i in range ( len ( oldSizes ), 0 ):
							sp.insertWidget ( index, s.widget ( i ) )
							newSizes.insert ( index, oldSizes[ i ] / oldSum * newSum )
						s.hide ()
						s.setParent ()
						s.deleteLater ()
						sp.setSizes ( newSizes )
						madeChanges = True

					s = sp

			for area in areasToRemove:
				area.hide ()
				aw = area.parentWidget ()
				if aw:
					aw.setContents ( None )

				area.setParent ()
				self.areas.remove ( area )
				area.deleteLater ()

		wrappersToRemove = [ ]
		for wrapper in self.wrappers:
			if wrapper.getWidget ().isWindow () and not wrapper.getContents ():
				wrappersToRemove.append ( wrapper )

		for wrapper in wrappersToRemove:
			self.wrappers.remove ( wrapper )
			wrapper.hide ()
			wrapper.deferDeletion ()

		for area in self.areas:
			area.adjustDragVisuals ()

		self.resumeLayoutNotifications ()
		self.notifyLayoutChange ()

	def createDragHandler ( self ):
		if self.dragHandler:
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

	def insertToToolTypes ( self, tool, type ):
		if tool in self.toolWindowsTypes:
			self.toolWindowsTypes[ tool ] = type

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
		super ( parent )

	def childEvent ( self, c ):
		"""Summary line.
		Args:
			c (QChildEvent): Description of param1
	    """
		if c.type () == Qt.QEvent.ChildRemoved:
			l = self.sizes ()
			i = self.indexOf ( c.child () )
			if i != -1 and len ( l ) > 1:
				s = l[ i ] + self.handleWidth ()
				if i == 0:
					l[ 1 ] = l[ 1 ] + s
				else:
					l[ i - 1 ] = l[ i - 1 ] + s
				l.remove ( l[ i ] )
				super ( c )
				self.setSizes ( l )
			else:
				super ( c )
		else:
			super ( c )
