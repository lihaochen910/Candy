from PyQt5 import QtCore
from PyQt5.QtCore import QSize, QEvent
from PyQt5.QtGui import QIcon, QCursor, QMouseEvent
from PyQt5.QtWidgets import QFrame, QHBoxLayout, QToolButton, QSizePolicy, QMenu, QSplitterHandle

from qt.controls.QToolWindowManager.QCustomWindowFrame import QCustomWindowFrame, QCustomTitleBar
from qt.controls.QToolWindowManager.QToolWindowArea import QToolWindowSingleTabAreaFrame, QToolWindowArea
from qt.controls.QToolWindowManager.QToolWindowCustomWrapper import QToolWindowCustomWrapper
from qt.controls.QToolWindowManager.QToolWindowManager import QSizePreservingSplitter
from qt.controls.QToolWindowManager.QToolWindowManagerCommon import *
from qt.controls.QToolWindowManager.QtViewPane import IPane


SANDBOX_WRAPPER_MINIMIZE_ICON = "sandboxMinimizeIcon"
SANDBOX_WRAPPER_MAXIMIZE_ICON = "sandboxMaximizeIcon"
SANDBOX_WRAPPER_RESTORE_ICON = "sandboxRestoreIcon"
SANDBOX_WRAPPER_CLOSE_ICON = "sandboxWindowCloseIcon"


class QBaseTabPane ( QFrame ):
	title = ''
	category = ''
	class_ = ''
	viewCreated = False
	pane = None
	defaultSize = QSize ()
	minimumSize = QSize ()


class QNotifierSplitterHandle ( QSplitterHandle ):

	def __init__ ( self, orientation, parent ):
		super ().__init__ ( orientation, parent )

	def mousePressEvent ( self, e ):
		if e.button () == QtCore.Qt.LeftButton:
			# TODO: GetIEditor()->Notify(eNotify_OnBeginLayoutResize) Notify editors that we have begun resizing
			pass
		super ().mousePressEvent ( e )

	def mouseReleaseEvent ( self, e ):
		if e.button () == QtCore.Qt.LeftButton:
			# TODO: GetIEditor()->Notify(eNotify_OnEndLayoutResize) Notify editors that we have stopped resizing
			pass
		super ().mouseReleaseEvent ( e )

	def mouseMoveEvent ( self, e ):
		e2 = QMouseEvent ( e.type (), e.localPos (), e.windowPos (), QCursor.pos (), e.button (), e.buttons (),
		                   e.modifiers () )
		return super ().eventFilter ( e )


class QNotifierSplitter ( QSizePreservingSplitter ):

	def __init__ ( self, parent = None ):
		super ().__init__ ( parent )
		self.setChildrenCollapsible ( False )

	def createHandle ( self ):
		return QNotifierSplitterHandle ( self.orientation (), self )


class QSandboxWindow ( QCustomWindowFrame ):
	def __init__ ( self, manager ):
		super ().__init__ ()
		self.manager = manager

	def ensureTitleBar ( self ):
		if not self.titleBar:
			self.titleBar = QSandboxTitleBar ( self, self.manager.config if self.manager.config else self.config )

	def keyPressEvent ( self, e ):
		# TODO: SendMissedShortcutEvent
		pass

	def eventFilter ( self, o, e ):
		if not self.manager and o == self.contents and e.type () == QEvent.KeyPress:
			# TODO: SendMissedShortcutEvent
			pass
		return super ().eventFilter ( o, e )

	@staticmethod
	def wrapWidget ( w, manager ):
		windowFrame = QSandboxWindow ( manager )
		windowFrame.internalSetContents ( w )
		return windowFrame


class QSandboxWrapper ( QToolWindowCustomWrapper ):
	def __init__ ( self, manager ):
		super ().__init__ ( manager )

	def ensureTitleBar ( self ):
		if not self.titleBar:
			self.titleBar = QSandboxTitleBar ( self, self.manager.config )

	def keyPressEvent ( self, e ):
		# TODO: SendMissedShortcutEvent
		pass

	def eventFilter ( self, o, e ):
		if o == self.contents and e.type () == QEvent.KeyPress:
			# TODO: SendMissedShortcutEvent
			pass
		return super ().eventFilter ( o, e )


class QSandboxTitleBar ( QCustomTitleBar ):

	def __init__ ( self, parent, config ):
		super ().__init__ ( parent )
		self.config = config
		if self.minimizeButton:
			self.minimizeButton.setIcon ( getIcon ( self.config, SANDBOX_WRAPPER_MINIMIZE_ICON, QIcon () ) )
		if self.maximizeButton:
			if self.parentWidget ().windowState () & QtCore.Qt.WindowMaximized:
				self.maximizeButton.setIcon ( getIcon ( self.config, SANDBOX_WRAPPER_RESTORE_ICON, QIcon () ) )
			else:
				self.maximizeButton.setIcon ( getIcon ( self.config, SANDBOX_WRAPPER_MAXIMIZE_ICON, QIcon () ) )

		self.closeButton.setIcon ( getIcon ( self.config, SANDBOX_WRAPPER_CLOSE_ICON, QIcon () ) )

	def updateWindowStateButtons ( self ):
		super ().updateWindowStateButtons ()
		if self.parentWidget ().windowState () & QtCore.Qt.WindowMaximized:
			self.maximizeButton.setIcon ( getIcon ( self.config, SANDBOX_WRAPPER_RESTORE_ICON, QIcon () ) )
		else:
			self.maximizeButton.setIcon ( getIcon ( self.config, SANDBOX_WRAPPER_MAXIMIZE_ICON, QIcon () ) )


class QToolsMenuWindowSingleTabAreaFrame ( QToolWindowSingleTabAreaFrame ):

	def __init__ ( self, manager, parent ):
		super ().__init__ ( manager, parent )
		self.upperBarLayout = QHBoxLayout ()
		self.layout.addLayout ( self.upperBarLayout, 0, 0 )
		self.upperBarLayout.addWidget ( self.caption, QtCore.Qt.AlignLeft )

	def setContents ( self, widget ):
		super ().setContents ( widget )


class QToolsMenuToolWindowArea ( QToolWindowArea ):

	def __init__ ( self, manager, parent ):
		super ().__init__ ( manager, parent )
		self.tabBar ().currentChanged.connect ( self.onCurrentChanged )
		self.setMovable ( True )
		self.menuButton = QToolButton ( self )
		self.menuButton.setObjectName ( "QuickAccessButton" )
		self.menuButton.setPopupMode ( QToolButton.InstantPopup )
		self.menuButton.setVisible ( False )
		self.menuButton.setIcon ( QIcon ( "icons:common/general_corner_menu.ico" ) )

		customTabFrame = QToolsMenuWindowSingleTabAreaFrame ( manager, self )
		self.menuButton.setSizePolicy ( QSizePolicy.Expanding, QSizePolicy.Preferred )
		# self.addAction (  )
		customTabFrame.layout.addWidget ( self.menuButton, 0, 1, QtCore.Qt.AlignVCenter | QtCore.Qt.AlignRight )
		self.tabFrame = customTabFrame
		self.tabFrame.hide ()
		self.tabFrame.installEventFilter ( self )
		customTabFrame.caption.installEventFilter ( self )
		self.tabBar ().installEventFilter ( self )

	def adjustDragVisuals ( self ):
		currentIdx = self.tabBar ().currentIndex ()
		if currentIdx >= 0:
			focusTarget = self.setupMenu ( currentIdx )
			self.menuButton.setFocusProxy ( focusTarget )
			self.tabBar ().setFocusProxy ( focusTarget )

			floatingWrapper = self.manager.isFloatingWrapper ( self.parentWidget () )

			if self.tabBar ().count () > 1:
				self.setCornerWidget ( self.menuButton )
			elif self.tabBar ().count () == 1:
				self.tabFrame.layout.addWidget ( self.menuButton, 0, 1, QtCore.Qt.AlignVCenter | QtCore.Qt.AlignRight )

			if self.tabFrame:
				if floatingWrapper:
					self.tabFrame.caption.hide ()
				else:
					self.tabFrame.caption.show ()

			self.updateMenuButtonVisibility ()

		super ().adjustDragVisuals ()

	def shouldShowSingleTabFrame ( self ):
		if not self.manager.config.setdefault(QTWM_SINGLE_TAB_FRAME,True):
			return False
		if self.count () == 1:
			return True
		return False

	def event ( self, e ):
		# TODO: SandboxEvent
		# if e.type() == SandboxEvent.Command:

		return super ().event ( e )

	def onCurrentChanged ( self, index ):
		if index < 0 or self.tabBar ().count () == 1:
			return

		focusTarget = self.setupMenu ( index )
		self.menuButton.setFocusProxy ( focusTarget )
		self.tabBar ().setFocusProxy ( focusTarget )

		if self.tabBar ().count () > 1:
			self.setCornerWidget ( self.menuButton )
		elif self.tabBar ().count () == 1:
			self.tabFrame.layout.addWidget ( self.menuButton, 0, 1, QtCore.Qt.AlignVCenter | QtCore.Qt.AlignRight )

		self.updateMenuButtonVisibility ()

	def findIPaneInTabChildren ( self, tabIndex ):
		result = [ ]
		widgetAtIndex = self.widget ( tabIndex )
		pane = widgetAtIndex

		if isinstance ( widgetAtIndex, QBaseTabPane ):
			result[ 0 ] = widgetAtIndex.pane
			result[ 1 ] = widgetAtIndex
			return result
		elif isinstance ( widgetAtIndex, IPane ):
			result[ 0 ] = widgetAtIndex
			result[ 1 ] = widgetAtIndex
			return result

		for object in widgetAtIndex.children ():
			result[ 1 ] = object
			if isinstance ( widgetAtIndex, QBaseTabPane ):
				result[ 0 ] = object.pane
				result[ 1 ] = object
				break
			elif isinstance ( widgetAtIndex, IPane ):
				result[ 0 ] = object.pane
				result[ 1 ] = object
				break

		return result

	def setupMenu ( self, currentIndex ):
		foundParents = self.findIPaneInTabChildren ( currentIndex )
		ownerWidget = foundParents[ 1 ]
		pane = foundParents[ 0 ]

		self.setCornerWidget ()

		focusTarget = ownerWidget
		menuToAttach = None

		if pane:
			menuToAttach = pane.getPaneMenu ()
			focusTarget = pane.getWidget ()

		self.menuButton.setMenu ( menuToAttach )

		return focusTarget

	def updateMenuButtonVisibility ( self ):
		if not self.menuButton:
			return
		if self.menuButton.menu ():
			self.menuButton.setVisible ( True )
		else:
			self.menuButton.setVisible ( False )

	def createDefaultMenu ( self ):
		helpMenu = QMenu ()
		menuItem = helpMenu.addMenu ( "Help" )
		# menuItem.addAction()
		return helpMenu
