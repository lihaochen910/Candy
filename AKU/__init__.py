def _try_import_with_global_library_symbols ():
	try:
		import DLFCN
		dlopen_flags = DLFCN.RTLD_NOW | DLFCN.RTLD_GLOBAL
	except ImportError:
		import ctypes
		dlopen_flags = ctypes.RTLD_GLOBAL

	import sys
	old_flags = sys.getdlopenflags ()
	try:
		sys.setdlopenflags ( dlopen_flags )
		import lupa._lupa
	finally:
		sys.setdlopenflags ( old_flags )


try:
	_try_import_with_global_library_symbols ()
except:
	pass

del _try_import_with_global_library_symbols

import sys

isPython2 = sys.version_info.major == 2


def load_lib ( name ):
	import pkg_resources, platform

	if platform.system () == 'Windows':
		__file__ = pkg_resources.resource_filename ( __name__, name + '.dll' )
		print ( 'load lib ' + __file__ )
	elif platform.system () == 'Darwin':
		__file__ = pkg_resources.resource_filename ( __name__, name + '.so' )
		print ( 'load lib ' + __file__ )
	else:
		raise Exception ( 'Undefined platform: ' + platform.system () )

	# if not isPython2:
	# 	import os
	# 	os.add_dll_directory ( os.getcwd () )
	# 	os.add_dll_directory ( os.path.dirname ( os.path.realpath ( __file__ ) ) )

	# __loader__ = None; del __bootstrap__, __loader__
	if isPython2:
		import imp
		imp.load_dynamic ( __name__, __file__ )
	else:
		import imp
		imp.load_dynamic ( __name__, __file__ )
		# from ctypes import cdll
		# cdll.LoadLibrary ( __file__ )


def __bootstrap__ ():
	load_lib ( 'AKU' )


__bootstrap__ ()
