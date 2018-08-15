import tempfile
import os
import sys

from PyQt4 import QtCore, QtGui, uic
from PyQt4.QtCore import Qt, QEvent, QObject

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
# class ConsoleWindow( QtGui.QWidget, ui_console.Ui_ConsoleWindow ):
class ConsoleWindow( QtGui.QWidget):
	"""docstring for ConsoleWindow"""
	def __init__(self):
		super(ConsoleWindow, self).__init__()
		
		# self.setupUi(self)

		self.history = []
		self.historyCursor = 0

		uic.loadUi(getAppPath('packages/EditorConsole/console.ui'), self)

		self.luaLogTabLayout.setSpacing(2)

		self.buttonExec = QtGui.QPushButton(self)
		self.buttonExec.setObjectName("buttonExec")
		self.buttonExec.setText('exec')
		self.luaLogTabLayout.addWidget(self.buttonExec)
		self.buttonClear = QtGui.QPushButton(self)
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

