import os
##----------------------------------------------------------------##
from core import *
from qt.controls.PropertyEditor import PropertyEditor
from qt.controls.Menu import MenuManager

from PyQt4 import QtCore, QtGui, uic, Qt
from PyQt4.QtCore import Qt, QEventLoop, QEvent, QObject, pyqtSignal, pyqtSlot

from SceneEditor import SceneEditorModule
from util.IDPool import IDPool

from moai.LuaBridge import getSelection
from moai.MOAIRuntime import _CANDY
from moai.CandyRuntime import isCandyInstance, isCandySubInstance
from qt.controls.GenericTreeWidget import GenericTreeWidget

from qt.controls.GLWidget import CommonGLWidget
from qt.helpers import addWidgetWithLayout, repolishWidget
from qt.helpers.IconCache import getIcon


##----------------------------------------------------------------##
ObjectContainerBase, BaseClass = uic.loadUiType(app.getPath('sceneEditor/ObjectContainer.ui'))


##----------------------------------------------------------------##
class ObjectContainer(QtGui.QWidget):
    foldChanged = pyqtSignal(bool)

    def __init__(self, *args):
        super(ObjectContainer, self).__init__(*args)
        self.ui = ObjectContainerBase()
        self.ui.setupUi(self)

        self.setSizePolicy(
            QtGui.QSizePolicy.Expanding,
            QtGui.QSizePolicy.Fixed
        )
        self.setAttribute(Qt.WA_NoSystemBackground, True)
        self.mainLayout = QtGui.QVBoxLayout(self.getInnerContainer())
        self.mainLayout.setSpacing(0)
        self.mainLayout.setMargin(0)
        self.contextObject = None

        self.folded = False
        self.toggleFold(False, True)

        self.ui.buttonFold.clicked.connect(lambda x: self.toggleFold(None))

        self.ui.buttonContext.clicked.connect(lambda x: self.openContextMenu())
        self.ui.buttonContext.setIcon(getIcon('menu'))

        self.ui.buttonName.clicked.connect(lambda x: self.toggleFold(None))
        self.ui.buttonName.setIcon(getIcon('component'))
        self.ui.buttonName.setToolButtonStyle(Qt.ToolButtonTextBesideIcon)

        self.ui.buttonKey.setIcon(getIcon('key'))
        self.ui.buttonKey.hide()

        self.ui.buttonFold.setIcon(getIcon('node_folded'))

    def getButtonKey(self):
        return self.ui.buttonKey

    def getButtonContext(self):
        return self.ui.buttonContext

    def setContextObject(self, context):
        self.contextObject = context

    def addWidget(self, widget, **layoutOption):
        if isinstance(widget, list):
            for w in widget:
                self.addWidget(w, **layoutOption)
            return
        # widget.setParent(self)
        if layoutOption.get('fixed', False):
            widget.setSizePolicy(
                QtGui.QSizePolicy.Fixed,
                QtGui.QSizePolicy.Fixed
            )
        elif layoutOption.get('expanding', True):
            widget.setSizePolicy(
                QtGui.QSizePolicy.Expanding,
                QtGui.QSizePolicy.Expanding
            )
        self.mainLayout.addWidget(widget)
        return widget

    def setContextMenu(self, menuName):
        menu = menuName and MenuManager.get().find(menuName) or None
        self.contextMenu = menu
        if not menu:
            self.ui.buttonContext.hide()
        else:
            self.ui.buttonContext.show()

    def getInnerContainer(self):
        return self.ui.ObjectInnerContainer

    def getHeader(self):
        return self.ui.ObjectHeader

    def repolish(self):
        repolishWidget(self.ui.ObjectInnerContainer)
        repolishWidget(self.ui.ObjectHeader)
        repolishWidget(self.ui.buttonContext)
        repolishWidget(self.ui.buttonKey)
        repolishWidget(self.ui.buttonFold)
        repolishWidget(self.ui.buttonName)

    def toggleFold(self, folded=None, notify=True):
        if folded == None:
            folded = not self.folded
        self.folded = folded
        if folded:
            # self.ui.buttonFold.setText( '+' )
            self.ui.buttonFold.setIcon(getIcon('node_folded'))
            self.ui.ObjectInnerContainer.hide()
        else:
            # self.ui.buttonFold.setText( '-' )
            self.ui.buttonFold.setIcon(getIcon('node_unfolded'))
            self.ui.ObjectInnerContainer.show()
        if notify:
            self.foldChanged.emit(self.folded)

    def setTitle(self, title):
        self.ui.buttonName.setText(title)

    def openContextMenu(self):
        if self.contextMenu:
            self.contextMenu.popUp(context=self.contextObject)


##----------------------------------------------------------------##
_OBJECT_EDITOR_CACHE = {}


def pushObjectEditorToCache(typeId, editor):
    pool = _OBJECT_EDITOR_CACHE.get(typeId, None)
    if not pool:
        pool = []
        _OBJECT_EDITOR_CACHE[typeId] = pool
    editor.container.setUpdatesEnabled(False)
    pool.append(editor)
    return True


def popObjectEditorFromCache(typeId):
    pool = _OBJECT_EDITOR_CACHE.get(typeId, None)
    if pool:
        editor = pool.pop()
        if editor:
            editor.container.setUpdatesEnabled(True)
        return editor


def clearObjectEditorCache(typeId):
    if _OBJECT_EDITOR_CACHE.has_key(typeId):
        del _OBJECT_EDITOR_CACHE[typeId]


##----------------------------------------------------------------##
class ObjectEditor(object):
    def __init__(self):
        self.parentIntrospector = None

    def getContainer(self):
        return self.container

    def getInnerContainer(self):
        return self.container.ObjectInnerContainer()

    def getIntrospector(self):
        return self.parentIntrospector

    def initWidget(self, container, objectContainer):
        pass

    def getContextMenu(self):
        pass

    def setTarget(self, target):
        self.target = target

    def getTarget(self):
        return self.target

    def unload(self):
        pass

    def needCache(self):
        return True

    def setFocus(self):
        pass


##----------------------------------------------------------------##
class CommonObjectEditor(ObjectEditor):  # a generic property grid
    def initWidget(self, container, objectContainer):
        self.grid = PropertyEditor(container)
        self.grid.propertyChanged.connect(self.onPropertyChanged)
        return self.grid

    def setTarget(self, target):
        self.target = target
        self.grid.setTarget(target)

    def refresh(self):
        self.grid.refreshAll()

    def unload(self):
        self.grid.clear()
        self.target = None

    def onPropertyChanged(self, obj, id, value):
        pass


##----------------------------------------------------------------##
def registerObjectEditor(typeId, editorClas):
    app.getModule('detail_panel').registerObjectEditor(typeId, editorClas)


##----------------------------------------------------------------##
class DetailInstance(object):
    def __init__(self, id):
        self.id = id

        self.target = None
        self.container = None
        self.body = None
        self.editors = []

    def createWidget(self, container):
        self.container = container
        self.header = container.addWidgetFromFile(
            app.getPath('sceneEditor/DetailPanel.ui'),
            expanding=False)
        self.scroll = scroll = container.addWidget(QtGui.QScrollArea(container))
        self.body = body = QtGui.QWidget(container)
        self.header.hide()
        self.scroll.verticalScrollBar().setStyleSheet('width:4px')
        scroll.setWidgetResizable(True)
        body.mainLayout = layout = QtGui.QVBoxLayout(body)
        layout.setSpacing(0)
        layout.setMargin(0)
        layout.addStretch()
        scroll.setWidget(body)

        self.updateTimer = self.container.startTimer(10, self.onUpdateTimer)
        self.updatePending = False

    def getTarget(self):
        return self.target

    def setTarget(self, t, forceRefresh=False):
        if self.target == t and not forceRefresh: return

        if self.target:
            self.clear()

        if not t:
            self.target = None
            return

        if len(t) > 1:
            self.header.textInfo.setText('Multiple object selected...')
            self.header.buttonApply.hide()
            self.header.show()
            self.target = t[0]  # TODO: use a multiple selection proxy as target
        else:
            self.target = t[0]

        self.addObjectEditor(self.target)

    def hasTarget(self, target):
        if self.getObjectEditor(target): return True
        return False

    def focusTarget(self, target):
        editor = self.getObjectEditor(target)
        if not editor: return
        # scroll to editor
        editorContainer = editor.getContainer()
        y = editorContainer.y()
        # h = editorContainer.height()
        # y1 = y + h
        scrollBar = self.scroll.verticalScrollBar()
        # containerH = self.container.height()
        # scrollY = max( containerH - h )
        scrollBar.setValue(y)
        editor.setFocus()

    def getObjectEditor(self, targetObject):
        for editor in self.editors:
            if editor.getTarget() == targetObject: return editor
        return None

    def addWidget(self, widget, **option):
        self.scroll.hide()
        widget.setParent(self.body)
        count = self.body.mainLayout.count()
        self.body.mainLayout.insertWidget(count - 1, widget)
        self.scroll.show()

    def addObjectEditor(self, target, **option):
        self.scroll.hide()
        parent = app.getModule('detail_panel')
        typeId = ModelManager.get().getTypeId(target)
        if not typeId:
            self.scroll.show()
            return

        # create or use cached editor
        cachedEditor = popObjectEditorFromCache(typeId)
        if cachedEditor:
            editor = cachedEditor
            container = editor.container
            count = self.body.mainLayout.count()
            assert count > 0
            self.body.mainLayout.insertWidget(count - 1, container)
            container.show()
            container.setContextObject(target)
            self.editors.append(editor)

        else:
            defaultEditorClas = option.get('editor_class', None)
            editorClas = parent.getObjectEditorByTypeId(typeId, defaultEditorClas)

            editor = editorClas()
            editor.targetTypeId = typeId
            self.editors.append(editor)
            container = ObjectContainer(self.body)
            editor.container = container
            widget = editor.initWidget(container.getInnerContainer(), container)
            container.setContextObject(target)
            if widget:
                if isinstance(widget, list):
                    for w in widget:
                        container.addWidget(w)
                else:
                    container.addWidget(widget)

                model = ModelManager.get().getModelFromTypeId(typeId)
                if model:
                    container.setTitle(model.getShortName())
                else:
                    container.setTitle(repr(typeId))
                # ERROR
                count = self.body.mainLayout.count()
                assert count > 0
                self.body.mainLayout.insertWidget(count - 1, container)
                menuName = option.get('context_menu', editor.getContextMenu())
                container.setContextMenu(menuName)
                container.ownerEditor = editor

            else:
                container.hide()

        editor.parentIntrospector = self
        editor.setTarget(target)
        size = self.body.sizeHint()
        size.setWidth(self.scroll.width())
        self.body.resize(size)
        self.scroll.show()
        return editor

    def clear(self):
        for editor in self.editors:
            editor.container.setContextObject(None)
            cached = False
            if editor.needCache():
                cached = pushObjectEditorToCache(editor.targetTypeId, editor)
            if not cached:
                editor.unload()
            editor.target = None

        # remove containers
        layout = self.body.mainLayout
        for count in reversed(range(layout.count())):
            child = layout.takeAt(count)
            w = child.widget()
            if w:
                w.setParent(None)
        layout.addStretch()

        self.target = None
        self.header.hide()
        self.editors = []

    def refresh(self, target=None):
        for editor in self.editors:
            if not target or editor.getTarget() == target:
                editor.refresh()

    def onUpdateTimer(self):
        if self.updatePending == True:
            self.updatePending = False
            self.refresh()

    def scheduleUpdate(self):
        self.updatePending = True


##----------------------------------------------------------------##
class SceneDetailPanel(SceneEditorModule):
    """docstring for SceneIntrospector"""

    def __init__(self):
        super(SceneDetailPanel, self).__init__()
        self.instances = []
        self.instanceCache = []
        self.idPool = IDPool()
        self.activeInstance = None
        self.objectEditorRegistry = {}

    def getName(self):
        return 'detail_panel'

    def getDependency(self):
        return ['qt', 'scene_editor']

    def onLoad(self):
        self.window = self.requestDockWindow('Detail', title='Detail', dock='right', minSize=(200, 100))
        self.actorPreviewWidget = self.window.addWidget(uic.loadUi(app.getPath('sceneEditor/Detail_ActorPreviewWidget.ui')))
        self.actorPreviewTree = self.actorPreviewWidget.container.addWidget(ActorComponentTreeWidget(
            self.actorPreviewWidget,
            multiple_selection=False,
            sorting=False,
            editable=False,
            # no_header=True
        ))
        self.actorPreviewWidget.hide()

        self.requestInstance()
        signals.connect('selection.changed', self.onSelectionChanged)
        signals.connect('component.added', self.onComponentAdded)
        signals.connect('component.removed', self.onComponentRemoved)
        signals.connect('actor.modified', self.onActorModified)
        self.widgetCacheHolder = QtGui.QWidget()

    def onStart(self):
        pass

    def updateProp(self):
        if app.isDebugging():
            return

        if self.activeInstance:
            self.activeInstance.refresh()

    def requestInstance(self):
        # todo: pool
        id = self.idPool.request()
        # container = self.requestDockWindow('Detail-%d' % id,
        #                                    title='Detail',
        #                                    dock='right',
        #                                    minSize=(200, 100)
        #                                    )
        instance = DetailInstance(id)
        # instance.createWidget(self.container)
        instance.createWidget(self.window)
        self.instances.append(instance)
        if not self.activeInstance: self.activeInstance = instance
        return instance

    def findInstances(self, target):
        res = []
        for ins in self.instances:
            if ins.target == target:
                res.append(ins)
        return res

    def getInstances(self):
        return self.instances

    def registerObjectEditor(self, typeId, editorClas):
        assert typeId, 'null typeid'
        self.objectEditorRegistry[typeId] = editorClas

    def getObjectEditorByTypeId(self, typeId, defaultClass=None):
        while True:
            clas = self.objectEditorRegistry.get(typeId, None)
            if clas: return clas
            typeId = getSuperType(typeId)
            if not typeId: break
        if defaultClass: return defaultClass
        return CommonObjectEditor

    def onSelectionChanged(self, selection, key):
        if key != 'scene':
            self.actorPreviewWidget.setWindowOpacity(0)
            # self.actorPreviewWidget.hide()
            return
        if not self.activeInstance: return
        target = None
        if isinstance(selection, list):
            target = selection
        elif isinstance(selection, tuple):
            target = selection
        else:
            target = selection

        print ('onSelectionChanged()', target)

        print('getClass()', _CANDY.isClassInstance(target))

        if isCandySubInstance(target, 'Actor'):
            print ('onSelectionChanged() isCandySubInstance: Actor')
            self.actorPreviewWidget.actorName.setText(target.name)
            self.actorPreviewWidget.actorIcon.setIcon(getIcon('obj'))
            self.actorPreviewTree.clear()
            self.actorPreviewTree.addNode(target)

        self.actorPreviewWidget.setWindowOpacity(1)
        self.actorPreviewWidget.show()

        # first selection only?
        self.activeInstance.setTarget(target)

    def onComponentAdded(self, com, actor):
        if not self.activeInstance: return
        if self.activeInstance.target == actor:
            self.activeInstance.setTarget([actor], True)
            self.activeInstance.focusTarget(com)

    def onComponentRemoved(self, com, entity):
        if not self.activeInstance: return
        if self.activeInstance.target == entity:
            self.activeInstance.setTarget([entity], True)

    def onActorModified(self, entity, context=None):
        if context != 'detail_panel':
            self.refresh(entity, context)

    def refresh(self, target=None, context=None):
        for ins in self.instances:
            if not target or ins.hasTarget(target):
                ins.scheduleUpdate()


##----------------------------------------------------------------##
SceneDetailPanel().register()


##----------------------------------------------------------------##
class ActorComponentTreeWidget(GenericTreeWidget):
    def getHeaderInfo(self):
        return [('Actor Structure', -1)]
        # return None

    def getRootNode(self):
        # selection = getSelection('scene')
        # if type(selection) == list:
        #     return selection[0]
        # return selection
        return _CANDY.game

    def getNodeChildren(self, node):
        # Actor
        if isCandySubInstance(node, 'Actor'):
            result = []
            for com in node.components.values():
                if com.FLAG_INTERNAL: continue
                result.append(com)
            return reversed(result)
        # ActorComponent
        if isCandySubInstance(node, 'ActorComponent'):
            result = []
            for com in node.children.values():
                if com.FLAG_INTERNAL: continue
                result.append(com)
            return reversed(result)
        return []

    def getNodeParent(self, node):
        # Actor
        if isCandySubInstance(node, 'Actor'):
            return None
        # ActorComponent
        if isCandySubInstance(node, 'ActorComponent'):
            if node.parent != None:
                return node
            else: return node._actor
        return None

    def updateItemContent(self, item, node, **option):
        if isCandySubInstance(node, 'Actor'):
            item.setText(0, node.name)
            item.setIcon(0, getIcon('obj'))
        if isCandySubInstance(node, 'ActorComponent'):
            if node.name:
                item.setText(0, node.name)
            else:
                item.setText(0, node.__class.__name)
            item.setIcon(0, getIcon('component'))

    def onItemSelectionChanged(self):
        selections = self.getSelection()

    def onClicked(self, item, col):
        if col == 1:  # editor view toggle
            node = self.getNodeByItem(item)
            if isCandyInstance(node, 'Actor'):
                # TODO: show Actor attribute
                pass
            if isCandyInstance(node, 'ActorComponent'):
                # TODO: show Component attribute
                pass
