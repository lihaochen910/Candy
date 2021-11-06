
---@class AnimTreeNodeBlendEntry
local AnimTreeNodeBlendEntry = CLASS: AnimTreeNodeBlendEntry ()
	:MODEL {}

function AnimTreeNodeBlendEntry:__init ()
end

---@class AnimTreeNodeBlend : AnimTreeNode
local AnimTreeNodeBlend = CLASS: AnimTreeNodeBlend ( AnimTreeNode )
	:MODEL {}

function AnimTreeNodeBlend:__init ()
end

function AnimTreeNodeBlend:getTypeName ()
	return "blend"
end
