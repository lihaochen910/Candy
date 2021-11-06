from PyQt5.QtCore import QPoint, QRect
from PyQt5.QtGui import QPixmap, QPainter
from PyQt5.QtWidgets import QWidget

from .QToolWindowManagerCommon import *


DROPTARGET_PADDING = 4 # 4


class SplitSizes:
	oldSize = 0
	newSize = 0


class QToolWindowDropTarget ( QWidget ):

	def __init__ ( self, imagePath, areaReference ):
		super ().__init__ ( None )
		self.pixmap = QPixmap ()
		self.areaReference = areaReference

		self.setWindowFlags ( QtCore.Qt.Tool | QtCore.Qt.FramelessWindowHint | QtCore.Qt.WindowStaysOnTopHint )
		self.setAttribute ( QtCore.Qt.WA_TranslucentBackground )
		self.setAttribute ( QtCore.Qt.WA_ShowWithoutActivating )

		if QtCore.QFile.exists ( imagePath ):
			self.pixmap.load ( imagePath )
		else:
			qWarning ( imagePath + " not found." )
		self.setFixedSize ( self.pixmap.size () )

	def __del__ ( self ):
		if self.pixmap:
			del self.pixmap

	def target ( self ):
		return self.areaReference

	def paintEvent ( self, paintEvent ):
		painter = QPainter ( self )
		painter.drawPixmap ( 0, 0, self.pixmap )


class QToolWindowDragHandlerDropTargets:

	def __init__ ( self, manager ):
		from . import QToolWindowAreaReference
		self.targets = [
			QToolWindowDropTarget (
				manager.config.setdefault ( QTWM_DROPTARGET_COMBINE, "./resources/icons/QToolWindowManager/base_window.png" ),
				QToolWindowAreaReference.Combine ),
			QToolWindowDropTarget (
				manager.config.setdefault ( QTWM_DROPTARGET_TOP, "./resources/icons/QToolWindowManager/dock_top.png" ),
				QToolWindowAreaReference.Top ),
			QToolWindowDropTarget (
				manager.config.setdefault ( QTWM_DROPTARGET_BOTTOM, "./resources/icons/QToolWindowManager/dock_bottom.png" ),
				QToolWindowAreaReference.Bottom ),
			QToolWindowDropTarget (
				manager.config.setdefault ( QTWM_DROPTARGET_LEFT, "./resources/icons/QToolWindowManager/dock_left.png" ),
				QToolWindowAreaReference.Left ),
			QToolWindowDropTarget (
				manager.config.setdefault ( QTWM_DROPTARGET_RIGHT, "./resources/icons/QToolWindowManager/dock_right.png" ),
				QToolWindowAreaReference.Right ),
			QToolWindowDropTarget (
				manager.config.setdefault ( QTWM_DROPTARGET_SPLIT_LEFT, "./resources/icons/QToolWindowManager/vsplit_left.png" ),
				QToolWindowAreaReference.VSplitLeft ),
			QToolWindowDropTarget (
				manager.config.setdefault ( QTWM_DROPTARGET_SPLIT_RIGHT, "./resources/icons/QToolWindowManager/vsplit_right.png" ),
				QToolWindowAreaReference.VSplitRight ),
			QToolWindowDropTarget (
				manager.config.setdefault ( QTWM_DROPTARGET_SPLIT_TOP, "./resources/icons/QToolWindowManager/hsplit_top.png" ),
				QToolWindowAreaReference.HSplitTop ),
			QToolWindowDropTarget (
				manager.config.setdefault ( QTWM_DROPTARGET_SPLIT_BOTTOM, "./resources/icons/QToolWindowManager/hsplit_bottom.png" ),
				QToolWindowAreaReference.HSplitBottom )
		]

		self.hideTargets ()

	def __del__ ( self ):
		for target in self.targets:
			del target

	def startDrag ( self ):
		pass

	def getRectFromCursorPos ( self, previewArea, area ) -> QRect:
		target = self.getTargetFromPosition ( area )
		s = previewArea.size ()
		widthSplit = self.getSplitSizes ( s.width () )
		heightSplit = self.getSplitSizes ( s.height () )

		from . import QToolWindowAreaReference

		if target.reference == QToolWindowAreaReference.Top or \
				target.reference == QToolWindowAreaReference.HSplitTop:
			s.setHeight ( heightSplit.newSize )
			return QRect ( QPoint ( 0, 0 ), s )
		elif target.reference == QToolWindowAreaReference.Bottom or \
				target.reference == QToolWindowAreaReference.HSplitBottom:
			s.setHeight ( heightSplit.newSize )
			return QRect ( QPoint ( 0, heightSplit.oldSize ), s )
		elif target.reference == QToolWindowAreaReference.Left or \
				target.reference == QToolWindowAreaReference.VSplitLeft:
			s.setWidth ( widthSplit.newSize )
			return QRect ( QPoint ( 0, 0 ), s )
		elif target.reference == QToolWindowAreaReference.Right or \
				target.reference == QToolWindowAreaReference.VSplitRight:
			s.setWidth ( widthSplit.newSize )
			return QRect ( QPoint ( widthSplit.oldSize, 0 ), s )
		elif target.reference == QToolWindowAreaReference.Combine:
			if target.index == -1:
				return QRect ( QPoint ( 0, 0 ), s )
			else:
				return area.combineSubWidgetRect ( target.index )

		return QRect ()

	def switchedArea ( self, lastArea, newArea ):
		# print ( "[QToolWindowDragHandlerDropTargets] switchedArea %s -> %s" % ( lastArea, newArea ) )
		if newArea != None:
			self.showTargets ( newArea )
		else:
			self.hideTargets ()

	def getTargetFromPosition ( self, area ):
		from . import QToolWindowAreaReference, QToolWindowAreaTarget

		result = QToolWindowAreaTarget.createByArea ( area, QToolWindowAreaReference.Floating, -1 )
		if area != None:
			widgetUnderMouse = qApp.widgetAt ( QCursor.pos () )
			if self.isHandlerWidget ( widgetUnderMouse ):
				result.reference = widgetUnderMouse.target ()

			if area != None and result.reference == QToolWindowAreaReference.Floating:
				tabPos = area.mapCombineDropAreaFromGlobal ( QCursor.pos () )
				if area.combineAreaRect ().contains ( tabPos ):
					result.reference = QToolWindowAreaReference.Combine
					result.index = area.subWidgetAt ( tabPos )

		return result

	def isHandlerWidget ( self, widget ) -> bool:
		return widget in self.targets

	def finishDrag ( self, toolWindows, source, destination ):
		from . import QToolWindowAreaReference, QToolWindowAreaTarget

		result = QToolWindowAreaTarget.createByArea ( destination, QToolWindowAreaReference.Floating, -1 )
		if destination != None:
			widgetUnderMouse = qApp.widgetAt ( QCursor.pos () )
			if self.isHandlerWidget ( widgetUnderMouse ):
				result.reference = cast ( widgetUnderMouse, QToolWindowDropTarget ).target ()

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
		from . import QToolWindowAreaReference
		from .QToolWindowWrapper import QToolWindowWrapper
		from .QToolWindowCustomWrapper import QToolWindowCustomWrapper

		areaCenter = area.mapToGlobal ( QPoint ( area.geometry ().width () / 2, area.geometry ().height () / 2 ) )
		wrapper = findClosestParent ( area.getWidget (), [ QToolWindowWrapper, QToolWindowCustomWrapper ] ).getContents ()
		wrapperCenter = wrapper.mapToGlobal (
			QPoint ( wrapper.geometry ().width () / 2, wrapper.geometry ().height () / 2 ) )

		for target in self.targets:
			newPos = QPoint ()

			if target.target () == QToolWindowAreaReference.Combine:
				newPos = areaCenter
			elif target.target () == QToolWindowAreaReference.Top:
				newPos = wrapperCenter - QPoint ( 0, ( wrapper.geometry ().height () / 2 ) - target.height () - DROPTARGET_PADDING )
			elif target.target () == QToolWindowAreaReference.Bottom:
				newPos = wrapperCenter + QPoint ( 0, ( wrapper.geometry ().height () / 2 ) - target.height () - DROPTARGET_PADDING )
			elif target.target () == QToolWindowAreaReference.Left:
				newPos = wrapperCenter - QPoint ( ( wrapper.geometry ().width () / 2 ) - target.width () - DROPTARGET_PADDING, 0 )
			elif target.target () == QToolWindowAreaReference.Right:
				newPos = wrapperCenter + QPoint ( ( wrapper.geometry ().width () / 2 ) - target.width () - DROPTARGET_PADDING, 0 )
			elif target.target () == QToolWindowAreaReference.HSplitTop:
				newPos = areaCenter - QPoint ( 0, target.height () + DROPTARGET_PADDING )
				newPos += QPoint ( target.geometry ().width () / 2, target.geometry ().height () / 2 )
			elif target.target () == QToolWindowAreaReference.HSplitBottom:
				newPos = areaCenter + QPoint ( 0, target.height () + DROPTARGET_PADDING )
				newPos += QPoint ( target.geometry ().width () / 2, target.geometry ().height () / 2 )
			elif target.target () == QToolWindowAreaReference.VSplitLeft:
				newPos = areaCenter - QPoint ( target.width () + DROPTARGET_PADDING, 0 )
				newPos += QPoint ( target.geometry ().width () / 2, target.geometry ().height () / 2 )
			elif target.target () == QToolWindowAreaReference.VSplitRight:
				newPos = areaCenter + QPoint ( target.width () + DROPTARGET_PADDING, 0 )
				newPos += QPoint ( target.geometry ().width () / 2, target.geometry ().height () / 2 )
			else:
				newPos = target.pos ()

			newPos -= QPoint ( target.geometry ().width () / 2, target.geometry ().height () / 2 )
			target.move ( newPos )
			target.show ()
			target.raise_ ()
