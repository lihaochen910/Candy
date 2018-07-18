################################################
##                                            ##
##                                            ##
##    8888ba.88ba   .88888.   .d888888  dP    ##
##    88  `8b  `8b d8'   `8b d8'    88  88    ##
##    88   88   88 88     88 88aaaaa88a 88    ##
##    88   88   88 88     88 88     88  88    ##
##    88   88   88 Y8.   .8P 88     88  88    ##
##    dP   dP   dP  `8888P'  88     88  dP    ##
##                                            ##
##                                            ##
################################################
cdef extern from *:
    ctypedef char* const_char_ptr "const char*"

ctypedef void (*funcOpenWindow)         ( const_char_ptr title, int width, int height)
ctypedef void (*funcEnterFullscreen)    ()
ctypedef void (*funcExitFullscreen)     ()

cdef extern from "moai-core/host.h" nogil:
    ctypedef struct lua_State:
        pass
    ctypedef int AKUContextID

    void            AKUAppFinalize                  ()
    void            AKUAppInitialize                ()
    int				AKUCheckContext					( AKUContextID context )
    void            AKUClearMemPool                 ()
    int				AKUCountContexts				()
    AKUContextID    AKUCreateContext                ()
    void            AKUDeleteContext                ( AKUContextID context )
    AKUContextID    AKUGetContext                   ()
    void*           AKUGetUserdata                  ()

    void            AKUInitMemPool                  ( size_t sizeInBytes )
    void            AKUSetContext                   ( AKUContextID context )
    void            AKUSetLogLevel                  ( int logLevel )
    void            AKUSetUserdata                  ( void* user )

    # management api
    int				AKUCallFunc						()
    # int				AKUCallFuncWithArgArray			( char* exeName, char* scriptName, int argc, char** argv, int asParams )
    # int				AKUCallFuncWithArgString		( char* exeName, char* scriptName, char* args, int asParams )
    lua_State*      AKUGetLuaState                  ()
    char*           AKUGetMoaiVersion               ( char* buffer, size_t length )
    char*           AKUGetWorkingDirectory          ( char* buffer, size_t length )
    int				AKULoadFuncFromBuffer			( void* data, size_t size, const_char_ptr chunkname, int compressed )
    int				AKULoadFuncFromFile				( const_char_ptr filename )
    int				AKULoadFuncFromString			( const_char_ptr script, size_t size, const_char_ptr chunkname )
    int             AKUMountVirtualDirectory        ( char* virtualPath, char* archive )
    int             AKUSetWorkingDirectory          ( char* path )

    ctypedef void ( *AKUErrorTracebackFunc )        ( char* message, lua_State* L, int level )
    void            AKUSetFunc_ErrorTraceback       ( AKUErrorTracebackFunc func )

# cdef extern from "moai-util/host.h":
    # void            AKUUtilAppFinalize          ()
    # void            AKUUtilAppInitialize        ()
    # void            AKUUtilContextInitialize    ()

# cdef extern from "moai-untz/host.h":
    # void            AKUUntzAppFinalize          ()
    # void            AKUUntzAppInitialize        ()
    # void            AKUUntzContextInitialize    ()

# cdef extern from "lua-headers/moai_lua.h":
    # cdef int moai_lua_SIZE
    # cdef unsigned char moai_lua[]
    # cdef int AKU_DATA_BYTECODE
    # cdef char* AKU_DATA_STRING
    # cdef int AKU_DATA_ZIPPED
    # cdef int AKU_DATA_UNCOMPRESSED

# cdef char* AKU_DATA_STRING = 'moai.lua'

# cdef extern from "moai-luaext/host.h":
    # void            AKULuaExtAppFinalize      ()
    # void            AKULuaExtAppInitialize    ()
    # void            AKULuaExtContextInitialize()

cdef extern from "moai-sim/host.h" nogil:
    # setup
    void            AKUSimAppFinalize               ()
    void            AKUSimAppInitialize             ()
    void            AKUSimContextInitialize         ()

    #....
    void			AKUSetOrientation				( int orientation )
    void			AKUSetScreenDpi					( int dpi )
    void			AKUSetScreenSize				( int width, int height )
    void			AKUSetViewSize					( int width, int height )

    # management api
    void			AKUDetectFramebuffer			()
    void			AKUDetectGfxContext				()
    void			AKUDiscardGfxResources			()
    double			AKUGetSimStep					()
    # int				AKUIsGfxBufferOpaque			()
    void			AKUPause						( bint pause )
    void			AKURender						()
    void			AKUUpdate						()

    # callback management
    ctypedef void ( *AKUEnterFullscreenModeFunc )    ()
    ctypedef void ( *AKUExitFullscreenModeFunc )     ()
    ctypedef void ( *AKUHideCursorFunc )			 ()
    # ctypedef void ( *AKUOpenWindowFunc )             ( const char* title, int width, int height )
    ctypedef void ( *AKUOpenWindowFunc )             ( const_char_ptr title, int width, int height )
    ctypedef void ( *AKUSetSimStepFunc )             ( double step )
    ctypedef void ( *AKUSetTextInputRectFunc )		 ( int xMin, int yMin, int xMax, int yMax )
    ctypedef void ( *AKUShowCursorFunc )			 ()

    void            AKUSetFunc_OpenWindow           ( funcOpenWindow func )
    void            AKUSetFunc_SetSimStep           ( AKUSetSimStepFunc func )
    void		    AKUSetFunc_ShowCursor			( AKUShowCursorFunc func )
    void		    AKUSetFunc_HideCursor			( AKUHideCursorFunc func )
    void            AKUSetFunc_EnterFullscreenMode  ( funcEnterFullscreen func )
    void            AKUSetFunc_ExitFullscreenMode   ( funcExitFullscreen func )
    void		    AKUSetFunc_SetTextInputRect		( AKUSetTextInputRectFunc func )

    # input device api
    void            AKUReserveInputDevices          ( int total )
    void            AKUReserveInputDeviceSensors    ( int deviceID, int total )
    void			AKUSetInputAutoTimestamp		( bint autotimestamp )
    void            AKUSetInputConfigurationName    ( char* name )
    void            AKUSetInputDevice               ( int deviceID, char* name )
    void			AKUSetInputDeviceHardwareInfo	( int deviceID, char* hardwareInfo )
    void            AKUSetInputDeviceActive         ( int deviceID, bint active )
    void            AKUSetInputDeviceButton         ( int deviceID, int sensorID, char* name )
    void            AKUSetInputDeviceCompass        ( int deviceID, int sensorID, char* name )
    void            AKUSetInputDeviceKeyboard       ( int deviceID, int sensorID, char* name )
    void			AKUSetInputDeviceJoystick		( int deviceID, int sensorID, char* name )
    void            AKUSetInputDeviceLevel          ( int deviceID, int sensorID, char* name )
    void            AKUSetInputDeviceLocation       ( int deviceID, int sensorID, char* name )
    void            AKUSetInputDevicePointer        ( int deviceID, int sensorID, char* name )
    void            AKUSetInputDeviceTouch          ( int deviceID, int sensorID, char* name )
    void			AKUSetInputDeviceVector			( int deviceID, int sensorID, char* name )
    void            AKUSetInputDeviceWheel          ( int deviceID, int sensorID, char* name )
    void			AKUSetInputTimebase				( double timebase )
    void			AKUSetInputTimestamp			( double timestamp )

    # input events api
    void			AKUEnqueueButtonEvent			( int deviceID, int sensorID, bint down )
    void			AKUEnqueueCompassEvent			( int deviceID, int sensorID, float heading )
    void			AKUEnqueueJoystickEvent			( int deviceID, int sensorID, float x, float y )
    void			AKUEnqueueKeyboardCharEvent		( int deviceID, int sensorID, int unicodeChar )
    void			AKUEnqueueKeyboardEditEvent		( int deviceID, int sensorID, char* text, int start, int editLength, int maxLength)
    void			AKUEnqueueKeyboardKeyEvent		( int deviceID, int sensorID, int keyID, bint down )
    void			AKUEnqueueKeyboardTextEvent		( int deviceID, int sensorID, const_char_ptr text )
    void			AKUEnqueueLevelEvent			( int deviceID, int sensorID, float x, float y, float z )
    void			AKUEnqueueLocationEvent			( int deviceID, int sensorID, double longitude, double latitude, double altitude, float hAccuracy, float vAccuracy, float speed )
    void			AKUEnqueuePointerEvent			( int deviceID, int sensorID, int x, int y )
    void			AKUEnqueueTouchEvent			( int deviceID, int sensorID, int touchID, bint down, float x, float y )
    void			AKUEnqueueTouchEventCancel		( int deviceID, int sensorID )
    void			AKUEnqueueVectorEvent			( int deviceID, int sensorID, float x, float y, float z )
    void			AKUEnqueueWheelEvent			( int deviceID, int sensorID, float value )

cdef extern from "aku_modules.h" nogil:
    void	        AKUModulesAppFinalize           ()
    void            AKUModulesAppInitialize         ()
    void    	    AKUModulesContextInitialize     ()
    void    	    AKUModulesPause					( bint pause )
    void            AKUModulesUpdate                ()

cdef extern from "aku_modules_util.h" nogil:
    void		    AKUModulesRunLuaAPIWrapper      ()

