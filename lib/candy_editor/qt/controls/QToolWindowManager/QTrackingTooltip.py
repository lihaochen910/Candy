from PyQt5 import QtCore
from PyQt5.QtCore import QPoint, QEvent, QRect
from PyQt5.QtGui import QCursor
from PyQt5.QtWidgets import QFrame, QLabel, QToolTip, QVBoxLayout, QApplication, qApp


class QTrackingTooltip ( QFrame ):
	_instance = None

	@staticmethod
	def get ():
		return QTrackingTooltip._instance

	def __init__ ( self, parent = None ):
		super ().__init__ ( parent )
		self.isTracking = False
		self.cursorOffset = QPoint ( 0, 0 )
		self.autoHide = True
		self.setWindowFlags ( QtCore.Qt.ToolTip | QtCore.Qt.FramelessWindowHint | QtCore.Qt.WindowStaysOnTopHint )
		self.setFocusPolicy ( QtCore.Qt.NoFocus )
		self.setAttribute ( QtCore.Qt.WA_ShowWithoutActivating )
		self.setAttribute ( QtCore.Qt.WA_TransparentForMouseEvents )

	def show ( self ):
		self.raise_ ()
		super ().show ()

	def setText ( self, str ):
		label = self.findChild ( QLabel, "QTrackingTooltipLabel" )
		if label:
			label.setText ( str )
			self.adjustSize ()
			return True

		if self.layout ():
			return False

		label = QLabel ( self, QtCore.Qt.WindowStaysOnTopHint )
		label.setFrameStyle ( QFrame.Panel )
		label.setFont ( QToolTip.font () )
		label.setPalette ( QToolTip.palette () )
		label.setText ( str )
		label.setObjectName ( "QTrackingTooltipLabel" )
		label.adjustSize ()

		layout = QVBoxLayout ()
		layout.setContentsMargins ( 0,0,0,0 )
		layout.setSpacing ( 0 )
		layout.addWidget ( label )
		self.setLayout ( layout )
		return True

	def setPixmap ( self, pixmap ):
		label = self.findChild ( QLabel, "QTrackingTooltipLabel" )
		if label:
			pixmapSize = pixmap.size ()
			label.setPixmap ( pixmap )
			self.adjustSize ()
			return True

		if self.layout ():
			return False

		label = QLabel ()
		label.setFrameStyle ( QFrame.Panel )
		label.setPixmap ( pixmap )
		label.setObjectName ( "QTrackingTooltipLabel" )
		label.adjustSize ()

		pLayout = QVBoxLayout ()
		pLayout.setContentsMargins ( 0,0,0,0 )
		pLayout.setSpacing ( 0 )
		pLayout.addWidget ( label )
		self.setLayout ( pLayout )
		return True

	def setPos ( self, p ):
		self.move ( self.adjustPosition ( p ) )

	def setPosCursorOffset ( self, p = QPoint () ):
		if not p.isNull ():
			self.cursorOffset = p
		self.setPos ( QCursor.pos () + self.cursorOffset )

	def getCursorOffset ( self ):
		return self.cursorOffset

	def setAutoHide ( self, autoHide ):
		self.autoHide = autoHide

	@staticmethod
	def showTextTooltip ( str, p ):
		instance = QTrackingTooltip._instance
		if instance:
			if str and instance.setText ( str ):
				instance.setPos ( p )
				return
			else:
				QTrackingTooltip.hideTooltip ()

		if str:
			instance = QTrackingTooltip ()  # FIXME: QSharedPointer<QTrackingTooltip>(new QTrackingTooltip(), &QObject::deleteLater)
			instance.setText ( str )
			instance.show ()
			instance.setPos ( p )

	@staticmethod
	def showTrackingTooltip ( tooltip, cursorOffset ):
		instance = QTrackingTooltip._instance
		if instance and instance != tooltip:
			QTrackingTooltip.hideTooltip ()

		if tooltip:
			QTrackingTooltip._instance = tooltip
			QTrackingTooltip._instance.show ()

			instance = QTrackingTooltip._instance

			if not cursorOffset.isNull ():
				instance.setPosCursorOffset ( cursorOffset )
			elif instance.getCursorOffset ().isNull ():
				instance.setPosCursorOffset ( QPoint ( 25, 25 ) )
			else:
				instance.setPosCursorOffset ()

			instance.isTracking = True
			qApp.installEventFilter ( instance.data () )

	@staticmethod
	def hideTooltip ( tooltip ):
		if QTrackingTooltip._instance == tooltip:
			if QTrackingTooltip._instance:
				qApp.removeEventFilter ( QTrackingTooltip._instance.data )
				QTrackingTooltip._instance.m_isTracking = False
				QTrackingTooltip._instance.setVisible ( False )
				QTrackingTooltip._instance.clear ()

	def adjustPosition ( self, p ):
		rect = self.rect ()
		screen = QApplication.desktop ().screenGeometry ( self.getToolTipScreen () )

		if p.x () + rect.width () > screen.x () + screen.width ():
			p.setX ( p.x () - 4 + rect.width () )
		if p.y () + rect.height () > screen.y () + screen.height ():
			p.setY ( p.y () - 24 + rect.height () )
		if p.y () < screen.y ():
			p.setY ( screen.y () )
		if p.x () + rect.width () > screen.x () + screen.width ():
			p.setX ( screen.x () + screen.width () - rect.width () )
		if p.x () < screen.x ():
			p.setX ( screen.x () )
		if p.y () + rect.height () > screen.y () + screen.height ():
			p.setY ( screen.y () + screen.height () - rect.height () )

		futureRect = QRect ( p.x (), p.y (), rect.width (), rect.height () )
		cursor = QCursor.pos ()
		if futureRect.contains ( cursor ):
			offset = QPoint ()
			diff = cursor.x () - futureRect.left ()
			minDiff = diff
			offset = QPoint ( diff + abs ( self.cursorOffset.x () ) + 1, 0 )

			diff = futureRect.right () - cursor.x ()
			if diff < minDiff:
				minDiff = diff
				offset = QPoint ( -diff - abs ( self.cursorOffset.x () ) - 1, 0 )

			diff = cursor.y () - futureRect.top ()
			if diff < minDiff:
				minDiff = diff
				offset = QPoint ( 0, diff + abs ( self.cursorOffset.y () ) + 1 )

			diff = futureRect.bottom () - cursor.y ()
			if diff < minDiff:
				minDiff = diff
				offset = QPoint ( 0, -diff - abs ( self.cursorOffset.y () ) - 1 )

			p += offset

			assert not QRect ( p.x (), p.y (), rect.width (), rect.height () ).contains ( cursor )

		return p

	def getToolTipScreen ( self ):
		if QApplication.desktop ().isVirtualDesktop ():
			return QApplication.desktop ().screenNumber ( QCursor.pos () )
		else:
			return QApplication.desktop ().screenNumber ( self )

	def eventFilter ( self, o, e ):
		if e.type () == QEvent.Leave or \
				e.type () == QEvent.WindowActivate or \
				e.type () == QEvent.WindowDeactivate or \
				e.type () == QEvent.FocusIn or \
				e.type () == QEvent.FocusOut or \
				e.type () == QEvent.MouseButtonPress or \
				e.type () == QEvent.MouseButtonRelease or \
				e.type () == QEvent.MouseButtonDblClick or \
				e.type () == QEvent.Wheel:
			if self.autoHide:
				QTrackingTooltip.HideTooltip ()
		elif e.type () == QEvent.MouseMove:
			if self.isTracking:
				self.setPosCursorOffset ( self.cursorOffset )
		return False

	def resizeEvent ( self, e ):
		if self.isTracking:
			self.setPosCursorOffset ( self.cursorOffset )
