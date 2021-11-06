----------------------------------------------------------------------------------------------------
-- This class is an Image that can be pressed.
--
-- <h4>Extends:</h4>
-- <ul>
--   <li><a href="flower.widget.Button.html">Button</a><l/i>
-- </ul>
--
-- @author Makoto
-- @release V3.0.0
----------------------------------------------------------------------------------------------------

-- import
local Image = require 'candy.ui.Image'
local Button = require 'candy.ui.Button'

---@class ImageButton : Button
local ImageButton = CLASS: ImageButton ( Button )

---
-- Initializes the internal variables.
function ImageButton:_initInternal ()
    ImageButton.__super._initInternal ( self )
    self._themeName = "ImageButton"
end

---
-- Create the buttonImage.
function ImageButton:_createButtonImage ()
    if self._buttonImage then
        return
    end
    local imagePath = assert ( self:getImagePath () )
    self._buttonImage = Image ( imagePath )
    self:addChild ( self._buttonImage )
end

---
-- Update the imageDeck.
function ImageButton:updateButtonImage ()
    local imagePath = assert ( self:getImagePath () )

    self._buttonImage:setTexture ( imagePath )
    self:setSize ( self._buttonImage:getSize () )
end

return ImageButton