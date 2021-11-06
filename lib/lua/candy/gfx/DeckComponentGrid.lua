-- import
local DeckComponent = require 'candy.gfx.DeckComponent'
local ComponentModule = require 'candy.Component'

---@class DeckComponentGrid : DeckComponent
local DeckComponentGrid =  CLASS: DeckComponentGrid ( DeckComponent )
	:MODEL {
		"----",
		Field("gridSize"):type("vec2"):getset("GridSize"):meta({
			decimals = 0
		}),
		Field("cellSize"):type("vec2"):getset("CellSize"),
		Field("spacing"):type("vec2"):getset("Spacing"),
		Field("fitDeckSize"):action()
	}

ComponentModule.registerComponent ( "DeckComponentGrid", DeckComponentGrid )

function DeckComponentGrid:__init ()
	self.gridSize = {
		1,
		1
	}
	self.cellSize = {
		50,
		50
	}
	self.spacing = {
		0,
		0
	}
	self.deckPath = false
	self.attached = false
	self.grid = MOAIGrid.new ()
	self.grid:fill ( 1 )

	self.remapper = MOAIDeckRemapper.new ()
	self.remapper:reserve ( 1 )
	self.remapper:setAttrLink ( 1, self.prop, MOAIProp.ATTR_INDEX )
	self.prop:setGrid ( self.grid )
end

function DeckComponentGrid:_createMoaiProp ()
	return MOAIGraphicsGridProp.new ()
end

function DeckComponentGrid:onAttach ( ent )
	DeckComponentGrid.__super.onAttach ( self, ent )
	self:updateGrid ()
end

function DeckComponentGrid:getGridSize ()
	return unpack ( self.gridSize )
end

function DeckComponentGrid:setGridSize ( x, y )
	self.gridSize = {
		math.floor ( math.max ( 1, x ) ),
		math.floor ( math.max ( 1, y ) )
	}
	self:updateGrid ()
end

function DeckComponentGrid:getCellSize ()
	return unpack ( self.cellSize )
end

function DeckComponentGrid:setCellSize ( x, y )
	self.cellSize = { x, y }
	self:updateGrid ()
end

function DeckComponentGrid:getSpacing ()
	return unpack ( self.spacing )
end

function DeckComponentGrid:setSpacing ( x, y )
	self.spacing = { x, y }
	self:updateGrid ()
end

function DeckComponentGrid:fitDeckSize ()
	local deck = self._moaiDeck

	if not deck then
		return
	end

	local x0, y0, z0, x1, y1, z1 = deck.source:getBounds ()
	local w = x1 - x0
	local h = y1 - y0
	local d = z1 - z0

	return self:setCellSize ( w, h )
end

function DeckComponentGrid:updateGrid ()
	local prop = self:getMoaiProp ()
	local gx, gy = unpack ( self.gridSize )
	local cx, cy = unpack ( self.cellSize )
	local sx, sy = unpack ( self.spacing )
	local ox = 0
	local oy = 0

	self.grid:setSize ( gx, gy, cx + sx, cy + sy, -ox, -oy, 1, 1 )
	self.grid:fill ( 1 )
end

return DeckComponentGrid