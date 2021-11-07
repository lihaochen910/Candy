from PyQt5.QtWidgets import *
from PyQt5.QtGui import QPixmap
from PyQt5 import uic, QtCore
from candy_editor import qt
from candy_editor.core.project import Project

def openProject(parent):
	path = QFileDialog.getExistingDirectory(parent, 'Select Project Folder', './')
	result = Project.get().load(path)
	if result:
		print ( 'open Project OK!' )
		parent.close()
	else:
		from candy_editor.qt.dialogs.Dialogs import alertMessage
		alertMessage("Error", path + "\nisn't a valid Candy Project.")

def createProject(parent):
	directory = QFileDialog.getExistingDirectory(parent, 'Create a Project Folder', './')
	array = directory.split("\\")
	result = Project.get().init(directory, array[len(array) - 1])
	if result:
		print ( 'create OK!' )
		parent.close()
	else:
		from candy_editor.qt.dialogs.Dialogs import alertMessage
		alertMessage("Error", "Project.init() return False")

def launch():
	import sys

	app = QApplication(sys.argv)

	widget = uic.loadUi('./packages/WelcomeScreen/form.ui', None)
	widget.setWindowTitle('Candy Launcher')
	# widget.setWindowIcon(QIcon(QPixmap('icon.png')))
	# widget.setWindowFlags(Qt.FramelessWindowHint)
	widget.content.setContentsMargins(0,0,0,0)
	widget.setFixedSize(600, 260)
	widget.image.resize(600, 200)
	widget.image.setPixmap(QPixmap('./packages/WelcomeScreen/logo.png'))
	widget.openProjectBtn.clicked.connect(lambda: openProject(widget))
	widget.createProjectBtn.clicked.connect(lambda: createProject(widget))

	widget.show()

	app.exec_()

