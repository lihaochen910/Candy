from PyQt5 import QtWidgets
##----------------------------------------------------------------##
from qt.controls.Window import MainWindow
from qt.controls.Menu import MenuManager
from qt.QtEditorModule import QtEditorModule

# from qt.controls.GenericTreeWidget import GenericTreeWidget

# from moai.MOAIRuntime import MOAILuaDelegate

##----------------------------------------------------------------##
# from mock import _MOCK, isMockInstance


##----------------------------------------------------------------##

##----------------------------------------------------------------##
class SceneEditor(QtEditorModule):
    def __init__(self):
        pass

    def getDependency(self):
        return ['qt']

    def setupMainWindow(self):
        self.mainWindow = QtMainWindow(None)
        self.mainWindow.setBaseSize(800, 600)
        self.mainWindow.resize(800, 600)
        self.mainWindow.setWindowTitle('Candy - Scene Editor')
        self.mainWindow.setMenuWidget(self.getQtSupport().getSharedMenubar())
        self.mainWindow.module = self

        self.mainToolBar = self.addToolBar('scene', self.mainWindow.requestToolBar('main'))
        self.statusBar = QtWidgets.QStatusBar()
        self.mainWindow.setStatusBar(self.statusBar)

    def onLoad(self):
        self.setupMainWindow()
        self.containers = {}

        self.addTool('scene/run', label='Run')

        return True

    def onStart(self):
        self.setFocus()
        self.restoreWindowState(self.mainWindow)

    def onStop(self):
        self.saveWindowState(self.mainWindow)

    # controls
    def onSetFocus(self):
        self.mainWindow.show()
        self.mainWindow.raise_()
        self.mainWindow.setFocus()

    # resource provider
    def requestDockWindow(self, id, **dockOptions):
        container = self.mainWindow.requestDockWindow(id, **dockOptions)
        self.containers[id] = container
        return container

    def requestSubWindow(self, id, **windowOption):
        container = self.mainWindow.requestSubWindow(id, **windowOption)
        self.containers[id] = container
        return container

    def requestDocumentWindow(self, id, **windowOption):
        container = self.mainWindow.requestDocuemntWindow(id, **windowOption)
        self.containers[id] = container
        return container

    def getMainWindow(self):
        return self.mainWindow

    def onMenu(self, node):
        name = node.name


##----------------------------------------------------------------##
class QtMainWindow(MainWindow):
    """docstring for QtMainWindow"""

    def __init__(self, parent, *args):
        super(QtMainWindow, self).__init__(parent, *args)

    def closeEvent(self, event):
        if self.module.alive:
            self.hide()
            event.ignore()
        else:
            pass


##----------------------------------------------------------------##
class SceneEditorModule(QtEditorModule):
    def getMainWindow(self):
        return self.getModule('scene_editor').getMainWindow()


##----------------------------------------------------------------##
SceneEditor().register()
