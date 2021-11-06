-- import
local UISliderModule = require 'candy.ui.light.widgets.UISlider'
local UISlider = UISliderModule.UISlider
local EntityModule = require 'candy.Entity'

-- module
local UIScrollBarModule = {}

--------------------------------------------------------------------
-- UIScrollBar
--------------------------------------------------------------------
---@class UIScrollBar : UISlider
local UIScrollBar = CLASS: UIScrollBar ( UISlider )
	:MODEL {
		Field "pageStep"
	}

function UIScrollBar:onUpdateVisual ( style )
	UIScrollBar.__super.onUpdateVisual ( self, style )

	local w, h = self:getSize ()
	local handleSize = style:getNumber ( "handle_size", 30 )
	local orientation = self.orientation

	if orientation == "h" then
		local handlePageSize = math.abs ( self:getPageStep () / self:getRangeDiff () ) * w
		self.handle:setSize ( handlePageSize, handleSize )
		self.handle:setPiv ( 0, -handleSize / 2 )
	else
		local handlePageSize = math.abs ( self:getPageStep () / self:getRangeDiff () ) * h
		self.handle:setSize ( handleSize, handlePageSize )
		self.handle:setPiv ( handleSize / 2, 0 )
	end

	self:_syncPos ()
end


--------------------------------------------------------------------
-- UIHScrollBar
--------------------------------------------------------------------
---@class UIHScrollBar : UIScrollBar
local UIHScrollBar = CLASS: UIHScrollBar ( UIScrollBar )
	:MODEL {}

function UIHScrollBar:__init ()
	self.orientation = "h"
end

--------------------------------------------------------------------
-- UIVScrollBar
--------------------------------------------------------------------
---@class UIVScrollBar : UIScrollBar
local UIVScrollBar = CLASS: UIVScrollBar ( UIScrollBar )
	:MODEL {}

function UIVScrollBar:__init ()
	self.orientation = "v"
end


EntityModule.registerEntity ( "UIHScrollBar", UIHScrollBar )
EntityModule.registerEntity ( "UIVScrollBar", UIVScrollBar )

UIScrollBarModule.UISlider = UIScrollBar
UIScrollBarModule.UIHSlider = UIHScrollBar
UIScrollBarModule.UIVSlider = UIVScrollBar

return UIScrollBarModule