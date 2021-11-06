from PyQt5.QtCore import Qt, qWarning
from PyQt5.QtWidgets import QAction

from qt.controls.EditorCommon.IEditor import getIEditor


class CCommandArgument:

	def __init__ ( self, command, index, name, description ):
		self.command = command
		self.index = index
		self.name = name
		self.description = description

	def getCommand ( self ):
		return self.name

	def getDescription ( self ):
		return self.description

	def getIndex ( self ):
		return self.index

	def getName ( self ):
		return self.name


class CCommandDescription:

	def __init__ ( self, description ):
		self.command = None
		self.params = []
		self.description = ""

	def param ( self, name, description ):
		self.params.append ( self.command, len ( self.params ), name, description )

	def getParams ( self ):
		return self.params

	def setDescription ( self, description ):
		self.description = description

	def getDescription ( self ):
		return self.description

	def setCommand ( self, parent ):
		self.command = parent
		# TODO: params


# Class for storing function parameters as a type-erased string
class CArgs:

	def __init__ ( self ):
		self.args = []
		self.stringFlags = 0 # This is needed to quote string parameters when logging a command.

	def addT ( self, p ):
		self.args.append ( "%s" % p )

	def add ( self, p ):
		self.stringFlags |= 1 << len ( self.args )
		self.args.append ( "%s" % p )

	def isStringArg ( self, i ):
		if i < 0 or i >= self.getArgCount ():
			return False
		if self.stringFlags & ( 1 << i ):
			return True
		else:
			return False

	def getArgCount ( self ):
		return len ( self.args )

	def getArg ( self, i ):
		return self.args[ i ]


class CCommand:

	def __init__ ( self, module: str, name: str, description: CCommandDescription ):
		self.module = module
		self.name = name
		self.commandDescription = description
		self.bAlsoAvailableInScripting = False

	def getName ( self ):
		return self.name

	def getModule ( self ):
		return self.module

	def getDescription ( self ):
		return self.commandDescription.getDescription ()

	def getCommandString ( self ):
		return "%s.%s" % ( self.module, self.name )

	def setAvailableInScripting ( self ):
		self.bAlsoAvailableInScripting = True

	def isAvailableInScripting ( self ):
		return self.bAlsoAvailableInScripting

	def getParameters ( self ):
		return self.commandDescription.getParams ()

	def execute ( self, args ):
		pass

	def canBeUICommand ( self ) -> bool:
		return False

	def isCustomCommand ( self ) -> bool:
		return False

	def isPolledKey ( self ) -> bool:
		return False

	def toString ( self ):
		pass

	def fromString ( self ):
		pass


class UiInfo:

	def __init__ ( self, text = "", iconName = "", shortcut = None, checkable = False ):
		self.buttonText = text
		self.icon = iconName
		self.key = shortcut
		self.isCheckable = checkable


class CUiCommand ( CCommand ):

	def __init__ ( self, module: str, name: str, description: CCommandDescription ):
		super ().__init__ ( module, name, description )
		self.uiInfo = ""

	def setDescription ( self, description ):
		self.commandDescription.setDescription ( description )

	def canBeUICommand ( self ) -> bool:
		return True

	def getUiInfo ( self ):
		return self.uiInfo

	def setUiInfo ( self, info ):
		if self.uiInfo != info:
			del self.uiInfo
			self.uiInfo = info


class QCommandAction ( QAction, UiInfo ):

	def __init__ ( self, actionName, actionText, parent, command ):
		QAction.__init__ ( self, actionName, parent )
		# UiInfo.__init__ ( self,  )
		self.setShortcutContext ( Qt.WidgetWithChildrenShortcut )
		self.setShortcutVisibleInContextMenu ( True )
		self.setText ( actionText )
		if command:
			self.setProperty ( "QCommandAction", str ( command ) )
		self.triggered.connect ( self.onTriggered )

	def getCommand ( self ):
		return self.property ( "QCommandAction" )

	def setCommand ( self, command ):
		self.setProperty ( "QCommandAction", command )

	def setDefaultShortcuts ( self, shortcuts ):
		self.defaults = shortcuts

	def getDefaultShortcuts ( self ):
		return self.defaults

	def onTriggered ( self ):
		cmd = ""
		commandProp = self.property ( "QCommandAction" )
		if commandProp:
			cmd = str ( commandProp )
		else:
			qWarning ( "Invalid QCommandAction %s" % self.objectName () )

		getIEditor ().executeCommand ( cmd )
