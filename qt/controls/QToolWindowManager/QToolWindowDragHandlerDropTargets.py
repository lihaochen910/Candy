from PyQt5 import QtCore
from PyQt5.QtCore import QPoint
from PyQt5.QtGui import QPixmap, QPainter, QCursor
from PyQt5.QtWidgets import QWidget, qApp

from qt.controls.QToolWindowManager.IToolWindowDragHandler import SplitSizes
from qt.controls.QToolWindowManager.IToolWindowWrapper import IToolWindowWrapper
from qt.controls.QToolWindowManager.QToolWindowManagerCommon import *

DROPTARGET_PADDING = 4


class QToolWindowDropTarget ( QWidget ):

	def __init__ ( self, imagePath, areaReference ):
		super ( QToolWindowDropTarget, self ).__init__ ( None )
		self.pixmap = QPixmap ()
		self.areaReference = areaReference

		self.setWindowFlags ( QtCore.Qt.Tool | QtCore.Qt.FramelessWindowHint | QtCore.Qt.WindowStaysOnTopHint )
		self.setAttribute ( QtCore.Qt.WA_TranslucentBackground )
		self.setAttribute ( QtCore.Qt.WA_ShowWithoutActivating )

		self.pixmap.load ( imagePath )
		self.setFixedSize ( self.pixmap.size () )

	def __del__ ( self ):
		if self.pixmap:
			del self.pixmap

	def target ( self ):
		return self.areaReference

	def paintEvent ( self, paintEvent ):
		painter = QPainter ( self )
		painter.drawPixmap ( 0, 0, self.pixmap )


class QToolWindowDragHandlerDropTargets ( QWidget ):

	def __init__ ( self, manager ):
		from .QToolWindowManager import QToolWindowAreaReference
		self.targets = [
			QToolWindowDropTarget (
				manager.config.setdefault ( QTWM_DROPTARGET_COMBINE, ":/QtDockLibrary/gfx/base_window.png" ),
				QToolWindowAreaReference.Combine ),
			QToolWindowDropTarget (
				manager.config.setdefault ( QTWM_DROPTARGET_TOP, ":/QtDockLibrary/gfx/dock_top.png" ),
				QToolWindowAreaReference.Top ),
			QToolWindowDropTarget (
				manager.config.setdefault ( QTWM_DROPTARGET_BOTTOM, ":/QtDockLibrary/gfx/dock_bottom.png" ),
				QToolWindowAreaReference.Bottom ),
			QToolWindowDropTarget (
				manager.config.setdefault ( QTWM_DROPTARGET_LEFT, ":/QtDockLibrary/gfx/dock_left.png" ),
				QToolWindowAreaReference.Left ),
			QToolWindowDropTarget (
				manager.config.setdefault ( QTWM_DROPTARGET_RIGHT, ":/QtDockLibrary/gfx/dock_right.png" ),
				QToolWindowAreaReference.Right ),
			QToolWindowDropTarget (
				manager.config.setdefault ( QTWM_DROPTARGET_SPLIT_LEFT, ":/QtDockLibrary/gfx/vsplit_left.png" ),
				QToolWindowAreaReference.VSplitLeft ),
			QToolWindowDropTarget (
				manager.config.setdefault ( QTWM_DROPTARGET_SPLIT_RIGHT, ":/QtDockLibrary/gfx/vsplit_right.png" ),
				QToolWindowAreaReference.VSplitRight ),
			QToolWindowDropTarget (
				manager.config.setdefault ( QTWM_DROPTARGET_SPLIT_TOP, ":/QtDockLibrary/gfx/hsplit_top.png" ),
				QToolWindowAreaReference.HSplitTop ),
			QToolWindowDropTarget (
				manager.config.setdefault ( QTWM_DROPTARGET_SPLIT_BOTTOM, ":/QtDockLibrary/gfx/hsplit_bottom.png" ),
				QToolWindowAreaReference.HSplitBottom )
		]

		self.hideTargets ()

	def __del__ ( self ):
		for target in self.targets:
			del target

	def startDrag ( self ):
		pass

	def switchedArea ( self, lastArea, newArea ):
		if newArea:
			self.showTargets ( newArea )
		else:
			self.hideTargets ()

	def getTargetFromPosition ( self, area ):
		from .QToolWindowManager import QToolWindowAreaReference, QToolWindowAreaTarget

		result = QToolWindowAreaTarget.createByArea ( area, QToolWindowAreaReference.Floating, -1 )
		if area:
			widgetUnderMouse = qApp ().widgetAt ( QCursor.pos () )
			if self.isHandlerWidget ( widgetUnderMouse ):
				result.reference = widgetUnderMouse.target ()

			if area and result.reference == QToolWindowAreaReference.Floating:
				tabPos = area.mapCombineDropAreaFromGlobal ( QCursor.pos () )
				if area.combineAreaRect ().contains ( tabPos ):
					result.reference = QToolWindowAreaReference.Combine
					result.index = area.subWidgetAt ( tabPos )

		return result

	def isHandlerWidget ( self, widget ):
		return widget in self.targets

	def finishDrag ( self, toolWindows, source, destination ):
		from .QToolWindowManager import QToolWindowAreaReference, QToolWindowAreaTarget

		result = QToolWindowAreaTarget.createByArea ( destination, QToolWindowAreaReference.Floating, -1 )
		if destination:
			widgetUnderMouse = qApp.widgetAt ( QCursor.pos () )
			if self.isHandlerWidget ( widgetUnderMouse ):
				result.reference = widgetUnderMouse.target ()

			if result.reference == QToolWindowAreaReference.Floating:
				tabPos = destination.mapCombineDropAreaFromGlobal ( QCursor.pos () )
				if destination.combineAreaRect ().contains ( tabPos ):
					result.reference = QToolWindowAreaReference.Combine
					result.index = destination.subWidgetAt ( tabPos )
					if destination == source and result.index > destination.indexOf ( toolWindows[ 0 ] ):
						result.index -= 1

		self.hideTargets ()
		return result

	def getSplitSizes ( self, originalSize ):
		result = SplitSizes ()
		result.oldSize = originalSize / 2
		result.newSize = originalSize - result.oldSize
		return result

	def hideTargets ( self ):
		for target in self.targets:
			target.hide ()

	def showTargets ( self, area ):
		from .QToolWindowManager import QToolWindowAreaReference

		areaCenter = area.mapToGlobal ( QPoint ( area.geometry ().width () / 2, area.geometry ().height () / 2 ) )
		wrapper = findClosestParent ( area.getWidget (), IToolWindowWrapper ).getContents ()
		wrapperCenter = wrapper.mapToGlobal (
			QPoint ( wrapper.geometry ().width () / 2, wrapper.geometry ().height () / 2 ) )

		for target in self.targets:
			newPos = QPoint ()

			if target.target () == QToolWindowAreaReference.Combine:
				newPos = areaCenter
			elif target.target () == QToolWindowAreaReference.Top:
				newPos = wrapperCenter - QPoint ( 0, (
							wrapper.geometry ().height () / 2) - target.height () - DROPTARGET_PADDING )
			elif target.target () == QToolWindowAreaReference.Bottom:
				newPos = wrapperCenter + QPoint ( 0, (
							wrapper.geometry ().height () / 2) - target.height () - DROPTARGET_PADDING )
			elif target.target () == QToolWindowAreaReference.Left:
				newPos = wrapperCenter - QPoint (
					(wrapper.geometry ().width () / 2) - target.width () - DROPTARGET_PADDING, 0 )
			elif target.target () == QToolWindowAreaReference.Right:
				newPos = wrapperCenter + QPoint (
					(wrapper.geometry ().width () / 2) - target.width () - DROPTARGET_PADDING, 0 )
			elif target.target () == QToolWindowAreaReference.HSplitTop:
				newPos = areaCenter - QPoint ( 0, target.height () + DROPTARGET_PADDING )
			elif target.target () == QToolWindowAreaReference.HSplitBottom:
				newPos = areaCenter + QPoint ( 0, target.height () + DROPTARGET_PADDING )
			elif target.target () == QToolWindowAreaReference.VSplitLeft:
				newPos = areaCenter - QPoint ( target.width () + DROPTARGET_PADDING, 0 )
			elif target.target () == QToolWindowAreaReference.VSplitRight:
				newPos = areaCenter + QPoint ( target.width () + DROPTARGET_PADDING, 0 )
			else:
				newPos = target.pos ()

			newPos -= QPoint ( target.geometry ().width () / 2, target.geometry ().height () / 2 )
			target.move ( newPos )
			target.show ()
			target.raise_ ()
