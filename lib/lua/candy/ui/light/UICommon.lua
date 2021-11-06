local DEFAULT_TOUCH_PADDING = 20

---@class UICommon
local UICommon = CLASS: UICommon ()
	:MODEL {}

function UICommon.setDefaultTouchPadding ( pad )
	DEFAULT_TOUCH_PADDING = pad or 20
end

function UICommon.getDefaultTouchPadding ()
	return DEFAULT_TOUCH_PADDING or 20
end

return UICommon