# cython: embedsignature=True
STUFF = "Hi"
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

include '_lupa.pyx'

from AKU cimport *
from libc.string cimport strcpy, strlen

import atexit

_aku = None

def _removeMoaiSingleton():
    global _aku
    if _aku:
        del _aku

def getAKU():
    global _aku
    if _aku:
        return _aku
    return AKU()

atexit.register(_removeMoaiSingleton)

cdef void _callbackOpenWindow(const_char_ptr title, int width, int height):
    _aku.onOpenWindow(title, width, height)

cdef void _callbackEnterFullscreenMode():
    _aku.onEnterFullscreenMode()

cdef void _callbackExitFullscreenMode():
    _aku.onExitFullscreenMode()

cdef class AKU:
    cdef LuaRuntime lua
    cdef object _funcOpenWindow
    cdef object _funcEnterFS
    cdef object _funcExitFS
    cdef object _initialized

    def __cinit__(self):
        global _aku
        _aku = self

    def __dealloc__(self):
        global _aku
        _aku = None
        self.deleteContext()
        if self._initialized:
            AKUAppFinalize()

    def __init__(self):
        self._initialized = False

    # Management
    def update(self):
        AKUModulesUpdate()

    def pause(self, paused=True):
        AKUPause(paused)

    def render(self):
        AKURender()

    def detectGfxContext(self):
        AKUDetectGfxContext()

    def finalize(self):
        AKUModulesAppFinalize()

    # Lua
    def getLuaRuntime(self):
        return self.lua

    def runScript(self, filename):
        AKULoadFuncFromFile(filename.encode('utf-8'))
        AKUCallFunc()

    def runString(self, script, chunkname = "chunk"):
        bscript = script.encode('utf-8')
        bchunkname = chunkname.encode('utf-8')
        AKULoadFuncFromString(bscript, strlen(bscript), bchunkname)
        AKUCallFunc()

    def evalString(self, text):
        return self.lua.eval(text)

    # Context
    def createContext(self):
        if not self._initialized:
            AKUAppInitialize()
            AKUModulesAppInitialize()
            self._initialized = True

        AKUCreateContext()

        AKUModulesContextInitialize()

        # registerHelpers()
        # registerExtensionClasses()

        # AKUAudioSamplerInit()

        AKUSetFunc_OpenWindow(_callbackOpenWindow)
        AKUSetFunc_ExitFullscreenMode(_callbackExitFullscreenMode)
        AKUSetFunc_EnterFullscreenMode(_callbackEnterFullscreenMode)

        cdef lua_State *L = AKUGetLuaState()
        self.lua = LuaRuntime()
        self.lua.initWithState(L)

    def checkContext(self):
        return AKUGetContext() != 0

    def resetContext(self):
        self.deleteContext()
        self.createContext()

    def deleteContext(self):
        context = AKUGetContext()
        if context != 0:
            # self.lua.destroy()
            self.lua = None
            AKUDeleteContext(context)
            self.finalize()

    def clearMemPool(self):
        AKUClearMemPool()

    # Display
    def setScreenSize(self, w, h):
        AKUSetScreenSize(w, h)

    def setViewSize(self, w, h):
        AKUSetViewSize(w, h)

    def setOrientationLandscape(self):
        AKUSetOrientation(1)

    def setOrientationPortrait(self):
        AKUSetOrientation(0)

    def setWorkingDirectory(self, path):
        AKUSetWorkingDirectory(path.encode('utf-8'))

    # Input device
    def reserveInputDevices(self, count):
        AKUReserveInputDevices(count)

    def reserveInputDeviceSensors(self, devId, count):
        AKUReserveInputDeviceSensors(devId, count)

    def setInputAutoTimestamp(self, autotimestamp = False):
        AKUSetInputAutoTimestamp(autotimestamp)

    def setInputConfigurationName(self, name):
        AKUSetInputConfigurationName(name.encode('utf-8'))

    def setInputDevice(self, id, name):
        AKUSetInputDevice(id, name.encode('utf-8'))

    def setInputDeviceHardwareInfo(self, id, hardwareInfo):
        AKUSetInputDeviceHardwareInfo(id, hardwareInfo)

    def setInputDeviceActive(self, id, active):
        AKUSetInputDeviceActive(id, active)

    def setInputDeviceButton(self, devId, sensorId, name):
        AKUSetInputDeviceButton(devId, sensorId, name.encode('utf-8'))

    def setInputDeviceCompass(self, devId, sensorId, name):
        AKUSetInputDeviceCompass(devId, sensorId, name.encode('utf-8'))

    def setInputDeviceKeyboard(self, devId, sensorId, name):
        AKUSetInputDeviceKeyboard(devId, sensorId, name.encode('utf-8'))

    def setInputDeviceJoystick(self, devId, sensorId, name):
        AKUSetInputDeviceJoystick(devId, sensorId, name.encode('utf-8'))

    def setInputDeviceLevel(self, devId, sensorId, name):
        AKUSetInputDeviceLevel(devId, sensorId, name.encode('utf-8'))

    def setInputDeviceLocation(self, devId, sensorId, name):
        AKUSetInputDeviceLocation(devId, sensorId, name.encode('utf-8'))

    def setInputDevicePointer(self, devId, sensorId, name):
        AKUSetInputDevicePointer(devId, sensorId, name.encode('utf-8'))

    def setInputDeviceTouch(self, devId, sensorId, name):
        AKUSetInputDeviceTouch(devId, sensorId, name.encode('utf-8'))

    def setInputDeviceVector(self, devId, sensorId, name):
        AKUSetInputDeviceVector(devId, sensorId, name.encode('utf-8'))

    def setInputDeviceWheel(self, devId, sensorId, name):
        AKUSetInputDeviceWheel(devId, sensorId, name.encode('utf-8'))

    def setInputTimebase(self, timebase):
        AKUSetInputTimebase(timebase)

    def setInputTimestamp(self, timestamp):
        AKUSetInputTimestamp(timestamp)

    # Input events
    def enqueueButtonEvent(self, deviceID, sensorID, down):
        AKUEnqueueButtonEvent(deviceID, sensorID, down)

    def enqueueCompassEvent(self, deviceID, sensorID, heading):
        AKUEnqueueCompassEvent(deviceID, sensorID, heading)

    def enqueueJoystickEvent(self, deviceID, sensorID, x, y):
        AKUEnqueueJoystickEvent(deviceID, sensorID, x, y)

    def enqueueKeyboardCharEvent(self, deviceID, sensorID, character):
        AKUEnqueueKeyboardCharEvent(deviceID, sensorID, character)

    def enqueueKeyboardKeyEvent(self, deviceID, sensorID, keyID, down):
        AKUEnqueueKeyboardKeyEvent(deviceID, sensorID, keyID, down)

    def enqueueKeyboardTextEvent(self, deviceID, sensorID, text):
        AKUEnqueueKeyboardTextEvent(deviceID, sensorID, text)

    def enqueueLevelEvent(self, deviceID, sensorID, x, y, z):
        AKUEnqueueLevelEvent(deviceID, sensorID, x, y, z)

    def enqueuePointerEvent(self, deviceID, sensorID, x, y):
        AKUEnqueuePointerEvent(deviceID, sensorID, x, y)

    def enqueueTouchEvent(self, deviceID, sensorID, touchID, down, x, y):
        AKUEnqueueTouchEvent(deviceID, sensorID, touchID, down, x, y)

    def enqueueTouchEventCancel(self, deviceID, sensorID):
        AKUEnqueueTouchEventCancel(deviceID, sensorID)

    def enqueueVectorEvent(self, deviceID, sensorID, x, y ,z):
        AKUEnqueueVectorEvent(deviceID, sensorID, x, y ,z)

    def enqueueWheelEvent(self, deviceID, sensorID, value):
        AKUEnqueueWheelEvent(deviceID, sensorID, value)

    # Callback
    def setFuncOpenWindow(self, f):
        self._funcOpenWindow = f

    def setFuncEnterFullscreenMode(self, f):
        self._funcEnterFS = f

    def setFuncExitFullscreenMode(self, f):
        self._funcExitFS = f

    def onOpenWindow(self, title, width, height):
        if self._funcOpenWindow:
            self._funcOpenWindow(title, width, height)

    def onEnterFullScreen(self):
        if self._funcEnterFS:
            self._funcEnterFS()

    def onExitFullScreen(self):
        if self._funcExitFS:
            self._funcExitFS()

# Modules
# def AKUModulesAppInitialize():
# AKULuaExtAppInitialize()
# AKUSimAppInitialize()
# AKUUntzAppInitialize()
# AKUUtilAppInitialize()

# def AKUModulesAppFinalize():
# AKUUtilAppFinalize()
# AKUSimAppFinalize()
# AKULuaExtAppFinalize()
# AKUUntzAppFinalize()

# def AKUModulesContextInitialize():
# AKULuaExtContextInitialize()
# AKUSimContextInitialize()
# AKUUntzContextInitialize()
# AKUUtilContextInitialize()
