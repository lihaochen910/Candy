module 'candy_edit'

local generateGUID = MOAIEnvironment.generateGUID

--------------------------------------------------------------------
local function affirmGUID( actor )
	if not actor.__guid then
		actor.__guid = generateGUID()
	end
	for com in pairs( actor.components ) do
		if not com.__guid then
			com.__guid = generateGUID()
		end
	end
	for child in pairs( actor.children ) do
		affirmGUID( child )
	end
end

local function affirmSceneGUID( scene )
	--affirm guid
	for actor in pairs( scene.actors ) do
		affirmGUID( actor )
	end
end

--------------------------------------------------------------------
local function findTopLevelGroups( groupSet )
	local found = {}
	for g in pairs( groupSet ) do
		local isTop = true
		local p = g.parent
		while p do
			if groupSet[ p ] then isTop = false break end
			p = p.parent
		end
		if isTop then found[g] = true end
	end
	return found
end

local function findTopLevelActors( entitySet )
	local found = {}
	for e in pairs( entitySet ) do
		local p = e.parent
		local isTop = true
		while p do
			if entitySet[ p ] then isTop = false break end
			p = p.parent
		end
		if isTop then found[e] = true end
	end
	return found
end

local function findActorsOutsideGroups( entitySet, groupSet )
	local found = {}
	for e in pairs( entitySet ) do
		local g = e:getEntityGroup( true )
		local isTop = true
		while g do
			if entitySet[ g ] then isTop = false break end
			g = g.parent
		end
		if isTop then found[e] = true end
	end
	return found
end

local function getTopLevelActorSelection()
	local actorSet = {}
	local groupSet  = {}
	for i, e in ipairs( candy_editor.getSelection( 'scene' ) ) do
		if isInstance( e, candy.Actor ) then
			actorSet[ e ] = true
		elseif isInstance( e, candy.ActorGroup ) then
			groupSet[ e ] = true
		end
	end
	local topLevelActorSet = findTopLevelActors(actorSet)
	local topLevelGroupSet = findTopLevelGroups( groupSet )
	topLevelActorSet = findActorsOutsideGroups(topLevelActorSet, topLevelGroupSet )
	local list = {}
	for ent in pairs(topLevelActorSet) do
		table.insert( list, ent )
	end
	for group in pairs( topLevelGroupSet ) do
		table.insert( list, group )
	end
	return list
end

local function isEditorActor( a )
	while a do
		if a.FLAG_EDITOR_OBJECT or a.FLAG_INTERNAL then return true end
		a = a.parent
	end
	return false
end

--local updateGfxResource = MOAIGfxResourceMgr.update
--function updateMOAIGfxResource()
--	if updateGfxResource then
--		updateGfxResource()
--	end
--end
--------------------------------------------------------------------
_C.findTopLevelActors       	= findTopLevelActors
_C.getTopLevelActorSelection 	= getTopLevelActorSelection
_C.isEditorActor             	= isEditorActor
_C.affirmGUID                 	= affirmGUID
_C.affirmSceneGUID            	= affirmSceneGUID

candy_edit.affirmGUID			= affirmGUID
candy_edit.isEditorActor		= isEditorActor
