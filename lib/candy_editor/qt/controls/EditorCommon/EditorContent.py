from PyQt5.QtCore import QSize
from PyQt5.QtGui import QPainter
from PyQt5.QtWidgets import QVBoxLayout, QWidget, QLayout, QHBoxLayout, QSizePolicy, QStyleOption, QStyle, QBoxLayout

from .ToolBar.ToolBarAreaManager import CToolBarAreaManager, CToolBarAreaManagerArea


class CEditorContent ( QWidget ):

	def __init__ ( self, editor ):
		super ().__init__ ()
		self.editor = editor
		self.toolBarAreaManager = CToolBarAreaManager ( editor )

		self.mainLayout = QVBoxLayout ()
		self.mainLayout.setContentsMargins ( 0, 0, 0, 0 )
		self.mainLayout.setSpacing ( 0 )
		self.contentLayout = QHBoxLayout ()
		self.contentLayout.setContentsMargins ( 0, 0, 0, 0 )
		self.contentLayout.setSpacing ( 0 )

		self.content = QWidget ()
		self.content.setSizePolicy ( QSizePolicy.Expanding, QSizePolicy.Expanding )

		self.editor.signalAdaptiveLayoutChanged.connect ( self.onAdaptiveLayoutChanged )

		self.setLayout ( self.mainLayout )

	def initialize ( self ):
		self.toolBarAreaManager.initialize ()

		self.mainLayout.addWidget ( self.toolBarAreaManager.getWidget ( CToolBarAreaManagerArea.Top ) )
		self.mainLayout.addLayout ( self.contentLayout )
		self.mainLayout.addWidget ( self.toolBarAreaManager.getWidget ( CToolBarAreaManagerArea.Bottom ) )

		self.contentLayout.addWidget ( self.toolBarAreaManager.getWidget ( CToolBarAreaManagerArea.Left ) )
		self.contentLayout.addWidget ( self.content )
		self.contentLayout.addWidget ( self.toolBarAreaManager.getWidget ( CToolBarAreaManagerArea.Right ) )

	def getContent ( self ):
		return self.content

	def setContent ( self, content ):
		if isinstance ( content, QWidget ):
			self.content.setSizePolicy ( QSizePolicy.Expanding, QSizePolicy.Expanding )
			self.contentLayout.replaceWidget ( self.content, content )
			self.content.setObjectName ( "CEditorContent" )
			self.content.deleteLater ()
			self.content = content
		elif isinstance ( content, QLayout ):
			contentLayout = content
			content = QWidget ()
			content.setSizePolicy ( QSizePolicy.Expanding, QSizePolicy.Expanding )
			content.setLayout ( contentLayout )
			content.setObjectName ( "CEditorContent" )
			contentLayout.setContentsMargins ( 0, 0, 0, 0 )
			contentLayout.setSpacing ( 0 )

			self.contentLayout.replaceWidget ( self.content, content )
			self.content.deleteLater ()
			self.content = content

	def customizeToolBar ( self ):
		# TODO: CToolBarCustomizeDialog
		return self.content

	def toggleToolBarLock ( self ):
		return self.toolBarAreaManager.toggleLock ()

	def addExpandingSpacer ( self ):
		return self.toolBarAreaManager.addExpandingSpacer ()

	def addFixedSpacer ( self ):
		return self.toolBarAreaManager.addFixedSpacer ()

	def getMinimumSizeForOrientation ( self, orientation ) -> QSize:
		isDefaultOrientation = orientation == self.editor.GetDefaultOrientation ()
		contentMinSize = self.content.layout ().minimumSize ()

		topArea = self.toolBarAreaManager.getWidget ( CToolBarAreaManagerArea.Top )
		bottomArea = self.toolBarAreaManager.getWidget ( CToolBarAreaManagerArea.Bottom )
		leftArea = self.toolBarAreaManager.getWidget ( CToolBarAreaManagerArea.Left )
		rightArea = self.toolBarAreaManager.getWidget ( CToolBarAreaManagerArea.Right )

		result = QSize ( 0, 0 )
		if isDefaultOrientation:
			# Take width from left and right areas if we're switching to the editor's default orientation
			result.setWidth ( result.width () + leftArea.getLargestItemMinimumSize ().width () )
			result.setWidth ( result.width () + rightArea.getLargestItemMinimumSize ().width () )

			# Use top and bottom area to calculate min height
			result.setHeight ( result.height () + leftArea.getLargestItemMinimumSize ().height () )
			result.setHeight ( result.height () + rightArea.getLargestItemMinimumSize ().height () )

			# Add content min size
			result += contentMinSize

			# Take the area layout size hints into account. Expand the current result with the toolbar area layout's size hint.
			# We use size hint rather than minimum size since toolbar area item's size policy is set to preferred.
			result = result.expandedTo ( QSize ( topArea.layout ().sizeHint ().height (), leftArea.layout ().sizeHint ().width () ) )
			result = result.expandedTo ( QSize ( bottomArea.layout ().sizeHint ().height (), rightArea.layout ().sizeHint ().width () ) )
		else:
			# If we're not switching to the default orientation, then we need to use the top and bottom toolbar areas' width
			# since these areas will be placed at the left and right of the editor content in this case of adaptive layouts
			result.setWidth ( result.width () + topArea.getLargestItemMinimumSize ().width () )
			result.setWidth ( result.width () + bottomArea.getLargestItemMinimumSize ().width () )

			# We must also flip where we get toolbar area min height from
			result.setHeight ( result.height () + leftArea.getLargestItemMinimumSize ().height () )
			result.setHeight ( result.height () + rightArea.getLargestItemMinimumSize ().height () )

			# Add flipped content min size
			result += QSize ( contentMinSize.height (), contentMinSize.width () )

			result = result.expandedTo ( QSize ( leftArea.layout ().sizeHint ().height (), topArea.layout ().sizeHint ().width () ) )
			result = result.expandedTo ( QSize ( rightArea.layout ().sizeHint ().height (), bottomArea.layout ().sizeHint ().width () ) )

		return result


	def onAdaptiveLayoutChanged ( self ):
		isDefaultOrientation = self.editor.GetOrientation () == self.editor.GetDefaultOrientation ()
		self.mainLayout.setDirection ( QBoxLayout.TopToBottom if isDefaultOrientation else QBoxLayout.LeftToRight )
		self.contentLayout.setDirection ( QBoxLayout.LeftToRight if isDefaultOrientation else QBoxLayout.TopToBottom )

	def paintEvent ( self, event ):
		styleOption = QStyleOption ()
		styleOption.initFrom ( self )
		painter = QPainter ( self )
		self.style ().drawPrimitive ( QStyle.PE_Widget, styleOption, painter, self )
