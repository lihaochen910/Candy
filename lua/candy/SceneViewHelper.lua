--_C.showAlertMessage("Debug", 'start load SceneViewHelper.lua')

print('start load SceneViewHelper.lua')

--require 'candy.env'
require 'candy_edit'
--
----------------------------------------------------------------------
view = false

function onSceneOpen( scene )
	-- local ctx = gii.getCurrentRenderContext()
	-- local gameActionRoot = game:getActionRoot()
	-- gii.setCurrentRenderContextActionRoot( game:getActionRoot() )
	view = candy_edit.createSceneView( scene, _M )
	view.updateCanvas = function()
		_candyEditorSceneView.scheduleUpdate()
	end

	view:registerDragFactory( candy_edit.ProtoDragInFactory() )
	view:registerDragFactory( candy_edit.TextureDragInFactory() )
	view:registerDragFactory( candy_edit.DeckDragInFactory() )

	scene:addEntity( view )
	view:makeCurrent()
end

function onSceneClose()
	view = false
end

function onResize( w, h )
	if view then
		view:onCanvasResize( w, h )
		candy_edit.updateMOAIGfxResource()
	end
end
