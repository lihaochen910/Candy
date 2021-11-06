-- import
local Viewport = require 'candy.Viewport'

local max = math.max
local floor = math.floor

---@class RenderBuffer : Viewport
local RenderBuffer = CLASS: RenderBuffer ( Viewport )

function RenderBuffer:__init ()
	self.buffer = false
	self.owner = false
	self.scale = 1
	self.autoResizeBuffer = true
	self.prevBufferSize = false
	self.format = self:getDefaultFormat ()
	self.initialized = false
	self.allowResize = true
end

function RenderBuffer:setFormat ( format )
	self.format = format or self:getDefaultFormat ()
end

function RenderBuffer:setOption ( option )
	option = option or {}
	self.option = option
	self.scale = option.scale or 1
	self:onUpdateOption ( option )
end

function RenderBuffer:getMoaiRenderBuffer ()
	return self.buffer
end

function RenderBuffer:onUpdateSize ()
	local w, h = self:getPixelSize ()
	w = max ( 1, floor ( w * (self.scale or 1)) )
	h = max ( 1, floor ( h * (self.scale or 1)) )
	self.absPixelRect = { 0, 0, w, h }
	local needResize = false

	if self.prevBufferSize then
		needResize = w ~= self.prevBufferSize[ 1 ] or h ~= self.prevBufferSize[ 2 ]
	else
		needResize = true
	end

	if not needResize then
		return
	end

	if self.autoResizeBuffer then
		self:resizeBuffer ( w, h )
	end
end

function RenderBuffer:resizeBuffer ( w, h )
	if not self.allowResize then
		_error ( "not resizable renderbuffer" )
	end

	if not self.initialized then
		self.initialized = true
		self:onInit ( w, h )
	else
		self:onResize ( w, h )
	end

	self.prevBufferSize = { w, h }
end

function RenderBuffer:onInit ( w, h )
end

function RenderBuffer:onResize ( w, h )
	self.buffer:resize ( w, h )
end

function RenderBuffer:onUpdateOption ( option )
end

function RenderBuffer:clear ()
	RenderBuffer.__super.clear ( self )
	self:onRelease ()
end

function RenderBuffer:onRelease ()
end

---@class ColorRenderBuffer : RenderBuffer
local ColorRenderBuffer = CLASS: ColorRenderBuffer ( RenderBuffer )

function ColorRenderBuffer:__init ()
	self.buffer = MOAIColorBufferTexture.new ()
end

function ColorRenderBuffer:getDefaultFormat ()
	return MOAITexture.GL_RGBA8
end

function ColorRenderBuffer:onInit ( w, h )
	self.buffer:init ( w, h, self.format )
end

function ColorRenderBuffer:onUpdateOption ( option )
	if option.filter then
		self.buffer:setFilter ( option.filter )
	end

	if option.wrap then
		self.buffer:setWrap ( option.wrap )
	end
end

---@class DepthRenderBuffer : RenderBuffer
local DepthRenderBuffer = CLASS: DepthRenderBuffer ( RenderBuffer )

function DepthRenderBuffer:__init ()
	error ( "no more separated depth buffer" )
	self.buffer = MOAIRenderBuffer.new ()
end

function DepthRenderBuffer:getDefaultFormat ()
	return MOAITexture.GL_DEPTH_COMPONENT16
end

function DepthRenderBuffer:onInit ( w, h )
	self.buffer:initDepthBuffer ( w, h, self.format )
end

---@class StencilRenderBuffer : RenderBuffer
local StencilRenderBuffer = CLASS: StencilRenderBuffer ( RenderBuffer )

function StencilRenderBuffer:__init ()
	error ( "no more separated stencil buffer" )
	self.buffer = MOAIRenderBuffer.new ()
end

function StencilRenderBuffer:getDefaultFormat ()
	return assert ( MOAITexture.GL_STENCIL_INDEX8 )
end

function StencilRenderBuffer:onInit ( w, h )
	self.buffer:initStencilBuffer ( w, h, self.format )
end

---@class DepthStencilRenderBuffer : RenderBuffer
local DepthStencilRenderBuffer = CLASS:DepthStencilRenderBuffer ( RenderBuffer )

function DepthStencilRenderBuffer:__init ()
	self.buffer = MOAIRenderBuffer.new ()
end

function DepthStencilRenderBuffer:getDefaultFormat ()
	return assert ( MOAITexture.GL_DEPTH24_STENCIL8 )
end

function DepthStencilRenderBuffer:onInit ( w, h )
	self.buffer:initDepthStencilBuffer ( w, h, self.format )
end

---@class MRTRenderTarget : RenderTarget
local MRTRenderTarget = CLASS: MRTRenderTarget ( RenderTarget )
	:MODEL {}

function MRTRenderTarget:__init ()
	self.frameBuffer = MOAIMRTFrameBuffer.new ()
	self.colorBuffers = {}
	self.depthBuffer = false
	self.stencilBuffer = false
	self.depthStencilBuffer = false
	self.prevBufferSize = false
	self.autoResizeRenderbuffers = true
end

function MRTRenderTarget:getColorBuffer ( idx )
	return self.colorBuffers[ idx or 1 ]
end

function MRTRenderTarget:getColorBufferTexture ( idx )
	local buffer = self:getColorBuffer ( idx )
	return buffer and buffer:getMoaiRenderBuffer ()
end

function MRTRenderTarget:setColorBuffers ( t )
	local buffers = {}
	local fb = self.frameBuffer

	fb:reserveColorBuffers ( #t )

	for i, b in ipairs ( t ) do
		buffers[ i ] = b or false

		if b then
			assert ( isInstance ( b, RenderBuffer ) )
			fb:setColorBuffer ( i, b:getMoaiRenderBuffer () )

			if not b.owner then
				b.owner = self
			end
		end
	end

	self.colorBuffers = buffers
end

function MRTRenderTarget:setDepthBuffer ( b )
	self.depthBuffer = b or false

	if b then
		assert ( isInstance ( b, RenderBuffer ) )
		self.frameBuffer:setDepthBuffer ( b:getMoaiRenderBuffer () )

		if not b.owner then
			b.owner = self
		end
	end
end

function MRTRenderTarget:setStencilBuffer ( b )
	self.stencilBuffer = b or false

	if b then
		assert ( isInstance ( b, RenderBuffer ) )
		self.frameBuffer:setStencilBuffer ( b:getMoaiRenderBuffer () )

		if not b.owner then
			b.owner = self
		end
	end
end

function MRTRenderTarget:setDepthStencilBuffer ( b )
	self.depthStencilBuffer = b or false

	if b then
		assert ( isInstance ( b, RenderBuffer ) )
		self.frameBuffer:setDepthStencilBuffer ( b:getMoaiRenderBuffer () )

		if not b.owner then
			b.owner = self
		end
	end
end

function MRTRenderTarget:onUpdateSize ()
	local w, h = self:getPixelSize ()
	w = w * (self.scale or 1)
	h = h * (self.scale or 1)
	self.absPixelRect = { 0, 0, w, h }
	self.frameBuffer:setBufferSize ( w, h )
end

function MRTRenderTarget:onUpdateScale ()
end

function MRTRenderTarget:clear ()
	if self.frameBuffer then
		self.frameBuffer = nil
	end

	MRTRenderTarget.__super.clear ( self )
end
