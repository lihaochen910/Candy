-- import
local AssetLibraryModule = require 'candy.AssetLibrary'
local AsyncTextureLoadTaskModule = require 'candy.task.AsyncTextureLoadTask'
local AsyncTextureLoadTask = AsyncTextureLoadTaskModule.AsyncTextureLoadTask

-- module
local Deck2DModule = {}

--------------------------------------------------------------------
local loadedDecks = table.weak ()

local function getLoadedDecks ()
	return loadedDecks
end

--------------------------------------------------------------------
-- Deck2D
--------------------------------------------------------------------
---@class Deck2D
local Deck2D = CLASS: Deck2D ()
	:MODEL {
		Field 'type'     :string()  :no_edit();
		Field 'name'     :string()  :getset('Name')    :readonly() ;
		Field 'texture'  :asset('texture')  :getset('Texture') :readonly() ;		
	}

local _seq = 0
function Deck2D:__init ()
	_seq = _seq + 1
	loadedDecks[ _seq ] = self
	self._deck = self:createMoaiDeck ()
	self._deck.source = self
	self.name  = 'deck'
	self.w = 0
	self.h = 0
end

function Deck2D:__tostring ()
	return string.format ( "%s:%s", self:__repr (), self.name )
end

function Deck2D:setTexture ( path, autoResize )
	self.texturePath = path
	local tex, node = candy.loadAsset ( path )
	if not tex then return false end
	if autoResize ~= false then
		local w, h = tex:getSize ()
		self.w = w
		self.h = h
	end
	self.texture = tex
	self:update ()
	return true
end

function Deck2D:getTexture ()
	return self.texturePath
end

function Deck2D:getTextureInstance ()
	return self.texture
end

function Deck2D:getTextureData ()
	if self.texture then
		return self.texture:getMoaiTextureUV ()
	end
end

function Deck2D:getSize ()
	return self.w, self.h
end

function Deck2D:setSize ( w, h )
	self.w = w
	self.h = h
end

function Deck2D:getRect ()
	local ox,oy = self:getOrigin ()
	local w,h = self:getSize ()
	return ox - w/2, oy - h/2, ox + w/2, oy + h/2 
end

function Deck2D:getBounds ()
	local x0, y0, x1, y1 = self:getRect ()
	return x0, y0, 0, x1, y1, 0
end
	
function Deck2D:setName ( n )
	self.name = n
end

function Deck2D:getName ()
	return self.name
end

function Deck2D:setOrigin ( dx, dy )
end

function Deck2D:getOrigin ()
	return 0,0
end

function Deck2D:getMoaiDeck ()
	return self._deck
end

function Deck2D:createMoaiDeck ()
end

function Deck2D:update ()
end

function Deck2D:load ( data )
end


--------------------------------------------------------------------
-- Quad2D
--------------------------------------------------------------------
---@class Quad2D : Deck2D
local Quad2D = CLASS: Quad2D ( Deck2D )
	:MODEL{
		Field 'ox' :number() :label('origin X');
		Field 'oy' :number() :label('origin Y');
		Field 'w'  :number() :label('width');
		Field 'h'  :number() :label('height');
		'----';
		Field 'reset' :action('reset');
	}

function Quad2D:__init ()
	self.ox = 0
	self.oy = 0
	self.w = 0
	self.h = 0
end

function Quad2D:setOrigin ( ox, oy )
	self.ox = ox
	self.oy = oy
end

function Quad2D:getOrigin ()
	return self.ox, self.oy
end

function Quad2D:createMoaiDeck ()
	return MOAISpriteDeck2D.new ()
end

function Quad2D:update ()
	local deck = self:getMoaiDeck ()
	local w, h = self.w, self.h
	deck:setRect ( self.ox - w/2, self.oy - h/2, self.ox + w/2, self.oy + h/2 )
	if not self.texture then return end	
	local tex, uv = self.texture:getMoaiTextureUV ()
	deck:setTexture ( tex )
	deck:setUVRect ( unpack ( uv ) )
end

function Quad2D:reset ()
	if not self.texture then return end	
	local tex, uv = self.texture:getMoaiTextureUV ()
	local w, h = self.texture:getSize ()
	self.w = w
	self.h = h
	self:update ()
end


--------------------------------------------------------------------
-- Tileset
--------------------------------------------------------------------
---@class Tileset : Deck2D
local Tileset = CLASS: Tileset ( Deck2D )
	:MODEL {
		Field 'ox'       :int() :label('offset X') ;
		Field 'oy'       :int() :label('offset Y') ;
		Field 'tw'       :int() :label('tile width')  ;
		Field 'th'       :int() :label('tile height') ;
		Field 'spacing'  :int() :label('spacing')  ;
		Field 'reset'    :action();
	}

function Tileset:__init ()
	self.ox = 0
	self.oy = 0
	self.tw = 32
	self.th = 32
	self.col = 1
	self.row = 1
	self.spacing = 0
end

function Tileset:getTileSize ()
	return self.tw, self.th
end

function Tileset:getTileCount ()
	return self.col * self.row
end

function Tileset:getTileData ( id )
	return false
end

function Tileset:getTileDimension ()
	return self.col, self.row
end

function Tileset:createMoaiDeck ()
	return MOAITileDeck2D.new ()
end

function Tileset:reset ()
	if not self.texture then return end	
	local tex, uv = self.texture:getMoaiTextureUV ()
	local w, h = self.texture:getSize ()
	self.w = w
	self.h = h
	self:update ()
end

function Tileset:update ()
	local texW, texH = self.w, self.h
	local tw, th  = self.tw, self.th
	local ox, oy  = self.ox, self.oy
	local spacing = self.spacing

	if tw < 0 then tw = 1 end
	if th < 0 then th = 1 end

	self.tw = tw
	self.th = th
	local w1, h1   = tw + spacing, th + spacing
	local col, row = math.floor ( texW / w1 ), math.floor ( texH / h1 )
	self.col = col
	self.row = row

	if not self.texture then return end	

	local deck = self:getMoaiDeck ()
	local tex, uv = self.texture:getMoaiTextureUV ()
	local u0,v1,u1,v0 = unpack ( uv )
	deck:setTexture ( tex )

	local du, dv = u1 - u0, v1 - v0
	deck:setSize (
		col, row, 
		w1 / texW * du,      h1 / texH * dv,
		ox / texW * du + u0, oy / texH * dv + v0,
		tw / texW * du,      th / texH * dv
	)

end

function Tileset:buildPreviewGrid ()
	local grid = MOAIGrid.new ()
	return grid
end

function Tileset:getRawRect ( id )
	return 0,0,1,1 --TODO
end

function Tileset:getTerrainBrushes ()
	return {}
end

function Tileset:findTerrainBrush ( id )
	return nil
end


--------------------------------------------------------------------
-- TileMapTerrainBrush
--------------------------------------------------------------------
---@class TileMapTerrainBrush
local TileMapTerrainBrush = CLASS: TileMapTerrainBrush ()
	:MODEL {}

function TileMapTerrainBrush:__init ()
	self.name = 'terrain'
end

function TileMapTerrainBrush:paint ( layer, x, y )
end

function TileMapTerrainBrush:remove ( layer, x, y )
end

function TileMapTerrainBrush:getName ()
	return self.name
end

function TileMapTerrainBrush:getTerrainId ()
	return self.name
end


--------------------------------------------------------------------
-- QuadArray
--------------------------------------------------------------------
---@class QuadArray : Deck2D
local QuadArray = CLASS: QuadArray ( Deck2D )
	:MODEL {
		Field 'ox'       :int() :label('origin X') ;
		Field 'oy'       :int() :label('origin Y') ;
		Field 'count'    :int();
		'----';
		Field 'offx'     :int() :label('offset X') ;
		Field 'offy'     :int() :label('offset Y') ;
		Field 'tw'       :int() :label('tile width')  ;
		Field 'th'       :int() :label('tile height') ;
		Field 'spacing'  :int() :label('spacing')  ;
		'----';
		Field 'inverseOrder' :boolean();
	}

function QuadArray:__init ()
	self.count   = -1
	self.ox      = 0
	self.oy      = 0
	self.offx    = 0
	self.offy    = 0
	self.tw      = 32
	self.th      = 32
	self.col     = 1
	self.row     = 1
	self.spacing = 0
	self.inverseOrder = false
end

function QuadArray:createMoaiDeck ()
	local deck = MOAISpriteDeck2D.new ()
	return deck
end

function QuadArray:update ()
	if not self.texture then return end
	local deck = self:getMoaiDeck ()
	local tex, uv = self.texture:getMoaiTextureUV ()
	local u0,v0,u1,v1 = unpack ( uv )
	deck:setTexture ( tex )

	local texW, texH  = self.w, self.h
	local tw,   th    = self.tw, self.th
	local offx, offy  = self.offx, self.offy
	local spacing     = self.spacing

	if tw < 0 then tw = 1 end
	if th < 0 then th = 1 end

	self.tw = tw
	self.th = th
	local w1, h1 = tw + spacing, th + spacing
	local col, row = math.floor ( texW / w1 ), math.floor ( texH / h1 )
	
	self.col = col
	self.row = row

	local du, dv = u1 - u0, v1 - v0
	local uu, vv 
	tileU  = tw/texW * du
	tileV  = th/texH * dv
	tileU1 = w1/texW * du
	tileV1 = h1/texH * dv
	offU = offx/texW * du + u0
	offV = offy/texH * dv + v0
	local count = self.count
	if count <= 0 then 
		count = col * row		
	end

	deck:reserveQuads ( count )
	deck:reserveUVQuads ( count )
	local ox, oy  = self.ox, self.oy
	for r = 1, row do
		local done = false
		for c = 1, col do
			local i = c + ( r - 1 ) * col
			if i <= count then
				-- done = true
				-- break
				local tu0 = ( c - 1 ) * tileU1 + offU
				local tv0 = ( row - r ) * tileV1 + offV
				local tu1 = tu0 + tileU
				local tv1 = tv0 + tileV

				deck:setRect ( i, ox - tw/2, oy - th/2, ox + tw/2, oy + th/2 )
				deck:setUVRect ( i, tu0, tv0, tu1, tv1 )
			end
		end
		if done then break end
	end

end


--------------------------------------------------------------------
-- SubQuad
-- QuadList
--------------------------------------------------------------------
---@class SubQuad : Deck2D
local SubQuad = CLASS: SubQuad ()
	:MODEL {
		Field 'x';
		Field 'y';
		Field 'w';
		Field 'h';
		Field 'u1';
		Field 'v1';
		Field 'u0';
		Field 'v0';
	}

---@class QuadList : Deck2D
local QuadList = CLASS: QuadList ( Deck2D )
	:MODEL {
		Field 'ox'       :int() :label('origin X') ;
		Field 'oy'       :int() :label('origin Y') ;
		Field 'count'    :int();
	}

function QuadList:__init ()
	self.count = 0
	self.ox    = 0
	self.oy    = 0
	self.quads = {} 
end

function QuadList:createMoaiDeck ()
	local deck = MOAIGfxQuadListDeck2D.new ()
	return deck
end

function QuadList:clearQuads ()
	self.quads = {}
end

function QuadList:addQuad ( x0,y0,x1,y1, u0,v0,u1,v1 )
	local q = { x0,y0,x1,y1, u0,v0,u1,v1 } 
	table.insert ( self.quads, q )
end

function QuadList:update ()
	if not self.texture then return end
	local deck = self:getMoaiDeck ()
	local tex, uv = self.texture:getMoaiTextureUV ()
	local u0,v0,u1,v1 = unpack ( uv )
	deck:setTexture ( tex )
	
	local quads = self.quads
	local count = #quads
	if count == 0 then return end
	deck:reserveSpriteLists ( count )
	deck:reserveSprites ( count )
	deck:reserveQuads ( count )
	deck:reserveUVQuads ( count )
	deck:setSpriteList ( 1, 1, count )

	for i = 1, count do
		local q = quads[ i ]
		local  x0,y0,x1,y1, u0,v0,u1,v1 = unpack ( q )
		deck:setRect ( i, x0,y0, x1,y1 )
		deck:setUVRect ( i, u0,v0, u1,v1 )
		deck:setSprite ( i, i, i )
	end
end


--------------------------------------------------------------------
-- StretchPatch
--------------------------------------------------------------------
---@class StretchPatch : Deck2D
local StretchPatch = CLASS: StretchPatch ( Quad2D )
	:MODEL {
		Field 'left'   :number() :label('border left')   :meta{ min=0, max=1 };
		Field 'right'  :number() :label('border right')  :meta{ min=0, max=1 };
		Field 'top'    :number() :label('border top')    :meta{ min=0, max=1 };
		Field 'bottom' :number() :label('border bottom') :meta{ min=0, max=1 };
	}

function StretchPatch:__init ()
	self.ox = 0
	self.oy = 0
	self.w = 0
	self.h = 0

	self.left   = 0.33
	self.right  = 0.33
	self.top    = 0.33
	self.bottom = 0.33

	self.repeatX = false
	self.repeatY = false
	self.splitX = true
	self.splitY = true
end

function StretchPatch:setOrigin ( ox, oy )
	self.ox = ox
	self.oy = oy
end

function StretchPatch:createMoaiDeck ()
	local deck = MOAIStretchPatch2D.new ()
	deck:reserveRows ( 3 )
	deck:reserveColumns ( 3 )
	deck:reserveUVRects ( 1 )
	deck:setUVRect ( 1, 0, 1, 1, 0 )
	return deck
end

function StretchPatch:update ()
	local deck = self:getMoaiDeck ()
	if not self.texture then return false end
	local tex, uv = self.texture:getMoaiTextureUV ()
	deck:setTexture ( tex )
	deck:setUVRect ( 1, unpack ( uv ) )

	local w, h = self.w, self.h
	deck:setRect ( self.ox - w/2, self.oy - h/2, self.ox + w/2, self.oy + h/2 )

	if self.splitY then
		deck:setRow ( 1, self.top, false, self.repeatY )
		deck:setRow ( 3, self.bottom, false, self.repeatY )
		deck:setRow ( 2, 1 - (self.top + self.bottom), true, self.repeatY )
	else
		deck:setRow ( 1, 1, true, self.repeatY )
	end

	if self.splitX then
		deck:setColumn ( 1, self.left, false, self.repeatX )
		deck:setColumn ( 3, self.right, false, self.repeatX )
		deck:setColumn ( 2, 1 - (self.left + self.right), true, self.repeatX )
	else
		deck:setColumn ( 1, 1, true, self.repeatX )
	end

	deck.patchWidth = w
	deck.patchHeight = h
end


--------------------------------------------------------------------
-- MESH Decks
--------------------------------------------------------------------
local vertexFormat = MOAIVertexFormat.new ()
vertexFormat:declareCoord ( 1, MOAIVertexFormat.GL_FLOAT, 2 )
vertexFormat:declareUV ( 2, MOAIVertexFormat.GL_FLOAT, 2 )
vertexFormat:declareColor ( 3, MOAIVertexFormat.GL_UNSIGNED_BYTE )

---@class PolygonDeck : Deck2D
local PolygonDeck = CLASS: PolygonDeck ( Deck2D )
	:MODEL{
		Field 'polyline'   :array() :no_edit();		
		Field 'vertexList' :array() :no_edit();		
		Field 'indexList'  :array() :no_edit();		
	}


function PolygonDeck:__init ()
	self.polyline = false
	self.vertexList = {}
	self.indexList = {}
	self.uvScale = { 1,1 }
	self.uvOffset = { 0,0 }
end

function PolygonDeck:createMoaiDeck ()
	local mesh = MOAIMesh.new ()
	mesh:setPrimType ( MOAIMesh.GL_TRIANGLES )
	return mesh
end

function PolygonDeck:update ()
	-- local w, h = self.w, self.h
	-- mesh:setRect( self.ox - w/2, self.oy - h/2, self.ox + w/2, self.oy + h/2 )
	if not self.texture then return end	

	local mesh = self:getMoaiDeck ()
	local tex, uv = self.texture:getMoaiTextureUV ()
	local u0,v0,u1,v1 = unpack ( uv )
	mesh:setTexture ( tex )
	local uscale,vscale = unpack ( self.uvScale )
	local uo,vo = unpack ( self.uvOffset )
	
	local usize = u1 - u0
	local vsize = v1 - v0

	uo = uo * usize
	vo = vo * usize

	local vertexList  = self.vertexList
	local vertexCount = #vertexList
	local indexList   = self.indexList
	local indexCount  = #indexList

	if vertexCount > 3 then
		local vbo = MOAIVertexBuffer.new ()

		vbo:setUsageHint ( BUFFER_USAGE_STATIC_DRAW)
		vbo:setFormat ( vertexFormat)
		vbo:reserve ( vertexCount * vertexFormat:getVertexSize () )

		for i = 1, viCount, 4 do
			local x = vertexList[ i ]
			local y = vertexList[ i + 1 ]
			local u = vertexList[ i + 2 ]
			local v = vertexList[ i + 3 ]
			local fu = u * usize * uscale + u0 + uo
			local fv = v * vsize * vscale + v0 + vo

			vbo:writeFloat ( x, y, 0, fu, fv )
			vbo:writeColor32 ( 1, 1, 1 )
		end

		mesh:setVertexBuffer ( vbo )
		mesh:setTotalElements ( vertexCount )

		local u = {
			vbo:computeBounds ()
		}

		if u[ 1 ] then
			mesh:setBounds ( unpack ( u ) )
		end
	end

end


--------------------------------------------------------------------
-- Cylinder
--------------------------------------------------------------------
---@class CylinderDeck : Deck2D
local CylinderDeck = CLASS: CylinderDeck ( Deck2D )
	:MODEL{
		Field 'radius' ;
		Field 'height' ;
		Field 'span'   :int() :range( 3 );
	}

function CylinderDeck:__init ()
	self.radius = 100
	self.height = 100
	self.span = 16
end

function CylinderDeck:createMoaiDeck ()
	local mesh = MOAIMesh.new ()
	mesh:setPrimType ( MOAIMesh.GL_TRIANGLES )
	return mesh
end

function CylinderDeck:update ()
	-- local w, h = self.w, self.h
	-- mesh:setRect( self.ox - w/2, self.oy - h/2, self.ox + w/2, self.oy + h/2 )
	local mesh = self:getMoaiDeck ()

	local tex, uv = self.texture:getMoaiTextureUV ()
	local u0,v0,u1,v1 = unpack ( uv )
	mesh:setTexture ( tex )
	
	local us = u1-u0
	local vs = v1-v0

	local vertexList  = self.vertexList
	local vertexCount = #vertexList
	local indexList   = self.indexList
	local indexCount  = #indexList

	local vbo = MOAIVertexBuffer.new ()
	vbo:reserve ( vertexCount * vertexFormat:getVertexSize () )
	vbo:setFormat ( vertexFormat )

	for i = 1, vertexCount, 4 do
		local x = vertexList[ i ]
		local y = vertexList[ i + 1 ]
		local u = vertexList[ i + 2 ]
		local v = vertexList[ i + 3 ]

		vbo:writeFloat ( x, y )
		vbo:writeFloat ( u * us + u0, v * vs + v0 )
		vbo:writeColor32 ( 1, 1, 1 )
	end

	mesh:setVertexBuffer ( vbo)
	mesh:setTotalElements ( vbo:countElements () )
	mesh:setBounds ( vbo:computeBounds () )

end


--------------------------------------------------------------------
-- TiledQuad2D
--------------------------------------------------------------------
---@class TiledQuad2D : Deck2D
local TiledQuad2D = CLASS: TiledQuad2D ( Quad2D )
	:MODEL {}

function TiledQuad2D:createMoaiDeck ()
	return MOAITiledQuadDeck.new ()
end


--------------------------------------------------------------------
-- DeckPackBase
--------------------------------------------------------------------
---@class DeckPackBase
local DeckPackBase = CLASS: DeckPackBase ()
	:MODEL {}

function DeckPackBase:getDeck ( name )
	return nil
end


--------------------------------------------------------------------
-- DeckPack
--------------------------------------------------------------------
---@class DeckPack : DeckPackBase
local DeckPack = CLASS: DeckPack ( DeckPackBase )
	:MODEL {}

function DeckPack:__init ()
	self.items = {}
	self.texColor = false
	self.texNormal = false
	self.assetNode = false
end

function DeckPack:getDeck ( name )
	return self.items[ name ]
end

local function _findTexture ( path, name )
	local noExtName = string.format ( "%s/%s", path, name )
	if MOAIFileSystem.checkFileExists ( noExtName ) then
		return noExtName
	end

	local texName = string.format ( "%s/%s.tex", path, name )
	if MOAIFileSystem.checkFileExists ( texName ) then
		return texName
	end

	local hmgName = string.format ( "%s/%s.hmg", path, name )
	if MOAIFileSystem.checkFileExists ( hmgName ) then
		return hmgName
	end

	local pngName = string.format ( "%s/%s.png", path, name )
	if MOAIFileSystem.checkFileExists ( pngName ) then
		return pngName
	end

	return nil
end

function DeckPack:load ( path )
	local asyncTexture = TEXTURE_ASYNC_LOAD
	local packData = loadAssetDataTable ( path .. "/" .. "decks.json" )
	self.texColor = MOAITexture.new ()
	self.texNormal = MOAITexture.new ()

	if asyncTexture then
		local taskC = AsyncTextureLoadTask ( _findTexture ( path, "decks"), MOAIImage.TRUECOLOR )
		taskC:setTargetTexture ( self.texColor )

		local taskN = AsyncTextureLoadTask ( _findTexture ( path, "decks_n"), MOAIImage.TRUECOLOR )
		taskN:setTargetTexture ( self.texNormal )

		taskC:start ()
		taskN:start ()
	else
		self.texColor:load ( _findTexture ( path, "decks" ), MOAIImage.TRUECOLOR, nil, true )
		self.texNormal:load (_findTexture ( path, "decks_n" ), MOAIImage.TRUECOLOR, nil, true )
	end

	self.texColor:setFilter ( MOAITexture.GL_NEAREST )
	self.texNormal:setFilter ( MOAITexture.GL_NEAREST )

	local deckDatas = packData.decks
	local deckCount = #deckDatas

	for i = 1, deckCount do
		local deckData = deckDatas[ i ]
		local deckType = deckData.type
		local deck = nil

		if deckType == "deck2d.mquad" then
			deck = MQuadDeck ()
		elseif deckType == "deck2d.mtileset" then
			deck = MTileset ()
		elseif deckType == "deck2d.quads" then
			deck = QuadsDeck ()
		end

		local name = deckData.name
		deck:load ( deckData )
		deck.name = name
		deck.pack = self

		self.items[ name ] = deck
	end
end

local function DeckPackloader ( node )
	local pack = DeckPack ()
	pack.assetNode = node
	local dataPath = node:getObjectFile ( "export" )
	pack:load ( dataPath )
	return pack
end

local function Deck2DPackUnloader ( node )
	local pack = node:getCachedAsset ()

	if not pack then
		return
	end

	if pack.texNormal then
		pack.texNormal:purge ()
	end

	if pack.texColor then
		pack.texColor:purge ()
	end
end

--------------------------------------------------------------------
-- Deck2DPack
--------------------------------------------------------------------
---@class Deck2DPack : DeckPackBase
local Deck2DPack = CLASS: Deck2DPack ( DeckPackBase )
	:MODEL{
		Field 'name'  :string();
		Field 'decks' :array( Deck2D ) :no_edit() :sub()
	}

function Deck2DPack:__init ()
	self.decks = {}
end

function Deck2DPack:getDeck ( name )
	for i, deck in ipairs ( self.decks ) do
		if deck.name == name then return deck end
	end
	return nil
end

function Deck2DPack:addDeck ( name, dtype, src )
	local deck
	if dtype == 'quad' then
		local quad = Quad2D ()
		quad:setTexture ( src )
		deck = quad
	elseif dtype == 'tileset' then
		local tileset = Tileset ()
		tileset:setTexture ( src )
		deck = tileset
	elseif dtype == 'stretchpatch' then
		local patch = StretchPatch ()
		patch:setTexture ( src )
		deck = patch
	elseif dtype == 'quad_array' then
		local qa = QuadArray ()
		qa:setTexture ( src )
		deck = qa
	elseif dtype == 'polygon' then
		local poly = PolygonDeck ()
		poly:setTexture ( src )
		deck = poly
	end
	deck.type = dtype
	deck:setName ( name )
	deck.pack = self
	table.insert ( self.decks, deck )
	return deck
end

function Deck2DPack:removeDeck ( deck )
	local idx = table.index ( self.decks, deck )
	if idx then table.remove ( self.decks, idx ) end
end

--------------------------------------------------------------------
local function Deck2DPackLoader ( node )
	local packData = loadAssetDataTable ( node:getObjectFile ('def') )
	local pack = deserialize ( nil, packData )
	return pack
end

local function Deck2DPackUnloader ( node )
	local pack = node:getCachedAsset ()
	if not pack then return end
	for i, item in ipairs ( pack.decks ) do
		local name = item.name
		releaseAsset ( node:getChildPath ( name ) )
	end
end

local function Deck2DItemLoader ( node )
	local pack = candy.loadAsset ( node.parent )
	local name = node:getName ()
	local item = pack:getDeck ( name )
	if item then
		item:update ()
		node.cached.deckItem = item
		return item		
	end
	return nil
end

local function Deck2DItemRuntimeLoader ( path, option )
	local atype = option[ 'asset_type_hint' ]
	local node = AssetLibraryModule.registerAssetNode ( path, {
			type = atype, 
			objectFiles = {},
			dependency = {}
		}
	)
	return node
end

--------------------------------------------------------------------
AssetLibraryModule.registerAssetLoader ( 'deck2d', Deck2DPackLoader, Deck2DPackUnloader )
AssetLibraryModule.registerAssetLoader ( "deck_pack", DeckPackloader )
AssetLibraryModule.registerAssetLoader ( "deck_pack_raw", DeckPackloader )

AssetLibraryModule.registerAssetLoader ( 'deck2d.quad',         Deck2DItemLoader )
AssetLibraryModule.registerAssetLoader ( 'deck2d.tileset',      Deck2DItemLoader )
AssetLibraryModule.registerAssetLoader ( 'deck2d.stretchpatch', Deck2DItemLoader )
AssetLibraryModule.registerAssetLoader ( 'deck2d.polygon',      Deck2DItemLoader )
AssetLibraryModule.registerAssetLoader ( 'deck2d.quad_array',   Deck2DItemLoader )

AssetLibraryModule.registerRuntimeAssetLoader ( 'deck2d.quad' , 		Deck2DItemRuntimeLoader )
AssetLibraryModule.registerRuntimeAssetLoader ( 'deck2d.tileset',      	Deck2DItemRuntimeLoader )
AssetLibraryModule.registerRuntimeAssetLoader ( 'deck2d.stretchpatch', 	Deck2DItemRuntimeLoader )
AssetLibraryModule.registerRuntimeAssetLoader ( 'deck2d.polygon',		Deck2DItemRuntimeLoader )
AssetLibraryModule.registerRuntimeAssetLoader ( 'deck2d.quad_array',	Deck2DItemRuntimeLoader )
AssetLibraryModule.registerRuntimeAssetTypeHinter ( 'deck2d', 'deck_pack' )


Deck2DModule.getLoadedDecks = getLoadedDecks
Deck2DModule.Deck2D = Deck2D
Deck2DModule.Quad2D = Quad2D
Deck2DModule.Tileset = Tileset
Deck2DModule.TileMapTerrainBrush = TileMapTerrainBrush
Deck2DModule.QuadArray = QuadArray
Deck2DModule.SubQuad = SubQuad
Deck2DModule.StretchPatch = StretchPatch
Deck2DModule.PolygonDeck = PolygonDeck
Deck2DModule.CylinderDeck = CylinderDeck
Deck2DModule.TiledQuad2D = TiledQuad2D
Deck2DModule.DeckPackBase = DeckPackBase
Deck2DModule.DeckPack = DeckPack
Deck2DModule.Deck2DPack = Deck2DPack
Deck2DModule.Deck2DPackLoader = Deck2DPackLoader
Deck2DModule.Deck2DPackUnloader = Deck2DPackUnloader

return Deck2DModule