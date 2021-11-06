from enum import IntEnum

from PyQt5 import QtCore
from PyQt5.QtCore import qWarning
from PyQt5.QtGui import QCursor
from PyQt5.QtWidgets import qApp

QTWM_AREA_IMAGE_HANDLE = "areaUseImageHandle"
QTWM_AREA_IMAGE_HANDLE_IMAGE = "areaImageHandle"
QTWM_AREA_SHOW_DRAG_HANDLE = "areaImageHandle"
QTWM_AREA_DOCUMENT_MODE = "areaImageHandle"
QTWM_AREA_TABS_CLOSABLE = "areaTabsClosable"
QTWM_AREA_TAB_POSITION = "areaTabPosition"
QTWM_AREA_EMPTY_SPACE_DRAG = "areaAllowFrameDragFromEmptySpace"
QTWM_AREA_USE_TAB_FRAME = "areaUseTableFrame"
QTWM_WRAPPER_USE_CUSTOM_FRAME = "wrapperUseCustomFrame"
QTWM_THUMBNAIL_TIMER_INTERVAL = "thumbnailTimerInterval"
QTWM_TOOLTIP_OFFSET = "tooltipOffset"
QTWM_AREA_TAB_ICONS = "areaTabIcons"
QTWM_RELEASE_POLICY = "releasePolicy"
QTWM_ALWAYS_CLOSE_WIDGETS = "alwaysCloseWidgets"
QTWM_WRAPPERS_ARE_CHILDREN = "wrappersAreChildren"
QTWM_RAISE_DELAY = "raiseDelay"
QTWM_RETITLE_WRAPPER = "retitleWrapper"
QTWM_SINGLE_TAB_FRAME = "singleTabFrame"
QTWM_BRING_ALL_TO_FRONT = "bringAllToFront"
QTWM_PRESERVE_SPLITTER_SIZES = "preserveSplitterSizes"
QTWM_SUPPORT_SIMPLE_TOOLS = "supportSimpleTools"
QTWM_TAB_CLOSE_ICON = "tabCloseIcon"
QTWM_SINGLE_TAB_FRAME_CLOSE_ICON = "tabFrameCloseIcon"

QTWM_DROPTARGET_TOP = "droptargetTop"
QTWM_DROPTARGET_BOTTOM = "droptargetBottom"
QTWM_DROPTARGET_LEFT = "droptargetLeft"
QTWM_DROPTARGET_RIGHT = "droptargetRight"
QTWM_DROPTARGET_SPLIT_TOP = "droptargetSplitTop"
QTWM_DROPTARGET_SPLIT_BOTTOM = "droptargetSplitBottom"
QTWM_DROPTARGET_SPLIT_LEFT = "droptargetSplitLeft"
QTWM_DROPTARGET_SPLIT_RIGHT = "droptargetSplitRight"
QTWM_DROPTARGET_COMBINE = "droptargetCombine"


class QTWMReleaseCachingPolicy ( IntEnum ):
	rcpKeep = 0
	rcpWidget = 1
	rcpForget = 2
	rcpDelete = 3


class QTWMWrapperAreaType ( IntEnum ):
	watTabs = 0
	watRollups = 1


class QTWMToolType ( IntEnum ):
	ttStandard = 0
	ttSimple = 1


def cast ( obj, clas ):
	# if obj is None:
	# 	obj.cause_a_exception ()
	if isinstance ( clas, list ):
		for c in clas:
			# print ( "cast %s to %s" % ( obj, c ) )
			if type ( obj ) == c: return obj
			if isinstance ( obj, c ): return obj
	else:
		if type ( obj ) == clas: return obj
		if isinstance ( obj, clas ): return obj
	return None


def findClosestParent ( widget, widgetType ):
	while widget != None:
		if isinstance ( widgetType, list ):
			for t in widgetType:
				# from qt.controls.QToolWindowManager.QToolTabManager import QTabPane
				# if isinstance ( widget, QTabPane ):
				# 	widget.cause_a_exception ()
				# print ( "findClosestParent %s is %s?" % (widget, t) )
				if isinstance ( widget, t ):
					# qWarning ( "findClosestParent [return] %s is %s" % ( widget, t ) )
					return widget
		else:
			if isinstance ( widget, widgetType ):
				# qWarning ( "findClosestParent [return] %s is %s" % ( widget, widgetType ) )
				return widget
		widget = widget.parentWidget ()

	# qWarning ( "findClosestParent [return] None" )
	return None


def findFurthestParent ( widget, widgetType ):
	result = None
	while widget != None:
		if isinstance ( widget, widgetType ):
			result = widget
		widget = widget.parentWidget ()
	return result


mainWindow = None


def registerMainWindow ( w ):
	global mainWindow
	mainWindow = w


def getMainWindow ():
	global mainWindow
	return mainWindow


def windowBelow ( w ):
	while w != None and not w.isWindow ():
		w = w.parentWidget ()
	if w is None:
		return None
	for topWindow in qApp.topLevelWidgets ():
		# if topWindow.isWindow () and topWindow.isVisible () and topWindow.winId () == w.winId () and topWindow.windowState () != QtCore.Qt.WindowMinimized:
		if topWindow.isWindow () and topWindow.isVisible () and topWindow != w and topWindow.windowState () != QtCore.Qt.WindowMinimized:
			if topWindow.geometry ().contains ( QCursor.pos () ):
				# qWarning ( "windowBelow return: %s below: %s" % ( topWindow, w ) )
				return topWindow
	return None


def getIcon ( config, key, fallback ):
	v = config.setdefault ( key, fallback )
	if v == fallback:
		return v
	return v
