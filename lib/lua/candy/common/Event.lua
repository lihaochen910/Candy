---@class Event
local Event = CLASS: Event ()

---
-- Event's constructor.
---@param eventType (option)The type of event.
function Event:__init ( eventType )
    self.type = eventType
    self.stopFlag = false
end

---
-- INTERNAL USE ONLY -- Sets the event listener via EventDispatcher.
---@param callback callback function
---@param source source object.
function Event:setListener ( callback, source )
    self.callback = callback
    self.source = source
end

---
-- Stop the propagation of the event.
function Event:stop ()
    self.stopFlag = true
end

return Event