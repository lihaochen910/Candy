--------------------------------------------------------------------
---- Debug Library
--------------------------------------------------------------------
require ( "candy.mobdebug" ).start ( "localhost", 8172 )

-- package.cpath = package.cpath .. ';/Users/Kanbaru/Library/Application Support/JetBrains/PyCharm2021.2/plugins/EmmyLua/classes/debugger/emmy/mac/?.dylib'
-- local dbg = require('emmy_core')
-- dbg.tcpListen('localhost', 9966)

rawset ( _G, '_C', {} )

--------------------------------------------------------------------
---- import lib
--------------------------------------------------------------------
inspect = require 'inspect'
utf8 = require '3rdparty.utf8.utf8'
config = require 'config'
candy = _G.candy or require 'candy'
--candy_editor = require 'candy_editor'
--candy_edit = require 'candy_edit'

candy.setupEnvironment ( '.', '.' )
candy.Resources.addResourceDirectory ( "assets" )


--------------------------------------------------------------------
---- game init
--------------------------------------------------------------------
---@type Game
candy.game = candy.Game ()
game = candy.game
game:init (
	{ 
		graphics = { 
			device_width = 1600, 
			device_height = 1200, 
			fullscreen = false 
		},
		layers = {
			{
				name = "main",
				default = true,
				parallax = { 1, 1 },
				sort = 'z_descending',
				visible = true
			},
			{
				name = "post-main",
				default = false,
				parallax = { 1, 1, 1 },
				sort = 'z_ascending',
				visible = true
			},
			{
				name = "ui",
				default = false,
				parallax = { 1, 1 },
				sort = 'z_ascending',
				visible = true
			},
		},
	}, false, nil 
)
game:start ()


--------------------------------------------------------------------
---- entry
--------------------------------------------------------------------
local mainLayer = candy.game.mainScene:getLayer ( 'main' )
local uiLayer = candy.game.mainScene:getLayer ( 'ui' )

-- init camera
local cameraEntity = candy.Entity ()
local camera = candy.Camera ()
game.mainCamera = camera
cameraEntity:attach ( camera )
camera:setShowDebugLines ( true )
camera:setClearColor ( 0,0,0,1 )
camera:setLoc ( 0, 0, -1 )
cameraEntity.name = "CameraEntity"

candy.game.mainScene:addEntity ( cameraEntity )


-- deck
local deckEntity = candy.Entity ()
deckEntity:setLayer ( mainLayer )

local deckComponent = candy.DeckComponent ()
deckComponent:setQuad2DDeck ( 'assets/gfx/Miner_mining_1.png' )
deckComponent:getTransform ():setLoc ( 100, 0 )
deckEntity:attach ( deckComponent )

-- local quad = candy.Quad2D ()
-- quad:setTexture ( )
-- local texture = MOAITexture.new ()
-- texture:load ( 'assets/gfx/decks.hmg' )

local deckComponent2 = candy.DeckComponent ()
-- deckComponent2:setQuad2DDeck ( 'assets/gfx/Miner_mining_4.png' )
deckComponent2:getTransform ():setLoc ( 200, 0 )
deckEntity:attach ( deckComponent2 )

-- local psComponent = candy.PatchSprite ( 'assets/gfx/Miner_mining_1.png' )
-- psComponent:getTransform ():setLoc ( 0, 0 )
-- deckEntity:attach ( psComponent )

-- candy.game.mainScene:addEntity ( deckEntity )

-- ui
-- local uiEntity = candy.UIView ()
-- uiEntity:setLayer ( uiLayer )

-- local uiImage = candy.UIImage ()
-- uiImage:setImage ( candy.loadAsset ('assets/gfx/Miner_mining_1.png') )
-- uiEntity:addChild ( uiImage )

-- local uiLabel = candy.UILabel ()
-- uiLabel:setText ( "Hello World" )
-- uiLabel:setSize (300, 30)
-- uiEntity:addChild ( uiLabel )

-- candy.game.mainScene:addEntity ( uiEntity )

local function flower_label_sample_1 ( scene )

	-- label1
    local label1 = candy.Label("Hello World!!")
	label1:setVisible ( true )
    scene:addEntity(label1)
    
    -- label2
    local label2 = candy.Label("Hello World!!", 200, 40, "assets/fonts/sce-ps3-rd-r-latin-webfont.ttf")
    label2:setPos(0, label1:getBottom())
	label2:setVisible ( false )
    scene:addEntity(label2)

    -- label3
    local label3 = candy.Label("こんにちわこんにちわこんにちわこんにちわ", 150, 40, "assets/fonts/VL-PGothic.ttf", 32)
    label3:setPos(0, label2:getBottom())
    -- label3:setWordBreak(MOAITextBox.WORD_BREAK_CHAR)
    label3:fitHeight()
	label3:setVisible ( false )
    scene:addEntity(label3)

    -- label4
    local label4 = candy.Label("こんにちはモアイ！\n改行もOK\n自動でサイズ設定")
    label4:setPos(0, label3:getBottom())
	label4:setVisible ( false )
    scene:addEntity(label4)
    
    -- bitmap font
    local bitmapFont = MOAIFont.new ()
    bitmapFont:loadFromBMFont ( 'assets/fonts/Rodin.fnt' )
    local label5 = candy.Label("Hello BitmapFont!", 300, 100, bitmapFont, 32)
    label5:setShader(MOAIShaderMgr.getShader(MOAIShaderMgr.DECK2D_SHADER))
    label5:setPos(0, label4:getBottom())
    scene:addEntity(label5)
end

local function flower_image_sample ( scene )
	-- image1
    local image1 = candy.Image("assets/gfx/cathead.png")
    scene:addEntity(image1)
    
    -- image2
    local image2 = candy.Image("assets/gfx/cathead.png", 64, 64)
    image2:setPos(0, image1:getBottom())
    -- scene:addEntity(image2)

    -- image3
    local image3 = candy.Image("assets/gfx/cathead.png", nil, nil, true, true)
    image3:setPos(0, image2:getBottom())
    -- scene:addEntity(image3)

    -- image4
    local image4 = candy.Image("assets/gfx/cathead.png")
    image4:setFlip(true, false)
    image4:setPos(0, image3:getBottom())
    -- scene:addEntity(image4)
end

flower_label_sample_1 ( candy.game.mainScene )
flower_image_sample ( candy.game.mainScene )


local CanvasGrid = CLASS: CanvasGrid ( candy.EditorEntity )

function CanvasGrid:onLoad ()
	self:attach ( candy.DrawScript () )
	self.gridSize = { 50, 50 }
end

function CanvasGrid:onDraw ()
	--local context = candy.getCurrentRenderContext ()
	local w, h = MOAIGfxMgr:getViewSize ()
	local x0, y1 = self:wndToWorld ( 0, 0 )
	local x1, y0 = self:wndToWorld ( w, h )
	if w and h then
		--sub grids
		MOAIDraw.setPenWidth ( 1 )
		MOAIDraw.setPenColor ( .4, .4, .4, .5 )
		local dx = x1-x0
		local dy = y1-y0
		local gw, gh = self.gridSize[ 1 ], self.gridSize[ 2 ]
		x0, y1 = self:wndToWorld ( 0, 0 )
		x1, y0 = self:wndToWorld ( w, h )
		local col = math.ceil ( dx/gw )
		local row = math.ceil ( dy/gh )
		local cx0 = math.floor ( x0/gw ) * gw
		local cy0 = math.floor ( y0/gh ) * gh
		for x = cx0, cx0 + col*gw, gw do
			MOAIDraw.drawLine ( x, y0, x, y1 )
		end
		for y = cy0, cy0 + row*gh, gh do
			MOAIDraw.drawLine ( x0, y, x1, y )
		end
	else
		x0, y0 = -100000, -100000
		x1, y1 =  100000,  100000
	end
	--Axis
	MOAIDraw.setPenWidth ( 1 )
	MOAIDraw.setPenColor ( .5, .5, .7, .7 )
	MOAIDraw.drawLine ( x0, 0, x1, 0 )
	MOAIDraw.drawLine ( 0, y0, 0, y1 )

	MOAIDraw.setPenWidth ( 1 )

    --_stat ( "CanvasGrid:onDraw" )
end


local canvasGridEntity = CanvasGrid ()
canvasGridEntity.name = "CanvasGridEntity"

-- entity:addSibling ( canvasGridEntity )

-- local deck = candy.Quad2D ()
-- deck:setTexture ( 'assets/gfx/djmax_icon_1.jpg' )

-- deckComponent:setDeck ( deck )

-- local timer = MOAITimer.new ()
-- timer:setSpan ( 1 )
-- timer:setListener ( MOAITimer.EVENT_TIMER_END_SPAN, function () 
-- 	label1:appendText ( "Nice!" )
-- end )
-- timer:start ()

-- print ( Model.fromName ( "Texture" ) )
-- print ( candy.serializeToString ( Model.fromName ( "Texture" ):newInstance ( "character.png" ) ) )

-- print ( inspect ( _G, { depth = 1 } ) )


-- local asset = candy.loadAsset ( "gfx/Miner_mining_0.png", {}, true )
