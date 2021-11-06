from abc import ABCMeta, abstractmethod

from PyQt5.QtCore import Qt, pyqtSignal
from PyQt5.QtWidgets import QVBoxLayout, QMenuBar, QMenu, QWidget

from .EditorContent import CEditorContent
from .EditorWidget import CEditorWidget
from .IEditor import getIEditor
from ..QToolWindowManager.CDockableContainer import CDockableContainer
from ..QToolWindowManager.QtViewPane import IPane


class CEditor ( CEditorWidget ):
	__metaclass__ = ABCMeta

	signalAdaptiveLayoutChanged = pyqtSignal ( int )

	def __init__ ( self, parent = None, bIsOnlyBackend = False ):
		super ().__init__ ( parent )
		self.bIsOnlybackend = bIsOnlyBackend
		self.dockingRegistry = None
		self.actionAdaptiveLayout = None
		self.isAdaptiveLayoutEnabled_ = True

		if bIsOnlyBackend:
			return

		self.paneMenu = QMenu ( self )

		self.menuBar = QMenuBar ()
		self.currentOrientation = self.getDefaultOrientation ()
		self.setLayout ( QVBoxLayout () )
		self.layout ().setContentsMargins ( 1, 1, 1, 1 )
		self.layout ().addWidget ( self.menuBar )
		self.editorContent = CEditorContent ( self )
		self.layout ().addWidget ( self.editorContent )

		# Important so the focus is set to the CEditor when clicking on the menu.
		self.setFocusPolicy ( Qt.StrongFocus )

		self.initActions ()
		self.initMenuDesc ()

	def initialize ( self ):
		if self.supportsAdaptiveLayout ():
			pass

		self.currentOrientation = self.getDefaultOrientation ()
		self.editorContent.initialize ()

	# TODO: CAbstractMenu
	# TODO: CMenuUpdater

	@abstractmethod
	def getEditorName ( self ) -> str:
		return "CEditor"

	def getOrientation ( self ):
		""" Editor orientation when using adaptive layouts.

			Returns:
				Qt.Orientation
	    """
		return self.currentOrientation

	def getDefaultOrientation ( self ):
		""" Used for determining what layout direction to use if adaptive layout is turned off.

			Returns:
				Qt.Orientation
	    """
		return Qt.Horizontal

	def onFocus ( self ):
		""" Panel or widget descendant is focused.

			Returns:
				None
	    """
		pass

	def customEvent ( self, event ):
		super ().customEvent ( event )

	def resizeEvent ( self, event ):
		super ().resizeEvent ( event )
		if not self.isAdaptiveLayoutEnabled ():
			return
		self.updateAdaptiveLayout ()

	def supportsAdaptiveLayout ( self ) -> bool:
		return False

	def isAdaptiveLayoutEnabled ( self ) -> bool:
		return self.supportsAdaptiveLayout () and self.isAdaptiveLayoutEnabled_

	def onAdaptiveLayoutChanged ( self ):
		pass

	def setContent ( self, content ):
		self.editorContent.setContent ( content )
		# print ( "[CEditor] setContent", content )

	def canQuit ( self, unsavedChanges ) -> bool:
		return True

	def isOnlyBackend ( self ) -> bool:
		return self.bIsOnlybackend

	def onOpenFile ( self, path ):
		return False

	def onFind ( self ):
		return False

	def onFindPrevious ( self ):
		return self.onFind ()

	def onFindNext ( self ):
		return self.onFind ()

	def onHelp ( self ):
		pass

	def getMenuAction ( self, item ):
		pass

	def getRootMenu ( self ):
		return self.menu.get ()

	def enableDockingSystem ( self ):
		if self.dockingRegistry != None:
			return
		self.dockingRegistry = CDockableContainer ( self )
		# TODO: CDockableContainer signal
		self.dockingRegistry.onLayorutChange.connct ( self.onLayoutChange )
		# self.dockingRegistry.setDefaultLayoutCallback ( )
		# self.dockingRegistry.setMenu ( )
		self.setContent ( self.dockingRegistry )

	def registerDockableWidget ( self, name, factory, isUnique = False, isInternal = False ):
		# TODO: registerDockableWidget
		pass

	def createDefaultLayout ( self, sender ):
		pass

	def onLayoutChange ( self, state ):
		pass

	def forceRebuildMenu ( self ):
		pass

	def initActions ( self ):
		pass

	def populateRecentFilesMenu ( self, menu ):
		pass

	def onMainFrameAboutToClose ( self, event ):
		pass

	def initMenuDesc ( self ):
		pass

	def updateAdaptiveLayout ( self ):
		if not self.isAdaptiveLayoutEnabled ():
			self.currentOrientation = self.getDefaultOrientation ()
			return self.onAdaptiveLayoutChanged ()

		newOrientation = None
		if self.width () > self.height ():
			newOrientation = Qt.Horizontal
		else:
			newOrientation = Qt.Vertical

		if newOrientation == self.currentOrientation:
			return

		minSize = self.editorContent.getMinimumSizeForOrientation ( newOrientation )
		currentSize = self.size ()
		if currentSize.width () < minSize.width () or currentSize.height () < minSize.height ():
			return

		self.currentOrientation = newOrientation
		self.onAdaptiveLayoutChanged ()

	def setAdaptiveLayoutEnabled ( self, enable ):
		if self.isAdaptiveLayoutEnabled_ == enable:
			return

		self.isAdaptiveLayoutEnabled_ = enable
		self.actionAdaptiveLayout.setChecked ( self.isAdaptiveLayoutEnabled_ )
		self.updateAdaptiveLayout ()


class CDockableEditor ( CEditor, IPane ):

	def __init__ ( self, parent = None ):
		super ().__init__ ( parent )
		self.setAttribute ( Qt.WA_DeleteOnClose )

	def initialize ( self ):
		super ().initialize ()

	def getWidget ( self ) -> QWidget:
		return self

	def getPaneMenu ( self ):
		pass

	def getPaneTitle ( self ) -> str:
		return self.getEditorName ()

	def getState ( self ):
		return self.getLayout ()

	def setState ( self, state ):
		self.setLayout ( state )

	def getSubPanes ( self ) -> list:
		return self.dockingRegistry.getPanes () if self.dockingRegistry else []

	def raise_ ( self ):
		getIEditor ().raiseDockable ( self )

	def highlight ( self ):
		pass

	def closeEvent ( self, event ):
		super ( CDockableEditor, self ).closeEvent ( event )
