-- import
local ComponentModule = require 'candy.Component'
local TexturePlane = require 'candy.gfx.TexturePlane'
local Deck2DModule = require 'candy.asset.Deck2D'

---@class TiledTexturePlane : TexturePlane
local TiledTexturePlane = CLASS: TiledTexturePlane ( TexturePlane )
	:MODEL {
		Field ( "textureSize" ):type ( "vec2" ):getset ( "TextureSize" ):insert_after ( "size" )
	}

ComponentModule.registerComponent ( "TiledTexturePlane", TiledTexturePlane )

function TiledTexturePlane:__init ()
	self.tw = 1
	self.th = 1
end

function TiledTexturePlane:_createDeck ()
	return Deck2DModule.TiledQuad2D ()
end

function TiledTexturePlane:getTextureSize ()
	return self.tw, self.th
end

function TiledTexturePlane:setTextureSize ( w, h )
	self.tw = w
	self.th = h
	self:updateSize ()
end

function TiledTexturePlane:setSize ( w, h )
	self.w = w
	self.h = h
	self:updateSize ()
end

function TiledTexturePlane:updateSize ()
	self.deck:setSize ( self.tw, self.th )
	self.deck:update ()
	local sx = self.w / self.tw
	local sy = self.h / self.th
	self.prop:setScl ( sx, sy )
	self.prop:forceUpdate ()
end

function TiledTexturePlane:resetSize ()
	if self.texture then
		local tex = candy.loadAsset ( self.texture )
		self:setTextureSize ( tex:getOutputSize () )
	end
end

return TiledTexturePlane