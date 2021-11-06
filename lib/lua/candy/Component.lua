-- import
local EntityModule = require 'candy.Entity'
local MoaiHelpersModule = require 'candy.helper.MOAIHelpers'

-- module
local ComponentModule = {}

---@class Component
local Component = CLASS: Component ()
    :MODEL {
        Field '_alias'    :string() :no_edit();
        -- Field 'active'    :boolean() :get('isLocalActive')  :set('setActive');
    }

--------------------------------------------------------------------
wrapWithMoaiPropMethods ( Component, '_entity._prop' )

function Component:__init ()
    self.active = true
    self.FLAG_INTERNAL = false

    self._entity = false
end

function Component:__tostring ()
	if self._entity then
		if self._alias then
			return string.format ( "(%s)%s@%s @%s", self._alias, self:__repr (), tostring ( self._entity:getFullName () ), self._entity:getSceneSessionName () )
		else
			return string.format ( "%s@%s @%s", self:__repr (), tostring ( self._entity:getFullName () ), self._entity:getSceneSessionName () or "???" )
		end
	else
		return self:__repr ()
	end
end


--------------------------------------------------------------------
-- Callback
--------------------------------------------------------------------
function Component:onAttach ( entity ) end

function Component:onDetach ( entity ) end

function Component:isSuspended ()
	return self._suspendState
end

function Component:onSuspend () end

function Component:onResurrect () end

-- function Component:onStart ( entity ) end

-- function Component:onSetActive ( active ) end

--------------------------------------------------------------------
-- Basic
--------------------------------------------------------------------

--- Get owner entity
---@return Entity the owner entity
function Component:getEntity ()
	return self._entity
end


function Component:getOwner ()
    return self._entity
end


--- Check if owner entity is started
---@return boolean started
function Component:isEntityStarted ()
	local ent = self._entity
	return ent and ent.started or false
end

--- Get component alias ID
---@return string alias of the component
function Component:getAlias ()
	return self._alias
end

--- Get the name of the owner entity
---@return string owner entity's name
function Component:getEntityName ()
	return self._entity:getName ()
end

--- Get the name of the owner entity
---@return string owner entity's name
function Component:getEntityFullName ()
	return self._entity:getFullName ()
end

--- Get the tags of the owner entity
---@return string owner entity's tags
function Component:getEntityTags ()
	return self._entity:getTags ()
end

--- Destroy the owner entity
function Component:destroyEntity ()
	if self._entity then self._entity:destroy () end
end

--- Find entity by name in current scene
-- @tparam string name the name to look for
---@return Entity result of search
function Component:findEntity ( name )
	return self._entity:findEntity ( name )
end

--- Find entity in current scene by full entity 'path'
---@param string path the entity path to look for
---@return Entity result of search
function Component:findEntityByPath ( path )
	return self._entity:findEntityByPath ( path )
end

--- Find entity by name within owner entity's children
---@param string name the name to look for
-- @p[opt=false] bool deep should do deep-search
---@return Entity result of search
function Component:findChild ( name, deep )
	if not self._entity then return end
	return self._entity:findChild ( name, deep )
end

function Component:findSibling ( name )
	return self._entity:findSibling ( name )
end

--- Find child entity by relative entity 'path'
---@param string path the entity path to look for
---@return Entity result of search
function Component:findChildByPath ( path )
	return self._entity:findChildByPath ( path )
end

--- Get parent entity of hte owner
---@return Entity the parent of owner entity
function Component:getParent ()
	return self._entity.parent
end

--- Shortcut method to get component from a named entity, in scene-scope
---@param string name name of the entity
---@param comId string|Class component type to be looked for
---@return Entity the parent of owner entity
function Component:findEntityCom ( name, comId )
	return self._entity:findEntityCom ( name, comId )
end

--- Shortcut method to get component from a named child entity
---@param string name name of the child entity
---@param comId string|Class component type to be looked for
---@return Entity the parent of owner entity
function Component:findChildCom ( name, comId, deep )
	return self._entity:findChildCom ( name, comId, deep )
end

--- Get component of given type from owner entity
---@param comType Class type of component
---@return Component result
function Component:getComponent ( comType )
	return self._entity:getComponent ( comType )
end

--- Get component of given type name from owner entity
---@param comTypeName string name of component class
---@return Component result
function Component:getComponentByName ( comTypeName )
	return self._entity:getComponentByName ( comTypeName )
end

--- Get component of given type from owner entity, either by name of by class
---@param id string|Class type of component
---@return Component result
function Component:com ( id )
	return self._entity:com ( id )
end

--------------------------------------------------------------------
-- Attach Control
--------------------------------------------------------------------

--- Detach this component from owner entity
function Component:detach ()
    assert ( self._entity, 'Component not ready, _entity = nil' )
    self._entity:detach ( self, 'Component:detach()' )
end


function Component:detachFromEntity ()
	if self._entity then
		self._entity:detach ( self )
	end
end

--------------------------------------------------------------------
-- MSG API
--------------------------------------------------------------------
function Component:tell ( ... )
	return self._entity:tell ( ... )
end

function Component:tellLater ( ... )
	return self._entity:tellLater ( ... )
end

function Component:tellNextFrame ( ... )
	return self._entity:tellNextFrame ( ... )
end

function Component:tellInterval ( ... )
	return self._entity:tellInterval ( ... )
end

function Component:tellSelfAndChildren ( ... )
	return self._entity:tellSelfAndChildren ( ... )
end

function Component:tellChildren ( ... )
	return self._entity:tellChildren ( ... )
end

function Component:tellSiblings ( ... )
	return self._entity:tellSiblings ( ... )
end

--------------------------------------------------------------------
-- Signal API
--------------------------------------------------------------------
function Component:connect ( sig, methodName )
	return self._entity:connectForObject ( self, sig, methodName )
end

function Component:disconnect ( sig )
	return self._entity:disconnectForObject ( self, sig )
end


--------------------------------------------------------------------
-- Other
--------------------------------------------------------------------
function Component:getScene ()
	local ent = self._entity
	return ent and ent.scene
end

function Component:getLayer ()
	local ent = self._entity
	return ent and ent:getLayer ()
end

function Component:getTime ()
	local ent = self._entity
	return ent and ent:getTime () or 0
end

function Component:getUserConfig ( key, default )
	if self._entity then
		return self._entity:getUserConfig ( key, default )
	end
	return game:getUserConfig ( key, default )
end

--------------------------------------------------------------------
-- Component management
--------------------------------------------------------------------
local componentRegistry = setmetatable ( {}, { __no_traverse = true } )

local function registerComponent ( name, clas )
    -- assert( not componentRegistry[ name ], 'duplicated component type:'..name )
    if not clas then
        _error ( 'no component to register', name )
    end
    if not isClass ( clas ) then
        _error ( 'attempt to register non-class component', name )
    end
    componentRegistry[ name ] = clas
end

local function registerEntityWithComponent ( name, ... )
    local comClasses = { ... }
    local creator = function ( ... )
        local a = EntityModule.Entity ()
        for i, comClass in ipairs ( comClasses ) do
            local com = comClass ()
            a:attach ( com )
        end
        return a
    end
    return EntityModule.registerEntity ( name, creator )
end

local function getComponentRegistry ()
    return componentRegistry
end

local function getComponentType ( name )
    return componentRegistry[ name ]
end

local function buildComponentCategories ()
    local categories = {}
    local unsorted = {}
    for name, comClass in pairs ( getComponentRegistry () ) do
        local model = Model.fromClass ( comClass )
        local category
        if model then
            local meta = model:getCombinedMeta ()
            category = meta[ 'category' ]
        end
        local entry = { name, comClass, category }
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

local function onAttachProp ( self, entity )
	return entity:_attachProp ( self )
end

local function onDetachProp ( self, entity )
	return entity:_detachProp ( self )
end

local function injectMoaiPropComponentMethod ( clas )
	MoaiHelpersModule.injectMoaiClass ( clas, {
		onAttach = onAttachProp,
		onDetach = onDetachProp
	} )
end

injectMoaiPropComponentMethod ( MOAIProp )
injectMoaiPropComponentMethod ( MOAITextLabel )
injectMoaiPropComponentMethod ( MOAIParticleSystem )


ComponentModule.Component = Component
ComponentModule.registerComponent = registerComponent
ComponentModule.registerEntityWithComponent = registerEntityWithComponent
ComponentModule.getComponentRegistry = getComponentRegistry
ComponentModule.getComponentType = getComponentType
ComponentModule.buildComponentCategories = buildComponentCategories

return ComponentModule