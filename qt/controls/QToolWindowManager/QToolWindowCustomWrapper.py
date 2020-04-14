from PyQt5 import QtCore
from PyQt5.QtCore import QEvent
from PyQt5.QtWidgets import QFrame
from qt.controls.QToolWindowManager.QCustomWindowFrame import QCustomTitleBar, QCustomWindowFrame
from qt.controls.QToolWindowManager.QToolWindowManagerCommon import *


class QToolWindowCustomTitleBar ( QCustomTitleBar ):

	def __init__ ( self, parent ):
		super ().__init__ ( parent )


class QToolWindowCustomWrapper ( QCustomWindowFrame ):

	def __init__ ( self, manager, wrappedWidget = None ):
		super().__init__()
		self.manager = manager
		self.manager.installEventFilter(self)

		self.setStyleSheet(self.manager.styleSheet())

		if self.manager.config.setdefault(QTWM_WRAPPERS_ARE_CHILDREN,False):
			self.setParent(manager)

		self.setContents(wrappedWidget)

	def __del__ ( self ):
		if self.manager:
			self.manager.removeWrapper ( self )
			self.manager = None

	@staticmethod
	def wrapWidget ( w, config = [ ] ):
		return QToolWindowCustomWrapper ( None, w, config )

	def getWidget ( self ):
		return self

	def getContents ( self ):
		return self.contents

	def setContents ( self, widget ):
		self.internalSetContents ( widget, False )

	def startDrag ( self ):
		self.titleBar.onBeginDrag ()

	def hide ( self ):
		QCustomWindowFrame.hide ( self )

	def deferDeletion ( self ):
		if self.manager:
			self.manager.removeWrapper ( self )
			self.manager = None
		self.setParent ( None )
		self.deleteLater ()

	def setParent ( self, parent ):
		QCustomWindowFrame.setParent ( self, parent )

	def event ( self, e ):
		if e.type () == QEvent.Show or e.type () == QEvent.Hide:
			return super ().event ( e )
		elif e.type () == QEvent.Polish:
			self.ensureTitleBar ()
		elif e.type () == QEvent.ParentChange:
			self.setWindowFlags ( self.windowFlags () )
			return True
		return super ().event ( e )

	def closeEvent ( self, e ):
		if self.contents:
			toolWindows = [ ]
			for toolWindow in self.manager.toolWindows:
				if toolWindow.window == self:
					toolWindows.append ( toolWindow )
			if self.manager.releaseToolWindows ( toolWindows, True ):
				e.ignore ()

	def calcFrameWindowFlags ( self ):
		flags = QCustomWindowFrame.calcFrameWindowFlags ( self )
		if self.parentWidget ():
			flags = flags & ~QtCore.Qt.WindowMinimizeButtonHint
		return flags

	def eventFilter ( self, o, e ):
		if o == self.manager:
			if e.type() == QEvent.StyleChange and self.manager.styleSheet() != self.styleSheet():
				self.setStyleSheet(self.manager.styleSheet())

		if o == self.contents:
			if e.type() == QEvent.Close or \
				e.type () == QEvent.HideToParent or \
				e.type () == QEvent.ShowToParent:
				return False
			
		return super().eventFilter(o, e)

	def nativeEvent ( self, eventType, message, result ):
		if not self.titleBar:
			return False
		super ().nativeEvent ( eventType, message, result )
