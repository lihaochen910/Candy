from abc import ABCMeta, abstractmethod

from PyQt5.QtCore import qWarning

from .IToolWindowWrapper import IToolWindowWrapper
from .QToolWindowManagerCommon import findClosestParent


class IToolWindowArea:
	__metaclass__ = ABCMeta

	@abstractmethod
	def addToolWindow ( self, toolWindow, index = -1 ):
		qWarning ( "[IToolWindowArea] @abstractmethod: addToolWindow called." )
		pass

	@abstractmethod
	def addToolWindows ( self, toolWindows, index = -1 ):
		qWarning ( "[IToolWindowArea] @abstractmethod: addToolWindows called." )
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
		qWarning ( "[IToolWindowArea] @abstractmethod: adjustDragVisuals called." )
		pass

	@abstractmethod
	def getWidget ( self ):
		qWarning ( "[IToolWindowArea] @abstractmethod: getWidget called." )
		pass

	def wrapper ( self ):
		qWarning ( "[IToolWindowArea] @abstractmethod: wrapper called." )
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
