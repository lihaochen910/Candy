import logging

from core import signals, app

from moai.MOAIRuntime import getAKU

from PyQt5 import QtCore, QtGui, QtOpenGL, QtWidgets
from PyQt5.QtCore import Qt

from sceneEditor.SceneEditor import SceneEditorModule

##----------------------------------------------------------------##
class GameView(SceneEditorModule):
	"""docstring for GameView"""

	def __init__(self):
		super(GameView, self).__init__()
		self.paused = False
		self.viewWidth = 0
		self.viewHeight = 0

	def getName(self):
		return 'game_view'

	def getDependency(self):
		return ['qt', 'moai', 'scene_editor']

	def getRuntime(self):
		return self.affirmModule('moai')

	def tryResizeContainer(self, w, h):
		# TODO:client area
		return True

	def setOrientationPortrait(self):
		if self.window.isFloating():
			pass  # TODO
		getAKU().setOrientationPortrait()

	def setOrientationLandscape(self):
		if self.window.isFloating():
			pass  # TODO
		getAKU().setOrientationLandscape()

	def onLoad(self):
		self.window = self.requestDockWindow(
			title='Game',
			# dock='right'
		)

		self.canvas = self.window.addWidget(
			GameViewCanvas(self.window)
		)
		# self.canvas.startRefreshTimer(self.nonActiveFPS)
		self.paused = None

		tool = self.window.addWidget(QtWidgets.QToolBar(self.window), expanding=False)
		self.qtool = tool
		self.toolbar = self.addToolBar('game_preview', tool)

		self.canvas.module = self

		self.updateTimer = None
		self.window.setFocusPolicy(Qt.StrongFocus)

		signals.connect('app.activate', self.onAppActivate)
		signals.connect('app.deactivate', self.onAppDeactivate)

		# signals.connect( 'game.pause',     self.onGamePause )
		# signals.connect( 'game.resume',    self.onGameResume )

		self.menu = self.addMenu('main/run', dict(label='Run'))

		self.menu.addChild([
			{'name': 'start_game', 'label': 'Start Game', 'shortcut': 'meta+]'},
			{'name': 'pause_game', 'label': 'Pause Game', 'shortcut': 'meta+shit+]'},
			{'name': 'stop_game', 'label': 'Stop Game', 'shortcut': 'meta+['},
			'----',
			{'name': 'next_frame', 'label': 'Next Frame', 'shortcut': 'f6'},
			'----',
			{'name': 'toggle_game_preview_window', 'label': 'Show Game Window', 'shortcut': 'f5'},
		], self)

		##----------------------------------------------------------------##
		# self.previewToolBar = self.addToolBar('game_preview_tools',
		#                                       self.getMainWindow().requestToolBar('view_tools')
		#                                       )

		# self.addTool(	'game_preview_tools/play',
		# 	widget = SceneToolButton( 'scene_view_selection',
		# 		icon = 'tools/selection',
		# 		label = 'Selection'
		# 		)
		# 	)
		#
		# self.addTool(	'game_preview_tools/stop',
		# 	widget = SceneToolButton( 'scene_view_translation',
		# 		icon = 'tools/translation',
		# 		label = 'Translation'
		# 		)
		# 	)

		# self.addTool('game_preview_tools/run_external',
		#              label='Play External',
		#              icon='tools/run_external',
		#              )
		#
		# self.addTool('game_preview_tools/run_game_external',
		#              label='Play Game External',
		#              icon='tools/run_game_external',
		#              )

		self.enableMenu('main/run/pause_game', False)
		self.enableMenu('main/run/stop_game', False)
		self.enableMenu('main/run/next_frame', False)

		self.onMoaiReset()

	def onStart(self):
		pass

	def onAppReady(self):
		pass

	def onStop(self):
		if self.updateTimer:
			self.updateTimer.stop()

	def show(self):
		self.window.show()

	def hide(self):
		self.window.hide()

	def refresh(self):
		self.canvas.updateGL()

	def resizeView(self, w, h):
		self.viewWidth = w
		self.viewHeight = h
		getAKU().setScreenSize(w, h)
		getAKU().setViewSize(w, h)

	def renderView(self):
		w = self.viewWidth
		h = self.viewHeight
		print(w, h)
		runtime = self.getRuntime()
		getAKU().setViewSize(w, h)
		runtime.changeRenderContext('game', w, h)
		runtime.renderAKU()

	def onSetFocus(self):
		self.window.show()
		self.window.raise_()
		self.window.setFocus()
		self.canvas.setFocus()
		self.canvas.activateWindow()
		self.setActiveWindow(self.window)

	def startPreview(self):
		if self.paused == False: return
		self.canvas.setInputDevice(self.getRuntime().getInputDevice('device'))
		self.canvas.startTick()
		self.getApp().setMinimalMainLoopBudget()

		self.enableMenu('main/run/pause_game', True)
		self.enableMenu('main/run/stop_game', True)
		self.enableMenu('main/run/start_game', False)
		self.enableMenu('main/run/next_frame', False)

		if self.paused:  # resume
			logging.info('resume game preview')
			# signals.emitNow('preview.resume')

		elif self.paused is None:  # start
			logging.info('start game preview')
			# signals.emitNow('preview.start')
			# signals.emitNow('preview.resume')
			entryScript = self.getProject().getScriptLibPath('main.lua')
			import os
			if os.path.exists(entryScript):
				# self.getRuntime().setWorkingDirectory(self.getProject().getPath() + "/game")
				self.getRuntime().getRuntimeEnv()['SCREEN_WIDTH'] = self.canvas.size().width()
				self.getRuntime().getRuntimeEnv()['SCREEN_HEIGHT'] = self.canvas.size().height()
				getAKU().runScript(entryScript)

		self.window.setWindowTitle('Game [ RUNNING ]')
		self.qtool.setStyleSheet('QToolBar{ border-top: 1px solid rgb(0, 120, 0); }')
		self.paused = False
		self.setFocus()
		logging.info('game preview started')

	def pausePreview(self):
		if self.paused: return
		# jhook = self.getModule('joystick_hook')
		# if jhook: jhook.setInputDevice(None)

		self.getApp().resetMainLoopBudget()

		# signals.emitNow('preview.pause')
		logging.info('pause game preview')
		self.enableMenu('main/run/start_game', True)
		self.enableMenu('main/run/pause_game', False)
		self.enableMenu('main/run/next_frame', True)

		self.window.setWindowTitle('Game [ Paused ]')
		self.qtool.setStyleSheet('QToolBar{ border-top: 1px solid rgb(255, 255, 0); }')

		self.paused = True
		self.canvas.stopTick()

	def stopPreview(self):
		if self.paused is None: return
		logging.info('stop game preview')
		# jhook = self.getModule('joystick_hook')
		# if jhook: jhook.setInputDevice(None)

		self.getApp().resetMainLoopBudget()

		# signals.emitNow('preview.stop')
		self.enableMenu('main/run/stop_game', False)
		self.enableMenu('main/run/pause_game', False)
		self.enableMenu('main/run/start_game', True)
		self.enableMenu('main/run/next_frame', False)

		self.window.setWindowTitle('Game')
		self.qtool.setStyleSheet('QToolBar{ border-top: none; }')

		self.paused = None
		self.canvas.stopTick()

		self.getRuntime().reset()
		self.onMoaiReset()
		self.refresh()
		logging.info('game preview stopped')

	def onMoaiReset(self):
		runtime = self.getRuntime()
		runtime.createRenderContext('game')
		runtime.addDefaultInputDevice('device')

	def onAppActivate(self):
		if self.waitActivate:
			self.waitActivate = False
			self.getRuntime().resume()

	def onAppDeactivate(self):
		if self.getConfig('pause_on_leave', False):
			self.waitActivate = True
			self.getRuntime().pause()

	def onMenu(self, node):
		name = node.name
		if name == 'size_double':
			if self.originalSize:
				w, h = self.originalSize
				self.tryResizeContainer(w * 2, h * 2)

		elif name == 'size_original':
			if self.originalSize:
				w, h = self.originalSize
				self.tryResizeContainer(w, h)

		elif name == 'reset_moai':
			# TODO: dont simply reset in debug
			# self.restartScript( self.runningScript )
			self.getRuntime().reset()

		elif name == 'orient_portrait':
			self.setOrientationPortrait()

		elif name == 'orient_landscape':
			self.setOrientationLandscape()

		elif name == 'start_game':
			self.startPreview()

		elif name == 'stop_game':
			self.stopPreview()

		elif name == 'pause_game':
			self.pausePreview()

		elif name == 'next_frame':
			self.canvas.simStep()
			self.canvas.updateGL()

		elif name == 'toggle_game_preview_window':
			self.window.show()

	def onTool(self, tool):
		name = tool.name
		if name == 'switch_screen_profile':
			pass

		elif name == 'run_external':
			self.runSceneExternal()

		elif name == 'run_game_external':
			self.runGameExternal()


##----------------------------------------------------------------##
# input sensors IDs
KEYBOARD, POINTER, MOUSE_LEFT, MOUSE_MIDDLE, MOUSE_RIGHT, TOTAL = range(0, 6)

class GameViewCanvas(QtOpenGL.QGLWidget):
	windowReady = False
	inputDevice = None
	buttonCount = 0

	def __init__(self, parent=None, **option):
		QtOpenGL.QGLWidget.__init__(self, parent)
		self.setSizePolicy(QtWidgets.QSizePolicy.Ignored, QtWidgets.QSizePolicy.Ignored)
		self.setFocusPolicy(QtCore.Qt.ClickFocus)
		self.setMouseTracking(True)

		self.refreshContext()

		timer = QtCore.QTimer(self)
		timer.timeout.connect(self.simStep)
		timer.timeout.connect(self.updateGL)
		self.timer = timer

	def setInputDevice(self, device):
		self.inputDevice = device

	def startTick(self, fps=60):
		self.timer.start(1000 / fps)
		self.timer.setInterval(1000 / fps)

	def stopTick(self):
		self.timer.stop()

	def resizeGL(self, w, h):
		if self.windowReady:
			logging.info('Game resizeGL ( %d x %d )' % (w, h))
			getAKU().setScreenSize(w, h)
			getAKU().setViewSize(w, h)

	def paintGL(self):
		if self.windowReady:
			getAKU().render()

	def simStep(self):
		if self.windowReady:
			getAKU().update()

	# Game Management API
	def refreshContext(self):

		# getAKU().resetContext()

		# getAKU().setInputConfigurationName('Game')
		# #
		# getAKU().reserveInputDevices(1)
		# getAKU().setInputDevice(0, "device")
		#
		# getAKU().reserveInputDeviceSensors(0, TOTAL)
		# getAKU().setInputDeviceKeyboard(0, KEYBOARD, "keyboard")
		# getAKU().setInputDevicePointer(0, POINTER, "pointer")
		# getAKU().setInputDevicePointer(0, MOUSE_LEFT, "mouseLeft")
		# getAKU().setInputDevicePointer(0, MOUSE_MIDDLE, "mouseMiddle")
		# getAKU().setInputDevicePointer(0, MOUSE_RIGHT, "mouseRight")

		getAKU().runString(
			"MOAIEnvironment.setValue('horizontalResolution', %d) MOAIEnvironment.setValue('verticalResolution', %d)" %
			(int(self.size().width()), int(self.size().height())))
		# AKUSetWorkingDirectory()

		self.lua = getAKU().getLuaRuntime()

		getAKU().setFuncOpenWindow(self.openWindow)

	def openWindow(self, title, width, height):
		self.makeCurrent()
		getAKU().detectGfxContext()

		w = self.size().width()
		h = self.size().height()

		getAKU().setScreenSize(w, h)
		getAKU().setViewSize(w, h)

		self.windowReady = True

	# Input
	def mousePressEvent(self, event):
		inputDevice = self.inputDevice
		if not inputDevice: return
		button = event.button()
		if self.buttonCount == 0:
			self.grabMouse()
		self.buttonCount += 1
		inputDevice.getSensor('pointer').enqueueEvent(event.x(), event.y())
		if button == Qt.LeftButton:
			inputDevice.getSensor('mouseLeft').enqueueEvent(True)
		elif button == Qt.RightButton:
			inputDevice.getSensor('mouseRight').enqueueEvent(True)
		elif button == Qt.MiddleButton:
			inputDevice.getSensor('mouseMiddle').enqueueEvent(True)

	def mouseReleaseEvent(self, event):
		inputDevice = self.inputDevice
		if not inputDevice: return
		self.buttonCount -= 1
		if self.buttonCount == 0:
			self.releaseMouse()
		button = event.button()
		inputDevice.getSensor('pointer').enqueueEvent(event.x(), event.y())
		if button == Qt.LeftButton:
			inputDevice.getSensor('mouseLeft').enqueueEvent(False)
		elif button == Qt.RightButton:
			inputDevice.getSensor('mouseRight').enqueueEvent(False)
		elif button == Qt.MiddleButton:
			inputDevice.getSensor('mouseMiddle').enqueueEvent(False)

	def mouseMoveEvent(self, event):
		inputDevice = self.inputDevice
		if not inputDevice: return
		inputDevice.getSensor('pointer').enqueueEvent(event.x(), event.y())

	def keyPressEvent(self, event):
		if event.isAutoRepeat(): return
		inputDevice = self.inputDevice
		if not inputDevice: return
		key = event.key()
		inputDevice.getSensor('keyboard').enqueueKeyEvent(convertKeyCode(key), True)

	def keyReleaseEvent(self, event):
		inputDevice = self.inputDevice
		if not inputDevice: return
		key = event.key()
		inputDevice.getSensor('keyboard').enqueueKeyEvent(convertKeyCode(key), False)


##----------------------------------------------------------------##
GameView().register()


def convertKeyCode(k):
	if k > 1000:
		return (k & 0xff) + (255 - 0x55)
	else:
		return k
