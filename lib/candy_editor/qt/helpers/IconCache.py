from PyQt5 import QtGui

import logging
from candy_editor.core import app

_iconCache = {}
_nullIcon = QtGui.QIcon()


def getIcon(name, fallback=None):
    global _iconCache
    if not name: return _nullIcon

    icon = _iconCache.get(name, None)
    if icon: return icon
    iconFile = None
    path = app.findDataFile('icons/%s.png' % name)
    if not path:
        if fallback:
            return getIcon(fallback)
        logging.error('icon not found: %s' % name)
        return QtGui.QIcon()

    icon = QtGui.QIcon(QtGui.QPixmap(path))
    _iconCache[name] = icon
    return icon
