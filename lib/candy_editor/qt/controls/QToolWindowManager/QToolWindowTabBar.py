from PyQt5.QtCore import QPoint, QSignalMapper
from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import QMenu, QTabBar, QToolButton


class QTabSelectionMenu ( QMenu ):

	def __init__ ( self, toolButton, parentTabbar ):
		super ().__init__ ( toolButton )
		self.parentTabbar = parentTabbar


class QToolWindowTabBar ( QTabBar ):

	def __init__ ( self, parent = None ):
		QTabBar.__init__ ( self, parent )
		self.tabSelectionButton = QToolButton ( self )
		self.tabSelectionMenu = QTabSelectionMenu ( self.tabSelectionButton, self )

		self.tabSelectionButton.setEnabled ( True )
		self.tabSelectionButton.setIcon ( QIcon ( "./resources/general_pointer_down_expanded.ico" ) )  # TODO: CryIcon
		self.tabSelectionButton.setMenu ( self.tabSelectionMenu )
		self.tabSelectionButton.setPopupMode ( QToolButton.InstantPopup )

		styleSheet = f"QToolWindowArea > QTabBar::scroller{{ width: {self.tabSelectionButton.sizeHint ().width () / 2}px; }}"
		# print ( "QToolWindowTabBar", styleSheet )
		self.setStyleSheet ( styleSheet )
		self.tabSelectionMenu.aboutToShow.connect ( self.onSelectionMenuClicked )

	def paintEvent ( self, e ):
		QTabBar.paintEvent ( self, e )
		tabbarRect = self.rect ()
		if not tabbarRect.contains ( self.tabRect ( self.count () - 1 ) ) or not tabbarRect.contains (
				self.tabRect ( 0 ) ):
			self.tabSelectionButton.show ()
			self.tabSelectionButton.raise_ ()
			rect = self.contentsRect ()
			size = self.tabSelectionButton.sizeHint ()
			self.tabSelectionButton.move ( QPoint ( rect.width () - self.tabSelectionButton.width (), 0 ) )
		else:
			self.tabSelectionButton.hide ()

	def onSelectionMenuClicked ( self ):
		signalMapper = QSignalMapper ( self )
		acts = self.tabSelectionMenu.actions ()
		activeAction = self.currentIndex ()

		for i in range ( 0, acts.size () ):
			self.tabSelectionMenu.removeAction ( acts[ i ] )

		for i in range ( 0, self.count () ):
			action = self.tabSelectionMenu.addAction ( self.tabText ( i ) )
			action.triggered.connect ( signalMapper.map )
			signalMapper.setMapping ( action, i )

		if activeAction >= 0:
			acts = self.tabSelectionMenu.actions ()
			acts[ activeAction ].setIcon ( QIcon ( "./resources/general_tick.ico" ) )  # TODO: CryIcon

		signalMapper.mapped.connect ( self.setCurrentIndex )
