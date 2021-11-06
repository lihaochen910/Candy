-- module
local JSONHelperModule = {}

local function clearNullUserdata ( t )
	for k,v in pairs ( t ) do
		local tt = type ( v )
		if tt == 'table' then
			clearNullUserdata ( v )
		elseif tt == 'userdata' then
			t[ k ] = nil
		end
	end	
end

local function loadJSONText ( text, clearNulls )
	local data =  MOAIJsonParser.decode (text)
	if not data then 
		_error ( 'json file not parsed: '..path )
		return nil
	end
	if clearNulls then
		clearNullUserdata ( data )
	end
	return data
end

local function loadJSONFile ( path, clearNulls )
	local f = io.open ( path, 'r' )
	if not f then
		_error ( 'data file not found:' .. tostring ( path ),2  )
		return nil
	end
	local text=f:read ('*a')
	f:close ()

	return loadJSONText ( text, clearNulls )
end

local function tryLoadJSONFile ( path, clearNulls )
	local succ, data = pcall ( loadJSONFile, path, clearNulls )
	if succ then return data end
	return nil
end

local function saveJSONFile ( data, path, dataInfo )
	local output = JSONHelperModule.encodeJSON ( data )
	local file = io.open ( path, 'w' )
	if file then
		file:write (output)
		file:close ()
		_stat ( dataInfo, 'saved to', path )
	else
		_error ( 'can not save ', dataInfo , 'to' , path )
	end
end

----
local JSON_FLAG_INDENT			= function (n) return n > 31 and 31 or n < 0 and 0 or n end
local JSON_FLAG_COMPACT			= 32
local JSON_FLAG_SORT_KEY		= 128
local JSON_FLAG_PRESERVE_ORDER 	= 256
local JSON_FLAG_ENCODE_ANY		= 512

----
MOAIJsonParser.defaultEncodeFlags = JSON_FLAG_INDENT ( 2 ) + JSON_FLAG_SORT_KEY

JSONHelperModule.encodeJSON = function ( data, compact ) --included default flags
    if compact then
        return MOAIJsonParser.encode ( data, JSON_FLAG_SORT_KEY + JSON_FLAG_COMPACT )
    else
        return MOAIJsonParser.encode ( data, MOAIJsonParser.defaultEncodeFlags )
    end
end

JSONHelperModule.decodeJSON = function ( data ) --included default flags
    return MOAIJsonParser.decode ( data )
end

JSONHelperModule.loadJSONText = loadJSONText
JSONHelperModule.loadJSONFile = loadJSONFile
JSONHelperModule.tryLoadJSONFile = tryLoadJSONFile
JSONHelperModule.saveJSONFile = saveJSONFile

return JSONHelperModule