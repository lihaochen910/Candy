from PyQt5.QtCore import Qt, QPoint, QEvent
from PyQt5.QtWidgets import QWidget, QSizePolicy, QDialog, QApplication, QGridLayout, qApp


class CEditorDialog ( QDialog ):

	def __init__ ( self, dialogNameId, parent = None, saveSize = True ):
		super ().__init__ ( parent if parent else QApplication.activeWindow (),
		                    Qt.WindowTitleHint | Qt.WindowSystemMenuHint | Qt.WindowCloseButtonHint | Qt.FramelessWindowHint )
		self.dialogNameId = dialogNameId
		self.layoutWrapped = False
		self.titleBar = None
		self.grid = None
		self.saveSize = saveSize
		self.resizable = True
		self.canClose = True

		self.setSizeGripEnabled ( False )
		if not self.saveSize:
			return

	# TODO: AddPersonalizedSharedProperty

	def getDialogName ( self ):
		return self.dialogNameId

	def setResizable ( self, resizable ):
		if resizable != self.resizable:
			self.resizable = resizable
			if not self.resizable:
				self.setFocusPolicy ( QSizePolicy.Preferred, QSizePolicy.Preferred )

	def execute ( self ):
		return self.exec_ () == QDialog.Accepted

	def raise_ ( self ):
		if self.window ():
			self.window ().raise_ ()

	def popup ( self, position, size ):
		if position and size:
			self.resize ( size )
			self.popup ()
			if self.window ():
				self.window ().move ( position )
		else:
			self.show ()
			self.raise_ ()

	def setPosCascade ( self ):
		if self.window ():
			if self.i == None:
				self.i = 0
			self.window ().move ( QPoint ( 32, 32 ) * (self.i + 1) )
			self.i = (self.i + 1) % 10

	def setHideOnClose ( self ):
		onDialogFinished = lambda: self.hide ()
		self.connectNotify ( QDialog.finished, onDialogFinished )

	# TODO: check self.connect

	def setDoNotClose ( self ):
		flags = self.windowFlags ()
		self.setWindowFlags ( flags & ~Qt.WindowCloseButtonHint )
		self.canClose = False

	def setTitle ( self, title ):
		self.setWindowTitle ( title )

	def changeEvent ( self, event ):
		if event.type () == QEvent.WindowStateChange and self.layoutWrapped:
			if self.windowState () == Qt.WindowMaximized:
				self.grid.setRowMinimumHeight ( 0, 0 )
				self.grid.setRowMinimumHeight ( 2, 0 )
				self.grid.setColumnMinimumWidth ( 0, 0 )
				self.grid.setColumnMinimumWidth ( 2, 0 )
			else:
				self.grid.setRowMinimumHeight ( 0, 4 )
				self.grid.setRowMinimumHeight ( 2, 4 )
				self.grid.setColumnMinimumWidth ( 0, 4 )
				self.grid.setColumnMinimumWidth ( 2, 4 )
		QWidget.changeEvent ( event )

	def showEvent ( self, event ):
		if not self.layoutWrapped:
			self.grid = QGridLayout ()
			self.grid.setSpacing ( 0 )
			self.grid.setContentsMargins ( 0, 0, 0, 0 )
			from qt.controls.QToolWindowManager.SandboxWindowing import QSandboxTitleBar
			self.titleBar = QSandboxTitleBar ( { } )
			self.grid.addWidget ( self.titleBar, 0, 0, 1, 3 )
			self.grid.setRowMinimumHeight ( 0, 4 )
			self.grid.setRowMinimumHeight ( 2, 4 )
			self.grid.setColumnMinimumWidth ( 0, 4 )
			self.grid.setColumnMinimumWidth ( 2, 4 )
			w = QWidget ( self )
			w.setLayout ( self.layout () )
			w.setSizePolicy ( QSizePolicy.Expanding, QSizePolicy.Expanding )
			self.grid.addWidget ( w, 1, 1 )
			self.setLayout ( self.grid )
			self.layoutWrapped = True

		QDialog.showEvent ( event )

		if self.layoutWrapped:
			p = self.pos ()
			self.move ( p + QPoint ( 1, 0 ) )
			qApp.processEvents ()
			self.move ( p )

	# def nativeEvent ( self, Union, QByteArray = None, bytes = None, bytearray = None, *args, **kwargs ):
	# 	# TODO: WIN32/64

	def keyPressEvent ( self, keyEvent ):
		if self.canClose or keyEvent.key () != Qt.Key_Escape:
			QDialog.keyPressEvent ( keyEvent )
