-- import
local candy_editor = require 'candy_editor'

-- module
local EditorCommandModule = {}

--------------------------------------------------------------------
--Editor Command
--------------------------------------------------------------------
---@class EditorCommand
local EditorCommand = CLASS: EditorCommand ()

function EditorCommand.register ( clas, name )
	--print ( 'from Lua register Editor Command', name, clas, candy_editor.registerLuaEditorCommand )
	candy_editor.registerLuaEditorCommand ( name, clas )
	clas._commandName = name
	return clas
end

function EditorCommand:init ( option )
end

function EditorCommand:redo ()
end

function EditorCommand:undo ()
end

function EditorCommand:hasHistory ()
	return true
end

function EditorCommand:canUndo ()
	return true
end

function EditorCommand:toString ()
	return self._commandName
end

function EditorCommand:getResult ()
	return nil
end


--------------------------------------------------------------------
---@class EditorCommandNoHistory : EditorCommand
local EditorCommandNoHistory = CLASS: EditorCommandNoHistory ( EditorCommand )
	:MODEL {}

function EditorCommandNoHistory:hasHistory ()
	return false
end


--------------------------------------------------------------------
---@class EditorCommandNoUndo : EditorCommand
local EditorCommandNoUndo = CLASS: EditorCommandNoUndo ( EditorCommand )
	:MODEL {}

function EditorCommandNoUndo:canUndo ()
	return false
end


EditorCommandModule.EditorCommand = EditorCommand
EditorCommandModule.EditorCommandNoHistory = EditorCommandNoHistory
EditorCommandModule.EditorCommandNoUndo = EditorCommandNoUndo

return EditorCommandModule