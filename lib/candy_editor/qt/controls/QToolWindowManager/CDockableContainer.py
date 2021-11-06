from PyQt5.QtCore import QRect, QMetaObject, qrand, QEvent
from PyQt5.QtGui import QPainter
from PyQt5.QtWidgets import QWidget, QVBoxLayout, QSizePolicy, QStyleOption, QStyle

from .QToolWindowManager import QToolWindowAreaReference, QToolWindowManager
from .QToolWindowManagerCommon import *
from .QTrackingTooltip import QTrackingTooltip

s_dockingFactory = None  # QToolWindowManagerClassFactory / CToolWindowManagerClassFactory


class FactoryInfo:
	def __init__ ( self, factory, isUnique, isInternal ):
		self.factory = factory
		self.isUnique = isUnique
		self.isInternal = isInternal


class WidgetInstance:
	def __init__ ( self, widget, spawnName ):
		self.widget = widget
		self.spawnName = spawnName


class CDockableContainer ( QWidget ):

	def __init__ ( self, parent, startingLayout ):
		super ().__init__ ( parent )
		self.owner = parent
		self.startingLayout = startingLayout
		self.toolManager = None
		self.defaultLayoutCallback = None
		self.menu = None
		self.registry = {}
		self.spawned = {}
		self.layoutChangedConnection = QMetaObject.Connection ()
		self.owner = None
		parent.installEventFilter ( self )

	def __del__ ( self ):
		if self.toolManager:
			self.disconnect ( self.layoutChangedConnection )
		for pair in self.spawned:
			self.disconnect ( pair.second.widget, 0, self, 0 )
		self.spawned.clear ()

	def register ( self, name, factory, isUnique, isInternal ):
		self.registry[ name ] = FactoryInfo ( factory, isUnique, isInternal )

	def getState ( self ):
		result = {}
		if self.toolManager:
			stateMap = {}
			for sw in self.spawned:
				w = sw.second
				if self.toolManager.areaOf ( w.widget ):
					toolData = {}
					toolData[ "class" ] = w.spawnName
					if w.widget:
						toolData[ "state" ] = w.widget.getState ()
					stateMap[ w.widget.objectName () ] = toolData
			result[ "Windows" ] = stateMap
			result[ "ToolsLayout" ] = self.toolManager.saveState ()
		return result

	def setState ( self, state ):
		if not self.toolManager:
			self.startingLayout = state
			return
		lock = self.toolManager.getNotifyLock ( False )
		self.toolManager.hide ()
		self.toolManager.clear ()
		self.spawned.clear ()
		openToolsMap = state[ "Windows" ]
		for key, v in openToolsMap.items ():
			className = v[ "class" ]
			toolState = v[ "state" ] or { }

			w = self.spawnWidget ( className, key )
			if w:
				if toolState and w:
					w.setState ( toolState )

		self.toolManager.restoreState ( state[ "ToolsLayout" ] )
		self.buildWindowMenu ()
		self.toolManager.show ()
		self.startingLayout = {}

	def getPanes ( self ):
		panes = []
		for it in self.spawned:
			pane = self.spawned[ it ].second.widget  # TODO: IPane
			if pane:
				panes.append ( pane )
		return panes

	def spawnWidgetTarget ( self, name, target ):
		return self.spawnWidgetInternalTarget ( name, "", target )

	def spawnWidgetTargetWidget ( self, name, targetWidget, target ):
		toolArea = self.toolManager.areaOf ( targetWidget )
		if toolArea:
			return self.spawnWidgetInternal ( name, "", toolArea, target.reference, target.index, target.geometry )
		return None

	def spawnWidget ( self, name, area, reference, index, geometry ):
		return self.spawnWidgetInternal ( name, "", area, reference, index, geometry )

	def setDefaultLayoutCallback ( self, callback ):
		self.defaultLayoutCallback = callback

	def setMenu ( self, abstractMenu ):
		self.menu = abstractMenu

	def setSplitterSizes ( self, widget, sizes ):
		self.toolManager.resizeSplitter ( widget, sizes )

	def onLayorutChange ( self, layout ):
		pass

	def showEvent ( self, e ):
		if self.toolManager:
			return
		config = {}  # TODO: CEditorDialog.config
		config[ QTWM_RELEASE_POLICY ] = QTWMReleaseCachingPolicy.rcpDelete
		self.toolManager = QToolWindowManager ( self, config, s_dockingFactory )
		self.toolManager.updateTrackingTooltip.connect (
			lambda str, p: QTrackingTooltip.showTextTooltip ( str, p ) )
		self.setLayout ( QVBoxLayout () )
		self.layout ().setContentsMargins ( 0, 0, 0, 0 )
		self.setSizePolicy ( QSizePolicy.Expanding, QSizePolicy.Expanding )
		self.layout ().addWidget ( self.toolManager )
		if not self.startingLayout:
			self.setState ( self.startingLayout )
		else:
			self.defaultLayoutCallback ( self )

		def onLayoutChanged ():
			self.getState ()
			self.buildWindowMenu ()

		self.layoutChangedConnection = self.toolManager.layoutChanged.connect ( onLayoutChanged )
		self.buildWindowMenu ()

	def paintEvent ( self, e ):
		styleOption = QStyleOption ()
		styleOption.initFrom ( self )
		painter = QPainter ( self )
		self.style ().drawPrimitive ( QStyle.PE_Widget, styleOption, painter, self )

	def eventFilter ( self, o, e ):
		if e.type () != QEvent.Close or o != self.owner:
			return False
		o.event ( e )
		if e.isAccepted ():
			self.closeSpawnedWidgets ()
		return True

	def spawnWidgetInternalTarget ( self, name, objectName, target ):
		return self.spawnWidgetInternal ( name, objectName, target.area, target.reference, target.index,
		                                  target.geometry )

	def spawnWidgetInternal ( self, name, forceObjectName, area, reference = QToolWindowAreaReference.Combine,
	                          index = -1, geometry = QRect () ):
		w = self.spawn ( name, forceObjectName )
		if w:
			if not self.toolManager.ownsToolWindow ( w ):
				self.toolManager.addToolWindow ( w, area, reference, index, geometry )
			self.toolManager.bringToFront ( w )
		return w

	def spawn ( self, name, forceObjectName ):
		it = self.registry[ name ]
		if it:
			if it.second.isUnique:
				for wi in self.spawned:
					if wi.second.spawnName == name:
						return wi.second.widget
			widget = it.second.factory ()
			if not forceObjectName:
				widget.setObjectName ( self.createObjectName ( name ) )
			else:
				widget.setObjectName ( forceObjectName )
			self.spawned[ widget.objectName () ] = WidgetInstance ( widget, name )
			widget.destroyed.connect ( self.onWidgetDestroyed )

	def closeSpawnedWidgets ( self ):
		for it in self.spawned:
			it.second.widget.close ()

	def onWidgetDestroyed ( self, o ):
		it = self.spawned[ o.objectName () ]
		if it and it.second.widget == o:
			del self.spawned[ o.objectName () ]
			self.buildWindowMenu ()

	def createObjectName ( self, title ):
		result = title
		while result in self.spawned:
			i = qrand ()
			result = "%s#%d" % (title, i)
		return result

	def buildWindowMenu ( self ):
		if not self.menu:
			return
		self.menu.clear ()
		addMenu = None  # TODO: CAbstractMenu
		for it in self.registry:
			if it.second.isInternal:
				continue
			if not addMenu:
				addMenu = self.menu.CreateMenu ( "&Panels" )

			s = it.first
			action = addMenu.CreateAction ( s )
			action.triggered.connect ( lambda: self.spawnWidget ( s ) )

		action = self.menu.CreateAction ( "&Reset layout" )
		action.triggered.connect ( self.resetLayout )

	def resetLayout ( self ):
		lock = self.toolManager.getNotifyLock ()
		self.toolManager.hide ()
		self.toolManager.clear ()
		self.spawned.clear ()
		self.defaultLayoutCallback ( self )
		self.toolManager.show ()
