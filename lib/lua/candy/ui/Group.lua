-- import
local DisplayObject = require 'candy.ui.DisplayObject'
local ComponentModule = require 'candy.Component'
local Component = ComponentModule.Component

---@class Group : DisplayObject
local Group = CLASS: Group ( DisplayObject )
    :MODEL {}

---
-- The constructor.
---@param layer (option)layer object
---@param width (option)width
---@param height (option)height
---@see candy.DisplayObject
function Group:__init ( layer, width, height )
    self.isGroup = true
    self.layer = layer
    self.parentScissorRect = nil
    self.contentScissorRect = nil

    self:setSize ( width or 0, height or 0 )
    self:setPivToCenter ()
end

---
-- Sets the size.
---@param width width
---@param height height
function Group:fitChildrenSize ()
    local maxWidth, maxHeight = 0, 0
    for i, child in ipairs ( self:getChildren () ) do
       maxWidth = math.max ( maxWidth, child:getRight () )
       maxHeight = math.max ( maxHeight, child:getBottom () )
    end
    self:setSize ( maxWidth, maxHeight )
end

---
-- Sets the bounds.
-- This is the bounds of a Group, rather than of the children.
---@param xMin xMin
---@param yMin yMin
---@param zMin zMin
---@param xMax xMax
---@param yMax yMax
---@param zMax zMax
function Group:setBounds ( xMin, yMin, zMin, xMax, yMax, zMax )
    self:getProp ():setBounds ( xMin, yMin, zMin, xMax, yMax, zMax )

    if self.contentScissorRect then
        self.contentScissorRect:setRect ( xMin, yMin, xMax, yMax )
    end
end

---
-- Adds the specified child.
---@param child candy.ui.UIComponent
function Group:addChild ( child )

    -- if isInstance ( child, Component ) then
    --     self:attach ( child )
    --     return true
    -- end

    if not self:getChildren ()[ child ] then
        child:setParent ( self )

        -- if child.setLayer then
        --     child:setLayer ( self.layer )
        -- elseif self.layer then
        --     self.layer:getMoaiLayer ():insertProp ( child )
        -- end

        local scissorRect = self.contentScissorRect or self.parentScissorRect
        if scissorRect then
            if child.setParentScissorRect then
                child:setParentScissorRect ( scissorRect )
            else
                child:setScissorRect ( scissorRect )
            end
        end

        return true
    end
    return false
end

---
-- Removes a child.
---@param child DisplayObject
---@return True if removed.
function Group:removeChild ( child )
    if self:getChildren ()[ child ] then
        child:setParent ( nil )

        -- if child.setLayer then
        --     child:setLayer ( nil )
        -- elseif self.layer then
        --     self.layer:getMoaiLayer ():removeProp ( child )
        -- end

        local scissorRect = self.contentScissorRect or self.parentScissorRect
        if scissorRect then
            if child.setParentScissorRect then
                child:setParentScissorRect ( nil )
            else
                child:setScissorRect ( nil )
            end
        end

        return true
    end
    return false
end

---
-- Add the children.
function Group:addChildren ( children )
    for i, child in ipairs ( children ) do
        self:addChild ( child )
    end
end

---
-- Remove the children.
function Group:removeChildren ()
    local children = table.simplecopy ( self:getChildren () )
    for i, child in ipairs ( children ) do
        self:removeChild ( child )
    end
end

---
-- Set the children.
---@param children
function Group:setChildren ( children )
    self:removeChildren ()
    self:addChildren ( children )
end

---
-- Returns a child by name.
---@param name child's name
---@return child
function Group:getChildByName ( name )
    for i, child in ipairs ( self:getChildren () ) do
        if child.name == name then
            return child
        end
        if child.isGroup and child.getChildByName ~= nil then
            local child2 = child:getChildByName ( name )
            if child2 then
                return child2
            end
        end
    end
end

---
-- Sets the layer for this group to use.
---@param layer(MOAILayer) Layer
function Group:setLayer ( layer )
    if self.layer == layer then
        return
    end

    UIComponent.__super.setLayer ( self, layer )

    if self.layer then
        for i, v in ipairs ( self:getChildren () ) do
            if v.setLayer then
                v:setLayer ( nil )
            else
                -- self.layer:getMoaiLayer ():removeProp ( v )
                v:setPartition ( nil )
            end
        end
    end

    self.layer = layer

    if self.layer then
        for i, v in ipairs ( self:getChildren () ) do
            if v.setLayer then
                v:setLayer ( self.layer )
            else
                -- self.layer:getMoaiLayer ():insertProp ( v )
                v:setPartition ( self.layer:getMoaiLayer () )
            end
        end
    end
end

---
-- Sets the group's priority.
-- Also sets the priority of any children.
---@param priority priority
function Group:setPriority ( priority )
    -- Group.__index.setPriority ( self, priority )
    self:getProp ():setPriority ( priority )

    for i, v in ipairs ( self:getChildren () ) do
        v:setPriority ( priority )
    end
end

---
-- Specify whether to scissor test the children.
---@param scissorRect scissorRect
function Group:setScissorRect ( scissorRect )
    -- Group.__index.setScissorRect ( self, scissorRect )
    self:getProp ():setScissorRect ( scissorRect )

    for i, child in ipairs ( self:getChildren () ) do
        if child.setParentScissorRect then
            child:setParentScissorRect ( scissorRect )
        else
            child:setScissorRect ( scissorRect )
        end
    end
end

function Group:setParentScissorRect ( parentRect )
    self.parentScissorRect = parentRect

    if self.contentScissorRect then
        self.contentScissorRect:setScissorRect ( self.parentScissorRect )
    else
        self:setScissorRect ( self.parentScissorRect )
    end
end

---
-- Specify whether to scissor test the children.
-- If the group is moved, scissorRect to move.
---@param enabled enabled
function Group:setScissorContent ( enabled )
    if enabled then
        self.contentScissorRect = MOAIScissorRect.new ()
        self.contentScissorRect:setRect ( 0, 0, self:getWidth (), self:getHeight () )
        self.contentScissorRect:setScissorRect ( self.parentScissorRect )
        self.contentScissorRect:setAttrLink ( MOAITransform.INHERIT_TRANSFORM, self, MOAITransform.TRANSFORM_TRAIT )
        self:setScissorRect ( self.contentScissorRect )
    else
        self.contentScissorRect = nil
        self:setScissorRect ( self.parentScissorRect )
    end
end

return Group