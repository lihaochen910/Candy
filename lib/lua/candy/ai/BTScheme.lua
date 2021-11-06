-- import
local AssetLibraryModule = require 'candy.AssetLibrary'
local BTControllerModule = require 'candy.ai.BTController'
local BehaviorTree = BTControllerModule.BehaviorTree

local function BTSchemeLoader ( node )
	local path = node:getObjectFile ( "def" )
	local data = dofile ( path )
	local tree = BehaviorTree ()
	tree:load ( data )
	return tree
end

AssetLibraryModule.registerAssetLoader ( "bt_scheme", BTSchemeLoader )