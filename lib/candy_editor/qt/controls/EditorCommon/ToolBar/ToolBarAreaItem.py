from enum import IntEnum

from PyQt5.QtCore import Qt, pyqtSignal, QByteArray, QIODevice, QDataStream
from PyQt5.QtGui import QPixmap, QPainter, QColor
from PyQt5.QtWidgets import QWidget, QSizePolicy, QBoxLayout, QLabel, QStyleOption, QStyle

from ..DragDrop import CDragDropData


class CToolBarAreaItem ( QWidget ):
	signalDragStart = pyqtSignal ( QWidget )
	signalDragEnd = pyqtSignal ( QWidget )

	def __init__ ( self, area, orientation ):
		super ().__init__ ()
		self.area = area
		self.orientation = orientation
		self.content = None
		self.layout_ = QBoxLayout (
			QBoxLayout.LeftToRight if (orientation == Qt.Horizontal) else QBoxLayout.TopToBottom )
		self.layout_.setContentsMargins ( 0, 0, 0, 0 )
		self.layout_.setSpacing ( 0 )

	def setArea ( self, area ):
		self.area = area

	def setLocked ( self, isLocked ):
		self.dragHandle.setVisiable ( not isLocked )

	def setOrientation ( self, orientation ):
		self.orientation = orientation
		self.layout_.setDirection (
			QBoxLayout.LeftToRight if (orientation == Qt.Horizontal) else QBoxLayout.TopToBottom )
		self.dragHandle.setOrientation ( orientation )

	def getType ( self ):
		pass

	def getArea ( self ):
		return self.area

	def getOrientation ( self ):
		return self.orientation

	def getMinimumSize ( self ):
		return self.minimumSize ()

	def getMimeType ( self ):
		return "CToolBarAreaItem"

	def onDragStart ( self ):
		self.signalDragStart.emit ( self )

	def onDragEnd ( self ):
		self.signalDragEnd.emit ( self )

	def setContent ( self, newContent ):
		if self.content == None:
			self.content = newContent
			self.layout_.addWidget ( self.content )

		self.layout_.replaceWidget ( self.content, newContent )
		self.content.setVisiable ( False )
		newContent.setVisiable ( True )

		self.content.deleteLater ()
		self.content = newContent

	def paintEvent ( self, event ):
		styleOption = QStyleOption ()
		styleOption.initFrom ( self )
		painter = QPainter ( self )
		self.style ().drawPrimitive ( QStyle.PE_Widget, styleOption, painter, self )


class CToolBarItem ( CToolBarAreaItem ):

	def __init__ ( self, area, toolBar, orientation ):
		super ().__init__ ( area, orientation )
		self.toolBar = toolBar
		self.setContent ( toolBar )

	def replaceToolBar ( self, newToolBar ):
		newToolBar.setOrientation ( self.orientation )
		self.setContent ( newToolBar )
		self.toolBar = newToolBar

	def setOrientation ( self, orientation ):
		super ().setOrientation ( orientation )
		self.layout_.setAlignment ( Qt.AlignVCenter if (orientation == Qt.Horizontal) else Qt.AlignHCenter )
		self.toolBar.setOrientation ( self.orientation )

	def getMinimumSize ( self ):
		minSize = super ( CToolBarItem, self ).getMinimumSize ()
		minSize = minSize.expandedTo ( self.toolBar.minimumSize () )
		minSize = minSize.expandedTo ( self.toolBar.layout ().minimumSize () )
		return minSize

	def getTitle ( self ):
		return self.toolBar.windowTitle ()

	def getName ( self ):
		return self.toolBar.objectName ()

	def getToolBar ( self ):
		return self.toolBar


class CSpacerType ( IntEnum ):
	Expanding = 0
	Fixed = 1


class CSpacerItem ( CToolBarAreaItem ):

	def __init__ ( self, area, spacerType, orientation ):
		super ().__init__ ( area, orientation )
		self.setProperty ( "locked", False )
		self.setSpacerType ( spacerType )

	def setLocked ( self, isLocked ):
		super ().setLocked ( isLocked )
		self.setProperty ( "locked", isLocked )
		self.style ().unpolish ( self )
		self.style ().polish ( self )

	def setOrientation ( self, orientation ):
		super ( CSpacerItem, self ).setOrientation ( orientation )

		if self.spacerType == CSpacerType.Fixed:
			return

		if self.orientation == Qt.Horizontal:
			self.setSizePolicy ( QSizePolicy.Expanding, QSizePolicy.Minimum )
		else:
			self.setSizePolicy ( QSizePolicy.Minimum, QSizePolicy.Expanding )

	def setSpacerType ( self, spacerType ):
		""" Set spacer type.

			Args:
				spacerType (CSpacerType): CSpacerType

			Returns:
				None
	    """
		self.spacerType = spacerType

		if self.spacerType == CSpacerType.Expanding:
			if self.orientation == Qt.Horizontal:
				self.setSizePolicy ( QSizePolicy.Expanding, QSizePolicy.Minimum )
			else:
				self.setSizePolicy ( QSizePolicy.Minimum, QSizePolicy.Expanding )
		else:
			self.setSizePolicy ( QSizePolicy.Fixed, QSizePolicy.Fixed )


class CDragHandle ( QLabel ):
	signalDragStart = pyqtSignal ()
	signalDragEnd = pyqtSignal ()

	def __init__ ( self, content, orientation ):
		super ().__init__ ()
		self.content = content
		self.hasIconOverride = False
		if orientation == Qt.Horizontal:
			self.setPixmap ( QPixmap ( "./resources/icons/general_drag_handle_horizontal.ico" ) )
		else:
			self.setPixmap ( QPixmap ( "./resources/icons/general_drag_handle_vertical.ico" ) )

		self.setAlignment ( Qt.AlignHCenter, Qt.AlignVCenter )
		self.setCursor ( Qt.SizeAllCursor )

	def setOrientation ( self, orientation ):
		self.hasIconOverride = True
		if orientation == Qt.Horizontal:
			self.setPixmap ( QPixmap ( "./resources/icons/general_drag_handle_horizontal.ico" ) )
		else:
			self.setPixmap ( QPixmap ( "./resources/icons/general_drag_handle_vertical.ico" ) )

	def setIconOverride ( self, pixmap ):
		self.hasIconOverride = True
		self.setPixmap ( pixmap )

	def mouseMoveEvent ( self, event ):
		if event.buttons () & Qt.LeftButton and self.isEnabled ():
			dragData = CDragDropData ()
			byteArray = QByteArray ()
			stream = QDataStream ( byteArray, QIODevice.ReadWrite )
			stream << self.content
			dragData.setCustomData ( CToolBarAreaItem.getMimeType (), byteArray )

			pixmap = QPixmap ( self.content.size () )
			pixmap.fill ( QColor ( 0,0,0,0 ) )
			self.content.render ( pixmap )

			self.signalDragStart.emit ()
			CDragDropData.startDrag ( self, Qt.MoveAction, dragData, pixmap, -event.pos () )
			self.signalDragEnd.emit ()
