--_C.showAlertMessage("Debug", 'start load SceneView.lua')

--require 'candy.env'
local candy_edit = require 'candy_edit'
--
----------------------------------------------------------------------
local view = false

function onSceneOpen ( scene )
	-- local ctx = gii.getCurrentRenderContext()
	local gameActionRoot = candy.game:getActionRoot ()
	candy_editor.setCurrentRenderContextActionRoot ( gameActionRoot )

	--if not candy_editor.contextName then candy_editor.contextName = 'game' end
	--if not candy_editor._delegate then candy_editor._delegate = _candyEditorSceneView.canvas.delegate end

	view = candy_edit.createSceneView ( scene, _C )
	view.updateCanvas = function ()
		_candyEditorSceneView.scheduleUpdate ()
	end

	--view:registerDragFactory( candy_edit.ProtoDragInFactory() )
	--view:registerDragFactory( candy_edit.TextureDragInFactory() )
	--view:registerDragFactory( candy_edit.DeckDragInFactory() )

	scene:addEntity ( view )
	view:makeCurrent ()
end

function onSceneClose ()
	view = false
end

function onResize ( w, h )
	if view then
		view:onCanvasResize ( w, h )
		--candy_edit.updateMOAIGfxResource()
	end
end
