-- import
local ComponentModule = require 'candy.Component'
local Component = ComponentModule.Component
local TileMapModule = require 'candy.gfx.TileMap'
local TileMap = TileMapModule.TileMap

---@class TilemapBrush : Component
local TilemapBrush = CLASS: TilemapBrush ( Component )
	:MODEL {
		Field "targetTileMap" :type ( TileMap ),
		Field "targetLayer" :string ()
	}

function TilemapBrush:__init ()
	self.targetTileMap = false
	self.targetLayer = false
	self.targetTileLayer = false
end

function TilemapBrush:onAttach ( ent )
	TilemapBrush.__super.onAttach ( self, ent )

	self.updateNode = MOAIScriptNode.new ()
	local lastX = false
	local lastY = false

	self.updateNode:setCallback ( function  ()
		local x, y = ent:getWorldLoc ()
		local layer = self.targetTileLayer

		if not layer then
			return
		end

		local newX, newY = layer:worldToCoord ( x, y )
		if newX ~= lastX or newY ~= lastY then
			self:onPaint ( layer, newX, newY, lastX, lastY )
			lastY = newY
			lastX = newX
		end
	end )
	self.updateNode:setNodeLink ( ent:getProp () )
end

function TilemapBrush:onPaint ( layer, x, y, x0, y0 )
end

function TilemapBrush:getTileValue ()
	return 0
end

function TilemapBrush:onDetach ( ent )
	TilemapBrush.__super.onDetach ( self, ent )
	self.updateNode:clearNodeLink ( ent:getProp () )
	self.targetTileLayer = false
end

function TilemapBrush:onStart ( ent )
	if self.targetTileMap and self.targetLayer then
		self.targetTileLayer = self.targetTileMap:findLayerByName ( self.targetLayer )
	else
		self.targetTileLayer = false
	end
end

return TilemapBrush