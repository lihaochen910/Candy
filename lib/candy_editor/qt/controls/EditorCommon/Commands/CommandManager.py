
class SCommandTableEntry:

	def __init__ ( self ):
		self.command = None
		self.deleter = None


class CEditorCommandManager:
	CUSTOM_COMMAND_ID_FIRST = 10000
	CUSTOM_COMMAND_ID_LAST = 15000

	def __init__ ( self ):
		self.commands = {}
		self.deprecatedCommands = {}
		self.commandModules = {}
		self.customCommands = []
		self.bWarnDuplicate = False
		self.areActionsEnabled = False

	def registerAutoCommands ( self ):
		pass

	def addCommand ( self, command ):
		pass

	def addCommandModule ( self, command ):
		pass

	def unregisterCommand ( self, cmdFullName ):
		pass

	def execute ( self, cmdLine ):
		pass

	def executeWithArg ( self, module, name, args ):
		pass

	def getCommandList ( self, cmds ):
		pass

	def remapCommand ( self, oldModule, oldName, newModule ):
		pass

	def isCommandDeprecated ( self, cmdFullName ):
		pass

	def findOrCreateModuleDescription ( self, moduleName ):
		pass

	def getCommand ( self, cmdFullName ):
		pass

	def setChecked ( self, cmdFullName, checked ):
		pass

	def getAction ( self, cmdFullName, text = None ):
		pass

	def createNewAction ( self, cmdFullName ):
		pass

	def getCommandAction ( self, command, text = None ):
		pass

	def setEditorUIActionsEnabled ( self, bEnabled ):
		pass

	def isRegistered ( self, module, name ):
		pass

	def turnDuplicateWarningOn ( self ):
		self.bWarnDuplicate = True

	def turnDuplicateWarningOff ( self ):
		self.bWarnDuplicate = False

	def registerAction ( self, action, command ):
		pass

	def setUiDescription ( self, module, name, info ):
		pass

	def resetShortcut ( self, commandFullName ):
		pass

	def resetAllShortcuts ( self ):
		pass

	def addCustomCommand ( self, command ):
		pass

	def removeCustomCommand ( self, command ):
		pass

	def removeAllCustomCommands ( self ):
		pass

	def getCustomCommandList ( self, cmds ):
		pass

	def getFullCommandName ( self, module, name ):
		pass

	def getArgsFromString ( self, argsTxt, argList ):
		pass

	def logCommand ( self, fullCmdName, args ):
		pass

	def executeAndLogReturn ( self, command, args ):
		pass
