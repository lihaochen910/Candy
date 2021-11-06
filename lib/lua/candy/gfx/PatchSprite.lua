-- import
local DeckComponent = require 'candy.gfx.DeckComponent'
local ComponentModule = require 'candy.Component'
local DeckMgr = require 'candy.asset.DeckMgr'

---@class PatchSprite : DeckComponent
local PatchSprite = CLASS: PatchSprite ( DeckComponent )
	:MODEL {
		Field "deck" :asset("deck2d\\.stretchpatch") :getset("Deck");
		Field "size" :type("vec2") :getset("Size");
	}

ComponentModule.registerComponent ( "PatchSprite", PatchSprite )

function PatchSprite:__init ( imagePath, width, height )
	self.imagePath = imagePath
	self:setImage ( imagePath, width, height )
    if not width or not height then
        self:setSize ( width or self.displayWidth, height or self.displayHeight )
    end
end

function PatchSprite:setDeck ( deck )
	local w, h = self:getSize ()
	DeckComponent.setDeck ( self, deck )
	self:setSize ( w, h )
end

---
-- Set the NineImageDeck.
---@param imagePath File path or NineImageDeck.
---@param width (option) Width of image.
---@param height (option) Height of image.
function PatchSprite:setImage ( imagePath, width, height )
	local deck = imagePath
    if type ( deck ) == "string" then
        deck = DeckMgr:getNineImageDeck ( imagePath )
    end

    local orgWidth, orgHeight = self:getSize ()
    width = width or orgWidth
    height = height or orgHeight

    self:setDeck ( deck )
    self.displayWidth = deck.displayWidth
    self.displayHeight = deck.displayHeight
    self.contentPadding = deck.contentPadding

    self:setSize ( width, height )
end

function PatchSprite:setWidth ( w )
	local sclX = self:sizeToScl ( w, 1 )
	setSclX ( self.prop, sclX )
end

function PatchSprite:setHeight ( h )
	local _, sclY = self:sizeToScl ( 1, h )
	setSclY ( self.prop, sclY )
end

function PatchSprite:sizeToScl ( w, h )
	local patch = self:getMoaiDeck ()

	if patch then
		local pw = patch.patchWidth or w
		local ph = patch.patchHeight or h

		return w / pw, h / ph
	else
		return w, h
	end
end

function PatchSprite:sclToSize ( sx, sy )
	local patch = self:getMoaiDeck ()

	if patch then
		local pw = patch.patchWidth or w
		local ph = patch.patchHeight or h
		return sx * pw, sy * ph
	else
		return sx, sy
	end
end

function PatchSprite:getSize ()
	return self:sclToSize ( self.prop:getScl () )
end

function PatchSprite:setSize ( w, h )
	self.prop:setScl ( self:sizeToScl ( w, h ) )
end

---
-- Returns the content rect from NinePatch.
---@return xMin
---@return yMin
---@return xMax
---@return yMax
function PatchSprite:getContentRect ()
    local width, height = self:getSize ()
    local padding = self.contentPadding
    local xMin = padding[ 1 ]
    local yMin = padding[ 2 ]
    local xMax = width - padding[ 3 ]
    local yMax = height - padding[ 4 ]
    return xMin, yMin, xMax, yMax
end

function PatchSprite:seekSize ( w, h, t, easeType )
	local sx, sy = self:sizeToScl ( w, h )
	return self.prop:seekScl ( sx, sy, nil, t, easeType )
end

function PatchSprite:moveSize ( dw, dh, t, easeType )
	local dx, dy = self:sizeToScl ( dw, dh )
	return self.prop:moveScl ( dx, dy, 0, t, easeType )
end


return PatchSprite