from candy_editor.core import *
from candy_editor.core.model import *

from .PropertyEditor import registerSimpleFieldEditorFactory
from .SearchFieldEditor import SearchFieldEditorBase

##----------------------------------------------------------------##
class ReferenceFieldEditor( SearchFieldEditorBase ):	
	def getSearchContext( self ):
		return "scene"

	def gotoObject( self ):
		signals.emit( 'selection.hint', self.target )

##----------------------------------------------------------------##

registerSimpleFieldEditorFactory( ReferenceType, ReferenceFieldEditor )
