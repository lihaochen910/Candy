local AssetLibraryModule = require 'candy.AssetLibrary'

local function JSONDataLoader ( node )
	local path = node:getObjectFile ( "data" )
	local metaPath = node:getObjectFile ( "meta_data" )
	local data = loadJSONFile ( path, true )

	if metaPath then
		local metaData = loadJSONFile ( metaPath, true )
		node:setCacheData ( "meta", metaData )
	end

	return data
end

function findDataSheetRow ( dataSheet, idFieldName, id )
	for i, row in pairs ( dataSheet ) do
		if row[ idFieldName ] == id then
			return row
		end
	end

	return nil
end

function findDataSheetValue ( dataSheet, idFieldName, id, valueField )
	local row = findDataSheetRow ( dataSheet, idFieldName, id )

	if not row then
		return nil
	end

	return row[ valueField ]
end

AssetLibraryModule.registerAssetLoader ( "data_json", JSONDataLoader )
AssetLibraryModule.registerAssetLoader ( "data_yaml", JSONDataLoader )
AssetLibraryModule.registerAssetLoader ( "data_csv", JSONDataLoader )

return {
	findDataSheetRow = findDataSheetRow,
	findDataSheetValue = findDataSheetValue
}