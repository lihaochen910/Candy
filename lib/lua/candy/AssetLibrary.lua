-- import
local SignalModule = require 'candy.signal'

-- module
local AssetLibraryModule = {}

local _assetLogFile = false
local _deprecatedAssets = false
local _assetTagGroups = {}
local _assetMapping = false
local _assetMappingDisabled = false

SignalModule.registerGlobalSignals {
	'asset_library.loaded',
}

--------------------------------------------------------------------
local __AssetCacheMap = {}
local __ASSET_NODE_READONLY = false

local function makeAssetNodeCacheTable ( node )
	local cacheTable = {}
	__AssetCacheMap[ node ] = cacheTable
	return cacheTable
end

function _allowAssetCacheWeakMode ( allowed )
end

local __pendingAssetInvalidate = {}

function flushAssetClear ()
	for a in pairs ( __pendingAssetInvalidate ) do
		a:invalidate ()
	end

	__pendingAssetInvalidate = table.cleared ( __pendingAssetInvalidate )
end

local __ASSET_CACHE_MT = { 
	-- __mode = 'kv'
}

local __ASSET_CACHE_LOCKED_MT = { 	
}

local __ASSET_CACHE_WEAK_MODE = 'kv'

function makeAssetCacheTable ()
	return setmetatable ( {}, __ASSET_CACHE_MT )
end

function _allowAssetCacheWeakMode ( allowed )
	__ASSET_CACHE_WEAK_MODE = allowed and 'v' or false
end

function setAssetCacheWeak ()
	__ASSET_CACHE_MT.__mode = __ASSET_CACHE_WEAK_MODE
end

function setAssetCacheStrong ()
	__ASSET_CACHE_MT.__mode = false
end

--------------------------------------------------------------------
local _retainedAssetTable = {}
function retainAsset ( assetPath ) --keep asset during one collection cycle
	local node = _getAssetNode ( assetPath )
	if not node then return _warn ( 'no asset to hold', assetPath ) end
	_retainedAssetTable[ node ] = true
	setmetatable ( node.cached, __ASSET_CACHE_LOCKED_MT )
end

function releaseRetainAssets ()
	for node in pairs ( _retainedAssetTable ) do
		setmetatable ( node.cached, __ASSET_CACHE_MT )
	end
	_retainedAssetTable = {}
end


local pendingAssetGarbageCollection = false
local _assetCollectionPreGC

function _doAssetCollection ()
	_Stopwatch.start ( "asset_gc" )
	game:startBoostLoading ()
	MOAISim.forceGC ( 1 )
	game:stopBoostLoading ()
	_Stopwatch.stop ( "asset_gc" )
	_log ( _Stopwatch.report ( "asset_gc" ) )
end

function _assetCollectionPreGC ()
	_doAssetCollection ()
	MOAISim.setListener ( MOAISim.EVENT_PRE_GC, nil ) --stop
			-- reportLoadedMoaiTextures()
			-- reportAssetInCache()
			-- reportHistogram()
			-- reportTracingObject()
end

--------------------------------------------------------------------
function collectAssetGarbage ()
	local collectThread = MOAICoroutine.new ()
	collectThread:run ( function ()
		while true do
			if not isAssetThreadTaskBusy () then break end
			coroutine.yield ()
		end

		local async = false--MOAIRenderMgr.isAsync ()
		if async then
			getRenderManager ():addPostSyncRenderCall ( _doAssetCollection )
		else
			MOAISim.setListener ( MOAISim.EVENT_PRE_GC, _assetCollectionPreGC )
		end
	end )
	collectThread:attach ( game:getSceneActionRoot () )
	return collectThread
end


--------------------------------------------------------------------
-- tool functions
--------------------------------------------------------------------
---
-- 替换给定路径中的字符'\\'为'/'
local function fixpath ( p )
	p = string.gsub ( p, '\\', '/' )
	return p
end

local function _splitAssetPath ( path )
	path = fixpath ( path )
	local dir, file = string.match ( path, "(.*)/(.*)" )

	if not dir then
		dir = ""
		file = path
	end

	return dir, file
end

local function stripExt ( p )
	return string.gsub ( p, '%..*$', '' )
end

local function stripDir ( p )
	p = fixpath ( p )
	return string.match ( p, "[^\\/]+$" )
end

--------------------------------------------------------------------
--asset index library
local AssetLibrary = {}
local AssetSearchCache = {}

local function _getAssetNode ( path )
	return AssetLibrary[ path ]
end

--asset loaders
local AssetLoaderConfigs = setmetatable ( {}, { __no_traverse = true } )

--runtime importer
local AssetRuntimeImporterConfigs = setmetatable ( {}, { __no_traverse = true } )

--runtime asset type hinter
local RuntimeAssetTypeHinter = {}

--env
local AssetLibraryIndex = false

--funtion
local loadAssetInternal, tryLoadAsset, forceLoadAsset
local getCachedAsset
local releaseAsset

local function getAssetLibraryIndex ()
	return AssetLibraryIndex
end

local function getAssetLibrary ()
	return AssetLibrary
end

local function loadAssetLibrary ( indexPath, searchPatches )
	if not indexPath then
		_stat ( 'asset library not specified, skip.' )
		return
	end

	local msgpackPath = indexPath .. '.packed'

	local useMsgPack = MOAIFileSystem.checkFileExists ( msgpackPath )

	_stat ( 'loading library from', indexPath )
	_Stopwatch.start ( 'load_asset_library' )
	
	--json assetnode
	local indexData = false
	if useMsgPack then
		print( 'use packed asset table' )
		local fp = io.open ( msgpackPath, 'r' )
		if not fp then 
			_error ( 'can not open asset library index file', msgpackPath )
			return
		end
		local indexString = fp:read ( '*a' )
		fp:close ()
		indexData = MOAIMsgPackParser.decode ( indexString )
	else
		local fp = io.open ( indexPath, 'r' )
		if not fp then 
			_error ( 'can not open asset library index file', indexPath )
			return
		end
		local indexString = fp:read ( '*a' )
		fp:close ()
		indexData = MOAIJsonParser.decode ( indexString )
	end

	if not indexData then
		_error ( 'can not parse asset library index file', indexPath )
		return
	end
	_Stopwatch.stop ( 'load_asset_library' )
	_log ( _Stopwatch.report ( 'load_asset_library' ) )

	_Stopwatch.start ( 'load_asset_library' )
	AssetLibrary = {}
	AssetSearchCache = {}
	local count = 0
	for path, value in pairs ( indexData ) do
		--we don't need all the information from python
		count = count + 1
		AssetLibraryModule.registerAssetNode ( path, value )
	end
	AssetLibraryIndex = indexPath

	if searchPatches then
		--TODO: better asset patch storage
		findAndLoadAssetPatches ( '../asset_index_patch.json' )
		findAndLoadAssetPatches ( 'asset_index_patch.json' )
	end
	emitSignal ( 'asset_library.loaded' )
	_Stopwatch.stop ( 'load_asset_library' )
	_log ( _Stopwatch.report ( 'load_asset_library' ) )
	_log ( 'asset registered', count )
	return true
end

local function _extendDeep ( t0, t1 )
	for k, v1 in pairs( t1 ) do
		local v0 = t0[ k ]
		if v0 == nil then
			t0[ k ] = v1
		end
		if type ( v0 ) == 'table' then
			if type ( v1 ) ~= 'table' then
				return false
			end
			if not _extendDeep ( v0, v1 ) then return false end
		else
			if type ( v1 ) == 'table' then
				return false
			end
			t0[ k ] = v1
		end
	end
	return true
end

local function findAndLoadAssetPatches ( patchPath )
	if MOAIFileSystem.checkFileExists ( patchPath ) then
		local data = loadJSONFile ( patchPath )
		if data then
			_extendDeep ( AssetLibrary, data )
		end
	end
end

--------------------------------------------------------------------
-- Asset Node
--------------------------------------------------------------------
---@class AssetNode
local AssetNode = CLASS: AssetNode ()
	:MODEL { extra_size = 12 }
function AssetNode:__init ()
	self.children = {}
	self.parent = false
	self.holders = false
	self.staticData = false
	self.refcount = 0
end

function AssetNode:__tostring ()
	return string.format ( "%s|%s|%s", self:__repr (), self:getType (), self:getPath () or "???" )
end

function AssetNode:getName ()
	return stripDir ( self.path )
end

function AssetNode:getBaseName ()
	return stripExt ( self:getName () )
end

function AssetNode:getType ()
	return self.type
end

function AssetNode:isVirtual ()
	return not self.filePath
end

function AssetNode:getTagCache ()
	local cache = self.tagCache
	if not self.tagCache then
		cache = {}
		self.tagCache = cache
		local p = self
		while p do
			local tags = p.tags
			if tags then
				for i, t in ipairs ( tags ) do
					cache[ t ] = true
				end
			end
			p = p:getParentNode ()
		end
	end
	return cache
end

function AssetNode:hasTag ( tag )
	local cache = self:getTagCache ()
	return cache and cache[ tag ] or false
end

function AssetNode:getSiblingPath ( name )
	local parent = self.parent
	if parent == '' then return name end
	return self.parent .. '/' .. name
end

function AssetNode:getChildPath ( name )
	return self.path .. '/' .. name
end

function AssetNode:getChildren ()
	return self.children
end

local function _collectAssetOf ( node, targetType, collected, deepSearch )
	collected = collected or {}
	local t = node:getType ()
	if ( not targetType ) or t:match ( targetType ) then
		collected[ node.path ] = node
	end
	if deepSearch then
		for name, child in pairs ( node.children ) do
			_collectAssetOf ( child, targetType, collected, deepSearch )
		end
	end
	return collected
end

function AssetNode:enumChildren ( targetType, deepSearch )
	local collected = {}
	for name, child in pairs ( self.children ) do
		_collectAssetOf ( child, targetType, collected, deepSearch )
	end
	return collected
end

local function _findChildAsset ( node, name, targetType, deep )
	for childName, child in pairs ( node.children ) do
		if childName == name or child:getPath ():endwith ( name ) then
			local t = child:getType ()
			if ( not targetType ) or t:match ( targetType ) then
				return child
			end
		end
		if deep then
			local result = _findChildAsset ( child, name, targetType, deep )
			if result then return result end
		end
	end
end

function AssetNode:findChild ( name, targetType, deep )
	local result = _findChildAsset ( self, name, targetType, deep )
	return result
end

function AssetNode:getObjectFile ( name )
	local objectFiles = self.objectFiles
	if not objectFiles then return false end
	return objectFiles[ name ]
end

function AssetNode:getProperty ( name )
	local properties = self.properties
	return properties and properties[ name ]
end

function AssetNode:getPath ()
	return self.path
end

function AssetNode:getNodePath ()
	return self.path
end

function AssetNode:getFilePath ()
	return self.filePath
end

function AssetNode:getAbsObjectFile ( name )
	local objectFiles = self.objectFiles
	if not objectFiles then return false end
	local path = objectFiles[ name ]
	if path then
		return getProjectPath ( path )
	else
		return false
	end
end

function AssetNode:getDependency ( name )
	local dependency = self.dependency
	if not dependency then return false end
	return dependency[ name ]
end

function AssetNode:getAbsFilePath ()
	return getProjectPath ( self.filePath )
end

function AssetNode:getNonVirtualParentNode ()
	local p = self:getParentNode ()

	while p do
		if not p:isVirtual () then
			return p
		end

		p = p:getParentNode ()
	end

	return nil
end

function AssetNode:getParentNode ()
	if not self.parent then return nil end
	return AssetLibrary[ self.parent ]
end

function AssetNode:enableGC ()
	self.gcDisabled = false
end

function AssetNode:disableGC ()
	self.gcDisabled = true
end

function AssetNode:_affirmCache ()
	local cache = __AssetCacheMap[ self ]
	cache = cache or makeAssetNodeCacheTable ( self )
	return cache
end

function AssetNode:getCacheData ( key )
	local cache = __AssetCacheMap[ self ]
	return cache and cache[ key ]
end

function AssetNode:setCacheData ( key, data )
	local cache = __AssetCacheMap[ self ]
	cache[ key ] = data
end

function AssetNode:getCachedAsset ()
	local cache = __AssetCacheMap[ self ]
	return cache and cache.asset
end

function AssetNode:invalidate ()
	local cache = __AssetCacheMap[ self ]

	if not cache then
		return
	end

	_stat ( "invalidate asset:", self )

	for name, child in pairs ( self.children ) do
		child:invalidate ()
	end

	local atype = self.type
	self.staticData = false
	local assetLoaderConfig = AssetLoaderConfigs[ atype ]
	local unloader = assetLoaderConfig and assetLoaderConfig.unloader

	if unloader then
		local prevCache, prevAsset = nil
		prevCache = table.simplecopy ( cache )
		prevAsset = cache.asset

		table.clear ( cache )
		unloader ( self, prevAsset, cache, prevCache )
	else
		table.clear ( cache )
	end
end

function AssetNode:getCache ()
	return self.cached
end

function AssetNode:setCachedAsset ( data )
	local cache = __AssetCacheMap[ self ]
	cache.asset = data
end

function AssetNode:load ()
	return loadAsset ( self:getNodePath () )
end

function AssetNode:retainFor ( holder )
	if self.gcDisabled then
		return
	end

	if self:isVirtual () then
		local nonVirtualParentNode = self:getNonVirtualParentNode ()
		if nonVirtualParentNode then
			return holder:retainAsset ( nonVirtualParentNode )
		end
	else
		if not self.holders then
			self.holders = {}
		end

		if self.holders[ holder ] then
			return
		end

		self.holders[ holder ] = true
		self.refcount = self.refcount + 1
		__pendingAssetInvalidate[ self ] = nil
	end
end

function AssetNode:releaseFor ( holder )
	if self.gcDisabled then
		return
	end

	local holders = self.holders

	if not holders or not holders[ holder ] then
		return
	end

	holders[ holder ] = nil
	self.refcount = self.refcount - 1

	if self.refcount == 0 then
		__pendingAssetInvalidate[ self ] = true
	end
end

--------------------------------------------------------------------
local newAssetNode = AssetNode.__new
local function _newAssetNode ( path, force )
	local node = newAssetNode ()
	node.path = path or ""
	node.type = ""
	if MOAIFileSystem.checkFileExists ( path ) then
		node.filePath = path
	end
	if not MOAIFileSystem.checkFileExists ( path ) and MOAIFileSystem.checkPathExists ( path ) then
		node.type = "folder"
	end
	AssetLibrary[ path ] = node
	return node
end

---
-- 确认一个路径，如不存在则创建并注册
---@param path
---@return AssetNode
local function _affirmAssetNode ( path, force )
	local node = nil
	node = AssetLibrary[ path ]
	node = node or _newAssetNode ( path )
	return node
end

local function _skipEmptyTable ( a )
	if not a then
		return nil
	end

	if not next ( a ) then
		return nil
	end

	return a
end

local function updateAssetNode ( node, data ) --dynamic attributes
	node.type 			= data.type
	node.properties 	= _skipEmptyTable ( data.properties )
	node.objectFiles	= _skipEmptyTable ( data.objectFiles )
	node.deployMeta 	= _skipEmptyTable ( data.deployMeta )
	node.dependency 	= _skipEmptyTable ( data.dependency )
end

local function registerAssetNode ( path, data )
	local ppath, name = _splitAssetPath ( path )
	if ppath == '' then ppath = false end

	local node = _affirmAssetNode ( path )
	node.type			= data[ 'type' ]
	node.name			= name
	node.parent			= ppath
	node.path			= path
	node.filePath		= data[ 'filePath' ]
	node.parent			= ppath
	node.cached			= makeAssetCacheTable ()
	node.cached.asset 	= data[ 'type' ] == 'folder' and true or false
	node.tags         	= data[ 'tags' ] or false

	updateAssetNode ( node, data )
	AssetLibrary[ path ] = node

	if node.tags then
		local tags = node.tags

		for i = 1, #tags do
			local t = tags[ i ]
			local reg = _assetTagGroups[ t ]

			if reg then
				reg[ path ] = node
			end
		end
	end

	if ppath then
		local pnode = _affirmAssetNode ( ppath )
		node.parentNode = pnode
		pnode.children[ name ] = node
	end
	return node
end

local function unregisterAssetNode ( path )
	local node = AssetLibrary[ path ]
	if not node then return end
	for name, child in pairs ( node.children ) do
		unregisterAssetNode ( child.path )
	end
	releaseAsset ( node )
	local pnode = node.parentNode
	if pnode then
		pnode.children[ node.name ] = nil
	end
	node.parentNode = nil
	AssetLibrary[ path ] = nil
	__AssetCacheMap[ node ] = nil
end

---@return AssetNode
local function getAssetNode ( path )
	return _getAssetNode ( path )
end

local function checkAsset ( path )
	return AssetLibrary[ path ] ~= nil
end

local function matchAssetType ( path, pattern, plain )
	local t = getAssetType ( path )
	if not t then return false end
	if plain then
		return t == pattern and t or false
	else
		return t:match ( pattern ) and t or false
	end
end

local function getAssetType ( path )
	local node = _getAssetNode ( path )
	return node and node:getType ()
end


--------------------------------------------------------------------
--loader: func( assetType, filePath )
local function registerAssetLoader ( assetType, loader, unloader, option )
	assert ( loader )
	option = option or {}
	AssetLoaderConfigs[ assetType ] = {
		loader      = loader,
		unloader    = unloader or false,
		skip_parent = option[ 'skip_parent' ] or false,
		option      = option
	}

	-- _stat ( "register AssetLoader:", assetType )
end

local function CommonAssetNodeRuntimeLoader ( path, option )
	local atype = option[ 'asset_type_hint' ]
	local node = AssetLibraryModule.registerAssetNode ( path, {
			type = atype, 
			objectFiles = {},
			dependency = {}
		}
	)
	return node
end

local function registerRuntimeAssetLoader ( assetType, loader, option )
	assert ( loader )
	option = option or {}
	AssetRuntimeImporterConfigs[ assetType ] = {
		loader = loader,
		option = option
	}

	-- _stat ( "register AssetLoader:", assetType )
end

local function registerRuntimeAssetTypeHinter ( ext, assetType )
	RuntimeAssetTypeHinter[ ext ] = assetType
end

--------------------------------------------------------------------
--put preloaded asset into AssetNode of according path
local function preloadIntoAssetNode ( path, asset )
	local node = _getAssetNode ( path )
	if node then
		node.cached.asset = asset 
		return asset
	end
	return false
end


--------------------------------------------------------------------
local function findAssetNode ( path, assetType )
	local tag = path .. '|' .. ( assetType or '' )
	local result = AssetSearchCache[ tag ]
	if result == nil then
		for k, node in pairs ( AssetLibrary ) do
			local typeMatched = false
			local deprecated = node:hasTag ( 'deprecated' )
			if deprecated then
				typeMatched = false
			else
				if node.path == path then print ( 'hello!' ) end
				if not assetType then
					typeMatched = true
				else
					if string.match ( node:getType (), assetType ) then
						typeMatched = true
					end
				end
			end

			if typeMatched then
				if k == path then
					result = node
					break
				elseif k:endwith ( path ) then
					result = node
					break
				elseif stripExt ( k ):endwith ( path ) then
					result = node
					break
				end
			end
		end
		AssetSearchCache[ tag ] = result or false
	end
	return result or nil
end	

local findAsset
local function affirmAsset ( pattern, assetType )
	local path = findAsset ( pattern, assetType )
	if not path then
		_error ( 'asset not found', pattern, assetType or '<?>' )
	end
	return path
end

local function findAsset ( path, assetType )
	local node = findAssetNode ( path, assetType )
	return node and node.path or nil
end

local function findChildAsset ( parentPath, name, assetType, deep )
	deep = deep ~= false
	local parentNode = getAssetNode ( parentPath )
	if not parentNode then
		_error ( 'no parent asset:', parentPath )
		return
	end
	local node = parentNode:findChild ( name, assetType, deep )
	return node and node.path or nil	
end

local function findAndLoadAsset ( path, assetType )
	local node = findAssetNode ( path, assetType )
	if node then
		return loadAsset ( node.path )
	end
	return nil
end


--------------------------------------------------------------------
-- load asset of node
--------------------------------------------------------------------
local loadingAsset = table.weak_k () --TODO: a loading list avoid cyclic loading?

local function isAssetLoading ( path )
	return loadingAsset[ path ] and true or false
end

local function hasAsset ( path )
	local node = _getAssetNode ( path )
	return node and true or false 
end

local function canPreload ( path ) --TODO:use a generic method for arbitary asset types
	local node = _getAssetNode ( path )
	if not node then return false end
	if node.type == 'scene' then return false end
	if node:hasTag ( "no_preload" ) then return false end
	return true
end

local AdhocAssetMT = {
	__tostring = function ( t )
		return "AdHocAsset:" .. tostring ( t.__traceback )
	end
}
local function AdHocAsset ( object )
	local traceback = debug.traceback ()
	local box = setmetatable ( {
		object,
		__traceback = traceback
	}, AdhocAssetMT )
	return box
end

local function isAdHocAsset ( box )
	local mt = getmetatable ( box )
	return mt == AdhocAssetMT
end

local assetLoadTimers = {}
local assetLoadCounts = {}

function clearAssetLoadTimers ()
	assetLoadTimers = {}
	assetLoadCounts = {}
end

function reportAssetLoadTimers ()
	if checkLogLevel ( "stat" ) then
		_log ( "asset loading time:" )
		for _, k in ipairs ( table.sortedkeys ( assetLoadTimers ) ) do
			printf ( "\t\t%s\t%.2f\t%d", k, assetLoadTimers[ k ] * 1000, assetLoadCounts[ k ] )
		end
	end
end

---
-- 加载资源.
---@param path string The path of the asset.
---@param option (option)加载选项
---@param warning (option)资源不存在时
---@return AssetInstance, node instance
function loadAssetInternal ( path, option, warning, requester, nomapping )
	if isAdHocAsset ( path ) then
		local adhocAsset = path
		return adhocAsset[ 1 ], false
	end
	
	if path == '' then return nil end
	if not path   then return nil end

	if path:startwith ( "$" ) then
		path = findAsset ( path:sub ( 2, -1 ) )
	end

	if not _assetMappingDisabled and _assetMapping and not nomapping then
		local mapped = _assetMapping[ path ]
		if mapped then
			return loadAssetInternal ( mapped, option, warning, requester, true )
		end
	end

	local function printAssetNotFoundWarning ()
		if warning ~= false then
			_warn ( 'no asset found', path or '???', requester )
			_warn ( singletraceback ( 2 ) )
		end
	end

	option = option or {}
	local policy = option.policy or 'auto'
	local node = _getAssetNode ( path )
	local asset, cached = nil
	if not node then
		-- 资源不存在时尝试创建
		if MOAIFileSystem.checkFileExists ( path ) then
			local assetTypeHint = option[ 'asset_type_hint' ]
			if not assetTypeHint then
				assetTypeHint = RuntimeAssetTypeHinter[ string.lower ( fileext ( path ) ) ]
			end
			local runtimeLoaderConfig = AssetRuntimeImporterConfigs[ assetTypeHint ]
			if runtimeLoaderConfig then
				local runtimeLoader = runtimeLoaderConfig.loader
				node = runtimeLoader ( path, option )
				if not node then
					printAssetNotFoundWarning ()
					return nil
				-- else
				-- 	_stat ( 'runtime importing asset from:', path )
				end
			else
				printAssetNotFoundWarning ()
				return nil
			end
		elseif MOAIFileSystem.checkPathExists ( path ) then
			local runtimeLoaderConfig = AssetRuntimeImporterConfigs[ assetTypeHint ]
			if runtimeLoaderConfig then
				local runtimeLoader = runtimeLoaderConfig.loader
				node = runtimeLoader ( path, option )
				if not node then
					printAssetNotFoundWarning ()
					return nil
				end
			else
				printAssetNotFoundWarning ()
				return nil
			end
		else
			printAssetNotFoundWarning ()
			return nil
		end
	end

	if policy ~= 'force' then
		local asset = node:getCachedAsset ()
		if asset then
			_stat ( 'get asset from cache:', path, node )
			return asset, node
		end
	end

	_stat ( 'loading asset from:', path )
	if policy ~= 'auto' and policy ~='force' then return nil end
	
	-- 从注册的loader中查找对应nodetype的
	local atype = node.type

	if atype == "folder" then
		node:_affirmCache ().asset = true
		return true, node
	end

	local loaderConfig = AssetLoaderConfigs[ atype ]
	if not loaderConfig then
		if warning ~= false then
			_warn ( 'no loader config for asset', atype, path )
			print ( "current AssetLoaderConfigs:" )
			print ( inspect ( AssetLoaderConfigs, { depth = 1 } ) )
		end
		return false
	end

	local t0 = os.clock ()
	
	if node.parent and ( not loaderConfig.skip_parent or option[ 'skip_parent' ] ) then
		if not loadingAsset[ node.parent ] then
			loadAssetInternal ( node.parent, option )
		end
		local cachedAsset = node:getCachedAsset ()
		if cachedAsset then 
			return cachedAsset, node
		end --already preloaded		
	end

	--load from file
	local loader = loaderConfig.loader
	if not loader then
		_warn ( 'no loader for asset:', atype, path )
		return false
	end
	loadingAsset[ path ] = true
	node:_affirmCache ()
	asset, cached = loader ( node, option )
	loadingAsset[ path ] = nil

	local loadDuration = os.clock () - t0
	assetLoadTimers[ atype ] = ( assetLoadTimers[ atype ] or 0 ) + loadDuration
	assetLoadCounts[ atype ] = ( assetLoadCounts[ atype ] or 0 ) + 1
	_statf ( "loaded: %s  (%.1fms)", path, loadDuration * 1000 )

	if asset then
		if cached ~= false then
			node:setCachedAsset ( asset )
		end
		return asset, node
	else
		_stat ( 'failed to load asset:', path )
		return nil
	end
end

function tryLoadAsset ( path, option ) --no warning
	return loadAsset ( path, option, false )
end

function forceLoadAsset ( path ) --no cache
	return loadAsset ( path, { policy = 'force' } )
end

function getCachedAsset ( path )
	if path == '' then return nil end
	if not path   then return nil end
	local node   = _getAssetNode ( path )
	if not node then 
		_warn ( 'no asset found', path or '???' )
		return nil
	end
	return node.cached.asset
end


--------------------------------------------------------------------
function releaseAsset ( asset )
	--local node = _getAssetNode ( path )
	--if node then
	--	local cached = node.cached
	--	local atype  = node.type
	--	local assetLoaderConfig =  AssetLoaderConfigs[ atype ]
	--	local unloader = assetLoaderConfig and assetLoaderConfig.unloader
	--	local newCacheTable = makeAssetCacheTable ()
	--	if unloader then
	--		unloader ( node, cached and cached.asset, newCacheTable )
	--	end
	--	node.cached = newCacheTable
	--	_stat ( 'released node asset', path, node )
	--end
	local node = nil

	if type ( asset ) == "string" then
		node = _getAssetNode ( asset )
		if not node then
			_warn ( "no asset found", asset )
			return false
		end
	elseif isInstance ( asset, AssetNode ) then
		node = asset
	end

	if node then
		node:invalidate ()
		_stat ( "released node asset", node )
	end

	return true
end


--------------------------------------------------------------------
local function reportAssetInCache ( typeFilter )
	local output = {}
	if type ( typeFilter ) == 'string' then
		typeFilter = { typeFilter }
	elseif type ( typeFilter ) == 'table' then
		typeFilter = typeFilter
	else
		typeFilter = false
	end
	for path, node in pairs ( AssetLibrary ) do
		local atype = node:getType ()
		if atype ~= 'folder' and node.cached.asset then
			local matched
			if typeFilter then
				matched = false
				for i, t in ipairs ( typeFilter ) do
					if t == atype then
						matched = true
						break
					end
				end
			else
				matched = true
			end
			if matched then
				table.insert ( output, { path, atype, node.cached.asset } )
			end
		end
	end
	local function _sortFunc ( i1, i2 )
		if i1[ 2 ] == i2[ 2 ] then
			return i1[ 1 ] < i2[ 1 ]
		else
			return i1[ 2 ] < i2[ 2 ]
		end
	end
	table.sort ( output, _sortFunc )
	for i, item in ipairs ( output ) do
		printf ( '%s \t %s', item[ 2 ], item[ 1 ]  )
	end
end

--------------------------------------------------------------------
local function loadAssetFolder ( path )
	local node = _getAssetNode ( path )
	if not ( node and node:getAssetType () == 'folder' ) then 
		return _warn ( 'folder path expected:', path )
	end
end

local function isAssetThreadTaskBusy ()
	return isTextureThreadTaskBusy () --TODO: other thread?
end

--------------------------------------------------------------------
-- _C.registerAssetNode = registerAssetNode
-- _C.updateAssetNode = updateAssetNode

AssetLibraryModule.getAssetLibraryIndex 		= getAssetLibraryIndex
AssetLibraryModule.getAssetLibrary 				= getAssetLibrary
AssetLibraryModule.loadAssetLibrary 			= loadAssetLibrary
AssetLibraryModule.AssetNode 					= AssetNode
AssetLibraryModule.isAssetLoading 				= isAssetLoading
AssetLibraryModule.hasAsset 					= hasAsset
AssetLibraryModule.canPreload 					= canPreload
AssetLibraryModule.AdHocAsset 					= AdHocAsset
AssetLibraryModule.isAdHocAsset 				= isAdHocAsset
AssetLibraryModule.loadAssetInternal 			= loadAssetInternal
AssetLibraryModule.tryLoadAsset 				= tryLoadAsset
AssetLibraryModule.forceLoadAsset 				= forceLoadAsset
AssetLibraryModule.getCachedAsset 				= getCachedAsset
AssetLibraryModule.updateAssetNode				= updateAssetNode
AssetLibraryModule.registerAssetNode 			= registerAssetNode
AssetLibraryModule.unregisterAssetNode 			= unregisterAssetNode
AssetLibraryModule.getAssetNode 				= getAssetNode
AssetLibraryModule.checkAsset 					= checkAsset
AssetLibraryModule.matchAssetType 				= matchAssetType
AssetLibraryModule.getAssetType 				= getAssetType
AssetLibraryModule.registerAssetLoader 			= registerAssetLoader
AssetLibraryModule.registerRuntimeAssetLoader 	= registerRuntimeAssetLoader
AssetLibraryModule.CommonAssetNodeRuntimeLoader = CommonAssetNodeRuntimeLoader
AssetLibraryModule.registerRuntimeAssetTypeHinter = registerRuntimeAssetTypeHinter
AssetLibraryModule.preloadIntoAssetNode 		= preloadIntoAssetNode
AssetLibraryModule.findAssetNode 				= findAssetNode
AssetLibraryModule.affirmAsset 					= affirmAsset
AssetLibraryModule.findAsset 					= findAsset
AssetLibraryModule.findChildAsset 				= findChildAsset
AssetLibraryModule.findAndLoadAsset 			= findAndLoadAsset
AssetLibraryModule.reportAssetInCache 			= reportAssetInCache
AssetLibraryModule.loadAssetFolder 				= loadAssetFolder
AssetLibraryModule.isAssetThreadTaskBusy 		= isAssetThreadTaskBusy
AssetLibraryModule.releaseAsset 				= releaseAsset


return AssetLibraryModule