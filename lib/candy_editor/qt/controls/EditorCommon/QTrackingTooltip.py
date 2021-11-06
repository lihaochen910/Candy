from PyQt5.QtCore import Qt, QPoint, QEvent, QRect
from PyQt5.QtGui import QCursor
from PyQt5.QtWidgets import QFrame, qApp, QLabel, QToolTip, QVBoxLayout, QApplication


class QTrackingTooltip ( QFrame ):
	# _instance = None

	def __init__ ( self, parent = None ):
		super ().__init__ ( parent )
		self.isTracking = False
		self.cursorOffset = QPoint ()
		self.autoHide = True
		self.instance = None
		self.setWindowFlags ( Qt.ToolTip | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint )
		self.setFocusPolicy ( Qt.NoFocus )
		self.setAttribute ( Qt.WA_ShowWithoutActivating )
		self.setAttribute ( Qt.WA_TransparentForMouseEvents )

	def __del__ ( self ):
		self.instance.deleteLater ()

	def show ( self ):
		self.raise_ ()
		super ().show ()

	def setText ( self, str ):
		label = self.findChild ( "QTrackingTooltipLabel" )
		if label:
			label.setText ( str )
			self.adjustSize ()
			return True

		if self.layout ():
			return False

		label = QLabel ( self, Qt.WindowStaysOnTopHint )
		label.setFrameStyle ( QFrame.Panel )
		label.setFont ( QToolTip.font () )
		label.setPalette ( QToolTip.palette () )
		label.setText ( str )
		label.setObjectName ( "QTrackingTooltipLabel" )
		label.adjustSize ()

		layout = QVBoxLayout ()
		layout.setContentsMargins ( 0, 0, 0, 0 )
		layout.setSpacing ( 0 )
		layout.addWidget ( label )

		self.setLayout ( layout )
		return True

	def setPixmap ( self, pixmap ):
		label = self.findChild ( "QTrackingTooltipLabel" )
		if label:
			pixmapSize = pixmap.size ()
			label.setPixmap ( pixmap )
			self.adjustSize ()
			return True

		if self.layout ():
			return False

		label = QLabel ( self, Qt.WindowStaysOnTopHint )
		label.setFrameStyle ( QFrame.Panel )
		label.setPixmap ( pixmap )
		label.setObjectName ( "QTrackingTooltipLabel" )
		label.adjustSize ()

		layout = QVBoxLayout ()
		layout.setContentsMargins ( 0, 0, 0, 0 )
		layout.setSpacing ( 0 )
		layout.addWidget ( label )

		self.setLayout ( layout )
		return True

	def setPos ( self, p ):
		self.move ( self.adjustPosition ( p ) )

	def setPosCursorOffset ( self, p ):
		if p != None:
			self.cursorOffset = p

		self.setPos ( QCursor.pos () + self.cursorOffset )

	def getCursorOffset ( self ):
		return self.cursorOffset

	def setAutoHide ( self, autoHide ):
		self.autoHide = autoHide

	@staticmethod
	def showTextTooltip ( self, str, p ):
		if self.instance != None:
			if len ( str ) != 0 and self.instance.setText ( str ):
				self.instance.setPos ( p )
				return
			else:
				QTrackingTooltip.hideTooltip ()

		if len ( str ) != 0:
			self.instance = QTrackingTooltip ()
			self.instance.setText ( str )
			self.instance.show ()
			self.instance.setPos ( p )

	# self.instance.deleteLater ()  # replace c++ QSharedPointer ?? deleteLater

	@staticmethod
	def showTrackingTooltip ( self, tooltip, cursorOffset = QPoint ( 25, 25 ) ):
		if self.instance and self.instance != tooltip:
			QTrackingTooltip.hideTooltip ()

		if tooltip:
			self.instance = tooltip
			self.instance.show ()

			self.instance.setPosCursorOffset ( cursorOffset )
			self.instance.isTracking = True

			qApp.installEventFilter ( self.instance.data () )

	@staticmethod
	def hideTooltip ( self, tooltip = None ):
		if tooltip == None:
			if self.instance:
				qApp.removeEventFilter ( self.instance.data () )
				self.instance.isTracking = False
				self.instance.setVisiable ( False )
				self.instance.clear ()
		else:
			if self.instance == tooltip:
				QTrackingTooltip.hideTooltip ()

	def adjustPosition ( self, p ):
		rect = self.rect ()
		screen = QApplication.desktop ().screenGeometry ( self.getToolTipScreen () )

		if p.x () + rect.width () > screen.x () + screen.width ():
			# p.rx() -= 4 + rect.width()
			p.setX ( p.x () - 4 + rect.width () )
		if p.y () + rect.height () > screen.y () + screen.height ():
			# p.ry() -= 24 + rect.height ()
			p.setY ( p.x () - 24 + rect.height () )
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

	def eventFilter ( self, object, event ):
		if event.type () == QEvent.Leave or event.type () == QEvent.WindowActivate \
				or event.type () == QEvent.WindowDeactivate or event.type () == QEvent.FocusIn \
				or event.type () == QEvent.FocusOut or event.type () == QEvent.MouseButtonPress \
				or event.type () == QEvent.MouseButtonRelease or event.type () == QEvent.MouseButtonDblClick \
				or event.type () == QEvent.Wheel:
			if self.autoHide:
				QTrackingTooltip.hideTooltip ()
		elif event.type () == QEvent.MouseMove:
			if self.isTracking:
				self.setPosCursorOffset ( self.cursorOffset )
		return False

	def resizeEvent ( self, resizeEvent ):
		if self.isTracking:
			self.setPosCursorOffset ( self.cursorOffset )
