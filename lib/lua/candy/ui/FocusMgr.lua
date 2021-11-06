-- import
local SignalModule = require 'candy.signal'
local GlobalManagerModule = require 'candy.GlobalManager'
local GlobalManager = GlobalManagerModule.GlobalManager

---@class FocusMgr : GlobalManager
local FocusMgr = CLASS: FocusMgr ( GlobalManager )

---
-- Constructor.
function FocusMgr:__init ()
    assert ( rawget ( FocusMgr, _singleton ) == nil )
    self.focusObject = nil
end

---
-- Set the focus object.
---@param object focus object.
function FocusMgr:setFocusObject ( object )
    if self.focusObject == object then
        return
    end

    local oldFocusObject = self.focusObject
    self.focusObject = object

    if oldFocusObject then
        SignalModule.emitGlobalSignal ( UIEvent.focus_out, oldFocusObject )
        oldFocusObject:dispatchEvent ( UIEvent.focus_out ) -- dispatchEvent
    end
    if self.focusObject then
        SignalModule.emitGlobalSignal ( UIEvent.focus_in, self.focusObject )
        self.focusObject:dispatchEvent ( UIEvent.focus_in ) -- dispatchEvent
    end
end

---
-- Return the focus object.
---@return focus object.
function FocusMgr:getFocusObject ()
    return self.focusObject
end

FocusMgr ()

return FocusMgr