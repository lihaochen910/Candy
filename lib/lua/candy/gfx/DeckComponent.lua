-- import
local GraphicsPropComponent = require 'candy.gfx.GraphicsPropComponent'
local ComponentModule = require 'candy.Component'
local Deck2DModule = require 'candy.asset.Deck2D'

---@class DeckComponent : GraphicsPropComponent
local DeckComponent = CLASS: DeckComponent ( GraphicsPropComponent )
	:MODEL {
		Field 'deck' :asset_pre('deck2d\\..*;mesh') :getset('Deck');
	}

ComponentModule.registerComponent ( 'DeckComponent', DeckComponent )
ComponentModule.registerEntityWithComponent ( 'DeckComponent', DeckComponent )

--------------------------------------------------------------------
function DeckComponent:__init ()
	self._moaiDeck = false
end

--------------------------------------------------------------------
---@param deck string | MOAIDeck | Deck2D
function DeckComponent:setDeck ( deck )
	if type ( deck ) == "string" then
		self.deckPath = deckPath
		local deck = candy.loadAsset ( deckPath )
		local moaiDeck = deck and deck:getMoaiDeck ()
		self._deck = deck
		self._moaiDeck = moaiDeck
		self.prop:setDeck ( moaiDeck )
		self.prop:forceUpdate ()
	elseif type ( deck ) == "userdata" then
		self:setMoaiDeck ( deck )
	elseif isInstance ( deck, Deck2DModule.Deck2D ) then
		local moaiDeck = deck and deck:getMoaiDeck ()
		self._deck = deck
		self._moaiDeck = moaiDeck
		self.prop:setDeck ( moaiDeck )
		self.prop:forceUpdate ()
	end
end

---@param deck MOAIDeck
function DeckComponent:setMoaiDeck ( deck )
	self.prop:setDeck ( deck )
end

---@param texture string | Quad2D
function DeckComponent:setQuad2DDeck ( texture )
	if type ( texture ) == "string" then
		local deck = Deck2DModule.Quad2D ()
		deck:setTexture ( texture )
		self:setDeck ( deck )
	elseif isInstance ( texture, Deck2DModule.Deck2D ) then
		local moaiDeck = texture and texture:getMoaiDeck ()
		self._deck = texture
		self._moaiDeck = moaiDeck
		self.prop:setDeck ( moaiDeck )
		self.prop:forceUpdate ()
	end
end

function DeckComponent:getDeck ( deckPath )
	return self.deckPath	
end

function DeckComponent:getBounds ()
	return self.prop:getBounds ()
end

function DeckComponent:getTransform ()
	return self.prop
end

function DeckComponent:getSourceSize ()
	local deck = self._deck
	if deck then
		local w, h = deck:getSize ()
		return w, h, 1
	else
		return 1, 1, 1
	end
end

--------------------------------------------------------------------
function DeckComponent:drawBounds ()
	-- GIIHelper.setVertexTransform ( self.prop )
	local x1,y1,z1, x2,y2,z2 = self.prop:getBounds ()
	MOAIDraw.drawRect ( x1,y1,x2,y2 )
end

--------------------------------------------------------------------
local defaultDeck2DShader = MOAIShaderMgr.getShader ( MOAIShaderMgr.DECK2D_SHADER )
function DeckComponent:getDefaultShader ()
	return defaultDeck2DShader
end

return DeckComponent