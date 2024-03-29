-- import
local candy = require "candy"
local EditorCommandModule = require 'candy_edit.common.EditorCommand'
local CanvasView = require 'candy_edit.EditorCanvas.CanvasView'

-- module
local SceneViewModule = {}

local function prioritySortFunc ( a, b )
	return  a._priority < b._priority
end

--------------------------------------------------------------------
local currentSceneView = false

function getCurrentSceneView ()
	return currentSceneView
end

function startAdhocSceneTool ( toolID, context )
	if not currentSceneView then return false end
	return currentSceneView:startAdhocTool ( toolID, context )
end

function stopAdhocSceneTool ( toolID ) 
	if not currentSceneView then return false end
	return currentSceneView:stopAdhocTool ()
end


--------------------------------------------------------------------
---@class SceneViewDrag
local SceneViewDrag = CLASS: SceneViewDrag ()
	:MODEL {}

function SceneViewDrag:onStart ( view, x, y )
	-- print( 'start drag', x, y )
end

function SceneViewDrag:onMove ( view, x, y )
	-- print( 'moving drag', x, y )
end

function SceneViewDrag:onFinish ( view, x, y )
	-- print( 'finishing drag', x, y )
end

function SceneViewDrag:onStop ( view )
	-- print( 'stop drag' )
end

--------------------------------------------------------------------
---@class SceneViewDragFactory
local SceneViewDragFactory = CLASS: SceneViewDragFactory ()
	:MODEL {}

function SceneViewDragFactory:create ( view, mimeType, data, x, y )
	return false 
end


--------------------------------------------------------------------
---@class SceneView : CanvasView
local SceneView = CLASS: SceneView ( CanvasView )

function SceneView:__init()
	self.dragFactoryList = {}
end

function SceneView:onInit ()
	self:connect ( 'scene.pre_serialize', 'preSceneSerialize' )
	self:connect ( 'scene.post_deserialize', 'postSceneDeserialize' )
	self:readConfig ()
	self.gizmoManager:updateConstantSize ()
	self.itemManager:updateAllItemScale ()
	self.activeDrags = {}
end

function SceneView:registerDragFactory ( factory, priority )
	factory._priority = priority or 0
	table.insert ( self.dragFactoryList, factory )
	table.sort ( self.dragFactoryList, prioritySortFunc )
end

function SceneView:readConfig ()
	local cfg = self.scene:getMetaData ( 'scene_view' )
	if cfg then
		local cameraCfg = cfg[ 'camera' ]
		if cameraCfg then
			self.camera:setLoc ( unpack ( cameraCfg[ 'loc' ] ) )
			self.navi.zoom = cameraCfg[ 'zoom' ]
			local cameraCom = self.camera:getComponent ( candy_edit.EditorCanvasCamera )
			cameraCom:setZoom ( cameraCfg[ 'zoom' ] )
		end
		local gridCfg = cfg[ 'grid' ]
		if gridCfg then
			self:setGridSize ( unpack ( gridCfg[ 'size' ] or { 100, 100 } ) )
			self:setGridVisible ( gridCfg[ 'visible' ]~=false )
			self:setGridSnapping ( gridCfg[ 'snap' ]==true )
		end
	else
		self:loadDefaultConfig ()
	end
end

function SceneView:loadDefaultConfig ()

end

function SceneView:saveConfig ()
	local cam = self.camera
	local cfg = {}
	self.scene:setMetaData ( 'scene_view', cfg )
	---
	cfg[ 'camera' ] = {
		loc = { cam:getLoc () },
		zoom = cam:getComponent ( candy_edit.EditorCanvasCamera ):getZoom (),
	}
	---
	cfg[ 'grid' ] = {
		size = { self:getGridSize () },
		visible = self:isGridVisible (),
		snap = self:isGridSnapping ()
	}
	---
	cfg[ 'gizmo' ] = {
		visible = self:isGizmoVisible ()
	}
end

function SceneView:focusSelection ()
	local selection = candy_editor.getSelection ( 'scene' )
	for _, a in ipairs ( selection ) do
		if isInstance ( a, candy.Entity ) then
			self.camera:setLoc ( a:getWorldLoc () )
		end
	end
	--todo: fit viewport to entity bound/ multiple selection
	self:updateCanvas ()
end

function SceneView:preSceneSerialize ( scene )
	if scene ~= self.scene then return end
	self:saveConfig ()
end

function SceneView:postSceneDeserialize ( scene )
	if scene ~= self.scene then return end
	self.gizmoManager:refresh ()
	self.pickingManager:refresh ()
end

function SceneView:makeCurrent ()
	currentSceneView = self
end

function SceneView:onDestroy ()
	if currentSceneView == self then
		currentSceneView = false
	end
end

function SceneView:pushObjectAttributeHistory ()
end

function SceneView:startDrag ( mimeType, dataString, x, y )
	local accepted = false
	local data = MOAIJsonParser.decode ( dataString )
	for i, fac in ipairs ( self.dragFactoryList ) do
		local drag = fac:create ( self, mimeType, data, x, y )
		if drag then
			drag.view = self
			local drags
			if isInstance ( drag, SceneViewDrag ) then
				drags = { drag }
			elseif type ( drag ) == 'table' then
				drags = drag
			end
			for _, drag in ipairs ( drags ) do
				if isInstance ( drag, SceneViewDrag ) then
					self.activeDrags[ drag ] = true
					drag:onStart ( self, x, y )
					accepted = true
				else
					_warn ( 'unkown drag type' )
				end
			end
			if accepted then return true end
		end
	end
	return false
end

function SceneView:stopDrag ()
	for drag in pairs ( self.activeDrags ) do
		drag:onStop ( self )
	end
	self.activeDrags = {}
end

function SceneView:finishDrag ( x, y )
	for drag in pairs ( self.activeDrags ) do
		drag:onFinish ( self, x, y )
	end
	self.activeDrags = {}
end

function SceneView:moveDrag ( x, y )
	for drag in pairs ( self.activeDrags ) do
		drag:onMove ( self, x, y )
	end
end

function SceneView:disableCamera ()
	self:getCameraComponent ():setActive ( false )
end

function SceneView:enableCamera ()
	self:getCameraComponent ():setActive ( true )
end

function SceneView:getCurrentToolId ()
	local sceneToolManager = candy_editor.getModule ( 'scene_tool_manager' )
	if sceneToolManager then
		return sceneToolManager:getCurrentToolId ()
	end
end

function SceneView:changeTool ( id, t )
	local sceneToolManager = candy_editor.getModule ( 'scene_tool_manager' )
	if sceneToolManager then
		local dict = candy.tableToDictPlain ( t or {} )
		sceneToolManager:changeToolD ( id, dict )
	end
end

--function SceneView:startAdhocTool( id, t )
--	local sceneToolManager = candy.getModule( 'scene_tool_manager' )
--	if sceneToolManager then
--		local dict = gii.tableToDictPlain( t or {} )
--		sceneToolManager:startAdhocToolD( id, dict )
--	end
--end
--
--function SceneView:stopAdhocTool()
--	local sceneToolManager = candy.getModule( 'scene_tool_manager' )
--	if sceneToolManager then
--		sceneToolManager:stopAdhocTool()
--	end
--end


--------------------------------------------------------------------
---@class SceneViewFactory
local SceneViewFactory = CLASS: SceneViewFactory ()

function SceneViewFactory:__init ()
	self.priority = 0
end

function SceneViewFactory:createSceneView ( scene, env )
	local view = SceneView ( env )
	return view
end

--------------------------------------------------------------------

local SceneViewFactories = {}
function registerSceneViewFactory ( key, factory, priority )
	SceneViewFactories[ key ] = factory
end

function createSceneView ( scene, env )
	local factoryList = {}
	for k, f in pairs ( SceneViewFactories ) do
		table.insert ( factoryList, f )
	end
	table.sort ( factoryList, prioritySortFunc )

	for i, factory in pairs ( factoryList ) do
		local view = factory:createSceneView ( scene, env )
		if view then
			view:setName ( 'FLAG_EDITOR_SCENE_VIEW')
			return view
		end
	end
	
	--fallback
	return SceneView ( env )
end


--------------------------------------------------------------------
---@class CmdFocusSelection : EditorCommandNoHistory
local CmdFocusSelection = CLASS: CmdFocusSelection ( EditorCommandModule.EditorCommandNoHistory )
	:register ( 'scene_editor/focus_selection' )

function CmdFocusSelection:init ( option )
	local view = getCurrentSceneView ()
	if view then
		view:focusSelection ()
	end
end


SceneViewModule.SceneViewDrag = SceneViewDrag
SceneViewModule.SceneViewDragFactory = SceneViewDragFactory
SceneViewModule.SceneView = SceneView
SceneViewModule.SceneViewFactory = SceneViewFactory
SceneViewModule.registerSceneViewFactory = registerSceneViewFactory
SceneViewModule.createSceneView = createSceneView
SceneViewModule.CmdFocusSelection = CmdFocusSelection

return SceneViewModule