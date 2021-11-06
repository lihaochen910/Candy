----------------------------------------------------------------------------------------------------
-- Layer class for the Widget.
--
-- <h4>Extends:</h4>
-- <ul>
--   <li><a href="flower.Layer.html">Layer</a><l/i>
-- </ul>
--
-- @author Makoto
-- @release V3.0.0
----------------------------------------------------------------------------------------------------

-- import
local Layer = require 'candy.Layer'
local TextAlign = require 'candy.ui.TextAlign'
local UIComponent = require 'candy.ui.UIComponent'
local FocusMgr = require 'candy.ui.FocusMgr'

---@class UILayer : Layer
local UILayer = CLASS: UILayer ( Layer )

---
-- The constructor.
---@param viewport (option)viewport
function UILayer:__init ( viewport )
    UILayer.__super.__init ( self, viewport )
    self.focusOutEnabled = true
    self.focusMgr = FocusMgr.getInstance ()

    self:setSortMode ( MOAILayer.SORT_PRIORITY_ASCENDING )
    self:setSortScale ( 1,1,1 )
    self:setTouchEnabled ( true )
    self:addEventListener ( UIEvent.touch_down, self.onTouchDown, self, 10 )
end

---
-- Sets the scene for layer.
---@param scene scene
function UILayer:setScene ( scene )
    if self.scene == scene then
        return
    end

    if self.scene then
        self.scene:removeEventListener ( UIEvent.STOP, self.onSceneStop, self, -10 )
    end

    UILayer.__super.setScene ( self, scene )

    if self.scene then
        self.scene:addEventListener ( UIEvent.STOP, self.onSceneStop, self, -10 )
    end
end

function UILayer:onTouchDown ( e )
    if self.focusOutEnabled then
        self.focusMgr:setFocusObject ( nil )
    end
end

---
-- This event handler is called when you start the scene.
---@param e Scene Event
function UILayer:onSceneStart ( e )
    -- TODO:
end

---
-- This event handler is called when you stop the scene.
---@param e Scene Event
function UILayer:onSceneStop ( e )
    self.focusMgr:setFocusObject ( nil )
end

return UILayer