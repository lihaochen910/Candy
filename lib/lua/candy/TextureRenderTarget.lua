-- import
local RenderTargetModule = require 'candy.RenderTarget'
local RenderTarget = RenderTargetModule.RenderTarget


local DefaultFrameBufferOptions = {
	useStencilBuffer = false,
	autoResize = true,
	clearDepth = true,
	clearStencil = true,
	useDepthBuffer = false,
	size = "relative",
	scale = 1,
	colorFormat = false,
	filter = MOAITexture.GL_LINEAR
}

---@class TextureRenderTarget : RenderTarget
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

	self.previousTextureSize = {
		w,
		h
	}
end

function TextureRenderTarget:onUpdateSize ()
	local w, h = self:getPixelSize ()
	w = w * (self.scale or 1)
	h = h * (self.scale or 1)
	self.absPixelRect = {
		0,
		0,
		w,
		h
	}
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
	self.frameBuffer = frameBuffer

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

return TextureRenderTarget