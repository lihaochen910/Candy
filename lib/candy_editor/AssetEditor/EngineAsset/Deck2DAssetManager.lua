---@class Deck2DAssetManager : AssetManager
local Deck2DAssetManager = CLASS: Deck2DAssetManager ( AssetManager )
function Deck2DAssetManager:getName ()
	return 'asset_manager.deck2d'
end

function Deck2DAssetManager:acceptAssetFile ( filePath )
	if not checkFileExt ( filePath, '.deck2d' ) then return false end
	if not checkSerializationFile ( filePath, 'candy.Deck2DPack' ) then return false end
	return true
end

function Deck2DAssetManager:editAsset ( path )
	editor = candy_editor.app:getModule ( 'deck2d_editor' )
	if editor then
	end
end
