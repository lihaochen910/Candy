-- import
local ComponentModule = require 'candy.Component'
local TexturePlane = require 'candy.gfx.TexturePlane'
local Deck2DModule = require 'candy.asset.Deck2D'

---@class PatchTexturePlane : TexturePlane
local PatchTexturePlane = CLASS: PatchTexturePlane ( TexturePlane )
	:MODEL {
		"----",
		Field ( "layoutX" ):type ( "vec2" ):getset ( "LayoutX" ),
		Field ( "layoutY" ):type ( "vec2" ):getset ( "LayoutY" )
	}

ComponentModule.registerComponent ( "PatchTexturePlane", PatchTexturePlane )

function PatchTexturePlane:__init ()
	self.deck = Deck2DModule.StretchPatch ()
	self.prop:setDeck ( self.deck:getMoaiDeck () )
	self.w = 100
	self.h = 100
	self.layoutLeft = 0.33
	self.layoutRight = 0.33
	self.layoutUp = 0.33
	self.layoutDown = 0.33
end

function PatchTexturePlane:getLayoutX ()
	return self.layoutLeft, self.layoutRight
end

function PatchTexturePlane:getLayoutY ()
	return self.layoutUp, self.layoutDown
end

function PatchTexturePlane:onAttach ( ent )
	PatchTexturePlane.__super.onAttach ( self, ent )
	self:updateLayout ()
end

function PatchTexturePlane:setLayoutX ( a, b )
	self.layoutRight = b
	self.layoutLeft = a
	self:updateLayout ()
end

function PatchTexturePlane:setLayoutY ( a, b )
	self.layoutDown = b
	self.layoutUp = a
	self:updateLayout ()
end

function PatchTexturePlane:updateLayout ()
	local deck = self.deck
	deck.left = self.layoutLeft
	deck.right = self.layoutRight
	deck.top = self.layoutUp
	deck.bottom = self.layoutDown
	deck:update ()
end

function PatchTexturePlane:setTexture ( t )
	PatchTexturePlane.__super.setTexture ( self, t )

	if self.texture then
		local tex = candy.loadAsset ( self.texture )

		if tex then
			local w, h = tex:getSize ()
			self.deck:setSize ( w, h )
			self.deck:update ()

			local d = self:getMoaiDeck ()
			self:updateSize ()
		end
	end
end

function PatchTexturePlane:sizeToScl ( w, h )
	local patch = self:getMoaiDeck ()

	if patch then
		local pw = patch.patchWidth or w
		local ph = patch.patchHeight or h
		return w / pw, h / ph
	else
		return w, h
	end
end

function PatchTexturePlane:sclToSize ( sx, sy )
	local patch = self:getMoaiDeck ()

	if patch then
		local pw = patch.patchWidth or 1
		local ph = patch.patchHeight or 1
		return sx * pw, sy * ph
	else
		return sx, sy
	end
end

function PatchTexturePlane:updateSize ()
	self.prop:setScl ( self:sizeToScl ( self.w, self.h ) )
end

function PatchTexturePlane:getSize ()
	return self.w, self.h
end

function PatchTexturePlane:getWorldSize ()
	local sx, sy = self:getEntity ():getWorldScl ()
	return sx * self.w, sy * self.h
end

function PatchTexturePlane:setWorldSize ( w, h )
	local sx, sy = self:getEntity ():getWorldScl ()
	return self:setSize ( w / sx, h / sy )
end

function PatchTexturePlane:setSize ( w, h )
	self.w = w
	self.h = h
	self:updateSize ()
end

return PatchTexturePlane