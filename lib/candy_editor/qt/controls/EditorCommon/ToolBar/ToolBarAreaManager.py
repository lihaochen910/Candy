from enum import IntEnum

from PyQt5.QtCore import Qt, qWarning

from ..IEditor import getIEditor
from .ToolBarArea import CToolBarArea
from .ToolBarAreaItem import CSpacerType


class CToolBarAreaManagerArea ( IntEnum ):
	Default = 0
	Top = 0
	Bottom = 1
	Left = 2
	Right = 3


class CToolBarAreaManager:

	def __init__ ( self, editor ):
		self.editor = editor
		self.defaultArea = None
		self.focusedArea = None
		self.toolBarAreas = []
		self.areaCount = self.indexForArea ( CToolBarAreaManagerArea.Right ) + 1
		self.isLocked = False
		self.editor.signalAdaptiveLayoutChanged.connect ( self.onAdaptiveLayoutChanged )

	def initialize ( self ):
		self.createAreas ()
		self.createMenu ()
		self.loadToolBars ()

	def toggleLock ( self ):
		self.setLocked ( not self.isLocked )
		return True

	def setLocked ( self, isLocked ):
		if self.isLocked == isLocked:
			return
		self.isLocked = isLocked
		for toolBarArea in self.toolBarAreas:
			toolBarArea.setLocked ( self.isLocked )

	def addExpandingSpacer ( self ):
		self.defaultArea.addSpacer ( CSpacerType.Expanding )
		return True

	def addFixedSpacer ( self ):
		self.defaultArea.addSpacer ( CSpacerType.Fixed )
		return True

	def getWidget ( self, area ):
		return self.toolBarAreas[ self.indexForArea ( area ) ]

	def getAreaFor ( self, toolBarArea ):
		for i in range ( len ( self.toolBarAreas ) ):
			if toolBarArea == self.toolBarAreas[ i ]:
				return self.areaForIndex ( i )
		return CToolBarAreaManagerArea.Default

	def getState ( self ):
		# TODO: IStateSerializable.getState
		pass

	def setState ( self, state ):
		# TODO: IStateSerializable.setState
		pass

	def onAdaptiveLayoutChanged ( self, orientation ):
		# TODO: IStateSerializable.onAdaptiveLayoutChanged
		if len ( self.toolBarAreas ) == 0:
			return

		for i in self.areaCount:
			self.toolBarAreas[ i ].setOrientation ( self.getOrientation ( self.areaForIndex ( i ) ) )

	def onNewToolBar ( self, toolBar ):
		self.getFocusedArea ().addToolBar ( toolBar )

	def onToolBarModified ( self, toolBar ):
		toolBarName = toolBar.objectName ()
		toolBarItem = self.findToolBarByName ( toolBarName )
		if not toolBarItem:
			print ( "Toolbar Modified: Failed to find tool bar: %s" % toolBarName )
		toolBarItem.replaceToolBar ( toolBar )

	def onToolBarRenamed ( self, szOldObjectName, toolBar ):
		toolBarItem = self.findToolBarByName ( szOldObjectName )
		if not toolBarItem:
			print ( "Toolbar Renamed: Failed to find tool bar: %s" % szOldObjectName )
		toolBarItem.replaceToolBar ( toolBar )

	def onToolBarDeleted ( self, szOldObjectName ):
		toolBarName = szOldObjectName
		areaForToolBar = None
		toolBarItem = None

		for area in self.toolBarAreas:
			toolBarItem = area.findToolBarByName ( toolBarName )
			if toolBarItem:
				areaForToolBar = area
				break

		if not areaForToolBar:
			print ( "Toolbar Modified: Failed to find tool bar: %s" % toolBarName )

		areaForToolBar.deleteToolBar ( toolBarItem )

	def getFocusedArea ( self ):
		if self.focusedArea:
			return self.focusedArea
		return self.defaultArea

	def findToolBarByName ( self, szToolBarObjectName ):
		toolBarItem = None
		for area in self.toolBarAreas:
			toolBarItem = area.findToolBarByName ( szToolBarObjectName )
			if toolBarItem:
				break
		return toolBarItem

	def showContextMenu ( self ):
		# TODO: CAbstractMenu
		pass

	def fillMenu ( self, menu ):
		self.fillMenuForArea ( menu, None )

	def fillMenuForArea ( self, menu, currentArea ):
		pass

	def createAreas ( self ):
		if len ( self.toolBarAreas ) >= self.areaCount:
			qWarning ( "Areas have been already created, cannot create more" )
			return

		for i in range ( self.areaCount ):
			area = self.areaForIndex ( i )
			toolBarArea = CToolBarArea ( self.editor, self.getOrientation ( area ) )
			def onCustomContextMenuRequested ():
				toolBarArea.setFocus ()
				self.focusedArea = toolBarArea
				self.showContextMenu ()
				self.focusedArea = None
			toolBarArea.customContextMenuRequested.connect ( onCustomContextMenuRequested )
			self.toolBarAreas.append ( toolBarArea )
			toolBarArea.signalDragStart.connect ( self.onDragStart )
			toolBarArea.signalDragEnd.connect ( self.onDragEnd )
			toolBarArea.signalItemDropped.connect ( self.moveToolBarToArea )

		self.defaultArea = self.getWidget ( CToolBarAreaManagerArea.Default )

	def loadToolBars ( self ):
		toolBars = getIEditor ().getToolBarService ().loadToolBars ( self.editor )
		# TODO: loadToolBars
		# for toolBar in toolBars:
		# 	self.defaultArea.addToolBar ( toolBar )

	def createMenu ( self ):
		pass

	def moveToolBarToArea ( self, areaItem, destinationArea, targetIndex = -1 ):
		area = areaItem.getArea ()
		area.removeItem ( areaItem )
		destinationArea.addItem ( areaItem, targetIndex )

	def setDragAndDropMode ( self, isEnabled ):
		for toolBarArea in self.toolBarAreas:
			toolBarArea.setProperty ( "dragAndDropMode", isEnabled )
			toolBarArea.style ().unpolish ( toolBarArea )
			toolBarArea.style ().polish ( toolBarArea )

	def onDragStart ( self ):
		self.setDragAndDropMode ( True )

	def onDragEnd ( self ):
		self.setDragAndDropMode ( False )

	def getOrientation ( self, area ):
		isDefaultOrientation = self.editor.getOrientation () == self.editor.getDefaultOrientation ()
		if area == CToolBarAreaManagerArea.Top or area == CToolBarAreaManagerArea.Bottom:
			return Qt.Horizontal if isDefaultOrientation else Qt.Vertical
		if area == CToolBarAreaManagerArea.Left or area == CToolBarAreaManagerArea.Right:
			return Qt.Vertical if isDefaultOrientation else Qt.Horizontal

		print ( "Requesting orientation for unknown tool bar area" )
		return Qt.Horizontal

	def indexForArea ( self, area ):
		""" Summary.

			Args:
				area (CToolBarAreaManagerArea): area

			Returns:
				int
	    """
		return area

	def areaForIndex ( self, index ):
		""" Summary.

			Args:
				index (int): index

			Returns:
				CToolBarAreaManagerArea
	    """
		return index
