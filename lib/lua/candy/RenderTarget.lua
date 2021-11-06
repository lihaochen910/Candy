-- import
local Viewport = require 'candy.Viewport'

-- module
local RenderTargetModule = {}

--- RenderTarget包含frameBuffer和viewport的定义
---@class RenderTarget : Viewport
local RenderTarget = CLASS: RenderTarget ( Viewport )
	:MODEL {}

function RenderTarget:__init ()
	self.mode = 'relative'
	self.frameBuffer = false
	self.debugName = ''
	self.renderViewport = false
end

function RenderTarget:__tostring ()
	return string.format ( "%s:%s (%d,%d,%d,%d)", self:__repr (), self.debugName or "???", self:getAbsPixelRect () )
end

function RenderTarget:setRenderViewport ( vp )
	self.renderViewport = vp or false
end

function RenderTarget:getRenderViewport ()
	return self.renderViewport or self
end

function RenderTarget:setDebugName ( name )
	self.debugName = name
end

function RenderTarget:getFrameBuffer ()
	return self.frameBuffer
end

function RenderTarget:setFrameBuffer ( buffer )
	self.frameBuffer = buffer
end

function RenderTarget:setClearColor ( r,g,b,a ) --todo:remove this
	if not self.frameBuffer then return end
	self:getFrameBuffer ():setClearColor ( r,g,b,a )
end

function RenderTarget:setClearDepth ( clear )
	if not self.frameBuffer then return end
	self:getFrameBuffer ():setClearDepth ( clear )
end

function RenderTarget:setClearStencil ( clear )
	if not self.frameBuffer then return end
	self:getFrameBuffer ():setClearStencil ( clear )
end

function RenderTarget:getRootRenderTarget ()
	local r = self
	while true do
		local p = r.parent
		if not p then break end
		if not p:isInstance ( RenderTarget ) then break end
		r = p
	end
	return r
end

function RenderTarget:clear ()
	RenderTarget.__super.clear ( self )
	self.cleared = true
end

--------------------------------------------------------------------
---@class DeviceRenderTarget : RenderTarget
local DeviceRenderTarget = CLASS: DeviceRenderTarget ( RenderTarget )
	:MODEL {}

---@param frameBuffer MOAIFrameBuffer
---@param w number
---@param h number
function DeviceRenderTarget:__init ( frameBuffer, w, h )
	self.frameBuffer = assert ( frameBuffer )
	self.mode = 'fixed'
	self:setPixelSize ( w, h )
end

function DeviceRenderTarget:setMode ( m )
	_error ( 'device rendertarget is fixed' )
end


--------------------------------------------------------------------
local DefaultFrameBufferOptions = {
	filter           = MOAITexture.GL_LINEAR,
	useStencilBuffer = false,
	useDepthBuffer   = false,
	clearDepth       = true,
	clearStencil     = true,
	colorFormat      = false,
	scale            = 1,
	size             = 'relative',
	autoResize       = true
}

--------------------------------------------------------------------
-- class
local TextureRenderTarget = CLASS: TextureRenderTarget ( RenderTarget )
	:MODEL {}

function TextureRenderTarget:__init ()
	self.mode = "relative"
	self.keepAspect = false
	self.previousTextureSize = false
	self.colorFormat = false
	self.depthFormat = false
	self.stencilFormat = false
	self.sharedDepthBuffer = false
	self.autoResizeFramebuffer = true
end

function TextureRenderTarget:resizeFramebuffer ( w, h )
	if not self.frameBuffer then
		_error ( "frameBuffer not initialized or already cleared", self.__name, self.cleared )
		return
	end

	if self.sharedDepthBuffer then
		_stat ( "init sharedDepthBuffer in frameBuffer", w, h, self, self.sharedDepthBuffer )

		local fb = nil
		if isInstance ( self.sharedDepthBuffer, TextureRenderTarget ) then
			fb = self.sharedDepthBuffer:getFrameBuffer ()
		elseif isMOAIObject ( self.sharedDepthBuffer, MOAIFrameBufferTexture ) then
			fb = self.sharedDepthBuffer
		end

		if fb then
			local res = self.frameBuffer:initWithSharedDepthBuffer ( w, h, self.colorFormat, fb )

			if not res then
				_error ( "failed in binding shared frame buffer" )
				return false
			end
		else
			_error ( "invalid shared sharedDepthBuffer", self.sharedDepthBuffer )
			return false
		end
	else
		_stat ( "init frameBuffer", w, h, self )
		self.frameBuffer:init ( w, h, self.colorFormat, self.depthFormat, false )
	end

	self.previousTextureSize = { w, h }
end

function TextureRenderTarget:onUpdateSize ()
	local w, h = self:getPixelSize ()
	w = w * ( self.scale or 1 )
	h = h * ( self.scale or 1 )
	self.absPixelRect = { 0, 0, w, h }
	local needResize = false

	if self.previousTextureSize then
		if self.previousTextureSize[ 1 ] ~= w or self.previousTextureSize[ 2 ] ~= h then
			needResize = true
		end
	else
		needResize = true
	end

	if not needResize then
		return
	end

	if self.autoResizeFramebuffer then
		return self:resizeFramebuffer ( w, h )
	end
end

function TextureRenderTarget:onUpdateScale ()
end

function TextureRenderTarget:initFrameBuffer ( option )
	option = table.extend ( table.simplecopy ( DefaultFrameBufferOptions ), option or {} )
	local frameBuffer = MOAIFrameBufferTexture.new ()
	self.frameBuffer = frameBuffer ---@type MOAIFrameBufferTexture

	-- if MOCKHelper.setTextureDebugName then
	-- 	local debugName = self.debugName or "<FrameBuffer?>"
	-- 	MOCKHelper.setTextureDebugName(self.frameBuffer, debugName)
	-- end

	local clearColor = false
	local clearDepth = option.clearDpeth or false
	local clearStencil = option.clearStencil or false
	local sharedDepthBuffer = option.sharedDepthBuffer or false
	local useStencilBuffer = option.useStencilBuffer or false
	local useDepthBuffer = option.useDepthBuffer or false
	local colorFormat = option.colorFormat or nil
	local filter = option.filter or MOAITexture.GL_LINEAR
	local wrap = option.wrap or false
	local scale = option.scale or 1
	local depthFormat = false
	local stencilFormat = false

	if useDepthBuffer or useStencilBuffer then
		depthFormat = MOAITexture.GL_DEPTH24_STENCIL8
	else
		depthFormat = useDepthBuffer and MOAITexture.GL_DEPTH_COMPONENT16 or false
		stencilFormat = useStencilBuffer and MOAITexture.GL_STENCIL_INDEX8 or false
	end

	self.useDepthBuffer = useDepthBuffer
	self.useStencilBuffer = useStencilBuffer
	self.colorFormat = colorFormat
	self.depthFormat = depthFormat
	self.stencilFormat = stencilFormat
	self.scale = scale
	self.sharedDepthBuffer = sharedDepthBuffer

	frameBuffer:setFilter ( filter )
	frameBuffer:setWrap ( wrap )
end

function TextureRenderTarget:clear ()
	if self.frameBuffer then
		self.frameBuffer:release ()
		self.frameBuffer = nil
	end

	TextureRenderTarget.__super.clear ( self )
end

RenderTargetModule.RenderTarget = RenderTarget
RenderTargetModule.DeviceRenderTarget = DeviceRenderTarget
RenderTargetModule.TextureRenderTarget = TextureRenderTarget

return RenderTargetModule