from PyQt5.QtCore import QRect
from PyQt5.QtGui import QCursor
from PyQt5.QtWidgets import QStyle

from qt.controls.QToolWindowManager.IToolWindowDragHandler import IToolWindowDragHandler, SplitSizes
from qt.controls.QToolWindowManager.QToolWindowManager import QToolWindowAreaReference, QToolWindowAreaTarget


def tabSeparatorRect ( tabRect, splitterWidth ):
	return QRect ( tabRect.x () - splitterWidth / 2, tabRect.y (), splitterWidth, tabRect.height () )


class QToolWindowDragHandlerNinePatch ( IToolWindowDragHandler ):

	def startDrag ( self ):
		pass

	def switchedArea ( self, lastArea, newArea ):
		pass

	def getTargetFromPosition ( self, area ):
		result = QToolWindowAreaTarget()
		result.area = area
		result.index = -1
		result.reference = QToolWindowAreaReference.Type.Floating
		if not area:
			return result

		areaRect = area.rect()
		centerRect = QRect(areaRect.x() + areaRect.width() / 3, areaRect.y() + areaRect.height() / 3, areaRect.width() / 3, areaRect.height() / 3)
		pos = area.mapFromGlobal(QCursor.pos())
		tabPos = area.mapCombineDropAreaFromGlobal(QCursor.pos())

		if area.combineAreaRect().contains(tabPos):
			result.reference = QToolWindowAreaReference.Type.Combine
			result.index = area.subWidgetAt ( tabPos )
		else:
			if pos.x () < centerRect.x ():
				result.reference = QToolWindowAreaReference.Type.VSplitLeft
			elif pos.x () > centerRect.x () + centerRect.width():
				result.reference = QToolWindowAreaReference.Type.VSplitRight
			elif pos.y () < centerRect.y ():
				result.reference = QToolWindowAreaReference.Type.HSplitTop
			elif pos.y () > centerRect.y () + centerRect.height():
				result.reference = QToolWindowAreaReference.Type.HSplitBottom

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

	def getRectFromCursorPos ( self, previewArea, area ):
		splitterWidth = area.getWidget ().style ().pixelMetric ( QStyle.PM_SplitterWidth, 0, area.getWidget () )
		tabEndRect = area.combineSubWidgetRect ( area.count () - 1 )
		tabEndRect.setX ( tabEndRect.x () + tabEndRect.width () )
		target = self.getTargetFromPosition ( area )
		if target.reference == QToolWindowAreaReference.Type.Combine:
			if target.index == -1:
				return tabSeparatorRect ( tabEndRect, splitterWidth )
			else:
				return tabSeparatorRect ( area.combineSubWidgetRect ( target.index ), splitterWidth )
		return super ( IToolWindowDragHandler, self ).getRectFromCursorPos ( previewArea, area )
