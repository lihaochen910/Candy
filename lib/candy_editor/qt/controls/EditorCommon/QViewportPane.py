from PyQt5.QtCore import Qt, QSize, QRect
from PyQt5.QtGui import QPainter
from PyQt5.QtWidgets import QWidget, QVBoxLayout, QLayout, QStyleOption, QStyle
from .EditorCommonInit import getEditor
from .QViewportHeader import QViewportHeader
from .Viewport import EViewportType, CViewport, CRenderViewport
from ..QToolWindowManager.QtViewPane import CDockableWidget, IViewPaneClass, ESystemClassID, registerClass


def shouldForwardEvent ():
	return getEditor ().isInGameMode ()


# TODO: viewport input event handle
class QViewportWidget ( QWidget ):

	def __init__ ( self, viewport ):
		super ().__init__ ()
		self.viewport = viewport
		self.setMouseTracking ( True )
		self.setFocusPolicy ( Qt.WheelFocus )
		self.setAttribute ( Qt.WA_PaintOnScreen )
		self.setAcceptDrops ( True )

	def keyPressEvent ( self, keyEvent ):
		super ().keyPressEvent ( keyEvent )

	def keyReleaseEvent ( self, keyEvent ):
		super ().keyPressEvent ( keyEvent )

	def mousePressEvent ( self, mouseEvent ):
		super ().mousePressEvent ( mouseEvent )

	def mouseReleaseEvent ( self, mouseEvent ):
		super ().mouseReleaseEvent ( mouseEvent )

	def mouseDoubleClickEvent ( self, mouseEvent ):
		super ().mouseDoubleClickEvent ( mouseEvent )

	def mouseMoveEvent ( self, mouseEvent ):
		super ().mouseMoveEvent ( mouseEvent )

	def wheelEvent ( self, wheelEvent ):
		super ().wheelEvent ( wheelEvent )

	def enterEvent ( self, event ):
		super ().enterEvent ( event )


class QAspectLayout ( QLayout ):

	def __init__ ( self ):
		super ().__init__ ()
		self.child = None

	def addItem ( self, item ):
		self.child = item

	def sizeHint ( self ):
		if self.child:
			return self.child.sizeHint ()
		else:
			return QSize ( 400, 300 )

	def minimumSize ( self ):
		if self.child:
			return self.child.minimumSize ()
		else:
			return QSize ( 400, 300 )

	def count ( self ):
		if self.child != None:
			return 1
		else:
			return 0

	def itemAt ( self, i ):
		if i == 0:
			return self.child
		else:
			return None

	def takeAt ( self, i ):
		if i == 0:
			return self.child
		else:
			return None


class QAspectRatioWidget ( QWidget ):

	def __init__ ( self, viewportWidget ):
		super ().__init__ ()
		self.setFocusPolicy ( Qt.NoFocus )
		self.setLayout ( QAspectLayout () )
		self.layout ().addWidget ( viewportWidget )

	def paintEvent ( self, pe ):
		o = QStyleOption ()
		o.initFrom ( self )
		p = QPainter ( self )
		self.style ().drawPrimitive ( QStyle.PE_Widget, o, p, self )

	def updateAspect ( self ):
		geomRect = self.geometry ()
		self.layout ().setGeometry ( QRect ( 0, 0, geomRect.width (), geomRect.height () ) )


class QViewportPane ( QWidget ):

	def __init__ ( self, viewport, headerWidget ):
		super ().__init__ ()
		self.viewWidget = QViewportWidget ( viewport )
		self.headerWidget = headerWidget
		layout = QVBoxLayout ()
		layout.setContentsMargins ( 0, 0, 0, 0 )
		layout.setSpacing ( 0 )
		if self.headerWidget:
			layout.addWidget ( self.headerWidget )

		self.setLayout ( layout )
		viewport.setViewWidget ( self.viewWidget )

	def getViewWidget ( self ):
		return self.viewWidget


class QViewportPaneContainer ( CDockableWidget ):

	def __init__ ( self, viewportPane, viewport ):
		super ().__init__ ( None )
		self.viewport = viewport
		layout = QVBoxLayout ()
		layout.setContentsMargins ( 0, 0, 0, 0 )
		layout.setSpacing ( 0 )
		self.setLayout ( layout )
		layout.addWidget ( viewportPane )

		# viewWidget = viewportPane.getViewWidget ()
		# viewWidget.addAction ( self.getPaneMenu ().menuAction () )

	def getPaneTitle ( self ) -> str:
		return self.viewport.getName ()

	def getPaneMenu ( self ):
		pass

	def getState ( self ):
		pass

	def setState ( self, state ):
		pass


class CViewportClassDesc ( IViewPaneClass ):

	def __init__ ( self, inType, inName ):
		self.type = inName
		self.name = inType
		self.className_ = "ViewportClass_%s" % inName

	def systemClassID ( self ):
		return ESystemClassID.ESYSTEM_CLASS_VIEWPANE

	def className ( self ):
		return self.className_

	def category ( self ):
		return "Viewport"

	def getMenuPath ( self ):
		return "Viewport"

	def getRuntimeClass ( self ):
		return None

	def getPaneTitle ( self ):
		return self.name

	def singlePane ( self ):
		return False

	def createPane ( self ):
		viewport = self.createViewport ()
		viewport.setType ( self.type )
		viewport.setName ( self.name )
		viewportPane = QViewportPane ( viewport, None )
		viewportPaneContainer = QViewportPaneContainer ( viewportPane, viewport )
		return viewportPaneContainer

	def createViewport ( self ) -> CViewport:
		pass


class CViewportClassDesc_Perspective ( CViewportClassDesc ):

	def __init__ ( self ):
		super ().__init__ ( EViewportType.ET_ViewportCamera, "Perspective" )

	def createViewport( self ):
		return CRenderViewport ()

	def createPane ( self ):
		viewport = self.createViewport ()
		header = QViewportHeader ( viewport )
		viewport.setType ( self.type )
		viewport.setName ( self.name )
		# viewport.setHeaderWidget ( header )
		viewportPane = QViewportPane ( viewport, header )
		viewportPaneContainer = QViewportPaneContainer ( viewportPane, viewport )
		return viewportPaneContainer


registerClass ( CViewportClassDesc_Perspective )
