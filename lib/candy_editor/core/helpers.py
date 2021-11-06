import traceback


def printTraceBack ():
	traceback.print_stack ()


def generateGUID ():
	import uuid
	return uuid.uuid1 ().hex


def isPythonFrozen ():
	import sys
	return hasattr ( sys, "frozen" )


def getModulePath ( path, srcFile ):
	import os.path
	return os.path.dirname ( srcFile ) + '/' + path


def _getMainModulePath ():
	import sys, os, platform
	import os.path

	if isPythonFrozen ():
		p = os.path.dirname ( sys.executable )
		if platform.system () == u'Darwin':
			return os.path.realpath ( p + '/../../..' )
		elif platform.system () == u'Windows':
			return p
		else:
			return p

	if __name__ == 'main':
		mainfile = os.path.realpath ( __file__ )
		return os.path.dirname ( mainfile )
	else:
		import __main__
		if hasattr ( __main__, "__candy_path__" ):
			return __main__.__candy_path__
		# elif hasattr ( __main__, "candyEditorPath" ):
		# 	return __main__.candyEditorPath
		else:
			mainfile = os.path.realpath ( __main__.__file__ )
			return os.path.dirname ( mainfile )


def getMainModulePath ( path = None ):
	base = _getMainModulePath ()
	if not path: return base
	return base + '/' + path
