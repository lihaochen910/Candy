from candy_editor.core import *
from candy_editor.core.model import *
from .PropertyEditor import FieldEditor
from candy_editor.qt.helpers.IconCache  import getIcon

from PyQt5 import QtCore, QtWidgets
from PyQt5.QtCore import Qt

from candy_editor.qt.controls.SearchView import requestSearchView

class SearchFieldButton( QtWidgets.QToolButton ):
	def sizeHint( self ):
		return QtCore.QSize( 20, 20)

	
		
##----------------------------------------------------------------##
class SearchFieldWidget( QtWidgets.QWidget ):
	def __init__(self, *args):
		super(SearchFieldWidget, self).__init__( *args )
		self.parentEditor = None
		self.layout = layout = QtWidgets.QHBoxLayout( self )
		layout.setSpacing( 0 )
		layout.setMargin( 0 )
		self.buttonRef   = buttonRef   = SearchFieldButton( self )
		self.buttonGoto  = buttonGoto  = SearchFieldButton( self )
		self.buttonClear = buttonClear = SearchFieldButton( self )
		buttonRef.setObjectName( 'ButtonReferenceField' )
		self.buttonRef.setToolButtonStyle( Qt.ToolButtonTextBesideIcon )
		buttonRef.setSizePolicy(
			QtWidgets.QSizePolicy.Expanding,
			QtWidgets.QSizePolicy.Fixed
			)
		buttonGoto.setSizePolicy(
			QtWidgets.QSizePolicy.Fixed,
			QtWidgets.QSizePolicy.Fixed
			)
		buttonClear.setSizePolicy(
			QtWidgets.QSizePolicy.Fixed,
			QtWidgets.QSizePolicy.Fixed
			)
		buttonRef.setText( '<None>' )
		buttonRef.setStyleSheet ("text-align: left;"); 
		buttonGoto.setIcon( getIcon('search-2') )
		buttonClear.setIcon( getIcon('remove') )
		layout.addWidget( buttonGoto )
		layout.addWidget( buttonRef )
		layout.addWidget( buttonClear )
		self.targetRef = None 
		self.setRef( None )
		self.setAcceptDrops( False )

	def setRef( self, target ):
		self.targetRef = target
		if not target:
			self.buttonRef.setText( '<None>' )
			self.buttonGoto.hide()
			self.buttonClear.hide()
		else:
			self.buttonRef.setText( 'Object' ) 
			self.buttonGoto.show()
			self.buttonClear.show()

	def setRefName( self, name, formatted ):
		if isinstance( formatted, (unicode, str) ):
			self.buttonRef.setText( formatted )
			self.buttonRef.setToolTip( name )
		else:
			logging.error('unknown ref name type:' + repr( formatted ) )
			self.buttonRef.setText( repr( formatted ) )
			self.buttonRef.setToolTip( '<unkown ref name>' )

	def setRefIcon( self, iconName ):
		icon = getIcon( iconName )
		self.buttonRef.setIcon( icon )

	def dragEnterEvent( self, ev ):
		self.parentEditor.dragEnterEvent( ev )

	def dropEvent( self, ev ):
		self.parentEditor.dropEvent( ev )

	def dragLeaveEvent( self, ev ):
		self.parentEditor.dragLeaveEvent( ev )

##----------------------------------------------------------------##
class SearchFieldEditorBase( FieldEditor ):	
	def setTarget( self, parent, field ):
		FieldEditor.setTarget( self, parent, field )
		self.target = None
		self.defaultTerms = self.getOption( 'search_terms' )

	def clear( self ):
		pass

	def get( self ):
		#TODO
		return None

	def set( self, value ): #update button text
		self.target = value
		self.refWidget.setRef( value )
		if value:
			r = self.getValueRepr( value )
			if isinstance( r, tuple ):
				( name, icon ) = r
				self.refWidget.setRefIcon( icon )
				self.refWidget.setRefName( name, self.formatRefName( name ) )
			else:
				self.refWidget.setRefIcon( None )
				self.refWidget.setRefName( r, self.formatRefName( r ) )
	
	def setReadonly( self, readonly ):
		self.refWidget.buttonRef.setEnabled( not readonly )
		self.refWidget.buttonClear.setEnabled( not readonly )
		if self.getOption( 'no_nil', False ):
			self.refWidget.buttonClear.setEnabled( False )

	def initEditor( self, container ):
		widget = SearchFieldWidget( container )
		widget.parentEditor = self
		widget.buttonRef   .clicked .connect( self.openBrowser )
		widget.buttonClear .clicked .connect( self.clearObject )
		widget.buttonGoto  .clicked .connect( self.gotoObject  )
		self.refWidget = widget
		if self.isDropAllowed():
			widget.setAcceptDrops( True )
		return self.refWidget

	def openBrowser( self ):
		self.prevValue = self.getSearchInitial()
		self.testApplied = False
		requestSearchView( 
			context      = self.getSearchContext(),
			type         = self.getSearchType(),
			on_selection = self.onSearchSelection,
			on_test      = self.onSearchSelectionTest,
			on_cancel    = self.onSearchCancel,
			initial      = self.getSearchInitial(),
			terms        = self.defaultTerms
			)
			#TODO: allow persist previous search terms

	def getBrowserPos( self ):
		size = self.refWidget.size()
		w, h = size.width(), size.height()
		p = self.refWidget.mapToGlobal( QtCore.QPoint( 0, h ) )
		return p

	def setFocus( self ):
		self.refWidget.setFocus()

	def getRefButton( self ):
		return self.refWidget.buttonRef

	def onSearchSelection( self, target ):
		self.setValue( target )
		self.setFocus()

	def onSearchSelectionTest( self, target ):
		self.setValue( target )
		self.testApplied = True

	def onSearchCancel( self ):
		if self.testApplied:
			self.setValue( self.prevValue )
		self.setFocus()
		self.prevValue = None		

	def setValue( self, value ):	#virtual
		self.set( value )
		self.notifyChanged( value )

	def getValueRepr( self, value ): #virtual
		return ModelManager.get().getObjectRepr( value )

	def getIcon( self, value ): #virtual
		return None

	def getSearchType( self ): #virtual
		return self.field.getType()

	def getSearchContext( self ): #virtual
		return ""

	def getSearchInitial( self ): #virtual
		return self.target

	def gotoObject( self ): #virtual
		pass		

	def clearObject( self ): #virtual
		self.setValue( None )

	def formatRefName( self, name ): #virtual
		return name

	def dragEnterEvent( self, ev ):
		pass

	def dropEvent( self, ev ):
		pass

	def isDropAllowed( self ):
		return False
