-- import
local RenderManagerModule = require 'candy.RenderManager'
local getRenderManager = RenderManagerModule.getRenderManager

-- module
local RenderContextModule = {}

--------------------------------------------------------------------
-- RenderContext
--------------------------------------------------------------------
---@class RenderContext
local RenderContext = CLASS: RenderContext ()

function RenderContext:__init ()
	self.current = false
	self.name = false ---@type string
	self.contentHeight = 0
	self.contentWidth = 0
	self.height = 0
	self.width = 0
	self.scale = 1
	self.globalTextureValues = table.weak ()
	self.frameBuffer = MOAIGfxMgr.getFrameBuffer () ---@type MOAIFrameBuffer
	self.dummyLayer = MOAITableViewLayer.new () ---@type MOAITableViewLayer
	self.renderTarget = false
	self.rootMaterialBatch = MOAIMaterialBatch.new ()
	self.rootRenderPass = RenderManagerModule.createTableRenderLayer () ---@type MOAITableLayer
	self.rootRenderPass:setClearMode ( MOAILayer.CLEAR_NEVER )
	-- self.rootRenderPass:setMaterialBatch ( self.rootMaterialBatch ) -- TODO: MOAITableLayer no setMaterialBatch function
end

function RenderContext:__tostring ()
	return string.format ( "%s:%s", self:__repr (), tostring ( self.name ) )
end

function RenderContext:setName ( n )
	self.name = n
end

function RenderContext:setRenderTarget ( target )
	self.renderTarget = target
	self:setFrameBuffer ( target:getFrameBuffer () )
	self.dummyLayer:setViewport ( target:getMoaiViewport () )
end

function RenderContext:getGlobalTextureItem ( name )
	return getRenderManager ():getGlobalTextureItem ( name )
end

function RenderContext:_setGlobalTextureValue ( item, tex )
	self.globalTextureValues[ item ] = tex
end

function RenderContext:_getGlobalTextureValue ( item )
	return self.globalTextureValues[ item ]
end

function RenderContext:setGlobalTextures ( t )
	for name, tex in pairs ( t ) do
		local item = self:getGlobalTextureItem ( name )
		assert ( item, "global texture not found:" .. name )
		item:setTexture ( self, tex )
	end

	self:updateGlobalTextures ()
end

function RenderContext:setGlobalTexture ( name, tex )
	local item = self:getGlobalTextureItem ( name )
	assert ( item, "global texture not found:" .. name )
	item:setTexture ( self, tex )
	self:updateGlobalTextures ()
end

function RenderContext:updateGlobalTextures ()
	local mgr = getRenderManager ()
	local mat = self.rootMaterialBatch
	local unit0 = mgr.globalTextureUnitStart

	for i, item in ipairs ( mgr:getGlobalTextureItems () ) do
		local idx = unit0 + item.index
		local tex = item:getMoaiTexture ( self )
		if tex then
			mat:setTexture ( 1, idx, tex )
		else
			mat:setTexture ( 1, idx )
		end
	end
end

function RenderContext:getGlobalTexture ( name )
	local item = self:getGlobalTextureItem ( name )
	if item then
		return item:getTexture ( self )
	else
		return nil
	end
end

function RenderContext:setRenderTable ( t )
	self.rootRenderPass:setRenderTable ( t )
end

function RenderContext:draw ()
	self.rootRenderPass:draw ()
end

function RenderContext:getRenderRoot ()
	return self.rootRenderPass
end

function RenderContext:getRenderTarget ()
	return self.renderTarget
end

function RenderContext:getOutputViewport ()
	return self.renderTarget
end

function RenderContext:getViewportRect ()
	return self.renderTarget:getAbsPixelRect ()
end

function RenderContext:getViewportScale ()
	return self.renderTarget:getScale ()
end

function RenderContext:getFrameBuffer ()
	return self.frameBuffer
end

function RenderContext:setFrameBuffer ( fb )
	self.frameBuffer = fb
	self.rootRenderPass:setFrameBuffer ( fb )
end

function RenderContext:getContentSize ()
	return self.contentWidth, self.contentHeight
end

function RenderContext:getScale ()
	return self.scale
end

function RenderContext:getSize ()
	return self.width, self.height
end

function RenderContext:setContentSize ( w, h )
	_stat ( "resize context content", self, w, h )
	self.contentWidth = w
	self.contentHeight = h
	self:onResizeContent ( w, h )
end

function RenderContext:setSize ( w, h, scale )
	_stat ( "resize context", self, w, h )
	self.width = w
	self.height = h
	self.scale = scale or 1
	self:onResize ( w, h, scale )
end

function RenderContext:onInit ()
end

function RenderContext:onContextReady ()
end

function RenderContext:onActivate ()
end

function RenderContext:onDeactivate ()
end

function RenderContext:onResize ( w, h, scale )
end

function RenderContext:onResizeContent ( w, h, scale )
end

function RenderContext:makeCurrent ()
	getRenderManager ():setCurrentContext ( self )
end

function RenderContext:isCurrent ()
	return self.current
end

---@param id string
function RenderContext:register ( id )
	getRenderManager ():registerContext ( id, self )
end

function RenderContext:deviceToContext ( x, y )
	return x, y
end

function RenderContext:contextToDevice ( x, y )
	return x, y
end

--------------------------------------------------------------------
-- DummyRenderContext
--------------------------------------------------------------------
local DummyRenderContext = CLASS: DummyRenderContext ( RenderContext )
	:MODEL {}


RenderContextModule.RenderContext = RenderContext
RenderContextModule.DummyRenderContext = DummyRenderContext

return RenderContextModule