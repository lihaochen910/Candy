from PyQt5.QtCore import QRect, QPoint
from PyQt5.QtGui import QCursor
from PyQt5.QtWidgets import QStyle

from .QToolWindowManager import QToolWindowAreaReference, QToolWindowAreaTarget


class SplitSizes:
	oldSize = 0
	newSize = 0


def tabSeparatorRect ( tabRect, splitterWidth ):
	return QRect ( tabRect.x () - splitterWidth / 2, tabRect.y (), splitterWidth, tabRect.height () )


class QToolWindowDragHandlerNinePatch ():

	def startDrag ( self ):
		pass

	def switchedArea ( self, lastArea, newArea ):
		pass

	def getTargetFromPosition ( self, area ):
		result = QToolWindowAreaTarget ( QToolWindowAreaReference.Floating )
		result.area = area
		result.index = -1
		result.reference = QToolWindowAreaReference.Floating
		if not area:
			return result

		areaRect = area.rect()
		centerRect = QRect(areaRect.x() + areaRect.width() / 3, areaRect.y() + areaRect.height() / 3, areaRect.width() / 3, areaRect.height() / 3)
		pos = area.mapFromGlobal(QCursor.pos())
		tabPos = area.mapCombineDropAreaFromGlobal(QCursor.pos())

		if area.combineAreaRect().contains(tabPos):
			result.reference = QToolWindowAreaReference.Combine
			result.index = area.subWidgetAt ( tabPos )
		else:
			if pos.x () < centerRect.x ():
				result.reference = QToolWindowAreaReference.VSplitLeft
			elif pos.x () > centerRect.x () + centerRect.width():
				result.reference = QToolWindowAreaReference.VSplitRight
			elif pos.y () < centerRect.y ():
				result.reference = QToolWindowAreaReference.HSplitTop
			elif pos.y () > centerRect.y () + centerRect.height():
				result.reference = QToolWindowAreaReference.HSplitBottom

		return result

	def isHandlerWidget ( self, widget ):
		return False

	def finishDrag ( self, toolWindows, source, destination ):
		return self.getTargetFromPosition ( destination )

	def getSplitSizes ( self, originalSize ):
		result = SplitSizes ()
		result.oldSize = originalSize * 2 / 3
		result.newSize = originalSize - result.oldSize
		return result

	def baseGetRectFromCursorPos ( self, previewArea, area ) -> QRect:
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
			s.setHeight ( widthSplit.newSize )
			return QRect ( QPoint ( 0, 0 ), s )
		elif target.reference == QToolWindowAreaReference.Right or \
				target.reference == QToolWindowAreaReference.VSplitRight:
			s.setHeight ( widthSplit.newSize )
			return QRect ( QPoint ( widthSplit.oldSize, 0 ), s )
		elif target.reference == QToolWindowAreaReference.Combine:
			if target.index == -1:
				return QRect ( QPoint ( 0, 0 ), s )
			else:
				return area.combineSubWidgetRect(target.index)

		return QRect ()

	def getRectFromCursorPos ( self, previewArea, area ):
		splitterWidth = area.getWidget ().style ().pixelMetric ( QStyle.PM_SplitterWidth, 0, area.getWidget () )
		tabEndRect = area.combineSubWidgetRect ( area.count () - 1 )
		tabEndRect.setX ( tabEndRect.x () + tabEndRect.width () )
		target = self.getTargetFromPosition ( area )
		if target.reference == QToolWindowAreaReference.Combine:
			if target.index == -1:
				return tabSeparatorRect ( tabEndRect, splitterWidth )
			else:
				return tabSeparatorRect ( area.combineSubWidgetRect ( target.index ), splitterWidth )
		return self.baseGetRectFromCursorPos ( previewArea, area )
