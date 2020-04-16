from abc import ABCMeta, abstractmethod
from PyQt5.QtCore import QRect, QPoint


# qt.controls.QToolWindowManager.QToolWindowManager

class SplitSizes:
	oldSize = 0
	newSize = 0


class IToolWindowDragHandler ():
	__metaclass__ = ABCMeta

	@abstractmethod
	def startDrag ( self ):
		pass

	def getRectFromCursorPos ( self, previewArea, area ):
		target = self.getTargetFromPosition ( area )
		s = previewArea.size ()
		widthSplit = self.getSplitSizes ( s.width () )
		heightSplit = self.getSplitSizes ( s.height () )

		from . import QToolWindowAreaReference

		if target.reference == QToolWindowAreaReference.Top or \
				target.reference == QToolWindowAreaReference.HSplitTop:
			s.setHeight(heightSplit.newSize)
			return QRect ( QPoint ( 0,0 ), s )
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

		return QRect()

	@abstractmethod
	def switchedArea ( self, lastArea, newArea ):
		pass

	@abstractmethod
	def getTargetFromPosition ( self, area ):
		pass

	@abstractmethod
	def isHandlerWidget ( self, widget ):
		pass

	@abstractmethod
	def finishDrag ( self, toolWindows, source, destination ):
		pass

	@abstractmethod
	def getSplitSizes ( self, originalSize ):
		pass
