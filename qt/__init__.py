from PyQt5 import sip
# import sip
sip.setapi("QString", 2)
sip.setapi('QVariant', 2)

from . import QtSupport
from .TopEditorModule import TopEditorModule
