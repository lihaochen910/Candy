from PyQt5.QtCore import Qt, QSize
from PyQt5.QtWidgets import QStackedLayout, QLabel

from .Editor import CEditor, CDockableEditor
from ..QToolWindowManager.QtViewPane import registerViewPaneFactory


class CLevelEditor ( CEditor ):

	def __init__ ( self, parent = None ):
		super ().__init__ ( parent )
		self.setObjectName ( self.getEditorName () )
		# self.registerActions ()
		# self.initMenu ()
		# self.registerDockingWidgets ()

	@staticmethod
	def createNewWindow ():
		pass

	def getEditorName ( self ):
		return "Level Editor"


class CObjectCreateToolPanel ( CDockableEditor ):

	def __init__ ( self, parent = None ):
		super ().__init__ ( parent )
		self.stacked = QStackedLayout ()

		label = QLabel ()
		label.setText ( "CObjectCreateToolPanel" )
		self.stacked.addWidget ( label )
		self.stacked.setAlignment ( label, Qt.AlignTop )

		self.setContent ( self.stacked )

	def sizeHint ( self ):
		return QSize ( 300, 400 )

registerViewPaneFactory ( CLevelEditor, "LevelEditor", "Main", False )
registerViewPaneFactory ( CObjectCreateToolPanel, "ObjectCreateToolPanel", "Main", False )