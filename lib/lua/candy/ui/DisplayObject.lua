-- import
local EventDispatcherEntity = require 'candy.common.EventDispatcherEntity'

---@class DisplayObject : EventDispatcherEntity
local DisplayObject = CLASS: DisplayObject ( EventDispatcherEntity )
    :MODEL {}

function DisplayObject:__init ()
    self.prop = self:_createRenderProp ()
    self.touchEnabled = true
end

function DisplayObject:_createRenderProp ()
    return MOAIGraphicsProp.new ()
end

function DisplayObject:onLoad ()
	self:_attachProp ( self:getProp ( 'render' ), '' )
end

---
-- Returns the size.
-- If there is a function that returns a negative getDims.
-- getSize function always returns the size of the positive.
---@return width, height, depth
function DisplayObject:getSize ()
    local w, h, d = self:getProp ( 'render' ):getDims ()
    w = w or 0
    h = h or 0
    d = d or 0
    return math.abs ( w ), math.abs ( h ), math.abs ( d )
end

---
-- Returns the width.
---@return width
function DisplayObject:getWidth ()
    local w, h, d = self:getSize ()
    return w
end

---
-- Returns the height.
---@return height
function DisplayObject:getHeight ()
    local w, h, d = self:getSize ()
    return h
end

---
-- Sets the position.
-- Without depending on the Pivot, move the top left corner as the origin.
---@param left Left position
---@param top Top position
function DisplayObject:setPos ( left, top )
    local xMin, yMin, zMin, xMax, yMax, zMax = self:getProp ( 'render' ):getBounds ()
    xMin = math.min ( xMin or 0, xMax or 0 )
    yMin = math.min ( yMin or 0, yMax or 0 )

    local pivX, pivY, pivZ = self:getPiv ()
    local locX, locY, locZ = self:getLoc ()
    self:getProp ( 'render' ):setLoc ( left + pivX - xMin, top + pivY - yMin, locZ )
end

---
-- Returns the position.
---@return Left
---@return Top
function DisplayObject:getPos ()
    local xMin, yMin, zMin, xMax, yMax, zMax = self:getProp ( 'render' ):getBounds ()
    xMin = math.min ( xMin or 0, xMax or 0 )
    yMin = math.min ( yMin or 0, yMax or 0 )

    local pivX, pivY, pivZ = self:getProp ( 'render' ):getPiv ()
    local locX, locY, locZ = self:getProp ( 'render' ):getLoc ()
    return locX - pivX + xMin, locY - pivY + yMin
end

---
-- Returns the left position.
---@return left
function DisplayObject:getLeft ()
    local left, top = self:getPos ()
    return left
end

---
-- Set the left position.
---@param value left position.
function DisplayObject:setLeft ( value )
    local left, top = self:getPos ()
    self:setPos ( value, top )    
end

---
-- Returns the top position.
---@return top
function DisplayObject:getTop ()
    local left, top = self:getPos ()
    return top
end

---
-- Set the top position.
---@param value top position.
function DisplayObject:setTop ( value )
    local left, top = self:getPos ()
    self:setPos ( left, value )    
end

---
-- Returns the right position.
---@return right
function DisplayObject:getRight ()
    local left, top = self:getPos ()
    local width, height = self:getSize ()
    return left + width
end

---
-- Set the right position.
---@param value right position.
function DisplayObject:setRight ( value )
    local left, top = self:getPos ()
    self:setPos ( value - self:getWidth (), top )    
end

---
-- Returns the bottom position.
---@return bottom
function DisplayObject:getBottom ()
    local left, top = self:getPos ()
    local width, height = self:getSize ()
    return top + height
end

---
-- Set the bottom position.
---@param value bottom position.
function DisplayObject:setBottom ( value )
    local left, top = self:getPos ()
    self:setPos ( left, value - self:getHeight () )    
end

---
-- Returns the color.
---@return red, green, blue, alpha
function DisplayObject:getColor ()
    local r = self:getProp ( 'render' ):getAttr ( MOAIColor.ATTR_R_COL )
    local g = self:getProp ( 'render' ):getAttr ( MOAIColor.ATTR_G_COL )
    local b = self:getProp ( 'render' ):getAttr ( MOAIColor.ATTR_B_COL )
    local a = self:getProp ( 'render' ):getAttr ( MOAIColor.ATTR_A_COL )
    return r, g, b, a
end

---
-- Sets the piv (the anchor around which the object can 'pivot') to the object's center.
function DisplayObject:setPivToCenter ()
    local w, h, d = self:getSize ()
    local left, top = self:getPos ()
    self:getProp ( 'render' ):setPiv ( w / 2, h / 2, 0 )
    self:setPos ( left, top )
end

---
-- Returns whether or not the object is currently visible or invisible.
---@return visible
function DisplayObject:getVisible ()
    -- return self:getMoaiProp ():getAttr ( MOAIGraphicsProp.ATTR_VISIBLE ) > 0
    -- return DisplayObject.__super.isVisible ( self )
    return self:getProp ( 'render' ):isVisible ( self )
end

---
-- Sets the visibility.
-- TODO:I avoid the bug of display settings MOAIProp.(2013/05/20 last build)
---@param visible visible
function DisplayObject:setVisible ( visible )
    -- DisplayObject.__super.setVisible ( self, visible )
    self:getProp ( 'render' ):setVisible ( visible )
    self:forceUpdate ()
end

---
-- Sets the object's parent, inheriting its color and transform.
---@param parent Entity | nil parent
function DisplayObject:setParent ( parent )

    if self.scene then
        self.reparent ( parent )
    else
        if parent then
            if not self.parent then
                parent:addChild ( self )
            else
                self.parent:_detachChildEntity ( self )
                parent:addChild ( self )
            end
		else
			local parent0 = self.parent
			if parent0 then
				parent0.children[ self ] = nil
				parent0:_detachChildEntity ( self )
			end
        end
    end

    -- if self.parent then
    --     self.parent:_detachChildEntity ( self )
    -- end

    -- self:getMoaiProp ():clearAttrLink ( MOAIColor.INHERIT_COLOR )
    -- self:getMoaiProp ():clearAttrLink ( MOAITransform.INHERIT_TRANSFORM )

    -- -- Conditions compatibility
    -- if MOAIGraphicsProp.INHERIT_VISIBLE then
    --     self:getMoaiProp ():clearAttrLink ( MOAIGraphicsProp.INHERIT_VISIBLE )
    -- end

    -- if parent then

        -- parent:addChild ( self )

        -- local parentProp = parent:getMoaiProp ()
        -- self:getMoaiProp ():setAttrLink ( MOAIColor.INHERIT_COLOR, parentProp, MOAIColor.COLOR_TRAIT )
        -- self:getMoaiProp ():setAttrLink ( MOAITransform.INHERIT_TRANSFORM, parentProp, MOAITransform.TRANSFORM_TRAIT )

        -- -- Conditions compatibility
        -- if MOAIGraphicsProp.INHERIT_VISIBLE then
        --     self:getMoaiProp ():setAttrLink ( MOAIGraphicsProp.INHERIT_VISIBLE, parentProp, MOAIGraphicsProp.ATTR_VISIBLE )
        -- end
    -- end
end

---
-- Set the scissor rect.
---@param scissorRect scissorRect
function DisplayObject:setScissorRect ( scissorRect )
    self:getProp ( 'render' ):setScissorRect ( scissorRect )
    self.scissorRect = scissorRect
end

function DisplayObject:getProp ( role )
    if role == 'render' then
        return self.prop
    end
    return DisplayObject.__super.getProp ( self )
end

return DisplayObject