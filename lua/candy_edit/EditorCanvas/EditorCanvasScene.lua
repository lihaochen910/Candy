module 'candy_edit'
--------------------------------------------------------------------
--EditorCanvasCamera
--------------------------------------------------------------------
CLASS: EditorCanvasCamera ( candy.Camera )

function EditorCanvasCamera:__init( env )
	self.FLAG_EDITOR_OBJECT = true
	context = candy_editor.getCurrentRenderContext()
	self.context = context.key
	self.env = env
	self.parallaxEnabled = false
end

function EditorCanvasCamera:loadPasses()
	self:addPass( candy.SceneCameraPass( self.clearBuffer, self.clearColor ) )
end

function EditorCanvasCamera:isEditorCamera()
	return true
end

function EditorCanvasCamera:getDefaultOutputRenderTarget()
	context = candy_editor.getCurrentRenderContext()
	local w, h = context.w, context.h
	self.canvasRenderTarget = candy.DeviceRenderTarget(
		MOAIGfxDevice.getFrameBuffer(), 1, 1
	)
	self:setScreenSize( w or 100, h or 100 )

	_stat('CurrentRenderContext:', context)
	_stat('EditorCanvasCamera:getDefaultOutputRenderTarget()', self.canvasRenderTarget)

	return self.canvasRenderTarget
end

function EditorCanvasCamera:tryBindSceneLayer( layer )
	local name = layer.name
	if name == 'CANDY_EDITOR_LAYER' then
		layer:setViewport( self:getMoaiViewport() )
		layer:setCamera( self._camera )
	end
end

function EditorCanvasCamera:getScreenRect()
	return self.canvasRenderTarget:getAbsPixelRect()
end

function EditorCanvasCamera:getScreenScale()
	return self.canvasRenderTarget:getScale()
end

function EditorCanvasCamera:setScreenSize( w, h )
	self.canvasRenderTarget:setPixelSize( w, h )
	self.canvasRenderTarget:setFixedScale( w, h )
	self:updateZoom()
end

function EditorCanvasCamera:updateCanvas()
	if self.env then self.env.updateCanvas() end
end

function EditorCanvasCamera:hideCursor()
	if self.env then self.env.hideCursor() end
end

function EditorCanvasCamera:showCursor()
	if self.env then self.env.showCursor() end
end

function EditorCanvasCamera:setCursor( id )
	if self.env then self.env.setCursor( id ) end
end

function EditorCanvasCamera:onAttach( actor )
	actor.FLAG_EDITOR_OBJECT = true
	return candy.Camera.onAttach( self, actor)
end


--------------------------------------------------------------------
--EditorCanvasScene
--------------------------------------------------------------------
CLASS: EditorCanvasScene ( candy.Scene )
function EditorCanvasScene:__init()
	self.FLAG_EDITOR_SCENE = true
end

function EditorCanvasScene:setEnv( env )
	self.env = env
end

function EditorCanvasScene:getEnv()
	return self.env
end

function EditorCanvasScene:initLayers()
	self.layerSource = candy.Layer( 'CANDY_EDITOR_LAYER' )
	local l = self.layerSource:makeMoaiLayer()
	self.layers = { l }
	self.layersByName = {
		['CANDY_EDITOR_LAYER']	 = l
	}
	self.defaultLayer = l
end

function EditorCanvasScene:onLoad()
	self.cameraCom = EditorCanvasCamera( self.env )
	--self.camera    = candy.SingleEntity( self.cameraCom )
	self.cameraActor    = candy.Actor()
	self.cameraActor.FLAG_EDITOR_OBJECT = true
	self.cameraActor:attach(self.cameraCom)
	self:addActor( self.cameraActor )
end


function EditorCanvasScene:getParentActionRoot()
	local ctx = candy_editor.getCurrentRenderContext()
	return ctx.actionRoot
end

function EditorCanvasScene:updateCanvas()
	self.env.updateCanvas()
end

function EditorCanvasScene:getCanvasSize()
	local s = self.env.getCanvasSize()
	return s[0], s[1]
end

function EditorCanvasScene:hideCursor()
	return self.env.hideCursor()
end

function EditorCanvasScene:setCursor( id )
	return self.env.setCursor( id )
end

function EditorCanvasScene:showCursor()
	return self.env.showCursor()
end

function EditorCanvasScene:setCursorPos( x, y )
	return self.env.setCursorPos( x, y )
end

function EditorCanvasScene:startUpdateTimer( fps )
	return self.env.startUpdateTimer( fps )
end

function EditorCanvasScene:stopUpdateTimer()
	return self.env.stopUpdateTimer()
end

function EditorCanvasScene:getCameraZoom()
	return self.cameraCom:getZoom()
end

function EditorCanvasScene:setCameraZoom( zoom )
	self.cameraCom:setCameraZoom( zoom )
end

-- function EditorCanvasScene:threadMain( dt )
	
-- end

--------------------------------------------------------------------
function createEditorCanvasInputDevice( env )
	local env = env or getfenv( 2 )
	local inputDevice = candy.InputDevice( assert( env.contextName ), true )

	function env.onMouseDown( btn, x, y )
		inputDevice:sendMouseEvent( 'down', x, y, btn )
	end

	function env.onMouseUp( btn, x, y )
		inputDevice:sendMouseEvent( 'up', x, y, btn )
	end

	function env.onMouseMove( x, y )
		inputDevice:sendMouseEvent( 'move', x, y, false )
	end

	function env.onMouseScroll( dx, dy, x, y )
		inputDevice:sendMouseEvent( 'scroll', dx, dy, false )
	end

	function env.onMouseEnter()
		inputDevice:sendMouseEvent( 'enter' )
	end

	function env.onMouseLeave()
		inputDevice:sendMouseEvent( 'leave' )
	end

	function env.onKeyDown( key )
		inputDevice:sendKeyEvent( key, true )
	end

	function env.onKeyUp( key )
		inputDevice:sendKeyEvent( key, false )
	end

	env._delegate:updateHooks()
	return inputDevice
end


---------------------------------------------------------------------
function createEditorCanvasScene()
	local env = getfenv( 2 )
	local scn = EditorCanvasScene()

	scn:setEnv( env )

	function env.onResize( w, h )
		scn.cameraCom:setScreenSize( w, h )
	end

	function env.onLoad()
	end

	local inputDevice = createEditorCanvasInputDevice( env )

	function env.EditorInputScript()
		return candy.InputScript{ device = inputDevice }
	end

	scn.inputDevice = inputDevice
	scn:init()
	scn.defaultLayer.name = 'CANDY_EDITOR_LAYER'
	scn:start()
	return scn
end 
