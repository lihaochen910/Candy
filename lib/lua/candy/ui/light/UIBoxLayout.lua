-- import
local UILayoutModule = require 'candy.ui.light.UILayout'
local UILayout = UILayoutModule.UILayout
local ComponentModule = require 'candy.Component'

-- module
local UIBoxLayoutModule = {}

local insert = table.insert
local max = math.max

EnumBoxLayoutDirection = _ENUM_V {
	"vertical",
	"horizontal"
}

--------------------------------------------------------------------
-- UIBoxLayout
--------------------------------------------------------------------
---@class UIBoxLayout : UILayout
local UIBoxLayout = CLASS: UIBoxLayout ( UILayout )
	:MODEL {
		Field "direction" :enum(EnumBoxLayoutDirection) :getset("Direction"),
		Field "spacing" :getset("Spacing")
	}

function UIBoxLayout:__init ()
	self.direction = "vertical"
	self.spacing = 5
end

function UIBoxLayout:setDirection ( dir )
	self.direction = dir
end

function UIBoxLayout:getDirection ()
	return self.direction
end

function UIBoxLayout:setSpacing ( s )
	self.spacing = s
	self:invalidate ()
end

function UIBoxLayout:getSpacing ()
	return self.spacing
end

function UIBoxLayout:onUpdate ( entries )
	local dir = self.direction

	if dir == "vertical" then
		self:calcLayoutVertical ( entries )
	elseif dir == "horizontal" then
		self:calcLayoutHorizontal ( entries )
	else
		error ( "unknown layout direction: " .. tostring ( dir ) )
	end
end

function UIBoxLayout:calcLayoutVertical ( entries )
	local count = #entries

	if count == 0 then
		return
	end

	local spacing = self.spacing
	local marginL, marginT, marginR, marginB = self:calcMargin ()
	local owner = self:getOwner ()
	local innerWidth, innerHeight = self:getInnerSize ()
	innerHeight = innerHeight - spacing *  ( count - 1 )
	local minHeightTotal = 0
	local minWidthTotal = 0

	for i, entry in ipairs ( entries ) do
		entry:setFrameSize ( innerWidth, false )
	end

	for i, entry in ipairs ( entries ) do
		minWidthTotal = max ( minWidthTotal, entry.minWidth )
		local policy = entry.policyH

		if policy == "expand" then
			entry.targetWidth = max ( innerWidth, entry.minWidth )
			entry.offsetX = 0
		else
			local targetWidth = entry.minWidth
			entry.targetWidth = targetWidth
		end
	end

	for i, entry in ipairs ( entries ) do
		minHeightTotal = minHeightTotal + entry.minHeight
	end

	if innerHeight <= minHeightTotal then
		for i, entry in ipairs ( entries ) do
			entry.targetHeight = entry.minHeight
		end
	else
		local propAvailHeight = innerHeight
		local proportional = {}
		local nonproportional = {}
		local fixed = {}
		local totalProportion = 0

		for i, entry in ipairs ( entries ) do
			local policy = entry.policyV

			if policy == "expand" then
				if entry.proportionV > 0 then
					insert ( proportional, entry )
					totalProportion = totalProportion + entry.proportionV
				else
					entry.targetHeight = entry.minHeight
					propAvailHeight = propAvailHeight - entry.minHeight
					insert ( nonproportional, entry )
				end
			elseif policy == "minimum" then
				entry.targetHeight = entry.minHeight
				propAvailHeight = propAvailHeight - entry.minHeight
				insert ( fixed, entry )
			elseif policy == "fixed" then
				entry.targetHeight = entry.fixedHeight
				propAvailHeight = propAvailHeight - entry.fixedHeight
				insert ( fixed, entry )
			else
				error ( "unknown policy", policy )
			end
		end

		if totalProportion == 0 then
			if next ( nonproportional ) then
				local remain = innerHeight - minHeightTotal
				local expand = remain / #nonproportional

				for _, entry in ipairs ( nonproportional ) do
					entry.targetHeight = entry.minHeight + expand
				end
			end
		else
			while true do
				local proportional2 = {}
				local heightUnit = propAvailHeight / totalProportion
				totalProportion = 0

				for _, entry in ipairs ( proportional ) do
					local targetHeight = entry.proportionV * heightUnit

					if targetHeight < entry.minHeight then
						entry.targetHeight = entry.minHeight
						propAvailHeight = propAvailHeight - entry.minHeight
					else
						entry.targetHeight = targetHeight
						totalProportion = totalProportion + entry.proportionV
						insert ( proportional2, entry )
					end
				end

				if #proportional == #proportional2 then
					break
				end

				proportional = proportional2
			end
		end
	end

	local x = marginL
	local y = -marginT

	for i, entry in ipairs ( entries ) do
		entry:setLoc ( x, y )
		y = y - entry.targetHeight - spacing
	end
end

function UIBoxLayout:calcLayoutHorizontal ( entries )
	local count = #entries

	if count == 0 then
		return
	end

	local spacing = self.spacing
	local marginL, marginT, marginR, marginB = self:calcMargin ()
	local owner = self:getOwner ()
	local innerWidth, innerHeight = self:getInnerSize ()
	innerWidth = innerWidth - spacing *  ( count - 1 )
	local minWidthTotal = 0
	local minHeightTotal = 0

	for i, entry in ipairs ( entries ) do
		entry:setFrameSize ( false, innerHeight )
	end

	for i, entry in ipairs ( entries ) do
		minHeightTotal = max ( minHeightTotal, entry.minHeight )
		local policy = entry.policyV

		if policy == "expand" then
			entry.targetHeight = max ( innerHeight, entry.minHeight )
			entry.offsetY = 0
		else
			local targetHeight = entry.minHeight
			entry.targetHeight = targetHeight
		end
	end

	for i, entry in ipairs ( entries ) do
		minWidthTotal = minWidthTotal + entry.minWidth
	end

	if innerWidth <= minWidthTotal then
		for i, entry in ipairs ( entries ) do
			entry.targetWidth = entry.minWidth
		end
	else
		local propAvailWidth = innerWidth
		local proportional = {}
		local nonproportional = {}
		local fixed = {}
		local totalProportion = 0

		for i, entry in ipairs ( entries ) do
			if entry.policyH == "expand" then
				if entry.proportionH > 0 then
					insert ( proportional, entry )
					totalProportion = totalProportion + entry.proportionH
				else
					entry.targetWidth = entry.minWidth
					propAvailWidth = propAvailWidth - entry.minWidth
					insert ( nonproportional, entry )
				end
			else
				entry.targetWidth = entry.minWidth
				propAvailWidth = propAvailWidth - entry.minWidth
				insert ( fixed, entry )
			end
		end

		if totalProportion == 0 then
			if next ( nonproportional ) then
				local remain = innerWidth - minWidthTotal
				local expand = remain / #nonproportional

				for _, entry in ipairs ( nonproportional ) do
					entry.targetWidth = entry.minWidth + expand
				end
			end
		else
			while true do
				local proportional2 = {}
				local widthUnit = propAvailWidth / totalProportion
				totalProportion = 0

				for _, entry in ipairs ( proportional ) do
					local targetWidth = entry.proportionH * widthUnit

					if targetWidth < entry.minWidth then
						entry.targetWidth = entry.minWidth
						propAvailWidth = propAvailWidth - entry.minWidth
					else
						entry.targetWidth = targetWidth
						totalProportion = totalProportion + entry.proportionH
						insert ( proportional2, entry )
					end
				end

				if #proportional == #proportional2 then
					break
				end

				proportional = proportional2
			end
		end
	end

	local y = -marginT
	local x = marginL

	for i, entry in ipairs ( entries ) do
		entry:setLoc ( x, y )
		x = x + entry.targetWidth + spacing
	end
end


--------------------------------------------------------------------
-- UIHBoxLayout
--------------------------------------------------------------------
---@class UIHBoxLayout : UIBoxLayout
local UIHBoxLayout = CLASS: UIHBoxLayout ( UIBoxLayout )
	:MODEL {
		Field "direction" :no_edit()
	}

function UIHBoxLayout:__init ()
	self:setDirection ( "horizontal" )
end

function UIHBoxLayout:setDirection ( dir )
	return UIHBoxLayout.__super.setDirection ( self, "horizontal" )
end

ComponentModule.registerComponent ( "UIHBoxLayout", UIHBoxLayout )


--------------------------------------------------------------------
-- UIVBoxLayout
--------------------------------------------------------------------
---@class UIVBoxLayout : UIBoxLayout
local UIVBoxLayout = CLASS: UIVBoxLayout ( UIBoxLayout )
	:MODEL {
		Field "direction" :no_edit()
	}

function UIVBoxLayout:__init ()
	self:setDirection ( "vertical" )
end

function UIVBoxLayout:setDirection ( dir )
	return UIVBoxLayout.__super.setDirection ( self, "vertical" )
end

ComponentModule.registerComponent ( "UIVBoxLayout", UIVBoxLayout )


UIBoxLayoutModule.UIBoxLayout = UIBoxLayout
UIBoxLayoutModule.UIHBoxLayout = UIHBoxLayout
UIBoxLayoutModule.UIVBoxLayout = UIVBoxLayout

return UIBoxLayoutModule