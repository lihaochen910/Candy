-- import
local AssetLibraryModule = require 'candy.AssetLibrary'
-- local AssetLibraryModule = rawget ( package.loaded, 'candy.Assetlibrary' )
-- print ( "---------- Summary ----------" )
-- print ( inspect ( package.loaded, { depth = 1 } ) )
-- print ( "package", package.loaded[ 'candy.AssetLibrary' ] )
-- print ( AssetLibraryModule )

-- module
local BasicAssetModule = {}

function loadAssetDataTable ( filename ) --lua or json?
	-- _stat ( 'loading json data table', filename )
	if not filename then return nil end
	local f = io.open ( filename, 'r' )
	if not f then
		error ( 'data file not found:' .. tostring ( filename ), 2  )
	end
	local text = f:read ( '*a' )
	f:close ()
	local data =  MOAIJsonParser.decode ( text )
	if not data then _error ( 'json file not parsed: '..filename ) end
	return data
end

function loadTextData ( filename )
	local fp = io.open ( filename, 'r' )
	local text = fp:read ( '*a' )
	return text
end

function saveTextData ( txt, filename )
	local fp = io.open ( filename, 'w' )
	fp:write ( txt )
	fp:close ()
end

---------------------basic loaders
local basicLoaders = {}
function basicLoaders.text ( node )
	return loadTextData ( node.filePath )
end

----------REGISTER the loaders
for assetType, loader in pairs ( basicLoaders ) do
	AssetLibraryModule.registerAssetLoader ( assetType, loader )
	AssetLibraryModule.registerRuntimeAssetLoader ( assetType, AssetLibraryModule.CommonAssetNodeRuntimeLoader )
end

BasicAssetModule.loadAssetDataTable = loadAssetDataTable
BasicAssetModule.loadTextData = loadTextData
BasicAssetModule.saveTextData = saveTextData

return BasicAssetModule