from enum import Enum
from abc import ABCMeta, abstractmethod


class ESystemClassID ( Enum ):
	ESYSTEM_CLASS_OBJECT = 0x0001
	ESYSTEM_CLASS_EDITTOOL = 0x0002
	ESYSTEM_CLASS_PREFERENCE_PAGE = 0x0020
	ESYSTEM_CLASS_VIEWPANE = 0x0021
	# Source/Asset Control Management Provider
	ESYSTEM_CLASS_SCM_PROVIDER = 0x0022
	ESYSTEM_CLASS_ASSET_TYPE = 0x0023
	ESYSTEM_CLASS_ASSET_IMPORTER = 0x0024
	ESYSTEM_CLASS_ASSET_COVERTER = 0x0025
	ESYSTEM_CLASS_VCS_PROVIDER = 0x0026
	ESYSTEM_CLASS_UITOOLS = 0x0050 # Still used by UI Emulator
	ESYSTEM_CLASS_USER = 0x1000


#! This interface describes a class created by a plugin
class IClassDesc:
	__metaclass__ = ABCMeta

	@abstractmethod
	def systemClassID ( self ):
		pass

	@abstractmethod
	def className ( self ):
		pass

	def uiName ( self ):
		return self.className ()

	def generateObjectName ( self, szCreationParams ):
		return self.className ()

	def createObject ( self ):
		return None

	def category ( self ):
		return None

	def getRuntimeClass ( self ):
		return None


class IEditorClassFactory:
	__metaclass__ = ABCMeta

	@abstractmethod
	def registerClass ( self, classDesc ):
		pass

	@abstractmethod
	def unregisterClass ( self, classDesc ):
		pass

	@abstractmethod
	def findClass ( self, className ):
		pass

	@abstractmethod
	def getClassesBySystemID ( self, systemClassID, rOutClasses ):
		pass

	@abstractmethod
	def getClassesByCategory ( self, category, rOutClasses ):
		pass
