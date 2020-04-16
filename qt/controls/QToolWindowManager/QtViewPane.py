from abc import ABCMeta, abstractmethod
from enum import Enum

from PyQt5 import QtCore
from PyQt5.QtCore import QRect, QSize
from PyQt5.QtWidgets import QMenu, QWidget

from qt.controls.QToolWindowManager.IEditorClassFactory import *


class IViewPaneClass ( IClassDesc ):
	__metaclass__ = ABCMeta

	def systemClassID( self ):
		return ESystemClassID.ESYSTEM_CLASS_VIEWPANE

	@abstractmethod
	def getRuntimeClass( self ):
		pass

	@abstractmethod
	def getPaneTitle ( self ):
		pass

	@abstractmethod
	def singlePane ( self ):
		pass

	@abstractmethod
	def needsMenuItem ( self ):
		pass

	def getMenuPath ( self ):
		return ""

	def createPane ( self ):
		return None


class EDockingDirection ( Enum ):
	DOCK_DEFAULT = 0
	DOCK_TOP = 1
	DOCK_LEFT = 2
	DOCK_RIGHT = 3
	DOCK_BOTTOM = 4
	DOCK_FLOAT = 5


class IPane:
	__metaclass__ = ABCMeta

	def initialize ( self ):
		pass

	@abstractmethod
	def getWidget ( self ):
		pass

	def getDockingDirection ( self ):
		return EDockingDirection.DOCK_FLOAT

	@abstractmethod
	def getPaneTitle ( self ):
		pass

	def getSubPanes ( self ):
		return { }

	def getPaneRect ( self ):
		return QRect ( 0, 0, 800, 500 )

	def getMinSize ( self ):
		return QSize ( 0, 0 )

	def getState ( self ):
		return { }

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
		QWidget.setAttribute ( self, QtCore.Qt.WA_DeleteOnClose )

	def getWidget ( self ):
		return self
