import logging

from PyQt5 import QtGui, QtCore, QtWidgets
from PyQt5.QtWidgets import QDialog, QMessageBox, QFileDialog, QInputDialog


class StringDialog ( QDialog ):
	
	def __init__ ( self, prompt, *args ):
		super ( StringDialog, self ).__init__ ( *args )
		lineEdit = QtWidgets.QLineEdit ( self )
		self.setWindowTitle ( prompt )
		btnOK = QtWidgets.QPushButton ( 'OK' )
		btnCancel = QtWidgets.QPushButton ( 'Cancel' )
		
		buttonBox = QtGui.QDialogButtonBox ( QtCore.Qt.Horizontal )
		buttonBox.addButton ( btnOK, QtGui.QDialogButtonBox.AcceptRole )
		buttonBox.addButton ( btnCancel, QtGui.QDialogButtonBox.RejectRole )
		buttonBox.accepted.connect ( self.accept )
		buttonBox.rejected.connect ( self.reject )

		box = QtWidgets.QVBoxLayout ()
		self.setLayout ( box )

		box.addWidget ( lineEdit )
		box.addWidget ( buttonBox )

		self.lineEdit = lineEdit

	def getText ( self ):
		return self.lineEdit.text ()
	
def requestConfirm ( title, msg, level='normal' ):
	f = None
	if level == 'warning':
		f = QMessageBox.warning
	elif level == 'critical':
		f = QMessageBox.critical
	else:
		f = QMessageBox.question
	res = f ( None, title, msg, QMessageBox.Yes | QMessageBox.No | QMessageBox.Cancel )
	if res == QMessageBox.Yes:    return True
	if res == QMessageBox.Cancel: return None
	if res == QMessageBox.No:     return False

def alertMessage ( title, msg, level='warning' ):
	f = None
	if level == 'warning':
		f = QMessageBox.warning
		logging.warning ( msg  )

	elif level == 'critical':
		f = QMessageBox.critical
		logging.error ( msg  )

	elif level == 'question':
		f = QMessageBox.question

	else:
		f = QMessageBox.information
	res = f ( None, title, msg	 )

def requestString ( title, prompt, defaultValue = '' ):
	text, ok = QInputDialog.getText ( None, title, prompt, QtWidgets.QLineEdit.Normal, defaultValue  )
	# dialog=StringDialog ( prompt )
	# dialog.move ( QtGui.QCursor.pos () )
	# if dialog.exec_ ():
	# 	return dialog.getText ()
	# else:
	# 	return None
	if ok:
		return text
	else:
		return None

def requestColor ( prompt, initColor = None, **kwargs ):
	dialog = QtGui.QColorDialog ( initColor or QtCore.Qt.white  )
	dialog.move ( QtGui.QCursor.pos ()  )
	dialog.setWindowTitle ( prompt  )
	onColorChanged = kwargs.get ( 'onColorChanged', None  )
	if onColorChanged:
		dialog.currentColorChanged.connect ( onColorChanged  )
	if dialog.exec_ () == 1:
		col = dialog.currentColor ()
		# dialog.destroy ()
		if col.isValid (): return col
	return initColor

def requestSaveFile ( parentContainer, title, sourcePath, filter = 'All Files  ( * )' ):
	fileName = QFileDialog.getSaveFileName ( parentContainer, title, sourcePath, filter )
	return fileName

def requestOpenFile ( parentContainer, title, sourcePath, filter = 'All Files  ( * )' ):
	fileName, filetype = QFileDialog.getOpenFileName ( parentContainer, title, sourcePath, filter )
	return fileName, filetype

def requestOpenDir ( parentContainer, title, sourcePath ):
	dir_choose = QFileDialog.getExistingDirectory ( parentContainer, title, sourcePath )
	return dir_choose

def requestOpenFileOrDir ( parent=None, caption='', directory='',
                        filter='All Files  ( * )', initialFilter='', options=None ):
	def updateText ():
		# update the contents of the line edit widget with the selected files
		selected = []
		for index in view.selectionModel ().selectedRows ():
			selected.append ( '"{}"'.format ( index.data () ) )
		lineEdit.setText ( ' '.join ( selected ) )

	dialog = QFileDialog ( parent, caption = caption )
	dialog.setFileMode ( QFileDialog.ExistingFiles )
	if options:
		dialog.setOptions ( options )
	dialog.setOption ( QFileDialog.DontUseNativeDialog, True )
	if directory:
		dialog.setDirectory ( directory )
	if filter:
		dialog.setNameFilter ( filter )
		if initialFilter:
			dialog.selectNameFilter ( initialFilter )

	# by default, if a directory is opened in file listing mode,
	# QFileDialog.accept() shows the contents of that directory, but we
	# need to be able to "open" directories as we can do with files, so we
	# just override accept() with the default QDialog implementation which
	# will just return exec_()
	dialog.accept = lambda: QtWidgets.QDialog.accept ( dialog )

	# there are many item views in a non-native dialog, but the ones displaying
	# the actual contents are created inside a QStackedWidget; they are a
	# QTreeView and a QListView, and the tree is only used when the
	# viewMode is set to QFileDialog.Details, which is not this case
	stackedWidget = dialog.findChild ( QtWidgets.QStackedWidget )
	view = stackedWidget.findChild ( QtWidgets.QListView )
	view.selectionModel ().selectionChanged.connect ( updateText )

	lineEdit = dialog.findChild ( QtWidgets.QLineEdit )
	# clear the line edit contents whenever the current directory changes
	dialog.directoryEntered.connect ( lambda: lineEdit.setText ( '' ) )

	dialog.exec_ ()
	return dialog.selectedFiles ()

	# col = None
	# if initCol: 
	# 	col = QtGui.QColor ( initCol )
	# else:
	# 	col = QtCore.Qt.white
	# 	if onColorChanged:
	# 		currentColorChanged
	# col = QtGui.QColorDialog.getColor ( 
	# 	col, 
	# 	None,
	# 	prompt,
	# 	QtGui.QColorDialog.ShowAlphaChannel
	# 	 )
	# if col.isValid (): return col
	# return None

