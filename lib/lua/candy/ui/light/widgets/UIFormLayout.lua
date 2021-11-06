-- import
local UILabel = require 'candy.ui.light.widgets.UILabel'
local UILayoutItem = require 'candy.ui.light.UILayoutItem'
local UIBoxLayoutModule = require 'candy.ui.light.UIBoxLayout'
local UIVBoxLayout = UIBoxLayoutModule.UIVBoxLayout
local ComponentModule = require 'candy.Component'

-- module
local UIFormLayoutModule = {}

--------------------------------------------------------------------
-- UIFormLayoutLabel
--------------------------------------------------------------------
---@class UIFormLayoutLabel : UILabel
local UIFormLayoutLabel = CLASS: UIFormLayoutLabel ( UILabel )


--------------------------------------------------------------------
-- UIFormLayoutLabel
--------------------------------------------------------------------
---@class UIFormLayoutItem : UILayoutItem
local UIFormLayoutItem = CLASS:UIFormLayoutItem ( UILayoutItem )
	:MODEL {
		"----";
		Field "label" :string () :getset ( "Label" );
		"----";
		Field "labelFeatures" :string () :getset ( "LabelFeatures" );
	}

ComponentModule.registerComponent ( "UIFormLayoutItem", UIFormLayoutItem )

function UIFormLayoutItem:__init ()
	self.label = "Label"
	self.labelWidget = false
	self.policy = {
		"expand",
		"minimum"
	}
	self.alignment = {
		"left",
		"middle"
	}
	self.proportion = {
		0,
		0
	}
	self.minSize = {
		0,
		30
	}
	self.maxSize = {
		10000,
		10000
	}
	self.labelFeatures = ""
end

function UIFormLayoutItem:onAttach ( ent )
	UIFormLayoutItem.__super.onAttach ( self, ent )

	if not ent:isInstance ( "UIWidget" ) then
		return
	end

	local p = ent:getParentWidget ()

	if not p then
		return
	end

	local labelWidget = self:createLabelWidget ()
	self.labelWidget = labelWidget

	p:addInternalChild ( labelWidget )
	linkLocalVisible ( labelWidget:getProp (), ent:getEntity ():getProp () )
	labelWidget:setText ( self.label )
	labelWidget:setDefaultFeatures ( self.labelFeatures )
end

function UIFormLayoutItem:onDetach ( ent )
	UIFormLayoutItem.__super.onDetach ( self, ent )
	self.labelWidget:destroyAllNow ()
	self.labelWidget = false
end

function UIFormLayoutItem:createLabelWidget ()
	return UIFormLayoutLabel ()
end

function UIFormLayoutItem:getLabel ()
	return self.label
end

function UIFormLayoutItem:setLabel ( text )
	self.label = text
	if self.labelWidget then
		self.labelWidget:setText ( self.label )
	end
end

function UIFormLayoutItem:setLabelFeatures ( features )
	self.labelFeatures = features
	if self.labelWidget then
		self.labelWidget:setDefaultFeatures ( features )
	end
end

function UIFormLayoutItem:getLabelFeatures ( features )
	return self.labelFeatures
end

function UIFormLayoutItem:setGeometry ( x, y, w, h )
	local playout = self:getParentLayout ()
	local labelSize = playout.labelSize
	local labelSpacing = playout.labelSpacing
	local labelWidget = self.labelWidget

	labelWidget:setGeometry ( x - labelSize - labelSpacing, y, labelSize, h, false, true )

	local widget = self:getEntity ()
	if isInstance ( widget, "UIWidget" ) then
		self:getEntity ():setGeometry ( x, y, w, h, false, true )
	end
end


--------------------------------------------------------------------
-- UIFormLayout
--------------------------------------------------------------------
---@class UIFormLayout : UIVBoxLayout
local UIFormLayout = CLASS: UIFormLayout ( UIVBoxLayout )
	:MODEL {
		Field "labelProportion" :onset ( "onModified" );
		Field "labelMinSize" :onset ( "onModified" );
		Field "labelSpacing" :onset ( "onModified" );
	}

ComponentModule.registerComponent ( "UIFormLayout", UIFormLayout )

function UIFormLayout:__init ()
	self.labelProportion = 0.5
	self.labelMinSize = 100
	self.labelSpacing = 10
	self.labelSize = 0
end

function UIFormLayout:onModified ()
	local entity = self:getEntity ()

	if not entity then
		return
	end

	return entity:invalidateLayout ()
end

function UIFormLayout:onUpdate ( entries )
	self:calcLayoutVertical ( entries )
	self:updateLabelSize ( entries )
end

function UIFormLayout:getInnerMargin ()
	return self.labelMinSize + self.labelSpacing, 0, 0, 0
end

function UIFormLayout:updateLabelSize ( entries )
	local spacing = self.spacing
	local marginL, marginT, marginR, marginB = self:getMargin ()
	local y = -marginT
	local x = marginL
	local labelMinSize = self.labelMinSize
	local availWidth, availableHeight = self:getAvailableSize ()
	local maxWidgetWidth = 0

	for i, entry in ipairs ( entries ) do
		maxWidgetWidth = math.max ( maxWidgetWidth, entry.targetWidth )
	end

	local labelSpacing = self.labelSpacing
	local availWidth2 = availWidth - marginL - marginR - maxWidgetWidth - labelSpacing
	local labelSize = math.max ( self.labelMinSize, availWidth2 * self.labelProportion )
	self.labelSize = labelSize
end

function UIFormLayout:createLayoutItem ()
	return UIFormLayoutItem ()
end


UIFormLayoutModule.UIFormLayoutLabel = UIFormLayoutLabel
UIFormLayoutModule.UIFormLayoutItem = UIFormLayoutItem
UIFormLayoutModule.UIFormLayout = UIFormLayout

return UIFormLayoutModule