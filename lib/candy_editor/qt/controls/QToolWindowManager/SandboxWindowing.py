from PyQt5.QtCore import QEvent
from PyQt5.QtGui import QIcon, QMouseEvent
from PyQt5.QtWidgets import QHBoxLayout, QToolButton, QSizePolicy, QMenu, QSplitterHandle, QWidget

from .QCustomWindowFrame import QCustomWindowFrame, QCustomTitleBar
from .QToolWindowArea import QToolWindowSingleTabAreaFrame, QToolWindowArea
from .QToolWindowCustomWrapper import QToolWindowCustomWrapper
from .QToolWindowManager import QSizePreservingSplitter
from .QToolTabManager import QBaseTabPane
from .QToolWindowManagerCommon import *
from .QtViewPane import IPane


SANDBOX_WRAPPER_MINIMIZE_ICON = "sandboxMinimizeIcon"
SANDBOX_WRAPPER_MAXIMIZE_ICON = "sandboxMaximizeIcon"
SANDBOX_WRAPPER_RESTORE_ICON = "sandboxRestoreIcon"
SANDBOX_WRAPPER_CLOSE_ICON = "sandboxWindowCloseIcon"



class QNotifierSplitterHandle ( QSplitterHandle ):
	""" QSplitterHandle class that also lets us know when we have started resizing the layout.
    """

	def __init__ ( self, orientation, parent ):
		super ( QNotifierSplitterHandle, self ).__init__ ( orientation, parent )

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
		super ().mouseMoveEvent ( e2 )


class QNotifierSplitter ( QSizePreservingSplitter ):
	""" QSplitter class that creates QNotifierSplitterHandle.
    """
	def __init__ ( self, parent = None ):
		super ( QNotifierSplitter, self ).__init__ ( parent )
		self.setChildrenCollapsible ( False )

	def createHandle ( self ):
		return QNotifierSplitterHandle ( self.orientation (), self )


class QSandboxWindow ( QCustomWindowFrame ):

	def __init__ ( self, manager ):
		super ( QSandboxWindow, self ).__init__ ()
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
		super ( QSandboxWrapper, self ).__init__ ( manager )

	def ensureTitleBar ( self ):
		if not self.titleBar:
			self.titleBar = QSandboxTitleBar ( self, self.manager.config )

	def keyPressEvent ( self, e ):
		# TODO: SendMissedShortcutEvent
		super ( QSandboxWrapper, self ).keyPressEvent ( e )

	def eventFilter ( self, o, e ):
		if o == self.contents and e.type () == QEvent.KeyPress:
			# TODO: SendMissedShortcutEvent
			pass
		return super ().eventFilter ( o, e )


class QSandboxTitleBar ( QCustomTitleBar ):

	def __init__ ( self, parent, config ):
		super ( QSandboxTitleBar, self ).__init__ ( parent )
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
		super ( QToolsMenuWindowSingleTabAreaFrame, self ).__init__ ( manager, parent )
		self.upperBarLayout = QHBoxLayout ()
		self.layout.addLayout ( self.upperBarLayout, 0, 0 )
		self.upperBarLayout.addWidget ( self.caption, QtCore.Qt.AlignLeft | QtCore.Qt.AlignVCenter, QtCore.Qt.AlignLeft )

	def setContents ( self, widget ):
		super ().setContents ( widget )


class QToolsMenuToolWindowArea ( QToolWindowArea ):
	""" Handles the tabbar and decides where the menu button should be displayed.
    """

	def __init__ ( self, manager, parent ):
		super ( QToolsMenuToolWindowArea, self ).__init__ ( manager, parent )
		self.tabBar ().currentChanged.connect ( self.onCurrentChanged )
		self.setMovable ( True )
		self.menuButton = QToolButton ( self )
		# Used in qss to style this widget
		self.menuButton.setObjectName ( "QuickAccessButton" )
		self.menuButton.setPopupMode ( QToolButton.InstantPopup )
		self.menuButton.setVisible ( False )
		self.menuButton.setIcon ( QIcon ( "./resources/general_corner_menu.ico" ) )

		customTabFrame = QToolsMenuWindowSingleTabAreaFrame ( manager, self )
		self.menuButton.setSizePolicy ( QSizePolicy.Expanding, QSizePolicy.Preferred )
		# self.addAction ( )
		customTabFrame.layout.addWidget ( self.menuButton, 0, 1, QtCore.Qt.AlignVCenter | QtCore.Qt.AlignRight )
		self.tabFrame = customTabFrame
		self.tabFrame.hide ()
		self.tabFrame.installEventFilter ( self )
		self.tabFrame.caption.installEventFilter ( self )
		self.tabBar ().installEventFilter ( self )

	def adjustDragVisuals ( self ):
		currentIdx = self.tabBar ().currentIndex ()
		if currentIdx >= 0:
			focusTarget = self.setupMenu ( currentIdx )
			self.menuButton.setFocusProxy ( focusTarget )
			self.tabBar ().setFocusProxy ( focusTarget )

			customTabFrame = cast ( self.tabFrame, QToolsMenuWindowSingleTabAreaFrame )
			floatingWrapper = self.manager.isFloatingWrapper ( self.parentWidget () )
			# print ( "[QToolsMenuToolWindowArea] adjustDragVisuals isFloatingWrapper %s %s" % ( floatingWrapper, self.parentWidget () ), self )

			if self.tabBar ().count () > 1:
				self.setCornerWidget ( self.menuButton )
			elif self.tabBar ().count () == 1:
				customTabFrame.layout.addWidget ( self.menuButton, 0, 1, QtCore.Qt.AlignVCenter | QtCore.Qt.AlignRight )

			# If we are floating we can hide the caption because we already
			# 		   have the titlebar in Sandbox wrapper to show the title
			if customTabFrame != None:
				if floatingWrapper:
					customTabFrame.caption.hide ()
				else:
					customTabFrame.caption.show ()

			self.updateMenuButtonVisibility ()

		super ().adjustDragVisuals ()

	def shouldShowSingleTabFrame ( self ):
		if not self.manager.config.setdefault ( QTWM_SINGLE_TAB_FRAME, True ):
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

		customTabFrame = cast ( self.tabFrame, QToolsMenuWindowSingleTabAreaFrame )

		if self.tabBar ().count () > 1:
			self.setCornerWidget ( self.menuButton )
		elif self.tabBar ().count () == 1:
			customTabFrame.layout.addWidget ( self.menuButton, 0, 1, QtCore.Qt.AlignVCenter | QtCore.Qt.AlignRight )

		self.updateMenuButtonVisibility ()

	def findIPaneInTabChildren ( self, tabIndex ):
		result = [ None, None ]
		widgetAtIndex = self.widget ( tabIndex )
		paneProxy = cast ( widgetAtIndex, QBaseTabPane )
		pane = cast ( widgetAtIndex, IPane )

		if paneProxy != None:
			result[ 0 ] = paneProxy.pane
			result[ 1 ] = paneProxy
			return result
		elif pane != None:
			result[ 0 ] = pane
			result[ 1 ] = widgetAtIndex
			return result

		for obj in widgetAtIndex.children ():

			ppaneProxy = cast ( obj, QBaseTabPane )
			ppane = cast ( obj, IPane )

			result[ 1 ] = cast ( obj, QWidget )

			if ppaneProxy != None:
				result[ 0 ] = ppaneProxy.pane
				result[ 1 ] = ppaneProxy
				break
			elif ppane != None:
				result[ 0 ] = ppane
				break

		return result

	def setupMenu ( self, currentIndex ):
		foundParents = self.findIPaneInTabChildren ( currentIndex )
		ownerWidget = foundParents[ 1 ]
		pane = foundParents[ 0 ]

		self.setCornerWidget ( None )

		focusTarget = ownerWidget
		menuToAttach = None

		if pane != None:
			menuToAttach = pane.getPaneMenu ()
			focusTarget = pane.getWidget ()

		self.menuButton.setMenu ( menuToAttach )

		return focusTarget

	def updateMenuButtonVisibility ( self ):
		if self.menuButton == None:
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
