def _try_import_with_global_library_symbols():
    try:
        import DLFCN
        dlopen_flags = DLFCN.RTLD_NOW | DLFCN.RTLD_GLOBAL
    except ImportError:
        import ctypes
        dlopen_flags = ctypes.RTLD_GLOBAL

    import sys
    old_flags = sys.getdlopenflags()
    try:
        sys.setdlopenflags(dlopen_flags)
        import lupa._lupa
    finally:
        sys.setdlopenflags(old_flags)

try:
    _try_import_with_global_library_symbols()
except:
    pass

del _try_import_with_global_library_symbols

def __bootstrap__():
   import pkg_resources, imp, platform

   if platform.system() == 'Windows':
       print 'load AKU.dll'
       __file__ = pkg_resources.resource_filename(__name__, 'AKU.dll')
   elif platform.system() == 'Darwin':
       print 'load AKU.so'
       __file__ = pkg_resources.resource_filename(__name__, 'AKU.so')
   else:
       raise Exception('Undefined platform: ' + platform.system())

   # __loader__ = None; del __bootstrap__, __loader__
   imp.load_dynamic(__name__,__file__)
   
__bootstrap__()