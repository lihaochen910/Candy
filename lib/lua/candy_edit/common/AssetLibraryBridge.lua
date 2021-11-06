--------------------------------------------------------------------
-- Asset Sync
--------------------------------------------------------------------
function _pyAssetNodeToData ( node )
	return {
        deploy      = node.deployState == true,
        filePath    = node.filePath,
        type        = node.assetType,
        objectFiles = candy_editor.dictToTable ( node.objectFiles ),
        properties  = candy_editor.dictToTable ( node.properties ),
        dependency  = candy_editor.dictToTable ( node.dependency ),
        fileTime    = node.fileTime
    }
end

local function onAssetModified ( node ) --node: <py>AssetNode	
	local nodepath = node:getPath ()
	candy.releaseAsset ( nodepath )
	local candyNode = candy.getAssetNode ( nodepath )
	if candyNode then
		local data = _pyAssetNodeToData ( node )
		candy.updateAssetNode ( candyNode, data )
	end
	if candyNode then
		candy.emitSignal ( 'asset.modified', candyNode )
	end
end

local function onAssetRegister ( node )
	local nodePath = node:getPath ()
	local data = _pyAssetNodeToData ( node )
	candy.registerAssetNode ( nodePath, data )
	-- _stat ( "onEditorAssetRegister", nodePath, data )
end

local function onAssetUnregister ( node )
	local nodePath = node:getPath ()
	candy.unregisterAssetNode ( nodePath )
	-- _stat ( "onEditorAssetUnregister", nodePath )
end

candy_editor.connectPythonSignal ( 'asset.modified',   onAssetModified )
candy_editor.connectPythonSignal ( 'asset.register',   onAssetRegister )
candy_editor.connectPythonSignal ( 'asset.unregister', onAssetUnregister )
