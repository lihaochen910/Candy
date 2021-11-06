-- import
local Actor = require 'candy.Actor'

-- module
local EntityModule = {}

-- import
local insert = table.insert
local remove = table.remove
local sort = table.sort
local pairs = pairs
local ipairs = ipairs
local unpack = unpack
local next = next
local type = type
local weakt = table.weak
local SignalModule = require 'candy.signal'

---@class Entity : Actor
local Entity = CLASS: Entity ( Actor )
	:MODEL {
		Field 'name'		:string()   :getset('Name');
		Field '_fullname'	:string() 	:get('getFullName') :no_edit();
		Field 'visible'		:boolean() 	:get('isLocalVisible') :set('setVisible');
		-- Field 'active'    :boolean() :get('isLocalActive')  :set('setActive');		
		Field 'layer'		:type('layer')  :getset('Layer') :no_nil();
	}
	
wrapWithMoaiPropMethods ( Entity, '_prop' )

local _PRIORITY = 1
function Entity:__init ()
	self.name = 'Entity'

	self.active = true
	self.localActive = true
	self.suspendCount = 0

	self.msgListeners = {}
	self.coroutines = false

	self.scene = false ---@type Scene
	-- self.rootComponent = false
	self.components = {}
	self.children = {}
	self.parent = false

	self.layer = false

	self._entityGroup = false ---@type EntityGroup

	self._prop = self:_createEntityProp () -- _prop字段存放Entity的transform信息
	_PRIORITY = _PRIORITY + 1
	self._priority = _PRIORITY
	self._editLocked = false

	self._comCache = {}

	self._maxComponentID = 0
end

function Entity:__tostring ()
	return string.format ( "%s%s @%s", self:__repr (), self:getFullName () or "???", tostring ( self:getSceneSessionName () ) )
end

local setupMoaiTransform = setupMoaiTransform
Entity.__accept = false
-- local newProp = MOCKProp.new
local newProp = MOAIGraphicsProp.new
function Entity:_createEntityProp ()
	return newProp ()
end

function Entity:_createTransformProxy ()
	return false
end

--- 当此Entity添加到Scene时调用
function Entity:onLoad ()
end

--- 当此Entity销毁时调用
function Entity:onDestroy ()
end

--- 当此Entity挂起时调用
function Entity:onSuspend ()
end

function Entity:onResurrect ()
end

--- 当Scene每帧更新时调用
---@param dt number
function Entity:onUpdate ( dt )
	-- if self.rootComponent then self.rootComponent:_onUpdate ( dt ) end

	-- for child in pairs ( self.children ) do
	-- 	child:onUpdate ( dt )
	-- end
end

function Entity:getName ()
	return self.name
end

function Entity:setName ( name )
	self.name = name
end

function Entity:getTime ()
	return candy.game:getTime ()
end

function Entity:getScene ()
	return self.scene
end

function Entity:getSceneSession ()
	local scene = self.scene
	return scene and scene:getSession ()
end

function Entity:getSceneSessionName ()
	local scene = self.scene
	return scene and scene:getSessionName ()
end

function Entity:getProp ()
	return self._prop
end

function Entity.getParentOrGroup ( entityInstance ) --for editor, return parent entity or group
	return entityInstance.parent or entityInstance._entityGroup
end

--- 获取Entity所在的Group
---@param searchParent boolean 搜索时是否包含父节点
---@return EntityGroup
function Entity:getEntityGroup ( searchParent )
	if searchParent ~= false then
		local p = self
		while p do
			local group = p._entityGroup
			if group then return group end
			p = p.parent
		end
		return false
	else
		return self._entityGroup
	end
end

--- 获取Entity执行的ActionRoot
--- 默认返回所在Scene的ActionRoot
---@return MOAIAction
function Entity:getActionRoot ()
	if self.scene then
		return self.scene:getActionRoot ()
	end
	return nil
end

function Entity:getFullName ()
	if not self.name then return false end
	local output = self.name
	local n0 = self
	local n = n0.parent
	while n do
		output = ( n.name or '<noname>' ) .. '/' .. output
		n0 = n
		n = n0.parent
	end
	if n0._entityGroup and not n0._entityGroup:isRootGroup () then
		local groupName = n0._entityGroup:getFullName ()
		return groupName .. '::' .. output
	end
	return output
end

function Entity:getComponentInfo ()
	if self._componentInfo then
		return self._componentInfo
	else
		local info = false
		for i, com in ipairs ( self:getSortedComponentList () ) do
			if not com.FLAG_INTERNAL then
				if com.FLAG_EDITOR_OBJECT then
					-- Nothing
				else
					local name = com:getClassName ()
					if info then
						info = info .. "," .. name
					else
						info = name
					end
				end
			end
		end

		self._componentInfo = info

		return info
	end
end

--------------------------------------------------------------------
------ Active control
--------------------------------------------------------------------
function Entity:isSuspended ()
	return self.suspendCount > 0
end

function Entity:suspend ()
	local count1 = self.suspendCount + 1
	self.suspendCount = count1

	if count1 > 1 then
		return
	end

	self:onSuspend ()

	for i, com in ipairs ( self:getSortedComponentList () ) do
		if com._entity then
			local state = com._suspendState

			if not state then
				state = {}
				com._suspendState = state
			end

			if not com.onSuspend then
				print ( com )
			end

			com:onSuspend ( state )
		end
	end

	for child in pairs ( self.children ) do
		child:suspend ()
	end
end

function Entity:resurrect ()
	local count0 = self.suspendCount

	assert ( count0 > 0 )

	local count1 = count0 - 1
	self.suspendCount = count1

	if count1 == 0 then
		self:onResurrect ()

		for i, com in ipairs ( self:getSortedComponentList () ) do
			if com._entity then
				com:onResurrect ( com._suspendState )
			end

			com._suspendState = false
		end

		for child in pairs ( self.children ) do
			child:resurrect ()
		end
	end
end

function Entity:start ()
	if self.started then return end
	if not self.scene then return end
	
	if self.onStart then
		self:onStart ()
	end
	self.started = true

	-- local copy = {} --there might be new components attached inside component starting
	-- for com in pairs( self.components ) do
	-- 	copy[ com ] = true
	-- end
	-- for com, clas in pairs( copy ) do
	-- 	local onStart = com.onStart
	-- 	if onStart then onStart( com, self ) end
	-- end

	for i, com in ipairs ( self:getSortedComponentList () ) do
		if com._entity then
			local onStart = com.onStart
			if onStart then onStart( com, self ) end
		end
	end

	for child in pairs ( self.children ) do
		child:start ()
	end

	if self.onThread then
		self:addCoroutine ( 'onThread' )
	end
	
end

function Entity:setActive ( active , selfOnly )
	active = active or false
	if active == self.localActive then return end
	self.localActive = active
	self:_updateGlobalActive ( selfOnly )
end

function Entity:_updateGlobalActive ( selfOnly )
	local active = self.localActive
	local p = self.parent
	if p then
		active = p.active and active
		self.active = active
	else
		self.active = active
	end

	--inform components
	-- for com in pairs(self.components) do
	-- 	local setActive = com.setActive
	-- 	if setActive then
	-- 		setActive( com, active )
	-- 	end
	-- end

	--inform children
	selfOnly = selfOnly or false
	if not selfOnly then
		for c in pairs ( self.children ) do
			c:_updateGlobalActive ()
		end
	end

	local onSetActive = self.onSetActive
	if onSetActive then
		return onSetActive( self, active )
	end
end

function Entity:isStarted ()
	return self.started
end

function Entity:isActive ()
	return self.active
end

function Entity:isLocalActive ()
	return self.localActive
end

--------------------------------------------------------------------
------ Destructor
--------------------------------------------------------------------
--- 尝试销毁此Entity
---@return boolean
function Entity:tryDestroy ()
	if not self.scene then
		return false
	end

	return self:destroy ()
end

--- 销毁此Entity
--- 仅在此Entity已经添加到Scene的情况下可以调用
---@return boolean
function Entity:destroy ()
    assert ( self.scene )

    local scene = self.scene
    scene.pendingDestroy[ self ] = true
    scene.pendingStart[ self ] = nil
    
    for child in pairs ( self.children ) do
        child:destroy ()
    end

    if self.name then
		scene:changeEntityName ( self, self.name, nil )
    end

    return true
end

--- 在一段延迟后销毁此Entity
--- 仅在此Entity已经添加到Scene的情况下可以调用
---@param delay number
function Entity:destroyLater ( delay )
	assert ( self.scene )
	self.scene.laterDestroy[ self ] = self.getTime () + delay
end

--- 在当前帧销毁此Entity, 不包含子节点
---@return boolean
function Entity:_destroyNow ()
	local scene = self.scene
	if not scene then return end

	self:disconnectAll ()
	self:clearCoroutines ()

	local entityListener = scene.entityListener
	local timers = self.timers

	if timers then
		for timer in pairs ( timers ) do
			timer:stop ()
		end
	end

	if self.onDestroy then self:onDestroy ( self ) end

	local components = self.components
	for i, com in ipairs ( self:getSortedComponentList ( 'reversed' ) ) do
		components[ com ] = nil
		local onDetach = com.onDetach
		if entityListener then
			entityListener ( 'detach', self, com )
		end
		if onDetach then
			onDetach ( com, self )
		end
		com._entity = nil
    end
    
	local parent = self.parent
	if parent then
		parent:_detachChildEntity ( self )
		parent.children[ self ] = nil
		parent = nil
	end

	if self._entityGroup then
		self._entityGroup:removeEntity ( self )
	end
	
	scene:removeUpdateListener ( self )
	scene.entities[ self ] = nil
	scene.entityCount = scene.entityCount - 1
	
	--callback
	if entityListener then entityListener ( 'remove', self, scene ) end

	self.scene = false
	self.components = false

	if self._tag then
		self._tag.owner = false
		self._tag = nil
	end
end

--- 在当前帧销毁此Entity, 及其子节点
---@return boolean
function Entity:destroyWithChildrenNow ()
    for child in pairs ( self.children ) do
        child:destroyWithChildrenNow ()
    end
    self:_destroyNow ()
end

--------------------------------------------------------------------
-- Child
--------------------------------------------------------------------
---
-- 将此entity实例添加到给定scene中.
---@param scene(candy.Scene) Scene
---@param layer(candy.Layer) Layer
function Entity:_insertIntoScene ( scene, layer )
    self.scene = assert ( scene )

    local layer = layer or self.layer
    if type ( layer ) == 'string' then
        layer = scene:getLayer ( layer )
    end
    self.layer = layer
    
	local entityListener = scene.entityListener
    scene.entities[ self ] = true
	scene.entityCount = scene.entityCount + 1

	if self.parent then
		self.parent:_attachChildEntity ( self, layer )
	end

	if next ( self.children ) then
		local children = self:getSortedChildrenList ()

		for i, child in ipairs ( children ) do
			if not child.scene then
				child:_insertIntoScene ( scene, child.layer or layer )
			end
		end
	end

    for i, com in ipairs ( self:getSortedComponentList () ) do
        if not com._entity then
            com._entity = self
			local onAttach = com.onAttach
			-- EntityComponent Callback
			if onAttach then onAttach ( com, self ) end
			-- Scene EntityListener Callback
            if entityListener then entityListener ( 'attach', self, com ) end
        end
    end

    if self.onLoad then
        self:onLoad ()
    end

    if self.onUpdate then
        scene:addUpdateListener ( self )
    end

    local onMsg = self.onMsg
    if onMsg then
        self:addMsgListener ( function ( msg, data, src )
            return onMsg ( self, msg, data, src )
        end )
    end
    
    if self.name then
        scene:changeEntityName ( self, false, self.name )
    end

    scene.pendingStart[ self ] = true
    
    --callback
    if entityListener then entityListener ( 'add', self, nil ) end
end

--- 与给定的child建立联系, 继承transform、color、Visible、ScissorRect属性
--- 子类可以重写此方法
---@param child Entity
---@param layer Entity
function Entity:_attachChildEntity ( child, layer )
	local _prop = self._prop
	local _p1 = child._prop
	inheritTransformColorVisible ( _p1, _prop )

	if not child._scissorRect then
		linkScissorRect ( _p1, _prop )
	else
		local rect = self._scissorRect
		child:relinkScissorRect ( rect or self:getParentScissorRect () )
	end
end

--- 与给定的child断开联系
--- 子类可以重写此方法
---@param child Entity
function Entity:_detachChildEntity ( child )
	local _p1 = child._prop
	clearInheritTransform ( _p1 )
	clearInheritColor ( _p1 )
	clearInheritVisible ( _p1 )
	clearLinkScissorRect ( _p1 )
end

--- 添加给定的child作为子节点
---@param entity Entity
---@param layerName string
---@return Entity
function Entity:addChild ( entity, layerName )
	self.children[ entity ] = true
	entity.parent = self
	entity.layer = layerName or entity.layer or self.layer

	local scene = self.scene

	if scene then
		entity:_insertIntoScene ( scene )
	end
	
	return entity
end

function Entity:addInternalChild ( e, layer )
	e.FLAG_INTERNAL = true
	return self:addChild ( e, layer )
end

function Entity:isInternal ()
	return self.FLAG_INTERNAL
end

function Entity:addSubEntity ( e )
	e.FLAG_INTERNAL = true
	e.FLAG_SUBENTITY = true
	return self:addChild ( e )
end

function Entity:isSubEntity ()
	return self.FLAG_SUBENTITY
end

function Entity:isChildOf ( e )
	local parent = self.parent

	while parent do
		if parent == e then
			return true
		end
		parent = parent.parent
	end

	return false
end

function Entity:isParentOf ( e )
	return e:isChildOf ( self )
end

function Entity:hasChild ( e )
	return e:isChildOf ( self )
end

function Entity:getChildren ()
	return self.children
end

function Entity:getChildCount ()
	return table.len ( self.children )
end

local function entitySortFunc ( a, b )
	return ( a._priority or 0 ) < ( b._priority or 0 )
end

local function entitySortFuncReversed ( b, a )
	return ( a._priority or 0 ) > ( b._priority or 0 )
end

function Entity:getSortedChildrenList ( reversed )
	local children = self.children
	if not children then
		return false
	end

	local l = table.keys ( children )
	if reversed then
		sort ( l, entitySortFuncReversed )
	else
		sort ( l, entitySortFunc )
	end

	return l
end

function Entity:clearChildren ()
	local children = self.children

	while true do
		local child = next ( children )
		if not child then
			return
		end

		children[ child ] = nil
		child:destroy ()
	end
end

function Entity:clearChildrenNow ()
	local children = self.children

	while true do
		local child = next ( children )

		if not child then
			return
		end

		children[ child ] = nil
		child:destroyWithChildrenNow ()
	end
end

function Entity:getParent ()
	return self.parent
end

function Entity:getParentOrGroup ()
	return self.parent or self._entityGroup
end

--- 向此Entity的父节点(如果有)添加Entity
---@param entity Entity
---@param layerName string
function Entity:addSibling ( entity, layerName )
	if self.parent then
		return self.parent:addChild ( entity, layerName )
	else
		return self.scene:addEntity ( entity, layerName )
	end
end

--- 向此Entity所在的Scene添加Entity
---@param entity Entity
---@param layerName string
function Entity:addRootEntity ( entity, layerName )
	return self.scene:addEntity ( entity, layerName )
end

--- 变更所在EntityGroup
---@param group EntityGroup
function Entity:reparentGroup ( group )
	if self._entityGroup then
		self._entityGroup:removeEntity ( self )
	end
	if group then
		group:addEntity ( self )
	end
end

---
-- Sets the object's parent, inheriting its color and transform.
-- 注意必须在此Entity已添加到Scene中时调用
---@param entity Entity | nil parent
function Entity:reparent ( entity )
	--assert this entity is already inserted
	assert ( self.scene, 'invalid usage of reparent' )
	local parent0 = self.parent
	if parent0 then
		parent0.children[ self ] = nil
		parent0:_detachChildEntity ( self )
	end
	self.parent = entity
	if entity then
		self:reparentGroup ( nil )
		entity.children[ self ] = true
		entity:_attachChildEntity ( self )
	end
end

function Entity:findChildByClass ( clas, deep )
	for child in pairs ( self.children ) do
		if child:isInstance ( clas ) then return child end
		if deep then
			local c = child:findChildByClass ( clas, deep )
			if c then return c end
		end
	end
	return nil
end

function Entity:findChildByPath ( path )
	local a = self
	for part in string.gsplit ( path, '/' ) do
		a = a:findChild ( part, false )
		if not a then return nil end
	end
	return a
end

function Entity:findEntity ( name )
	return self.scene:findEntity ( name )
end

function Entity:findEntityCom ( entName, comId )
	local ent = self:findEntity ( entName )

	if ent then
		return ent:com ( comId )
	end

	return nil
end

function Entity:findSibling ( name )
	local parent = self.parent

	if not parent then
		return nil
	end

	for child in pairs ( parent.children ) do
		if child.name == name and child ~= self then
			return child
		end
	end

	return nil
end

function Entity:findChildCom ( name, comId, deep )
	local ent = self:findChild ( name, deep )

	if ent then
		return ent:com ( comId )
	end

	return nil
end

function Entity:findParent ( name )
	local p = self.parent

	while p do
		if p.name == name then
			return p
		end

		p = p.parent
	end

	return nil
end

function Entity:findParentOf ( typeName )
	local p = self.parent

	while p do
		if p:isInstance ( typeName ) then
			return p
		end
		p = p.parent
	end

	return nil
end

function Entity:findParentWithComponent ( comType )
	local p = self.parent

	while p do
		if p:hasComponent ( comType ) then
			return p
		end
		p = p.parent
	end

	return nil
end

function Entity:findChild ( name, deep )
	for child in pairs ( self.children ) do
		if child.name == name then
			return child
		end

		if deep then
			local c = child:findChild ( name, deep )

			if c then
				return c
			end
		end
	end

	return nil
end

function Entity:findChildByClass ( clas, deep )
	for child in pairs ( self.children ) do
		if child:isInstance ( clas ) then
			return child
		end

		if deep then
			local c = child:findChildByClass ( clas, deep )

			if c then
				return c
			end
		end
	end

	return nil
end

function Entity:findChildByPath ( path )
	local e = self

	for part in string.gsplit ( path, "/" ) do
		e = e:findChild ( part, false )

		if not e then
			return nil
		end
	end

	return e
end

function Entity:findEntityByPath ( path )
	local e = false

	for part in string.gsplit ( path, "/" ) do
		if not e then
			e = self:findEntity ( part )
		else
			e = e:findChild ( part, false )
		end

		if not e then
			return nil
		end
	end

	return e
end

function Entity:foreachChild ( func, deep )
	for child in pairs ( self.children ) do
		local res = func ( child )

		if res == "stop" then
			return "stop"
		end

		if res == "out" then
			return
		end

		if deep and res ~= "skip" then
			local res = child:foreachChild ( func, true )

			if res == "stop" then
				return "stop"
			end
		end
	end
end

--------------------------------------------------------------------
-- Component Management
--------------------------------------------------------------------

-- function Entity:getRootComponent ()
-- 	return self.rootComponent
-- end

-- function Entity:setRootComponent ( com )
-- 	local rootComponent = self.rootComponent
-- 	if not com or rootComponent == com then return end

-- 	if rootComponent then
-- 		if rootComponent.parent ~= nil then
-- 			rootComponent.parent.children[ rootComponent ] = nil
-- 		end
-- 		if com.parent ~= nil then
-- 			com.parent.children[ com ] = nil
-- 		end
-- 		rootComponent.parent = com
-- 		rootComponent.isRootComponent = false
-- 		com.children[ rootComponent ] = true
		
-- 		self.rootComponent = com
-- 		com.isRootComponent = true
-- 	else
-- 		self.rootComponent = com
-- 		com.isRootComponent = true
-- 	end
-- end

--- Get the first component of asking type
---@param Class clas the component class to be looked for
---@return Component|nil
function Entity:getComponent ( clas )
    if not self.components then return nil end
    for com, comType in pairs ( self.components ) do
        if comType == clas then return com end
        if isClass ( comType ) and comType:isSubclass ( clas ) then return com end
    end
    return nil
end

function Entity:getComponentByAlias ( alias )
	if not self.components then
		return nil
	end

	for com, comType in pairs ( self.components ) do
		if com._alias == alias then
			return com
		end
	end

	return nil
end

--- Get component by class name
---@param (string) name component class name to be looked for
---@return (Component) the found component
function Entity:getComponentByName ( name )
    if not self.components then return nil end
    for com, comType in pairs ( self.components ) do
        while comType do
            if comType.__name == name then return com end    
            comType = comType.__super
        end
    end
    return nil
end

--- Get the component table [ com ] = Class
---@return the component table
function Entity:getComponents ()
    return self.components
end

function Entity:getComponentByGUID ( guid )
	if not self.components then
		return nil
	end

	for com, comType in pairs ( self.components ) do
		if com.__guid == guid then
			return com
		end
	end

	return nil
end

function Entity:com ( id )
	if not id then
		local components = self.components
		if components then
			return next ( components )
		else
			return nil
		end
	end

	local cache = self._comCache
	local com = cache[ id ]
	if com ~= nil then
		return com
	end

	local tt = type ( id )

	if tt == "string" then
		com = self:getComponentByName ( id ) or false
	elseif tt == "table" then
		com = self:getComponent ( id ) or false
	else
		_error ( "invalid component id", tostring ( id ) )
	end

	cache[ id ] = com
	return com
end

function Entity:hasComponent ( id )
	return self:com ( id ) and true or false
end

function Entity:isOwnerOf ( com )
	local components = self.components

	if not components then
		return nil
	end

	return components[ com ] and true or false
end

function Entity:getAllComponentsOf ( id, searchChildren )
	local result = {}

	local function _collect ( e, typeId, result, deep )
		local components = e.components
		if components then
			local tt = type ( typeId )
			if tt == "string" then
				local clasName = typeId

				for com, comType in pairs ( components ) do
					while comType do
						if comType.__name == clasName then
							insert ( result, com )
							break
						end
						comType = comType.__super
					end
				end
			elseif tt == "table" then
				local clasBody = typeId
				for com, comType in pairs ( components ) do
					if comType == clasBody then
						insert ( result, com )
					elseif isClass ( comType ) and comType:isSubclass ( clasBody ) then
						insert ( result, com )
					end
				end
			end
		end

		if deep then
			for child in pairs ( e.children ) do
				_collect ( child, typeId, result, deep )
			end
		end

		return result
	end

	return _collect ( self, id, {}, searchChildren )
end

function Entity:eachComponent ()
	local list = table.keys ( self:getComponents () )
	return eachT ( list )
end

function Entity:eachComponentOf ( id )
	local list = self:getAllComponentsOf ( id )
	return eachT ( list )
end

function Entity:printComponentClassNames ()
	for com in pairs ( self.components ) do
		print ( com:getClassName () )
	end
end

--- Attach a component to root component node
---@param com Component the component instance to be attached
---@return Component the component attached ( same as the input )
function Entity:attach ( com )
    local components = self.components
    if not components then
        _error ( 'attempt to attach component to a dead entity' )
        return com
    end
    if components[ com ] then
        _log ( self.name, tostring ( self.__guid ), com:getClassName () )
        error ( 'component already attached!!!!' )
    end

    self._componentInfo = nil
    
	if next ( self._comCache ) then
		self._comCache = {}
	end

    local maxId = self._maxComponentID + 1
    self._maxComponentID = maxId
    com._componentID = maxId
	components[ com ] = com:getClass ()
	
	-- if not self:getRootComponent () then
	-- 	self:setRootComponent ( com )
	-- else
	-- 	com:attachTo ( self:getRootComponent () )
	-- end

    if self.scene then
        com._entity = self    
        local onAttach = com.onAttach
        if onAttach then onAttach ( com, self ) end
        for otherCom in pairs ( self.components ) do
            if otherCom ~= com then
                local onOtherAttach = com.onOtherAttach
                if onOtherAttach then
                    onOtherAttach ( otherCom, self, com )
                end
            end
        end
        if self.scene.entityListener then
            self.scene.entityListener ( 'attach', self, com )
        end
        if self.started then
            local onStart = com.onStart
            if onStart then onStart ( com, self ) end
        end
    end
    return com
end

--- Attach an internal component ( invisible in the editor )
---@param Component com the component instance to be inserted
---@return Component the component attached ( same as the input )
function Entity:attachInternal ( com )
    com.FLAG_INTERNAL = true
    return self:attach ( com )
end

--- Attach an array of components
---@param {Component} components an array of components to be attached
function Entity:attachList ( l )
    for i, com in ipairs ( l ) do
        self:attach ( com )
    end
end

--- Detach given component
---@param (Component) com component to be detached
---@param (string) reason reason to detaching
function Entity:detach ( com, reason, _skipDisconnection )
    local components = self.components
    if not components[ com ] then return end
    components[ com ] = nil
    self._componentInfo = nil

    if next ( self._comCache ) then
		self._comCache = {}
	end
	
    if self.scene then
        local entityListener = self.scene.entityListener
        if entityListener then
            entityListener ( 'detach', self, com )
        end

        local onDetach = com.onDetach
        if not _skipDisconnection then
            self:disconnectAllForObject ( com )
        end
        if onDetach then onDetach ( com, self, reason ) end
        for otherCom in pairs ( components ) do
            if otherCom ~= com then
                local onOtherDetach = com.onOtherDetach
                if onOtherDetach then
                    onOtherDetach ( otherCom, self, com )
                end
            end
        end
    end
    com._entity = nil
	com._suspendState = nil
    return com
end

--- Detach all the components
---@param (?string) reason reason to detaching
function Entity:detachAll ( reason )
	local components = self.components
	while true do
		local com = next ( components )
		if not com then break end
		self:detach ( com, reason, true )
	end
end

function Entity:detachAllOf ( comType, reason )
	for i, com in ipairs ( self:getAllComponentsOf ( comType ) ) do
		self:detach ( com, reason )
	end
end

local function componentSortFunc ( a, b )
	return ( a._componentID or 0 ) < ( b._componentID or 0 )
end
local function componentSortFuncReversed ( b, a )
	return ( a._componentID or 0 ) < ( b._componentID or 0 )
end
--- Get the sorted component list
---@return {Component} the sorted component array
function Entity:getSortedComponentList ( reversed )
	local list = {}
	local i = 0
	for com in pairs ( self.components ) do
		table.insert ( list , com )
	end
	if reversed then
		table.sort ( list, componentSortFuncReversed )
	else
		table.sort ( list, componentSortFunc )
	end
	return list
end

--------------------------------------------------------------------
------ Layer
--------------------------------------------------------------------
function Entity:getLayer ()
	if not self.layer then return nil end
	if type ( self.layer ) == 'string' then return self.layer end
	return self.layer.name
end

--- 设置Entity所在Layer, 只修改字段
--- 子类可以重写此方法
---@param layerName string
function Entity:setLayer ( layerName )
	if self.scene then
		local layer = self.scene:getLayer ( layerName )
		assert ( layer, 'layer not found:' .. layerName )
		self.layer = layer
		for com in pairs ( self.components ) do
			local setLayer = com.setLayer
			if setLayer then
				setLayer ( com, layer )
			end
		end
	else
		self.layer = layerName --insert later
	end
end

---@return MOAIPartition
function Entity:getPartition ()
	if self.layer then
		return self.layer:getLayerPartition ()
	end
	return nil
end


--------------------------------------------------------------------
-- MSGListener: a string message based approach
--------------------------------------------------------------------
function Entity:tellSelfAndChildren ( msg, data, source )
	self:tellChildren ( msg, data, source )
	return self:tell ( msg, data, source )
end

function Entity:tellChildren ( msg, data, source )
	for ent in pairs ( self.children ) do
		ent:tellChildren ( msg, data, source )
		ent:tell ( msg, data, source )
	end
end

function Entity:tellParent ( msg, data, source )
	if not self.parent then
		return
	end
	return self.parent:tell ( msg, data, source )
end

function Entity:tellSiblings ( msg, data, source )
	if not self.parent then
		return
	end

	for ent in pairs ( self.parent.children ) do
		if ent ~= self then
			return ent:tell ( msg, data, source )
		end
	end
end

function Entity:callNextFrame ( f, ... )
	local scene = self.scene

	if not scene then
		return
	end

	local t = {
		func = f,
		object = self,
		...
	}

	insert ( scene.pendingCall, t )
end

function Entity:callInterval ( interval, func, ... )
	local timer = self:createTimer ()
	local args = nil

	if type ( func ) == "string" then
		func = self[ func ]
		args = {
			self,
			...
		}
	else
		args = {
			...
		}
	end

	timer:setListener ( MOAITimer.EVENT_TIMER_END_SPAN, function ()
		return func ( unpack ( args ) )
	end)
	timer:setMode ( MOAITimer.LOOP )
	timer:setSpan ( interval )

	return timer
end

local function _callTimerFunc ( t )
	return t.__func ( unpack ( t.__args ) )
end

function Entity:callLater ( time, func, ... )
	local timer = self:createTimer ()
	local args = nil

	if type ( func ) == "string" then
		func = self[ func ]
		args = {
			self,
			...
		}
	else
		args = {
			...
		}
	end

	timer.__func = func
	timer.__args = args

	timer:setListener ( MOAITimer.EVENT_STOP, _callTimerFunc )
	timer:setMode ( MOAITimer.NORMAL )
	timer:setSpan ( time )

	return timer
end

function Entity:tellNextFrame ( msg, data, source )
	return self:callNextFrame ( self.tell, self, msg, data, source )
end

function Entity:tellInterval ( interval, msg, data, source )
	return self:callInterval ( interval, self.tell, self, msg, data, source )
end

function Entity:tellLater ( time, msg, data, source )
	return self:callLater ( time, self.tell, self, msg, data, source )
end

local function _onTimerStop ( t )
	local owner = t._owner
	owner.timers[ t ] = nil
end

function Entity:createTimer ()
	local timers = self.timers

	if not timers then
		timers = {}
		self.timers = timers
	end

	local timer = self.scene:createTimer ( _onTimerStop )
	timer._owner = self
	timers[ timer ] = true

	return timer
end

--------------------------------------------------------------------
------ Visibility Control
--------------------------------------------------------------------
function Entity:isVisible ()
	return self._prop:getAttr ( MOAIProp.ATTR_VISIBLE ) == 1
end

function Entity:isLocalVisible ()
	local vis = self._prop:getAttr ( MOAIProp.ATTR_LOCAL_VISIBLE )
	return vis == 1
end

function Entity:setVisible ( visible )
	self._prop:setVisible ( visible )
end

function Entity:show ()
	self:setVisible ( true )
end

function Entity:hide ()
	self:setVisible ( false )
end

function Entity:toggleVisible ()
	return self:setVisible ( not self:isLocalVisible () )
end

function Entity:hideChildren ()
	for child in pairs ( self.children ) do
		child:hide ()
	end
end

function Entity:showChildren ()
	for child in pairs ( self.children ) do
		child:show ()
	end
end

--------------------------------------------------------------------
------ Editor Edit lock control
--------------------------------------------------------------------
function Entity.isLocalEditLocked ( entityInstance )
	return entityInstance._editLocked
end

function Entity:setEditLocked ( locked )
	self._editLocked = locked
end

function Entity:isEditLocked ()
	if self._editLocked then return true end
	if self.parent then return self.parent:isEditLocked () end
	if self._entityGroup then return self._entityGroup:isEditLocked () end
	return false
end

--------------------------------------------------------------------
------ Attributes Links
--------------------------------------------------------------------
local inheritTransformColor = inheritTransformColor
local inheritTransform      = inheritTransform
local inheritColor          = inheritColor
local inheritVisible        = inheritVisible
local inheritLoc            = inheritLoc

---
-- 连接指定prop并将其加入Entity所在层, 继承Entity的基本属性(Transform、Color、Visible、ScissorRect)
---@param p(MOAIGraphicsProp) Prop
---@param role(string)
function Entity:_attachProp ( p, role )
	local _prop = self:getProp ( role )
	p:setPartition ( self.layer )
	inheritTransformColorVisible ( p, _prop )
	linkScissorRect ( p, _prop )
	return p
end

function Entity:_attachPropAttribute ( p, role )
	local _prop = self:getProp ( role )
	inheritTransformColorVisible ( p, _prop )
	return p
end

function Entity:_attachTransform ( t, role )
	local _prop = self:getProp ( role )
	inheritTransform ( t, _prop )
	return t
end

function Entity:_attachLoc ( t, role )
	local _prop = self:getProp ( role )
	inheritLoc ( t, _prop )
	return t
end

function Entity:_attachColor ( t, role )
	local _prop = self:getProp ( role )
	inheritColor ( t, _prop )
	return t
end

function Entity:_attachVisible ( t, role )
	local _prop = self:getProp ( role )
	inheritVisible ( t, _prop )
	return t
end

--- 向Entity所在MOAILayer插入给定Prop
---@param p MOAIGraphicsProp
function Entity:_insertPropToLayer ( p )
	assert ( p )
	p:setPartition ( self.layer )
	return p
end

function Entity:_detachProp ( p, role )
	p:setPartition ( nil )
end

function Entity:_detachVisible ( t, role )
	local _prop = self:getProp ( role )
	clearInheritVisible ( t, _prop )
end

function Entity:_detachColor ( t, role )
	local _prop = self:getProp ( role )
	clearInheritColor ( t, _prop )
end

function isEditorEntity ( entity )
	return entity.FLAG_EDITOR_OBJECT or false
end

--------------------------------------------------------------------
------ Transform Conversion
--------------------------------------------------------------------
function Entity:setWorldLoc ( x, y, z )
	return self._prop:setWorldLoc ( x, y, z )
end

function Entity:setWorldRot ( dir )
	return self._prop:setWorldRot ( dir )
end

function Entity:wndToWorld ( x, y, z )
	local scene = self.scene
	if scene then
		x, y = scene:deviceToContext ( x, y )
	end
	return self.layer:wndToWorld ( x, y, z )
end

function Entity:worldToWnd ( x, y ,z )
	x, y = self.layer:worldToWnd ( x, y, z )
	local scene = self.scene
	if scene then
		x, y = scene:contextToDevice ( x, y )
	end
	return x, y
end

function Entity:worldToProj ( x, y ,z )
	return self.layer:worldToProj ( x, y ,z )
end

function Entity:worldToView ( x, y ,z )
	return self.layer:worldToView ( x, y ,z )
end

function Entity:worldToModel ( x, y ,z )
	return self._prop:worldToModel ( x, y ,z )
end

function Entity:modelToWorld ( x, y ,z )
	return self._prop:modelToWorld ( x, y ,z )
end

function Entity:wndToModel ( x, y, z )
	return self._prop:worldToModel ( self.layer:wndToWorld ( x, y, z ) )
end

function Entity:modelToWnd ( x, y ,z )
	return self.layer:worldToWnd ( self._prop:modelToWorld ( x, y ,z ) )
end

function Entity:modelToProj( x, y ,z )
	return self.layer:worldToProj ( self._prop:modelToWorld ( x, y ,z ) )
end

function Entity:modelToView ( x, y ,z )
	return self.layer:worldToView ( self._prop:modelToWorld ( x, y ,z ) )
end

function Entity:modelRectToWorld ( x0, y0, x1, y1 )
	x0,y0 = self:modelToWorld ( x0, y0 )
	x1,y1 = self:modelToWorld ( x1, y1 )
	return x0,y0,x1,y1
end

function Entity:worldRectToModel ( x0, y0, x1, y1 )
	x0,y0 = self:worldToModel ( x0, y0 )
	x1,y1 = self:worldToModel ( x1, y1 )
	return x0,y0,x1,y1
end


--------------------------------------------------------------------
------ Scissor Rect?????
--------------------------------------------------------------------
function Entity:setScissorRect ( x1, y1, x2, y2, noFollow )
	if not x1 then
		return self:removeScissorRect ()
	end

	local prop = self._prop
	local rect = self._scissorRect

	if not rect then
		clearLinkScissorRect ( prop )

		rect = MOAIScissorRect.new ()
		self._scissorRect = rect

		prop:setScissorRect ( rect )
		self:relinkScissorRect ( self:getParentScissorRect () )
	end

	rect:setRect ( x1, y2, x2, y1) 

	if noFollow then
		clearInheritTransform ( rect )
	else
		self:_attachTransform ( rect )
	end
end

function Entity:removeScissorRect ()
	local rect = self._scissorRect

	if not rect then
		return
	end

	self._scissorRect = false
	local prop = self._prop
	local pp = self.parent and self.parent._prop

	if pp then
		linkScissorRect ( prop, pp )
	else
		prop:setScissorRect ( nil )
	end

	return self:relinkScissorRect ( self:getParentScissorRect () )
end

function Entity:relinkScissorRect ( parentRect )
	self._prop:forceUpdate ()

	local rect = self._scissorRect

	if rect then
		rect:setScissorRect ( parentRect or nil )
	end

	local currentRect = rect or parentRect

	for child in pairs ( self.children ) do
		child:relinkScissorRect ( currentRect )
	end
end

function Entity:getParentScissorRect ()
	local p = self.parent

	while p do
		local parentRect = p._scissorRect
		if parentRect then
			return parentRect
		end
		p = p.parent
	end

	return false
end

local _getScissorRect = MOAIGraphicsProp.getInterfaceTable ().getScissorRect
function Entity:getScissorRect ()
	return _getScissorRect ( self._prop )
end


--------------------------------------------------------------------
------ Other prop wrapper
--------------------------------------------------------------------
function Entity:inside ( x, y, z, pad, checkChildren )
	for com in pairs ( self.components ) do
		local inside = com.inside

		if inside and inside ( com, x, y, z, pad ) then
			return true
		end
	end

	if checkChildren ~= false then
		for child in pairs ( self.children ) do
			if child:inside ( x, y, z, pad ) then
				return true
			end
		end
	end

	return false
end

function Entity:pick ( x, y, z, pad )
	if self.FLAG_EDITOR_OBJECT or self.FLAG_INTERNAL then
		return nil
	end

	for child in pairs ( self.children ) do
		local e = child:pick ( x, y, z, pad )

		if e then
			return e
		end
	end

	for com in pairs ( self.components ) do
		local inside = com.inside

		if inside and inside ( com, x, y, z, pad ) then
			return self
		end
	end

	return nil
end

local min = math.min
local max = math.max
function Entity:getBounds ( reason )
	local bx0, by0, bz0, bx1, by1, bz1
	for com in pairs ( self.components ) do
		local getBounds = com.getBounds
		if getBounds then
			local x0,y0,z0, x1,y1,z1 = getBounds ( com, reason )
			if x0 then
				x0,y0,z0, x1,y1,z1 = x0 or 0,y0 or 0,z0 or 0, x1 or 0,y1 or 0,z1 or 0
				bx0 = bx0 and min( x0, bx0 ) or x0
				by0 = by0 and min( y0, by0 ) or y0
				bz0 = bz0 and min( z0, bz0 ) or z0
				bx1 = bx1 and max( x1, bx1 ) or x1
				by1 = by1 and max( y1, by1 ) or y1
				bz1 = bz1 and max( z1, bz1 ) or z1
			end
		end
	end
	return bx0 or 0, by0 or 0, bz0 or 0, bx1 or 0, by1 or 0, bz1 or 0
end

function Entity:getWorldBounds ( reason )
	local bx0, by0, bz0, bx1, by1, bz1
	for com in pairs ( self.components ) do
		local getWorldBounds = com.getWorldBounds
		if getWorldBounds then
			local x0,y0,z0, x1,y1,z1 = getWorldBounds ( com, reason )
			if x0 then
				x0,y0,z0, x1,y1,z1 = x0 or 0,y0 or 0,z0 or 0, x1 or 0,y1 or 0,z1 or 0
				bx0 = bx0 and min( x0, bx0 ) or x0
				by0 = by0 and min( y0, by0 ) or y0
				bz0 = bz0 and min( z0, bz0 ) or z0
				bx1 = bx1 and max( x1, bx1 ) or x1
				by1 = by1 and max( y1, by1 ) or y1
				bz1 = bz1 and max( z1, bz1 ) or z1
			end
		end
	end
	return bx0 or 0, by0 or 0, bz0 or 0, bx1 or 0, by1 or 0, bz1 or 0
end

--bounds include children objects
function Entity:getFullBounds ( reason )
	local bx0, by0, bz0, bx1, by1, bz1 = self:getWorldBounds ( reason )
	for child in pairs ( self.children ) do
		local x0,y0,z0, x1,y1,z1 = child:getFullBounds ( reason )
		bx0 = bx0 and min( x0, bx0 ) or x0
		by0 = by0 and min( y0, by0 ) or y0
		bz0 = bz0 and min( z0, bz0 ) or z0
		bx1 = bx1 and max( x1, bx1 ) or x1
		by1 = by1 and max( y1, by1 ) or y1
		bz1 = bz1 and max( z1, bz1 ) or z1
	end
	return bx0, by0, bz0, bx1, by1, bz1
end

function Entity:resetTransform ()
	self:setLoc ( 0, 0, 0 )
	self:setRot ( 0, 0, 0 )
	self:setScl ( 1, 1, 1 )
	self:setPiv ( 0, 0, 0 )
end

---@param target Entity | MOAIGraphicsProp
function Entity:copyTransform ( target )
	self:setLoc ( target:getLoc () )
	self:setScl ( target:getScl () )
	self:setRot ( target:getRot () )
	self:setPiv ( target:getPiv () )
end

function Entity:saveTransform ()
	local t = {
		loc = { self:getLoc () },
		scl = { self:getScl () },
		rot = { self:getRot () },
		piv = { self:getPiv () }
	}
	return t
end

function Entity:loadTransform ( data )
	if not data then
		return
	end

	self:setLoc ( unpack ( data.loc or {} ) )
	self:setRot ( unpack ( data.rot or {} ) )
	self:setScl ( unpack ( data.scl or {} ) )
	self:setPiv ( unpack ( data.piv or {} ) )
end

function Entity:setHexColor ( hex, alpha )
	return self:setColor ( hexcolor ( hex, alpha ) )
end

function Entity:seekHexColor ( hex, alpha, duration, easeType )
	local r,g,b = hexcolor ( hex )
	return self:seekColor ( r,g,b, alpha, duration ,easeType )
end

function Entity:getHexColor ()
	local r,g,b,a = self:getColor ()
	local hex = colorhex ( r,g,b )
	return hex, a
end
-- function Entity:onEditorPick( x, y, z, pad )
-- 	for child in pairs(self.children) do
-- 		local e = child:onEditorPick(x,y,z,pad)
-- 		if e then return e end
-- 	end

-- 	for com in pairs(self.components) do
-- 		local inside = com.inside
-- 		if inside then
-- 			if inside( com, x, y, z, pad ) then return self end
-- 		end
-- 	end
-- 	return nil
-- end

--增加这个，是为了防止爆炸的时候碰到这个Entity而调用不存在的函数
function Entity:getDistanceToObj ( o )
	local x0,y0 = self:getWorldLoc ()
	local x1,y1 = o:getWorldLoc ()
	return distance ( x0, y0, x1, y1 )
end

function Entity:loadAsset ( path, option )
	return candy.loadAndHoldAsset ( self.scene, path, option )
end

function Entity:getPriority ()
	return self._priority
end

function Entity:setPriority ( p )
	self._priority = p
	self._prop:setPriority ( p )
end

--------------------------------------------------------------------
------ Registry
--------------------------------------------------------------------
local entityTypeRegistry = setmetatable ( {}, { __no_traverse = true } )

local function registerEntity ( name, creator )
    if not creator then
        return _error ( 'no entity to register', name )
    end

    if not name then
        return _error ( 'no entity name specified' )
    end

    -- _stat ( 'register entity type', name )
    entityTypeRegistry[ name ] = creator
end

local function getEntityRegistry ()
    return entityTypeRegistry
end

local function getEntityType ( name )
    return entityTypeRegistry[ name ]
end

local function buildEntityCategories()
    local categories = {}
    local unsorted = {}
    for name, entClass in pairs ( getEntityRegistry () ) do
        local model = Model.fromClass ( entClass )
        local category
        if model then
            local meta = model:getCombinedMeta ()
            category = meta[ 'category' ]
        end
        local entry = { name, entClass, category }
        if not category then
            table.insert ( unsorted, entry )
        else
            local catTable = categories[ category ]
            if not catTable then
                catTable = {}
                categories[ category ] = catTable
            end
            table.insert ( catTable, entry )
        end
    end
    categories[ '__unsorted__' ] = unsorted
    return categories
end

local function _cloneEntity ( src, cloneComponents, cloneChildren, objMap, ensureComponentOrder )
	local objMap = {}
	local dst = clone ( src, nil, objMap )
	dst.layer = src.layer

	if cloneComponents ~= false then
		if ensureComponentOrder then
			for i, com in ipairs ( src:getSortedComponentList () ) do
				if not com.FLAG_INTERNAL then
					local com1 = clone ( com, nil, objMap )
					dst:attach ( com1 )
				end
			end
		else
			for com in pairs ( src.components ) do
				if not com.FLAG_INTERNAL then
					local com1 = clone ( com, nil, objMap )
					dst:attach ( com1 )
				end
			end
		end
	end

	if cloneChildren ~= false then
		for child in pairs ( src.children ) do
			if not child.FLAG_INTERNAL then
				local child1 = _cloneEntity ( child, cloneComponents, cloneChildren, objMap, ensureComponentOrder )
				dst:addChild ( child1 )
			end
		end
	end

	return dst
end

local function cloneEntity ( src, ensureComponentOrder )
	return _cloneEntity ( src, true, true, nil, ensureComponentOrder )
end


registerEntity ( 'Entity', Entity )

EntityModule.Entity = Entity
EntityModule.registerEntity = registerEntity
EntityModule.getEntityRegistry = getEntityRegistry
EntityModule.getEntityType = getEntityType
EntityModule.buildEntityCategories = buildEntityCategories
EntityModule.cloneEntity = cloneEntity

return EntityModule