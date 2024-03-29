from time import time as getTime

from PyQt5 import QtCore
from PyQt5.QtCore import Qt

from candy_editor import *
from candy_editor.core.EditorApp import app
from candy_editor.core import signals

from candy_editor.moai.MOAIRuntime import MOAILuaDelegate
from candy_editor.moai.MOAICanvasBase import MOAICanvasBase

# import ContextDetection

def isBoundMethod ( v ):
	return hasattr ( v, '__func__' ) and hasattr ( v, 'im_self' )


def boundToClosure ( value ):
	if isBoundMethod ( value ):
		func = value
		value = lambda *args: func ( *args )
	return value


QTKeymap = {
	205: "lalt",
	178: "pause",
	255: "menu",
	44: ",",
	48: "0",
	52: "4",
	56: "8",
	180: "sysreq",
	64: "@",
	174: "return",
	55: "7",
	92: "\\",
	176: "insert",
	68: "d",
	72: "h",
	76: "l",
	80: "p",
	84: "t",
	88: "x",
	190: "right",
	204: "meta",
	170: "escape",
	186: "home",
	96: "'",
	32: "space",
	51: "3",
	173: "backspace",
	193: "pagedown",
	47: "slash",
	59: ";",
	208: "scrolllock",
	91: "[",
	67: "c",
	90: "z",
	71: "g",
	202: "lshift",
	75: "k",
	79: "o",
	83: "s",
	87: "w",
	177: "delete",
	191: "down",
	46: ".",
	50: "2",
	54: "6",
	58: ":",
	66: "b",
	70: "f",
	74: "j",
	192: "pageup",
	189: "up",
	78: "n",
	82: "r",
	86: "v",
	229: "f12",
	230: "f13",
	227: "f10",
	228: "f11",
	231: "f14",
	232: "f15",
	203: "lctrl",
	218: "f1",
	219: "f2",
	220: "f3",
	221: "f4",
	222: "f5",
	223: "f6",
	224: "f7",
	225: "f8",
	226: "f9",
	171: "tab",
	207: "numlock",
	187: "end",
	45: "-",
	49: "1",
	53: "5",
	57: "9",
	61: "=",
	93: "]",
	65: "a",
	69: "e",
	73: "i",
	77: "m",
	81: "q",
	85: "u",
	89: "y",
	188: "left",
}


def convertKeyCode ( k ):
	if k > 1000: k = ( k & 0xff ) + ( 255 - 0x55 )
	return QTKeymap.get ( k, k )


class MOAIEditCanvasLuaDelegate ( MOAILuaDelegate ):

	# class MOAIEditCanvasLuaDelegate():
	# Add some shortcuts
	def clearLua ( self ):
		super ( MOAIEditCanvasLuaDelegate, self ).clearLua ()
		self._onMouseDown = None
		self._onMouseUp = None
		self._onMouseMove = None
		self._onMouseEnter = None
		self._onMouseLeave = None
		self._onMouseScroll = None
		self._onKeyDown = None
		self._onKeyUp = None

		self._onResize = None
		self._postDraw = None
		self._onUpdate = None

	def load ( self, scriptPath, scriptEnv = None ):
		super ( MOAIEditCanvasLuaDelegate, self ).load ( scriptPath, scriptEnv )
		env = self.luaEnv
		if not env:
			raise Exception ( 'failed loading editcanvas script:%s' % scriptPath )
			pass
		self.updateHooks ()

	def updateHooks ( self ):
		env = self.luaEnv
		if not env: return
		self._onMouseDown = env.onMouseDown
		self._onMouseUp = env.onMouseUp
		self._onMouseMove = env.onMouseMove
		self._onMouseLeave = env.onMouseLeave
		self._onMouseEnter = env.onMouseEnter

		self._onMouseScroll = env.onMouseScroll
		self._onKeyDown = env.onKeyDown
		self._onKeyUp = env.onKeyUp

		self._onResize = env.onResize
		self._postDraw = env.postDraw
		self._onUpdate = env.onUpdate

	def onMouseDown ( self, btn, x, y ):
		if self._onMouseDown: self._onMouseDown ( btn, x, y )

	def onMouseUp ( self, btn, x, y ):
		if self._onMouseUp: self._onMouseUp ( btn, x, y )

	def onMouseMove ( self, x, y ):
		if self._onMouseMove: self._onMouseMove ( x, y )

	def onMouseEnter ( self ):
		if self._onMouseEnter: self._onMouseEnter ()

	def onMouseLeave ( self ):
		if self._onMouseLeave: self._onMouseLeave ()

	def onMouseScroll ( self, dx, dy, x, y ):
		if self._onMouseScroll: self._onMouseScroll ( dx, dy, x, y )

	def onKeyDown ( self, key ):
		if self._onKeyDown: self._onKeyDown ( key )

	def onKeyUp ( self, key ):
		if self._onKeyUp: self._onKeyUp ( key )

	def onUpdate ( self, step ):
		if self._onUpdate: self._onUpdate ( step )

	def postDraw ( self ):
		if self._postDraw: self._postDraw ()

	def onResize ( self, w, h ):
		if self._onResize: self._onResize ( w, h )


_NameToCursor = {
	'arrow': Qt.ArrowCursor,
	'up-arrow': Qt.UpArrowCursor,
	'cross': Qt.CrossCursor,
	'wait': Qt.WaitCursor,
	'i-beam': Qt.IBeamCursor,
	'size-vertical': Qt.SizeVerCursor,
	'size-horizontal': Qt.SizeHorCursor,
	'size-bd': Qt.SizeBDiagCursor,
	'size-fd': Qt.SizeFDiagCursor,
	'size-all': Qt.SizeAllCursor,
	'blank': Qt.BlankCursor,
	'split-v': Qt.SplitVCursor,
	'split-h': Qt.SplitHCursor,
	'pointing-hand': Qt.PointingHandCursor,
	'forbidden': Qt.ForbiddenCursor,
	'open-hand': Qt.OpenHandCursor,
	'closed-hand': Qt.ClosedHandCursor,
	'whats-this': Qt.WhatsThisCursor,
	'busy': Qt.BusyCursor,
}


class MOAIEditCanvasBase ( MOAICanvasBase ):
	_id = 0

	def __init__ ( self, *args, **kwargs ):
		MOAIEditCanvas._id += 1
		super ( MOAIEditCanvasBase, self ).__init__ ( *args )

		contextPrefix = kwargs.get ( 'context_prefix', 'edit_canvas' )
		self.clearColor = kwargs.get ( 'clear_color', ( 0.75, 0.75, 0.75, 0 ) )
		self.runtime = app.affirmModule ( 'moai' )
		self.contextName = '%s<%d>' % (contextPrefix, MOAIEditCanvas._id)
		self.delegate = MOAIEditCanvasLuaDelegate ()
		self.updateTimer = QtCore.QTimer ( self )
		self.viewWidth = 0
		self.viewHeight = 0

		self.scriptEnv = None
		self.scriptPath = None
		self.lastUpdateTime = 0
		self.updateStep = 0
		self.alwaysForcedUpdate = False

		self.currentCursorId = 'arrow'
		self.cursorHidden = False

		self.updateTimer.timeout.connect ( self.updateCanvas )
		signals.connect ( 'moai.reset', self.onMoaiReset )
		signals.connect ( 'moai.clean', self.onMoaiClean )

	def hideCursor ( self ):
		self.cursorHidden = True
		self.setCursor ( QtCore.Qt.BlankCursor )

	def showCursor ( self ):
		self.cursorHidden = False
		self.setCursorById ( self.currentCursorId )

	def setCursorById ( self, id ):
		self.currentCursorId = id
		if self.cursorHidden: return
		self.setCursor ( _NameToCursor.get ( self.currentCursorId, QtCore.Qt.ArrowCursor ) )

	def setCursorPos ( self, x, y ):
		self.cursor ().setPos ( self.mapToGlobal ( QtCore.QPoint ( x, y ) ) )

	def getCanvasSize ( self ):
		return self.width (), self.height ()

	def startUpdateTimer ( self, fps ):
		step = 1000 / fps
		self.updateTimer.start ( step )
		self.updateStep = 1.0 / fps
		self.lastUpdateTime = getTime ()

	def stopUpdateTimer ( self ):
		self.updateTimer.stop ()

	def onMoaiReset ( self ):
		self.setupContext ()

	def onMoaiClean ( self ):
		self.stopUpdateTimer ()
		self.stopRefreshTimer ()

	def loadScript ( self, scriptPath, env = None, **kwargs ):
		self.scriptPath = scriptPath
		self.scriptEnv = env
		self.setupContext ()

	def setDelegateEnv ( self, key, value, autoReload = True ):
		# convert bound method to closure
		self.delegate.setEnv ( key, boundToClosure ( value ), autoReload )

	def getDelegateEnv ( self, key, defaultValue = None ):
		return self.delegate.getEnv ( key, defaultValue )

	def setupContext ( self ):
		self.runtime.createRenderContext ( self.contextName, self.clearColor )
		# self.setInputDevice( self.runtime.addDefaultInputDevice( self.contextName ) )

		if self.scriptPath:
			self.makeCurrent ()
			env = {
				# '_delegate'        : self.delegate,
				'updateCanvas': boundToClosure ( self.updateCanvas ),
				'hideCursor': boundToClosure ( self.hideCursor ),
				'showCursor': boundToClosure ( self.showCursor ),
				'setCursor': boundToClosure ( self.setCursorById ),
				'setCursorPos': boundToClosure ( self.setCursorPos ),
				'getCanvasSize': boundToClosure ( self.getCanvasSize ),
				'startUpdateTimer': boundToClosure ( self.startUpdateTimer ),
				'stopUpdateTimer': boundToClosure ( self.stopUpdateTimer ),
				'contextName': boundToClosure ( self.contextName )
			}

			if self.scriptEnv:
				env.update ( self.scriptEnv )
			self.delegate.load ( self.scriptPath, env )

			self.delegate.safeCall ( 'onLoad' )
			self.resizeGL ( self.width (), self.height () )
			self.startRefreshTimer ()
			self.updateCanvas ()

	def safeCall ( self, method, *args ):
		self.makeCurrent ()
		return self.delegate.safeCall ( method, *args )

	def call ( self, method, *args ):
		self.makeCurrent ()
		return self.delegate.call ( method, *args )

	def safeCallMethod ( self, objId, method, *args ):
		self.makeCurrent ()
		return self.delegate.safeCallMethod ( objId, method, *args )

	def callMethod ( self, objId, method, *args ):
		self.makeCurrent ()
		return self.delegate.callMethod ( objId, method, *args )

	# def callMethodWithContext(self, objId, method, *args):		 
	# 	self.makeCurrent()
	# 	return self.delegate.safeCallMethod(objId, method, *args)

	# def callWithContext( self, method, *args):
	# 	self.makeCurrent()
	# 	return self.safeCall( method, *args )

	def makeCurrent ( self ):
		self.runtime.changeRenderContext ( self.contextName, self.viewWidth, self.viewHeight )

	def onDraw ( self ):
		runtime = self.runtime
		runtime.setBufferSize ( self.viewWidth, self.viewHeight )
		self.makeCurrent ()
		runtime.manualRenderAll ()
		self.delegate.postDraw ()

	def updateCanvas ( self, **option ):
		currentTime = getTime ()
		step = currentTime - self.lastUpdateTime
		self.lastUpdateTime = currentTime

		step = self.updateStep  # >>>>>>

		runtime = self.runtime
		runtime.setBufferSize ( self.viewWidth, self.viewHeight )

		# self.makeCurrent()

		if not option.get ( 'no_sim', False ):
			runtime.stepSim ( step )

		# getAKU().updateFMOD()

		self.delegate.onUpdate ( step )
		if option.get ( 'forced', self.alwaysForcedUpdate ):
			self.forceUpdateGL ()
		else:
			self.updateGL ()

	def resizeGL ( self, width, height ):
		self.delegate.onResize ( width, height )
		self.viewWidth = width
		self.viewHeight = height


class MOAIEditCanvas ( MOAIEditCanvasBase ):

	def __init__ ( self, *args, **kwargs ):
		super ( MOAIEditCanvas, self ).__init__ ( *args, **kwargs )
		self.keyGrabbingCount = 0

	def mousePressEvent ( self, event ):
		button = event.button ()
		x, y = event.x (), event.y ()
		btn = None
		if button == Qt.LeftButton:
			btn = 'left'
		elif button == Qt.RightButton:
			btn = 'right'
		elif button == Qt.MiddleButton:
			btn = 'middle'
		self.makeCurrent ()
		self.delegate.onMouseDown ( btn, x, y )

	def mouseReleaseEvent ( self, event ):
		button = event.button ()
		x, y = event.x (), event.y ()
		btn = None
		if button == Qt.LeftButton:
			btn = 'left'
		elif button == Qt.RightButton:
			btn = 'right'
		elif button == Qt.MiddleButton:
			btn = 'middle'
		self.makeCurrent ()
		self.delegate.onMouseUp ( btn, x, y )

	def mouseMoveEvent ( self, event ):
		x, y = event.x (), event.y ()
		self.makeCurrent ()
		self.delegate.onMouseMove ( x, y )

	def wheelEvent ( self, event ):
		steps = event.pixelDelta () / 120.0 # pixelDelta / angleDelta
		dx = 0
		dy = 0
		# if event.orientation () == Qt.Horizontal: # orientation to angleDelta
		if event.angleDelta ().x () != 0: # orientation to angleDelta
			dx = steps
		elif event.angleDelta ().y () != 0:
			dy = steps
		x, y = event.x (), event.y ()
		self.makeCurrent ()
		self.delegate.onMouseScroll ( dx, dy, x, y )

	def enterEvent ( self, event ):
		self.makeCurrent ()
		self.delegate.onMouseEnter ()

	def leaveEvent ( self, event ):
		self.makeCurrent ()
		self.delegate.onMouseLeave ()

	def clearModifierKeyState ( self ):  # workaround for canvas focus loss without give keyrelease event
		self.makeCurrent ()
		self.delegate.onKeyUp ( 'lshift' )
		self.delegate.onKeyUp ( 'lctrl' )
		self.delegate.onKeyUp ( 'lalt' )
		self.delegate.onKeyUp ( 'meta' )

	def keyPressEvent ( self, event ):
		if event.isAutoRepeat (): return
		# if self.keyGrabbingCount == 0:
		# 	self.grabKeyboard()
		# self.keyGrabbingCount += 1
		key = event.key ()
		self.makeCurrent ()
		self.delegate.onKeyDown ( convertKeyCode ( key ) )

	def keyReleaseEvent ( self, event ):
		# self.keyGrabbingCount -= 1
		# if self.keyGrabbingCount == 0:
		# 	self.releaseKeyboard()
		key = event.key ()
		self.makeCurrent ()
		self.delegate.onKeyUp ( convertKeyCode ( key ) )
