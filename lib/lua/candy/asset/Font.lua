-- import
local AssetLibraryModule = require 'candy.AssetLibrary'

--------------------------------------------------------------------
-- CharCodes
--------------------------------------------------------------------
local charCodes = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,:.?!{}()<>+_="

--------------------------------------------------------------------
-- Font
--------------------------------------------------------------------
local function loadFont ( node )
	local font  = MOAIFont.new ()
	local atype = node.type
	--TODO: support serialized font
	local attributes = node.attributes or {}
	if attributes[ 'serialized' ] then
		local sdataPath   = node.objectFiles['data']
		local texturePath = node.objectFiles['texture']
		font = dofile ( sdataPath )
		-- load the font image back in
		local image = MOAIImage.new ()
		image:load ( texturePath, 0 )
		-- set the font image
		font:setCache ()
		font:setReader ()
		font:setImage ( image )
	end

	if atype == 'font_bmfont' then
		local texPaths = {}
		local dependency = node.dependency or {}
		for k, v in pairs ( dependency ) do
			if k:sub ( 1, 3 ) == 'tex' then
				local id = tonumber ( k:sub ( 5, -1 ) )
				texPaths[ id ] = v
			end
		end
		local textures = {}
		for i, path in ipairs ( texPaths ) do
			local tex, node = loadAsset ( path )
			if not tex then 
				_error ( 'failed load font texture' ) 
				return getFontPlaceHolder ()
			end
			table.insert ( textures, tex:getMoaiTexture () )
		end
		if #textures > 0 then
			font:loadFromBMFont ( node.objectFiles[ 'font' ], textures )
		else
			-- _warn ( 'bmfont texture not load', node:getNodePath () )
			font:load ( node:getNodePath () )
		end
	elseif atype == 'font_ttf' then
		local filename = node.objectFiles[ 'font' ]
		font:getReader ():enableAntiAliasing ( true )
		font:getCache ():setColorFormat ( MOAIImage.COLOR_FMT_RGBA_8888 )
		font:load ( filename, 0 )
	elseif atype == 'font_bdf' then
		font:load ( node.objectFiles[ 'font' ] )
	else
		_error ( 'failed to load font:', node.path )
		return getFontPlaceHolder ()
	end

	local dpi           = 72
	local size          = attributes[ 'size' ] or 20
	local preloadGlyphs = attributes[ 'preloadGlyphs' ]

	if preloadGlyphs then font:preloadGlyphs ( preloadGlyphs, size ) end
	font.size = size

	return font
end

local function runtimeTTFFontLoader ( path, option )
	local node = AssetLibraryModule.registerAssetNode ( path, {
			type = 'font_ttf',
			filePath = path,
			objectFiles = { 
				font = path 
			}
		}
	)
	return node
end

local function runtimeBMFontLoader ( path, option )
	local node = AssetLibraryModule.registerAssetNode ( path, {
			type = 'font_bmfont',
			filePath = path,
			objectFiles = { 
				font = path 
			},
			dependency = {}
		}
	)
	return node
end

--------------------------------------------------------------------
-- Loaders
--------------------------------------------------------------------
AssetLibraryModule.registerAssetLoader ( 'font_ttf',    loadFont )
AssetLibraryModule.registerAssetLoader ( 'font_bdf',    loadFont )
AssetLibraryModule.registerAssetLoader ( 'font_bmfont', loadFont )

AssetLibraryModule.registerRuntimeAssetLoader ( 'font_ttf', runtimeTTFFontLoader )
AssetLibraryModule.registerRuntimeAssetLoader ( 'font_bmfont', runtimeBMFontLoader )
AssetLibraryModule.registerRuntimeAssetTypeHinter ( 'ttf', 'font_ttf' )
AssetLibraryModule.registerRuntimeAssetTypeHinter ( 'fnt', 'font_bmfont' )
AssetLibraryModule.registerRuntimeAssetTypeHinter ( 'bdf', 'font_bdf' )

--preload font placeholder
-- getFontPlaceHolder ()

return { loadFont = loadFont }