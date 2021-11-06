-- import
local candy = require 'candy'
local RenderContext = candy.RenderContext
local Viewport = candy.Viewport
local RenderTarget = candy.RenderTarget
local TextureRenderTarget = candy.TextureRenderTarget
local RenderManagerModule = require 'candy.RenderManager'
local getRenderManager = RenderManagerModule.getRenderManager

-- module
local RenderContextModule = {}

-- function
local createRenderContext
local addContextChangeListeners
local removeContextChangeListener
local changeRenderContext
local getCurrentRenderContextKey
local getCurrentRenderContext
local getRenderContext
local setCurrentRenderContextActionRoot
local setRenderContextActionRoot
local getKeyName

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


--[[
	EditorRenderContext incluces:
		1. an action root
		2. a render table
	shares:
		layer information
		prop
		assets
]]
-- local renderContextTable = {}
-- local currentContext = false ---@type RenderContext

local ContextChangeListeners = {}

local OriginalMOAIActionRoot = MOAIActionMgr.getRoot ()

--------------------------------------------------------------------
---@class EditorRenderContext : RenderContext
local EditorRenderContext = CLASS: EditorRenderContext ( RenderContext )

function EditorRenderContext:__init ( clearColor )
	self.clearColor = clearColor or { 0.1, 0.1, 0.1, 1 }
	local root = MOAIAction.new ()
	root:setAutoStop ( false )
	self.actionRoot = root ---@type MOAIAction
end

function EditorRenderContext:onInit ()
	_stat ( "init editor render context" )
	self:initTextureOutputRenderTarget ()
	self:initPlaceHolderRenderTable ()
	self:setFrameBuffer ()
end

---@param actionRoot MOAIAction
function EditorRenderContext:setActionRoot ( actionRoot )
	self.actionRoot = actionRoot
end

function EditorRenderContext:setOutputScale ( scl )
	self.outputViewport:setFixedScale ( 1 / scl, 1 / scl )
end

function EditorRenderContext:initTextureOutputRenderTarget ()
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
	mainRenderTarget:setDebugName ( "editorTRT" )
	mainRenderTarget.mode = "fixed"
	mainRenderTarget:setPixelSize ( w, h )
	mainRenderTarget:setFixedScale ( w, h )
	mainRenderTarget.__main = true

	local quad = MOAISpriteDeck2D.new ()
	quad:setRect ( -0.5, -0.5, 0.5, 0.5 )

	if RenderManagerModule.getRenderManager ().flipRenderTarget then
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
	mainClearRenderPass:setClearColor ( unpack ( self.clearColor ) )
	mainClearRenderPass:setFrameBuffer ( mainRenderTarget:getFrameBuffer () )
	mainClearRenderPass:setClearMode ( MOAILayer.CLEAR_ALWAYS )

	self.mainClearRenderPass = mainClearRenderPass
end

---
-- 当渲染内容为空的时候将使用默认的渲染表
-- 默认渲染顺序:
-- clearPass
function EditorRenderContext:initPlaceHolderRenderTable ()
	local clearPass = RenderManagerModule.createTableRenderLayer ()
	clearPass:setClearColor ( 0, 0.2, 0, 1 )
	clearPass:setFrameBuffer ( MOAIGfxMgr.getFrameBuffer () )
	clearPass:setClearMode ( MOAILayer.CLEAR_ALWAYS )

	local async = false --MOAIRenderMgr.isAsync ()
	self.placeHolderRenderTable = _valueList ( {
		-- not async and function ()
		-- 	return game:preSyncRender ()
		-- end,
		clearPass,
		-- getLogViewManager ():getRenderLayer (),
		-- not candy.__nodebug and getDebugUIManager ():getRenderLayer () or false,
		-- not async and function ()
		-- 	return game:postRender ()
		-- end,
		-- getUICursorManager ():getRenderLayer ()
	} )
end

function EditorRenderContext:applyPlaceHolderRenderTable ()
	_stat ( "apply placeholder render table" )
	self:getRenderRoot ():setRenderTable ( self.placeHolderRenderTable )
end

---
-- 当存在渲染内容的时候的apply方法
-- 渲染顺序:
-- self.mainClearRenderPass -> contentTable -> outputRenderPass
function EditorRenderContext:applyMainRenderTable ( contentTable )
	local async = false --MOAIRenderMgr.isAsync ()

	_stat ( "apply main render table", contentTable, contentTable and #contentTable )

	local game = game
	local insert = table.insert
	local allowDebug = false--not candy.__nodebug
	local finalTable = _valueList ( 
		--not async and function ()
		--	return game:preSyncRender ()
		--end,
		--game.baseClearRenderPass,
		self.mainClearRenderPass or false, 
		--game.preRenderTable,
		contentTable or false, 
		self.outputRenderPass
		--allowDebug and getTopOverlayManager ():getRenderLayer () or false,
		--allowDebug and getLogViewManager ():getRenderLayer () or false,
		--allowDebug and getDebugUIManager ():getRenderLayer () or false,
		--not async and function ()
		--	return game:postRender ()
		--end,
		-- getUICursorManager ():getRenderLayer () or false, 
		--game.postRenderTable
	)

	self:getRenderRoot ():setRenderTable ( finalTable )
end

function EditorRenderContext:setRenderTable ( contentTable )
	if not contentTable then
		return self:applyPlaceHolderRenderTable ()
	else
		return self:applyMainRenderTable ( contentTable )
	end
end

function EditorRenderContext:deviceToViewport ( x, y )
	return x, y
end

function EditorRenderContext:viewportToDevice ( x, y )
	return x, y
end

function EditorRenderContext:onResize ()
	self:updateViewportDeviceMapping ()
end

function EditorRenderContext:updateViewportDeviceMapping ()
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

--------------------------------------------------------------------
function createRenderContext ( key, cr, cg, cb, ca )
	--[[
		local clearColor = { 0,0,0,1 }
		if cr == false then
			clearColor = false
		else
			clearColor = { cr or 0, cg or 0, cb or 0, ca or 0 }
		end

		local root = MOAIAction.new ()
		root:setAutoStop ( false )
		root._contextKey = key

		local context = {
			key              = key,
			w                = false,
			h                = false,
			clearColor       = clearColor,
			actionRoot       = root,
			bufferTable      = {},
			renderTableMap   = {},
		}
		renderContextTable[ key ] = context
	]]
	local context = EditorRenderContext ( { cr or 0, cg or 0, cb or 0, ca or 0 } )
	context:setName ( key )

	getRenderManager ():registerContext ( key, context )

	return context
end

function addContextChangeListeners ( f )
	ContextChangeListeners[ f ] = true
end

function removeContextChangeListener ( f )
	ContextChangeListeners[ f ] = nil
end

function changeRenderContext ( key, w, h )
	if getRenderManager ():getCurrentContext ().name == key then return end

	local context = getRenderManager ():getContext ( key ) ---@type EditorRenderContext

	assert ( context, 'no render context for:' .. tostring ( key ) )

	for f in pairs ( ContextChangeListeners ) do
		--- key The new key
		--- key The new key
		f ( key, getRenderManager ():getCurrentContext ().name )
	end

	--[[
		local deviceBuffer = MOAIGfxMgr.getFrameBuffer ()

		if currentContext then --persist context
			local bufferTable = MOAIRenderMgr.getBufferTable ()
			local renderTableMap = {}
			local hasDeviceBuffer = false
			for i, fb in pairs ( bufferTable ) do
				if fb.getRenderTarget then
					renderTableMap[ fb ] = fb:getRenderTable ()
				end
			end		
			currentContext.bufferTable       = bufferTable
			currentContext.renderTableMap    = renderTableMap

			if currentContext.deviceRenderTable ~= false then
				currentContext.deviceRenderTable = deviceBuffer:getRenderTable ()
			end

			currentContext.actionRoot = assert( currentContext.actionRoot )
		end

		--TODO: persist clear depth& color flag(need to modify moai)
		
		currentContext    = context
		currentContextKey = key
		currentContext.w  = w
		currentContext.h  = h

		local clearColor = currentContext.clearColor
		--if clearColor then
		--	MOAIGfxMgr.getFrameBuffer ():setClearColor ( unpack ( clearColor ) )
		--else
		--	MOAIGfxMgr.getFrameBuffer ():setClearColor ()
		--end

		for fb, rt in pairs ( currentContext.renderTableMap ) do
			fb:setRenderTable ( rt )
		end
		--MOAIRenderMgr.setBufferTable ( currentContext.bufferTable )
		if currentContext.deviceRenderTable then
			deviceBuffer:setRenderTable ( currentContext.deviceRenderTable )
		end
		MOAIActionMgr.setRoot ( currentContext.actionRoot )
	]]
	RenderManagerModule.getRenderManager ():setCurrentContext ( context )
	MOAIActionMgr.setRoot ( context.actionRoot )
end

function getCurrentRenderContextKey ()
	return getRenderManager ():getCurrentContext ().name
end

function getCurrentRenderContext ()
	return getRenderManager ():getCurrentContext ()
end

function getRenderContext ( key )
	return getRenderManager ():getContext ( key )
end

function setCurrentRenderContextActionRoot ( root )
	getRenderManager ():getCurrentContext ().actionRoot = root
	MOAIActionMgr.setRoot ( root )
end

function setRenderContextActionRoot ( key, root )
	local context = getRenderContext ( key )
	if key == getCurrentRenderContextKey () then
		MOAIActionMgr.setRoot ( root )
	end
	if context then
		context.actionRoot = root
	end
end

--------------------------------------------------------------------
local keymap_CANDY = {
	["alt"]        = 163;
	["pause"]      = 168;
	["menu"]       = 245;
	[","]          = 44;
	["0"]          = 48;
	["4"]          = 52;
	["8"]          = 56;
	["sysreq"]     = 170;
	["@"]          = 64;
	["return"]     = 164;
	["7"]          = 55;
	["\\"]         = 92;
	["insert"]     = 166;
	["d"]          = 68;
	["h"]          = 72;
	["l"]          = 76;
	["p"]          = 80;
	["t"]          = 84;
	["x"]          = 88;
	["right"]      = 180;
	["meta"]       = 162;
	["escape"]     = 160;
	["home"]       = 176;
	["'"]          = 96;
	["space"]      = 32;
	["3"]          = 51;
	["backspace"]  = 163;
	["pagedown"]   = 183;
	["slash"]      = 47;
	[";"]          = 59;
	["scrolllock"] = 166;
	["["]          = 91;
	["c"]          = 67;
	["z"]          = 90;
	["g"]          = 71;
	["shift"]      = 160;
	["k"]          = 75;
	["o"]          = 79;
	["s"]          = 83;
	["w"]          = 87;
	["delete"]     = 167;
	["down"]       = 181;
	["."]          = 46;
	["2"]          = 50;
	["6"]          = 54;
	[":"]          = 58;
	["b"]          = 66;
	["f"]          = 70;
	["j"]          = 74;
	["pageup"]     = 182;
	["up"]         = 179;
	["n"]          = 78;
	["r"]          = 82;
	["v"]          = 86;
	["f12"]        = 187;
	["f13"]        = 188;
	["f10"]        = 185;
	["f11"]        = 186;
	["f14"]        = 189;
	["f15"]        = 190;
	["control"]    = 161;
	["f1"]         = 176;
	["f2"]         = 177;
	["f3"]         = 178;
	["f4"]         = 179;
	["f5"]         = 180;
	["f6"]         = 181;
	["f7"]         = 182;
	["f8"]         = 183;
	["f9"]         = 184;
	["tab"]        = 161;
	["numlock"]    = 165;
	["end"]        = 177;
	["-"]          = 45;
	["1"]          = 49;
	["5"]          = 53;
	["9"]          = 57;
	["="]          = 61;
	["]"]          = 93;
	["a"]          = 65;
	["e"]          = 69;
	["i"]          = 73;
	["m"]          = 77;
	["q"]          = 81;
	["u"]          = 85;
	["y"]          = 89;
	["left"]       = 178;
	["shift"]      = 256;
	["control"]    = 257;
	["alt"]        = 258;
}

local keyname = {}
for k,v in pairs ( keymap_CANDY ) do
	keyname[ v ] = k
end

function getKeyName ( code )
	return keyname[ code ]
end


RenderContextModule.EditorRenderContext = EditorRenderContext
RenderContextModule.createRenderContext = createRenderContext
RenderContextModule.addContextChangeListeners = addContextChangeListeners
RenderContextModule.removeContextChangeListener = removeContextChangeListener
RenderContextModule.changeRenderContext = changeRenderContext
RenderContextModule.getCurrentRenderContextKey = getCurrentRenderContextKey
RenderContextModule.getCurrentRenderContext = getCurrentRenderContext
RenderContextModule.getRenderContext = getRenderContext
RenderContextModule.setCurrentRenderContextActionRoot = setCurrentRenderContextActionRoot
RenderContextModule.setRenderContextActionRoot = setRenderContextActionRoot
RenderContextModule.getKeyName = getKeyName

return RenderContextModule