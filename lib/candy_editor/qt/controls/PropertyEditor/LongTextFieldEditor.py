import logging

from candy_editor.core import app

from .PropertyEditor import FieldEditor, registerFieldEditorFactory, FieldEditorFactory
from .FieldEditorControls import *

from PyQt5 import QtGui, QtCore, uic, QtWidgets
from PyQt5.QtCore import Qt
from PyQt5.QtCore import QEventLoop, QEvent, QObject

from candy_editor.core import getModulePath
from candy_editor.qt.helpers.IconCache  import getIcon

LongTextForm,BaseClass = uic.loadUiType ( getModulePath ( './LongTextEditor.ui', __file__ ) )

class WindowAutoHideEventFilter( QObject ):
	def eventFilter(self, obj, event):
		e = event.type()
		if e == QEvent.WindowDeactivate:
			obj.hide()
		return QObject.eventFilter( self, obj, event )

class LongTextEditorWidget( QtWidgets.QWidget ):
	def __init__( self, *args ):
		super( LongTextEditorWidget, self ).__init__( *args )
		self.setWindowFlags( Qt.Popup )
		self.ui = LongTextForm()
		self.ui.setupUi( self )
		self.installEventFilter( WindowAutoHideEventFilter( self ) )

		self.editor = None
		self.originalText = ''

		self.ui.buttonOK.clicked.connect( self.apply )
		self.ui.buttonCancel.clicked.connect( self.cancel )
		self.ui.textContent.textChanged.connect( self.onTextEdited )

		self.setFocusProxy( self.ui.textContent )
	
	def getText( self ):
		return self.ui.textContent.toPlainText()

	def startEdit( self, editor, text ):
		self.originalText = text or ''
		self.editor = editor
		self.ui.textContent.setPlainText( text )
		self.ui.textContent.selectAll()

	def hideEvent( self, ev ):
		self.apply( True )
		return super( LongTextEditorWidget, self ).hideEvent( ev )

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

	def onTextEdited( self  ):
		if self.editor:
			self.editor.changeText( self.getText() )

	def keyPressEvent( self, ev ):
		key = ev.key()
		if ( key, ev.modifiers() ) == ( Qt.Key_Return, Qt.ControlModifier ):
			self.apply()
			return
		if key == Qt.Key_Escape:
			self.cancel()
			return
		return super( LongTextEditorWidget, self ).keyPressEvent( ev )


##----------------------------------------------------------------##
_LongTextEditorWidget = None

def getLongTextEditorWidget():
	global _LongTextEditorWidget
	if not _LongTextEditorWidget:
		_LongTextEditorWidget = LongTextEditorWidget( None )
	return _LongTextEditorWidget

##----------------------------------------------------------------##
class LongTextFieldButton( QtWidgets.QToolButton ):
	def sizeHint( self ):
		return QtCore.QSize( 20, 20)

class LongTextFieldWidget( QtWidgets.QWidget ):
	def __init__( self, *args ):
		super( LongTextFieldWidget, self ).__init__( *args )
		self.layout = layout = QtWidgets.QHBoxLayout( self )
		layout.setSpacing( 0 )
		layout.setMargin( 0 )
		self.lineText = FieldEditorLineEdit( self )
		self.lineText.setMinimumSize( 50, 16 )
		self.lineText.setReadOnly( True )
		self.buttonEdit = LongTextFieldButton( self )
		self.buttonEdit.setSizePolicy(
			QtWidgets.QSizePolicy.Fixed,
			QtWidgets.QSizePolicy.Fixed
			)
		layout.addWidget( self.lineText  )
		layout.addWidget( self.buttonEdit  )
		self.text = ''
		self.buttonEdit.setIcon( getIcon('pencil') )
	
	def setText( self, t ):
		self.text = t
		self.lineText.setText( t )

	def getText( self ):
		return self.text


##----------------------------------------------------------------##
class LongTextFieldEditor( FieldEditor ):	
	def get( self ):
		return self.text

	def set( self, value ):
		self.text = value
		self.widget.setText( value or '' )

	def initEditor( self, container ):
		self.text = ''
		self.widget = LongTextFieldWidget( container )
		self.widget.buttonEdit.clicked.connect( self.startEdit )
		if self.getOption( 'readonly', False ):
			self.widget.buttonEdit.setEnabled( False )
		return self.widget

	def startEdit( self ):
		editor = getLongTextEditorWidget()
		pos        = QtGui.QCursor.pos()
		editor.move( pos )
		editor.show()
		editor.raise_()
		editor.setFocus()
		editor.startEdit( self, self.text )

	def changeText( self, t ):
		self.text = t
		self.widget.setText( t )
		self.notifyChanged( t )

##----------------------------------------------------------------##
class LongTextFieldEditorFactory( FieldEditorFactory ):
	def getPriority( self ):
		return 10

	def build( self, parentEditor, field, context = None ):
		dataType  = field._type
		if dataType != str: return None
		widget = field.getOption( 'widget', None )
		if widget == 'textbox':
			editor = LongTextFieldEditor( parentEditor, field )
			return editor
		return None

registerFieldEditorFactory( LongTextFieldEditorFactory() )
