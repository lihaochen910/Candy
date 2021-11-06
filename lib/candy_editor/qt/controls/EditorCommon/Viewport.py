from abc import ABCMeta, abstractmethod
from enum import IntEnum


class EViewportType ( IntEnum ):
	ET_ViewportUnknown = 0
	ET_ViewportXY = 1
	ET_ViewportXZ = 2
	ET_ViewportYZ = 3
	ET_ViewportCamera = 4
	ET_ViewportMap = 5
	ET_ViewportModel = 6
	ET_ViewportZ = 7
	ET_ViewportUI = 8
	ET_ViewportLast = 9


class CViewport:
	NothingMode = 0
	ScrollZoomMode = 1
	ScrollMode = 2
	ZoomMode = 3
	ManipulatorDragMode = 4

	Stretch = 0
	Window = 1
	Center = 2
	TopRight = 3
	TopLeft = 4
	BottomRight = 5
	BottomLeft = 6

	def __init__ ( self ):
		self.viewWidget = None
		self.name = ""
		self.selectionTolerance = 0.0
		self.fZoomFactor = 0.0
		self.nCurViewportID = 0
		self.nCurViewportID = 0

	def update ( self ):
		""" Called while window is idle.

			Returns:
				None
	    """
		pass

	def setName ( self, name: str ):
		""" Set name of this viewport.
	    """
		self.name = name

	def getName ( self ):
		""" Get name of viewport.

			Returns:
				str
	    """
		return self.name

	def setType ( self, type: EViewportType ):
		""" Must be overridden in derived classes.
	    """
		pass

	def getType ( self ) -> EViewportType:
		""" Get type of this viewport.

			Returns:
				EViewportType
	    """
		return EViewportType.ET_ViewportUnknown

	def isRenderViewport ( self ):
		""" Return true if this is a RenderViewport based class.

			Returns:
				bool
	    """
		return False

	def setFOV ( self, fov: float ):
		""" Is overridden by RenderViewport.
	    """
		pass

	def getFOV ( self ):
		""" Get type of this viewport.

			Returns:
				float
	    """
		return None

	def getAspectRatio ( self ):
		""" Must be overridden in derived classes.

			Returns:
				float
	    """
		return 0

	def getDimensions ( self ):
		""" Must be overridden in derived classes.
	    """
		return 0, 0

	def screenToClient ( self, x, y ):
		""" Must be overridden in derived classes.
	    """
		return 0, 0

	def createRenderContext ( self ):
		pass

	def setViewWidget ( self, viewWidget ):
		self.viewWidget = viewWidget
		self.createRenderContext ()

	def getViewWidget ( self ):
		return self.viewWidget

	@abstractmethod
	def canDrop ( self, point, item ):
		return False

	@abstractmethod
	def drop ( self, point, item ):
		pass

	def onResize ( self ):
		pass

	def onPaint ( self ):
		pass


class CRenderViewport ( CViewport ):

	def getType ( self ):
		return EViewportType.ET_ViewportCamera

	def setType ( self, type ):
		self.type = type

	def isRenderViewport ( self ):
		return True

