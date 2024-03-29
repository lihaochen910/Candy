import logging

from core import app, RemoteCommand
import signals

from candy_editor.moai.MOAIRuntime import getAKU
from candy_editor.moai.MOAICanvasBase import MOAICanvasBase
# from gii.moai.MOAIEditCanvas import MOAIEditCanvas

# from gii.qt.dialogs          import ProcessDialog

from PyQt5 import QtCore
from PyQt5.QtCore import Qt

from SceneEditor import SceneEditorModule
# import ExternRun

##----------------------------------------------------------------##
class GamePreview ( SceneEditorModule ):
	"""docstring for GamePreview"""

	def __init__ ( self ):
		super ( GamePreview, self ).__init__ ()
		self.paused         = False
		self.waitActivate   = False
		self.viewWidth      = 0
		self.viewHeight     = 0
		self.pendingScript  = None
		self.activeFPS      = 60
		self.nonActiveFPS   = 15

	def getName ( self ):
		return 'game_preview'

	def getDependency ( self ):
		return [ 'qt', 'moai', 'scene_editor' ]

	def getRuntime ( self ):
		return self.affirmModule ('moai')

	def tryResizeContainer (self, w,h):
		#TODO:client area
		return True		

	def setOrientationPortrait ( self ):
		if self.window.isFloating ():
			pass #TODO
		getAKU ().setOrientationPortrait ()

	def setOrientationLandscape ( self ):
		if self.window.isFloating ():
			pass #TODO
		getAKU ().setOrientationLandscape ()

	def onOpenWindow (self, title, w,h):
		logging.info ('opening MOAI window: %s @  (%d,%d)' %  ( str (title), w, h ) )
		print ('opening MOAI window: %s @  (%d,%d)' %  ( str (title), w, h ))
		#no argument accepted here, just use full window
		# self.getRuntime ().initGLContext ()
		from qt.controls.GLWidget import GLWidget
		GLWidget.getSharedWidget ().makeCurrent ()

		self.originalSize =  (w,h)
		self.tryResizeContainer ( *self.originalSize )

		size=self.canvas.size ()
		w,h = size.width (),size.height ()

		getAKU ().setScreenSize (w,h)
		getAKU ().setViewSize (w,h)


	def onLoad ( self ):
		self.window = self.requestToolWindow (
			'GamePreview',
			title = 'Game Preview',
			area  = 'right'
		)

		self.canvas = self.window.addWidget  (
			GamePreviewCanvas ( self.window )
		)
		self.canvas.startRefreshTimer ( self.nonActiveFPS )
		self.paused = None
		
		tool = self.window.addWidget ( QtWidgets.QToolBar ( self.window ), expanding = False )
		self.qtool = tool
		self.toolbar = self.addToolBar ( 'game_preview', tool )

		self.canvas.module = self

		self.updateTimer = None
		self.window.setFocusPolicy (Qt.StrongFocus)
		
		signals.connect ( 'app.activate', self.onAppActivate )
		signals.connect ( 'app.deactivate', self.onAppDeactivate )
		
		# signals.connect ( 'debug.enter',    self.onDebugEnter )
		# signals.connect ( 'debug.exit',     self.onDebugExit )
		# signals.connect ( 'debug.stop',     self.onDebugStop )
		
		# signals.connect ( 'game.pause',     self.onGamePause )
		# signals.connect ( 'game.resume',    self.onGameResume )
		signals.connect ( 'moai.reset', self.onMoaiReset )
		
		self.menu = self.addMenu ( 'main/preview', dict ( label = 'Game' ) )

		self.menu.addChild ([
				{'name':'start_game',  'label':'Resume Preview', 'shortcut':'meta+]' },
				{'name':'pause_game',  'label':'Pause Preview',  'shortcut':'meta+shit+]' },
				{'name':'stop_game',   'label':'Stop Preview',   'shortcut':'meta+[' },
				'----',
				{'name':'start_external_scene',  'label':'Run Scene',  'shortcut':'meta+alt+]' },
				{'name':'start_external_game',   'label':'Run Game',  'shortcut':'meta+alt+shift+]' },
				'----',
				{'name':'pause_on_leave', 'label':'Pause On Leave', 'type':'check', 'checked':self.getConfig ('pause_on_leave')},
				# '----',
				# {'name':'reset_moai',     'label':'RESET MOAI', 'shortcut':'Ctrl+Shift+R'}
				'----',
				{'name': 'toggle_game_preview_window', 'label': 'Show Game Preview', 'shortcut': 'f4'},
			], self)

		# label = QtWidgets.QLabel ()
		# label.setMinimumSize ( 300, 20 )
		# label.setMaximumSize ( 300, 20 )
		# self.toolbar.addWidget ( label )
		# self.labelScreen = label
		# self.addTool ( 'game_preview/----' )
		# self.addTool ( 'game_preview/toggle_stay_top', label = 'Stay Top', type = 'check' )
		# self.addTool ( 'game_preview/switch_screen_profile', label = 'Screen Profile' )
		self.onMoaiReset ()

		##----------------------------------------------------------------##
		self.previewToolBar = self.addToolBar ( 'game_preview_tools', 
			self.getMainWindow ().requestToolBar ( 'view_tools' )
		)

		# self.addTool (	'game_preview_tools/play',
		# 	widget = SceneToolButton ( 'scene_view_selection',
		# 		icon = 'tools/selection',
		# 		label = 'Selection'
		# 		)
		# 	)
		#
		# self.addTool (	'game_preview_tools/stop',
		# 	widget = SceneToolButton ( 'scene_view_translation',
		# 		icon = 'tools/translation',
		# 		label = 'Translation'
		# 		)
		# 	)

		self.addTool  ( 'game_preview_tools/run_external',
			label = 'Play External',
			icon = 'tools/run_external',
		)

		self.addTool  ( 'game_preview_tools/run_game_external',
			label = 'Play Game External',
			icon = 'tools/run_game_external',
		)

		self.enableMenu ( 'main/preview/pause_game',  False )
		self.enableMenu ( 'main/preview/stop_game',   False )

	def onStart ( self ):
		pass

	def onAppReady ( self ):
		pass

	def onStop ( self ):
		if self.updateTimer:
			self.updateTimer.stop ()

	def show ( self ):
		self.window.show ()

	def hide ( self ):
		self.window.hide ()

	def refresh ( self ):
		self.canvas.updateGL ()

	def updateView ( self ):
		if self.paused: return
		w = self.viewWidth
		h = self.viewHeight
		runtime = self.getRuntime ()
		# runtime.setBufferSize ( w, h )
		runtime.changeRenderContext ( 'game', w, h )
		if runtime.updateAKU ():
			self.canvas.forceUpdateGL ()


	def resizeView (self, w,h):
		self.viewWidth  = w
		self.viewHeight = h
		getAKU ().setScreenSize (w,h)
		getAKU ().setViewSize (w,h)

	def renderView ( self ):
		w = self.viewWidth
		h = self.viewHeight
		runtime = self.getRuntime ()
		getAKU ().setViewSize ( w, h )
		# runtime.setBufferSize ( w, h )
		runtime.changeRenderContext ( 'game', w, h )
		runtime.renderAKU ()

	def onMoaiReset ( self ):
		runtime = self.getRuntime ()
		# runtime.createRenderContext ( 'game' )
		runtime.addDefaultInputDevice ( 'device' )
		# getAKU ().setFuncOpenWindow ( self.onOpenWindow )
	
	def onDebugEnter ( self ):
		self.paused = True
		self.getRuntime ().pause ()
		self.window.setFocusPolicy (Qt.NoFocus)

	def onDebugExit ( self, cmd=None ):
		self.paused=False
		self.getRuntime ().resume ()
		self.window.setFocusPolicy (Qt.StrongFocus)
		if self.pendingScript:
			script = self.pendingScript
			self.pendingScript=False
			self.restartScript (script)
		self.setFocus ()
		
	def onDebugStop ( self ):
		self.paused=True

	def onSetFocus ( self ):
		self.window.show ()
		self.window.raise_ ()
		self.window.setFocus ()
		self.canvas.setFocus ()
		self.canvas.activateWindow ()
		self.setActiveWindow ( self.window )

	def startPreview ( self ):
		if self.paused == False: return
		runtime = self.getRuntime ()
		runtime.changeRenderContext ( 'game', self.viewWidth, self.viewHeight )
		self.canvas.setInputDevice ( runtime.getInputDevice ('device') )
		self.canvas.startRefreshTimer ( self.activeFPS )
		self.canvas.interceptShortcut = True
		self.getApp ().setMinimalMainLoopBudget ()
		# jhook = self.getModule ( 'joystick_hook' )
		# if jhook:
		# 	jhook.refreshJoysticks ()
		# 	jhook.setInputDevice ( runtime.getInputDevice ('device') )

		self.enableMenu ( 'main/preview/pause_game', True )
		self.enableMenu ( 'main/preview/stop_game',  True )
		self.enableMenu ( 'main/preview/start_game', False )

		if self.paused: #resume
			logging.info ('resume game preview')
			signals.emitNow ( 'preview.resume' )

		elif self.paused is None: #start
			logging.info ('start game preview')
			signals.emitNow ( 'preview.start' )
			signals.emitNow ( 'preview.resume' )
			self.updateTimer = self.window.startTimer ( 60, self.updateView )

			getAKU ().setFuncOpenWindow (self.onOpenWindow)

		self.window.setWindowTitle ( 'Game Preview [ RUNNING ]')
		self.qtool.setStyleSheet ( 'QToolBar{ border-top: 1px solid rgb (0, 120, 0); }' )
		self.paused = False
		runtime.resume ()
		self.setFocus ()
		logging.info ('game preview started')

		entryScript = self.getProject ().getScriptLibPath ( 'main.lua' )
		import os
		if os.path.exists ( entryScript ):
			getAKU ().runScript ( entryScript )

	def pausePreview ( self ):
		if self.paused: return
		self.canvas.setInputDevice ( None )
		# jhook = self.getModule ('joystick_hook')
		# if jhook: jhook.setInputDevice (None)

		self.getApp ().resetMainLoopBudget ()

		signals.emitNow ( 'preview.pause' )
		logging.info ( 'pause game preview' )
		self.enableMenu ( 'main/preview/start_game', True )
		self.enableMenu ( 'main/preview/pause_game', False )

		self.window.setWindowTitle ( 'Game Preview[ Paused ]' )
		self.qtool.setStyleSheet ( 'QToolBar{ border-top: 1px solid rgb (255, 0, 0); }' )

		self.paused = True
		self.getRuntime ().pause ()
		self.canvas.startRefreshTimer ( self.nonActiveFPS )

	def stopPreview ( self ):
		if self.paused is None: return
		logging.info ('stop game preview')

		jhook = self.getModule ( 'joystick_hook' )
		if jhook: jhook.setInputDevice ( None )
		
		self.getApp ().resetMainLoopBudget ()

		signals.emitNow ( 'preview.stop' )
		self.updateTimer.stop ()
		self.enableMenu ( 'main/preview/stop_game',  False )
		self.enableMenu ( 'main/preview/pause_game', False )
		self.enableMenu ( 'main/preview/start_game', True )
		
		self.window.setWindowTitle ( 'Game Preview' )
		self.qtool.setStyleSheet ('QToolBar{ border-top: none; }')

		self.paused = None
		self.updateTimer = None
		self.canvas.startRefreshTimer ( self.nonActiveFPS )
		logging.info ('game preview stopped')

	
	def runGameExternal ( self ):
		#TODO: use a modal window to indicate external host state
		pass
		# ExternRun.runGame ( parent_window = self.getMainWindow () )

	def runSceneExternal ( self ):
		#TODO: use a modal window to indicate external host state
		scnEditor = self.getModule ( 'scenegraph_editor' )
		if scnEditor and scnEditor.activeSceneNode:
			path = scnEditor.activeSceneNode.getNodePath ()
			# ExternRun.runScene ( path, parent_window = self.getMainWindow () )



	def onAppActivate ( self ):
		if self.waitActivate:
			self.waitActivate=False
			self.getRuntime ().resume ()

	def onAppDeactivate ( self ):
		if self.getConfig ('pause_on_leave',False):
			self.waitActivate=True
			self.getRuntime ().pause ()

	def onMenu (self, node):
		name = node.name
		if name=='size_double':
			if self.originalSize:
				w,h=self.originalSize
				self.tryResizeContainer (w*2,h*2)

		elif name=='size_original':
			if self.originalSize:
				w,h=self.originalSize
				self.tryResizeContainer (w,h)

		elif name=='pause_on_leave':
			self.setConfig ( 'pause_on_leave', node.getValue ())

		elif name=='reset_moai':
			#TODO: dont simply reset in debug
			# self.restartScript ( self.runningScript )
			self.getRuntime ().reset ()

		elif name=='orient_portrait':
			self.setOrientationPortrait ()

		elif name=='orient_landscape':
			self.setOrientationLandscape ()

		elif name == 'start_game':
			self.startPreview ()

		elif name == 'stop_game':
			self.stopPreview ()

		elif name == 'pause_game':
			self.pausePreview ()

		elif name == 'start_external_scene':
			self.runSceneExternal ()
			
		elif name == 'start_external_game':
			self.runGameExternal ()

		elif name == 'toggle_game_preview_window':
			self.window.show ()
			# QtGui.QDockWidget ().show ()

	def onTool ( self, tool ):
		name = tool.name
		if name == 'switch_screen_profile':
			pass
			
		elif name == 'run_external':
			self.runSceneExternal ()

		elif name == 'run_game_external':
			self.runGameExternal ()

##----------------------------------------------------------------##
class GamePreviewCanvas ( MOAICanvasBase ):
	def __init__ ( self, *args, **kwargs ):
		super ( GamePreviewCanvas, self ).__init__ ( *args, **kwargs )
		self.interceptShortcut = False
		self.installEventFilter ( self )

	def eventFilter ( self, obj, ev ):
		if not self.interceptShortcut: return False
		if obj == self:
			etype = ev.type ()
			# if etype == QtCore.QEvent.KeyPress :
			# 	self.keyPressEvent ( ev )
			# 	return True
			# elif etype == QtCore.QEvent.KeyRelease :
			# 	self.keyReleaseEvent ( ev )
			# 	return True
			if etype == QtCore.QEvent.ShortcutOverride:
				self.keyPressEvent ( ev )
				ev.accept ()
				return True
		return False
		# return super ( GamePreviewCanvas, self ).eventFilter ( obj, ev )

	def resizeGL (self, width, height):
		self.module.resizeView (width,height)
		MOAICanvasBase.resizeGL ( self, width, height )

	def onDraw ( self ):
		self.module.renderView ()
		
##----------------------------------------------------------------##
GamePreview ().register ()
##----------------------------------------------------------------##

class RemoteCommandPreviewStart ( RemoteCommand ):
	name = 'preview_start'
	def run ( self, *args ):
		preview = app.getModule ('game_preview')
		preview.startPreview ()
		
class RemoteCommandPreviewStart ( RemoteCommand ):
	name = 'preview_stop'
	def run ( self, *args ):
		preview = app.getModule ('game_preview')
		preview.stopPreview ()

class RemoteCommandRunGame ( RemoteCommand ):
	name = 'run_game'
	def run ( self, *args ):
		preview = app.getModule ('game_preview')
		preview.runGameExternal ()
		
class RemoteCommandRunScene ( RemoteCommand ):
	name = 'run_scene'
	def run ( self, *args ):
		preview = app.getModule ('game_preview')
		preview.runSceneExternal ()
		