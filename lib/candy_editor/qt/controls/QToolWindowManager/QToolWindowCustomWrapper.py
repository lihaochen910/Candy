from PyQt5.QtCore import QEvent, Qt
from PyQt5.QtGui import QMouseEvent

from .QCustomWindowFrame import QCustomTitleBar, QCustomWindowFrame
from .QToolWindowManagerCommon import *


class QToolWindowCustomTitleBar ( QCustomTitleBar ):

	def __init__ ( self, parent ):
		super ( QToolWindowCustomTitleBar, self ).__init__ ( parent )


class QToolWindowCustomWrapper ( QCustomWindowFrame ):

	def __init__ ( self, manager, wrappedWidget = None, config = {} ):
		super ( QToolWindowCustomWrapper, self ).__init__ ()
		self.manager = manager
		self.manager.installEventFilter ( self )
		self.dragCanStart = False
		# self.createdFromDrag = False
		self.moveCountAvailable = 0

		self.setWindowFlags ( self.windowFlags () | Qt.Tool )
		self.setStyleSheet ( self.manager.styleSheet () )

		if self.manager.config.setdefault ( QTWM_WRAPPERS_ARE_CHILDREN, False ):
			self.setParent ( manager )

		qApp.installEventFilter ( self )

		self.setContents ( wrappedWidget )

	def __del__ ( self ):
		if self.manager != None:
			self.manager.removeWrapper ( self )
			self.manager = None

	@staticmethod
	def wrapWidget ( w, config = {} ):
		return QToolWindowCustomWrapper ( None, w, config )

	def getWidget ( self ):
		return self

	def getContents ( self ):
		return self.contents

	def setContents ( self, widget ):
		self.internalSetContents ( widget, False )
		# if widget != None:
		# 	self.titleBar.onMousePressEvent.connect ( self.mousePressEvent )
		# 	self.titleBar.onMouseMoveEvent.connect ( self.mouseMoveEvent )
		# 	self.titleBar.onMouseReleaseEvent.connect ( self.mouseReleaseEvent )
			# self.titleBar.onCloseButtonClickedEvent.connect ( self.onTitleBarCloseButtonClickedEvent )
			# print ( "[QToolWindowCustomWrapper] setContents %s" % widget )

	def onTitleBarCloseButtonClickedEvent ( self ):
		self.close ()
		return True

	def startDrag ( self ):
		self.titleBar.onBeginDrag ()

		# pressEvent = QMouseEvent ( QEvent.MouseButtonPress, QCursor.pos (), QtCore.Qt.LeftButton,
		#                            QtCore.Qt.LeftButton, QtCore.Qt.NoModifier )
		# qApp.sendEvent ( self, pressEvent )

		# self.dragCanStart = True
		# self.manager.startDragWrapper ( self )

	def moveEvent ( self, e ):
		# print ( "[QToolWindowCustomWrapper] moveEvent" )
		if self.dragCanStart:
			self.moveCountAvailable += 1

		super ().moveEvent ( e )

	def deferDeletion ( self ):
		if self.manager != None:
			self.manager.removeWrapper ( self )
			self.manager = None
		self.setParent ( None )
		self.deleteLater ()

	# def setParent ( self, parent ):
	# 	super ().setParent ( parent )

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
		# print ( "[QToolWindowCustomWrapper] closeEvent", self.contents )
		if self.contents != None:
			toolWindows = []
			for toolWindow in self.manager.toolWindows:
				if toolWindow.window () == self:
					toolWindows.append ( toolWindow )
			if not self.manager.releaseToolWindows ( toolWindows, True ):
				e.ignore ()
		super ().closeEvent ( e )

	def calcFrameWindowFlags ( self ):
		flags = super ().calcFrameWindowFlags ()
		if self.parentWidget () != None:
			flags = flags & ~QtCore.Qt.WindowMinimizeButtonHint
		return flags

	def eventFilter ( self, o, e ):

		# if o == self or o == self.titleBar or o == self.window ():
		# 	print ( "QToolWindowCustomWrapper::eventFilter", o, EventTypes ().as_string ( e.type () ) )

		# MyCode
		# TODO: nativeEvent监听窗口移动事件
		# 原有代码适用nativeEvent监听窗口移动事件，此处仅监听鼠标事件可能不准确
		# 改进:使用moveEvent配合eventFilter中的鼠标事件
		# if o == self.titleBar or o == self or o == self.window ():
		if o == self.titleBar:
			# print ( "QToolWindowCustomWrapper::eventFilter", o, EventTypes ().as_string ( e.type () ) )
			if e.type () == QEvent.MouseButtonPress and e.buttons () == Qt.LeftButton:
				if self.manager:
					self.dragCanStart = True
					self.manager.startDragWrapper ( self )
			elif e.type () == QEvent.MouseMove:
				# print ( "[QToolWindowCustomWrapper] eventFilter QEvent.MouseMove" )
				if self.manager and self.dragCanStart:
					if self.moveCountAvailable > 0:
						if self.manager.draggedWrapper == self:
							self.manager.updateDragPosition ()
						else:
							self.manager.startDragWrapper ( self )
						self.moveCountAvailable -= 1
			elif e.type () == QEvent.MouseButtonRelease:
				self.dragCanStart = False
				if self.manager:
					if self.manager.draggedWrapper != self:  # hook
						self.manager.draggedWrapper = self
					self.manager.finishWrapperDrag ()

		# MyCode
		# if o == self and self.createdFromDrag:
		# 	if e.type () == QEvent.Show:
		# 		startDragEvent = QMouseEvent ( QEvent.MouseButtonPress, QCursor.pos (), QtCore.Qt.LeftButton,
		# 		                               QtCore.Qt.LeftButton, QtCore.Qt.NoModifier )
		# 		qApp.sendEvent ( self.titleBar, startDragEvent )
		# 		self.titleBar.specialDragging = True
		# 		qWarning ( "eventFilter sendEvent: startDragEvent" )
		# 	elif e.type () == QEvent.Leave:
		# 		self.createdFromDrag = False
			# elif e.type () == QEvent.MouseMove:
			# 	dragMoveEvent = QMouseEvent ( QEvent.MouseMove, QCursor.pos (), QtCore.Qt.LeftButton,
			# 	                               QtCore.Qt.LeftButton, QtCore.Qt.NoModifier )
			# 	qApp.sendEvent ( self.titleBar, dragMoveEvent )
			# elif e.type () == QEvent.MouseButtonRelease:
			# 	dragFinishedEvent = QMouseEvent ( QEvent.MouseButtonRelease, QCursor.pos (), QtCore.Qt.LeftButton,
			# 	                               QtCore.Qt.LeftButton, QtCore.Qt.NoModifier )
			# 	qApp.sendEvent ( self.titleBar, dragFinishedEvent )

		# winEvent Code
		# if e.type () == QEvent.MouseMove:
		# 	if self.manager.draggedWrapper == self:
		# 		self.manager.updateDragPosition ()
		# 	else:
		# 		self.manager.startDragWrapper ( self )

		if o == self.manager:
			if e.type () == QEvent.StyleChange and self.manager.styleSheet () != self.styleSheet ():
				self.setStyleSheet ( self.manager.styleSheet () )

		if o == self.contents:
			if e.type () == QEvent.Close or \
					e.type () == QEvent.HideToParent or \
					e.type () == QEvent.ShowToParent:
				return False

		return super ().eventFilter ( o, e )

	def nativeEvent ( self, eventType, message ):
		if not self.titleBar:
			return False, 0

		if eventType == "NSEvent":
			# from AppKit import NSEvent
			# from PyQt5 import sip
			# e = sip.wrapinstance ( message.__int__ (), NSEvent )
			# e = NSEvent ( ms )
			pass
		elif eventType == "windows_generic_MSG":
			# import ctypes.wintypes
			# import win32con
			# msg = ctypes.wintypes.MSG.from_address ( message.__int__ () )
			# if msg.message == win32con.WM_NCCALCSIZE:
			# 	return True, 0
			pass

		return super ( QToolWindowCustomWrapper, self ).nativeEvent ( eventType, message )
