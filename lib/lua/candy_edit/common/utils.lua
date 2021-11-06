-- module
local UtilsModule = {}

local generateGUID = MOAIEnvironment.generateGUID

--------------------------------------------------------------------
local function affirmGUID ( entity )
	if not entity.__guid then
		entity.__guid = generateGUID ()
	end
	for com in pairs ( entity.components ) do
		if not com.__guid then
			com.__guid = generateGUID ()
		end
	end
	for child in pairs ( entity.children ) do
		affirmGUID ( child )
	end
end

local function affirmSceneGUID ( scene )
	--affirm guid
	for entity in pairs ( scene.entities ) do
		affirmGUID ( entity )
	end
end

--------------------------------------------------------------------
local function findTopLevelGroups ( groupSet )
	local found = {}
	for g in pairs ( groupSet ) do
		local isTop = true
		local p = g.parent
		while p do
			if groupSet[ p ] then isTop = false break end
			p = p.parent
		end
		if isTop then found[ g ] = true end
	end
	return found
end

local function findTopLevelEntities ( entitySet )
	local found = {}
	for e in pairs ( entitySet ) do
		local p = e.parent
		local isTop = true
		while p do
			if entitySet[ p ] then isTop = false break end
			p = p.parent
		end
		if isTop then found[ e ] = true end
	end
	return found
end

local function findEntitiesOutsideGroups (entitySet, groupSet )
	local found = {}
	for e in pairs ( entitySet ) do
		local g = e:getEntityGroup ( true )
		local isTop = true
		while g do
			if entitySet[ g ] then isTop = false break end
			g = g.parent
		end
		if isTop then found[e] = true end
	end
	return found
end

local function getTopLevelEntitySelection ()
	local entitySet = {}
	local groupSet  = {}
	for i, e in ipairs ( candy_editor.getSelection ( 'scene' ) ) do
		if isInstance ( e, candy.Entity ) then
			entitySet[ e ] = true
		elseif isInstance ( e, candy.EntityGroup ) then
			groupSet[ e ] = true
		end
	end
	local topLevelEntitySet = findTopLevelEntities (entitySet)
	local topLevelGroupSet = findTopLevelGroups ( groupSet )
	topLevelEntitySet = findEntitiesOutsideGroups (topLevelEntitySet, topLevelGroupSet )
	local list = {}
	for ent in pairs ( topLevelEntitySet ) do
		table.insert ( list, ent )
	end
	for group in pairs ( topLevelGroupSet ) do
		table.insert ( list, group )
	end
	return list
end

local function isEditorEntity ( a )
	while a do
		if a.FLAG_EDITOR_OBJECT or a.FLAG_INTERNAL then return true end
		a = a.parent
	end
	return false
end

--local updateGfxResource = MOAIGfxResourceMgr.update
--function updateMOAIGfxResource ()
--	if updateGfxResource then
--		updateGfxResource ()
--	end
--end
--------------------------------------------------------------------
UtilsModule.findTopLevelEntities       	= findTopLevelEntities
UtilsModule.getTopLevelEntitySelection 	= getTopLevelEntitySelection
UtilsModule.isEditorEntity             	= isEditorEntity
UtilsModule.affirmGUID                 	= affirmGUID
UtilsModule.affirmSceneGUID            	= affirmSceneGUID

UtilsModule.affirmGUID			= affirmGUID
UtilsModule.isEditorEntity		= isEditorEntity
UtilsModule.getTopLevelEntitySelection = getTopLevelEntitySelection

return UtilsModule