import tempfile
import os
import sys
import logging
import time

from PyQt5 import QtCore, QtGui, uic
from PyQt5.QtCore import Qt, QEvent, QObject

from core       import getAppPath
from core       import signals
from sceneEditor import SceneEditorModule

# import ui_console

signals.register('console.exec')

##----------------------------------------------------------------##
class StdoutCapture():
	def __init__(self):
		self.prevfd = None
		self.prev = None

		self.file = file = tempfile.NamedTemporaryFile()
		self.where = file.tell()

		sys.stdout.flush()
		self.prevfd = os.dup(sys.stdout.fileno())
		os.dup2(file.fileno(), sys.stdout.fileno())
		self.prev = sys.stdout
		sys.stdout = os.fdopen(self.prevfd, "w")

	def stop(self):
		os.dup2(self.prevfd, self.prev.fileno())
		sys.stdout = self.prev
		self.file.close()

	def read(self):
		file=self.file
		file.seek(self.where)
		output=None
		while True:
			line = file.readline()
			if not line:
				self.where = file.tell()
				return output
			else:
				if not output: output=''
				output+=line
		
class Console( SceneEditorModule ):
	name       = 'console'
	# dependency = 'debug_view'

	def write(self,text):
		self.panel.appendText(text)		

	def onLoad(self):
		self.container = self.requestDockWindow('Console',
				title   = 'Console',
				minSize = (100,100),
				dock    = 'bottom'
			)
		self.panel = self.container.addWidget(
				ConsoleWindow()
			)
		self.panel.module = self
		self.stdoutCapture = StdoutCapture()
		self.stdoutFile = self.stdoutCapture.file
		self.refreshTimer = self.container.startTimer( 10, self.doRefresh)
		sys.stdout = self

	def doRefresh(self):
		if self.alive:
			self.panel.appendText(self.stdoutCapture.read())
			# import datetime
			# print(datetime.datetime.now())

	def onStart( self ):
		self.container.show()

	def onUnload(self):
		pass

##----------------------------------------------------------------##
# class ConsoleWindow( QtWidgets.QWidget, ui_console.Ui_ConsoleWindow ):
class ConsoleWindow( QtWidgets.QWidget ):
	"""docstring for ConsoleWindow"""
	COLOR_WHITE = QtGui.QColor(255, 255, 255)
	COLOR_RED = QtGui.QColor(255, 0, 0)
	COLOR_YELLOW = QtGui.QColor(255, 255, 0)

	def __init__(self):
		super(ConsoleWindow, self).__init__()

		# self.setupUi(self)

		self.history = []
		self.historyCursor = 0

		self.loggingHandler = ConsoleLogHandler()
		self.loggingHandler.setListener(self.handleOnLoggingEmit)

		uic.loadUi(getAppPath('packages/EditorConsole/console.ui'), self)

		self.luaLogTabLayout.setSpacing(2)

		self.buttonExec = QtWidgets.QPushButton(self)
		self.buttonExec.setObjectName("buttonExec")
		self.buttonExec.setText('exec')
		self.luaLogTabLayout.addWidget(self.buttonExec)
		self.buttonClear = QtWidgets.QPushButton(self)
		self.buttonClear.setObjectName("buttonClear")
		self.buttonClear.setText('clr')
		self.luaLogTabLayout.addWidget(self.buttonClear)

		self.buttonExec.clicked.connect(self.execCommand)
		self.buttonClear.clicked.connect(self.clearText)		
		
		self.luaConsoleInput.installEventFilter(self)
		self.luaConsoleInput.setFocusPolicy(Qt.StrongFocus)
		self.setFocusPolicy(Qt.StrongFocus)

	def eventFilter(self, obj, event):
		if event.type() == QEvent.KeyPress:
			if self.inputKeyPressEvent(event):
				return True

		return QObject.eventFilter(self, obj, event)

	def inputKeyPressEvent(self, event):
		key=event.key()
		if key == Qt.Key_Down: #next cmd history
			self.nextHistory()
		elif key == Qt.Key_Up: #prev
			self.prevHistory()
		elif key == Qt.Key_Escape: #clear
			self.luaConsoleInput.clear()
		elif key == Qt.Key_Return or key == Qt.Key_Enter:
			self.execCommand()
		else:
			return False
		return True

	def handleOnLoggingEmit(self, msg, level):
		timeStamp = time.strftime("%H:%M:%S", time.localtime())
		content = (' [%s] ' % (level)) + msg + '\n'

		# coloredText = None
		# if level == 'WARNING':
		# 	coloredText = ("<span style=\" color:#ffff00;\" >%s</span>" % (content))
		# elif level == 'ERROR':
		# 	coloredText = ("<span style=\" color:#ff0000;\" >%s</span>" % (content))
		# else: coloredText = content

		self.editorLogOutput.setTextColor(self.COLOR_WHITE)
		self.editorLogOutput.append(timeStamp)

		if level == 'WARNING':
			self.editorLogOutput.setTextColor(self.COLOR_YELLOW)
			self.editorLogOutput.insertPlainText(content)
		elif level == 'ERROR':
			self.editorLogOutput.setTextColor(self.COLOR_RED)
			self.editorLogOutput.insertPlainText(content)
		else:   self.editorLogOutput.insertPlainText(content)

		self.editorLogOutput.setTextColor(self.COLOR_WHITE)
		# self.editorLogOutput.insertPlainText(coloredText)
		self.editorLogOutput.moveCursor(QtGui.QTextCursor.End)

	def execCommand(self):
		text = self.luaConsoleInput.text()
		self.history.append(text)
		if len(self.history) > 10: self.history.pop(1)
		self.historyCursor=len(self.history)
		self.luaConsoleInput.clear()
		self.appendText(self.module.stdoutCapture.read())
		self.appendText(">>")
		self.appendText(text)
		self.appendText("\n")

		signals.emit('console.exec', text.encode('utf-8'))

	def prevHistory(self):
		count=len(self.history)
		if count == 0: return
		self.historyCursor = max(self.historyCursor-1, 0)
		self.luaConsoleInput.setText(self.history[self.historyCursor])

	def nextHistory(self):
		count=len(self.history)
		if count<= self.historyCursor:
			self.historyCursor=count-1
			self.luaConsoleInput.clear()
			return
		self.historyCursor = min(self.historyCursor+1, count-1)
		if self.historyCursor<0: return
		self.luaConsoleInput.setText(self.history[self.historyCursor])

	def appendText(self, text):
		if not text: return
		self.luaConsoleOutput.insertPlainText(text)
		self.luaConsoleOutput.moveCursor(QtGui.QTextCursor.End)

	def clearText(self):
		self.luaConsoleOutput.clear()

class ConsoleLogHandler( logging.Handler ):
	listener = False

	def __init__(self):
		logging.Handler.__init__(self)

		logging.getLogger().addHandler(self)
		logging.getLogger().setLevel(logging.INFO)

	def setListener(self, listener):
		self.listener = listener

	def emit(self, record):
		# print(str(type(record)))
		msg = self.format(record)

		if not msg: return
		self.listener(msg, record.levelname)
