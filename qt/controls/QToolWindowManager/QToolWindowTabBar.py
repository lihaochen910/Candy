from PyQt5.QtCore import QPoint, QSignalMapper
from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import QMenu, QTabBar, QToolButton


class QTabSelectionMenu ( QMenu ):

	def __init__ ( self, toolButton, parentTabbar ):
		super ().__init__ ( toolButton )
		self.parentTabbar = parentTabbar


class QToolWindowTabBar ( QTabBar ):

	def __init__ ( self, parent = None ):
		super ().__init__ ( parent )
		self.tabSelectionButton = QToolButton ( self )
		self.tabSelectionMenu = QTabSelectionMenu ( self.tabSelectionButton, self )

		self.tabSelectionButton.setEnabled ( True )
		self.tabSelectionButton.setIcon ( QIcon ( "icons:General/Pointer_Down_Expanded.ico" ) )  # TODO: CryIcon
		self.tabSelectionButton.setMenu ( self.tabSelectionMenu )
		self.tabSelectionButton.setPopupMode ( QToolButton.InstantPopup )

		styleSheet = "QToolWindowArea > QTabBar::scroller{	width: " + str ( self.tabSelectionButton.sizeHint ().width () / 2 ) + "px;}"
		self.setStyleSheet ( styleSheet )
		self.tabSelectionMenu.aboutToShow.connect ( self.onSelectionMenuClicked )

	def paintEvent ( self, e ):
		super ().paintEvent ( e )
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
			acts[ activeAction ].setIcon ()  # TODO: CryIcon

		signalMapper.mapped.connect ( self.setCurrentIndex )
