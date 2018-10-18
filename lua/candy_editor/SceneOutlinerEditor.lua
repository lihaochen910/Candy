local findTopLevelActors        = candy_edit.findTopLevelActors
local getTopLevelActorSelection = candy_edit.getTopLevelActorSelection
local isEditorActor             = candy_edit.isEditorActor

local affirmGUID      = candy.affirmGUID
local affirmSceneGUID = candy.affirmSceneGUID
local generateGUID = MOAIEnvironment.generateGUID

local function _handleOnError( msg )
	local errMsg = msg
	local tracebackMsg = debug.traceback(2)
	return errMsg .. '\n' .. tracebackMsg
end

local firstRun = true
--------------------------------------------------------------------
CLASS:  SceneOutlinerEditor()

function SceneOutlinerEditor:__init()
	self.failedRefreshData = false
	self.previewState = false
	connectSignalMethod( 'mainscene.open',  self, 'onMainSceneOpen' )
	connectSignalMethod( 'mainscene.close', self, 'onMainSceneClose' )
end

function SceneOutlinerEditor:getScene()
	return self.scene
end

function SceneOutlinerEditor:openScene( path )
	_stat( 'open candy scene', path )
	local scene = candy.game:openSceneByPath(
		path, 
		false,
		{
			fromEditor = true,
		},
		false
	) --dont start
	assert( scene )
	self.scene = scene
	candy.affirmSceneGUID( scene )
	--candy_edit.updateMOAIGfxResource()
	self:postLoadScene()
	if firstRun then
		firstRun = false
		--MOAIGfxResourceMgr.renewResources()
	end
	self.previewState = false
	return scene
end

function SceneOutlinerEditor:postOpenScene()
	_stat( 'post open candy scene' )
	--mock.setAssetCacheWeak()
	MOAISim.forceGC()
	--mock.setAssetCacheStrong()
	candy.game:resetClock()
end

function SceneOutlinerEditor:closeScene()
	if not self.scene then return end
	_stat( 'close candy scene' )
	self:clearScene()
	self.scene = false
	self.retainedSceneData = false
	self.retainedSceneSelection = false
	candy.game:resetClock()
end

function SceneOutlinerEditor:saveScene( path )
	if not self.scene then return false end
	affirmSceneGUID( self.scene )
	candy.serializeSceneToFile( self.scene, path, 'keepProto' )
	return true
end

function SceneOutlinerEditor:clearScene( keepEditorActor )
	-- _collectgarbage( 'stop' )
	self.scene:clear( keepEditorActor )
	self.scene:setActorListener( false )
	-- _collectgarbage( 'restart' )
end

function SceneOutlinerEditor:refreshScene()
	self:retainScene()
	self:clearScene( true )
	local r = self:restoreScene()	
	return r
end

local function collectFoldState( ent )
end

function SceneOutlinerEditor:saveEntityLockState()
	local output = {}
	for ent in pairs( self.scene.actors ) do
		if ent.__guid and ent._editLocked then output[ent.__guid] = true end
	end
	for group in pairs( self.scene:collectActorGroups() ) do
		if group.__guid and group._editLocked then output[group.__guid] = true end
	end
	return candy_editor.tableToDict( output )
end

function SceneOutlinerEditor:loadEntityLockState( data )
	local lockStates = candy_editor.dictToTable( data )
	for ent in pairs( self.scene.actors ) do
		if ent.__guid and lockStates[ent.__guid] then
			ent:setEditLocked( true )
		end
	end
	for group in pairs( self.scene:collectEntityGroups() ) do
		if group.__guid and lockStates[group.__guid] then
			group:setEditLocked( true )
		end
	end
end

function SceneOutlinerEditor:saveIntrospectorFoldState()
	local output = {}
	for ent in pairs( self.scene.actors ) do
		if ent.__guid and ent.__foldState then output[ent.__guid] = true end
		for com in pairs( ent.components ) do
			if com.__guid and com.__foldState then output[com.__guid] = true end
		end
	end
	return candy_editor.tableToDict( output )
end

function SceneOutlinerEditor:loadIntrospectorFoldState( containerFoldState )
	containerFoldState = candy.dictToTable( containerFoldState )
	for ent in pairs( self.scene.actors ) do
		if ent.__guid and containerFoldState[ent.__guid] then
			ent.__foldState = true
		end
		for com in pairs( ent.components ) do
			if com.__guid and containerFoldState[ com.__guid ] then
				com.__foldState = true
			end
		end

	end
end

function SceneOutlinerEditor:locateProto( path )
	local protoData = candy.loadAsset( path )
	local rootId = protoData.rootId
	for ent in pairs( self.scene.actors ) do
		if ent.__guid == rootId then
			return candy_editor.changeSelection( 'scene', ent )
		end
	end
end

function SceneOutlinerEditor:postLoadScene()
	local scene = self.scene
	--scene:setActorListener( function( action, ... ) return self:onActorEvent( action, ... ) end )
	scene:setActorListener( function( action, actor, com ) return self:onActorEvent( action, actor, com ) end )
end


function SceneOutlinerEditor:startScenePreview()
	self.previewState = true
	_collectgarbage( 'collect' )
	-- GIIHelper.forceGC()
	_stat( 'starting scene preview' )
	candy.game:start()
	_stat( 'scene preview started' )
end

function SceneOutlinerEditor:stopScenePreview()
	self.previewState = false
	_stat( 'stopping scene preview' )
	_collectgarbage( 'collect' )
	-- GIIHelper.forceGC()
	candy.game:stop()
	--restore layer visiblity
	for i, l in pairs( candy.game:getLayers() ) do
		l:setVisible( true )
	end
	_stat( 'scene preview stopped' )
end


function SceneOutlinerEditor:retainScene()
	--keep current selection
	local guids = {}
	for i, a in ipairs( candy_editor.getSelection( 'scene' ) ) do
		guids[ i ] = a.__guid
	end
	self.retainedSceneSelection = guids
	self.retainedSceneData = candy.serializeScene( self.scene, 'keepProto' )
	--keep node fold state
end

function SceneOutlinerEditor:restoreScene()
	if not self.retainedSceneData then return true end
	local function _onError( msg )
		local errMsg = msg
		local tracebackMsg = debug.traceback(2)
		return errMsg .. '\n' .. tracebackMsg
	end
	self.scene:reset()
	local ok, msg = xpcall( function()
			candy.deserializeScene( self.retainedSceneData, self.scene )
		end,
		_onError
		)
	candy_editor.emitPythonSignal( 'scene.update' )
	if ok then
		self.retainedSceneData = false
		self:postLoadScene()		
		_owner.tree:rebuild()
		local result = {}
		for i, guid in ipairs( self.retainedSceneSelection ) do
			local e = self:findActorByGUID( guid )
			if e then table.insert( result, e ) end			
		end
		candy_editor.changeSelection( 'scene', unpack( result ) )
		self.retainedSceneSelection = false		
		return true
	else
		print( msg )
		self.failedRefreshData = self.retainedSceneData
		return false
	end
end

function SceneOutlinerEditor:findActorByGUID( id )
	local result = false
	for e in pairs( self.scene.actors ) do
		if e.__guid == id then
			result = e
		end
	end
	return result
end

local function collectActor( e, typeId, collection )
	if isEditorActor( e ) then return end
	if isInstance( e, typeId ) then
		collection[ e ] = true
	end
	for child in pairs( e.children ) do
		collectActor( child, typeId, collection )
	end
end

local function collectComponent( actor, typeId, collection )
	if isEditorActor( actor ) then return end
	for com in pairs( actor.components ) do
		if not com.FLAG_INTERNAL and isInstance( com, typeId ) then
			collection[ com ] = true
		end
	end
	for child in pairs( actor.children ) do
		collectComponent( child, typeId, collection )
	end
end

local function collectActorGroup( group, collection )
	if isEditorActor( group ) then return end
	collection[ group ] = true 
	for child in pairs( group.childGroups ) do
		collectActorGroup( child, collection )
	end
end

function SceneOutlinerEditor:enumerateObjects( typeId, context, option )
	local scene = self.scene
	if not scene then return nil end
	local result = {}
	--REMOVE: demo codes
	if typeId == 'actor' then
		local collection = {}	
		
		for e in pairs( scene.actors ) do
			collectActor( e, candy.Actor, collection )
		end

		for e in pairs( collection ) do
			table.insert( result, e )
		end
	
	elseif typeId == 'group' then	
		local collection = {}	
		
		for g in pairs( scene:getRootGroup().childGroups ) do
			collectActorGroup( g, collection )
		end

		for g in pairs( collection ) do
			table.insert( result, g )
		end

	elseif typeId == 'actor_in_group' then
		local collection = {}	
		--TODO:!!!!
		
		for e in pairs( scene.actors ) do
			collectActor( e, candy.Actor, collection )
		end

		for e in pairs( collection ) do
			table.insert( result, e )
		end

	else
		local collection = {}	
		if isSubclass( typeId, candy.Actor ) then
			for e in pairs( scene.actors ) do
				collectActor( e, typeId, collection )
			end
		else
			for e in pairs( scene.actors ) do
				collectComponent( e, typeId, collection )
			end
		end
		for e in pairs( collection ) do
			table.insert( result, e )
		end
	end
	return result
end


function SceneOutlinerEditor:onActorEvent( action, actor, com )
	if self.previewState then return end --ignore actor event on previewing

	--_log('SceneOutlinerEditor:onActorEvent()', action, actor, com)

	emitSignal( 'scene.actor_event', action, actor, com )
	
	if action == 'clear' then
		return candy_editor.emitPythonSignal( 'scene.clear' )
	end

	if isEditorActor( actor ) then return end

	--candy_editor.pyLogWarn("onActorEvent() "..action.." "..tostring(actor))

	if action == 'add' then
		_owner.addActorNode( actor )
		-- candy_editor.emitPythonSignal( 'scene.update' )
	elseif action == 'remove' then
		_owner.removeActorNode( actor )
		-- candy_editor.emitPythonSignal( 'scene.update' )
	elseif action == 'add_group' then
		_owner.addActorNode( actor )
		-- candy_editor.emitPythonSignal( 'scene.update' )
	elseif action == 'remove_group' then
		_owner.removeActorNode( actor )
		-- candy_editor.emitPythonSignal( 'scene.update' )
	end

end

function SceneOutlinerEditor:onMainSceneOpen( scn )
	candy_editor.emitPythonSignal( 'scene.change' )
end

function SceneOutlinerEditor:onMainSceneClose( scn )
	candy_editor.emitPythonSignal( 'scene.change' )
end

function SceneOutlinerEditor:makeSceneSelectionCopyData()
	local targets = getTopLevelActorSelection()
	local dataList = {}
	for _, ent in ipairs( targets ) do
		local data = candy.makeActorCopyData( ent )
		table.insert( dataList, data )
	end
	return encodeJSON( { 
		actors = dataList,
		scene    = editor.scene.assetPath or '<unknown>',
	} )
end

editor = SceneOutlinerEditor()

--------------------------------------------------------------------
function enumerateSceneObjects( enumerator, typeId, context, option )
	--if context~='scene_editor' then return nil end
	return editor:enumerateObjects( typeId, context, option )
end

function getSceneObjectRepr( enumerator, obj )
	if isInstance( obj, candy.Actor ) then
		return obj:getFullName() or '<unnamed>'

	elseif isInstance( obj, candy.ActorGroup ) then
		return obj:getFullName() or '<unnamed>'

	end
	--todo: component
	local ent = obj._actor
	if ent then
		return ent:getFullName() or '<unnamed>'
	end
	return nil
end

function getSceneObjectTypeRepr( enumerator, obj )
	local class = getClass( obj )
	if class then
		return class.__name
	end
	return nil
end

candy_editor.registerObjectEnumerator{
	name = 'scene_object_enumerator',
	enumerateObjects   = enumerateSceneObjects,
	getObjectRepr      = getSceneObjectRepr,
	getObjectTypeRepr  = getSceneObjectTypeRepr
}


--------------------------------------------------------------------
function enumerateLayers( enumerator, typeId, context )
	--if context~='scene_editor' then return nil end
	if typeId ~= 'layer' then return nil end
	local r = {}
	for i, l in ipairs( candy.game.layers ) do
		if l.name ~= 'CANDY_EDITOR_LAYER' then
			table.insert( r, l.name )
		end
	end
	return r
end

function getLayerRepr( enumerator, obj )
	return obj
end

function getLayerTypeRepr( enumerator, obj )
	return 'Layer'
end

candy_editor.registerObjectEnumerator{
	name = 'layer_enumerator',
	enumerateObjects   = enumerateLayers,
	getObjectRepr      = getLayerRepr,
	getObjectTypeRepr  = getLayerTypeRepr
}


--------------------------------------------------------------------
--- COMMAND
--------------------------------------------------------------------


local function extractNumberPrefix( name )
	local numberPart = string.match( name, '_%d+$' )
	if numberPart then
		local mainPart = string.sub( name, 1, -1 - #numberPart )
		return mainPart, tonumber( numberPart )
	end
	return name, nil
end

local function findNextNumberProfix( scene, name )
	local max = -1
	local pattern = name .. '_(%d+)$'
	for ent in pairs( scene.actors ) do
		local n = ent:getName()
		if n then
			if n == name then 
				max = math.max( 0, max )
			else
				local id = string.match( n, pattern )
				if id then
					max = math.max( max, tonumber( id ) )
				end
			end
		end
	end
	return max
end

local function makeNumberProfix( scene, actor )
	local n = actor:getName()
	if n then
		--auto increase prefix
		local header, profix = extractNumberPrefix( n )
		local number = findNextNumberProfix( scene, header )
		if number >= 0 then
			local profix = '_' .. string.format( '%02d', number + 1 )
			actor:setName( header .. profix )
		end
	end
end

--------------------------------------------------------------------
CLASS: CmdCreateActorBase ( candy_edit.EditorCommand )
function CmdCreateActorBase:init( option )
	local contextActor = candy_editor.getSelection( 'scene' )[1]
	if isInstance( contextActor, candy.Actor ) then
		if option[ 'create_sibling' ] then
			self.parentActor = contextActor:getParent()
		else
			self.parentActor = contextActor
		end
	elseif isInstance( contextActor, candy.ActorGroup ) then
		self.parentActor = contextActor
	else
		self.parentActor = false
	end
end

function CmdCreateActorBase:createActor() end

function CmdCreateActorBase:getResult()
	return self.created
end

function CmdCreateActorBase:redo()
	local actor = self:createActor()
	if not actor then return false end
	affirmGUID( actor )
	self.created = actor
	if self.parentActor then
		self.parentActor:addChild( actor )
	else
		editor.scene:addActor( actor )
	end
	candy_editor.emitPythonSignal( 'actor.added', self.created, 'new' )
end

function CmdCreateActorBase:undo()
	self.created:destroyWithChildrenNow()
	candy_editor.emitPythonSignal( 'actor.removed', self.created )
end

local function _editorInitCom( com )
	if com.onEditorInit then
		com:onEditorInit()
	end
end

local function _editorDeleteCom( com )
	if com.onEditorDelete then
		com:onEditorDelete()
	end
end

local function _editorDeleteActor( e )
	if e.onEditorDelete then
		e:onEditorDelete()
	end
	for com in pairs( e.components ) do
		_editorDeleteCom( com )
	end
	for child in pairs( e.children ) do
		_editorDeleteActor( child )
	end
end

local function _editorInitActor( a )
	--_log('_editorInitActor', a:getName(), a)
	if a.onEditorInit then
		a:onEditorInit()
	end

	for com in pairs( a.components ) do
		--_log('_editorInitActor -> component', com:getClassName(), com)
		_editorInitCom( com )
	end

	for child in pairs( a.children ) do
		--_log('_editorInitActor -> children', child:getClassName(), child)
		_editorInitActor( child )
	end
end

--------------------------------------------------------------------
CLASS: CmdAddActor ( CmdCreateActorBase )
	:register( 'scene_editor/add_actor' )

function CmdAddActor:init( option )
	CmdCreateActorBase.init( self, option )
	self.precreatedActor = option.actor
	if not self.precreatedActor then
		return false
	end
	_editorInitActor( self.precreatedActor )
end

function CmdAddActor:createActor()
	return self.precreatedActor
end

--------------------------------------------------------------------
CLASS: CmdCreateActor ( CmdCreateActorBase )
	:register( 'scene_editor/create_actor' )

function CmdCreateActor:init( option )
	CmdCreateActorBase.init( self, option )
	self.actorName = option.name
end

function CmdCreateActor:createActor()
	local actorType = candy.getActorType( self.actorName )
	assert( actorType )
	local a = actorType()

	_log('CmdCreateActor:createActor()', self.actorName, a)

	local ok, msg = xpcall(function()
		_editorInitActor( a )
		if not a.name then a.name = self.actorName end
	end, _handleOnError)

	if not ok then
		print (msg)
	end

	-- _editorInitActor( a )
	-- if not a.name then a.name = self.actorName end

	return a
end

function CmdCreateActor:undo()
	self.created:destroyWithChildrenNow()
	candy_editor.emitPythonSignal( 'actor.removed', self.created )
end

--------------------------------------------------------------------
CLASS: CmdRemoveActor ( candy_edit.EditorCommand )
	:register( 'scene_editor/remove_actor' )

function CmdRemoveActor:init( option )
	self.selection = candy_edit.getTopLevelActorSelection()
end

function CmdRemoveActor:redo()
	for _, target in ipairs( self.selection ) do
		if isInstance( target, candy.Actor ) then
			if target.scene then 
				target:destroyWithChildrenNow()
				candy_editor.emitPythonSignal( 'actor.removed', target )
			end
		elseif isInstance( target, candy.ActorGroup ) then
			target:destroyWithChildrenNow()
			candy_editor.emitPythonSignal( 'actor.removed', target )
		end
	end
end

function CmdRemoveActor:undo()
	--todo: RESTORE deleted
	-- candy_editor.emitPythonSignal('actor.added', self.created )
end

--------------------------------------------------------------------
CLASS: CmdCreateComponent ( candy_edit.EditorCommand )
	:register( 'scene_editor/create_component' )

function CmdCreateComponent:init( option )
	self.componentName = option.name	
	local target = candy_editor.getSelection( 'scene' )[1]
	if not isInstance( target, candy.Actor ) then
		_warn( 'attempt to attach component to non Actor object', target:getClassName() )
		return false
	end	
	self.targetActor  = target
end

function CmdCreateComponent:redo()	
	local comType = candy.getComponentType( self.componentName )
	assert( comType )
	local component = comType()
	-- if not component:isAttachable( self.targetActor ) then
	-- 	mock_edit.alertMessage( 'todo', 'Group clone not yet implemented', 'info' )
	-- 	return false
	-- end
	component.__guid = generateGUID()
	self.createdComponent = component
	self.targetActor:attach( component )
	if component.onEditorInit then
		component:onEditorInit()
	end
	candy_editor.emitPythonSignal( 'component.added', component, self.targetActor )	
end

function CmdCreateComponent:undo()
	self.targetActor:detach( self.createdComponent )
	candy_editor.emitPythonSignal( 'component.removed', component, self.targetActor )	
end

--------------------------------------------------------------------
CLASS: CmdRemoveComponent ( candy_edit.EditorCommand )
	:register( 'scene_editor/remove_component' )

function CmdRemoveComponent:init( option )
	self.target = option['target']
end

function CmdRemoveComponent:redo()
	--todo
	local actor = self.target._actor
	if actor then
		actor:detach( self.target )
	end
	self.previousParent = actor
	candy_editor.emitPythonSignal( 'component.removed', self.target, self.previousParent )	
end

function CmdRemoveComponent:undo()
	self.previousParent:attach( self.target )
	candy_editor.emitPythonSignal( 'component.added', self.target, self.previousParent )	
end


--------------------------------------------------------------------
CLASS: CmdCloneActor ( candy_edit.EditorCommand )
	:register( 'scene_editor/clone_actor' )

function CmdCloneActor:init( option )
	local targets = getTopLevelActorSelection()
	self.targets = targets
	self.created = false
	if not next( targets ) then return false end
end

function CmdCloneActor:redo()
	local createdList = {}
	for _, target in ipairs( self.targets ) do
		if isInstance( target, candy.ActorGroup ) then
			candy_edit.alertMessage( 'todo', 'Group clone not yet implemented', 'info' )
			return false
		else
			local created = candy.copyAndPasteActor( target, generateGUID )
			makeNumberProfix( editor.scene, created )
			local parent = target.parent
			if parent then
				parent:addChild( created )
			else
				editor.scene:addActor( created, nil, target._actorGroup )
			end		
			candy_editor.emitPythonSignal( 'actor.added', created, 'clone' )
			table.insert( createdList, created )
		end
	end
	candy_editor.changeSelection( 'scene', unpack( createdList ) )
	self.createdList = createdList
end

function CmdCloneActor:undo()
	--todo:
	for i, created in ipairs( self.createdList ) do
		created:destroyWithChildrenNow()
		candy_editor.emitPythonSignal('actor.removed', created )
	end
	self.createdList = false
end

--------------------------------------------------------------------
CLASS: CmdPasteActor ( candy_edit.EditorCommand )
	:register( 'scene_editor/paste_actor' )

function CmdPasteActor:init( option )
	self.data   = decodeJSON( option['data'] )
	self.parent = candy_editor.getSelection( 'scene' )[1] or false
	self.createdList = false
	if not self.data then _error( 'invalid actor data' ) return false end
end

function CmdPasteActor:redo()
	local createdList = {}
	local parent = self.parent
	for i, copyData in ipairs( self.data.actors ) do
		local actorData = candy.makeActorPasteData( copyData, generateGUID )
		local created = candy.deserializeActor( actorData )
		if parent then
			parent:addChild( created )
		else
			editor.scene:addActor( created )
		end		
		candy_editor.emitPythonSignal('actor.added', created, 'paste' )
		table.insert( createdList, created )
	end
	self.createdList = createdList
	candy_editor.changeSelection( 'scene', unpack( createdList ) )
end

function CmdPasteActor:undo()
	--todo:
	for i, created in ipairs( self.createdList ) do
		created:destroyWithChildrenNow()
		candy_editor.emitPythonSignal('actor.removed', created )
	end
	self.createdList = false
end


--------------------------------------------------------------------
CLASS: CmdReparentActor ( candy_edit.EditorCommand )
	:register( 'scene_editor/reparent_actor' )

function CmdReparentActor:init( option )
	local mode = option[ 'mode' ] or 'child'
	if mode == 'sibling' then
		self.target   = option['target']:getParentOrGroup()
	else
		self.target   = option['target']
	end
	self.children = candy_edit.getTopLevelActorSelection()
	self.oldParents = {}
	local targetIsActor = isInstance( self.target, candy.Actor )
	for i, e in ipairs( self.children ) do
		if isInstance( e, candy.ActorGroup ) and targetIsActor then
			--candy_editor.alertMessage( 'fail', 'cannot make Group child of Actor', 'info' )
			return false
		end
	end
end

function CmdReparentActor:redo()
	local target = self.target
	for i, e in ipairs( self.children ) do
		if isInstance( e, candy.Actor ) then
			self:reparentActor( e, target )
		elseif isInstance( e, candy.ActorGroup ) then
			self:reparentActorGroup( e, target )
		end
	end	
end

function CmdReparentActor:reparentActorGroup( group, target )
	local targetGroup = false
	if target == 'root' then
		targetGroup = editor.scene:getRootGroup()

	elseif isInstance( target, candy.ActorGroup ) then
		targetGroup = target

	else
		error()		
	end

	group:reparent( targetGroup )
end

function CmdReparentActor:reparentActor( e, target )
	e:forceUpdate()
	local tx, ty ,tz = e:getWorldLoc()
	local sx, sy ,sz = e:getWorldScl()
	local rz = e:getWorldRot()
	
	--TODO: world rotation X,Y	
	if target == 'root' then
		e:setLoc( tx, ty, tz )
		e:setScl( sx, sy, sz )
		e:setRotZ( rz )
		e:reparent( nil )
		e:reparentGroup( editor.scene:getRootGroup() )

	elseif isInstance( target, candy.ActorGroup ) then
		e:setLoc( tx, ty, tz )
		e:setScl( sx, sy, sz )
		e:setRotZ( rz )
		e:reparent( nil )
		e:reparentGroup( target )

	else
		target:forceUpdate()
		local x, y, z = target:worldToModel( tx, ty, tz )
		
		local sx1, sy1, sz1 = target:getWorldScl()
		sx = ( sx1 == 0 ) and 0 or sx/sx1
		sy = ( sy1 == 0 ) and 0 or sy/sy1
		sz = ( sz1 == 0 ) and 0 or sz/sz1
		

		local rz1 = target:getWorldRot()
		rz = rz1 == 0 and 0 or rz/rz1
		e:setLoc( x, y, z )
		e:setScl( sx, sy, sz )
		e:setRotZ( rz )
		e:reparent( target )
	end

end

function CmdReparentActor:undo()
	--todo:
	_error( 'NOT IMPLEMENTED' )
end

--------------------------------------------------------------------
local function saveActorToPrefab( actor, prefabFile )
	local data = candy.serializeActor( actor )
	local str  = encodeJSON( data )
	local file = io.open( prefabFile, 'wb' )
	if file then
		file:write( str )
		file:close()
	else
		_error( 'can not write to scene file', prefabFile )
		return false
	end
	return true
end

local function reloadPrefabActor( actor )
	local guid = actor.__guid
	local prefabPath = actor.__prefabId

	--Just recreate entity from prefab
	local prefab, node = candy.loadAsset( prefabPath )
	if not prefab then return false end
	local newActor = prefab:createInstance()
	--only perserve location?
	newActor:setLoc( actor:getLoc() )
	newActor:setName( actor:getName() )
	newActor:setLayer( actor:getLayer() )
	newActor.__guid = guid
	newActor.__prefabId = prefabPath
	--TODO: just marked as deleted
	actor:addSibling( newActor )
	actor:destroyWithChildrenNow()	
end

--------------------------------------------------------------------
CLASS: CmdCreatePrefab ( candy_edit.EditorCommand )
	:register( 'scene_editor/create_prefab' )

function CmdCreatePrefab:init( option )
	self.prefabFile = option['file']
	self.prefabPath = option['prefab']
	self.entity     = option['entity']
end

function CmdCreatePrefab:redo()
	if saveActorToPrefab( self.entity, self.prefabFile ) then
		self.entity.__prefabId = self.prefabPath
		return true
	else
		return false
	end
end

--------------------------------------------------------------------
CLASS: CmdCreatePrefabEntity ( CmdCreateActorBase )
	:register( 'scene_editor/create_prefab_entity' )

function CmdCreatePrefabEntity:init( option )
	CmdCreateActorBase.init( self, option )
	self.prefabPath = option['prefab']
end

function CmdCreatePrefabEntity:createActor()
	local prefab, node = mock.loadAsset( self.prefabPath )
	if not prefab then return false end
	return prefab:createInstance()
end

--------------------------------------------------------------------
CLASS: CmdUnlinkPrefab ( candy_edit.EditorCommand )
	:register( 'scene_editor/unlink_prefab' )

function CmdUnlinkPrefab:init( option )
	self.entity     = option['entity']
	self.prefabId = self.entity.__prefabId
end

function CmdUnlinkPrefab:redo()
	self.entity.__prefabId = nil
	candy_editor.emitPythonSignal( 'prefab.unlink', self.entity )
end

function CmdUnlinkPrefab:undo()
	self.entity.__prefabId = self.prefabId --TODO: other process
	candy_editor.emitPythonSignal( 'prefab.relink', self.entity )
end


--------------------------------------------------------------------
CLASS: CmdPushPrefab ( candy_edit.EditorCommand )
	:register( 'scene_editor/push_prefab' )

function CmdPushPrefab:init( option )
	self.entity     = option['entity']
end

function CmdPushPrefab:redo()
	local entity = self.entity
	local prefabPath = entity.__prefabId
	local node = mock.getAssetNode( prefabPath )
	local filePath = node:getAbsObjectFile( 'def' )
	if saveActorToPrefab( entity, filePath ) then
		candy_editor.emitPythonSignal( 'prefab.push', entity )
		--Update all entity in current scene
		local scene = entity.scene
		local toReload = {}
		for e in pairs( scene.entities ) do
			if e.__prefabId == prefabPath and e~=entity then
				toReload[ e ] = true
			end
		end
		for e in pairs( toReload ) do
			reloadPrefabActor( e )
		end
	else
		return false
	end
end

--------------------------------------------------------------------
CLASS: CmdPullPrefab ( candy_edit.EditorCommand )
	:register( 'scene_editor/pull_prefab' )

function CmdPullPrefab:init( option )
	self.entity     = option['entity']
end

function CmdPullPrefab:redo()
	reloadPrefabActor( self.entity )
	candy_editor.emitPythonSignal( 'prefab.pull', self.newEntity )
	--TODO: reselect it ?
end

--------------------------------------------------------------------
CLASS: CmdCreatePrefabContainer ( CmdCreateActorBase )
	:register( 'scene_editor/create_prefab_container' )

function CmdCreatePrefabContainer:init( option )
	CmdCreateActorBase.init( self, option )
	self.prefabPath = option['prefab']
end

function CmdCreatePrefabContainer:createActor()
	local container = mock.PrefabContainer()
	container:setPrefab( self.prefabPath )
	return container	
end

--------------------------------------------------------------------
CLASS: CmdMakeProto ( candy_edit.EditorCommand )
	:register( 'scene_editor/make_proto' )

function CmdMakeProto:init( option )
	self.entity = option['entity']
end

function CmdMakeProto:redo()
	self.entity.FLAG_PROTO_SOURCE = true
end

function CmdMakeProto:undo()
	self.entity.FLAG_PROTO_SOURCE = false
end


--------------------------------------------------------------------
CLASS: CmdCreateProtoInstance ( CmdCreateActorBase )
	:register( 'scene_editor/create_proto_instance' )

function CmdCreateProtoInstance:init( option )
	CmdCreateActorBase.init( self, option )
	self.protoPath = option['proto']
end

function CmdCreateProtoInstance:createActor()
	local proto = mock.loadAsset( self.protoPath )
	local id    = generateGUID()
	local instance = proto:createInstance( nil, id )
	instance.__overrided_fields = {
		[ 'loc' ] = true,
		[ 'name' ] = true,
	}
	makeNumberProfix( editor.scene, instance )
	return instance
end


--------------------------------------------------------------------
CLASS: CmdCreateProtoContainer ( CmdCreateActorBase )
	:register( 'scene_editor/create_proto_container' )

function CmdCreateProtoContainer:init( option )
	CmdCreateActorBase.init( self, option )
	self.protoPath = option['proto']
end

function CmdCreateProtoContainer:createActor()
	local proto = mock.loadAsset( self.protoPath )
	local name = proto:getRootName()
	print( 'proto name', name )
	local container = mock.ProtoContainer()
	container:setName( name )
	container.proto = self.protoPath
	makeNumberProfix( editor.scene, container )
	return container
end

--------------------------------------------------------------------
CLASS: CmdUnlinkProto ( candy_edit.EditorCommand )
	:register( 'scene_editor/unlink_proto' )

function CmdUnlinkProto:_retainAndClearComponentProtoState( entity, data )
	for com in pairs( entity.components ) do
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

function CmdUnlinkProto:_retainAndClearChildProtoState( entity, data )
	if entity.PROTO_INSTANCE_STATE then return end
	if not entity.__proto_history then return end
	data[ entity ] = {
		overrided = entity.__overrided_fields,
		history   = entity.__proto_history,
	}
	entity.__overrided_fields = nil
	entity.__proto_history = nil
	self:_retainAndClearComponentProtoState( entity, data )
	for child in pairs( entity.children ) do
		self:_retainAndClearChildProtoState( child, data )
	end
end

function CmdUnlinkProto:_retainAndClearEntityProtoState( root, data )
	data = data or {}
	if root.PROTO_INSTANCE_STATE then
		data[ root ] = {
			overrided = root.__overrided_fields,
			history   = root.__proto_history,
			state     = root.PROTO_INSTANCE_STATE
		}
		for child in pairs( root.children ) do
			self:_retainAndClearChildProtoState( child, data )
		end
		self:_retainAndClearComponentProtoState( root, data )
		root.__overrided_fields   = nil
		root.__proto_history      = nil
		root.PROTO_INSTANCE_STATE = nil
	end
	return data
end

function CmdUnlinkProto:_restoreEntityProtoState( root, data )
	for ent, retained in pairs( data ) do
		if retained.state then
			ent.PROTO_INSTANCE_STATE = retained.state
		end
		ent.__overrided_fields = retained.overrided
		ent.__proto_history = retained.history
	end
end
--TODO
function CmdUnlinkProto:init( option )
	self.entity     = option['entity']
end

function CmdUnlinkProto:redo()	
	self.retainedState =  self:_retainAndClearEntityProtoState( self.entity )
	candy_editor.emitPythonSignal( 'proto.unlink', self.entity )
	candy_editor.emitPythonSignal( 'actor.modified', self.entity )
end

function CmdUnlinkProto:undo()
	self:_restoreEntityProtoState( self.retainedState )
	candy_editor.emitPythonSignal( 'proto.relink', self.entity )
	candy_editor.emitPythonSignal( 'actor.modified', self.entity )
end


--------------------------------------------------------------------
CLASS: CmdAssignActorLayer ( candy_edit.EditorCommand )
	:register( 'scene_editor/assign_layer' )

function CmdAssignActorLayer:init( option )
	self.layerName = option['target']
	self.actors  = candy_editor.getSelection( 'scene' )	
	self.oldLayers = {}
end

function CmdAssignActorLayer:redo()
	local layerName = self.layerName
	local oldLayers = self.oldLayers
	for i, e in ipairs( self.actors ) do
		oldLayers[ e ] = e:getLayer()
		e:setLayer( layerName )
		candy_editor.emitPythonSignal( 'actor.renamed', e, '' )
	end	
end

function CmdAssignActorLayer:undo()
	local oldLayers = self.oldLayers
	for i, e in ipairs( self.actors ) do
		layerName = oldLayers[ e ]
		e:setLayer( layerName )
		candy_editor.emitPythonSignal( 'actor.renamed', e, '' )
	end	
end

--------------------------------------------------------------------
CLASS: CmdToggleActorVisibility ( candy_edit.EditorCommand )
	:register( 'scene_editor/toggle_actor_visibility' )

function CmdToggleActorVisibility:init( option )
	local target = option[ 'target' ]
	if target then
		self.actors = { target }
	else
		self.actors  = candy_editor.getSelection( 'scene' )
	end
	self.originalVis  = {}
end

function CmdToggleActorVisibility:redo()
	local vis = false
	local originalVis = self.originalVis
	for i, e in ipairs( self.actors ) do
		originalVis[ e ] = e:isLocalVisible()
		if e:isLocalVisible() then vis = true end
	end	
	vis = not vis
	for i, e in ipairs( self.actors ) do
		e:setVisible( vis )
		--candy.markProtoInstanceOverrided( e, 'visible' )
		candy_editor.emitPythonSignal( 'actor.visible_changed', e )
		candy_editor.emitPythonSignal( 'actor.modified', e, '' )
	end
end

function CmdToggleActorVisibility:undo()
	local originalVis = self.originalVis
	for i, e in ipairs( self.entities ) do
		e:setVisible( originalVis[ e ] )
		candy_editor.emitPythonSignal( 'actor.modified', e, '' )
	end	
	self.originalVis  = {}
end


--------------------------------------------------------------------
CLASS: CmdToggleActorLock ( candy_edit.EditorCommandNoHistory )
	:register( 'scene_editor/toggle_actor_lock' )

function CmdToggleActorLock:init( option )
	local target = option[ 'target' ]
	if target then
		self.actors = { target }
	else
		self.actors  = candy_editor.getSelection( 'scene' )
	end

	local locked = false
	for i, e in ipairs( self.actors ) do
		if e:isLocalEditLocked() then locked = true break end
	end	
	locked = not locked
	for i, e in ipairs( self.actors ) do
		e:setEditLocked( locked )
		candy_editor.emitPythonSignal( 'actor.visible_changed', e )
		candy_editor.emitPythonSignal( 'actor.modified', e, '' )
	end
end

--------------------------------------------------------------------
CLASS: CmdUnifyChildrenLayer ( candy_edit.EditorCommand )
	:register( 'scene_editor/unify_children_layer' )

function CmdUnifyChildrenLayer:init( option )
	--TODO
end

function CmdUnifyChildrenLayer:redo( )
	--TODO
end

function CmdUnifyChildrenLayer:undo( )
	--TODO
end

--------------------------------------------------------------------
CLASS: CmdFreezePivot ( candy_edit.EditorCommand )
	:register( 'scene_editor/freeze_actor_pivot' )

function CmdFreezePivot:init( option )
	self.actors  = candy_editor.getSelection( 'scene' )
	self.previousPivots = {}
end

function CmdFreezePivot:redo( )
	local pivots = self.previousPivots
	for i, e in ipairs( self.actors ) do
		local px, py, pz = e:getPiv()
		e:setPiv( 0,0,0 )
		e:addLoc( -px, -py, -pz )
		-- for child in pairs( e:getChildren() ) do
		-- 	child:addLoc( -px, -py, -pz )
		-- end
		candy_editor.emitPythonSignal( 'actor.modified', e, '' )
	end
end

function CmdFreezePivot:undo( )
	--TODO
end



--------------------------------------------------------------------
CLASS: CmdActorGroupCreate ( candy_edit.EditorCommand )
	:register( 'scene_editor/actor_group_create')


function CmdActorGroupCreate:init( option )
	local contextActor = candy_editor.getSelection( 'scene' )[1]
	
	if isInstance( contextActor, candy.Actor ) then
		if not contextActor._actorGroup then
			candy_edit.alertMessage( 'fail', 'cannot create Group inside Actor', 'info' )
			return false
		end
		self.parentGroup = contextActor._actorGroup
	elseif isInstance( contextActor, candy.ActorGroup ) then
		self.parentGroup = contextActor
	else
		self.parentGroup = editor.scene:getRootGroup()
	end

	self.guid = generateGUID()
end

function CmdActorGroupCreate:redo()
	self.createdGroup = candy.ActorGroup()
	self.parentGroup:addChildGroup( self.createdGroup )
	self.createdGroup.__guid = self.guid
	candy_editor.emitPythonSignal( 'actor.added', self.createdGroup, 'new' )
end

function CmdActorGroupCreate:undo()
	--TODO
	self.parentGroup:removeChildGroup( self.createdGroup )
end


--------------------------------------------------------------------
CLASS: CmdGroupActors ( candy_edit.EditorCommand )
	:register( 'scene_editor/group_actors')

function CmdGroupActors:init( option )
	--TODO:!!!
	local contextActor = candy_editor.getSelection( 'scene' )[1]
	if isInstance( contextActor, candy.Actor ) then
		if not contextActor._actorGroup then
			candy_edit.alertMessage( 'fail', 'cannot create Group inside Actor', 'info' )
			return false
		end
		self.parentGroup = contextActor._actorGroup
	elseif isInstance( contextActor, candy.ActorGroup ) then
		self.parentGroup = contextActor
	else
		self.parentGroup = editor.scene:getRootGroup()
	end

	self.guid = generateGUID()

end

function CmdGroupActors:redo()
	self.createdGroup = candy.ActorGroup()
	self.parentGroup:addChildGroup( self.createdGroup )
	self.createdGroup.__guid = self.guid
	candy_editor.emitPythonSignal( 'actor.added', self.createdGroup, 'new' )
end

function CmdGroupActors:undo()
	--TODO
	self.parentGroup:removeChildGroup( self.createdGroup )
end


--------------------------------------------------------------------
CLASS: CmdSelectScene ( candy_edit.EditorCommandNoHistory )
	:register( 'scene_editor/select_scene')


function CmdSelectScene:init( option )
	return candy_editor.changeSelection( 'scene', editor.scene )
end


--------------------------------------------------------------------
CLASS: CmdAlignEntities ( candy_edit.EditorCommand )
	:MODEL{}

function CmdAlignEntities:init( option )
	local targets = getTopLevelActorSelection()
	local mode = option['mode']
	self.targets = targets
	if not mode then return false end
	if not next( targets ) then return false end
end

function CmdAlignEntities:redo()
end

function CmdAlignEntities:undo()
	--TODO:undo
end
