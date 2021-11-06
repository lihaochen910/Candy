import sys
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
from Cython.Build import cythonize


def get_extra_objects ():
    if sys.platform == 'darwin':
        return [
            'libluajit-5.1.a',
            'libmoai-osx-host-modules.a',
            'libmoai-osx-3rdparty-core.a',
            'libmoai-osx-3rdparty-mbedtls.a',
            'libmoai-osx-3rdparty-sdl.a',
            'libmoai-osx-apple.a',
            'libmoai-osx-audio-sampler.a',
            'libmoai-osx-box2d.a',
            'libmoai-osx-crypto.a',
            'libmoai-osx-harfbuzz.a',
            'libmoai-osx-http-client.a',
            'libmoai-osx-http-server.a',
            'libmoai-osx-image-jpg.a',
            'libmoai-osx-image-png.a',
            'libmoai-osx-image-pvr.a',
            'libmoai-osx-image-webp.a',
            'libmoai-osx-luaext.a',
            'libmoai-osx-sdl.a',
            'libmoai-osx-sim.a',
            'libmoai-osx-untz.a',
            'libmoai-osx-zl-core.a',
            'libmoai-osx-zl-crypto.a',
            'libmoai-osx-zl-vfs.a',
            'libmoai-osx.a',
        ]
    elif sys.platform == 'win32':
        return [
            'msvcrtd.lib',
            'Shell32.lib',
            'User32.lib',
            'ole32.lib',
            'setupapi.lib',
            'lua51.lib',
            'luaext.lib',
            'sqlite.lib',
            "zlib.lib",
            "zl-lib-vfs.lib",
            "box2d.lib",
            "contrib.lib",
            "expat.lib",
            "freetype.lib",
            "tlsf.lib",
            "glew.lib",
            "jansson.lib",
            "kissfft.lib",
            "tinyxml.lib",
            "libcurl.lib",
            "mbedtls.lib",
            "libjpg.lib",
            "libpng.lib",
            "libpvr.lib",
            "libwebp.lib",
            "libogg.lib",
            "libvorbis.lib",
            "libtess.lib",
            "sdl.lib",
            "sfmt.lib",
            "untz.lib",
            "zl-lib-core.lib",
            "zl-lib-crypto.lib",
            "zl-lib-gfx.lib",
            "moai-lib-core.lib",
            "moai-lib-crypto.lib",
            "moai-lib-box2d.lib",
            "moai-lib-http-client.lib",
            "moai-lib-http-server.lib",
            "moai-lib-sim.lib",
            "moai-lib-luaext.lib",
            "moai-lib-image-jpg.lib",
            "moai-lib-image-png.lib",
            "moai-lib-image-pvr.lib",
            "moai-lib-image-webp.lib",
            "moai-lib-sdl.lib",
            "moai-lib-untz.lib",
            "moai-lib-util.lib",
            "host-modules.lib",
            "dsound.lib",
            "strmiids.lib",
            "advapi32.lib",
            "comctl32.lib",
            "oleaut32.lib",
            "opengl32.lib",
            "gdi32.lib",
            "rpcrt4.lib",
            "winmm.lib",
            "wldap32.lib",
            "ws2_32.lib",
            "wsock32.lib",
            "iphlpapi.lib",
            "psapi.lib",
            "imm32.lib",
            "version.lib",
        ]
    else:
        return []

def get_extra_link_args ():
    if sys.platform == 'darwin':
        return [
            '-framework', 'CoreServices',
            '-framework', 'CoreFoundation',
            '-framework', 'Foundation',
            '-framework', 'AudioUnit',
            '-framework', 'AudioToolbox',
            '-framework', 'GLUT',
            '-framework', 'IOKit',
            '-framework', 'OpenGL',

            '-framework', 'ApplicationServices',
            '-framework', 'CoreAudio',
            '-framework', 'CoreGraphics',
            '-framework', 'CoreLocation',
            '-framework', 'CoreHaptics',
            '-framework', 'GameKit',
            '-framework', 'GameController',
            '-framework', 'QuartzCore',
            '-framework', 'StoreKit',
            '-framework', 'SystemConfiguration',
        ]
    else:
        return []

def get_include_dirs ():
    if sys.platform == 'darwin':
        return [
            '/Users/Kanbaru/GitWorkspace/moai-community/sdk/moai/src/',
            '/Users/Kanbaru/GitWorkspace/moai-community/sdk/moai/3rdparty/LuaJIT-2.1.0/src/',
            '/Users/Kanbaru/GitWorkspace/moai-community/sdk/moai/src/host-modules/'
        ]
    elif sys.platform == 'win32':
        return [
            'D:/Github/moai-community/sdk/moai/src/',
            'D:/Github/moai-community/sdk/moai/3rdparty/LuaJIT-2.0.5/src/',
            'D:/Github/moai-community/sdk/moai/src/host-modules/'
            # 'G:/BaiduNetdiskDownload/moai-community/sdk/moai/src/',
            # 'G:/BaiduNetdiskDownload/moai-community/sdk/moai/3rdparty/lua-5.1.3/src/',
            # 'G:/BaiduNetdiskDownload/moai-community/sdk/moai/src/host-modules/'
        ]
    else:
        return []

setup(
    cmdclass = { 'build_ext': build_ext },
    ext_modules = 
    cythonize (
    [
        Extension ( "AKU", ["AKU.pyx"],
            language = "c++",
            define_macros = [
                ( 'AKU_WITH_LUAEXT', '1' ),
                ( 'MOAI_WITH_LUAEXT', '1' ),
                ( 'MOAI_WITH_LUAJIT', '1' ),
                ( 'AKU_WITH_HARFBUZZ', '1' ),
                ( 'AKU_WITH_HTTP_SERVER', '1' ),
            ],
            extra_compile_args = [
                '-DAKU_WITH_LUAEXT',
                '-DMOAI_WITH_LUAEXT',
                '-DMOAI_WITH_LUAJIT',
                # '-DCYTHON_FAST_THREAD_STATE',
                # '-DCYTHON_FAST_PYCALL',
            ],
            extra_objects = get_extra_objects (),
            extra_link_args = get_extra_link_args (),
            include_dirs = get_include_dirs ()
        )
    ]
    , compiler_directives={
            'language_level': "3str",
            # "c_string_type": "acsii",
            # "c_string_encoding": "utf8"
    } )
)

# __Pyx_PyMODINIT_FUNC init__main__(void) CYTHON_SMALL_CODE; /*proto*/
# __Pyx_PyMODINIT_FUNC init__main__(void) {}
# __Pyx_PyMODINIT_FUNC initAKU(void) CYTHON_SMALL_CODE; /*proto*/
# __Pyx_PyMODINIT_FUNC initAKU(void)
