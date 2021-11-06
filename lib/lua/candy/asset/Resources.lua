----------------------------------------------------------------------------------------------------
-- A resource management system that caches loaded resources to maximize performance.
--
-- @author Makoto
-- @release V3.0.0
----------------------------------------------------------------------------------------------------

-- import
local AssetLibraryModule = require 'candy.AssetLibrary'

---@class Resources
local Resources = {}

-- variables
Resources.resourceDirectories = {}
Resources.textureCache = setmetatable ( {}, { __mode = "v" } )
Resources.fontCache = {}
Resources.PathSeparator = MOAIEnvironment.osBrand == 'Windows' and '\\' or '/'

---
-- Add the resource directory path.
-- You can omit the file path by adding.
-- It is assumed that the file is switched by the resolution and the environment.
---@param path string resource directory path
function Resources.addResourceDirectory ( path )
    table.insertElement ( Resources.resourceDirectories, path )
end

---
-- Returns the filePath from fileName.
---@param fileName string
---@return file path
function Resources.getResourceFilePath ( fileName )
    if MOAIFileSystem.checkFileExists ( fileName ) then
        return fileName
    end
    for i, path in ipairs ( Resources.resourceDirectories ) do
        local filePath = path .. "/" .. fileName
        if MOAIFileSystem.checkFileExists ( filePath ) then
            return filePath
        end
    end
    return fileName
end

---
-- Returns the dirPath from fileName.
---@param fileName string
---@return file directory
function Resources.stripFileName ( fileName )

    local brand = MOAIEnvironment.osBrand

    if brand == 'Windows' then
        return string.match ( fileName, "(.+)\\[^\\]*%.%w+$" ) -- windows
    else
        return string.match ( fileName, "(.+)/[^/]*%.%w+$" ) --unix system
    end
end

---
-- Returns the filename from filename path.
---@param fileName string
---@return file name
function Resources.stripPath ( fileName )

    local brand = MOAIEnvironment.osBrand

    if brand == 'Windows' then
        return string.match ( fileName, ".+\\([^\\]*%.%w+)$" ) -- windows
    else
        return string.match ( fileName, ".+/([^/]*%.%w+)$" ) -- *nix system
    end
end

---
-- Returns the file extension from filename.
---@param fileName string
---@return file extension
function Resources.stripExtension ( fileName )

    local idx = string.match ( fileName, ".+()%.%w+$" )
	if idx then
		return string.sub ( fileName, 1, idx - 1 )
	else
		return fileName
	end
end

function Resources.getFileExtension ( fileName )
    return string.match ( fileName, ".+%.(%w+)$" )
end

function Resources.combinePath ( ... )

    local path = nil

    for key, value in pairs ( { ... } ) do
        if path == nil then
            path = value
        else
            path = path .. Resources.PathSeparator .. value
        end
    end
    
    return path
end

---
-- Loads (or obtains from its cache) a texture and returns it.
-- Textures are cached.
---@param path string The path of the texture
---@param filter number filter.
---@return MOAITexture instance
function Resources.getTexture ( path, filter )
    if type ( path ) == "userdata" then
        return path
    end

    local cache = Resources.textureCache
    filter = filter or MOAITexture.GL_LINEAR

    local filepath = Resources.getResourceFilePath ( path )
    local cacheKey = filepath .. "$" .. tostring ( filter )
    if cache[ cacheKey ] == nil then
        local texture = MOAITexture.new ()
        texture:load ( filepath )
        texture:setFilter ( filter )
        cache[ cacheKey ] = texture
    end
    return cache[ cacheKey ]
end

---
-- Loads (or obtains from its cache) a font and returns it.
---@param path The path of the font.
---@param charcodes (option)Charcodes of the font
---@param points (option)Points of the font
---@param dpi (option)Dpi of the font
---@param filter (option)Filter of the font
---@return MOAIFont instance
function Resources.getFont ( path, charcodes, points, dpi, filter )
    if type ( path ) == "userdata" then
        return path
    end

    local cache = Resources.fontCache
    path = path or "assets/fonts/VL-PGothic.ttf"
    path = Resources.getResourceFilePath ( path )
    charcodes = charcodes or "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-"
    points = points or 24
    dpi = dpi or 72
    filter = filter or MOAITexture.GL_LINEAR

    local uid = path .. "$" .. (charcodes or "") .. "$" .. (points or "") .. "$" .. (dpi or "") .. "$" .. (filter and tostring(filter) or "")
    if cache[ uid ] == nil then
        local font = MOAIFont.new ()
        font:load ( path )
        font:setFilter ( filter )
        font:preloadGlyphs ( charcodes, points, dpi )
        font.uid = uid
        cache[ uid ] = font

        -- _log ( "load font", path )
    end

    return cache[ uid ]
end

---
-- Returns the file data.
---@param fileName file name
---@return file data
function Resources.readFile ( fileName )
    local path = Resources.getResourceFilePath ( fileName )
    local input = assert ( io.input ( path ) )
    local data = input:read ( "*a" )
    input:close ()
    return data
end

---
-- Returns the result of executing the dofile.
-- Browse to the directory of the resource.
---@param fileName lua file name
---@return results of running the dofile
function Resources.dofile ( fileName )
    local filePath = Resources.getResourceFilePath ( fileName )
    return dofile ( filePath )
end

---
-- Destroys the reference when the module.
---@param m module
function Resources.destroyModule ( m )
    if m and m._M and m._NAME and package.loaded[ m._NAME ] then
        package.loaded[ m._NAME ] = nil
        _G[ m._NAME ] = nil
    end
end

return Resources