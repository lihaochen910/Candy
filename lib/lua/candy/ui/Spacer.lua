----------------------------------------------------------------------------------------------------
-- Component class to fill the space.
--
-- @author Makoto
-- @release V3.0.0
----------------------------------------------------------------------------------------------------

-- import
local UIComponent = require 'candy.ui.UIComponent'

---@class Spacer : UIComponent
local Spacer = CLASS: Spacer ( UIComponent )

---
-- Initialization is the process of internal variables.
function Spacer:_initInternal ()
    Spacer.__super._initInternal ( self )
    self._focusEnabled = false
end

return Spacer