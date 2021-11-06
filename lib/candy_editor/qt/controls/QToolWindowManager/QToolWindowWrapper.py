from PyQt5.QtCore import QEvent, Qt
from PyQt5.QtGui import QMouseEvent, QMoveEvent
from PyQt5.QtWidgets import QWidget, QVBoxLayout

from .QToolWindowManagerCommon import *


class QToolWindowWrapper ( QWidget ):

	def __init__ ( self, manager, flags = None ):
		super ( QToolWindowWrapper, self ).__init__ ( None )
		self.manager = manager
		self.contents = None
		self.dragCanStart = False

		if self.manager != None:
			# self.manager.installEventFilter ( self )
			self.setStyleSheet ( self.manager.styleSheet () )

			if manager.config.setdefault ( QTWM_WRAPPERS_ARE_CHILDREN, False ):
				self.setParent ( manager )

		if flags:
			self.setWindowFlags ( flags )

		mainLayout = QVBoxLayout ( self )
		mainLayout.setContentsMargins ( 0, 0, 0, 0 )
		# self.manager.wrappers.append ( self )

	def __del__ ( self ):
		if self.manager != None:
			self.manager.removeWrapper ( self )
			self.manager = None

	def getWidget ( self ):
		return self

	def getContents ( self ):
		return self.contents

	def setContents ( self, widget ):
		if self.contents != None:
			if self.contents.parentWidget () == self:
				self.contents.setParent ( None )

			self.layout ().removeWidget ( self.contents )

		self.contents = widget

		if self.contents != None:
			self.setAttribute ( QtCore.Qt.WA_DeleteOnClose, self.contents.testAttribute ( QtCore.Qt.WA_DeleteOnClose ) )

			if self.contents.testAttribute ( QtCore.Qt.WA_QuitOnClose ):
				self.contents.setAttribute ( QtCore.Qt.WA_DeleteOnClose, False )
				self.setAttribute ( QtCore.Qt.WA_QuitOnClose )

			if self.parentWidget ():
				self.setWindowFlags ( self.windowFlags () & ~QtCore.Qt.WindowMinimizeButtonHint )

			self.layout ().addWidget ( self.contents )
			self.contents.setParent ( self )
			self.contents.show ()

			# qWarning ( "[QToolWindowWrapper] setContents layout: %s contents: %s" % ( self.layout (), self.contents ) )

	def startDrag ( self ):
		# self.dragCanStart = True
		# pressEvent = QMouseEvent ( Qt.QEvent.MouseButtonPress, QCursor.pos (), QtCore.Qt.LeftButton,
		#                              QtCore.Qt.LeftButton, QtCore.Qt.NoModifier )
		# qApp.sendEvent ( self, pressEvent )
		pass

	# def mousePressEvent ( self, e ):
	# 	if e.buttons () == Qt.LeftButton:
	# 		if self.manager:
	# 			self.dragCanStart = True
	# 			self.manager.startDragWrapper ( self )
	# 	super ().mousePressEvent ( e )
	#
	# def mouseMoveEvent ( self, e ):
	# 	if self.manager and self.dragCanStart:
	# 		if self.manager.draggedWrapper == self:
	# 			self.manager.updateDragPosition ()
	# 		else:
	# 			self.manager.startDragWrapper ( self )
	# 	super ().mouseMoveEvent ( e )
	#
	# def mouseReleaseEvent ( self, e ):
	# 	self.dragCanStart = False
	# 	if self.manager:
	# 		if self.manager.draggedWrapper != self: # hook
	# 			self.manager.draggedWrapper = self
	# 		self.manager.finishWrapperDrag ()
	# 	super ().mouseReleaseEvent ( e )

	def deferDeletion ( self ):
		if self.manager:
			self.manager.removeWrapper ( self )
			self.manager = None

		self.setParent ( None )
		self.deleteLater ()

	# def setParent ( self, parent ):
	# 	super ().setParent ( parent )

	# def moveEvent ( self, e ):
	# 	if self.manager:
	# 		if self.manager.draggedWrapper == self:
	# 			self.manager.updateDragPosition ()
	# 		else:
	# 			self.manager.startDragWrapper ( self )

	# def mousePressEvent ( self, e ):
	# 	if e.buttons () == Qt.LeftButton:
	# 		self.dragCanStart = True
	# 		if self.manager:
	# 			self.manager.startDragWrapper ( self )

	# def mouseReleaseEvent ( self, e ):
	# 	self.dragCanStart = False
	# 	self.manager.finishWrapperDrag ()

	# def mouseMoveEvent ( self, e ):
	# 	if self.manager and self.dragCanStart:
	# 		if self.manager.draggedWrapper == self:
	# 			self.manager.updateDragPosition ()
	# 		else:
	# 			self.manager.startDragWrapper ( self )

	def closeEvent ( self, e ):
		from . import QToolWindowArea, QToolWindowRollupBarArea
		toolWindows = []
		# for child in self.children ():
		# 	tabWidget = cast ( child, [ QToolWindowArea, QToolWindowRollupBarArea ] )
		# 	if tabWidget:
		# 		toolWindows.append ( tabWidget.toolWindows () )
		for child in self.findChildren ( QToolWindowArea ):
			tabWidget = cast ( child, [ QToolWindowArea, QToolWindowRollupBarArea ] )
			if tabWidget:
				toolWindows += tabWidget.toolWindows ()

		if not self.manager.releaseToolWindows ( toolWindows, True ):
			e.ignore ()

		super ().closeEvent ( e )

	def changeEvent ( self, e ):
		if e.type () == QEvent.WindowStateChange or e.type () == QEvent.ActivationChange:
			if getMainWindow ():
				getMainWindow ().setWindowState ( QtCore.Qt.WindowNoState )

		super ().changeEvent ( e )

	def eventFilter ( self, o, e ):
		# MyCode
		# if o == self or o == self.window ():
		# 	if e.type () == QEvent.MouseButtonPress and e.buttons () == Qt.LeftButton:
		# 		print ( "start press QToolWindowWrapper!!!!!" )
		# 		self.manager.startDragWrapper ( self )
		# 	elif e.type () == QEvent.MouseMove and e.buttons () == Qt.LeftButton:
		# 		if self.manager.draggedWrapper == self:
		# 			self.manager.updateDragPosition ()
		# 	elif e.type () == QEvent.MouseButtonRelease:
		# 		if self.manager and self.manager.draggedWrapper == self:
		# 			self.manager.finishWrapperDrag ()

		if o == self.manager:
			if e.type () == QEvent.StyleChange and self.manager.styleSheet () != self.styleSheet ():
				self.setStyleSheet ( self.manager.styleSheet () )

		if not self.manager and o == self.contents and e.type () == QEvent.StyleChange:
			return False

		return super ().eventFilter ( o, e )
