from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

setup(
    cmdclass = {'build_ext': build_ext},
    ext_modules = [
        Extension("AKU", ["AKU.pyx"],
            language="c++",
            extra_objects=[
                # 'libmoai-box2d.a',
                # 'libmoai-chipmunk.a',
                # 'libmoai-core.a',
                # 'libmoai-luaext.a',
                # 'libmoai-sim.a',
                # 'libmoai-untz.a',
                # 'libmoai-util.a',
                # 'libthird-party.a',
                # 'libzlcore.a',
                # 'libluasocket.a',
                '*.lib'
            ],

            # extra_link_args=[
            # '-framework', 'OpenGL',
            # '-framework', 'GLUT',
            # '-framework', 'CoreServices',
            # '-framework', 'ApplicationServices',
            # '-framework', 'AudioToolbox',
            # '-framework', 'AudioUnit',
            # '-framework', 'CoreAudio',
            # '-framework', 'CoreGraphics',
            # '-framework', 'CoreLocation',
            # '-framework', 'Foundation',
            # '-framework', 'GameKit',
            # '-framework', 'QuartzCore',
            # '-framework', 'StoreKit',
            # '-framework', 'SystemConfiguration',
            # ],

            include_dirs=[
            # '/Users/vavius/moai/moai-dev/src/',
            # '/Users/vavius/moai/moai-dev/3rdparty/lua-5.1.3/src/',
            'D:/Github/moai-community/sdk/moai/src/',
            'D:/Github/moai-community/sdk/moai/3rdparty/lua-5.1.3/src/',
            'D:/Github/moai-community/sdk/moai/src/host-modules/'
            ])
    ]
)

# __Pyx_PyMODINIT_FUNC init__main__(void) CYTHON_SMALL_CODE; /*proto*/
# __Pyx_PyMODINIT_FUNC init__main__(void) {}
# __Pyx_PyMODINIT_FUNC initAKU(void) CYTHON_SMALL_CODE; /*proto*/
# __Pyx_PyMODINIT_FUNC initAKU(void)