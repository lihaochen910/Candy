from PyQt5 import QtCore
from PyQt5.QtCore import QMetaObject, QEvent, pyqtSignal, Qt, qWarning
from PyQt5.QtGui import QCursor
from PyQt5.QtWidgets import QLabel, QFrame, QBoxLayout, QToolButton, QHBoxLayout, qApp, QSizePolicy, QWidget, QSizeGrip

from .QToolWindowManagerCommon import getMainWindow


class QCustomTitleBar ( QFrame ):
	onMousePressEvent = pyqtSignal ( QEvent )
	onMouseMoveEvent = pyqtSignal ( QEvent )
	onMouseReleaseEvent = pyqtSignal ( QEvent )
	onCloseButtonClickedEvent = pyqtSignal ( QWidget )

	def __init__ ( self, parent ):
		super ( QCustomTitleBar, self ).__init__ ( parent )
		# print ( "[create] QCustomTitleBar for parent", parent )
		self.dragging = False
		self.createFromDraging = False
		self.mouseStartPos = QCursor.pos ()

		if parent.metaObject ().indexOfSignal ( QMetaObject.normalizedSignature ( "contentsChanged" ) ) != -1:
			parent.contentsChanged.connect ( self.onFrameContentsChanged )

		myLayout = QHBoxLayout ( self )
		myLayout.setContentsMargins ( 0, 0, 0, 0 )
		myLayout.setSpacing ( 0 )

		self.setLayout ( myLayout )

		self.caption = QLabel ( self )
		self.caption.setAttribute ( QtCore.Qt.WA_TransparentForMouseEvents )
		self.caption.setSizePolicy ( QSizePolicy.Expanding, QSizePolicy.Preferred )

		self.sysMenuButton = QToolButton ( self )
		self.onIconChange ()
		self.sysMenuButton.setObjectName ( "sysMenu" )
		self.sysMenuButton.setFocusPolicy ( QtCore.Qt.NoFocus )
		self.sysMenuButton.installEventFilter ( self )
		myLayout.addWidget ( self.sysMenuButton )
		myLayout.addWidget ( self.caption, 1 )

		self.minimizeButton = QToolButton ( self )
		self.minimizeButton.setObjectName ( "minimizeButton" )
		self.minimizeButton.setFocusPolicy ( QtCore.Qt.NoFocus )
		# self.minimizeButton.clicked.connect ( parent.showMinimized )
		self.minimizeButton.clicked.connect ( lambda: parent.setWindowState ( Qt.WindowMinimized ) )
		myLayout.addWidget ( self.minimizeButton )

		self.maximizeButton = QToolButton ( self )
		self.maximizeButton.setObjectName ( "maximizeButton" )
		self.maximizeButton.setFocusPolicy ( QtCore.Qt.NoFocus )
		self.maximizeButton.clicked.connect ( self.toggleMaximizedParent )
		myLayout.addWidget ( self.maximizeButton )

		self.closeButton = QToolButton ( self )
		self.closeButton.setObjectName ( "closeButton" )
		self.closeButton.setFocusPolicy ( QtCore.Qt.NoFocus )
		self.closeButton.clicked.connect ( self.onCloseButtonClicked )
		myLayout.addWidget ( self.closeButton )

		parent.windowTitleChanged.connect ( self.caption.setText )
		parent.windowIconChanged.connect ( self.onIconChange )

		self.onFrameContentsChanged ( parent )

		# self.setMouseTracking ( True )

	def updateWindowStateButtons ( self ):
		if self.maximizeButton != None:
			if self.parentWidget ().windowState () & QtCore.Qt.WindowMaximized:
				self.maximizeButton.setObjectName ( "restoreButton" )
			else:
				self.maximizeButton.setObjectName ( "maximizeButton" )

			self.style ().unpolish ( self.maximizeButton )
			self.style ().polish ( self.maximizeButton )

	def setActive ( self, active ):
		self.caption.setObjectName ( "active" if active else "inactive" )
		self.style ().unpolish ( self.caption )
		self.style ().polish ( self.caption )

	def toggleMaximizedParent ( self ):
		if self.parentWidget ().windowState () & QtCore.Qt.WindowMaximized:
			self.parentWidget ().showNormal ()
		else:
			self.parentWidget ().showMaximized ()
		self.updateWindowStateButtons ()

	def toggleMinimizedParent ( self ):
		flags = self.parentWidget ().windowFlags ()
		self.parentWidget ().setWindowFlags ( flags | QtCore.Qt.CustomizeWindowHint & ~QtCore.Qt.WindowTitleHint )
		# self.setWindowFlags ( flags | QtCore.Qt.CustomizeWindowHint & ~QtCore.Qt.WindowTitleHint )
		self.parentWidget ().showMinimized ()
		self.parentWidget ().setWindowFlags ( self.parentWidget ().windowFlags () & (
					~QtCore.Qt.CustomContextMenu & ~QtCore.Qt.WindowTitleHint ) | QtCore.Qt.FramelessWindowHint )

	def showSystemMenu ( self, p ):
		pass

	def onCloseButtonClicked ( self ):
		# print ( "[QCustomTitleBar] close requested. %s" % self.parentWidget () )
		self.onCloseButtonClickedEvent.emit ( self )
		self.parentWidget ().close ()

	def onIconChange ( self ):
		icon = self.parentWidget ().windowIcon ()
		if icon is None:
			icon = qApp.windowIcon ()
			if icon is None:
				pass
		self.sysMenuButton.setIcon ( icon )

	def onFrameContentsChanged ( self, newContents ):
		flags = self.parentWidget ().windowFlags ()
		self.minimizeButton.setVisible (
			flags & QtCore.Qt.WindowMinimizeButtonHint or flags & QtCore.Qt.MSWindowsFixedSizeDialogHint )
		self.maximizeButton.setVisible (
			flags & QtCore.Qt.WindowMaximizeButtonHint or flags & QtCore.Qt.MSWindowsFixedSizeDialogHint )
		self.closeButton.setVisible ( flags & QtCore.Qt.WindowCloseButtonHint )

		winTitle = self.parentWidget ().windowTitle ()
		if len ( winTitle ) == 0:
			self.caption.setText ( "[QCustomTitleBar] onFrameContentsChanged NoneWindowTitle" )
			return
		self.caption.setText ( winTitle )

	def onBeginDrag ( self ):
		self.dragging = True

	def mousePressEvent ( self, e ):

		self.onMousePressEvent.emit ( e )

		if e.button () == QtCore.Qt.LeftButton and qApp.widgetAt ( QCursor.pos () ) != self.sysMenuButton:
			self.onBeginDrag ()
			self.mouseStartPos = e.globalPos ()
			# self.windowHandle ().startSystemMove ()
			# qWarning ( "QCustomTitleBar::onBeginDrag" )

		super ().mousePressEvent ( e )

	def mouseMoveEvent ( self, e ):

		self.onMouseMoveEvent.emit ( e )

		if self.dragging:
			# self.window ().move ( e.globalPos () - self.mouseStartPos )
			offset = self.mouseStartPos - e.globalPos ()
			self.mouseStartPos = e.globalPos ()
			self.window ().move ( self.window ().pos () - offset )
			e.accept ()
			# qWarning ( "QCustomTitleBar::mouseMoveEvent" )
		else:
			super ().mouseMoveEvent ( e )

	def mouseReleaseEvent ( self, e ):

		self.onMouseReleaseEvent.emit ( e )

		if not self.dragging:
			if e.button () == QtCore.Qt.RightButton and self.rect ().contains ( self.mapFromGlobal ( QCursor.pos () ) ):
				e.accept ()
				self.showSystemMenu ( QCursor.pos () )
			else:
				e.ignore ()
			return
		self.dragging = False

		if self.createFromDraging:
			self.releaseMouse ()
			self.createFromDraging = False

		# qWarning ( "QCustomTitleBar::mouseReleaseEvent" )

		super ().mouseReleaseEvent ( e )

	def mouseDoubleClickEvent ( self, e ):
		e.accept ()
		self.toggleMaximizedParent ()

	def eventFilter ( self, o, e ):
		if o == self.sysMenuButton:
			if e.type () == QEvent.MouseButtonPress:
				if e.button () == QtCore.Qt.LeftButton and qApp.widgetAt ( QCursor.pos () ) == self.sysMenuButton:
					self.showSystemMenu ( self.mapToGlobal ( self.rect ().bottomLeft () ) )
					return True
			if e.type () == QEvent.MouseButtonDblClick:
				if e.button () == QtCore.Qt.LeftButton and qApp.widgetAt ( QCursor.pos () ) == self.sysMenuButton:
					self.parentWidget ().close ()
					return True

		return super ().eventFilter ( o, e )


class QCustomWindowFrame ( QFrame ):
	contentsChanged = pyqtSignal ( QWidget )

	def __init__ ( self ):
		super ( QCustomWindowFrame, self ).__init__ ( None )
		self.titleBar = None
		self.contents = None
		self.sizeGrip = None
		self.resizeMargin = 4

		self.setMouseTracking ( True )

		self.layout = QBoxLayout ( QBoxLayout.TopToBottom )
		self.layout.setSpacing ( 0 )
		self.layout.setContentsMargins ( 0, 0, 0, 0 )
		self.setLayout ( self.layout )

	def __del__ ( self ):
		pass

	@staticmethod
	def wrapWidget ( w ):
		windowFrame = QCustomWindowFrame ()
		windowFrame.internalSetContents ( w )
		return windowFrame

	def ensureTitleBar ( self ):
		if self.titleBar is None:
			self.titleBar = QCustomTitleBar ( self )

	def internalSetContents ( self, widget, useContentsGeometry = True ):
		if self.contents != None:
			if self.contents.parentWidget () == self:
				self.contents.setParent ( None )

			self.layout.removeWidget ( self.sizeGrip )
			self.layout.removeWidget ( self.contents )
			self.layout.removeWidget ( self.titleBar )
			self.contents.removeEventFilter ( self )

			self.contents.windowTitleChanged.disconnect ( self.setWindowTitle )
			self.contents.windowIconChanged.disconnect ( self.onIconChange )

		self.contents = widget

		if self.contents != None:
			self.contents.setSizePolicy ( QSizePolicy.Expanding, QSizePolicy.Expanding )
			if self.contents.testAttribute ( QtCore.Qt.WA_QuitOnClose ):
				self.contents.setAttribute ( QtCore.Qt.WA_QuitOnClose, False )
				self.setAttribute ( QtCore.Qt.WA_QuitOnClose )

			self.setAttribute ( QtCore.Qt.WA_DeleteOnClose, self.contents.testAttribute ( QtCore.Qt.WA_DeleteOnClose ) )

			self.setWindowTitle ( self.contents.windowTitle () )
			self.setWindowIcon ( self.contents.windowIcon () )

			self.contents.installEventFilter ( self )

			self.contents.windowTitleChanged.connect ( self.setWindowTitle )
			self.contents.windowIconChanged.connect ( self.onIconChange )

			if useContentsGeometry:
				self.contents.show ()
				self.setGeometry ( self.contents.geometry () )
				self.contents.setParent ( self )
			else:
				self.contents.setParent ( self )
				self.contents.show ()

			self.updateWindowFlags ()
			self.ensureTitleBar ()

			self.layout.addWidget ( self.titleBar )
			self.layout.addWidget ( self.contents )

			if self.sizeGrip == None:
				self.sizeGrip = QSizeGrip ( self )
				self.sizeGrip.setMaximumHeight ( 2 )

			import sys
			if sys.platform == 'darwin':
				self.layout.addWidget ( self.sizeGrip, 2 ) # osx
			else:
				self.layout.addWidget ( self.sizeGrip, 2, QtCore.Qt.AlignBottom | QtCore.Qt.AlignRight )  # window

		self.contentsChanged.emit ( self.contents )

	# def nativeEvent ( self, eventType, message, result ):
	# 	if not self.titleBar:
	# 		return False
	# 	return super ().nativeEvent ( eventType, message, result )

	def event ( self, e ):
		if e.type () == QEvent.Show:
			if not self.contents.isVisibleTo ( self ):
				self.contents.show ()
		if e.type () == QEvent.Hide:
			if self.contents != None:
				if self.contents.isVisibleTo ( self ) and self.windowState () != QtCore.Qt.WindowMinimized:
					self.contents.hide ()
		return super ().event ( e )

	def closeEvent ( self, e ):
		if self.contents != None and self.contents.isVisibleTo ( self ):
			if not self.contents.close ():
				e.ignore ()
		super ().closeEvent ( e )

	def changeEvent ( self, e ):
		if ( e.type () == QEvent.WindowStateChange or e.type () == QEvent.ActivationChange ) and getMainWindow () and getMainWindow ().windowState () == QtCore.Qt.WindowMinimized:
			getMainWindow ().setWindowState ( QtCore.Qt.WindowNoState )

		if self.titleBar != None:
			self.titleBar.updateWindowStateButtons ()

		super ().changeEvent ( e )

	def eventFilter ( self, o, e ):
		if o == self.contents:
			if self.contents.parentWidget () == self:
				if e.type () == QEvent.Close:
					self.close ()
				elif e.type () == QEvent.HideToParent:
					if self.isVisible ():
						self.hide ()
				elif e.type () == QEvent.ShowToParent:
					if not self.isVisible ():
						self.show ()

		return super ().eventFilter ( o, e )

	def mouseReleaseEvent ( self, e ):
		if self.titleBar is None:
			e.ignore ()
			return
		if e.button () == QtCore.Qt.LeftButton:
			self.titleBar.dragging = False

		super ().mouseReleaseEvent ( e )

	# def nudgeWindow ( self ):
	# 	pass

	def calcFrameWindowFlags ( self ):
		flags = self.windowFlags ()

		if self.contents:
			# Get all window flags from contents, excluding WindowType flags.
			flags = ( flags & QtCore.Qt.WindowType_Mask ) | ( self.contents.windowFlags () & ~QtCore.Qt.WindowType_Mask )

		import sys
		if sys.platform == 'darwin':
			return flags | QtCore.Qt.FramelessWindowHint    # osx FIXME: CustomizeWindowHint flag will show cocoa title bar.
		else:
			return flags | QtCore.Qt.FramelessWindowHint | QtCore.Qt.CustomizeWindowHint    # windows

	def updateWindowFlags ( self ):
		if self.contents != None:
			contentsWindowType = self.contents.windowFlags () & QtCore.Qt.WindowType_Mask
			# Contents has window type set, assign them it to us.
			if contentsWindowType != QtCore.Qt.Widget:
				# Clear window type flags
				self.setWindowFlags ( self.windowFlags () & ~QtCore.Qt.WindowType_Mask )
				# Set window type from contents' flags, then clear contents' window type flags.
				self.setWindowFlags ( self.windowFlags () | contentsWindowType )
				self.contents.setWindowFlags ( self.windowFlags () & ~QtCore.Qt.WindowType_Mask )
			# No window type has been set on the contents, and we don't have any window flags
			elif ( self.windowFlags () & QtCore.Qt.WindowType_Mask ) == QtCore.Qt.Widget:
				self.setWindowFlags ( self.windowFlags () | QtCore.Qt.Window )

		self.setWindowFlags ( self.calcFrameWindowFlags () )

	def onIconChange ( self ):
		if self.contents != None and self.windowIcon ().cacheKey () != self.contents.windowIcon ().cacheKey ():
			self.setWindowIcon ( self.contents.windowIcon () )

	def getResizeMargin ( self ):
		return self.resizeMargin

	def setResizeMargin ( self, resizeMargin ):
		self.resizeMargin = resizeMargin
