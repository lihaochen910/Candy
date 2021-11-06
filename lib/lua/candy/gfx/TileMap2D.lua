-- import
local ComponentModule = require 'candy.Component'
local TilemapModule = require 'candy.gfx.TileMap'
local TileMapLayer = TilemapModule.TileMapLayer
local TileMap = TilemapModule.TileMap
local TileMapGrid = TilemapModule.TileMapGrid

-- module
local TileMap2DModule = {}

--------------------------------------------------------------------
-- TileMap2DLayer
--------------------------------------------------------------------
---@class TileMap2DLayer : TileMapLayer
local TileMap2DLayer = CLASS:TileMap2DLayer ( TileMapLayer )
	:MODEL {}

function TileMap2DLayer:onInit ()
	local tileset = self.tileset
	self.mapGrid = TileMapGrid ( EWGrid.new () )
	self.mapGrid:setTileset ( tileset )

	self.prop = markRenderNode ( MOAIGraphicsGridProp.new () )
	self.prop:setGrid ( self.mapGrid:getMoaiGrid () )
	self.prop:setDeck ( tileset:getMoaiDeck () )
	self.mapGrid:setSize ( self.width, self.height, self.tileWidth, self.tileHeight, 0, 0, 1, 1 )
end

function TileMap2DLayer:worldToModel ( x, y )
	return self.prop:worldToModel ( x, y, -y )
end

function TileMap2DLayer:onSetOrder ( orde )
end

function TileMap2DLayer:onSetOffset ( x, y, z )
	if self.prop then
		self.prop:setLoc ( x, y, z )
	end
end

function TileMap2DLayer:applyMaterial ( materialInstance )
	materialInstance:applyToMoaiProp ( self.prop )
end

function TileMap2DLayer:onSetVisible ( vis )
	self.prop:setVisible ( vis )
end


--------------------------------------------------------------------
-- TileMap2D
--------------------------------------------------------------------
---@class TileMap2D : TileMap
local TileMap2D = CLASS: TileMap2D ( TileMap )
	:MODEL {}

function TileMap2D:createLayerByTileset ( tilesetPath )
	local tileset, anode = loadAsset ( tilesetPath )
	local atype = anode:getType ()
	if atype == "deck2d.tileset" then
		return TileMap2DLayer()
	elseif atype == "named_tileset" then
		return TileMap2DLayer()
	elseif atype == "code_tileset" then
		return CodeTileMapLayer ()
	end

	return false
end

function TileMap2D:getSupportedTilesetType ()
	return "deck2d.tileset;named_tileset;deck2d.mtileset;code_tileset"
end


ComponentModule.registerComponent ( "TileMap2D", TileMap2D )

TileMap2DModule.TileMap2DLayer = TileMap2DLayer
TileMap2DModule.TileMap2D = TileMap2D

return TileMap2DModule