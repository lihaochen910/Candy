from abc import ABCMeta, abstractmethod
from enum import Enum, IntEnum

from .Commands.CommandManager import CEditorCommandManager
from .ToolBar.ToolBarService import CToolBarService
from ..QToolWindowManager.IEditorClassFactory import CClassFactory


class EEditorNotifyEvent ( Enum ):
	Notify_OnInit = 'OnInit'
	Notify_OnQuit = 'OnQuit'
	Notify_OnIdleUpdate = 'OnIdleUpdate'
	Notify_OnMainFrameInitialized = 'OnMainFrameInitialized'


class EDragEvent ( IntEnum ):
	DragEnter = 0
	DragLeave = 1
	DragMove = 2
	Drop = 3


class IEditor ():
	__metaclass__ = ABCMeta

	@abstractmethod
	def notify ( self, event ):
		pass

	@abstractmethod
	def registerNotifyListener ( self, listener ):
		""" Register Editor notifications listener.

			Returns:
				None
	    """
		pass

	@abstractmethod
	def unregisterNotifyListener ( self, listener ):
		""" Unregister Editor notifications listener.

			Returns:
				None
	    """
		pass

	@abstractmethod
	def getClassFactory ( self ):
		""" Access to class factory.

			Returns:
				IEditorClassFactory
	    """
		pass

	@abstractmethod
	def getToolBarService ( self ):
		pass

	##########################################
	# Dockable pane management
	##########################################

	@abstractmethod
	def createDockable ( self, szClassName ):
		pass

	@abstractmethod
	def findDockable ( self, szClassName ):
		pass

	@abstractmethod
	def findDockableIf ( self, predicate ):
		pass

	@abstractmethod
	def findAllDockables ( self, szClassName ):
		pass

	@abstractmethod
	def raiseDockable ( self, pane ):
		pass

	##########################################
	# Console pane management
	##########################################

	@abstractmethod
	def setConsoleVar ( self, var, value ):
		""" Set a variable for Console.

			Args:
				var: string
				value: Any

			Returns:
				None
	    """
		pass

	@abstractmethod
	def getConsoleVar ( self, var ):
		""" Get a variable of Console.

			Args:
				var: string

			Returns:
				Any
	    """
		pass

	@abstractmethod
	def createPreviewWidget ( self, file, parent ):
		""" Creates a preview widget for any file type, returns null if cannot be previewed.

			Args:
				file: string
				parent: QWidget

			Returns:
				QWidget
	    """
		pass

	@abstractmethod
	def pickObject ( self, vWorldRaySrc, vWorldRayDir, object ):
		pass


s_Editor = None


class CEditorImpl ( IEditor ):

	def __init__ ( self ):
		global s_Editor
		s_Editor = self
		self.classFactory = CClassFactory ()
		self.toolBarService = CToolBarService ()
		self.commandManager = CEditorCommandManager ()

	def init ( self ):
		pass

	def getClassFactory ( self ) -> CClassFactory:
		return self.classFactory

	def getToolBarService ( self ) -> CToolBarService:
		return self.toolBarService

	def createDockable ( self, szClassName: str ):
		from candy_editor.qt.controls.QToolWindowManager.QToolTabManager import CTabPaneManager
		return CTabPaneManager.get ().createPane ( szClassName )

	def findDockable ( self, szClassName: str ):
		from candy_editor.qt.controls.QToolWindowManager.QToolTabManager import CTabPaneManager
		return CTabPaneManager.get ().findPaneByClass ( szClassName )

	def findAllDockables ( self, szClassName: str ):
		from candy_editor.qt.controls.QToolWindowManager.QToolTabManager import CTabPaneManager
		return CTabPaneManager.get ().findAllPanelsByClass ( szClassName )

	def raiseDockable ( self, pane ):
		from candy_editor.qt.controls.QToolWindowManager.QToolTabManager import CTabPaneManager
		CTabPaneManager.get ().bringToFront ( pane )


def getIEditor () -> CEditorImpl:
	""" Get the glolbal CEditorImpl instance.

		Returns:
			CEditorImpl
    """
	global s_Editor
	return s_Editor

