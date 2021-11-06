from enum import IntEnum

from PyQt5.QtCore import pyqtSignal, QMimeData, QTimer, QObject
from PyQt5.QtGui import QPixmap, QDrag, QCursor
from PyQt5.QtWidgets import qApp

from .QTrackingTooltip import QTrackingTooltip


class EDisplayMode ( IntEnum ):
	Clear = 0
	Text = 1
	Pixmap = 2


class SScope:

	def __init__ ( self, scope = None ):
		if scope == None:
			self.displayMode = EDisplayMode.Clear
			self.text = ""
			self.pixmap = QPixmap ()
		else:
			self.displayMode = scope.displayMode
			self.text = scope.text
			self.pixmap = scope.pixmap


class CDragTooltip:
	_instance = None

	def __init__ ( self ):
		CDragTooltip._instance = self
		self.trackingTooltip = QTrackingTooltip ()
		self.scopes = {}
		self.defaultScope = SScope ()
		self.trackingTooltip = None
		self.timer = QTimer ()
		self.bDragging = False
		QObject.connect ( self.timer, QTimer.timeout, self.onTimerUpdate )

	@staticmethod
	def get ():
		if CDragTooltip._instance == None:
			CDragTooltip._instance = CDragTooltip ()
		return CDragTooltip._instance

	def startDrag ( self ):
		self.scopes.clear ()
		self.bDragging = True
		self.timer.start ( 0 )
		self.defaultScope = SScope ()

	def stopDrag ( self ):
		self.bDragging = False
		self.timer.stop ()
		self.update ()

	def setText ( self, widget, text ):
		scope = self.getScope ( widget )
		scope.displayMode = EDisplayMode.Text
		scope.text = text

	def setPixmap ( self, widget, pixmap ):
		scope = self.getScope ( widget )
		scope.displayMode = EDisplayMode.Pixmap
		scope.pixmap = pixmap

	def clear ( self, widget ):
		scope = self.getScope ( widget )
		scope.displayMode = EDisplayMode.Clear

	def setDefaultPixmap ( self, pixmap ):
		self.defaultScope.displayMode = EDisplayMode.Pixmap
		self.defaultScope.pixmap = pixmap

	def setCursorOffset ( self, point ):
		self.trackingTooltip.setPosCursorOffset ( point )

	def onTimerUpdate ( self ):
		self.update ()

	def update ( self ):
		subject = qApp.widgetAt ( QCursor.pos () )
		scope = self.getScope ( subject ) if subject else self.defaultScope
		if scope.displayMode == EDisplayMode.Clear:
			QTrackingTooltip.hideTooltip ( self.trackingTooltip.data () )
		else:
			if scope.displayMode == EDisplayMode.Text:
				self.trackingTooltip.setText ( scope.text )
			elif scope.displayMode == EDisplayMode.Pixmap:
				self.trackingTooltip.setPixmap ( scope.pixmap )

			QTrackingTooltip.showTrackingTooltip ( self.trackingTooltip )

	def getScope ( self, subject ):
		if self.scopes[ subject ] == None:
			self.scopes[ subject ].reset ( SScope ( self.defaultScope ) )
		return self.scopes[ subject ]


class CDragDropData ( QMimeData ):
	signalDragStart = pyqtSignal ( QMimeData )
	signalDragEnd = pyqtSignal ( QMimeData )

	def __init__ ( self ):
		super ().__init__ ()

	@staticmethod
	def fromDragDropEvent ( event ):
		""" Helper to get the CDragDropData from any drag&drop event (they all inherit from QDropEvent).

			Args:
				event: QDropEvent

			Return:
				CDragDropData
	    """
		return CDragDropData.FromMimeDataSafe ( event.mimeData () )

	@staticmethod
	def fromMimeDataSafe ( mimeData ):
		""" Helper method to create the CDragDropData from the QMimeData pointer provided by Qt, will fail if mimeData is not of CDragDropData type.

			Args:
				mimeData: QMimeData

			Return:
				CDragDropData
	    """
		if isinstance ( mimeData, CDragDropData ):
			return mimeData
		else:
			print ( "The QMimeData is not of type CDragDropData" )
			return None

	@staticmethod
	def fromMimeData ( mimeData ):
		""" Helper method to create the CDragDropData from the QMimeData pointer provided by Qt.

			Args:
				mimeData: QMimeData

			Return:
				CDragDropData
	    """
		return mimeData

	def getCustomData ( self, type ):
		""" Get custom data.

			Args:
				type: str

			Returns:
				QByteArray
	    """
		return QMimeData.data ( self.getMimeFormatForType ( type ) )

	def setCustomData ( self, type, data ):
		""" Set custom data.

			Args:
				type: str
				data: QByteArray
	    """
		QMimeData.setData ( self.getMimeFormatForType ( type ), data )

	def hasCustomData ( self, type ):
		""" Has custom data.

			Args:
				type: str

			Returns:
				bool
	    """
		return QMimeData.hasFormat ( self.getMimeFormatForType ( type ) )

	def hasFilePaths ( self ):
		""" Helper to check if mime data contains file paths (from file system, not internal file paths).

			Return:
				bool
	    """
		return self.hasUrls ()

	def getFilePaths ( self ):
		""" Retrieves file paths (from file system, not internal file paths).

			Return:
				List
	    """
		filePaths = []

		if self.hasUrls ():
			urls = QMimeData.urls ()
			for url in urls:
				filePaths.append ( url.toLocalFile () )

		return filePaths

	def getMimeFormatForType ( self, type ):
		""" Using crytek to be able to copy paste between all crytek applications.

			Args:
				type: str

			Return:
				QString
	    """
		# typeStr = type
		# typeStr = typeStr.simplified ()
		# typeStr.replace ( ' ', '_' )

		return ("application/crytek;type=\"%s\"" % type)

	@staticmethod
	def showDragText ( widget, what ):
		""" Show tracking tooltip to contextualize drag action. pWidget is the widget that is handling that drag action.

			Args:
				widget: QWidget
				what: str
	    """
		CDragTooltip.get ().setText ( widget, what )

	@staticmethod
	def showDragPixmap ( widget, what, pixmapCursorOffset = None ):
		""" Show tracking pixmap to contextualize drag action. pWidget is the widget that is handling that drag action.

			Args:
				widget: QWidget
				what: str
				pixmapCursorOffset: QPoint
	    """
		CDragTooltip.get ().setPixmap ( widget, what )

		if not pixmapCursorOffset == None:
			CDragTooltip.get ().setCursorOffset ( pixmapCursorOffset )

	@staticmethod
	def clearDragTooltip ( widget ):
		""" Clears the tooltip text for this widget.

			Args:
				widget: QWidget
	    """
		CDragTooltip.get ().clear ()

	@staticmethod
	def startDrag ( dragSource, supportedActions, mimeData, pixmap = None, pixmapCursorOffset = None ):
		""" Helper to create a QDrag and start a drag with the dragData as parameter.

			Args:
				dragSource: QObject
				supportedActions: Qt.DropActions
				mimeData: QMimeData
				pixmap: QPixmap
				pixmapCursorOffset: QPoint
	    """
		drag = QDrag ( dragSource )
		drag.setMimeData ( mimeData )
		tooltip = CDragTooltip.get ()
		tooltip.startDrag ()

		if mimeData and pixmap:
			tooltip.setDefaultPixmap ( pixmap )
			if pixmapCursorOffset != None:
				tooltip.setCursorOffset ( pixmapCursorOffset )

		CDragDropData.signalDragStart ( mimeData )
		drag.exec_ ( supportedActions )
		CDragDropData.signalDragEnd ( mimeData )

		tooltip.stopDrag ()
