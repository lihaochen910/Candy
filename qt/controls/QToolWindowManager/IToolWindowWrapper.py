from abc import ABCMeta, abstractmethod


class IToolWindowWrapper ():
	__metaclass__ = ABCMeta

	@abstractmethod
	def getWidget ( self ):
		pass

	@abstractmethod
	def getContents ( self ):
		pass

	@abstractmethod
	def setContents ( self, widget ):
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
