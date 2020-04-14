from PyQt5.QtCore import QSize, QEvent
from PyQt5.QtGui import QPainter, QIcon, QPixmap, QColor
from PyQt5.QtWidgets import QWidget, QVBoxLayout, QFrame, QStyleOption, QStyle, QLabel, QApplication, QPushButton, \
	QHBoxLayout, QSizePolicy, QToolButton


def createColorMap ():
	colorMap = { }
	colorMap[ QIcon.Mode.Normal ] = QColor ( 255, 255, 255 )
	return colorMap


class QCollapsibleFrame ( QWidget ):
	def __init__ ( self, title, parent ):
		super ().__init__ ( parent )
		self.widget = None
		self.headerWidget = None
		self.contentsFrame = None
		self.mainLayout = QVBoxLayout ()
		self.mainLayout.setSpacing ( 0 )
		self.mainLayout.setContentsMargins ( 2, 2, 2, 2 )
		self.setLayout ( self.mainLayout )

		self.SetHeaderWidget ( CCollapsibleFrameHeader ( title, self ) )

	def getWidget ( self ):
		return self.widget

	def getDragHandler ( self ):
		return self.headerWidget.collapseButton

	def setWidget ( self, widget ):
		if not self.contentsFrame:
			self.contentsFrame = QFrame ( self )
			frameLayout = QVBoxLayout ()
			frameLayout.setSpacing ( 0 )
			frameLayout.setContentsMargins ( 2, 2, 2, 2 )
			self.contentsFrame.setLayout ( frameLayout )
			self.layout ().addWidget ( self.contentsFrame )

		mainLayout = self.contentsFrame.layout ()

		if self.widget:
			mainLayout.removeWidget ( self.widget )
			self.widget.deleteLater ()

		self.widget = widget
		if self.widget:
			mainLayout.addWidget ( self.widget )
			self.contentsFrame.setHidden ( self.headerWidget.bCollapsed )

	def setClosable ( self, closable ):
		self.headerWidget.setClosable ( closable )

	def closable ( self ):
		return self.headerWidget.closable ()

	def setTitle ( self, title ):
		self.headerWidget.setTitle ( title )

	def collapsed ( self ):
		return self.headerWidget.bCollapsed

	def setCollapsed ( self, bCollapsed ):
		self.headerWidget.setCollapsed ( bCollapsed )

	def setCollapsedStateChangeCallback ( self, callback ):
		self.headerWidget.onCollapsedStateChanged = callback

	def paintEvent ( self, e ):
		opt = QStyleOption ()
		opt.initFrom ( self )
		painter = QPainter ( self )
		self.style ().drawPrimitive ( QStyle.PE_Widget, opt, painter, self )

	def setHearderWidget ( self, header ):
		self.headerWidget = header
		self.layout ().addWidget ( header )
		self.headerWidget.closeButton.clicked.connect ( self.onCloseRequested )

	def onCloseRequested ( self ):
		self.closeRequested ( self )

	def closeRequested ( self, caller ):
		pass


class CCollapsibleFrameHeader ( QWidget ):
	def __init__ ( self, title, parentCollapsible, icon, bCollapsed ):
		self.iconSize = QSize ( 16, 16 )
		self.parentCollapsible = QCollapsibleFrame ( parentCollapsible )
		self.titleLabel = QLabel ( title )
		self.collapsed = False

		if icon:
			self.iconLabel = QLabel ()
			self.iconLabel.setPixmap ( QIcon ( icon ).pixmap ( 16, 16, QIcon.Normal, QIcon.On ) )
		else:
			self.iconLabel = None

		collapsedPixmap = QPixmap ( "icons:Window/Collapse_Arrow_Right_Tinted.ico" )
		if collapsedPixmap.isNull ():
			self.collapsedIcon = QApplication.style ().standardIcon ( QStyle.SP_TitleBarShadeButton )
		else:
			self.collapsedIcon = QIcon ( collapsedPixmap, createColorMap () )

		expandedPixmap = QPixmap ( "icons:Window/Collapse_Arrow_Down_Tinted.ico" )
		if expandedPixmap.isNull ():
			self.expandedIcon = QApplication.style ().standardIcon ( QStyle.SP_TitleBarUnshadeButton )
		else:
			self.expandedIcon = QIcon ( expandedPixmap, createColorMap () )

		self.setupCollapseButton ()
		self.setupMainLayout ()

		self.collapseButton.installEventFilter ( self )
		self.collapseButton.clicked.connect ( self.onCollapseButtonClick )

	def getIconSize ( self ):
		return self.iconSize

	def setIconSize ( self, iconSize ):
		self.iconSize = iconSize

	def setClosable ( self, closable ):
		self.closeButton.setVisible ( closable )

	def closable ( self ):
		return self.closeButton.isVisible ()

	def setCollapsed ( self, collapsed ):
		if collapsed != self.collapsed:
			self.collapsed = collapsed

			if self.collapsed:
				self.collapseIconLabel.setPixmap (
					self.collapsedIcon.pixmap ( self.collapsedIcon.actualSize ( self.iconSize ) ) )
			else:
				self.collapseIconLabel.setPixmap (
					self.expandedIcon.pixmap ( self.expandedIcon.actualSize ( self.iconSize ) ) )

			if self.parentCollapsible.contentsFrame:
				self.parentCollapsible.contentsFrame.setHidden ( collapsed )

	def paintEvent ( self, e ):
		opt = QStyleOption ()
		opt.initFrom ( self )
		painter = QPainter ( self )
		self.style ().drawPrimitive ( QStyle.PE_Widget, opt, painter, self )

	def eventFilter ( self, o, e ):
		collapseButton = self.collapseButton
		if e.type () != QEvent.MouseButtonRelease or o != collapseButton or self.isEnabled ():
			return super ().eventFilter ( o, e )
		self.onCollapseButtonClick ()
		return True

	def setupCollapseButton ( self ):
		self.collapseButton = QPushButton ( self.parentCollapsible )
		self.collapseButton.setObjectName ( "CollapseButton" )

		layout = QHBoxLayout ()
		layout.setContentsMargins ( 6, 2, 6, 2 )
		self.collapseButton.setLayout ( layout )

		self.collapseIconLabel = QLabel ( self.collapseButton )
		self.collapseIconLabel.setSizePolicy ( QSizePolicy.Maximum, QSizePolicy.Maximum )

		self.titleLabel.setSizePolicy ( QSizePolicy.Minimum, QSizePolicy.Minimum )

		self.closeButton = QToolButton ( self.collapseButton )
		self.closeButton.setIcon ( QApplication.style ().standardIcon ( QStyle.SP_DockWidgetCloseButton ) )
		self.closeButton.setFixedHeight ( 16 )
		self.closeButton.setFixedWidth ( 16 )

		self.closeButton.setVisible ( False )
		self.collapseIconLabel.setPixmap ( self.expandedIcon.pixmap ( self.expandedIcon.actualSize ( self.iconSize ) ) )

		layout.addWidget ( self.collapseIconLabel )

		if self.iconLabel:
			layout.addWidget ( self.iconLabel )

		layout.addWidget ( self.titleLabel )
		layout.addStretch ()
		layout.addWidget ( self.closeButton )

	def setTitle ( self, title ):
		self.titleLabel.setText ( title )

	def setupMainLayout ( self ):
		titleLayout = QHBoxLayout ()
		titleLayout.setContentsMargins ( 0, 0, 0, 0 )
		titleLayout.setSpacing ( 0 )
		titleLayout.addWidget ( self.collapseButton )
		self.setLayout ( titleLayout )

	def onCollapseButtonClick ( self ):
		self.setCollapsed ( not self.collapsed )
		if self.onCollapsedStateChanged:
			self.onCollapsedStateChanged ( self.collapsed )
