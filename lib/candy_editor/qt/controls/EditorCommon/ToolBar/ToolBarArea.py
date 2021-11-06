from enum import IntEnum

from PyQt5.QtCore import Qt, pyqtSignal, QPoint, qWarning, QDataStream
from PyQt5.QtGui import QPainter
from PyQt5.QtWidgets import QWidget, QSizePolicy, QBoxLayout, QStyleOption, QStyle, QSpacerItem, QApplication

from ..DragDrop import CDragDropData
from .ToolBarAreaItem import CToolBarAreaItem, CToolBarItem, CSpacerItem, CSpacerType


class CToolBarAreaType ( IntEnum ):
	ToolBar = 0
	Spacer = 1


def getAllItems ( area ):
	""" Summary.

		Args:
			area (CToolBarArea): area

		Returns:
			List
    """
	return area.findChildren ( CToolBarArea, "", Qt.FindDirectChildrenOnly )


class CToolBarArea ( QWidget ):
	signalDragStart = pyqtSignal ()
	signalDragEnd = pyqtSignal ()
	signalItemDropped = pyqtSignal ( CToolBarAreaItem, QWidget, int )

	def __init__ ( self, parent, orientation ):
		super ().__init__ ( parent )
		self.editor = parent
		self.orientation = orientation
		self.dropTargetSpacer = None
		self.actionContextPosition = QPoint ()
		self.isLocked = False

		if self.orientation == Qt.Horizontal:
			self.layout_ = QBoxLayout ( QBoxLayout.LeftToRight )
		else:
			self.layout_ = QBoxLayout ( QBoxLayout.TopToBottom )

		self.layout_.setSpacing ( 0 )
		self.layout_.setContentsMargins ( 0, 0, 0, 0 )

		self.setSizePolicy ( QSizePolicy.Minimum, QSizePolicy.Minimum )
		self.setLayout ( self.layout_ )
		self.setAcceptDrops ( True )
		self.setContextMenuPolicy ( Qt.CustomContextMenu )

		# print ( "CToolBarArea.__init__", parent )

	def getOrientation ( self ):
		return self.orientation

	def getToolBars ( self ):
		items = getAllItems ( self )
		toolBarItems = []

		for item in items:
			if item.getType () != CToolBarAreaType.ToolBar:
				continue
			toolBarItems.append ( item )

		return toolBarItems

	def getLargestItemMinimumSize ( self ):
		minSize = self.minimumSize ()
		items = getAllItems ( self )
		for item in items:
			minSize = minSize.expandedTo ( item.getMinimumSize () )

		return minSize

	def setOrientation ( self, orientation ):
		self.orientation = orientation
		self.layout_.setDirection (
			QBoxLayout.LeftToRight if self.orientation == Qt.Horizontal else QBoxLayout.TopToBottom )
		self.updateLayoutAlignment ()

		items = getAllItems ( self )
		for item in items:
			item.setOrientation ( self.orientation )

	def setActionContextPosition ( self, actionContextPosition ):
		self.actionContextPosition = actionContextPosition

	def fillContextMenu ( self, menu ):
		pass

	def addItem ( self, item, targetIndex ):
		item.signalDragStart.connect ( self.onDragStart )
		item.signalDragEnd.connect ( self.onDragEnd )
		item.setOrientation ( self.orientation )
		item.setLocked ( self.isLocked )
		self.layout_.insertWidget ( targetIndex, item )
		item.setArea ( self )

	def addToolBar ( self, toolBar, targetIndex ):
		self.addItem ( CToolBarItem ( self, toolBar, self.orientation ), targetIndex )

	def addSpacer ( self, spacerType, targetIndex ):
		self.addItem ( CSpacerItem ( self, spacerType, self.orientation ), targetIndex )
		if spacerType == CSpacerType.Expanding:
			self.layout_.setAlignment ( 0 )

	def removeItem ( self, item ):
		self.layout_.removeWidget ( item )
		item.signalDragStart.disconnect ( self )
		item.signalDragEnd.disconnect ( self )

		self.updateLayoutAlignment ( item )

	def deleteToolBar ( self, toolBarItem ):
		if self.isAncestorOf ( toolBarItem ):
			qWarning ( "Trying to remove non-owned toolbar from area" )
			return
		toolBarItem.deleteLater ()

	def hideAll ( self ):
		items = getAllItems ( self )
		for item in items:
			item.setVisible ( False )

	def findToolBarByName ( self, szToolBarName ):
		toolBarItems = self.findChildren ( CToolBarItem, "", Qt.FindDirectChildrenOnly )
		for toolBarItem in toolBarItems:
			if toolBarItem.getName () == szToolBarName:
				return toolBarItem

		print ( "Toolbar not found: %s" % szToolBarName )
		return None

	def setLocked ( self, isLocked ):
		self.isLocked = isLocked
		items = getAllItems ( self )
		for item in items:
			item.setLocked ( isLocked )

	def getState ( self ):
		pass

	def setState ( self, state ):
		pass

	def dragEnterEvent ( self, event ):
		print ( "CToolBarArea.dragEnterEvent", event )
		dragDropData = CDragDropData.fromMimeData ( event.mimeData () )
		if dragDropData.hasCustomData ( CToolBarAreaItem.getMimeType () ):
			byteArray = dragDropData.getCustomData ( CToolBarAreaItem.getMimeType () )
			stream = QDataStream ( byteArray )
			value = None
			stream >> value
			draggedItem = value if isinstance ( value, CToolBarAreaItem ) else None

			if not self.parentWidget ().isAncestorOf ( draggedItem ):
				return

			event.acceptProposedAction ()

			self.setProperty ( "dragHover", True )
			self.style ().unpolish ( self )
			self.style ().polish ( self )

	def dragMoveEvent ( self, event ):
		dragDropData = CDragDropData.fromMimeData ( event.mimeData () )
		if dragDropData.hasCustomData ( CToolBarAreaItem.getMimeType () ):
			targetIndex = self.getPlacementIndexFromPosition ( self.mapToGlobal ( event.pos () ) )
			event.acceptProposedAction ()

			if self.dropTargetSpacer and targetIndex == self.layout_.indexOf ( self.dropTargetSpacer ):
				return

			byteArray = dragDropData.getCustomData ( CToolBarAreaItem.getMimeType () )
			stream = QDataStream ( byteArray )
			value = None
			stream >> value
			draggedItem = value if isinstance ( value, CToolBarAreaItem ) else None

			if not self.parentWidget ().isAncestorOf ( draggedItem ):
				return

			spacerWidth = draggedItem.width ()
			spacerHeight = draggedItem.height ()

			if draggedItem.getOrientation () != self.orientation:
				tempWidth = spacerWidth
				spacerWidth = spacerHeight
				spacerHeight = tempWidth

			if self.dropTargetSpacer == None:
				self.dropTargetSpacer = QSpacerItem ( spacerWidth, spacerHeight, QSizePolicy.Fixed, QSizePolicy.Fixed )
			else:
				spacerIndex = self.layout_.indexOf ( self.dropTargetSpacer )
				if spacerIndex == targetIndex - 1 or (targetIndex == -1 and spacerIndex == self.layout_.count () - 1):
					return

				self.removeDropTargetSpacer ()
				self.dropTargetSpacer = QSpacerItem ( spacerWidth, spacerHeight, QSizePolicy.Fixed, QSizePolicy.Fixed )

			self.layout_.insertSpacerItem ( targetIndex, self.dropTargetSpacer )

	def dragLeaveEvent ( self, event ):
		self.removeDropTargetSpacer ()

		self.setProperty ( "dragHover", False )
		self.style ().unpolish ( self )
		self.style ().polish ( self )

	def dropEvent ( self, event ):
		dragDropData = CDragDropData.fromMimeData ( event.mimeData () )
		if dragDropData.hasCustomData ( CToolBarAreaItem.getMimeType () ):
			event.acceptProposedAction ()
			byteArray = dragDropData.getCustomData ( CToolBarAreaItem.getMimeType () )
			stream = QDataStream ( byteArray )
			value = None
			stream >> value
			item = value if isinstance ( value, CToolBarAreaItem ) else None

			targetIndex = -1

			if self.dropTargetSpacer:
				targetIndex = self.layout_.indexOf ( self.dropTargetSpacer )

				containerIndex = self.layout_.indexOf ( item )
				if containerIndex >= 0 and containerIndex < targetIndex:
					targetIndex -= 1

				self.removeDropTargetSpacer ()

			if targetIndex >= self.layout_.count ():
				targetIndex = -1

			self.signalItemDropped.emit ( item, self, targetIndex )

	def customEvent ( self, event ):
		pass

	def paintEvent ( self, event ):
		styleOption = QStyleOption ()
		styleOption.initFrom ( self )
		painter = QPainter ( self )
		self.style ().drawPrimitive ( QStyle.PE_Widget, styleOption, painter, self )

	def onDragStart ( self, item ):
		self.updateLayoutAlignment ( item )
		item.setVisiable ( False )
		self.signalDragStart.emit ()

	def onDragEnd ( self, item ):
		item.setVisiable ( True )
		self.signalDragEnd.emit ()

	def removeDropTargetSpacer ( self ):
		if self.dropTargetSpacer:
			self.layout_.removeItem ( self.dropTargetSpacer )
			self.dropTargetSpacer = None

	def indexForItem ( self, item ):
		return self.layout_.indexOf ( item )

	def moveItem ( self, item, destinationIndex ):
		sourceIndex = self.indexForItem ( item )
		if sourceIndex == destinationIndex:
			return
		self.layout_.insertWidget ( destinationIndex, item )

	def updateLayoutAlignment ( self, itemToBeRemoved = None ):
		spacers = self.findChildren ( CSpacerItem, "", Qt.FindDirectChildrenOnly )
		expandingSpacers = []
		for spacer in spacers:
			if spacer.getSpacerType () == CSpacerType.Expanding:
				expandingSpacers.append ( spacer )

		if len ( expandingSpacers ) == 0 or len ( expandingSpacers ) != 0 or (
				len ( expandingSpacers ) == 1 and expandingSpacers[ 0 ] == itemToBeRemoved):
			if self.orientation == Qt.Horizontal:
				self.layout_.setAlignment ( Qt.AlignLeft | Qt.AlignVCenter )
			else:
				self.layout_.setAlignment ( Qt.AlignTop | Qt.AlignHCenter )

	def getItemAtPosition ( self, globalPos ):
		object = QApplication.widgetAt ( globalPos )
		if object == None or object == self:
			return None

		item = object if isinstance ( object, CToolBarAreaItem ) else None
		while item == None and object.parent ():
			object = object.parent ()
			item = object if isinstance ( object, CToolBarAreaItem ) else None

		return item

	def getPlacementIndexFromPosition ( self, globalPos ):
		targetIndex = -1
		item = self.getItemAtPosition ( globalPos )

		if item == None:
			localPos = self.mapFromGlobal ( globalPos )
			if self.dropTargetSpacer:
				geom = self.dropTargetSpacer.geometry ()
				if geom.contains ( localPos ):
					targetIndex = self.layout_.indexOf ( self.dropTargetSpacer )

			return targetIndex

		targetIndex = self.indexForItem ( item )

		if self.orientation == Qt.Horizontal and item.mapFromGlobal ( globalPos ).x () > item.width () / 2:
			targetIndex += 1
		elif self.orientation == Qt.Vertical and item.mapFromGlobal ( globalPos ).y () > item.height () / 2:
			targetIndex += 1

		if targetIndex >= self.layout_.count ():
			targetIndex = -1

		return targetIndex
