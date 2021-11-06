import sys

from PyQt5.QtCore import QDir
from PyQt5.QtWidgets import QApplication

from .IEditor import CEditorImpl
from ..QToolWindowManager import CEditorMainFrame


class EditorApp:
	_singleton = None

	def __init__ ( self ):
		assert ( EditorApp._singleton == None )
		EditorApp._singleton = self
		QDir.addSearchPath ( "icons", ":/resources/icons" )
		self.qtApp = QApplication ( [ '-graphicssystem', 'opengl' ] )
		self.qtApp.setStyleSheet ( open ( '/Users/Kanbaru/GitWorkspace/CandyEditor/resources/theme/CryEngineVStyleSheet.qss' ).read () )
		# self.qtApp.setStyleSheet ( open ( 'C:/Users/Administrator/OneDrive/文档/CandyEditor/resources/theme/CryEngineVStyleSheet.qss' ).read () )
		# self.qtApp.setStyleSheet ( open ( 'D:/OneDrive/文档/CandyEditor/resources/theme/CryEngineVStyleSheet.qss' ).read () )

		# Init game engine

		editorImpl = CEditorImpl ()
		editorImpl.init ()

		window = CEditorMainFrame ( None )
		window.postLoad ()
		window.show ()
		window.raise_ ()

		self.mainWindow = window

		sys.exit ( self.qtApp.exec_ () )

	@staticmethod
	def get ():
		return EditorApp._singleton




