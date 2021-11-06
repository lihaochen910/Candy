from enum import IntEnum
from abc import abstractmethod

from PyQt5.QtCore import Qt, pyqtSignal, QPoint, qWarning, QDataStream, QObject
from PyQt5.QtGui import QPainter
from PyQt5.QtWidgets import QWidget, QSizePolicy, QBoxLayout, QStyleOption, QStyle, QSpacerItem, QApplication

from ..DragDrop import CDragDropData
from .ToolBarAreaItem import CToolBarAreaItem, CToolBarItem, CSpacerItem, CSpacerType


class QItemDescType ( IntEnum ):
	Command = 0
	CVar = 1
	Separator = 2


class QItemDesc:

	@abstractmethod
	def toVariant ( self ):
		pass

	@abstractmethod
	def getType ( self ):
		pass


class QSeparatorDesc ( QItemDesc ):

	def toVariant ( self ):
		return "separator"

	def getType ( self ):
		return QItemDescType.Separator


# TODO: QCommandDesc
class QCommandDesc ( QItemDesc ):
	commandChangedSignal = pyqtSignal ()

	def __init__ ( self, commandOrVariantMap, version ):
		self.name = ''
		self.command = ''
		self.iconPath = ''
		self.isCustom = True
		self.isDeprecated = True

	def toVariant ( self ):
		return "separator"

	def toQCommandAction ( self ):
		pass

	def getType ( self ):
		return QItemDescType.Command

	def setName ( self, name ):
		pass

	def setIcon ( self, path ):
		pass

	def getName ( self ):
		return self.name

	def getCommand ( self ):
		return self.command

	def getIcon ( self ):
		return self.iconPath

	def isCustom ( self ):
		return self.isCustom

	def isDeprecated ( self ):
		pass

	def initFromCommand ( self, command ):
		pass


class QCVarDesc ( QItemDesc ):
	cvarChangedSignal = pyqtSignal ()

	def __init__ ( self, variantMap = None, version = None ):
		self.name = ''
		self.iconPath = ''
		self.value = {}
		self.isBitFlag_ = True

	def toVariant ( self ):
		return "separator"

	def getType ( self ):
		return QItemDescType.CVar

	def setCVar ( self, path ):
		pass

	def setCVarValue ( self, cvarValue ):
		pass

	def setIcon ( self, path ):
		pass

	def getName ( self ):
		return self.name

	def getValue ( self ):
		return self.value

	def getIcon ( self ):
		return self.iconPath

	def isBitFlag ( self ):
		return self.isBitFlag_


class QToolBarDesc:
	toolBarChangedSignal = pyqtSignal ( object )

	@staticmethod
	def getNameFromFileInfo ( self, fileInfo ):
		pass

	def __init__ ( self ):
		self.name = ''
		self.path = ''
		self.items = []
		self.separatorIndices = []
		self.updated = False

	def initialize ( self, commandList, version ):
		pass

	def toVariant ( self ):
		pass

	def indexOfItem ( self, item ):
		pass

	def indexOfCommand ( self, command ):
		pass

	def getItemDescAt ( self, idx ):
		return self.items[ idx ]

	def createItem ( self, item, version ):
		pass

	def moveItem ( self, currIdx, idx ):
		pass

	def insertItem ( self, itemVariant, idx ):
		pass

	def insertCommand ( self, command, idx ):
		pass

	def insertCVar ( self, cvarName, idx ):
		pass

	def insertSeparator ( self, idx ):
		pass

	def removeItem ( self, itemOrIdx ):
		pass

	def getName ( self ):
		return self.name

	def setName ( self, name ):
		self.name = name

	def getPath ( self ):
		return self.path

	def setPath ( self, path ):
		self.path = path

	def getObjectName ( self ):
		return self.name + "ToolBar"

	def getItems ( self ):
		return self.items

	def requiresUpdate ( self ):
		pass

	def markAsUpdated ( self ):
		self.updated = True

	def onCommandChanged ( self ):
		self.toolBarChangedSignal.emit ( self )

	def insertItem ( self, item, idx ):
		pass


class CVarActionMapper ( QObject ):

	def addCVar ( self, cVarDesc ):
		pass

	def onCVarChanged ( self, cVar ):
		pass

	def onCVarActionDestroyed ( self, cVar, object ):
		pass


class CToolBarService:  # CUserData

	def __init__ ( self ):
		pass

	def createToolBarDesc ( self, editor, szName ):
		pass

	def saveToolBar ( self, toolBarDesc ):
		pass

	def removeToolBar ( self, toolBarDesc ):
		pass

	def getToolBarNames ( self, editor ):
		pass

	def getToolBarDesc ( self, editor, name ):
		pass

	def toVariant ( self, command ):
		pass

	def createToolBar ( self, toolBarDesc, toolBar, editor ):
		pass

	def loadToolBars ( self, editor ):
		pass

	def migrateToolBars ( self, szSourceDirectory, szDestinationDirectory ):
		pass

	def createToolBarDesc ( self, szEditorName, szToolBarName ):
		pass

	def getToolBarNames ( self, szRelativePath ):
		pass

	def loadToolBars ( self, szRelativePath, editor = None ):
		pass

	def getToolBarDesc ( self, szRelativePath ):
		pass

	def getToolBarDirectories ( self, szRelativePath ):
		pass

	def findToolBarsInDirAndExecute ( self, dirPath, callback ):
		pass

	def getToolBarNamesFromDir ( self, dirPath, outResult ):
		pass

	def loadToolBarsFromDir ( self, dirPath, outToolBarDescriptors ):
		pass

	def loadToolBar ( self, absolutePath ):
		pass

	def createEditorToolBars ( self, toolBarDescriptors, editor = None ):
		pass

	def createEditorToolBar ( self, toolBarDesc, editor = None ):
		pass
