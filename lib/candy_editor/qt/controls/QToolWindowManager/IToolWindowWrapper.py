from abc import ABCMeta, abstractmethod

from PyQt5.QtCore import qWarning


class IToolWindowWrapper:
	__metaclass__ = ABCMeta

	@abstractmethod
	def getWidget ( self ):
		qWarning ( "[IToolWindowWrapper] @abstractmethod: getWidget called." )
		pass

	@abstractmethod
	def getContents ( self ):
		qWarning ( "[IToolWindowWrapper] @abstractmethod: getContents called." )
		pass

	@abstractmethod
	def setContents ( self, widget ):
		qWarning ( "[IToolWindowWrapper] @abstractmethod: setContents called." )
		pass

	@abstractmethod
	def startDrag ( self ):
		pass

	@abstractmethod
	def hide ( self ):
		pass

	@abstractmethod
	def deferDeletion ( self ):
		pass

	@abstractmethod
	def setParent ( self, newParent ):
		pass
