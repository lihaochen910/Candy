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
   import sys, pkg_resources, imp, platform

   if platform.system() == 'Windows':
       __file__ = pkg_resources.resource_filename(__name__, 'moaipy.dll')
   elif platform.system() == 'Darwin':
       __file__ = pkg_resources.resource_filename(__name__, 'moaipy.so')
   else:
       raise Exception('Undefined platform: ' + name)

   __loader__ = None; del __bootstrap__, __loader__
   imp.load_dynamic(__name__,__file__)
   
__bootstrap__()