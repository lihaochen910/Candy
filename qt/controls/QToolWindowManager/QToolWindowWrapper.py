from PyQt5 import QtCore
from PyQt5.QtCore import QEvent
from PyQt5.QtWidgets import QWidget, QVBoxLayout

from qt.controls.QToolWindowManager.QToolWindowManagerCommon import *


class QToolWindowWrapper ( QWidget ):

	def __init__ ( self, manager, flags = 0 ):
		super ().__init__ ( None )
		self.manager = manager
		self.contents = None

		if self.manager:
			self.manager.installEventFilter ( self )
			self.setStyleSheet ( self.manager.styleSheet () )

			if manager.config.setdefault( QTWM_WRAPPERS_ARE_CHILDREN, False ):
				self.setParent ( manager )

		if flags:
			self.setWindowFlags ( flags )

		mainLayout = QVBoxLayout ( self )
		mainLayout.setContentsMargins ( 0, 0, 0, 0 )

	def __del__ ( self ):
		if self.manager:
			self.manager.removeWrapper ( self )
			self.manager = None

	def getWidget ( self ):
		return self

	def getContents ( self ):
		return self.contents

	def setContents ( self, widget ):
		if self.contents:
			if self.contents.parentWidget() == self:
				self.contents.setParent(None)

			self.layout().removeWidget(self.contents)

		self.contents = widget

		if self.contents:
			self.setAttribute ( QtCore.Qt.WA_DeleteOnClose, self.contents.testAttribute( QtCore.Qt.WA_DeleteOnClose ) )

			if self.contents.testAttribute ( QtCore.Qt.WA_QuitOnClose ):
				self.contents.setAttribute ( QtCore.Qt.WA_DeleteOnClose, False )
				self.setAttribute ( QtCore.Qt.WA_QuitOnClose )

			if self.parentWidget():
				self.setWindowFlags(self.windowFlags()& ~QtCore.Qt.WindowMinimizeButtonHint)

			self.layout().addWidget(self.contents)
			self.contents.setParent(self)
			self.contents.show()

	def startDrag ( self ):
		pass

	def hide ( self ):
		QWidget.hide ( self )

	def deferDeletion ( self ):
		if self.manager:
			self.manager.removeWrapper ( self )
			self.manager = None

		self.setParent ( None )
		self.deleteLater ()

	def setParent ( self, parent ):
		QWidget.setParent ( self, parent )

	def closeEvent ( self, e ):
		toolWindows = [ ]
		for child in self.children ():
			tabWidget = child
			if tabWidget:
				toolWindows.append ( tabWidget.toolWindows () )

		if not self.manager.releaseToolWindows ( toolWindows, True ):
			e.ignore ()

	def changeEvent ( self, e ):
		if e.type () == QEvent.WindowStateChange or e.type () == QEvent.ActivationChange:
			self.getMainWindow ().setWindowState ( QtCore.Qt.WindowNoState )
		# super ().changeEvent ( e )

	def eventFilter ( self, o, e ):
		if o == self.manager:
			if e.type () == QEvent.StyleChange and self.manager.styleSheet () != self.styleSheet ():
				self.setStyleSheet ( self.manager.styleSheet () )

		if not self.manager and o == self.contents and e.type () == QEvent.StyleChange:
			return False

		return super ().eventFilter ( o, e )

	def nativeEvent ( self, eventType, message, result ):
		return super ().nativeEvent ( eventType, message, result )
