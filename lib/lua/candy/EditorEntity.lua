local EntityModule = require 'candy.Entity'

--------------------------------------------------------------------
---@class EditorEntity
local EditorEntity = CLASS: EditorEntity ( EntityModule.Entity )

function EditorEntity:__init ()
	self.layer = 'CANDY_EDITOR_LAYER'
	self.FLAG_EDITOR_OBJECT = true
end

--------------------------------------------------------------------
function resetFieldDefaultValue ( obj, fid )
	local model = Model.fromObject ( obj )
	if not model then return false end
	local field = model:getField ( fid )
	if not field then return false end
	field:resetDefaultValue ( obj )
	return true
end

return EditorEntity