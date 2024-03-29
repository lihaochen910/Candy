import logging

from PropertyEditor import registerFieldEditorFactory, FieldEditorFactory
from FieldEditorControls import *

from PyQt5 import QtGui, QtCore, uic
from PyQt5.QtCore import Qt
from PyQt5.QtCore import QEventLoop, QEvent, QObject

from qt.helpers.IconCache  import getIcon
from qt.controls.CodeEditor import CodeEditor
from qt.helpers    import addWidgetWithLayout, restrainWidgetToScreen
import signals

from LongTextFieldEditor import *

##----------------------------------------------------------------##
def getModulePath( path ):
	import os.path
	return os.path.dirname( __file__ ) + '/' + path

CodeBoxForm,BaseClass = uic.loadUiType( getModulePath( 'CodeBoxEditor.ui' ) )

class WindowAutoHideEventFilter(QObject):
	def eventFilter(self, obj, event):
		e = event.type()
		if e == QEvent.WindowDeactivate:
			obj.hide()
		return QObject.eventFilter( self, obj, event )
		

class CodeBoxEditorWidget( QtWidgets.QWidget ):
	def __init__( self, *args ):
		super( CodeBoxEditorWidget, self ).__init__( *args )
		self.setWindowFlags( Qt.Popup | Qt.Window )
		self.ui = CodeBoxForm()
		self.ui.setupUi( self )
		self.installEventFilter( WindowAutoHideEventFilter( self ) )

		self.editor = None
		self.originalText = ''

		self.ui.buttonOK.clicked.connect( self.apply )
		self.ui.buttonCancel.clicked.connect( self.cancel )
		self.codeBox = CodeEditor( self.ui.containerContent )
		layout = QtWidgets.QVBoxLayout( self.ui.containerContent )
		layout.addWidget( self.codeBox )
		layout.setSpacing( 0 )
		layout.setMargin( 0 )

		# settingData = jsonHelper.tryLoadJSON(
		# 		app.findDataFile( 'script_settings.json' )
		# 	)
		# if settingData:
		# 	self.codeBox.applySetting( settingData )
		
		self.setFocusProxy( self.codeBox )
	
	def getText( self ):
		return self.codeBox.toPlainText()

	def startEdit( self, editor, text ):
		self.originalText = text or ''
		self.editor = editor
		self.codeBox.setPlainText( text, 'text/x-lua' )

	def hideEvent( self, ev ):
		self.apply( True )
		return super( CodeBoxEditorWidget, self ).hideEvent( ev )

	def apply( self, noHide = False ):
		if self.editor:
			self.editor.changeText( self.getText() )
			self.editor = None
		if not noHide:
			self.hide()

	def cancel( self, noHide = False ):
		if self.editor:
			self.editor.changeText( self.originalText )
			self.editor = None
		if not noHide:
			self.hide()

	def keyPressEvent( self, ev ):
		key = ev.key()
		if ( key, ev.modifiers() ) == ( Qt.Key_Return, Qt.ControlModifier ):
			print("????" )
			self.apply()
			return
		# if key == Qt.Key_Escape:
		# 	self.cancel()
		# 	return
		return super( CodeBoxEditorWidget, self ).keyPressEvent( ev )


##----------------------------------------------------------------##
_CodeBoxEditorWidget = None

def getCodeBoxEditorWidget():
	global _CodeBoxEditorWidget
	if not _CodeBoxEditorWidget:
		_CodeBoxEditorWidget = CodeBoxEditorWidget( None )
	return _CodeBoxEditorWidget

##----------------------------------------------------------------##
class CodeBoxFieldEditor( LongTextFieldEditor ):	
	def startEdit( self ):
		editor = getCodeBoxEditorWidget()
		pos        = QtGui.QCursor.pos()
		editor.move( pos )
		restrainWidgetToScreen( editor )
		editor.startEdit( self, self.text )
		editor.show()
		editor.raise_()
		editor.setFocus()

##----------------------------------------------------------------##
class CodeBoxFieldEditorFactory( FieldEditorFactory ):
	def getPriority( self ):
		return 10

	def build( self, parentEditor, field, context = None ):
		dataType  = field._type
		if dataType != str: return None
		widget = field.getOption( 'widget', None )
		if widget == 'codebox':
			editor = CodeBoxFieldEditor( parentEditor, field )
			return editor
		return None

signals.connect( 'app.pre_start', getCodeBoxEditorWidget )

registerFieldEditorFactory( CodeBoxFieldEditorFactory() )
