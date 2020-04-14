from abc import ABCMeta, abstractmethod

from qt.controls.QToolWindowManager.IToolWindowWrapper import IToolWindowWrapper
from qt.controls.QToolWindowManager.QToolWindowManagerCommon import findClosestParent


class IToolWindowArea ():
	__metaclass__ = ABCMeta

	@abstractmethod
	def addToolWindow ( self, toolWindow, index = -1 ):
		pass

	@abstractmethod
	def addToolWindows ( self, toolWindows, index = -1 ):
		pass

	@abstractmethod
	def removeToolWindow ( self, toolWindows ):
		pass

	@abstractmethod
	def saveState ( self ):
		pass

	@abstractmethod
	def restoreState ( self, data, stateFormat ):
		pass

	@abstractmethod
	def adjustDragVisuals ( self ):
		pass

	@abstractmethod
	def getWidget ( self ):
		return self

	def wrapper( self ):
		return findClosestParent ( self.getWidget (), IToolWindowWrapper )

	@abstractmethod
	def switchAutoHide ( self, newValue ):
		pass

	@abstractmethod
	def palette ( self ):
		pass

	@abstractmethod
	def clear ( self ):
		pass

	@abstractmethod
	def rect ( self ):
		pass

	@abstractmethod
	def size ( self ):
		pass

	@abstractmethod
	def count ( self ):
		pass

	@abstractmethod
	def widget ( self, index ):
		pass

	@abstractmethod
	def deleteLater ( self, index ):
		pass

	@abstractmethod
	def width ( self ):
		pass

	@abstractmethod
	def height ( self ):
		pass

	@abstractmethod
	def geometry ( self ):
		pass

	@abstractmethod
	def hide ( self ):
		pass

	@abstractmethod
	def parent ( self ):
		pass

	@abstractmethod
	def setParent ( self, parent ):
		pass

	@abstractmethod
	def indexOf ( self, w ):
		pass

	@abstractmethod
	def parentWidget ( self ):
		pass

	@abstractmethod
	def mapFromGlobal ( self, pos ):
		pass

	@abstractmethod
	def mapToGlobal ( self, pos ):
		pass

	@abstractmethod
	def setCurrentWidget ( self, w ):
		pass

	@abstractmethod
	def mapCombineDropAreaFromGlobal ( self, pos ):
		pass

	@abstractmethod
	def combineAreaRect ( self ):
		pass

	@abstractmethod
	def combineSubWidgetRect ( self, index ):
		pass

	@abstractmethod
	def subWidgetAt ( self, pos ):
		pass

	@abstractmethod
	def areaType ( self ):
		pass
