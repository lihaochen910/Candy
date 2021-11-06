from enum import IntEnum

from PyQt5.QtCore import pyqtSignal
from PyQt5.QtWidgets import QAction, QMenu



class EPriorities ( IntEnum ):
	ePriorities_Append = -1
	ePriorities_Min = 0


class ESections ( IntEnum ):
	eSections_Default = -1
	eSections_Min = 0


class SSection:

	def __init__ ( self ):
		self.section = 0
		self.name = ""


# Creates a menu-like widget (e.g., QMenu, QMenuBar, ...) from an abstract menu.
class IWidgetBuilder:

	def addAction ( self, action ):
		pass

	def addSection ( self, sec ):
		pass

	def setEnabled ( self, enabled ):
		pass

	def addMenu ( self, menu ):
		pass


class CDescendantModifiedEvent:
	ActionAdded = 0

	def getType ( self ):
		pass


class CActionAddedEvent ( CDescendantModifiedEvent ):

	def __init__ ( self, action ):
		self.action = action

	def getType ( self ):
		return CDescendantModifiedEvent.ActionAdded

	def getAction ( self ):
		return self.action


class CAbstractMenu:
	signalDescendantModified = pyqtSignal ( CDescendantModifiedEvent )
	signalActionAdded = pyqtSignal ( QAction )
	signalMenuAdded = pyqtSignal ( object )
	signalAboutToShow = pyqtSignal ( object )

	def __init__ ( self ):
		self.subMenus = []
		self.actions = []
		self.subMenuItems = []
		self.actionItems = []
		self.sortedItems = []
		self.sortedNamedSections = []
		self.name = ""
		self.bEnabled = ""

	def getNextEmptySection ( self ):
		pass

	def isEmpty ( self ):
		pass

	def getMaxSection ( self ):
		pass

	def getMaxPriority ( self, section ):
		pass

	def clear ( self ):
		pass

	def addAction ( self, action, sectionHint = ESections.eSections_Default,
	                priorityHint = EPriorities.ePriorities_Append ):
		pass

	def addCommandAction ( self, action, sectionHint = ESections.eSections_Default,
	                       priorityHint = EPriorities.ePriorities_Append ):
		pass

	def createCommandAction ( self, szCommand, sectionHint = ESections.eSections_Default,
	                          priorityHint = EPriorities.ePriorities_Append ):
		pass

	def createAction ( self, name, sectionHint = ESections.eSections_Default,
	                   priorityHint = EPriorities.ePriorities_Append ):
		pass

	def createMenu ( self, szName, sectionHint = ESections.eSections_Default,
	                 priorityHint = EPriorities.ePriorities_Append ):
		pass

	def findAction ( self, name ):
		pass

	def setSectionName ( self, section, szName ):
		pass

	def isNamedSection ( self, section ):
		pass

	def getSectionName ( self, section ):
		pass

	def findSectionByName ( self, szName ):
		pass

	def findOrCreateSectionByName ( self, szName ):
		pass

	def findMenu ( self, szName ):
		pass

	def findMenuRecursive ( self, szName ):
		pass

	def containsAction ( self, action ):
		pass

	def setEnabled ( self, enabled ):
		self.bEnabled = enabled

	def isEnabled ( self ):
		return self.bEnabled

	def getName ( self ):
		pass

	def build ( self, widgetBuilder ):
		pass

	def getSectionFromHint ( self, sectionHint ):
		pass

	def getPriorityFromHint ( self, priorityHint, section ):
		pass

	def getDefaultSection ( self, priorityHint, section ):
		pass

	def insertItem ( self, item ):
		pass

	def insertNamedSection ( self, namedSection ):
		pass

	def onMenuAdded ( self, menu ):
		pass


class CMenu ( QMenu ):

	def __init__ ( self, parent = None ):
		super ().__init__ ( parent )

	def addCommand ( self, szCommand ):
		from qt.controls.EditorCommon.IEditor import getIEditor
		action = getIEditor ().GetCommandManager ().GetCommandAction ( szCommand )
		if action:
			self.addAction ( action )
		return action
