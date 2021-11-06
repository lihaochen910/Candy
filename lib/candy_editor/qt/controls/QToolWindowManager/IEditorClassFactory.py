from enum import IntEnum
from abc import ABCMeta, abstractmethod


class ESystemClassID ( IntEnum ):
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
	ESYSTEM_CLASS_UITOOLS = 0x0050  # Still used by UI Emulator
	ESYSTEM_CLASS_USER = 0x1000


class IClassDesc:
	""" This interface describes a class created by a plugin.
    """
	__metaclass__ = ABCMeta

	@abstractmethod
	def systemClassID ( self ) -> int:
		""" This method returns an Editor defined GUID describing the class this plugin class is associated with.

			Returns:
				ESystemClassID
	    """
		pass

	@abstractmethod
	def className ( self ) -> str:
		""" This method returns the human readable name of the class.

			Returns:
				str
	    """
		return 'IClassDesc'

	def uiName ( self ) -> str:
		""" This method returns the UI name of the class.

			Returns:
				str
	    """
		return self.className ()

	def generateObjectName ( self, szCreationParams ) -> str:
		""" This method is used to determine a name for an object of this class.

			Args:
				szCreationParams: str representing object creation params

			Returns:
				str
	    """
		return self.className ()

	def createObject ( self ):
		""" Creates the object associated with the description. Default implementation returns nullptr as this may not be used by all class types.

			Returns:
				Any
	    """
		return None

	def category ( self ) -> str:
		""" This method returns Category of this class, Category is specifying where this plugin class fits best in create panel.

			Returns:
				str
	    """
		return ''

	def getRuntimeClass ( self ):
		""" Get MFC runtime class of the object, created by this ClassDesc.

			Returns:
				CRuntimeClass
	    """
		return None


class IClassDescImpl ( IClassDesc ):

	def __init__ ( self, class_, name, category, unique = False, menuPath = "" ):
		self.class_ = class_
		self.name = name
		self.category_ = category
		self.unique = unique
		self.menuPath = menuPath

	def className ( self ):
		return self.name

	def uiName ( self ):
		return self.name

	def generateObjectName ( self, szCreationParams ):
		return self.name + ' (clone)'

	def createObject ( self ):
		return self.class_ ()

	def category ( self ):
		return self.category_

	def getRuntimeClass ( self ):
		return self.class_


class IEditorClassFactory:
	__metaclass__ = ABCMeta

	@abstractmethod
	def registerClass ( self, classDesc ):
		""" Register new class to the factory.

			Args:
				classDesc: IClassDesc

			Returns:
				None
	    """
		pass

	@abstractmethod
	def unregisterClass ( self, classDesc ):
		""" Unregister the class from the factory.

			Args:
				classDesc: IClassDesc

			Returns:
				None
	    """
		pass

	@abstractmethod
	def findClass ( self, className ):
		""" Find class in the factory by class name.

			Args:
				className: str

			Returns:
				IClassDesc
	    """
		pass

	@abstractmethod
	def getClassesBySystemID ( self, systemClassID ):
		""" Get classes that matching specific requirements.

			Args:
				systemClassID: ESystemClassID

			Returns:
				list
	    """
		pass

	@abstractmethod
	def getClassesByCategory ( self, category ):
		""" Get classes that matching specific requirements.

			Args:
				systemClassID: str

			Returns:
				list
	    """
		pass


class CClassFactory ( IEditorClassFactory ):
	_instance = None

	def __init__ ( self ):
		CClassFactory._instance = self
		self.classes = {}

	@staticmethod
	def get ():
		return CClassFactory._instance

	def registerClass ( self, classDesc: IClassDesc ):
		assert classDesc
		self.classes[ classDesc.className () ] = classDesc

	def unregisterClass ( self, classDesc: IClassDesc ):
		if classDesc == None:
			return
		self.classes[ classDesc.className () ] = None

	def findClass ( self, className: str ) -> IClassDesc:
		classDesc = self.classes.setdefault ( className, None )
		if classDesc != None:
			return classDesc

		# TODO: find in subClass
		# const char * pSubClassName = strstr ( pClassName, "::" );
		#
		# if (!pSubClassName)
		# {
		# 	return NULL;
		# }
		#
		# string name;
		#
		# name.Append ( pClassName, pSubClassName - pClassName );
		#
		# return stl::find_in_map ( m_nameToClass, name, (IClassDesc *)nullptr);
