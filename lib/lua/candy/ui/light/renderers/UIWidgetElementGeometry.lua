-- import
local UIWidgetElement = require 'candy.ui.light.UIWidgetElement'
local GeometryModule = require 'candy.gfx.Geometry'
local GeometryRect = GeometryModule.GeometryRect

---@class UIWidgetElementGeometryRect : UIWidgetElement
local UIWidgetElementGeometryRect = CLASS: UIWidgetElementGeometryRect ( UIWidgetElement )
	:MODEL {}

function UIWidgetElementGeometryRect:onLoad ()
	local geom = self:attachInternal ( GeometryRect () )
	self.geom = geom
end

function UIWidgetElementGeometryRect:onUpdateStyle ( widget, style )
	local geom = self.geom
	local filled = {
		style:getBoolean ( self:makeStyleName ( "filled" ), true )
	}
	local color = {
		style:getColor ( self:makeStyleName ( "color" ), { 1,1,1,1 } )
	}

	geom:setColor ( unpack ( color ) )
	geom:setFilled ( filled )
end

function UIWidgetElementGeometryRect:onUpdateSize ( widget, style )
	local geom = self.geom
	local ox, oy = self:getOffset ()
	local x0, y0, x1, y1 = self:getRect ()
	local w = x1 - x0
	local h = y1 - y0

	geom:setLoc ( x0 + ox + w / 2, y0 + oy + h / 2, self:getZOffset () )
	geom:setSize ( w, h )
end

return UIWidgetElementGeometryRect