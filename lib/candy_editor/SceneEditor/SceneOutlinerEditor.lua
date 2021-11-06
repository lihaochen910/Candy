local findTopLevelEntities = candy_edit.findTopLevelEntities
local getTopLevelEntitySelection = candy_edit.getTopLevelEntitySelection
local isEditorEntity = candy_edit.isEditorEntity

local affirmGUID = candy.affirmGUID
local affirmSceneGUID = candy.affirmSceneGUID
local generateGUID = MOAIEnvironment.generateGUID

local function _handleOnError ( msg )
	local errMsg = msg
	local tracebackMsg = debug.traceback ( 2 )
	return errMsg .. '\n' .. tracebackMsg
end

local firstRun = true
--------------------------------------------------------------------
---@class SceneOutlinerEditor
local SceneOutlinerEditor = CLASS: SceneOutlinerEditor ()

function SceneOutlinerEditor:__init ()
	self.failedRefreshData = false
	self.previewState = false
	connectSignalMethod ( 'mainscene.open',  self, 'onMainSceneOpen' )
	connectSignalMethod ( 'mainscene.close', self, 'onMainSceneClose' )
end

function SceneOutlinerEditor:getScene ()
	return self.scene
end

function SceneOutlinerEditor:openScene ( path )
	_stat ( 'open candy scene', path )
	local scene = candy.game:openSceneByPath (
		path, 
		false,
		{
			fromEditor = true,
		},
		false
	) --dont start
	assert ( scene )
	self.scene = scene
	candy.affirmSceneGUID ( scene )
	--candy_edit.updateMOAIGfxResource ()
	self:postLoadScene ()
	if firstRun then
		firstRun = false
		--MOAIGfxResourceMgr.renewResources ()
	end
	self.previewState = false
	return scene
end

function SceneOutlinerEditor:postOpenScene ()
	_stat ( 'post open candy scene' )
	--candy.setAssetCacheWeak ()
	MOAISim.forceGC ()
	--candy.setAssetCacheStrong ()
	candy.game:resetClock ()
end

function SceneOutlinerEditor:closeScene ()
	if not self.scene then return end
	_stat ( 'close candy scene' )
	self:clearScene ()
	self.scene = false
	self.retainedSceneData = false
	self.retainedSceneSelection = false
	candy.game:resetClock ()
end

function SceneOutlinerEditor:saveScene ( path )
	if not self.scene then return false end
	affirmSceneGUID ( self.scene )
	candy.serializeSceneToFile ( self.scene, path, 'keepProto' )
	return true
end

function SceneOutlinerEditor:clearScene ( keepEditorEntity )
	-- _collectgarbage ( 'stop' )
	self.scene:clear ( keepEditorEntity )
	self.scene:setEntityListener ( false )
	-- _collectgarbage ( 'restart' )
end

function SceneOutlinerEditor:refreshScene ()
	self:retainScene ()
	self:clearScene ( true )
	local r = self:restoreScene ()
	return r
end

local function collectFoldState ( ent )
end

function SceneOutlinerEditor:saveEntityLockState ()
	local output = {}
	for ent in pairs ( self.scene.entities ) do
		if ent.__guid and ent._editLocked then output[ ent.__guid ] = true end
	end
	for group in pairs ( self.scene:collectEntityGroups () ) do
		if group.__guid and group._editLocked then output[ group.__guid ] = true end
	end
	return candy_editor.tableToDict ( output )
end

function SceneOutlinerEditor:loadEntityLockState ( data )
	local lockStates = candy_editor.dictToTable ( data )
	for ent in pairs ( self.scene.entities ) do
		if ent.__guid and lockStates[ ent.__guid ] then
			ent:setEditLocked ( true )
		end
	end
	for group in pairs ( self.scene:collectEntityGroups () ) do
		if group.__guid and lockStates[ group.__guid ] then
			group:setEditLocked ( true )
		end
	end
end

function SceneOutlinerEditor:saveIntrospectorFoldState ()
	local output = {}
	for ent in pairs ( self.scene.entities ) do
		if ent.__guid and ent.__foldState then output[ ent.__guid ] = true end
		for com in pairs ( ent.components ) do
			if com.__guid and com.__foldState then output[ com.__guid ] = true end
		end
	end
	return candy_editor.tableToDict ( output )
end

function SceneOutlinerEditor:loadIntrospectorFoldState ( containerFoldState )
	containerFoldState = candy.dictToTable ( containerFoldState )
	for ent in pairs ( self.scene.entities ) do
		if ent.__guid and containerFoldState[ ent.__guid ] then
			ent.__foldState = true
		end
		for com in pairs ( ent.components ) do
			if com.__guid and containerFoldState[ com.__guid ] then
				com.__foldState = true
			end
		end

	end
end

function SceneOutlinerEditor:locateProto ( path )
	local protoData = candy.loadAsset ( path )
	local rootId = protoData.rootId
	for ent in pairs ( self.scene.entities ) do
		if ent.__guid == rootId then
			return candy_editor.changeSelection ( 'scene', ent )
		end
	end
end

function SceneOutlinerEditor:postLoadScene ()
	local scene = self.scene
	--scene:setEntityListener ( function ( action, ... ) return self:onEntityEvent ( action, ... ) end )
	scene:setEntityListener ( function ( action, entity, com ) return self:onEntityEvent ( action, entity, com ) end )
end


function SceneOutlinerEditor:startScenePreview ()
	self.previewState = true
	_collectgarbage ( 'collect' )
	-- GIIHelper.forceGC ()
	_stat ( 'starting scene preview' )
	candy.game:start ()
	_stat ( 'scene preview started' )
end

function SceneOutlinerEditor:stopScenePreview ()
	self.previewState = false
	_stat ( 'stopping scene preview' )
	_collectgarbage ( 'collect' )
	-- GIIHelper.forceGC ()
	candy.game:stop ()
	--restore layer visiblity
	for i, l in pairs ( candy.game:getLayers () ) do
		l:setVisible ( true )
	end
	_stat ( 'scene preview stopped' )
end

function SceneOutlinerEditor:retainScene ()
	--keep current selection
	local guids = {}
	for i, a in ipairs ( candy_editor.getSelection ( 'scene' ) ) do
		guids[ i ] = a.__guid
	end
	self.retainedSceneSelection = guids
	self.retainedSceneData = candy.serializeScene ( self.scene, 'keepProto' )
	--keep node fold state
end

function SceneOutlinerEditor:restoreScene ()
	if not self.retainedSceneData then return true end
	local function _onError ( msg )
		local errMsg = msg
		local tracebackMsg = debug.traceback ( 2 )
		return errMsg .. '\n' .. tracebackMsg
	end
	self.scene:reset ()
	local ok, msg = xpcall ( function ()
			candy.deserializeScene ( self.retainedSceneData, self.scene )
		end,
		_onError
	)
	candy_editor.emitPythonSignal ( 'scene.update' )
	if ok then
		self.retainedSceneData = false
		self:postLoadScene ()
		_owner.tree:rebuild ()
		local result = {}
		for i, guid in ipairs ( self.retainedSceneSelection ) do
			local e = self:findEntityByGUID ( guid )
			if e then table.insert ( result, e ) end			
		end
		candy_editor.changeSelection ( 'scene', unpack ( result ) )
		self.retainedSceneSelection = false		
		return true
	else
		print ( msg )
		self.failedRefreshData = self.retainedSceneData
		return false
	end
end

function SceneOutlinerEditor:findEntityByGUID ( id )
	local result = false
	for e in pairs ( self.scene.entities ) do
		if e.__guid == id then
			result = e
		end
	end
	return result
end

local function collectEntity ( e, typeId, collection )
	if isEditorEntity ( e ) then return end
	if isInstance ( e, typeId ) then
		collection[ e ] = true
	end
	for child in pairs ( e.children ) do
		collectEntity ( child, typeId, collection )
	end
end

local function collectComponent ( entity, typeId, collection )
	if isEditorEntity ( entity ) then return end
	for com in pairs ( entity.components ) do
		if not com.FLAG_INTERNAL and isInstance ( com, typeId ) then
			collection[ com ] = true
		end
	end
	for child in pairs ( entity.children ) do
		collectComponent ( child, typeId, collection )
	end
end

local function collectEntityGroup ( group, collection )
	if isEditorEntity ( group ) then return end
	collection[ group ] = true 
	for child in pairs ( group.childGroups ) do
		collectEntityGroup ( child, collection )
	end
end

function SceneOutlinerEditor:enumerateObjects ( typeId, context, option )
	local scene = self.scene
	if not scene then return nil end
	local result = {}
	--REMOVE: demo codes
	if typeId == 'entity' then
		local collection = {}	
		
		for e in pairs ( scene.entities ) do
			collectEntity ( e, candy.Entity, collection )
		end

		for e in pairs ( collection ) do
			table.insert ( result, e )
		end
	
	elseif typeId == 'group' then	
		local collection = {}	
		
		for g in pairs ( scene:getRootGroup ().childGroups ) do
			collectEntityGroup ( g, collection )
		end

		for g in pairs ( collection ) do
			table.insert ( result, g )
		end

	elseif typeId == 'entity_in_group' then
		local collection = {}	
		--TODO:!!!!
		
		for e in pairs ( scene.entities ) do
			collectEntity ( e, candy.Entity, collection )
		end

		for e in pairs ( collection ) do
			table.insert ( result, e )
		end

	else
		local collection = {}	
		if isSubclass ( typeId, candy.Entity ) then
			for e in pairs ( scene.entities ) do
				collectEntity ( e, typeId, collection )
			end
		else
			for e in pairs ( scene.entities ) do
				collectComponent ( e, typeId, collection )
			end
		end
		for e in pairs ( collection ) do
			table.insert ( result, e )
		end
	end
	return result
end


function SceneOutlinerEditor:onEntityEvent ( action, entity, com )
	if self.previewState then return end --ignore entity event on previewing

	--_log ('SceneOutlinerEditor:onEntityEvent ()', action, entity, com)

	emitSignal ( 'scene.entity_event', action, entity, com )
	
	if action == 'clear' then
		return candy_editor.emitPythonSignal ( 'scene.clear' )
	end

	if isEditorEntity ( entity ) then return end

	--candy_editor.pyLogWarn ("onEntityEvent () "..action.." "..tostring (entity))

	if action == 'add' then
		_owner.addEntityNode ( entity )
		-- candy_editor.emitPythonSignal ( 'scene.update' )
	elseif action == 'remove' then
		_owner.removeEntityNode ( entity )
		-- candy_editor.emitPythonSignal ( 'scene.update' )
	elseif action == 'add_group' then
		_owner.addEntityNode ( entity )
		-- candy_editor.emitPythonSignal ( 'scene.update' )
	elseif action == 'remove_group' then
		_owner.removeEntityNode ( entity )
		-- candy_editor.emitPythonSignal ( 'scene.update' )
	end

end

function SceneOutlinerEditor:onMainSceneOpen ( scn )
	candy_editor.emitPythonSignal ( 'scene.change' )
end

function SceneOutlinerEditor:onMainSceneClose ( scn )
	candy_editor.emitPythonSignal ( 'scene.change' )
end

function SceneOutlinerEditor:makeSceneSelectionCopyData ()
	local targets = getTopLevelEntitySelection ()
	local dataList = {}
	for _, ent in ipairs ( targets ) do
		local data = candy.makeEntityCopyData ( ent )
		table.insert ( dataList, data )
	end
	return encodeJSON ( { 
		entities = dataList,
		scene    = editor.scene.assetPath or '<unknown>',
	} )
end

editor = SceneOutlinerEditor ()

--------------------------------------------------------------------
function enumerateSceneObjects ( enumerator, typeId, context, option )
	--if context~='scene_editor' then return nil end
	return editor:enumerateObjects ( typeId, context, option )
end

function getSceneObjectRepr ( enumerator, obj )
	if isInstance ( obj, candy.Entity ) then
		return obj:getFullName () or '<unnamed>'
	elseif isInstance ( obj, candy.EntityGroup ) then
		return obj:getFullName () or '<unnamed>'
	end
	--todo: component
	local ent = obj._entity
	if ent then
		return ent:getFullName () or '<unnamed>'
	end
	return nil
end

function getSceneObjectTypeRepr ( enumerator, obj )
	local class = getClass ( obj )
	if class then
		return class.__name
	end
	return nil
end

candy_editor.registerObjectEnumerator {
	name = 'scene_object_enumerator',
	enumerateObjects   = enumerateSceneObjects,
	getObjectRepr      = getSceneObjectRepr,
	getObjectTypeRepr  = getSceneObjectTypeRepr
}


--------------------------------------------------------------------
function enumerateLayers ( enumerator, typeId, context )
	--if context~='scene_editor' then return nil end
	if typeId ~= 'layer' then return nil end
	local r = {}
	for i, l in ipairs ( candy.game.layers ) do
		if l.name ~= 'CANDY_EDITOR_LAYER' then
			table.insert ( r, l.name )
		end
	end
	return r
end

function getLayerRepr ( enumerator, obj )
	return obj
end

function getLayerTypeRepr ( enumerator, obj )
	return 'Layer'
end

candy_editor.registerObjectEnumerator {
	name = 'layer_enumerator',
	enumerateObjects   = enumerateLayers,
	getObjectRepr      = getLayerRepr,
	getObjectTypeRepr  = getLayerTypeRepr
}


--------------------------------------------------------------------
--- COMMAND
--------------------------------------------------------------------
local function extractNumberPrefix ( name )
	local numberPart = string.match ( name, '_%d+$' )
	if numberPart then
		local mainPart = string.sub ( name, 1, -1 - #numberPart )
		return mainPart, tonumber ( numberPart )
	end
	return name, nil
end

local function findNextNumberProfix ( scene, name )
	local max = -1
	local pattern = name .. '_ (%d+)$'
	for ent in pairs ( scene.entities ) do
		local n = ent:getName ()
		if n then
			if n == name then 
				max = math.max ( 0, max )
			else
				local id = string.match ( n, pattern )
				if id then
					max = math.max ( max, tonumber ( id ) )
				end
			end
		end
	end
	return max
end

local function makeNumberProfix ( scene, entity )
	local n = entity:getName ()
	if n then
		--auto increase prefix
		local header, profix = extractNumberPrefix ( n )
		local number = findNextNumberProfix ( scene, header )
		if number >= 0 then
			local profix = '_' .. string.format ( '%02d', number + 1 )
			entity:setName ( header .. profix )
		end
	end
end

--------------------------------------------------------------------
---@class CmdCreateEntityBase : EditorCommand
local CmdCreateEntityBase = CLASS: CmdCreateEntityBase ( candy_edit.EditorCommand )

function CmdCreateEntityBase:init ( option )
	local contextEntity = candy_editor.getSelection ( 'scene' )[ 1 ]
	if isInstance ( contextEntity, candy.Entity ) then
		if option[ 'create_sibling' ] then
			self.parentEntity = contextEntity:getParent ()
		else
			self.parentEntity = contextEntity
		end
	elseif isInstance ( contextEntity, candy.EntityGroup ) then
		self.parentEntity = contextEntity
	else
		self.parentEntity = false
	end
end

function CmdCreateEntityBase:createEntity () end

function CmdCreateEntityBase:getResult ()
	return self.created
end

function CmdCreateEntityBase:redo ()
	local entity = self:createEntity ()
	if not entity then return false end
	affirmGUID ( entity )
	self.created = entity
	if self.parentEntity then
		self.parentEntity:addChild ( entity )
	else
		editor.scene:addEntity ( entity )
	end
	candy_editor.emitPythonSignal ( 'entity.added', self.created, 'new' )
end

function CmdCreateEntityBase:undo ()
	self.created:destroyWithChildrenNow ()
	candy_editor.emitPythonSignal ( 'entity.removed', self.created )
end

local function _editorInitCom ( com )
	if com.onEditorInit then
		com:onEditorInit ()
	end
end

local function _editorDeleteCom ( com )
	if com.onEditorDelete then
		com:onEditorDelete ()
	end
end

local function _editorDeleteEntity ( e )
	if e.onEditorDelete then
		e:onEditorDelete ()
	end
	for com in pairs ( e.components ) do
		_editorDeleteCom ( com )
	end
	for child in pairs ( e.children ) do
		_editorDeleteEntity ( child )
	end
end

local function _editorInitEntity ( a )
	--_log ('_editorInitEntity', a:getName (), a)
	if a.onEditorInit then
		a:onEditorInit ()
	end

	for com in pairs ( a.components ) do
		--_log ('_editorInitEntity -> component', com:getClassName (), com)
		_editorInitCom ( com )
	end

	for child in pairs ( a.children ) do
		--_log ('_editorInitEntity -> children', child:getClassName (), child)
		_editorInitEntity ( child )
	end
end

--------------------------------------------------------------------
---@class CmdAddEntity : CmdCreateEntityBase
local CmdAddEntity = CLASS: CmdAddEntity ( CmdCreateEntityBase )
	:register ( 'scene_editor/add_entity' )

function CmdAddEntity:init ( option )
	CmdCreateEntityBase.init ( self, option )
	self.precreatedEntity = option.entity
	if not self.precreatedEntity then
		return false
	end
	_editorInitEntity ( self.precreatedEntity )
end

function CmdAddEntity:createEntity ()
	return self.precreatedEntity
end

--------------------------------------------------------------------
---@class CmdCreateEntity : CmdCreateEntityBase
local CmdCreateEntity = CLASS: CmdCreateEntity ( CmdCreateEntityBase )
	:register ( 'scene_editor/create_entity' )

function CmdCreateEntity:init ( option )
	CmdCreateEntityBase.init ( self, option )
	self.entityName = option.name
end

function CmdCreateEntity:createEntity ()
	local entityType = candy.getEntityType ( self.entityName )
	assert ( entityType )
	local a = entityType ()

	_log ('CmdCreateEntity:createEntity ()', self.entityName, a)

	local ok, msg = xpcall (function ()
		_editorInitEntity ( a )
		if not a.name then a.name = self.entityName end
	end, _handleOnError )

	if not ok then
		print ( msg )
	end

	-- _editorInitEntity ( a )
	-- if not a.name then a.name = self.entityName end

	return a
end

function CmdCreateEntity:undo ()
	self.created:destroyWithChildrenNow ()
	candy_editor.emitPythonSignal ( 'entity.removed', self.created )
end


--------------------------------------------------------------------
---@class CmdRemoveEntity : EditorCommand
local CmdRemoveEntity = CLASS: CmdRemoveEntity ( candy_edit.EditorCommand )
	:register ( 'scene_editor/remove_entity' )

function CmdRemoveEntity:init ( option )
	self.selection = candy_edit.getTopLevelEntitySelection ()
end

function CmdRemoveEntity:redo ()
	for _, target in ipairs ( self.selection ) do
		if isInstance ( target, candy.Entity ) then
			if target.scene then 
				target:destroyWithChildrenNow ()
				candy_editor.emitPythonSignal ( 'entity.removed', target )
			end
		elseif isInstance ( target, candy.EntityGroup ) then
			target:destroyWithChildrenNow ()
			candy_editor.emitPythonSignal ( 'entity.removed', target )
		end
	end
end

function CmdRemoveEntity:undo ()
	--todo: RESTORE deleted
	-- candy_editor.emitPythonSignal ('entity.added', self.created )
end

--------------------------------------------------------------------
---@class CmdCreateComponent : EditorCommand
local CmdCreateComponent = CLASS: CmdCreateComponent ( candy_edit.EditorCommand )
	:register ( 'scene_editor/create_component' )

function CmdCreateComponent:init ( option )
	self.componentName = option.name	
	local target = candy_editor.getSelection ( 'scene' )[1]
	if not isInstance ( target, candy.Entity ) then
		_warn ( 'attempt to attach component to non Entity object', target:getClassName () )
		return false
	end	
	self.targetEntity = target
end

function CmdCreateComponent:redo ()
	local comType = candy.getComponentType ( self.componentName )
	assert ( comType )
	local component = comType ()
	-- if not component:isAttachable ( self.targetEntity ) then
	-- 	mock_edit.alertMessage ( 'todo', 'Group clone not yet implemented', 'info' )
	-- 	return false
	-- end
	component.__guid = generateGUID ()
	self.createdComponent = component
	self.targetEntity:attach ( component )
	if component.onEditorInit then
		component:onEditorInit ()
	end
	candy_editor.emitPythonSignal ( 'component.added', component, self.targetEntity )
end

function CmdCreateComponent:undo ()
	self.targetEntity:detach ( self.createdComponent )
	candy_editor.emitPythonSignal ( 'component.removed', component, self.targetEntity )
end

--------------------------------------------------------------------
---@class CmdRemoveComponent : EditorCommand
local CmdRemoveComponent = CLASS: CmdRemoveComponent ( candy_edit.EditorCommand )
	:register ( 'scene_editor/remove_component' )

function CmdRemoveComponent:init ( option )
	self.target = option[ 'target' ]
end

function CmdRemoveComponent:redo ()
	--todo
	local entity = self.target._entity
	if entity then
		entity:detach ( self.target )
	end
	self.previousParent = entity
	candy_editor.emitPythonSignal ( 'component.removed', self.target, self.previousParent )
end

function CmdRemoveComponent:undo ()
	self.previousParent:attach ( self.target )
	candy_editor.emitPythonSignal ( 'component.added', self.target, self.previousParent )
end


--------------------------------------------------------------------
---@class CmdCloneEntity : EditorCommand
local CmdCloneEntity = CLASS: CmdCloneEntity ( candy_edit.EditorCommand )
	:register ( 'scene_editor/clone_entity' )

function CmdCloneEntity:init ( option )
	local targets = getTopLevelEntitySelection ()
	self.targets = targets
	self.created = false
	if not next ( targets ) then return false end
end

function CmdCloneEntity:redo ()
	local createdList = {}
	for _, target in ipairs ( self.targets ) do
		if isInstance ( target, candy.EntityGroup ) then
			candy_edit.alertMessage ( 'todo', 'Group clone not yet implemented', 'info' )
			return false
		else
			local created = candy.copyAndPasteEntity ( target, generateGUID )
			makeNumberProfix ( editor.scene, created )
			local parent = target.parent
			if parent then
				parent:addChild ( created )
			else
				editor.scene:addEntity ( created, nil, target._entityGroup )
			end		
			candy_editor.emitPythonSignal ( 'entity.added', created, 'clone' )
			table.insert ( createdList, created )
		end
	end
	candy_editor.changeSelection ( 'scene', unpack ( createdList ) )
	self.createdList = createdList
end

function CmdCloneEntity:undo ()
	--todo:
	for i, created in ipairs ( self.createdList ) do
		created:destroyWithChildrenNow ()
		candy_editor.emitPythonSignal ('entity.removed', created )
	end
	self.createdList = false
end

--------------------------------------------------------------------
---@class CmdPasteEntity : EditorCommand
local CmdPasteEntity = CLASS: CmdPasteEntity ( candy_edit.EditorCommand )
	:register ( 'scene_editor/paste_entity' )

function CmdPasteEntity:init ( option )
	self.data   = decodeJSON ( option['data'] )
	self.parent = candy_editor.getSelection ( 'scene' )[1] or false
	self.createdList = false
	if not self.data then _error ( 'invalid entity data' ) return false end
end

function CmdPasteEntity:redo ()
	local createdList = {}
	local parent = self.parent
	for i, copyData in ipairs ( self.data.entities ) do
		local entityData = candy.makeEntityPasteData ( copyData, generateGUID )
		local created = candy.deserializeEntity ( entityData )
		if parent then
			parent:addChild ( created )
		else
			editor.scene:addEntity ( created )
		end		
		candy_editor.emitPythonSignal ('entity.added', created, 'paste' )
		table.insert ( createdList, created )
	end
	self.createdList = createdList
	candy_editor.changeSelection ( 'scene', unpack ( createdList ) )
end

function CmdPasteEntity:undo ()
	--todo:
	for i, created in ipairs ( self.createdList ) do
		created:destroyWithChildrenNow ()
		candy_editor.emitPythonSignal ('entity.removed', created )
	end
	self.createdList = false
end


--------------------------------------------------------------------
---@class CmdReparentEntity : EditorCommand
local CmdReparentEntity = CLASS: CmdReparentEntity ( candy_edit.EditorCommand )
	:register ( 'scene_editor/reparent_entity' )

function CmdReparentEntity:init ( option )
	local mode = option[ 'mode' ] or 'child'
	if mode == 'sibling' then
		self.target   = option['target']:getParentOrGroup ()
	else
		self.target   = option['target']
	end
	self.children = candy_edit.getTopLevelEntitySelection ()
	self.oldParents = {}
	local targetIsEntity = isInstance ( self.target, candy.Entity )
	for i, e in ipairs ( self.children ) do
		if isInstance ( e, candy.EntityGroup ) and targetIsEntity then
			--candy_editor.alertMessage ( 'fail', 'cannot make Group child of Entity', 'info' )
			return false
		end
	end
end

function CmdReparentEntity:redo ()
	local target = self.target
	for i, e in ipairs ( self.children ) do
		if isInstance ( e, candy.Entity ) then
			self:reparentEntity ( e, target )
		elseif isInstance ( e, candy.EntityGroup ) then
			self:reparentEntityGroup ( e, target )
		end
	end	
end

function CmdReparentEntity:reparentEntityGroup ( group, target )
	local targetGroup = false
	if target == 'root' then
		targetGroup = editor.scene:getRootGroup ()
	elseif isInstance ( target, candy.EntityGroup ) then
		targetGroup = target
	else
		error ()
	end

	group:reparent ( targetGroup )
end

function CmdReparentEntity:reparentEntity ( e, target )
	e:forceUpdate ()
	local tx, ty ,tz = e:getWorldLoc ()
	local sx, sy ,sz = e:getWorldScl ()
	local rz = e:getWorldRot ()
	
	--TODO: world rotation X,Y	
	if target == 'root' then
		e:setLoc ( tx, ty, tz )
		e:setScl ( sx, sy, sz )
		e:setRotZ ( rz )
		e:reparent ( nil )
		e:reparentGroup ( editor.scene:getRootGroup () )

	elseif isInstance ( target, candy.EntityGroup ) then
		e:setLoc ( tx, ty, tz )
		e:setScl ( sx, sy, sz )
		e:setRotZ ( rz )
		e:reparent ( nil )
		e:reparentGroup ( target )

	else
		target:forceUpdate ()
		local x, y, z = target:worldToModel ( tx, ty, tz )
		
		local sx1, sy1, sz1 = target:getWorldScl ()
		sx = ( sx1 == 0 ) and 0 or sx/sx1
		sy = ( sy1 == 0 ) and 0 or sy/sy1
		sz = ( sz1 == 0 ) and 0 or sz/sz1

		local rz1 = target:getWorldRot ()
		rz = rz1 == 0 and 0 or rz/rz1
		e:setLoc ( x, y, z )
		e:setScl ( sx, sy, sz )
		e:setRotZ ( rz )
		e:reparent ( target )
	end

end

function CmdReparentEntity:undo ()
	--todo:
	_error ( 'NOT IMPLEMENTED' )
end

--------------------------------------------------------------------
local function saveEntityToPrefab ( entity, prefabFile )
	local data = candy.serializeEntity ( entity )
	local str  = encodeJSON ( data )
	local file = io.open ( prefabFile, 'wb' )
	if file then
		file:write ( str )
		file:close ()
	else
		_error ( 'can not write to scene file', prefabFile )
		return false
	end
	return true
end

local function reloadPrefabEntity ( entity )
	local guid = entity.__guid
	local prefabPath = entity.__prefabId

	--Just recreate entity from prefab
	local prefab, node = candy.loadAsset ( prefabPath )
	if not prefab then return false end
	local newEntity = prefab:createInstance ()
	--only perserve location?
	newEntity:setLoc ( entity:getLoc () )
	newEntity:setName ( entity:getName () )
	newEntity:setLayer ( entity:getLayer () )
	newEntity.__guid = guid
	newEntity.__prefabId = prefabPath
	--TODO: just marked as deleted
	entity:addSibling ( newEntity )
	entity:destroyWithChildrenNow ()
end


--------------------------------------------------------------------
---@class CmdCreatePrefab : EditorCommand
local CmdCreatePrefab = CLASS: CmdCreatePrefab ( candy_edit.EditorCommand )
	:register ( 'scene_editor/create_prefab' )

function CmdCreatePrefab:init ( option )
	self.prefabFile = option[ 'file' ]
	self.prefabPath = option[ 'prefab' ]
	self.entity     = option[ 'entity' ]
end

function CmdCreatePrefab:redo ()
	if saveEntityToPrefab ( self.entity, self.prefabFile ) then
		self.entity.__prefabId = self.prefabPath
		return true
	else
		return false
	end
end

--------------------------------------------------------------------
---@class CmdCreatePrefabEntity : CmdCreateEntityBase
local CmdCreatePrefabEntity = CLASS: CmdCreatePrefabEntity ( CmdCreateEntityBase )
	:register ( 'scene_editor/create_prefab_entity' )

function CmdCreatePrefabEntity:init ( option )
	CmdCreateEntityBase.init ( self, option )
	self.prefabPath = option['prefab']
end

function CmdCreatePrefabEntity:createEntity ()
	local prefab, node = candy.loadAsset ( self.prefabPath )
	if not prefab then return false end
	return prefab:createInstance ()
end

--------------------------------------------------------------------
---@class CmdUnlinkPrefab : EditorCommand
local CmdUnlinkPrefab = CLASS: CmdUnlinkPrefab ( candy_edit.EditorCommand )
	:register ( 'scene_editor/unlink_prefab' )

function CmdUnlinkPrefab:init ( option )
	self.entity     = option['entity']
	self.prefabId = self.entity.__prefabId
end

function CmdUnlinkPrefab:redo ()
	self.entity.__prefabId = nil
	candy_editor.emitPythonSignal ( 'prefab.unlink', self.entity )
end

function CmdUnlinkPrefab:undo ()
	self.entity.__prefabId = self.prefabId --TODO: other process
	candy_editor.emitPythonSignal ( 'prefab.relink', self.entity )
end


--------------------------------------------------------------------
---@class CmdPushPrefab : EditorCommand
local CmdPushPrefab = CLASS: CmdPushPrefab ( candy_edit.EditorCommand )
	:register ( 'scene_editor/push_prefab' )

function CmdPushPrefab:init ( option )
	self.entity = option['entity']
end

function CmdPushPrefab:redo ()
	local entity = self.entity
	local prefabPath = entity.__prefabId
	local node = candygetAssetNode ( prefabPath )
	local filePath = node:getAbsObjectFile ( 'def' )
	if saveEntityToPrefab ( entity, filePath ) then
		candy_editor.emitPythonSignal ( 'prefab.push', entity )
		--Update all entity in current scene
		local scene = entity.scene
		local toReload = {}
		for e in pairs ( scene.entities ) do
			if e.__prefabId == prefabPath and e~=entity then
				toReload[ e ] = true
			end
		end
		for e in pairs ( toReload ) do
			reloadPrefabEntity ( e )
		end
	else
		return false
	end
end


--------------------------------------------------------------------
---@class CmdPullPrefab : EditorCommand
local CmdPullPrefab = CLASS: CmdPullPrefab ( candy_edit.EditorCommand )
	:register ( 'scene_editor/pull_prefab' )

function CmdPullPrefab:init ( option )
	self.entity     = option['entity']
end

function CmdPullPrefab:redo ()
	reloadPrefabEntity ( self.entity )
	candy_editor.emitPythonSignal ( 'prefab.pull', self.newEntity )
	--TODO: reselect it ?
end

--------------------------------------------------------------------
---@class CmdCreatePrefabContainer : CmdCreateEntityBase
local CmdCreatePrefabContainer = CLASS: CmdCreatePrefabContainer ( CmdCreateEntityBase )
	:register ( 'scene_editor/create_prefab_container' )

function CmdCreatePrefabContainer:init ( option )
	CmdCreateEntityBase.init ( self, option )
	self.prefabPath = option['prefab']
end

function CmdCreatePrefabContainer:createEntity ()
	local container = candyPrefabContainer ()
	container:setPrefab ( self.prefabPath )
	return container	
end

--------------------------------------------------------------------
---@class CmdMakeProto : EditorCommand
local CmdMakeProto = CLASS: CmdMakeProto ( candy_edit.EditorCommand )
	:register ( 'scene_editor/make_proto' )

function CmdMakeProto:init ( option )
	self.entity = option['entity']
end

function CmdMakeProto:redo ()
	self.entity.FLAG_PROTO_SOURCE = true
end

function CmdMakeProto:undo ()
	self.entity.FLAG_PROTO_SOURCE = false
end


--------------------------------------------------------------------
---@class CmdCreateProtoInstance : CmdCreateEntityBase
local CmdCreateProtoInstance = CLASS: CmdCreateProtoInstance ( CmdCreateEntityBase )
	:register ( 'scene_editor/create_proto_instance' )

function CmdCreateProtoInstance:init ( option )
	CmdCreateEntityBase.init ( self, option )
	self.protoPath = option['proto']
end

function CmdCreateProtoInstance:createEntity ()
	local proto = candy.loadAsset ( self.protoPath )
	local id    = generateGUID ()
	local instance = proto:createInstance ( nil, id )
	instance.__overrided_fields = {
		[ 'loc' ] = true,
		[ 'name' ] = true,
	}
	makeNumberProfix ( editor.scene, instance )
	return instance
end


--------------------------------------------------------------------
---@class CmdCreateProtoContainer : CmdCreateEntityBase
local CmdCreateProtoContainer = CLASS: CmdCreateProtoContainer ( CmdCreateEntityBase )
	:register ( 'scene_editor/create_proto_container' )

function CmdCreateProtoContainer:init ( option )
	CmdCreateEntityBase.init ( self, option )
	self.protoPath = option['proto']
end

function CmdCreateProtoContainer:createEntity ()
	local proto = candy.loadAsset ( self.protoPath )
	local name = proto:getRootName ()
	print ( 'proto name', name )
	local container = candyProtoContainer ()
	container:setName ( name )
	container.proto = self.protoPath
	makeNumberProfix ( editor.scene, container )
	return container
end

--------------------------------------------------------------------
---@class CmdUnlinkProto : EditorCommand
local CmdUnlinkProto = CLASS: CmdUnlinkProto ( candy_edit.EditorCommand )
	:register ( 'scene_editor/unlink_proto' )

function CmdUnlinkProto:_retainAndClearComponentProtoState ( entity, data )
	for com in pairs ( entity.components ) do
		if com.__proto_history then
			data[ com ] = {
				overrided = com.__overrided_fields,
				history   = com.__proto_history,
			}
			com.__overrided_fields = nil
			com.__proto_history = nil
		end
	end
end

function CmdUnlinkProto:_retainAndClearChildProtoState ( entity, data )
	if entity.PROTO_INSTANCE_STATE then return end
	if not entity.__proto_history then return end
	data[ entity ] = {
		overrided = entity.__overrided_fields,
		history   = entity.__proto_history,
	}
	entity.__overrided_fields = nil
	entity.__proto_history = nil
	self:_retainAndClearComponentProtoState ( entity, data )
	for child in pairs ( entity.children ) do
		self:_retainAndClearChildProtoState ( child, data )
	end
end

function CmdUnlinkProto:_retainAndClearEntityProtoState ( root, data )
	data = data or {}
	if root.PROTO_INSTANCE_STATE then
		data[ root ] = {
			overrided = root.__overrided_fields,
			history   = root.__proto_history,
			state     = root.PROTO_INSTANCE_STATE
		}
		for child in pairs ( root.children ) do
			self:_retainAndClearChildProtoState ( child, data )
		end
		self:_retainAndClearComponentProtoState ( root, data )
		root.__overrided_fields   = nil
		root.__proto_history      = nil
		root.PROTO_INSTANCE_STATE = nil
	end
	return data
end

function CmdUnlinkProto:_restoreEntityProtoState ( root, data )
	for ent, retained in pairs ( data ) do
		if retained.state then
			ent.PROTO_INSTANCE_STATE = retained.state
		end
		ent.__overrided_fields = retained.overrided
		ent.__proto_history = retained.history
	end
end
--TODO
function CmdUnlinkProto:init ( option )
	self.entity     = option['entity']
end

function CmdUnlinkProto:redo ()
	self.retainedState =  self:_retainAndClearEntityProtoState ( self.entity )
	candy_editor.emitPythonSignal ( 'proto.unlink', self.entity )
	candy_editor.emitPythonSignal ( 'entity.modified', self.entity )
end

function CmdUnlinkProto:undo ()
	self:_restoreEntityProtoState ( self.retainedState )
	candy_editor.emitPythonSignal ( 'proto.relink', self.entity )
	candy_editor.emitPythonSignal ( 'entity.modified', self.entity )
end


--------------------------------------------------------------------
---@class CmdAssignEntityLayer : EditorCommand
local CmdAssignEntityLayer = CLASS: CmdAssignEntityLayer ( candy_edit.EditorCommand )
	:register ( 'scene_editor/assign_layer' )

function CmdAssignEntityLayer:init ( option )
	self.layerName = option['target']
	self.entities  = candy_editor.getSelection ( 'scene' )
	self.oldLayers = {}
end

function CmdAssignEntityLayer:redo ()
	local layerName = self.layerName
	local oldLayers = self.oldLayers
	for i, e in ipairs ( self.entities ) do
		oldLayers[ e ] = e:getLayer ()
		e:setLayer ( layerName )
		candy_editor.emitPythonSignal ( 'entity.renamed', e, '' )
	end	
end

function CmdAssignEntityLayer:undo ()
	local oldLayers = self.oldLayers
	for i, e in ipairs ( self.entities ) do
		layerName = oldLayers[ e ]
		e:setLayer ( layerName )
		candy_editor.emitPythonSignal ( 'entity.renamed', e, '' )
	end	
end


--------------------------------------------------------------------
---@class CmdToggleEntityVisibility : EditorCommand
local CmdToggleEntityVisibility = CLASS: CmdToggleEntityVisibility ( candy_edit.EditorCommand )
	:register ( 'scene_editor/toggle_entity_visibility' )

function CmdToggleEntityVisibility:init ( option )
	local target = option[ 'target' ]
	if target then
		self.entities = { target }
	else
		self.entities  = candy_editor.getSelection ( 'scene' )
	end
	self.originalVis  = {}
end

function CmdToggleEntityVisibility:redo ()
	local vis = false
	local originalVis = self.originalVis
	for i, e in ipairs ( self.entities ) do
		originalVis[ e ] = e:isLocalVisible ()
		if e:isLocalVisible () then vis = true end
	end	
	vis = not vis
	for i, e in ipairs ( self.entities ) do
		e:setVisible ( vis )
		--candy.markProtoInstanceOverrided ( e, 'visible' )
		candy_editor.emitPythonSignal ( 'entity.visible_changed', e )
		candy_editor.emitPythonSignal ( 'entity.modified', e, '' )
	end
end

function CmdToggleEntityVisibility:undo ()
	local originalVis = self.originalVis
	for i, e in ipairs ( self.entities ) do
		e:setVisible ( originalVis[ e ] )
		candy_editor.emitPythonSignal ( 'entity.modified', e, '' )
	end	
	self.originalVis  = {}
end


--------------------------------------------------------------------
---@class CmdToggleEntityLock : EditorCommandNoHistory
local CmdToggleEntityLock = CLASS: CmdToggleEntityLock ( candy_edit.EditorCommandNoHistory )
	:register ( 'scene_editor/toggle_entity_lock' )

function CmdToggleEntityLock:init ( option )
	local target = option[ 'target' ]
	if target then
		self.entities = { target }
	else
		self.entities  = candy_editor.getSelection ( 'scene' )
	end

	local locked = false
	for i, e in ipairs ( self.entities ) do
		if e:isLocalEditLocked () then locked = true break end
	end	
	locked = not locked
	for i, e in ipairs ( self.entities ) do
		e:setEditLocked ( locked )
		candy_editor.emitPythonSignal ( 'entity.visible_changed', e )
		candy_editor.emitPythonSignal ( 'entity.modified', e, '' )
	end
end

--------------------------------------------------------------------
---@class CmdUnifyChildrenLayer : EditorCommand
local CmdUnifyChildrenLayer = CLASS: CmdUnifyChildrenLayer ( candy_edit.EditorCommand )
	:register ( 'scene_editor/unify_children_layer' )

function CmdUnifyChildrenLayer:init ( option )
	--TODO
end

function CmdUnifyChildrenLayer:redo ( )
	--TODO
end

function CmdUnifyChildrenLayer:undo ( )
	--TODO
end

--------------------------------------------------------------------
---@class CmdFreezePivot : EditorCommand
local CmdFreezePivot = CLASS: CmdFreezePivot ( candy_edit.EditorCommand )
	:register ( 'scene_editor/freeze_entity_pivot' )

function CmdFreezePivot:init ( option )
	self.entities  = candy_editor.getSelection ( 'scene' )
	self.previousPivots = {}
end

function CmdFreezePivot:redo ( )
	local pivots = self.previousPivots
	for i, e in ipairs ( self.entities ) do
		local px, py, pz = e:getPiv ()
		e:setPiv ( 0,0,0 )
		e:addLoc ( -px, -py, -pz )
		-- for child in pairs ( e:getChildren () ) do
		-- 	child:addLoc ( -px, -py, -pz )
		-- end
		candy_editor.emitPythonSignal ( 'entity.modified', e, '' )
	end
end

function CmdFreezePivot:undo ( )
	--TODO
end


--------------------------------------------------------------------
---@class CmdEntityGroupCreate : EditorCommand
local CmdEntityGroupCreate = CLASS: CmdEntityGroupCreate ( candy_edit.EditorCommand )
	:register ( 'scene_editor/entity_group_create' )


function CmdEntityGroupCreate:init ( option )
	local contextEntity = candy_editor.getSelection ( 'scene' )[1]
	
	if isInstance ( contextEntity, candy.Entity ) then
		if not contextEntity._entityGroup then
			candy_edit.alertMessage ( 'fail', 'cannot create Group inside Entity', 'info' )
			return false
		end
		self.parentGroup = contextEntity._entityGroup
	elseif isInstance ( contextEntity, candy.EntityGroup ) then
		self.parentGroup = contextEntity
	else
		self.parentGroup = editor.scene:getRootGroup ()
	end

	self.guid = generateGUID ()
end

function CmdEntityGroupCreate:redo ()
	self.createdGroup = candy.EntityGroup ()
	self.parentGroup:addChildGroup ( self.createdGroup )
	self.createdGroup.__guid = self.guid
	candy_editor.emitPythonSignal ( 'entity.added', self.createdGroup, 'new' )
end

function CmdEntityGroupCreate:undo ()
	--TODO
	self.parentGroup:removeChildGroup ( self.createdGroup )
end


--------------------------------------------------------------------
---@class CmdGroupEntities : EditorCommand
local CmdGroupEntities = CLASS: CmdGroupEntities ( candy_edit.EditorCommand )
	:register ( 'scene_editor/group_entities' )

function CmdGroupEntities:init ( option )
	--TODO:!!!
	local contextEntity = candy_editor.getSelection ( 'scene' )[1]
	if isInstance ( contextEntity, candy.Entity ) then
		if not contextEntity._entityGroup then
			candy_edit.alertMessage ( 'fail', 'cannot create Group inside Entity', 'info' )
			return false
		end
		self.parentGroup = contextEntity._entityGroup
	elseif isInstance ( contextEntity, candy.EntityGroup ) then
		self.parentGroup = contextEntity
	else
		self.parentGroup = editor.scene:getRootGroup ()
	end

	self.guid = generateGUID ()

end

function CmdGroupEntities:redo ()
	self.createdGroup = candy.EntityGroup ()
	self.parentGroup:addChildGroup ( self.createdGroup )
	self.createdGroup.__guid = self.guid
	candy_editor.emitPythonSignal ( 'entity.added', self.createdGroup, 'new' )
end

function CmdGroupEntities:undo ()
	--TODO
	self.parentGroup:removeChildGroup ( self.createdGroup )
end


--------------------------------------------------------------------
---@class CmdSelectScene : EditorCommand
local CmdSelectScene = CLASS: CmdSelectScene ( candy_edit.EditorCommandNoHistory )
	:register ( 'scene_editor/select_scene' )


function CmdSelectScene:init ( option )
	return candy_editor.changeSelection ( 'scene', editor.scene )
end


--------------------------------------------------------------------
---@class CmdAlignEntities : EditorCommand
local CmdAlignEntities = CLASS: CmdAlignEntities ( candy_edit.EditorCommand )
	:MODEL {}

function CmdAlignEntities:init ( option )
	local targets = getTopLevelEntitySelection ()
	local mode = option['mode']
	self.targets = targets
	if not mode then return false end
	if not next ( targets ) then return false end
end

function CmdAlignEntities:redo ()
end

function CmdAlignEntities:undo ()
	--TODO:undo
end
