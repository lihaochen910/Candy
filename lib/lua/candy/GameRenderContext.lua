-- import
local Viewport = require 'candy.Viewport'
local RenderTargetModule = require 'candy.RenderTarget'
local RenderTarget = RenderTargetModule.RenderTarget
local TextureRenderTarget = RenderTargetModule.TextureRenderTarget
local RenderManagerModule = require 'candy.RenderManager'
local RenderContextModule = require 'candy.RenderContext'
local RenderContext = RenderContextModule.RenderContext

local function _valueList ( ... )
	local output = {}
	local insert = table.insert
	local n = select ( "#", ... )

	for i = 1, n do
		local v = select ( i, ... )
		if v then
			insert ( output, v )
		end
	end

	return output
end

---@class GameRenderContext : RenderContext
local GameRenderContext = CLASS: GameRenderContext ( RenderContext )

function GameRenderContext:__init ()
	self.outputMode = "direct"
end

function GameRenderContext:getOutputViewport ()
	return self.outputViewport
end

function GameRenderContext:setOutputMode ( mode )
	assert ( mode == "direct" or mode == "scaled" )
	self.outputMode = mode
end

function GameRenderContext:onInit ()
	_stat ( "init game render context" )

	if self.outputMode == "direct" then
		self:initDeviceOutputRenderTarget ()
	elseif self.outputMode == "scaled" then
		self:initTextureOutputRenderTarget ()
	else
		error ( "invalid output mode" )
	end

	self:initPlaceHolderRenderTable ()
	self:setFrameBuffer ()
end

function GameRenderContext:setOutputScale ( scl )
	if self.outputMode == "scaled" then
		self.outputViewport:setFixedScale ( 1 / scl, 1 / scl )
	else
		self.mainRenderTarget:setZoom ( scl, scl )
	end
end

function GameRenderContext:initDeviceOutputRenderTarget ()
	local w, h = self:getContentSize ()

	_stat ( "init device output render target" )

	local outputViewport = Viewport ()
	outputViewport:setParent ( game:getDeviceRenderTarget () )
	outputViewport:setMode ( "relative" )
	outputViewport:setKeepAspect ( false )
	outputViewport:setFixedScale ( w, h )
	self.outputViewport = outputViewport

	local mainRenderTarget = RenderTarget ()
	mainRenderTarget:setFrameBuffer ( assert ( game:getDeviceRenderTarget ():getFrameBuffer () ) )
	mainRenderTarget:setParent ( outputViewport )
	mainRenderTarget:setMode ( "relative" )
	mainRenderTarget:setAspectRatio ( w / h )
	mainRenderTarget:setKeepAspect ( true )
	mainRenderTarget:setZoom ( 1, 1 )
	mainRenderTarget:setDebugName ( "deviceRT" )
	mainRenderTarget.__main = true
	self.mainRenderTarget = mainRenderTarget
	self.textureRenderTarget = false

	self:setRenderTarget ( mainRenderTarget )

	self.dummyLayer:setViewport ( mainRenderTarget:getMoaiViewport () )
end

function GameRenderContext:initTextureOutputRenderTarget ()
	local w, h = self:getContentSize ()

	_stat ( "init texture ouput render target", w, h )

	local mainRenderTarget = TextureRenderTarget ()
	local option = {
		useStencilBuffer = false,
		useDepthBuffer = false,
		filter = MOAITexture.GL_LINEAR,
		colorFormat = MOAITexture.GL_RGBA8
	}
	mainRenderTarget:initFrameBuffer ( option )
	mainRenderTarget:setDebugName ( "deviceTRT" )
	mainRenderTarget.mode = "fixed"
	mainRenderTarget:setPixelSize ( w, h )
	mainRenderTarget:setFixedScale ( w, h )
	mainRenderTarget.__main = true

	local quad = MOAISpriteDeck2D.new ()
	quad:setRect ( -0.5, -0.5, 0.5, 0.5 )

	if getRenderManager ().flipRenderTarget then
		quad:setUVRect ( 0, 1, 1, 0 )
	else
		quad:setUVRect ( 0, 0, 1, 1 )
	end

	local outputRenderProp = createRenderProp ()
	outputRenderProp:setDeck ( quad )
	setPropBlend ( outputRenderProp, "solid" )
	outputRenderProp:setDepthTest ( 0 )
	outputRenderProp:setColor ( 1, 1, 1, 1 )
	quad:setTexture ( mainRenderTarget:getFrameBuffer () )

	local viewport = Viewport ()
	viewport:setMode ( "relative" )
	viewport:setFixedScale ( 1, 1 )
	viewport:setAspectRatio ( w / h )
	viewport:setKeepAspect ( true )
	viewport:setParent ( game:getDeviceRenderTarget () )
	viewport._main = true

	local outputRenderPass = MOAITableViewLayer.new ()
	outputRenderPass:setClearColor ( 0, 0, 0, 1 )
	outputRenderPass:setClearMode ( MOAILayer.CLEAR_NEVER )
	outputRenderPass:setViewport ( viewport:getMoaiViewport () )
	outputRenderPass:setFrameBuffer ( MOAIGfxMgr.getFrameBuffer () )
	outputRenderPass:setRenderTable ( { outputRenderProp } )

	self.outputViewport = viewport
	self.outputRenderPass = outputRenderPass
	self.outputRenderProp = outputRenderProp
	self.mainRenderTarget = mainRenderTarget
	self.textureRenderTarget = mainRenderTarget

	self:setRenderTarget ( mainRenderTarget )
	self:updateViewportDeviceMapping ()

	local mainClearRenderPass = RenderManagerModule.createTableRenderLayer ()

	if game:isEditorMode () then
		mainClearRenderPass:setClearColor ( 0.1, 0.1, 0.1, 1 )
	else
		mainClearRenderPass:setClearColor ( 0, 0, 0, 1 )
	end

	self.mainClearRenderPass = mainClearRenderPass

	mainClearRenderPass:setFrameBuffer ( mainRenderTarget:getFrameBuffer () )
	mainClearRenderPass:setClearMode ( MOAILayer.CLEAR_ALWAYS )
end

---
-- 当渲染内容为空的时候将使用默认的渲染表
-- 默认渲染顺序:
-- game.preSyncRender -> clearPass -> game.postRender
function GameRenderContext:initPlaceHolderRenderTable ()
	local clearPass = RenderManagerModule.createTableRenderLayer ()
	clearPass:setClearColor ( 0, 0.2, 0, 1 )
	clearPass:setFrameBuffer ( MOAIGfxMgr.getFrameBuffer () )
	clearPass:setClearMode ( MOAILayer.CLEAR_ALWAYS )

	local async = false --MOAIRenderMgr.isAsync ()
	self.placeHolderRenderTable = _valueList ( {
		not async and function ()
			return game:preSyncRender ()
		end,
		clearPass,
		-- getLogViewManager ():getRenderLayer (),
		-- not candy.__nodebug and getDebugUIManager ():getRenderLayer () or false,
		not async and function ()
			return game:postRender ()
		end,
		-- getUICursorManager ():getRenderLayer ()
	} )
end

function GameRenderContext:applyPlaceHolderRenderTable ()
	_stat ( "apply placeholder render table" )
	self:getRenderRoot ():setRenderTable ( self.placeHolderRenderTable )
end

---
-- 当存在渲染内容的时候的apply方法
-- 渲染顺序:
-- game.preSyncRender -> game.baseClearRenderPass -> self.mainClearRenderPass -> game.preRenderTable
-- -> contentTable -> outputRenderPass -> ... -> postRender
function GameRenderContext:applyMainRenderTable ( contentTable )
	local async = false --MOAIRenderMgr.isAsync ()

	_stat ( "apply main render table", contentTable, contentTable and #contentTable )

	local game = game
	local insert = table.insert
	local allowDebug = false--not candy.__nodebug
	local finalTable = _valueList ( 
		not async and function ()
			return game:preSyncRender ()
		end, 
		game.baseClearRenderPass, 
		self.mainClearRenderPass or false, 
		game.preRenderTable, 
		contentTable or false, 
		self.outputRenderPass, 
		allowDebug and getTopOverlayManager ():getRenderLayer () or false, 
		allowDebug and getLogViewManager ():getRenderLayer () or false, 
		allowDebug and getDebugUIManager ():getRenderLayer () or false, 
		not async and function ()
			return game:postRender ()
		end, 
		-- getUICursorManager ():getRenderLayer () or false, 
		game.postRenderTable 
	)

	self:getRenderRoot ():setRenderTable ( finalTable )
end

function GameRenderContext:setRenderTable ( contentTable )
	if not contentTable then
		return self:applyPlaceHolderRenderTable ()
	else
		return self:applyMainRenderTable ( contentTable )
	end
end

function GameRenderContext:deviceToViewport ( x, y )
	return x, y
end

function GameRenderContext:viewportToDevice ( x, y )
	return x, y
end

function GameRenderContext:onResize ()
	self:updateViewportDeviceMapping ()
end

function GameRenderContext:updateViewportDeviceMapping ()
	if self.outputMode == "direct" then
		self.deviceToContext = nil
		self.contextToDevice = nil
	else
		local x0, y0, x1, y1 = self.outputViewport:getAbsPixelRect ()
		local vw = x1 - x0
		local vh = y1 - y0
		local w, h = self:getContentSize ()

		function self.deviceToContext ( _, x, y )
			local ox = x - x0
			local oy = y - y0
			return ox / vw * w, oy / vh * h
		end

		function self.contextToDevice ( _, x, y )
			return x / w * vw + x0, y / h * vh + y0
		end
	end
end

return GameRenderContext