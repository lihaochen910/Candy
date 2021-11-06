from PyQt5 import sip

# import sip
sip.setapi ( "QString", 2 )
sip.setapi ( 'QVariant', 2 )

from .QtSupport import QtSupport
from .QtEditorModule import QtEditorModule
from .TopEditorModule import TopEditorModule, SubEditorModule
