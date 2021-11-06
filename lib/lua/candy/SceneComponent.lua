-- import
local EntityModule = require 'candy.Entity'
local ComponentModule = require 'candy.Component'

---@class SceneComponent : Component
local SceneComponent = CLASS: SceneComponent ( ComponentModule.Component )
    :MODEL {
        -- Field 'active'    :boolean() :get('isLocalActive')  :set('setActive');		
    }

--------------------------------------------------------------------
wrapWithMoaiPropMethods ( SceneComponent, '_entity._prop' )

function SceneComponent:__init ()
    self.isRootComponent = true

    self.parent = false
    self.children = {}
end

function SceneComponent:_onUpdate ( dt )
    if self.onUpdate then self:onUpdate ( dt ) end

    for childComponent in pairs ( self.children ) do
        childComponent:_onUpdate ( dt )
    end
end

--------------------------------------------------------------------
------ Behaviour
--------------------------------------------------------------------
function SceneComponent:onUpdate ( dt )
    for childComponent in pairs ( self.children ) do
        childComponent:onUpdate ( dt )
    end
end

--------------------------------------------------------------------
------ Attach Control
--------------------------------------------------------------------

---
-- Attach to the given SceneComponent.
---@param com The SceneComponent.
function SceneComponent:attachTo ( com )
    assert ( com, 'SceneComponent:attachTo() param is nil' )
    assert ( isSubclassInstance ( com, SceneComponent ), 'SceneComponent:attachTo() param must be sub class instance of SceneComponent' )
    -- assert(isClassInstance(com) and isSubclass(com, Component), 'param type error')
    -- assert(isSubclass(com, Component), 'param type error')

    if self.parent == com then return end

    local parent0 = self.parent
    if parent0 then
        parent0.children[ self ] = nil
    end
    self.parent = com
    com.children[ self ] = true
end

---
-- Detach from parent.
function SceneComponent:detach ()
   
    assert ( self._entity, 'Component not ready, _entity = nil' )
    for child in pairs ( self.children ) do
        child:detach ()
    end

     SceneComponent.__super.detach ( self )
end


return SceneComponent