from PyQt5.QtCore import Qt, pyqtSignal, QByteArray, QIODevice, QDataStream, QPoint, QSize
from PyQt5.QtGui import QPixmap, QPainter, QColor, QIcon
from PyQt5.QtWidgets import QWidget, QSizePolicy, QBoxLayout, QLabel, QStyleOption, QStyle, QHBoxLayout, QToolBar, \
	QVBoxLayout, QToolButton, QLineEdit

from ..DragDrop import CDragDropData
from ..Editor import CEditor
from ..EditorDialog import CEditorDialog
from ..IEditor import getIEditor


class CToolBarCustomizeDialog ( CEditorDialog ):
	signalToolBarAdded = pyqtSignal ( QToolBar )
	signalToolBarModified = pyqtSignal ( QToolBar )
	signalToolBarRenamed = pyqtSignal ( str, QToolBar )
	signalToolBarRemoved = pyqtSignal ( str )

	def __init__ ( self, parent, szEditorName ):
		super ().__init__ ()
		self.selectedItem = None
		self.dropContainer = None
		self.dropContainer = None
		self.toolbarSelect = None
		self.treeView = None
		self.itemModel = None  # TODO: CCommandModel
		self.proxyModel = None  # TODO: QDeepFilterProxyModel
		self.preview = None
		self.nameInput = None
		self.commandInput = None
		self.iconInput = None
		self.cVarInput = None
		self.cVarValueInput = None
		self.iconBrowserButton = None
		self.cVarBrowserButton = None
		self.searchBox = None
		self.editor = parent if isinstance ( parent, CEditor ) else None
		self.editorName = szEditorName
		self.commandWidgets = []
		self.cvarWidgets = []

		self.setAttribute ( Qt.WA_DeleteOnClose )
		self.toolbarSelect.itemRenamed.connect ( self.renameToolBar )

		toolBarNames = getIEditor ().GetToolBarService ().getToolBarNames ( self.editorName )
		for toolBarName in toolBarNames:
			self.toolbarSelect.addItem ( toolBarName )

		layout = QVBoxLayout ()
		layout.setContentsMargins ( 0, 0, 0, 0 )
		layout.setSpacing ( 0 )

		innerLayout = QHBoxLayout ()
		innerLayout.setAlignment ( Qt.AlignVCenter )
		innerLayout.setContentsMargins ( 0, 0, 0, 0 )
		innerLayout.setSpacing ( 0 )

		addToolBar = QToolButton ()
		addToolBar.setIcon ( QPixmap ( 'General/Plus.ico' ) )
		addToolBar.setToolTip ( QPixmap ( "Create new Toolbar" ) )
		addToolBar.clicked.connect ( self.onAddToolBar )

		removeToolBar = QToolButton ()
		removeToolBar.setIcon ( QPixmap ( 'General/Folder_Remove.ico' ) )
		removeToolBar.setToolTip ( QPixmap ( "Remove Toolbar" ) )
		removeToolBar.clicked.connect ( self.onRemoveToolBar )

		renameToolBar = QToolButton ()
		renameToolBar.setIcon ( QPixmap ( 'General/editable_true.ico' ) )
		renameToolBar.setToolTip ( QPixmap ( "Rename Toolbar" ) )
		onRenameToolBarClicked = lambda: self.toolbarSelect.onBeginEditing () if len (
			self.toolbarSelect.getCurrentText () ) != 0 else None
		renameToolBar.clicked.connect ( onRenameToolBarClicked )

		innerLayout.addWidget ( self.toolbarSelect )
		innerLayout.addWidget ( addToolBar )
		innerLayout.addWidget ( renameToolBar )
		innerLayout.addWidget ( removeToolBar )

		# TODO: CCommandModel

		# TODO: QSearchBox

		# TODO: QAdvancedTreeView

		self.dropContainer = QDropContainer ( self )
		self.dropContainer.setObjectName ( "DropContainer" )
		self.dropContainer.signalToolBarModified.connect ( self.onToolBarModified )

		nameLayout = QHBoxLayout ()
		nameLayout.setContentsMargins ( 0, 0, 0, 0 )
		nameLayout.setSpacing ( 0 )
		nameLabel = QLabel ( "Name" )
		nameLayout.addWidget ( nameLabel )
		self.nameInput = QLineEdit ()
		self.nameInput.setEnabled ( False )
		nameLayout.addWidget ( self.nameInput )
		onEditingFinished = lambda: self.setCommandName ( self.nameInput.text () )
		self.nameInput.editingFinished.connect ( onEditingFinished )

		self.commandWidgets.append ( nameLabel )
		self.commandWidgets.append ( self.nameInput )
		commandLayout = QHBoxLayout ()
		commandLabel = QLabel ( "Command" )
		commandLayout.addWidget ( commandLabel )
		commandLayout.setContentsMargins ( 0, 0, 0, 0 )
		commandLayout.setSpacing ( 0 )
		self.commandInput = QLineEdit ()
		self.commandInput.setEnabled ( False )
		commandLayout.addWidget ( self.commandInput )

		self.commandWidgets.append ( commandLabel )
		self.commandWidgets.append ( self.commandInput )

		self.cVarInput = QLineEdit ()
		self.cVarInput.setEnabled ( False )
		self.cVarInput.setVisible ( False )
		self.cVarBrowserButton = QToolButton ()
		self.cVarBrowserButton.setIcon ( QIcon ( "General/Folder.ico" ) )
		self.cVarBrowserButton.setEnabled ( False )
		self.cVarBrowserButton.setVisible ( False )
		self.cVarBrowserButton.setObjectName ( "open-cvar" )

		def onCVarBrowserButtonClicked ():
			dialog = CCVarBrowserDialog ()
			dialog.show ()
			onDialog = lambda: self.cVarsSelected ( dialog.getSelectedCVars () )
			dialog.accepted.connect ( onDialog )

		self.cVarBrowserButton.clicked.connect ( onCVarBrowserButtonClicked )
		onCVarInputEditingFinished = lambda: self.setCVarName ( self.cVarInput.text () )
		self.cVarInput.editingFinished.connect ( onCVarInputEditingFinished )

		cVarLayout = QHBoxLayout ()
		cVarLayout.setContentsMargins ( 0, 0, 0, 0 )
		cVarLayout.setSpacing ( 0 )
		cVarLabel = QLabel ( "CVar" )
		cVarLabel.setVisible ( False )
		cVarLayout.addWidget ( cVarLabel )
		cVarLayout.addWidget ( self.cVarInput )
		cVarLayout.addWidget ( self.cVarBrowserButton )

		self.cvarWidgets.append ( cVarLabel )
		self.cvarWidgets.append ( self.cVarInput )
		self.cvarWidgets.append ( self.cVarBrowserButton )

		cVarValueLayout = QHBoxLayout ()
		cVarValueLayout.setContentsMargins ( 0, 0, 0, 0 )
		cVarValueLayout.setSpacing ( 0 )
		cVarValueLabel = QLabel ( "CVar" )
		cVarValueLabel.setVisible ( False )
		cVarValueInput = QLineEdit ()
		cVarValueInput.setEnabled ( False )
		cVarValueInput.setVisible ( False )
		cVarValueLayout.addWidget ( cVarValueLabel )
		cVarValueLayout.addWidget ( cVarValueInput )
		onCVarInputEditingFinished = lambda: self.setCVarValue ( self.cVarValueInput.text () )
		self.cVarValueInput.editingFinished.connect ( onCVarInputEditingFinished )

		self.cvarWidgets.append ( cVarValueLabel )
		self.cvarWidgets.append ( cVarValueInput )

		self.iconInput = QLineEdit ()
		self.iconInput.setEnabled ( False )
		self.iconBrowserButton = QToolButton ()
		self.iconBrowserButton.setIcon ( QIcon ( "General/Folder.ico" ) )
		self.iconBrowserButton.setObjectName ( "open-icon" )
		self.iconBrowserButton.setEnabled ( False )

		def onIconBrowserButtonClicked ():
			dialog = QResourceBrowserDialog ()
			dialog.show ()
			onDialogAccepted = lambda: self.iconSelected ( dialog.getSelectedResource () )
			dialog.accepted.connect ( onDialogAccepted )

		self.iconBrowserButton.clicked.connect ( onIconBrowserButtonClicked )
		onIconInputEditingFinished = lambda: self.setIconPath ( self.iconInput.text () )
		self.iconInput.editingFinished.connect ( onIconInputEditingFinished )

		iconLayout = QHBoxLayout ()
		iconLayout.setContentsMargins ( 0, 0, 0, 0 )
		iconLayout.setSpacing ( 0 )
		iconLabel = QLabel ( "Icon" )
		iconLayout.addWidget ( iconLabel )
		iconLayout.addWidget ( self.iconInput )
		iconLayout.addWidget ( self.iconBrowserButton )

		self.commandWidgets.append ( iconLabel )
		self.commandWidgets.append ( self.iconInput )
		self.commandWidgets.append ( self.iconBrowserButton )
		self.cvarWidgets.append ( iconLabel )
		self.cvarWidgets.append ( self.iconInput )
		self.cvarWidgets.append ( self.iconBrowserButton )

		innerContainer = QWidget ()
		innerContainer.setLayout ( innerLayout )
		innerContainer.setObjectName ( "ToolbarComboBoxContainer" )
		commandDetailsLayout = QVBoxLayout ()
		commandDetailsLayout.setContentsMargins ( 0, 0, 0, 0 )
		commandDetailsLayout.setSpacing ( 0 )
		commandDetailsLayout.addLayout ( nameLayout )
		commandDetailsLayout.addLayout ( commandLayout )
		commandDetailsLayout.addLayout ( cVarLayout )
		commandDetailsLayout.addLayout ( cVarValueLayout )
		commandDetailsLayout.addLayout ( iconLayout )

		commandDetails = QWidget ()
		commandDetails.setLayout ( commandDetailsLayout )
		commandDetails.setObjectName ( "ToolbarPropertiesContainer" )

		# layout.addWidget ( searchBoxContainer )
		layout.addWidget ( self.treeView )
		layout.addWidget ( innerLayout )
		layout.addWidget ( self.dropContainer )
		layout.addWidget ( commandDetails )

		self.dropContainer.selectedItemChanged.connect ( self.onSelectedItemChanged )

		self.currentItemChanged ()

		self.setAcceptDrops ( True )
		self.setLayout ( layout )

	# if isinstance ( parent, CEditor ):
	# 	self.itemModel.deleteLater ()
	# 	self.itemModel = CCommandModel ( self.editor.getCommands () )
	# 	self.itemModel.enableDragAndDropSupport ( True )
	#
	# 	self.proxyModel = QDeepFilterProxyModel ()
	# 	self.proxyModel.setSourceModel ( self.itemModel )
	#
	# 	self.searchBox.setModel ( self.proxyModel )
	# 	self.treeView.setModel ( self.proxyModel )

	def getCurrentToolBarText ( self ):
		self.toolbarSelect.getCurrentText ()

	def iconSelected ( self, szIconPath ):
		self.iconInput.setText ( szIconPath )
		self.setIconPath ( szIconPath )

	def cVarsSelected ( self, selectedCVars ):
		pass

	def setCVarName ( self, cvarName ):
		pass

	def setCVarValue ( self, cvarValue ):
		pass

	def setCommandName ( self, commandName ):
		pass

	def setIconPath ( self, szIconPath ):
		pass

	def onSelectedItemChanged ( self, selectedItem ):
		pass

	def dragEnterEvent ( self, event ):
		dragDropData = CDragDropData.fromMimeData ( event.mimeData () )
		if dragDropData.hasCustomData ( CDragDropData.getMimeFormatForType () ):
			event.acceptProposedAction ()

	def dropEvent ( self, event ):
		dragDropData = CDragDropData.fromMimeData ( event.mimeData () )
		if dragDropData.hasCustomData ( CDragDropData.getMimeFormatForType () ):
			self.dropContainer.removeItem ( self.selectedItem )

	def sizeHint ( self ):
		return QSize ( 640, 480 )

	def currentItemChanged ( self ):
		pass

	def onAddToolBar ( self ):
		pass

	def onToolBarModified ( self, toolBarDesc ):
		pass

	def onRemoveToolBar ( self ):
		pass

	def onContextMenu ( self, position ):
		pass

	def renameToolBar ( self, before, after ):
		pass

	def showCommandWidgets ( self ):
		pass

	def showCVarWidgets ( self ):
		pass

	def setCVarValueRegExp ( self ):
		pass


class QDropContainer ( QWidget ):
	toolBarItemMimeType = None
	selectedItemChanged = pyqtSignal ()
	signalToolBarModified = pyqtSignal ()

	def __init__ ( self, parent ):
		super ().__init__ ( parent )
		self.selectedItem = None
		self.dragStartPosition = QPoint ()
		self.toolBarCreator = None
		self.currentToolBar = None
		self.currentToolBarDesc = None
		self.bDragStarted = False
		self.setAcceptDrops ( True )
		self.previewLayout = QHBoxLayout ()
		self.previewLayout.setContentsMargins ( 0, 0, 0, 0 )
		self.setLayout ( self.previewLayout )

	def __del__ ( self ):
		if self.currentToolBar:
			del self.currentToolBar
			self.currentToolBar = None

	def addItem ( self, itemVariant, idx = -1 ):
		pass

	def addCommand ( self, command, idx = -1 ):
		pass

	def addSeparator ( self, sourceIdx = -1, targetIdx = -1 ):
		pass

	def addCVar ( self, cvarName, idx = -1 ):
		pass

	def removeCommand ( self, command ):
		pass

	def removeItem ( self, item ):
		pass

	def removeItemAt ( self, idx ):
		pass

	def setCurrentToolBarDesc ( self, toolBarDesc ):
		pass

	def buildPreview ( self ):
		pass

	def createToolBar ( self, title, toolBarDesc ):
		pass

	def getCurrentToolBarDesc ( self ):
		return self.currentToolBarDesc

	def setIcon ( self, szPath ):
		pass

	def setCVarName ( self, szCVarName ):
		pass

	def setCVarValue ( self, szCVarValue ):
		pass

	def eventFilter ( self, object, event ):
		pass

	def mouseMoveEvent ( self, event ):
		pass

	def dragEnterEvent ( self, event ):
		if self.currentToolBar == None:
			return
		dragDropData = CDragDropData.fromMimeData ( event.mimeData () )
		if dragDropData.hasCustomData ( CDragDropData.getMimeFormatForType () ) or dragDropData.hasCustomData ( CCommandModel.getCommandMimeType () ):
			event.acceptProposedAction ()
			self.currentToolBar.drawDropTarget ( self.mapToGlobal ( event.pos () ) )

	def dragMoveEvent ( self, event ):
		dragDropData = CDragDropData.fromMimeData ( event.mimeData () )
		if dragDropData.hasCustomData ( CDragDropData.getMimeFormatForType () ) or dragDropData.hasCustomData (
				CCommandModel.getCommandMimeType () ):
			event.acceptProposedAction ()
			self.currentToolBar.drawDropTarget ( self.mapToGlobal ( event.pos () ) )

	def dropEvent ( self, event ):
		pass

	def dragLeaveEvent ( self, event ):
		self.currentToolBar.setShowDropTarget ( False )

	def showContextMenu ( self, position ):
		pass

	@staticmethod
	def getToolBarItemMimeType ():
		return QDropContainer.toolBarItemMimeType

	def getIndexFromMouseCoord ( self, globalPos ):
		pass

	def paintEvent ( self, event ):
		o = QStyleOption ()
		o.initFrom ( self )
		p = QPainter ( self )
		self.style ().drawPrimitive ( QStyle.PE_Widget, o, p, self )

	def updateToolBar ( self ):
		getIEditor ().getToolBarService ().saveToolBar ( self.currentToolBarDesc )
		self.buildPreview ()

		self.signalToolBarModified ( self.currentToolBarDesc )
