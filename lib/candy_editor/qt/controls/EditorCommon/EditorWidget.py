from PyQt5.QtCore import QMetaObject, QEvent, Qt
from PyQt5.QtGui import QPainter
from PyQt5.QtWidgets import QWidget, QVBoxLayout, QSizePolicy, QStyleOption, QStyle, QMenuBar


class CEditorWidget ( QWidget ):

	def __init__ ( self, parent = None ):
		super ().__init__ ( parent )
		self.menuBar = QMenuBar ()
		self.setLayout ( QVBoxLayout () )
		self.layout ().setContentsMargins ( 1, 1, 1, 1 )
		self.layout ().addWidget ( self.menuBar )
		self.setFocusPolicy ( Qt.StrongFocus )
