-- import
local SignalModule = require 'candy.signal'
local ComponentModule = require 'candy.Component'
local Component = ComponentModule.Component
local CameraManagerModule = require 'candy.gfx.CameraManager'
local CameraPassModule = require 'candy.gfx.CameraPass'
local SceneCameraPass = CameraPassModule.SceneCameraPass
local RenderTargetModule = require 'candy.RenderTarget'
local RenderTarget = RenderTargetModule.RenderTarget
local RenderManagerModule = require 'candy.RenderManager'

SignalModule.registerGlobalSignals {
	'camera.viewport_update'
}

local insert = table.insert
local remove = table.remove


---------------------------------------------------------------------
---@class Camera : Component
local Camera = CLASS: Camera ( Component )
	:MODEL {
		Field 'active'           :boolean() :isset('Active') ;
		Field 'zoom'             :number()  :getset('Zoom')   :range(0) :meta{ step = 0.1} ;
		'----';
		Field 'perspective'      :boolean() :isset('Perspective');
		Field 'nearPlane'        :number()  :getset('NearPlane');
		Field 'farPlane'         :number()  :getset('FarPlane');
		Field 'FOV'              :number()  :getset('FOV')  :range( 0, 360 ) :widget( 'slider' );
		'----';
		Field 'priority'         :int()     :getset('Priority');
		Field 'excludedLayers'   :collection( 'layer' ) :getset('ExcludedLayers');
		Field 'parallaxEnabled'  :boolean() :isset('ParallaxEnabled') :label('parallax');
		'----';
		Field 'clearBuffer'      :boolean();
		Field 'clearColor'       :type( 'color' ) :getset( 'ClearColor' );
		'----';
		Field 'showDebugLines'   :boolean() :set( 'setShowDebugLines' );
		'----';
		Field 'outputTarget'     :asset('render_target')  :getset('OutputRenderTargetPath');
	}
	:META {
		category = 'camera'
	}

wrapWithMoaiTransformMethods ( Camera, '_camera' )

local function nilFunc () end

local function _cameraZoomControlNodeCallback ( node )
	return node.camera:updateZoom ()
end

function Camera:__init ( option )
	option = option or {}
	self.clearBuffer = true
	self.clearColor = { 0,0,0,1 }
	self.clearColorNode = MOAIColor.new ()
	self.clearColorNode:setColor ( self.clearColor[ 1 ], self.clearColor[ 2 ], self.clearColor[ 3 ], self.clearColor[ 4 ] )

	local cam = markRenderNode ( MOAICamera.new () )
	self._camera = cam
	self._active = true
	cam.source = self

	---framebuffer & viewports
	self.renderTarget = RenderTarget ()
	self.renderTarget:setMode ( 'relative' )

	self.outputRenderTarget     = false
	self.outputRenderTargetPath = false

	--zoom control
	self.zoomControlNode = MOAIScriptNode.new ()
	self.zoomControlNode:reserveAttrs ( 1 )
	self.zoomControlNode.camera = self
	self:setZoom ( 1 )

	--layer control
	self.mainCamera   = false
	self.renderLayers = {}
	self.priority     = option.priority or 0
	
	self.dummyLayer = MOAITableViewLayer.new ()  --just for projection transform
	self.dummyLayer:setViewport ( self:getMoaiViewport () )
	self.dummyLayer:setCamera ( self._camera )

	self.includedLayers = option.included or 'all'
	self.excludedLayers = {}

	self.passGroupStates = {}
	
	--extra
	self.imageEffects = {}
	self.hasImageEffect = false

	self:_initDefault ()
	self._renderCommandTable = false
	self._renderPass = RenderManagerModule.createTableRenderLayer ()
	self._baseMaterialBatch = false
end

function Camera:_initDefault ()
	-- self:setOutputRenderTarget( false )
	
	self:setFOV ( 90 )
	local defaultNearPlane, defaultFarPlane = -10000, 10000
	self:setNearPlane( defaultNearPlane )
	self:setFarPlane ( defaultFarPlane )
	self:setPerspective ( false )

	self.context = 'game'

	self.parallaxEnabled = true
	self.showDebugLines  = false

	self.passes = {}
	self._active = true

end

function Camera:detectRenderContext ()
	return self.scene:getMainRenderContext ()
end

function Camera:onAttach ( entity )
	self.scene = entity.scene
	self._renderContext = assert ( self:detectRenderContext () )

	self:updateOutputRenderTarget ()
	self.zoomControlNode:setCallback ( _cameraZoomControlNodeCallback )
	entity:_attachTransform ( self._camera, "render" )
	self:updateViewport ()
	self:bindSceneLayers ()
	self:reloadPasses ( true )

	if game:isEditorMode () then
		CameraManagerModule.getCameraManager ():register ( self )
		self:setShowDebugLines ( self.showDebugLines )
	end
end

function Camera:onStart ( entity )
	if self.scene.FLAG_PREVIEW_SCENE and not entity.FLAG_EDITOR_OBJECT then
		return
	end

	if not game:isEditorMode () then
		CameraManagerModule.getCameraManager ():register ( self )
		self:setShowDebugLines ( self.showDebugLines )
	end
end

function Camera:onDetach ( entity )
	for _, pass in pairs ( self.passes ) do
		pass:release ()
	end
	self.renderTarget:setParent ( nil )
	self.renderTarget:clear ()
	self.passes = {}
	CameraManagerModule.getCameraManager ():unregister ( self )
	self.zoomControlNode:setCallback ( nilFunc )
	self.zoomControlNode.camera = nil
	self.zoomControlNode = nil
	self.dummyLayer = nil
	self._camera.source = nil
	self._camera = nil
	self._renderCommandTable = nil
	self._renderContext = nil
	self.scene = false
end

function Camera:getRenderContext ()
	return self._renderContext
end

function Camera:getRenderPass ()
	return self._renderPass
end

function Camera:getBaseMaterialBatch ()
	if not self._baseMaterialBatch then
		self._baseMaterialBatch = MOAIMaterialBatch.new ()
		self._renderPass:setMaterialBatch ( self._baseMaterialBatch )
	end

	return self._baseMaterialBatch
end

function Camera:buildRenderCommandTable ( force )
	if self._renderCommandTable and not force then
		return self._renderCommandTable
	end
	 local renderCommandTable = CameraPassModule.buildCameraRenderCommandTable ( self )
	 self._renderCommandTable = renderCommandTable
	return renderCommandTable
end

function Camera:updateRenderTarget ()
	if not self.outputRenderTarget then
		self:setOutputRenderTarget ( false )
	end
end

-- function Camera:setActive( active )
-- 	self._active = active
-- 	self:updateRenderLayers()
-- end

--------------------------------------------------------------------
--will affect Entity:wndToWorld

--TODO: update camera bindings if camera changes
function Camera:rebuildRenderPass ()
	return self:buildRenderPass ( true )
end

function Camera:buildRenderPass ( force )
	if force then
		self._renderCommandTable = false
	end

	if not self._renderCommandTable then
		self._renderCommandTable = buildCameraRenderPass ( self )
		self._renderPass:setRenderTable ( self._renderCommandTable )
	end

	return self._renderPass
end

function Camera:bindSceneLayers ()
	local scene = self.scene
	if not scene then return end	
	for k, layer in pairs ( scene.layers ) do
		self:tryBindSceneLayer ( layer )
	end	
end

function Camera:tryBindSceneLayer ( layer )
	local name = layer.name
	if self:isLayerIncluded ( name ) then
		layer:setViewport ( self:getMoaiViewport () )
		layer:setCamera ( self._camera )
		-- _log ( "Camera tryBindSceneLayer ", name, layer )
	end
end

function Camera:reloadPasses ( init )
	for i, pass in ipairs ( self.passes ) do
		pass:release ()
	end
	self.passes = {}
	self:loadPasses ()
	self:rebuildRenderPass ()

	--update group active state
	if init then
		for i, pass in ipairs ( self.passes ) do
			for id, groupState in pairs ( pass.groupStates ) do
				self.passGroupStates[ id ] = groupState
			end
		end
	else
		for id, active in pairs ( self.passGroupStates ) do
			for i, pass in ipairs ( self.passes ) do
				pass:setGroupActive ( id, active )
			end
		end
	end
end

function Camera:loadPasses ()
	self:addPass ( SceneCameraPass ( self.clearBuffer, self.clearColorNode ) )
end

function Camera:addPass ( pass )
	pass:init ( self )
	table.insert ( self.passes, pass )
	return pass
end

function Camera:onBuildPass ( pass )
end

function Camera:setPassGroupActive ( id, active )
	self.passGroupStates[ id ] = active
	for i, pass in ipairs ( self.passes ) do
		pass:setGroupActive ( id, active )
	end
end

function Camera:isPassGroupActive ( id )
	return self.passGroupStates[ id ]
end

--------------------------------------------------------------------
function Camera:isEditorCamera ()
	return false
end

function Camera:isLayerIncluded ( name, allowEditorLayer )
		return self:_isLayerIncluded ( name, allowEditorLayer ) or (not self:_isLayerExcluded ( name, allowEditorLayer ))
end 

--internal use
function Camera:_isLayerIncluded ( name, allowEditorLayer )
	if name == 'CANDY_EDITOR_LAYER' and not allowEditorLayer then return false end
	if self.includedLayers == 'all' then return nil end
	for i, n in ipairs ( self.includedLayers ) do
		if n == name then return true end
	end
	return false
end

--internal use
function Camera:_isLayerExcluded ( name, allowEditorLayer )
	if allowEditorLayer == nil then
		allowEditorLayer =  self.__allowEditorLayer
	end
	if name == 'CANDY_EDITOR_LAYER' and not allowEditorLayer then return true end
	if self.excludedLayers == 'all' then return true end
	if not self.excludedLayers then return false end
	for i, n in ipairs ( self.excludedLayers ) do
		if n == name then return true end
	end
	return false
end

function Camera:updateLayerVisible ()
	for i, pass in ipairs ( self.passes ) do
		pass:updateAllGroupVisible ()
	end
end

local function _prioritySortFunc ( a, b )
	local pa = a.priority or 0
	local pb = b.priority or 0
	return pa < pb
end

function Camera:reorderRenderLayers ()
	local layers = self.renderLayers 
	for i, layer in ipairs ( layers ) do
		local src = layer.source
		layer.priority = src and src.priority
	end
	table.sort ( layers, _prioritySortFunc )
end

function Camera:getRenderLayer ( name )
	for i, layer in ipairs ( self.renderLayers ) do
		if layer.name == name then return layer end
	end
	return nil
end

function Camera:getExcludedLayers ()
	return self.excludedLayers
end

function Camera:setExcludedLayers ( layers )
	self.excludedLayers = layers
	if self.scene then self:updateRenderLayers () end
end

--------------------------------------------------------------------
function Camera:getPriority ()
	return self.priority
end

function Camera:setPriority ( p )
	local p = p or 0
	if self.priority ~= p then
		self.priority = p
		CameraManagerModule.getCameraManager ():reorderCameras ()
	end
end

--------------------------------------------------------------------
function Camera:setPerspective ( p )
	self.perspective = p
	local ortho = not p
	local cam = self._camera	
	cam:setOrtho ( ortho )
	if not ortho then --perspective
		cam:setFieldOfView ( 90 )
	else 
		
	end
	self:updateZoom ()
end

function Camera:isPerspective ()
	return self.perspective
end

-------------------------------------------------------------------
function Camera:setParallaxEnabled ( p )
	self.parallaxEnabled = p~=false
	if self.scene then
		self:updateRenderLayers ()
	end
end

function Camera:isParallaxEnabled ()
	return self.parallaxEnabled
end

--------------------------------------------------------------------
function Camera:setShowDebugLines ( show )
	self.showDebugLines = show ~= false
	if self.scene then
		for i, pass in ipairs ( self.passes ) do
			pass:setShowDebugLayers ( show )
		end
	end
end

function Camera:isShowDebugLines ()
	return self.showDebugLines
end

--------------------------------------------------------------------

function Camera:setNearPlane ( near )
	local cam = self._camera
	self.nearPlane = near
	cam:setNearPlane ( near )
end

function Camera:setFarPlane ( far )
	local cam = self._camera
	self.farPlane = far
	cam:setFarPlane ( far )
end

function Camera:getFOV ()
	return self._camera:getFieldOfView ()
end

function Camera:setFOV ( fov )
	self._camera:setFieldOfView ( fov )
end

function Camera:seekFOV ( fov, duration, easeType )
	return self._camera:seekFieldOfView ( fov, duration, easeType )
end

function Camera:getNearPlane ()
	return self.nearPlane
end

function Camera:getFarPlane ()
	return self.farPlane
end
--------------------------------------------------------------------

function Camera:wndToWorld ( x, y )
	return self.dummyLayer:wndToWorld ( x, y )
end

function Camera:worldToWnd ( x, y, z )
	return self.dummyLayer:worldToWnd ( x, y, z )
end

function Camera:worldToView ( x, y, z )
	return self.dummyLayer:worldToView ( x, y, z )
end

function Camera:getScreenSize ()
	local x, y, x1, y1 = game:getViewportRect ()
	return  x1 - x, y1 - y
end

function Camera:getScreenScale ()
	return game:getViewportScale ()
end

function Camera:updateViewport ()
	self:updateZoom ()
	SignalModule.emitSignal ( 'camera.viewport_update', self )
end

function Camera:updateZoom ()
	local zoom = self:getZoom ()
	if zoom <= 0 then zoom = 1e-05 end
	self.renderTarget:setZoom ( zoom, zoom )
	-- local w, h = self:getOutputRenderTarget ():getScale ()
	-- print ( w, h )
	-- self.renderTarget:setFixedScale ( w/zoom, h/zoom )
	-- local sw, sh = self:getScreenScale ()
	-- if not sw then return end
	-- self.renderTarget:setScale ()
	-- local w, h   = sw / zoom, sh / zoom
	-- if self.perspective then
	-- 	local dx,dy,dx1,dy1 = self:getScreenRect ()
	-- 	local dw = dx1-dx
	-- 	local dh = dy1-dy
	-- 	self.renderTarget:setFixedScale ( w, h )
	-- else
	-- 	self.renderTarget:setFixedScale ( w, h )
	-- end
end

function Camera:getRenderTarget ()
	return self.renderTarget
end

function Camera:getMoaiViewport ()
	return self.renderTarget:getMoaiViewport ()
end

function Camera:getViewportSize ()
	return self.renderTarget:getScale ()
end

function Camera:getViewportRect ()
	local x0, y0, x1, y1 = self:getViewportLocalRect ()
	local cam = self._camera
	cam:forceUpdate ()
	local wx0, wy0 = cam:modelToWorld ( x0, y0 )
	local wx1, wy1 = cam:modelToWorld ( x1, y1 )
	return wx0, wy0, wx1, wy1
end

function Camera:getViewportLocalRect ()
	local w, h = self:getViewportSize ()
	return -w/2, -h/2, w/2, h/2
end

function Camera:getViewportWndRect ()
	return self.renderTarget:getAbsPixelRect ()
end

function Camera:getViewportWndSize ()
	return self.renderTarget:getPixelSize ()
end

function Camera:getClearColor ()
	return self.clearColorNode:getColor ()
end

function Camera:setClearColor ( r,g,b,a )
	self.clearColorNode:setColor ( r, g, b, a )
end

--------------------------------------------------------------------
--Layer control
--------------------------------------------------------------------
function Camera:bindLayers ( included )
	for i, layerName in ipairs ( included ) do
		local layer = self.scene:getLayer ( layerName )
		if not layer then error ('no layer named:'..layerName,2) end
		layer:setCamera ( self._camera )
	end
end

function Camera:bindAllLayerExcept ( excluded )
	for k, layer in pairs ( self.scene.layers ) do
		local match = false
		for i, n in ipairs ( excluded ) do
			if layer.name == n then match = true break end
		end
		if not match then layer:setCamera ( self._camera ) end
	end
end

function Camera:hideLayer ( layerName )
	return self:showLayer ( layerName, false )
end

function Camera:hideAllLayers ( layerName )
	return self:showAllLayers ( layerName, false )
end

function Camera:showAllLayers ( layerName, shown )
	shown = shown ~= false
	for i, layer in ipairs ( self.renderLayers ) do
		layer:setVisible ( shown )
	end
end

function Camera:showLayer ( layerName, shown )
	shown = shown ~= false
	for i, layer in ipairs ( self.renderLayers ) do
		if layer.name == layerName then
			layer:setVisible ( shown )
		end
	end
end

----
function Camera:seekZoom ( zoom, time, easeMode )
	return self.zoomControlNode:seekAttr ( 1, zoom, time, easeMode )
end

function Camera:moveZoom ( zoom, time, easeMode )
	return self.zoomControlNode:seekAttr ( 1, zoom + self:getZoom (), time, easeMode )
end

function Camera:setZoom ( zoom )
	return self.zoomControlNode:setAttr ( 1, zoom or 1 )
end

function Camera:getZoom ()
	return self.zoomControlNode:getAttr ( 1 )
end

function Camera:setPriority ( p )
	self.priority = p or 0
	CameraManagerModule.getCameraManager ():update ()
end

function Camera:_updateRenderCommandTable ( t )
	if t then
		self._renderCommandTable = t
	end
	local active = self._active
	if self._renderCommandTable then
		for i, command in ipairs ( self._renderCommandTable ) do
			command:setEnabled ( active )
		end
	end
end

function Camera:isActive ()
	return self._active
end

function Camera:setActive ( active )
	self._active = active ~= false
	self:_updateRenderCommandTable ()
end

--------------------------------------------------------------------
--image effect support
function Camera:addImageEffect ( imageEffect, update )
	table.insert ( self.imageEffects, imageEffect )
	self.hasImageEffect = next ( self.imageEffects ) ~= nil
	if update ~= false then self:reloadPasses () end
end

function Camera:removeImageEffect ( imageEffect, update )
	local idx = table.index ( self.imageEffects, imageEffect )
	if not idx then return end
	table.remove ( self.imageEffects, idx )
	self.hasImageEffect = next ( self.imageEffects ) ~= nil
	if update ~= false then self:reloadPasses () end
end

function Camera:setImageEffectVisible ( imageEffect )
	local idx = table.index ( self.imageEffects, imageEffect )
	if not id then return end
	--TODO: image effect activate/deactivate
end

--------------------------------------------------------------------
--output image buffer support

function Camera:getDefaultOutputRenderTarget ()
	return self._renderContext:getRenderTarget ()
end

function Camera:getOutputRenderTargetPath ()
	return self.outputRenderTargetPath
end

function Camera:setOutputRenderTargetPath ( path )
	self.outputRenderTargetPath = path
	self:updateOutputRenderTarget ()
end

function Camera:updateOutputRenderTarget ()
	if not self.scene then
		return
	end

	local target = nil

	if self.outputRenderTargetPath then
		local renderTargetTexture = candy.loadAsset ( self.outputRenderTargetPath )
		target = renderTargetTexture and renderTargetTexture:getRenderTarget ()
	end

	target = target or self:getDefaultOutputRenderTarget ()
	return self:setOutputRenderTarget ( target )
end

function Camera:setOutputRenderTarget ( target )
	target = target or self:getDefaultOutputRenderTarget ()
	self.outputRenderTarget = target

	if target then
		self.renderTarget:setFrameBuffer ( target:getFrameBuffer () )
		self.renderTarget:setParent ( target )
		self:rebuildRenderPass ()
	end
end

function Camera:getOutputRenderTarget ()
	return self.outputRenderTarget
end

function Camera:getMoaiCamera ()
	return self._camera
end

function Camera:onDrawGizmo ()
	-- GIIHelper.setVertexTransform ( self._camera )
	candy_edit.applyColor ( 'camera-bound' )
	local x0,y0,x1,y1 = self:getViewportLocalRect ()
	MOAIDraw.drawRect ( x0,y0,x1,y1 )
end

function Camera:grabNextFrame ( output )
	local tt = type ( output )
	if tt == 'string' then
		grabNextFrameToFile ( output, self:getOutputRenderTarget ():getFrameBuffer () )
	elseif tt == 'userdata' then
		--TODO
		self:getOutputRenderTarget ():getFrameBuffer ():grabNextFrame ( output )
	end
end

function Camera:grabCurrentFrame ( output )
	local tt = type ( output )
	if tt == 'string' then
		return grabCurrentFrameToFile ( output, self:getOutputRenderTarget ():getFrameBuffer () )
	elseif tt == 'userdata' then
		self:getOutputRenderTarget ():getFrameBuffer ():grabCurrentFrame ( output )
		return output
	elseif tt == 'nil' then
		local img = MOAIImage.new ()
		self:getOutputRenderTarget ():getFrameBuffer ():grabCurrentFrame ( img )
		return img

	end
end

--------------------------------------------------------------------
wrapWithMoaiTransformMethods ( Camera, '_camera' )

ComponentModule.registerComponent ( 'Camera', Camera )
ComponentModule.registerEntityWithComponent ( 'Camera', Camera )

--------------------------------------------------------------------
--EDITOR Support
function Camera:onBuildGizmo ()
	local iconGiz = candy_edit.IconGizmo ( 'camera.png' )
	local drawGiz = candy_edit.DrawScriptGizmo ()
	return iconGiz, drawGiz
end

return Camera
