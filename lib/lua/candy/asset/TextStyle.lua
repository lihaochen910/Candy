-- import
local AssetLibraryModule = require 'candy.AssetLibrary'
local Resources = require 'candy.asset.Resources'

-- module
local TextStyleModule = {}

local fallbackTextStyle = MOAITextStyle.new ()
fallbackTextStyle:setFont ( Resources.getFont () )
fallbackTextStyle:setSize ( 16 )

function getFallbackTextStyle ()
	return fallbackTextStyle
end

local globalTextScale = 1

function setGlobalTextScale ( scl )
	globalTextScale = scl or 1
end

function getGlobalTextScale ()
	return globalTextScale
end

local DEFAULT_STYLESHEET = nil
function getDefaultStyleSheet ()
	if DEFAULT_STYLESHEET then
		return DEFAULT_STYLESHEET
	end

	if DEFAULT_STYLESHEET == nil then
		DEFAULT_STYLESHEET = AssetLibraryModule.findAsset ( "stylesheet" ) or false
	end

	return DEFAULT_STYLESHEET
end

function setDefaultStyleSheet ( path )
	DEFAULT_STYLESHEET = AssetLibraryModule.findAsset ( path )
end

--------------------------------------------------------------------
-- TextStyle
--------------------------------------------------------------------
---@class TextStyle
local TextStyle = CLASS: TextStyle ()
	:MODEL {
		Field "name" :string (),
		Field "font" :asset ( "font_.*" ),
		Field "size" :int ():range ( 1 ),
		Field "color" :type ( "color" ):getset ( "Color" ),
		Field "allowScale" :boolean ()
	}

function TextStyle:__init ()
	self.name = "default"
	self.font = false
	self.size = 20
	self.fontRawSize = false
	self.color = { 1,1,1,1 }
	self.allowScale = true
	self.moaiTextStyle = MOAITextStyle.new ()
	self.moaiTextStyle:setFont ( Resources.getFont () )
end

function TextStyle:getMoaiTextStyle ()
	return self.moaiTextStyle
end

function TextStyle:setColor ( r, g, b, a )
	self.color = { r, g, b, a }
end

function TextStyle:getColor ()
	return unpack ( self.color )
end

function TextStyle:update ()
	local style = self.moaiTextStyle
	local font, node = nil

	if self.font ~= "default" then
		font, node = candy.loadAsset ( self.font )
	end

	font = font or Resources.getFont ()

	style:setFont ( font )
	style:setColor ( self:getColor () )

	local fontSize = self.size
	if self.allowScale then
		local fsize = self.fontRawSize or font.size or 30
		local scale = fontSize / fsize
		style:setSize ( fsize )
		style:setScale ( scale )
	else
		local globalTextScale = getGlobalTextScale ()
		style:setScale ( globalTextScale )
		style:setSize ( fontSize / globalTextScale )
	end

	style.name = self.name
end


--------------------------------------------------------------------
-- StyleSheet
--------------------------------------------------------------------
---@class StyleSheet
local StyleSheet = CLASS: StyleSheet ()
	:MODEL {
		Field "styles" :array ( TextStyle );
	}

function StyleSheet:__init ()
	self.styles = {}
end

function StyleSheet:updateStyles ()
	for i, s in ipairs ( self.styles ) do
		s:update ()
	end
end

function StyleSheet:getStyleNames ()
	local names = {}
	for i, s in ipairs ( self.styles ) do
		names[ i ] = s.name
	end
	return names
end

function StyleSheet:addStyle ()
	local s = TextStyle ()
	table.insert ( self.styles, s )
	return s
end

function StyleSheet:removeStyle ( s )
	local idx = table.index ( self.styles, s )
	if idx then
		table.remove ( self.styles, idx )
	end
end

function StyleSheet:cloneStyle ( s )
	local s1 = self:addStyle ()
	clone ( s, s1 )
	return s1
end

function StyleSheet:applyToTextBox ( box, defaultStyleName )
	local defaultStyle = false
	local defaultStyle1 = false

	for i, style in ipairs ( self.styles ) do
		local k = style.name
		local v = style:getMoaiTextStyle ()
		box:setStyle ( k, v )

		defaultStyle = defaultStyle or v

		if k == "default" then
			defaultStyle = v
		end

		if k == defaultStyleName then
			defaultStyle1 = v
		end
	end

	local result = defaultStyle1 or defaultStyle or fallbackTextStyle
	box:setStyle ( result )
end

local _StyleSheetCache = {}
function makeFontStyleSheetFromFont ( fontPath, size, color, fontRawSize )
	local assetNode = AssetLibraryModule.getAssetNode ( fontPath )
	local tt = assetNode and assetNode:getType ()

	if tt then
		if tt == "stylesheet" then
			local sheet = candy.loadAsset ( fontPath )
			return sheet
		elseif tt:startwith ( "font" ) then
			size = size or 20
			color = color or { 1,1,1,1 }
			fontRawSize = fontRawSize or -1
			local key = string.format ( "%s-%d-(%d,%d,%d,%d)-%d", fontPath, size, color[ 1 ], color[ 2 ], color[ 3 ], color[ 4 ], fontRawSize )
			local sheet = _StyleSheetCache[ key ]

			if sheet then
				return sheet
			end

			local sheet = StyleSheet ()
			local style = sheet:addStyle ()
			style.font = fontPath
			style.size = size
			style.color = color
			style.allowScale = false

			if fontRawSize > 0 then
				style.fontRawSize = fontRawSize
				style.allowScale = true
			end

			sheet:updateStyles ()

			_StyleSheetCache[ key ] = sheet
			return sheet
		end
	else
		return getDefaultStyleSheet ()
	end
end

function StyleSheetLoader ( node )
	local data = loadAssetDataTable ( node:getObjectFile ( "def" ) )
	local sheet = deserialize ( nil, data )

	if sheet then
		sheet:updateStyles ()
	end

	return sheet
end


AssetLibraryModule.registerAssetLoader ( "stylesheet", StyleSheetLoader )

TextStyleModule.TextStyle = TextStyle
TextStyleModule.StyleSheet = StyleSheet

return TextStyleModule