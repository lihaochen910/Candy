-- module
local EnvModule = {}

---env
local ProjectBasePath = false
local GameConfigBasePath = false


local function getProjectPath ( path )
	if not path then
		return ProjectBasePath or ''
	end

	if ProjectBasePath then
		return ProjectBasePath .. '/' .. ( path or '' )
	else
		return path
	end
end

local function getGameConfigPath ( path )
	if not path then
		return GameConfigBasePath or ''
	end
	
	if GameConfigBasePath then
		return GameConfigBasePath .. '/' .. ( path or '' )
	else
		return path
	end
end

local function setupEnvironment ( prjBase, configBase )
	ProjectBasePath = prjBase
	GameConfigBasePath  = configBase
end


EnvModule.getProjectPath = getProjectPath
EnvModule.getGameConfigPath = getGameConfigPath
EnvModule.setupEnvironment = setupEnvironment

--------------------------------------------------------------------
--config
local function loadGameConfig ( filename )
	local path = getGameConfigPath ( filename )
	local data = tryLoadJSONFile ( path )
	_stat ( 'loading game config', path )
	return data
end

local function saveGameConfig ( data, filename )
	if not data then return false end
	local path = getGameConfigPath ( filename )
	local dir = dirname ( path )
	_info ( 'saving game config', path )
	MOAIFileSystem.affirmPath ( dir )
	saveJSONFile ( data, path )
end

EnvModule.loadGameConfig = loadGameConfig
EnvModule.saveGameConfig = saveGameConfig

return EnvModule