-- import
local AssetLibraryModule = require 'candy.AssetLibrary'
local Deck2DModule = require 'candy.asset.Deck2D'
local UIWidgetModule = require 'candy.ui.light.UIWidget'
local UIWidgetBase = UIWidgetModule.UIWidgetBase
local UIWidget = UIWidgetModule.UIWidget

-- module
local UIStyleModule = {}

local UIStyleRawItem

local insert = table.insert
local remove = table.remove
local find = string.find
local match = string.match
local endwith = string.endwith

local function _compareStyleItemEntry ( a, b )
	local qa = a[ 2 ]
	local qb = b[ 2 ]
	local na = qa.name
	local nb = qb.name

	if na ~= nb then
		local ma = match ( nb, qa.finalPattern )
		local mb = match ( na, qb.finalPattern )

		if ma ~= mb then
			if ma then
				return true
			end

			if mb then
				return false
			end
		end

		local as = qa.state
		local bs = qb.state

		if bs and not as then
			return true
		end

		if as and not bs then
			return false
		end
	end

	return a[ 1 ] < b[ 1 ]
end

local _UIStyleLoaderEnv = {
	rgb = function  ( r, g, b )
		return {
			 ( r or 255 ) / 255,
			 ( g or 255 ) / 255,
			 ( b or 255 ) / 255
		}
	end,
	rgba = function  ( r, g, b, a )
		return {
			 ( r or 255 ) / 255,
			 ( g or 255 ) / 255,
			 ( b or 255 ) / 255,
			 ( a or 255 ) / 255
		}
	end,
	rgbf = function  ( r, g, b )
		return { r or 1, g or 1, b or 1, 1 }
	end,
	rgbaf = function  ( r, g, b, a )
		return { r or 1, g or 1, b or 1, a or 1 }
	end
}

local function _loadUIStyleSheetSource ( src, assetFinder )
	local items = {}
	local imports = {}
	local assets = {}
	local currentNamespace = ""

	local function importFunc ( n )
		insert ( imports, n )
	end

	local function namespaceFunc ( n )
		currentNamespace = type ( n ) == "string" and n or ""
		currentNamespace = currentNamespace:trim () .. " "
	end

	local function styleFunc ( ... )
		local styleItem = UIStyleRawItem ()
		styleItem:setNamespace ( currentNamespace )
		styleItem:parseTarget ( ... )
		table.insert ( items, styleItem )

		local styleUpdater = nil

		function styleUpdater ( data )
			local tt = type ( data )
			if tt == "table" then
				styleItem:load ( data )
			elseif tt == "string" then
				styleItem:parseTarget ( data )
				return styleUpdater
			else
				error ( "invalid style data", 2 )
			end
		end

		return styleUpdater
	end

	local function assetFunc ( name, assetTarget, assetOption )
		local assetData = {
			tag = "asset",
			name = name,
			target = assetTarget or false,
			option = assetOption or false
		}
		insert ( assets, assetData )
		return assetData
	end

	local function localizedFunc ( data )
		return {
			tag = "localized",
			data = data
		}
	end

	local function localeFunc ( name )
		assert ( type ( name ) == "string" )

		return function  ( body )
			assert ( type ( body ) == "table" )

			local localeData = {
				locale = name,
				tag = "locale",
				body = body
			}

			return localeData
		end
	end

	local function imageFunc ( name, mode )
		mode = mode or "normal"
		return assetFunc ( name, "image", mode )
	end

	local function image9Func ( name, stretchOption )
		return assetFunc ( name, "image9", stretchOption )
	end

	local function image3HFunc ( name, stretchOption )
		return assetFunc ( name, "image3h", stretchOption )
	end

	local function image3VFunc ( name, stretchOption )
		return assetFunc ( name, "image3v", stretchOption )
	end

	local function scriptFunc ( src )
		local scriptData = {
			tag = "script",
			source = src
		}
		return scriptData
	end

	local env = {
		import = importFunc,
		style = styleFunc,
		locale = localeFunc,
		localized = localizedFunc,
		namespace = namespaceFunc,
		asset = assetFunc,
		image = imageFunc,
		image9 = image9Func,
		image3h = image3HFunc,
		image3v = image3VFunc
	}

	setmetatable ( env, { __index = _UIStyleLoaderEnv } )

	local func, err = loadstring ( src )

	if not func then
		_warn ( "failed loading style sheet script" )
		print ( err )
		return false
	end

	setfenv ( func, env )

	local ok, err = pcall ( func )

	if not ok then
		_warn ( "failed evaluating style sheet script" )
		print ( err )
		return false
	end

	return items, imports, assets
end

--------------------------------------------------------------------
-- UIStyleSheet
--------------------------------------------------------------------
---@class UIStyleSheet
local UIStyleSheet = CLASS: UIStyleSheet ()
	:MODEL {}

function UIStyleSheet:__init ()
	self.assetPath = false
	self.maxPathSize = 0
	self.items = {}
	self.localCache = {}
	self.globalCache = {}
	self.importedSheets = {}
end

function UIStyleSheet:findAsset ( name )
	if AssetLibraryModule.hasAsset ( name ) then
		return name
	end

	if self.assetPath then
		local basePath = dirname ( self.assetPath )
		local siblingPath = basePath .. "/" .. name

		if AssetLibraryModule.hasAsset ( siblingPath ) then
			return siblingPath
		end

		for i, sheet in ipairs ( self.importedSheets ) do
			local found = sheet:findAsset ( name )
			if found then
				return found
			end
		end
	end

	return false
end

function _sovleImageTarget ( asset, target )
end

local function initDeck2D ( deck, texturePath )
	deck:setTexture ( texturePath )
	local dw, dh = deck:getSize ()
	deck:setOrigin ( dw / 2, dh / 2 )
	deck:update ()
end

local adhocAssetTiledQuadCache = table.weak ()
local function affirmAdhocTiledQuad ( texturePath )
	local a = adhocAssetTiledQuadCache[ texturePath ]

	if not a then
		local deck = Deck2DModule.TiledQuad2D ()
		initDeck2D ( deck, texturePath )
		a = AssetLibraryModule.AdHocAsset ( deck )
		adhocAssetTiledQuadCache[ texturePath ] = a
	end

	return a
end

local adhocAssetQuadCache = table.weak ()
local function affirmAdhocQuad ( texturePath )
	local a = adhocAssetQuadCache[ texturePath ]

	if not a then
		local deck = Deck2DModule.Quad2D ()
		initDeck2D ( deck, texturePath )
		a = AssetLibraryModule.AdHocAsset ( deck )
		adhocAssetQuadCache[ texturePath ] = a
	end

	return a
end

local adhocAssetStretchPatchCache = table.weak ()
local function affirmAdhocStretchPatch ( texturePath, rx, ry, sx, sy )
	local key = string.format ( "%s_%d%d%d%d", texturePath, rx and 1 or 0, ry and 1 or 0, sx and 1 or 0, sy and 1 or 0 )
	local a = adhocAssetQuadCache[ key ]

	if not a then
		local deck = Deck2DModule.StretchPatch ()
		deck.repeatX = rx
		deck.repeatY = ry
		deck.splitX = sx
		deck.splitY = sy
		initDeck2D ( deck, texturePath )

		a = AssetLibraryModule.AdHocAsset ( deck )
		adhocAssetQuadCache[ key ] = a
	end

	return a
end

function UIStyleSheet:solveAssetData ( data )
	local name = data.name
	local target = data.target
	local option = data.option
	local assetPath = self:findAsset ( name )

	if not assetPath then
		data.asset = false
		return false
	end

	if target == "image" then
		if AssetLibraryModule.matchAssetType ( assetPath, "texture" ) then
			if option == "repeat_x" then
				data.asset = affirmAdhocTiledQuad ( assetPath, true, false )
			elseif option == "repeat_y" then
				data.asset = affirmAdhocTiledQuad ( assetPath, false, true )
			elseif option == "repeat_xy" then
				data.asset = affirmAdhocTiledQuad ( assetPath, true, true )
			else
				data.asset = affirmAdhocQuad ( assetPath )
			end
		end
	elseif target == "image9" or target == "image3v" or target == "image3h" then
		if AssetLibraryModule.matchAssetType ( assetPath, "texture" ) then
			local repeatX, repeatY, splitX, splitY = nil

			if option == "repeat_x" then
				repeatX = true
				repeatY = false
			elseif option == "repeat_y" then
				repeatX = false
				repeatY = true
			elseif option == "repeat_xy" then
				repeatX = true
				repeatY = true
			else
				repeatX = false
				repeatY = false
			end

			if target == "image3h" then
				splitX = true
				splitY = false
			elseif target == "image3v" then
				splitX = false
				splitY = true
			else
				splitX = true
				splitY = true
			end

			data.asset = affirmAdhocStretchPatch ( assetPath, repeatX, repeatY, splitX, splitY )
		end
	else
		data.asset = assetPath
	end

	return true
end

function UIStyleSheet:load ( src )
	local idx = 0
	local noTag = {}
	local taggedList = {}
	local maxPathSize = 0

	local function _addItem ( item )
		item._index = idx
		idx = idx + 1

		for i, q in ipairs ( item.qualifiers ) do
			local tag = q.tag or false
			local list = nil

			if tag then
				list = taggedList[ tag ]
				if not list then
					list = {}
					taggedList[ tag ] = list
				end
			else
				list = noTag
			end

			local entry = { idx, q, item.data, item._globalIndex }
			insert ( list, entry )
		end
	end

	local function _findAsset ( ... )
	end

	_Stopwatch.start ( "ui_style_load_source" )

	local items, imports, assets = _loadUIStyleSheetSource ( src, _findAsset )

	if not items then
		self.items = {}
		return false
	end

	for i, item in ipairs ( getBaseStyleSheet ().items ) do
		_addItem ( item )
	end

	_Stopwatch.stop ( "ui_style_load_source" )
	_Stopwatch.start ( "ui_style_load_imports" )

	maxPathSize = getBaseStyleSheet ().maxPathSize
	local loaded = {}
	local importedSheets = {}

	for i, import in pairs ( imports ) do
		local path = self:findImport ( import )

		if path then
			if isAssetLoading ( path ) then
				_error ( "cyclic stylesheet imports detected", path )
				return false
			end
		else
			_error ( "cannot find stylesheet to import:", import )
			return false
		end

		if not loaded[path] then
			local sheet = candy.loadAsset ( path )
			if not sheet then
				_error ( "cannot import stylesheet", import, path )
				return false
			end

			loaded[ path ] = true
			importedSheets[ i ] = sheet
			maxPathSize = math.max ( maxPathSize, sheet.maxPathSize )

			for i, item in ipairs ( sheet.items ) do
				_addItem ( item )
			end
		end
	end

	_Stopwatch.stop ( "ui_style_load_imports" )

	for i, item in ipairs ( items ) do
		maxPathSize = math.max ( maxPathSize, item.pathSize )
		_addItem ( item )
	end

	_Stopwatch.start ( "ui_style_load_assets" )

	for i, assetData in ipairs ( assets ) do
		self:solveAssetData ( assetData )
	end

	_Stopwatch.stop ( "ui_style_load_assets" )
	_Stopwatch.start ( "ui_style_build_tags" )
	table.sort ( noTag, _compareStyleItemEntry )

	for t, list in pairs ( taggedList ) do
		table.sort ( list, _compareStyleItemEntry )
	end

	for t, list in pairs ( taggedList ) do
		for _, entryNoTag in ipairs ( noTag ) do
			local pattern = entryNoTag[2].finalPattern
			local inserted = false

			for i, entry0 in ipairs ( list ) do
				if endwith ( entry0[2].finalPattern, pattern ) then
					insert ( list, i, entryNoTag )
					inserted = true
					break
				end
			end

			if not inserted then
				insert ( list, entryNoTag )
			end
		end
	end

	local finalTaggedList = {}

	for t, list0 in pairs ( taggedList ) do
		local clas = findClass ( t )

		if isSubclass ( clas, UIWidget ) then
			local l = { list0 }
			finalTaggedList[ t ] = l
			clas = clas.__super

			while clas do
				if clas == UIWidgetBase then
					break
				end

				local list1 = taggedList[ clas.__name ]
				if list1 then
					table.insert ( l, 1, list1 )
				end

				clas = clas.__super
			end
		end
	end

	self.finalTaggedList = finalTaggedList

	_Stopwatch.stop ( "ui_style_build_tags" )

	self.maxPathSize = maxPathSize
	self.items = items
	self.importedSheets = importedSheets

	_log ( "loading", self.assetPath )
	_log ( _Stopwatch.report ( "ui_style_load_assets", "ui_style_sort_tags", "ui_style_build_tags" ) )

	return true
end

function UIStyleSheet:findImport ( name )
	if self.assetPath then
		local path = dirname ( self.assetPath ) .. "/" .. name
		local node = AssetLibraryModule.getAssetNode ( path )

		if not node then
			path = path .. ".ui_style"
			node = AssetLibraryModule.getAssetNode ( path )
		end

		if node then
			return node:getPath ()
		end
	end

	local path = AssetLibraryModule.findAsset ( name, "ui_style" )
	if not path then
		return false
	end
	return path
end

function UIStyleSheet:loadFromAsset ( node )
	local dataPath = node:getObjectFile ( "def" )
	self.assetPath = node:getPath ()
	return self:loadFromFile ( dataPath )
end

function UIStyleSheet:loadFromFile ( path )
	local source = loadTextData ( path )
	if source then
		return self:load ( source )
	else
		return false
	end
end

function UIStyleSheet:query ( acc )
	local globalCache = self.globalCache
	local queryList, fullQuery = acc:getQueryList ()
	local data = globalCache[ fullQuery ]

	if data then
		return data
	end

	data = {}
	local hasFeatureQuery = acc.hasFeatureQuery

	for i, query in ipairs ( queryList ) do
		local tag, query, queryLevel = unpack ( query )
		local result = self:_queryStyleData ( tag, query, queryLevel, hasFeatureQuery )
		if result then
			insert ( data, 1, result )
		end
	end

	globalCache[ fullQuery ] = data
	return data
end

function UIStyleSheet:findPatternGroup ( tag )
	local finalTaggedList = self.finalTaggedList
	local group = finalTaggedList[ tag ]

	if group ~= nil then
		return group
	end

	local clas = findClass ( tag )

	if not isSubclass ( clas, UIWidget ) then
		return false
	end

	while true do
		clas = clas.__super
		group = finalTaggedList[ clas.__name ]

		if group then
			finalTaggedList[ tag ] = group
			return group
		end
	end

	finalTaggedList[ tag ] = false
	return false
end

local matchCount = 0
function UIStyleSheet:_queryStyleData ( tag, query, queryLevel, hasFeatureQuery )
	local localCache = self.localCache
	local data = localCache[ query ]

	if data ~= nil then
		return data
	end

	local patternGroup = self:findPatternGroup ( tag )

	if not patternGroup then
		localCache[ query ] = false
		return false
	end

	local data = {}
	local visitQueue = {}
	local count = 0
	local visited = {}

	for i = #patternGroup, 1, -1 do

		local patternList = patternGroup[ i ]
		for j = #patternList, 1, -1 do
			local entry = patternList[ j ]
			local entryID = entry[ 4 ]
			if not visited[ entryID ] then
				count = count + 1
				visited[ entryID ] = true
				visitQueue[ count ] = entry
			end
		end
	end

	local visited = {}

	for i = count, 1, -1 do
		local entry = visitQueue[ i ]
		local qualifier = entry[ 2 ]

		assert ( not visited[ qualifier ] )

		visited[ qualifier ] = true
		local level = qualifier.level

		if level <= queryLevel and  ( not qualifier.hasFeature or hasFeature ) then
			matchCount = matchCount + 1

			if find ( query, qualifier.finalPattern ) then
				local itemdata = entry[ 3 ]
				for k, v in pairs ( itemdata ) do
					data[ k ] = v
				end
			end
		end
	end

	if next ( data ) then
		localCache[ query ] = data
		return data
	else
		localCache[ query ] = false
		return false
	end
end

--------------------------------------------------------------------
-- UIStyleRawItem
--------------------------------------------------------------------
---@class UIStyleRawItem
UIStyleRawItem = CLASS: UIStyleRawItem ()
	:MODEL {}

local _globalIndex = 0

function UIStyleRawItem:__init ( superStyle )
	self._globalIndex = _globalIndex
	_globalIndex = _globalIndex + 1
	self._index = 0
	self.pathSize = 0
	self.qualifiers = {}
end

function UIStyleRawItem:setNamespace ( ns )
	self.namespace = ns
end

local function parseStyleNamePart ( n )
	local features = {}
	local featureSet = {}
	n = n:trim ()
	local current = nil
	local a, b, tag = n:find ( "^%s*([%w_]+)", current )

	if b then
		current = b + 1
	end

	local state0 = nil

	while true do
		local a, b, state = n:find ( "^%s*:([%w_]+)", current )

		if state then
			if state0 then
				_warn ( "multiple state names not supported", n )
				return false
			end
			state0 = state
			current = b + 1
		end

		local a, b, feature = n:find ( "^%s*%.([%w_]+)", current )

		if feature then
			current = b + 1
			feature = feature:lower ()
			if not featureSet[ feature ] then
				featureSet[ feature ] = true
				table.insert ( features, feature )
			end
		elseif not state then
			break
		end
	end

	if not current or current < #n then
		_warn ( "invalid style name> ", n )
		return false
	end

	table.sort ( features )

	local pattern = ""
	local name = ""
	local pass = false

	if tag then
		local clas = findClass ( tag )

		if isSubclass ( clas, UIWidget ) then
			local abbr = _getWidgetClassAbbr ( clas.__name )
			name = name .. tag
			pattern = pattern .. "{.*" .. abbr .. ".*}"
		else
			_warn ( "no widget type", tag )
			name = name .. tag
			pattern = pattern .. "" .. tag
		end

		pass = false
	else
		pattern = pattern .. "[^>]*"
		pass = true
	end

	if state0 then
		name = name .. ":" .. state0
		pattern = pattern .. ":" .. state0 .. "[^>]*"
		pass = false
	elseif not pass then
		pattern = pattern .. "[^>]*"
		pass = true
	end

	local _getWidgetFeatureAbbr = _getWidgetFeatureAbbr

	for i, f in ipairs ( features ) do
		name = name .. "." .. f
		pattern = pattern .. "%." .. _getWidgetFeatureAbbr ( f )
		pattern = pattern .. "[^>]*"
		pass = true
	end

	if not pass then
		pattern = pattern .. "[^>]*"
		pass = true
	end

	return {
		tag = tag or false,
		state = state0 or false,
		features = features,
		hasFeature = next ( features ) and true,
		name = name,
		pattern = pattern
	}
end

local function parseStyleName ( n, ns )
	local path = {}
	n = n:trim ()
	n =  ( ns or "" ) .. n
	local name = false
	local pattern = false
	local parts = n:split ( ">", true )
	local level = #parts

	for i, part in ipairs ( parts ) do
		local data = parseStyleNamePart ( part )

		if not data then
			return false
		end

		path[ i ] = data

		if not pattern then
			pattern = data.pattern
			name = data.name
		else
			pattern = pattern .. ".*>" .. data.pattern
			name = name .. ">" .. data.name
		end
	end

	local tag = path and path[ #path ].tag
	local state = path and path[ #path ].state
	local finalPattern = pattern and pattern .. "$" or false

	return {
		tag = tag,
		state = state,
		path = path,
		pathSize = #path,
		level = level,
		name = name,
		finalPattern = finalPattern
	}
end

function UIStyleRawItem:parseTarget ( ... )
	local pathSize = 0
	local qualifiers = self.qualifiers

	for i, name in ipairs ( { ... } ) do
		local qualifier = parseStyleName ( name, self.namespace )
		if qualifier then
			table.insert ( qualifiers, qualifier )
			pathSize = math.max ( pathSize, qualifier.pathSize )
		end
	end

	self.pathSize = pathSize
end

function UIStyleRawItem:load ( data )
	self.data = data
	local localeEntries = {}

	for idx, entry in pairs ( data ) do
		if type ( entry ) == "table" and entry.tag == "locale" then
			localeEntries[ entry ] = idx
		end
	end

	for entry, idx in pairs ( localeEntries ) do
		local localeParts = entry.locale
		data[ idx ] = nil

		for locale in localeParts:gsplit ( "," ) do
			for k, v in pairs ( entry.body ) do
				local newKey = k .. "@" .. locale
				data[ newKey ] = v
			end
		end
	end
end

--------------------------------------------------------------------
local function UIStyleSheetLoader ( node )
	local sheet = UIStyleSheet ()
	if sheet:loadFromAsset ( node ) then
		node:disableGC ()
		return sheet
	else
		return false
	end
end

function prebuildUIStyleSheetTags ( path )
	local sheet = candy.loadAsset ( path )
	print ( serpent.dump ( sheet.finalTaggedList ) )
end


AssetLibraryModule.registerAssetLoader ( "ui_style", UIStyleSheetLoader )

UIStyleModule.UIStyleSheet = UIStyleSheet
UIStyleModule.UIStyleRawItem = UIStyleRawItem

return UIStyleModule