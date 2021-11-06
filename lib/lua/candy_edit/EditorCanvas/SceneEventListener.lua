-- import
local EditorEntity = require "candy.EditorEntity"

---@class SceneEventListener : EditorEntity
local SceneEventListener = CLASS: SceneEventListener ( EditorEntity )
	:MODEL {}

function SceneEventListener:onEntityEvent ( ev, entity, com )
end

function SceneEventListener:onSelectionChanged ( selection )
end

return SceneEventListener