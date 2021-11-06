from abc import ABCMeta, abstractmethod
from enum import IntEnum

from PyQt5 import QtCore
from PyQt5.QtCore import QRect, QSize, pyqtSignal
from PyQt5.QtWidgets import QMenu, QWidget

from .IEditorClassFactory import *


class IViewPaneClass ( IClassDesc ):
	__metaclass__ = ABCMeta

	def systemClassID ( self ):
		return ESystemClassID.ESYSTEM_CLASS_VIEWPANE

	@abstractmethod
	def getRuntimeClass ( self ):
		""" Get view pane window runtime class.

			Returns:
				CRuntimeClass
	    """
		pass

	@abstractmethod
	def getPaneTitle ( self ):
		""" Get view pane window title.

			Returns:
				string
	    """
		return 'IViewPaneClass'

	@abstractmethod
	def singlePane ( self ):
		""" Return true if only one pane at a time of time view class can be created.

			Returns:
				bool
	    """
		pass

	def needsMenuItem ( self ):
		""" Notifies the application if it should create an entry in the tools menu for this pane.

			Returns:
				bool
	    """
		return True

	def getMenuPath ( self ):
		""" This method returns the tools menu path where the tool can be spawned from.

			Returns:
				IPane
	    """
		return ""

	def createPane ( self ):
		""" Creates a Qt QWidget for this ViewPane.

			Returns:
				IPane
	    """
		return None


class IViewPaneClassImpl ( IClassDescImpl, IViewPaneClass ):

	def __init__ ( self, widgetClass, name, category, unique = False, menuPath = "", needsItem = False ):
		super ().__init__ ( widgetClass, name, category, unique, menuPath )
		self.needsItem = needsItem

	def needsMenuItem ( self ):
		return self.needsItem

	def getPaneTitle ( self ):
		return self.name

	def singlePane ( self ):
		return self.unique

	def createPane ( self ):
		return self.class_ ()


def registerClass ( klass ):
	from qt.controls.EditorCommon.IEditor import getIEditor
	getIEditor ().getClassFactory ().registerClass ( klass () )


def registerViewPaneFactoryAndMenuImpl ( widget, name, category, unique, menuPath, needsItem ):
	viewPaneClass = IViewPaneClassImpl ( widget, name, category, unique, menuPath, needsItem )
	from qt.controls.EditorCommon.IEditor import getIEditor
	getIEditor ().getClassFactory ().registerClass ( viewPaneClass )


def registerViewPaneFactory ( widget, name, category, unique ):
	registerViewPaneFactoryAndMenuImpl ( widget, name, category, unique, "", True )

def registerViewPaneFactoryAndMenu ( widget, name, category, unique, menuPath ):
	registerViewPaneFactoryAndMenuImpl ( widget, name, category, unique, menuPath, True )

def registerHiddenViewPaneFactory ( widget, name, category, unique ):
	registerViewPaneFactoryAndMenuImpl ( widget, name, category, unique, "", False )


class EDockingDirection ( IntEnum ):
	DOCK_DEFAULT = 0
	DOCK_TOP = 1
	DOCK_LEFT = 2
	DOCK_RIGHT = 3
	DOCK_BOTTOM = 4
	DOCK_FLOAT = 5


class IPane:
	__metaclass__ = ABCMeta

	signalPaneCreated = pyqtSignal ( object )

	def initialize ( self ):
		pass

	@abstractmethod
	def getWidget ( self ):
		pass

	def getDockingDirection ( self ):
		""" Return preferable initial docking position for pane.

			Returns:
				EDockingDirection
	    """
		return EDockingDirection.DOCK_FLOAT

	@abstractmethod
	def getPaneTitle ( self ):
		pass

	def getSubPanes ( self ):
		return {}

	def getPaneRect ( self ):
		""" Initial pane size.

			Returns:
				QRect
	    """
		return QRect ( 0, 0, 800, 500 )

	def getMinSize ( self ):
		""" Get Minimal view size

			Returns:
				QSize
	    """
		return QSize ( 0, 0 )

	def getState ( self ):
		return {}

	def getPaneMenu ( self ):
		mainMenu = QMenu ()
		helpMenu = mainMenu.addMenu ( "Help" )
		# helpMenu.addAction()
		return mainMenu

	def setState ( self, state ):
		pass

	def loadLayoutPersonalization ( self ):
		pass

	def saveLayoutPersonalization ( self ):
		pass


class CDockableWidget ( QWidget, IPane ):

	def __init__ ( self, parent = None ):
		super ().__init__ ( parent )
		self.setAttribute ( QtCore.Qt.WA_DeleteOnClose )

	def getWidget ( self ):
		return self

	def getPaneTitle ( self ):
		return 'CDockableWidget'
