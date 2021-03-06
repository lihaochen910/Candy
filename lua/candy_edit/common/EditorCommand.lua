module 'candy_edit'

require 'candy_editor'

--------------------------------------------------------------------
--Editor Command
--------------------------------------------------------------------
CLASS: EditorCommand ()
function EditorCommand.register( clas, name )
	_stat( 'from Lua register Editor Command', name )
	candy_editor.registerLuaEditorCommand( name, clas )
	clas._commandName = name
end

function EditorCommand:init( option )
end

function EditorCommand:redo()
end

function EditorCommand:undo()
end

function EditorCommand:hasHistory()
	return true
end

function EditorCommand:canUndo()
	return true
end

function EditorCommand:toString()
	return self._commandName
end

function EditorCommand:getResult()
	return nil
end


--------------------------------------------------------------------
CLASS: EditorCommandNoHistory (EditorCommand)
	:MODEL{}

function EditorCommandNoHistory:hasHistory()
	return false
end


--------------------------------------------------------------------
CLASS: EditorCommandNoUndo (EditorCommand)
	:MODEL{}

function EditorCommandNoUndo:canUndo()
	return false
end

