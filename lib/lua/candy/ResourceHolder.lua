-- import
local AssetLibraryModule = require 'candy.AssetLibrary'

-- module
local ResourceHolderModule = {}

local loadAssetInternal = AssetLibraryModule.loadAssetInternal
local _inStaticHolder = false
local _defaultResourceHolder, _globalResourceHolder, _overrideResourceHolder = nil
local _overrideResourceHolderStack = {}
local tinsert = table.insert
local tremove = table.remove

--------------------------------------------------------------------
function setDefaultResourceHolder ( holder )
	_defaultResourceHolder = holder
end

function pushResourceHolder ( holder )
	_overrideResourceHolder = holder
	table.insert ( _overrideResourceHolderStack, 1, holder )
end

function popResourceHolder ( holder )
	assert( _overrideResourceHolder == holder )
	table.remove ( _overrideResourceHolderStack, 1 )
	_overrideResourceHolder = _overrideResourceHolderStack[ 1 ]
end

function getGlobalResourceHolder ()
	return _globalResourceHolder
end

function releaseGlobalResourceHolder ()
	return _globalResourceHolder:releaseAllAssets ()
end

--------------------------------------------------------------------
-- ResourceHolder
--------------------------------------------------------------------
---@class ResourceHolder
local ResourceHolder = CLASS: ResourceHolder ()
	:MODEL {}

function ResourceHolder:__init ()
	self.name = false
	self.retainedAssets = {}
	self.weakReleasings = {}
end

function ResourceHolder:__tostring ()
	return string.format ( "%s(%s)", self:__repr (), tostring ( self.name ) )
end

function ResourceHolder:push ()
	pushResourceHolder ( self )
end

function ResourceHolder:pop ()
	popResourceHolder ( self )
end

function ResourceHolder:setName ( name )
	self.name = name
end

function ResourceHolder:retainAsset ( assetNode )
	assetNode:retainFor ( self )
	self.retainedAssets[ assetNode ] = true
	self.weakReleasings[ assetNode ] = nil
end

function ResourceHolder:releaseAllAssets ()
	for node in pairs ( self.retainedAssets ) do
		node:releaseFor ( self )
	end

	self.retainedAssets = {}
	self.weakReleasings = {}
end

function ResourceHolder:weakReleaseAllAssets ()
	local weakReleasings = self.weakReleasings

	for node in pairs ( self.retainedAssets ) do
		weakReleasings [ node ] = true
	end

	self.retainedAssets = {}
end

function ResourceHolder:flushWeakRelease ()
	for node in pairs ( self.weakReleasings ) do
		node:releaseFor ( self )
	end

	self.weakReleasings = {}
end

function ResourceHolder:loadAsset ( path, option )
	local asset, node = loadAssetInternal ( path, option )

	if node then
		self:retainAsset ( node )
	end

	return asset, node
end

--------------------------------------------------------------------
_globalResourceHolder = ResourceHolder ()
_globalResourceHolder.name = "_global"
_staticResourceHolder = ResourceHolder ()
_staticResourceHolder.name = "_static"

--------------------------------------------------------------------
function loadAndHoldAsset ( holder, path, option )
	holder = (not _inStaticHolder or _staticResourceHolder) and (holder or _overrideResourceHolder or _defaultResourceHolder or _globalResourceHolder)
	return holder:loadAsset ( path, option )
end

function loadAsset ( path, option )
	local holder = nil
	holder = (not _inStaticHolder or _staticResourceHolder) and (_overrideResourceHolder or _defaultResourceHolder or _globalResourceHolder)
	return holder:loadAsset ( path, option )
end

function loadStaticAsset ( path )
	_inStaticHolder = true
	local result = _staticResourceHolder:loadAsset ( path )
	_inStaticHolder = false
	return result
end

--------------------------------------------------------------------
--- hack in
AssetLibraryModule.loadAndHoldAsset = loadAndHoldAsset
AssetLibraryModule.loadAsset = loadAsset
AssetLibraryModule.loadStaticAsset = loadStaticAsset

ResourceHolderModule.setDefaultResourceHolder = setDefaultResourceHolder
ResourceHolderModule.pushResourceHolder = pushResourceHolder
ResourceHolderModule.popResourceHolder = popResourceHolder
ResourceHolderModule.getGlobalResourceHolder = getGlobalResourceHolder
ResourceHolderModule.releaseGlobalResourceHolder = releaseGlobalResourceHolder
ResourceHolderModule.ResourceHolder = ResourceHolder
ResourceHolderModule.loadAndHoldAsset = loadAndHoldAsset
ResourceHolderModule.loadAsset = loadAsset
ResourceHolderModule.loadStaticAsset = loadStaticAsset

return ResourceHolderModule