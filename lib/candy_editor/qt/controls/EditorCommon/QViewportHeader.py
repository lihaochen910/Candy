from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import QFrame, QBoxLayout, QToolButton


class QViewportHeader ( QFrame ):
	""" This interface describes a class created by a plugin.
    """

	def __init__ ( self, viewport ):
		super ().__init__ ()
		self.viewport = viewport
		self.moduleName = "QViewportHeader"

		self.setContentsMargins ( 0, 0, 0, 0 )
		boxLayout = QBoxLayout ( QBoxLayout.LeftToRight )
		boxLayout.setContentsMargins ( 0, 0, 0, 0 )
		boxLayout.setSpacing ( 0 )
		self.setLayout ( boxLayout )

		titleBtn = QToolButton ()
		titleBtn.setAutoRaise ( True )
		titleBtn.setToolButtonStyle ( Qt.ToolButtonTextOnly )
		titleBtn.setPopupMode ( QToolButton.InstantPopup )
		self.titleBtn = titleBtn

		pivotSnapping = QToolButton ()
		pivotSnapping.setToolTip ( "Pivot Snapping" )
		pivotSnapping.setAutoRaise ( True )
		pivotSnapping.setCheckable ( True )
		self.pivotSnapping = pivotSnapping

		boxLayout.addWidget ( titleBtn, 1 )

		boxLayout.addStretch ( 1 )

		# TODO:
