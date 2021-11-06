from PyQt5 import QtCore
from PyQt5.QtCore import QPoint, QEvent, pyqtSignal
from PyQt5.QtGui import QPixmap, QPalette
from PyQt5.QtWidgets import QWidget, QVBoxLayout, QApplication

from .QScrollableBox import QScrollableBox


class QRollupBar ( QWidget ):
	rollupCloseRequested = pyqtSignal ( int )

	def __init__ ( self, parent ):
		super ().__init__ ( parent )
		self.dragWidget = None
		self.canReorder = False
		self.dragInProgress = False
		self.rollupsClosable = False

		self.setLayout ( QVBoxLayout ( self ) )
		self.layout ().setContentsMargins ( 0, 0, 0, 0 )
		self.layout ().setSpacing ( 0 )

		self.scrollBox = QScrollableBox ( self )
		self.delimeter = QWidget ( self.scrollBox )
		self.delimeter.setObjectName ( "DropDelimeter" )
		self.delimeter.setStyleSheet ( "background-color:blue;" )
		self.delimeter.setVisible ( False )
		self.layout ().addWidget ( self.scrollBox )

		self.dragStartPosition = QPoint ()
		self.childRollups = {}
		self.subFrames = []
		self.draggedId = 0

	def addWidget ( self, widget ):
		return self.attachNewWidget ( widget )

	def insertWidget ( self, widget, index ):
		self.attachNewWidget ( widget, index )

	def removeWidget ( self, widget ):
		index = self.indexOf ( widget )
		self.removeAt ( index )

	def removeAt ( self, index ):
		if index >= 0 and len ( self.subFrames ) > index:
			self.scrollBox.removeWidget ( self.subFrames[ index ] )
			del self.childRollups[ self.subFrames[ index ].getDragHandler () ]
			self.subFrames[ index ].close ()
			del self.subFrames[ index ]

	def indexOf ( self, widget ):
		for i in range ( 0, len ( self.subFrames ) ):
			current = self.subFrames[ i ]
			if current.getWidget () == widget:
				return i
		return -1

	def count ( self ):
		return len ( self.subFrames )

	def clear ( self ):
		while self.count () != 0:
			self.removeAt ( 0 )

	def isDragHandle ( self, widget ):
		return widget in self.childRollups

	def getDragHandleAt ( self, index ):
		return self.subFrames[ index ].getDragHandler ()

	def getDragHandle ( self, w ):
		index = self.indexOf ( w )
		if index >= 0:
			return self.subFrames[ index ].getDragHandler ()
		return None

	def widget ( self, index ):
		if index >= len ( self.subFrames ):
			return None
		return self.subFrames[ index ].getWidget ()

	def setRollupsClosable ( self, closable ):
		self.rollupsClosable = closable
		for var in self.subFrames:
			var.setClosable ( closable )

	def setRollupsReorderable ( self, reorderable ):
		self.canReorder = reorderable

	def rollupsReorderable ( self ):
		return self.canReorder

	def getDropTarget ( self ):
		return self.scrollBox

	def eventFilter ( self, o, e ):
		if e.type () == QEvent.MouseButtonPress:
			if self.canReorder:
				if e.button () == QtCore.Qt.LeftButton:
					if o in self.childRollups:
						self.dragStartPosition = e.pos ()
		elif e.type () == QEvent.MouseMove:
			if e.button () == QtCore.Qt.LeftButton:
				if self.canReorder:
					if not self.dragInProgress and not self.dragStartPosition and (
							e.pos () - self.dragStartPosition).manhattanLength () > QApplication.startDragDistance ():
						if not self.dragWidget:
							self.dragWidget = QWidget ()
							self.dragWidget.setWindowFlags ( QtCore.Qt.FramelessWindowHint | QtCore.Qt.Tool )
						dragWidget = o

						grabRect = dragWidget.rect ()

						grabImage = QPixmap ( grabRect.size () )
						grabImage.fill ( QtCore.Qt.transparent )
						dragWidget.render ( grabImage )

						pal = QPalette ()
						pal.setBrush ( QPalette.All, QPalette.Window, grabImage )
						self.dragWidget.setPalette ( pal )
						self.dragWidget.setGeometry ( grabRect )
						self.dragWidget.setAutoFillBackground ( True )
						self.dragWidget.raise_ ()
						self.dragWidget.setVisible ( True )
						self.dragStartPosition = dragWidget.mapToGlobal ( dragWidget.pos () ) - e.globalPos ()

						self.delimeter.setGeometry ( 0, 0, self.rect ().width (), 2 )
						self.delimeter.setVisible ( True )
						self.dragInProgress = True
						self.draggedId = self.subFrames.index ( self.childRollups[ dragWidget ] )

					if self.dragInProgress:
						self.dragWidget.move ( e.globalPos () + self.dragStartPosition )
						currentTarget = self.rollupIndexAt ( self.scrollBox.mapFromGlobal ( e.globalPos ) )
						if currentTarget > -1:
							self.delimeter.move ( QPoint ( 0, self.subFrames[ currentTarget ].pos ().y () ) )
						else:
							lastItem = self.subFrames[ len ( self.subFrames ) - 1 ]
							self.delimeter.move ( QPoint ( 0, lastItem.pos ().y () + lastItem.height () ) )
		elif e.type () == QEvent.MouseButtonRelease:
			if self.dragInProgress:
				self.dragWidget.setVisible ( False )
				self.delimeter.setVisible ( False )
				self.dragStartPosition = QPoint ()
				targetPos = self.rollupIndexAt ( self.scrollBox.mapFromGlobal ( e.globalPos () ) )
				if targetPos == -1:
					targetPos = len ( self.subFrames )
				if targetPos != self.draggedId and targetPos != self.draggedId + 1:
					if targetPos > self.draggedId:
						targetPos -= 1

					itemToMove = self.subFrames[ self.draggedId ]
					self.subFrames.remove ( itemToMove )
					self.subFrames.insert ( targetPos, itemToMove )
					self.scrollBox.removeWidget ( itemToMove )
					self.scrollBox.insertWidget ( targetPos, itemToMove )

		return super ().eventFilter ( o, e )

	def rollupAt ( self, indexOrPos ):
		if isinstance ( indexOrPos, QPoint ):
			index = self.rollupIndexAt ( indexOrPos )
			if index > -1:
				return self.subFrames[ index ]
			else:
				return self.subFrames[ len ( self.subFrames ) - 1 ]
		elif isinstance ( indexOrPos, int ):
			if indexOrPos >= len ( self.subFrames ):
				return None
			return self.subFrames[ indexOrPos ]

	def rollupIndexAt ( self, pos ):
		for var in self.subFrames:
			current = self
			framePos = var.mapTo ( current, QPoint ( 0, 0 ) ).y () + var.height ()
			if pos.y () < framePos:
				return self.subFrames.index ( var )
		return -1

	def onRollupCloseRequested ( self, frame ):
		self.rollupCloseRequested ( self.subFrames.index ( frame ) )

	def attachNewWidget ( self, widget, index = -1 ):
		pass
