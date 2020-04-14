from enum import Enum


QTWM_AREA_IMAGE_HANDLE = "areaUseImageHandle"
QTWM_AREA_IMAGE_HANDLE_IMAGE = "areaImageHandle"
QTWM_AREA_SHOW_DRAG_HANDLE = "areaImageHandle"
QTWM_AREA_DOCUMENT_MODE = "areaImageHandle"
QTWM_AREA_TABS_CLOSABLE = "areaTabsClosable"
QTWM_AREA_TAB_POSITION = "areaTabPosition"
QTWM_AREA_EMPTY_SPACE_DRAG = "areaAllowFrameDragFromEmptySpace"
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


class QToolWindowManagerCommon:

	@staticmethod
	def registerMainWindow ( w ):
		pass

	@staticmethod
	def getMainWindow ():
		pass

	@staticmethod
	def windowBelow ( w ):
		pass

	@staticmethod
	def getIcon ( config, key, fallback ):
		pass

	@staticmethod
	def configHasValue ( config, key ):
		pass


class QTWMReleaseCachingPolicy ( Enum ):
	rcpKeep = 0
	rcpWidget = 1
	rcpForget = 2
	rcpDelete = 3

class QTWMWrapperAreaType ( Enum ):
	watTabs = 0
	watRollups = 1

class QTWMToolType ( Enum ):
	ttStandard = 0
	ttSimple = 1


def findClosestParent ( widget, widgetType ):
	while widget:
		if isinstance ( widget, widgetType ):
			return widget
		widget = widget.parentWidget ()
	return None

def findFurthestParent ( widget, widgetType ):
	result = None
	while widget:
		if isinstance ( widget, widgetType ):
			result = widget;
		widget = widget.parentWidget ()
	return result


mainWindow = None

def registerMainWindow ( w ):
	global mainWindow
	mainWindow = w

def getMainWindow ():
	return mainWindow

def windowBelow ( w ):
	return None

def getIcon ( config, key, fallback ):
	v = config.setdefault ( key, fallback )
	if v == fallback:
		return v
	return v.value ()

