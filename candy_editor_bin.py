##----------------------------------------------------------------##
# find candy library
import os
import os.path
import platform
import sys

try:
	import faulthandler
	faulthandler.enable ()
except Exception as e:
	pass


def isPythonFrozen ():
	return hasattr ( sys, "frozen" )


def getMainModulePath ():
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
		else:
			mainfile = os.path.realpath ( __main__.__file__ )
			return os.path.dirname ( mainfile )


candyPath = getMainModulePath () + '/lib'
candyEditorPath = getMainModulePath () + '/lib/candy_editor'
thirdPartyPathBase = getMainModulePath () + '/lib/3rdparty'
thirdPartyPathCommon = thirdPartyPathBase + '/common'
if platform.system () == u'Darwin':
	thirdPartyPathNative = thirdPartyPathBase + '/osx'
else:
	thirdPartyPathNative = thirdPartyPathBase + '/windows'

sys.path.insert ( 0, candyPath )
sys.path.insert ( 2, thirdPartyPathNative )
sys.path.insert ( 1, thirdPartyPathCommon )

##----------------------------------------------------------------##
import candy_editor_cfg
import candy_editor

##----------------------------------------------------------------##
DO_PROFILE = False
candy_editor.MODULEPATH = [
	candyPath,
	thirdPartyPathNative,
	thirdPartyPathCommon,
]

PYTHONPATH0 = os.getenv ( 'PYTHONPATH' )
PYTHONPATH1 = (PYTHONPATH0 and PYTHONPATH0 + ':' or '') + (':'.join ( candy_editor.MODULEPATH ))
os.putenv ( 'PYTHONPATH', PYTHONPATH1 )

print ( "PYTHONPATH: %s" % os.getenv ( 'PYTHONPATH' ) )

def main ():
	if DO_PROFILE:
		import cProfile, pstats
		pr = cProfile.Profile ()
		pr.enable ()

		candy_editor.startup ()

		pr.disable ()
		ps = pstats.Stats ( pr )
		ps.sort_stats ( 'calls', 'time' )
		ps.print_stats ()
	else:
		# print ( "candyPath: %s" % candyPath )
		# print ( "thirdPartyPathNative: %s" % thirdPartyPathNative )
		# print ( "thirdPartyPathCommon: %s" % thirdPartyPathCommon )
		candy_editor.startup ()


if __name__ == '__main__':
	if isPythonFrozen ():
		sys.argv = [ 'candy_editor', 'stub' ]
	main ()
