-- import
local RenderTargetModule = require 'candy.RenderTarget'
local RenderTarget = RenderTargetModule.RenderTarget
local RenderManagerModule = require 'candy.RenderManager'
local TextureRenderTarget = RenderTargetModule.TextureRenderTarget

-- module
local CameraPassModule = {}

--------------------------------------------------------------------
-- CameraPassResource
--------------------------------------------------------------------
---@class CameraPassResource
local CameraPassResource = CLASS: CameraPassResource ()

function CameraPassResource:__init ( name, owner, rtype, obj )
	self.name = name
	self.owner = owner
	self.rtype = rtype
	self.obj = obj
end

function CameraPassResource:asType ( targetType )
	if self:isType ( targetType ) then
		return self.obj
	else
		_warn ( "incorrect camera res type", self.name, self.rtype, targetType )
		return false
	end
end

function CameraPassResource:isType ( targetType )
	local rtype = self.rtype

	if rtype == targetType then
		return true
	end

	if targetType == "texture" then
		return rtype == "color_buffer" or rtype == "texture_target"
	elseif targetType == "render_buffer" then
		return rtype == "color_buffer"
	elseif targetType == "render_target" then
		return rtype == "texture_target"
	end

	return false
end

function CameraPassResource:release ()
	local rtype = self.rtype
	local obj = self.obj

	if rtype == "texture_target" or rtype == "render_target" or rtype == "render_buffer" then
		obj:setParent ( false )
		obj:clear ()
	end
end

function CameraPassResource:getMoaiTexture ()
	local rtype = self.rtype

	if rtype == "texture" then
		return self.obj
	elseif rtype == "texture_target" then
		return self.obj:getFrameBuffer ()
	elseif rtype == "color_buffer" then
		return self.obj:getMoaiRenderBuffer ()
	else
		_warn ( "non texture resource", self.name )
		return false
	end
end


--------------------------------------------------------------------
-- CameraPass
--------------------------------------------------------------------
local cameraPassLogEnabled = false
local cameraBatchProfiling = false
local getRenderManager = RenderManagerModule.getRenderManager

---@class CameraPass
local CameraPass = CLASS: CameraPass ()
	:MODEL {}

function CameraPass:__init ()
	self.camera = false
	self.renderTarget  = false
	self.imageEffectOutputBuffer = false
	self.resources = {}
	self.adhocRenderTargets = {}
	self.passes = {}
	self.currentRenderTarget = false
	self.defaultRenderTarget = false
	self.outputRenderTarget  = false
	self.debugLayers = {}
	self.groups = {}
	self.groupStates = {}
	self.finalizers = {}
	self.initialCopy = {}
end

function CameraPass:setGroupActive ( id, active )
	self.groupStates[ id ] = active ~= false
	local group = self.groups[ id ]
	if not group then return end
	self:updateGroupVisible( id )
end

function CameraPass:getGroups ()
	return self.groups
end

function CameraPass:getGroupStates ()
	return self.groupStates
end

function CameraPass:isGroupActive ( id )
	return self.groupStates[ id ] ~= false
end

function CameraPass:updateGroupVisible ( id )
	local group = self.groups[ id ]
	local groupVis = self.groupStates[ id ] ~= false
	local isEditorCamera = self.camera.FLAG_EDITOR_OBJECT
	for layer in pairs ( group ) do
		if not layer.FLAG_DEBUG_LAYER then
			local visible = groupVis
			if isEditorCamera then
				local src = layer.sceneLayer and layer.sceneLayer.source
				if src and layer.name ~= 'CANDY_EDITOR_LAYER' then
					local editorVisible = src.editorVisible and src.editorSolo ~= 'hidden'
					visible = visible and editorVisible or false
				end
			end
			-- layer:setVisible ( visible )
			layer:setEnabled ( visible )
		end
	end
end

function CameraPass:updateAllGroupVisible ()
	for id, group in pairs ( self.groups ) do
		self:updateGroupVisible ( id )
	end
end

function CameraPass:init ( camera )
	if self.persistent and self.inited then
		self:reuse ( camera )
		return
	end

	assert ( not self.inited )

	self.camera = camera
	self.initialCopy = {}
	self.outputRenderTarget = camera:getRenderTarget ()

	if camera.hasImageEffect and self.outputRenderTarget then
		self.defaultRenderTarget = self:buildTextureRenderTarget ( nil, self.outputRenderTarget )

		if camera.outputRenderTarget:isInstance ( TextureRenderTarget ) and not camera.clearBuffer then
			table.insert ( self.initialCopy, {
				self.defaultRenderTarget,
				camera.outputRenderTarget
			} )
		end
	else
		self.defaultRenderTarget = self.outputRenderTarget
	end

	self:onInit ()
	self.inited = true
end

function CameraPass:reuse ( camera )
	self.camera = camera
	self:onReuse ()
end

function CameraPass:setDefaultRenderTarget ( target )
	self.defaultRenderTarget = target
end

function CameraPass:setOutputRenderTarget ( target )
	self.outputRenderTarget = target
end

function CameraPass:setPersistent ( p )
	self.persistent = p ~= false
end

function CameraPass:release ()
	if self.persistent then
		return
	end

	self:onRelease ()
	self.passes = false
	self.debugLayers = false
	self.groupStates = false
	self.groups = false
	for i, finalizer in ipairs ( self.finalizers ) do
		finalizer ()
	end
	self.finalizers = false
end

function CameraPass:onRelease ()
	for key, res in pairs ( self.resources ) do
		res:release ()
	end

	for _, rt in pairs ( self.adhocRenderTargets ) do
		rt:setParent ( nil )
		rt:clear ()
	end

	self.adhocRenderTargets = {}
	self.resources = {}
	self.camera = false
end

function CameraPass:build ()
	self.passes = {}
	self.groups = {}

	self:setCurrentGroup ( "__init" )
	self:preBuild ()
	self:setCurrentGroup ( "default" )
	self:onBuild ()
	self:setCurrentGroup ( "__image_effect" )
	self:onBuildImageEffects ()
	self:setCurrentGroup ( "default" )
	self:postBuild ()
	self.camera:onBuildPass ( self )

	return self.passes
end

function CameraPass:onInit ()
end

function CameraPass:onReuse ()
end

function CameraPass:preBuild ()
	local camera = self:getCamera ()

	for i, entry in ipairs ( self.initialCopy ) do
		self:pushRenderTargetCopy ( unpack ( entry ) )
	end
end

function CameraPass:onBuild ()
end

function CameraPass:postBuild ()
end

function CameraPass:getCamera ()
	return self.camera
end

function CameraPass:getBaseMaterialBatch ()
	return self.camera:getBaseMaterialBatch ()
end

function CameraPass:getDefaultRenderTarget ()
	return self.defaultRenderTarget
end

function CameraPass:getCurrentFrameBuffer ()
	return self.currentRenderTarget:getFrameBuffer ()
end

function CameraPass:getCurrentRenderTarget ()
	return self.currentRenderTarget
end

function CameraPass:getOutputRenderTarget ()
	return self.outputRenderTarget
end

function CameraPass:setCurrentGroup ( id )
	local group = self.groups[ id ]

	if not group then
		group = {}
		self.groups[ id ] = group
		self.groupStates[ id ] = true
	end

	self.currentGroup = group
	self.currentGroupId = id

	local traceback = singletraceback ( 2 )
	self:pushLog ( "change group ->", self:getCamera (), id, traceback )
end

function CameraPass:pushPassData ( data )
	data[ 'camera' ] = self:getCamera ()
	data[ 'group'  ] = self.currentGroupId or 'default'
	data[ 'stacktrace' ] = debug.traceback ( 2 )
	table.insert ( self.passes, data )
end

function CameraPass:pushDebugDrawLayer ( layer )
	return self:pushRenderLayer ( layer, nil, true )
end

function CameraPass:pushRenderLayer ( layer, layerType, debugLayer )
	if not layer then 
		_error ( 'no render layer given!' )
		return
	end
	
	if not debugLayer then
		self.currentGroup[ layer ] = true
	end
	
	self:pushPassData {
		tag   = 'layer',
		layer = layer,
		type  = layerType or 'render'
	}
	return layer
end

function CameraPass:pushBaseScissorRect ( scissor )
	return self:pushPassData ( {
		tag = "scissor",
		scissor = scissor
	} )
end

function CameraPass:pushRenderTarget ( renderTarget, option )
	if type ( renderTarget ) == 'string' then
		local renderTargetName = renderTarget
		renderTarget = self:getRenderTarget ( renderTargetName )
		if not renderTarget then
			_error ( 'render target not found:', renderTargetName )
			return false
		end
	elseif not isInstance ( renderTarget, RenderTarget ) then
		_error ( "render target expected" )
		return false
	end

	local renderTarget = renderTarget or self:getDefaultRenderTarget ()
	self.currentRenderTarget = renderTarget
	assert ( isInstance ( renderTarget, RenderTarget ) )

	if option then
		option = table.simplecopy ( option )
		if option.clearColor == true then
			option.clearColor = { 0,0,0,0 }
		end
	else
		option = {
			clearStencil = false,
			clearDepth = false,
			clearColor = false
		}
	end

	self:pushPassData { 
		tag          = 'render-target',
		renderTarget = renderTarget,
		option       = option 
	}
end

function CameraPass:pushDefaultRenderTarget ( option )
	return self:pushRenderTarget ( self:getDefaultRenderTarget (), option )
end

function CameraPass:findPreviousRenderTarget ()
	for i = #self.passes, 1, -1 do
		local pass = self.passes[ i ]
		if pass.tag == 'render-target' then
			return pass.renderTarget
		end
	end
	return nil
end

function CameraPass:affirmRenderTarget ( target )
	if target == "__output" then
		return self.outputRenderTarget
	elseif target == "__default" then
		return self.defaultRenderTarget
	end

	local function _affirmSingleBufferTarget ( t )
		local rt = self.adhocRenderTargets[ t ]

		if not rt then
			rt = self:buildMRT ( {
				color = {
					t
				},
				scale = t.scale
			} )
			self.adhocRenderTargets[ t ] = rt
		end

		return rt
	end

	if type ( target ) == "string" then
		local res = self:getResourceItem ( target )

		if not res then
			_error ( "no resource", target )
			return false
		elseif res:isType ( "render_target" ) then
			return res.obj
		elseif res:isType ( "color_buffer" ) then
			return _affirmSingleBufferTarget ( res.obj )
		else
			_error ( "not a render target related resource", target )
			return false
		end
	elseif isInstance ( target, RenderTarget ) then
		return target
	elseif isInstance ( target, ColorRenderBuffer ) then
		return _affirmSingleBufferTarget ( target )
	else
		_error ( "invalid RenderTarget.", target )
		return false
	end
end

function CameraPass:pushRenderTargetCopy ( targetId, sourceId, scaleX, scaleY, option )
	local function _affirmRenderTargetTexture ( rt )
		if isInstance ( rt, TextureRenderTarget ) then
			return rt:getFrameBuffer()
		elseif isInstance ( rt, MRTRenderTarget ) then
			return rt:getColorBufferTexture ()
		else
			_error ( "no texture found", rt )
		end
	end

	option = option or {
		clearStencil = false,
		clearDepth = false,
		clearColor = false
	}
	local targetRT = self:affirmRenderTarget ( targetId )

	if not self:pushRenderTarget ( targetRT, option ) then
		return false
	end

	local sourceTarget = self:affirmRenderTarget ( sourceId )
	local ratio = sourceTarget:getRatio ()
	local w = 1
	local h = 1 / ratio
	local copyProp = self:buildSimpleQuadProp ( w, h, _affirmRenderTargetTexture ( sourceTarget ) )
	local scaleX = scaleX or 1
	local scaleY = scaleY or 1
	local ox = (1 - scaleX) / 2
	local oy = (1 - scaleY) / 2

	setPropBlend ( copyProp, "solid" )
	copyProp:setScl ( scaleX, scaleY )
	copyProp:setLoc ( -ox, oy )

	local copyLayer = self:buildSimpleOrthoRenderLayer ( w, h, false )

	copyProp:setPartition ( copyLayer )
	self:pushFinalizer ( function ()
		copyProp:setPartition ( nil )
	end )
	self:pushRenderLayer ( copyLayer )

	return copyLayer, copyProp
end

function CameraPass:addResource ( name, type, obj )
	if self.resources[ name ] then
		error ( "duplicated resource", name )
	end

	self.resources[ name ] = CameraPassResource ( name, self, type, obj )
	return obj
end

function CameraPass:getResourceItem ( name )
	return self.resources[ name ]
end

function CameraPass:getResource ( name, targetType )
	local resItem = self.resources[ name ]

	if not resItem then
		_warn ( "no resource", name )
	else
		return resItem:asType ( targetType )
	end
end

function CameraPass:getTexture ( name )
	local resItem = self:getResourceItem ( name )
	return resItem:getMoaiTexture ()
end

function CameraPass:getRenderBuffer ( name )
	return self:getResource ( name, "render_buffer" )
end


----
--Render Targets
function CameraPass:getRenderTarget ( name )
	if name == "__output" then
		return self.outputRenderTarget
	elseif name == "__default" then
		return self.defaultRenderTarget
	else
		return self:getResource ( name, "render_target" )
	end
end

function CameraPass:getRenderTargetTexture ( name )
	local resItem = self:getResourceItem ( name )
	if resItem and resItem:isType ( "render_target" ) then
		return resItem:getMoaiTexture ()
	end

	return false
end

function CameraPass:addColorBuffer ( name, option, srcRenderTarget )
	local rb = self:buildColorBuffer ( option, srcRenderTarget )
	return self:addResource ( name, "color_buffer", rb )
end

function CameraPass:addDepthBuffer ( name, option, srcRenderTarget )
	local rb = self:buildDepthBuffer ( option, srcRenderTarget )
	return self:addResource ( name, "render_buffer", rb )
end

function CameraPass:addDepthStencilBuffer ( name, option, srcRenderTarget )
	local rb = self:buildDepthStencilBuffer ( option, srcRenderTarget )
	return self:addResource ( name, "render_buffer", rb )
end

function CameraPass:addStencilBuffer ( name, option, srcRenderTarget )
	local rb = self:buildStencilBuffer ( option, srcRenderTarget )
	return self:addResource ( name, "render_buffer", rb )
end

function CameraPass:addTextureRenderTarget ( name, option, srcRenderTarget )
	local rt = self:buildTextureRenderTarget ( option, srcRenderTarget )
	rt:setDebugName ( "cameraTRT:" .. name )
	return self:addResource ( name, "texture_target", rt )
end

function CameraPass:addMRT ( name, option, srcRenderTarget )
	local rt = self:buildMRT ( option, srcRenderTarget )
	rt:setDebugName ( "cameraMRT:" .. name )
	return self:addResource ( name, "render_target", rt )
end

function CameraPass:_createRenderTarget ()
	return TextureRenderTarget ()
end

function CameraPass:createPartitionViewLayer ()
	return RenderManagerModule.createPartitionRenderLayer ()
end

function CameraPass:buildTextureRenderTarget ( option, srcRenderTarget )
	local option = option and table.simplecopy ( option ) or {}
	local rootRenderTarget = srcRenderTarget and srcRenderTarget:getRootRenderTarget ()

	if rootRenderTarget and rootRenderTarget:isInstance ( TextureRenderTarget ) then
		if option.colorFormat == nil then
			option.colorFormat = rootRenderTarget.colorFormat
		end

		if option.useDepthBuffer == nil then
			option.useDepthBuffer = rootRenderTarget.useDepthBuffer
		end

		if option.useStencilBuffer == nil then
			option.useStencilBuffer = rootRenderTarget.useStencilBuffer
		end

		if option.depthFormat == nil then
			option.depthFormat = rootRenderTarget.depthFormat
		end

		if option.stencilFormat == nil then
			option.stencilFormat = rootRenderTarget.stencilFormat
		end

		if option.sharedDepthBuffer == nil then
			option.sharedDepthBuffer = rootRenderTarget.sharedDepthBuffer
		end
	end

	local renderTarget = self:_createRenderTarget ()
	renderTarget:initFrameBuffer ( option )

	srcRenderTarget = srcRenderTarget or self:getDefaultRenderTarget ()
	srcRenderTarget:addSubViewport ( renderTarget )

	if option.clearColor or option.clearStencil or option.clearDepth then
		RenderManagerModule.getRenderManager ():addRenderTaskClearFramebuffer ( renderTarget:getFrameBuffer (), option.clearColor, option.clearStencil, option.clearDepth )
	end

	return renderTarget
end

function CameraPass:_buildRenderBuffer ( buffer, option, srcRenderTarget )
	option = option or {}
	local format = option.format or nil

	buffer:setFormat ( format )
	buffer:setOption ( option )

	srcRenderTarget = srcRenderTarget or self:getDefaultRenderTarget ()
	srcRenderTarget:addSubViewport ( buffer )

	return buffer
end

function CameraPass:buildColorBuffer ( option, srcRenderTarget )
	return self:_buildRenderBuffer ( ColorRenderBuffer (), option, srcRenderTarget )
end

function CameraPass:buildDepthBuffer ( option, srcRenderTarget )
	return self:_buildRenderBuffer ( DepthRenderBuffer (), option, srcRenderTarget )
end

function CameraPass:buildStencilBuffer ( option, srcRenderTarget )
	return self:_buildRenderBuffer ( StencilRenderBuffer (), option, srcRenderTarget )
end

function CameraPass:buildDepthStencilBuffer ( option, srcRenderTarget )
	return self:_buildRenderBuffer ( DepthStencilRenderBuffer (), option, srcRenderTarget )
end

function CameraPass:buildMRT ( option, srcRenderTarget )
	local function affirmRenderBuffer ( c )
		if type ( c ) == "string" then
			return self:getRenderBuffer ( c )
		else
			return c
		end
	end

	local mrt = MRTRenderTarget ()
	mrt.scale = option.scale or 1
	local depthStencilBuffer = affirmRenderBuffer ( option.depth_stencil )
	if depthStencilBuffer then
		mrt:setDepthStencilBuffer ( depthStencilBuffer )
	end

	local depthBuffer = affirmRenderBuffer ( option.depth )
	if depthBuffer then
		if depthStencilBuffer then
			_warn ( "DepthStencilBuffer already bound, ignore DepthBuffer", self:getCamera () )
		end
		mrt:setDepthBuffer ( depthBuffer )
	end

	local stencilBuffer = affirmRenderBuffer ( option.stencil )
	if stencilBuffer then
		if depthStencilBuffer then
			_warn ( "DepthStencilBuffer already bound, ignore StencilBuffer ", self:getCamera () )
		end
		mrt:setStencilBuffer ( stencilBuffer )
	end

	local colorBuffers = {}

	if type ( option.color ) == "string" then
		colorBuffers[ 1 ] = affirmRenderBuffer ( option.color )
	else
		for i, c in ipairs ( option.color or {} ) do
			colorBuffers[ i ] = affirmRenderBuffer ( c )
		end
	end

	mrt:setColorBuffers ( colorBuffers )

	srcRenderTarget = srcRenderTarget or self:getDefaultRenderTarget ()
	srcRenderTarget:addSubViewport ( mrt )

	return mrt
end

function CameraPass:setGlobalTexture ( name, tex )
	self.camera:getRenderContext ():setGlobalTexture ( name, tex )
end

function CameraPass:setGlobalTextures ( t )
	self.camera:getRenderContext ():setGlobalTextures ( t )
end

function CameraPass:buildDebugDrawLayer ()
	local camera = self.camera

	local innerLayer = self:createPartitionViewLayer ()
	innerLayer.priority = 100000

	innerLayer:setViewport ( camera:getMoaiViewport () )
	innerLayer:setCamera ( camera._camera )
	innerLayer:setClearMode ( MOAILayer.CLEAR_NEVER )
	innerLayer:showDebugLines ( true )

	innerLayer._candy_camera = camera

	local overlayTable = {}
	local underlayTable = {}

	innerLayer:setLayerPartition ( self.camera.scene:getDebugPropPartition () )

	local world = self.camera.scene:getBox2DWorld ()

	table.insert ( underlayTable, world )

	local debugDrawQueue = self.camera.scene:getDebugDrawQueue ()

	table.insert ( overlayTable, debugDrawQueue:getMoaiProp () )

	local debugDrawLayer = RenderManagerModule.createTableViewRenderLayer ()

	debugDrawLayer:setRenderTable ( {
		underlayTable,
		innerLayer,
		overlayTable
	} )
	debugDrawLayer:setCamera ( camera._camera )
	debugDrawLayer:setViewport ( camera:getMoaiViewport () )

	debugDrawLayer.FLAG_DEBUG_LAYER = true

	table.insert ( self.debugLayers, debugDrawLayer )
	-- debugDrawLayer:setEnabled ( false ) -- TODO: no setEnabled function

	return debugDrawLayer, innerLayer
end

function CameraPass:pushFinalizer ( f )
	table.insert ( self.finalizers, f )
end

function CameraPass:setShowDebugLayers ( visible )
	for i, layer in ipairs ( self.debugLayers ) do
		layer:setVisible ( visible )
		-- layer:setEnabled ( visible )
	end
end

function CameraPass:applyCameraToMoaiLayer ( layer, option )
	local camera = self.camera
	layer:setViewport ( self.currentRenderTarget:getMoaiViewport () )
	layer:setCamera ( camera._camera )
	return layer
end

function CameraPass:buildSceneLayerRenderLayer ( sceneLayer, option )
	local camera = self.camera
	local allowEditorLayer = option and option.allowEditorLayer
	if not camera:isLayerIncluded ( sceneLayer.name, allowEditorLayer ) then return false end
	local includeLayer = option and option.include
	local excludeLayer = option and option.exclude
	
	if includeLayer and not table.index ( includeLayer, sceneLayer.name ) then return false end
	if excludeLayer and table.index ( excludeLayer, sceneLayer.name ) then return false end
	local source   = sceneLayer.source
	local layer    = self:createPartitionViewLayer ()
	
	layer.name     = sceneLayer.name
	layer.priority = -1
	layer.source   = source
	layer.sceneLayer = sceneLayer

	layer:showDebugLines ( false )
	layer:setLayerPartition ( sceneLayer:getLayerPartition () )
	
	if option and option.viewport then
		layer:setViewport ( option.viewport )
	else
		--assert ( self:getCurrentRenderTarget ():getMoaiViewport () ~= nil )
		local renderViewport = self:getCurrentRenderTarget ():getRenderViewport ()
		layer:setViewport ( renderViewport:getMoaiViewport () )
	end

	if option and option.transform then
		layer:setCamera ( option.transform )
	else
		--assert ( camera._camera ~= nil )
		layer:setCamera ( camera._camera )
	end

	if camera.parallaxEnabled and source.parallax then
		layer:setParallax ( unpack ( source.parallax ) )
	end
	
	if sceneLayer.sortMode then
		layer:setSortMode ( sceneLayer.sortMode )
	end

	-- print ( "sceneLayer", inspect ( sceneLayer:getPropViewList (), {depth=2} ) )
	-- print ( "layer", inspect ( sceneLayer:getPropViewList (), {depth=2} ) )

	inheritVisible ( layer, sceneLayer )
	layer._candy_camera = camera

	return layer
end

function CameraPass:buildSimpleOrthoRenderLayer ( w, h, useRenderViewport )
	w, h =  w or 1, h or 1
	local viewport = Viewport ()
	viewport:setMode ( 'relative' )
	viewport:setFixedScale ( w, h )
	
	local renderTarget = self.currentRenderTarget or self:getDefaultRenderTarget ()
	if useRenderViewport then
		viewport:setParent ( renderTarget:getRenderViewport () )
	else
		viewport:setParent ( renderTarget )
	end

	local layer = self:createPartitionViewLayer ()
	layer:setViewport ( viewport:getMoaiViewport () )

	local quadCamera = MOAICamera.new ()
	quadCamera:setOrtho ( true )
	quadCamera:setNearPlane ( -100000 )
	quadCamera:setFarPlane ( 100000 )

	layer:setCamera ( quadCamera )
	layer.camera = quadCamera
	layer.width  = w
	layer.height = h
	return layer, w, h 
end

function CameraPass:buildSimpleQuadProp ( w, h, texture, shader )
	local quad = MOAISpriteDeck2D.new ()
	quad:setRect ( -w/2, -h/2, w/2, h/2 )
	quad:setUVRect ( 0,0,1,1 )
	local quadProp = createRenderProp ()
	quadProp:setDeck ( quad )
	quad:setUVRect ( 0, 0, 1, 1 )

	if texture then
		local cname = texture:getClassName ()
		quad:setTexture ( texture )

		if RenderManagerModule.getRenderManager ().flipRenderTarget and (cname == "MOAIColorBufferTexture" or cname == "MOAIFramebufferTexture") then
			quad:setUVRect ( 0, 1, 1, 0 )
		end
	end

	if shader  then quad:setShader ( shader ) end

	return quadProp, quad
end

function CameraPass:buildSingleQuadRenderLayer ( texture, shader, useRenderViewport )
	local layer, w, h = self:buildSimpleOrthoRenderLayer ( nil, nil, useRenderViewport )
	local prop, quad = self:buildSimpleQuadProp ( w, h, texture, shader )
	prop:setPartition ( layer )
	layer.prop = prop
	self:pushFinalizer ( function ()
		prop:setPartition ( false )
	end )
	return layer, prop, quad
end

function CameraPass:pushColorOnlyRenderLayer ( r,g,b,a, blend )
	local layer, prop = self:buildColorOnlyRenderLayer ( r,g,b,a )
	setPropBlend ( prop, blend or 'alpha' )
	self:pushRenderLayer ( layer )
	return layer, prop
end

function CameraPass:buildColorOnlyRenderLayer ( r,g,b,a, useRenderViewport )
	local layer, w, h = self:buildSimpleOrthoRenderLayer ( nil, nil, useRenderViewport )
	local prop = createRenderProp ()
	
	local deck  = MOAIScriptDeck.new ()
	deck:setRect( -0.5, -0.5, 0.5, 0.5 )
	deck:setDrawCallback ( 
		function ( idx, xOff, yOff, xScl, yScl )
			return MOAIDraw.fillRect ( -0.5, -0.5, 0.5, 0.5)
		end
	)

	-- local deck = MOAIGeometry2DDeck.new()
	-- deck:setFilledRectItem ( 1, -0.5, -0.5, 0.5, 0.5 )

	prop:setDeck ( deck )
	prop:setColor ( r or 1, g or 1, b or 1, a or 1 )
	prop:setIndex ( 1 )
	setPropBlend ( prop, 'alpha' )
	prop:setPartition ( layer )
	return layer, prop, deck
end

function CameraPass:buildCallbackRenderLayer ( func )
	local renderLayer = RenderManagerModule.createTableRenderLayer ()
	renderLayer:setRenderTable ( {
		func
	} )
	return renderLayer
end

function CameraPass:pushCallback ( func, layerType )
	local renderLayer = self:buildCallbackRenderLayer ( func )
	return self:pushRenderLayer ( renderLayer, "call" )
end

function CameraPass:pushLog ( ... )
	local args = { ... }

	if cameraPassLogEnabled then
		self:pushCallback ( function ()
			print ( unpack ( args ) )
		end )
	end
end

function CameraPass:pushOneshotCallback ( func, layerType )
	local renderLayer
	local done = false
	local outterFunc = function ( ... )
		if done then return end --TODO: should be unnecessary?
		done = true
		renderLayer:setVisible ( false )
		return func ( ... )
	end	
	renderLayer = self:buildCallbackRenderLayer ( outterFunc )
	return self:pushRenderLayer (
		renderLayer,
		layerType or 'call'
	)
end

function CameraPass:buildAndPushSceneRenderLayer ( layerName )
	local camera = self.camera
	local scene = camera.scene

	for id, sceneLayer in ipairs ( scene.layers ) do
		if sceneLayer.name == layerName then
			local renderLayer = self:buildSceneLayerRenderLayer ( sceneLayer, {} )
			if renderLayer then
				return self:pushRenderLayer ( renderLayer )
			else
				return false
			end
		end
	end

	return false
end

function CameraPass:pushSceneRenderPass ( option )
	self:pushLog ( ">> scene render pass", option )

	local camera = self.camera
	local scene = camera.scene
	local result = {}

	for id, sceneLayer in ipairs ( scene.layers ) do
		local name = sceneLayer.name
		local renderLayer = self:buildSceneLayerRenderLayer ( sceneLayer, option )
		if renderLayer then
			result[ name ] = renderLayer
			self:pushRenderLayer ( renderLayer )
		end
	end

	return result
end

function CameraPass:pushEditorLayerPass ()
	self:setCurrentGroup ( "editor" )

	local camera = self.camera
	local scene  = camera.scene

	for id, sceneLayer in ipairs ( scene.layers ) do
		local name = sceneLayer.name
		if name == 'CANDY_EDITOR_LAYER' then
			local p = self:buildSceneLayerRenderLayer ( sceneLayer, { allowEditorLayer = true } )
			if p then
				self:pushRenderLayer( p )
			end
			break
		end
	end
end

function CameraPass:preImageEffect ( effect, frontbuffer, backbuffer )
end

function CameraPass:postImageEffect ( effect, frontbuffer, backbuffer )
end

function CameraPass:findImageEffect ( clas )
	if not self.camera.hasImageEffect then
		return nil
	end

	for i, effect in ipairs ( self.camera.imageEffects ) do
		if effect:isInstance ( clas ) then
			return effect
		end
	end

	return nil
end

function CameraPass:onBuildImageEffects ()
	self:buildImageEffects ()
end

function CameraPass:buildImageEffects ( srcBuffer, outputBuffer )
	if not self.camera.hasImageEffect then return end
	
	local function _affirmRenderTarget ( obj, default )
		if not obj then
			return default
		end

		local tt = type ( obj )
		if tt == "string" then
			return self:getRenderTarget ( obj )
		else
			return assertInstanceOf ( obj, RenderTarget )
		end
	end

	local imageEffects = self.camera.imageEffects
	local effectPassCount = 0

	for i, effect in ipairs ( self.camera.imageEffects ) do
		effectPassCount = effectPassCount + effect:getPassCount ()
	end

	if effectPassCount == 0 then
		return
	end

	local defaultRenderTarget = self:getDefaultRenderTarget ()
	local outputRenderTarget = self.outputRenderTarget
	srcBuffer = _affirmRenderTarget ( srcBuffer, defaultRenderTarget )
	outputBuffer = _affirmRenderTarget ( outputBuffer, outputRenderTarget )

	assert ( srcBuffer ~= outputBuffer )

	local backbuffer = srcBuffer
	local frontbuffer = nil

	if effectPassCount > 1 then
		frontbuffer = self:buildTextureRenderTarget ( nil, outputBuffer )
	else
		frontbuffer = outputBuffer
	end

	local totalEffectPassId = 0

	for i, imageEffect in ipairs ( imageEffects ) do
		local passCount = imageEffect:getPassCount ()

		for pass = 1, passCount do
			totalEffectPassId = totalEffectPassId + 1

			if totalEffectPassId == effectPassCount then
				frontbuffer = outputBuffer
			end

			self:preImageEffect ( imageEffect, backbuffer, frontbuffer )

			self.defaultRenderTarget = frontbuffer

			self:pushRenderTarget ( frontbuffer, {
				clearStencil = false,
				clearDepth = false,
				clearColor = true
			} )

			local result = imageEffect:buildCameraPass ( self, backbuffer:getFrameBuffer (), pass )

			self:postImageEffect ( imageEffect, backbuffer, frontbuffer )

			frontbuffer = backbuffer
			backbuffer = frontbuffer
		end
	end

	self.imageEffectOutputBuffer = frontbuffer
	self.defaultRenderTarget = defaultRenderTarget

	return frontbuffer, backbuffer
end


--------------------------------------------------------------------
-- SceneCameraPass
--------------------------------------------------------------------
---@class SceneCameraPass : CameraPass
local SceneCameraPass = CLASS: SceneCameraPass ( CameraPass )
 	:MODEL {}

function SceneCameraPass:__init ( clear, clearColor )
	self.clearBuffer = clear ~= false
	self.clearColor  = clearColor or false
end

function SceneCameraPass:onBuild ()
	local camera = self:getCamera ()
	local fb0 = self:getDefaultRenderTarget ()

	if not self.clearBuffer then
		self:pushRenderTarget ( fb0, { clearColor = false } )
	else
		self:pushRenderTarget ( fb0, { clearColor = self.clearColor } )
	end

	self:pushSceneRenderPass ()

	local debugLayer = self:buildDebugDrawLayer ()
	if debugLayer then
		self:pushRenderLayer ( debugLayer )
	end

	if camera:isEditorCamera () then
		self:pushEditorLayerPass ()
	end

end


--------------------------------------------------------------------
-- CallbackCameraPass
--------------------------------------------------------------------
---@class CallbackCameraPass : CameraPass
local CallbackCameraPass = CLASS: CallbackCameraPass ( CameraPass )
	:MODEL {}

function CallbackCameraPass:onBuild ()
	local function callback ( ... )
		return self:onDraw ( ... )
	end
	self:pushRenderLayer ( self:buildCallbackRenderLayer ( callback ) )
end

function CallbackCameraPass:onDraw ( ... )
end


--------------------------------------------------------------------
--build render commands
local defaultOptions = { 
	clearColor   = { 0,0,0,0 },
	clearDepth   = true, 
	clearStencil = true
}

local emptyOptions = { 
	clearColor   = false, 
	clearDepth   = false, 
	clearStencil = false
}

--------------------------------------------------------------------
function buildCameraRenderPass ( camera )
	local batchTimer0 = {}
	local batchDuration = {}
	local clock = os.clock
	local max = math.max

	local function _batchTimerStart ( id )
		return function ()
			batchTimer0[ id ] = clock ()
		end
	end

	local function _batchTimerStop ( id )
		return function ()
			local duration = clock () - batchTimer0[ id ]
			duration = max ( batchDuration[ id ] or 0, duration )
			batchDuration[ id ] = duration
		end
	end

	camera._batchDuration = batchDuration

	function camera._clearBatchDuration ()
		batchDuration = {}
		camera._batchDuration = batchDuration
	end

	local batchEntry = {}
	camera._batchEntry = batchEntry
	local passQueue = {}

	for _, camPass in ipairs ( camera.passes ) do
		for i, passEntry in ipairs ( camPass:build () ) do
			table.insert ( passQueue, passEntry )
		end
	end

	local currentBuffer = false
	local currentOption = false
	local currentBatch = false
	local currentScissor = false
	local currentBufferScissor = false
	local bufferInfoTable = {}
	local defaultRenderTarget = game:getMainRenderTarget ()
	local defaultBuffer = defaultRenderTarget and defaultRenderTarget:getFrameBuffer () or MOAIGfxMgr.getFrameBuffer ()
	local idx = 0

	local function _newBatch ( entry, option )
		if cameraBatchProfiling and currentBatch then
			table.insert ( currentBatch, _batchTimerStop ( idx ) )
		end

		idx = idx + 1
		currentBatch = {}
		batchEntry[ idx ] = entry

		if cameraBatchProfiling then
			currentBatch[ 1 ] = _batchTimerStart ( idx )
		end

		table.insert ( bufferInfoTable, {
			buffer = currentBuffer or defaultBuffer,
			option = option or emptyOptions,
			batch = currentBatch,
			camera = camera,
			scissor = currentScissor
		} )
	end

	for i, entry in ipairs ( passQueue ) do
		local tag = entry.tag

		if tag == "render-target" then
			local renderTarget = entry.renderTarget
			local buffer = renderTarget:getFrameBuffer ()
			local option = entry.option or defaultOptions
			local batchDirty = buffer ~= currentBuffer or currentBufferScissor ~= currentScissor

			if batchDirty then
				currentBuffer = buffer
				currentOption = option
				currentBufferScissor = currentScissor
				_newBatch ( entry, option )
			end
		elseif tag == "scissor" then
			currentScissor = entry.scissor
		elseif tag == "layer" then
			if not currentBatch then
				_newBatch ( entry, emptyOptions )
			end

			local layer = entry.layer
			if layer then
				table.insert ( currentBatch, layer )
			end
		end
	end

	if cameraBatchProfiling and currentBatch then
		table.insert ( currentBatch, _batchTimerStop ( idx ) )
	end

	local cameraRenderTable = {}

	for i, info in ipairs ( bufferInfoTable ) do
		local fb = assert ( info.buffer )
		local batchPass = RenderManagerModule.createTableRenderLayer ()
		batchPass:setFrameBuffer ( fb )
		batchPass.camera = camera
		-- batchPass:setEnabled ( camera:isActive () ) -- TODO: no setEnabled function

		local option = info.option
		local clearColor = option and option.clearColor
		local clearDepth = option and option.clearDepth
		local clearStencil = option and option.clearStencil

		local tt = type ( clearColor )
		if tt == "table" then
			batchPass:setClearColor ( unpack ( clearColor ) )
		elseif tt == "string" then
			batchPass:setClearColor ( hexcolor ( clearColor ) )
		elseif tt == "userdata" then
			batchPass:setClearColor ( clearColor )
		else
			batchPass:setClearColor ()
		end

		batchPass:setClearDepth ( clearDepth ~= false )
		-- batchPass:setClearStencil ( clearStencil ~= false )

		if clearColor or clearDepth or clearStencil then
			batchPass:setClearMode ( MOAILayer.CLEAR_ALWAYS )
		else
			batchPass:setClearMode ( MOAILayer.CLEAR_NEVER )
		end

		-- batchPass:setScissorRect ( info.scissor )

		local batch = table.simplecopy ( info.batch )

		batchPass:setRenderTable ( batch )
		table.insert ( cameraRenderTable, batchPass )
	end

	return cameraRenderTable
end


CameraPassModule.CameraPass = CameraPass
CameraPassModule.SceneCameraPass = SceneCameraPass
CameraPassModule.CallbackCameraPass = CallbackCameraPass
CameraPassModule.buildCameraRenderPass = buildCameraRenderPass

return CameraPassModule