from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

setup(
    cmdclass = {'build_ext': build_ext},
    ext_modules = [
        Extension ( "AKU", ["AKU.pyx"],
            language = "c++",
            extra_compile_args = [

            ],
            extra_objects = [
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
                # 'Shell32.lib',
                # 'rpcrt4.lib',
                # 'iphlpapi.lib',
                # 'opengl32.lib',
                # 'lua-lib-5.1.lib',
                # 'moai-lib-box2d.lib',
                # 'moai-lib-core.lib',
                # 'moai-lib-crypto.lib',
                # 'moai-lib-sim.lib',
                # 'moai-lib-untz.lib',
                # 'moai-lib-util.lib',
                # 'zl-lib-core.lib',
                # 'zl-lib-crypto.lib',
                # 'zl-lib-gfx.lib',
                # 'zl-lib-vfs.lib',
                # '*.lib'
            ],

            extra_link_args = [
                '-framework', 'CoreServices',
                '-framework', 'CoreFoundation',
                '-framework', 'Foundation',
                '-framework', 'AudioUnit',
                '-framework', 'AudioToolbox',
                '-framework', 'GLUT',
                '-framework', 'IOKit',
                '-framework', 'OpenGL',

                # '-framework', 'CoreAudio',
                # '-framework', 'CoreVideo',
                # '-framework', 'CoreGraphics',
                # '-framework', 'CoreLocation',
            ],

            include_dirs = [
                # '/Users/vavius/moai/moai-dev/src/',
                # '/Users/vavius/moai/moai-dev/3rdparty/lua-5.1.3/src/',
                '/Users/Kanbaru/GitWorkspace/moai-community/sdk/moai/src/',
                '/Users/Kanbaru/GitWorkspace/moai-community/sdk/moai/3rdparty/lua-5.1.3/src/',
                '/Users/Kanbaru/GitWorkspace/moai-community/sdk/moai/src/host-modules/'
                # 'D:/Github/moai-community/sdk/moai/src/',
                # 'D:/Github/moai-community/sdk/moai/3rdparty/lua-5.1.3/src/',
                # 'D:/Github/moai-community/sdk/moai/src/host-modules/'
            ])
    ]
)

# __Pyx_PyMODINIT_FUNC init__main__(void) CYTHON_SMALL_CODE; /*proto*/
# __Pyx_PyMODINIT_FUNC init__main__(void) {}
# __Pyx_PyMODINIT_FUNC initAKU(void) CYTHON_SMALL_CODE; /*proto*/
# __Pyx_PyMODINIT_FUNC initAKU(void)
