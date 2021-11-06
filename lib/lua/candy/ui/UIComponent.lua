-- import
local Group = require 'candy.ui.Group'
local GlobalManagerModule = require 'candy.GlobalManager'
local GlobalManager = GlobalManagerModule.GlobalManager

---@class UIComponent : Group
local UIComponent = CLASS: UIComponent ( Group )
    : MODEL {}

--- Style: normalColor
UIComponent.STYLE_NORMAL_COLOR = "normalColor"

--- Style: disabledColor
UIComponent.STYLE_DISABLED_COLOR = "disabledColor"

--- Style: minSize
UIComponent.STYLE_MIN_SIZE = "minSize"

-- wrapWithMoaiPropMethods ( UIComponent, ":getMoaiProp()" )

---
-- Constructor.
-- Please do not inherit this constructor.
-- Please have some template functions are inherited.
---@param params Parameter table
function UIComponent:__init ( params )
    self.parentScissorRect = nil
    self.contentScissorRect = nil

    self:setSize ( params[ 'width' ] or 0, params[ 'height' ] or 0 )
    self:setPivToCenter ()
    
    self.isUIComponent = true
    self._initialized = false
    self._enabled = true
    self._focusEnabled = true
    self._theme = nil
    self._styles = {}
    self._layout = nil
    self._excludeLayout = false
    self._invalidateDisplayFlag = true
    self._invalidateLayoutFlag = true

    self:_initEventListeners ()
    self:_createChildren ()

    self:setProperties ( params )    
    self._initialized = true

    self:validate ()
    self:setPivToCenter ()
end

---
-- Performing the initialization processing of the event listener.
-- Please to inherit this function if you want to initialize the event listener.
function UIComponent:_initEventListeners ()
    self:addEventListener ( UIEvent.enabled_changed, self.onEnabledChanged, self )
    self:addEventListener ( UIEvent.theme_changed, self.onThemeChanged, self )
    self:addEventListener ( UIEvent.focus_in, self.onFocusIn, self )
    self:addEventListener ( UIEvent.focus_out, self.onFocusOut, self )
    self:addEventListener ( UIEvent.resize, self.onResize, self )
    self:addEventListener ( UIEvent.touch_down, self.onTouchCommon, self, -10 )
    self:addEventListener ( UIEvent.touch_up, self.onTouchCommon, self, -10 )
    self:addEventListener ( UIEvent.touch_move, self.onTouchCommon, self, -10 )
    self:addEventListener ( UIEvent.touch_cancel, self.onTouchCommon, self, -10 )
end

---
-- Performing the initialization processing of the component.
-- Please to inherit this function if you want to change the behavior of the component.
function UIComponent:_createChildren ()
end

--------------------------------------------------------------------
---
-- Invalidate the all state.
function UIComponent:invalidate ()
    self:invalidateDisplay ()
    self:invalidateLayout ()
end

---
-- Invalidate the display.
-- Schedule the validate the display.
function UIComponent:invalidateDisplay ()
    if not self._invalidateDisplayFlag then
        self:getLayoutMgr ():invalidateDisplay ( self )
        self._invalidateDisplayFlag = true
    end
end

---
-- Invalidate the layout.
-- Schedule the validate the layout.
function UIComponent:invalidateLayout ()
    if not self._invalidateLayoutFlag then
        self:getLayoutMgr ():invalidateLayout ( self )
        self._invalidateLayoutFlag = true
    end
end

---
-- Validate the all state.
-- For slow, it should not call this process as much as possible.
function UIComponent:validate ()
    self:validateDisplay ()
    self:validateLayout ()
end

---
-- Validate the display.
-- If you need to update the display, call the updateDisplay.
function UIComponent:validateDisplay ()
    if self._invalidateDisplayFlag then
        self:updateDisplay ()
        self._invalidateDisplayFlag = false
    end
end

---
-- Validate the layout.
-- If you need to update the layout, call the updateLayout.
function UIComponent:validateLayout ()
    if self._invalidateLayoutFlag then
        self:updateLayout ()

        if self.parent then
            self.parent:invalidateLayout ()
        end

        self._invalidateLayoutFlag = false
    end
end

---
-- Update the display.
-- Do not call this function directly.
-- Instead, please consider invalidateDisplay whether available.
function UIComponent:updateDisplay ()
end

---
-- Update the layout.
-- Do not call this function directly.
-- Instead, please consider invalidateLayout whether available.
function UIComponent:updateLayout ()
    if self._layout then
        self._layout:update ( self )
    end
end

---
-- Update the order of rendering.
-- It is called by LayoutMgr.
---@param priority priority.
---@return last priority
function UIComponent:updatePriority ( priority )
    priority = priority or 0
    self:getMoaiProp ().setPriority ( self, priority )--DisplayObject.setPriority ( self, priority )

    for i, child in ipairs ( self:getChildren () ) do
        if child.updatePriority then
            priority = child:updatePriority ( priority )
        else
            child:setPriority ( priority )
        end
        priority = priority + 10
    end

    return priority
end

---
-- Draw focus object.
-- Called at a timing that is configured with focus.
---@param focus focus
function UIComponent:drawFocus ( focus )
end

---
-- Returns the children object.
-- If you want to use this function with caution.
---@return children
-- function UIComponent:getChildren ()
--     return self:getChildren ()
-- end

---
-- Adds the specified child.
---@param child DisplayObject
function UIComponent:addChild ( child )
    if UIComponent.__super.addChild ( self, child ) then
        self:invalidateLayout ()
        return true
    end
    return false
end

---
-- Removes a child.
---@param child DisplayObject
---@return True if removed.
function UIComponent:removeChild ( child )
    if UIComponent.__super.removeChild ( self, child ) then
        self:invalidateLayout ()
        return true
    end
    return false
end

---
-- Returns the nest level.
---@return nest level
function UIComponent:getNestLevel ()
    local parent = self.parent
    if parent and parent.getNestLevel then
        return parent:getNestLevel () + 1
    end
    return 1
end

local function setProperty ( obj, name, value, unpackFlag )
    local setterNames = {}
    if not setterNames[ name ] then
        local setterName = "set" .. name:sub ( 1, 1 ):upper () .. ( #name > 1 and name:sub ( 2 ) or "" )
        setterNames[ name ] = setterName
    end

    local setterName = setterNames[ name ]
    local setter = assert ( obj[ setterName ], "Not Found Property!" .. name )
    if not unpackFlag or type ( value ) ~= "table" or getmetatable ( value ) ~= nil then
        return setter ( obj, value )
    else
        return setter ( obj, unpack ( value ) )
    end
end

local function setProperties ( obj, properties, unpackFlag )
    for name, value in pairs ( properties ) do
        setProperty ( obj, name, value, unpackFlag )
    end
end

---
-- Sets the properties
---@param properties properties
function UIComponent:setProperties ( properties )
    if properties then
        setProperties ( self, properties, true )
    end
end

---
-- Sets the name.
---@param name name
function UIComponent:setName ( name )
    self.name = name
end

---
-- Sets the width.
---@param width Width
function UIComponent:setWidth ( width )
    local w, h = self:getSize ()
    self:setSize ( width, h )
end

---
-- Sets the height.
---@param height Height
function UIComponent:setHeight ( height )
    local w, h = self:getSize ()
    self:setSize ( w, height )
end

---
-- Sets the size.
---@param width Width
---@param height Height
function UIComponent:setSize ( width, height )
    local minW, minH = self:getMinSize ()
    width  = math.max ( minW or 0, width or 0 )
    height = math.max ( minH or 0, height or 0 )

    local oldWidth, oldHeight =  self:getSize ()

    if oldWidth ~= width or oldHeight ~= height then
        -- UIComponent.__super.setSize ( self, width, height )
        self:setBounds ( 0, 0, 0, width, height, 0 )
        self:invalidate ()
        self:dispatchEvent ( UIEvent.resize )
    end
end

---
-- Sets the min size.
---@param minWidth minWidth
---@param minHeight minHeight
function UIComponent:setMinSize ( minWidth, minHeight )
    minWidth = minWidth or 0
    minHeight = minHeight or 0
    local oldMinW, oldMinH = self:getMinSize ()
    if oldMinW ~= minWidth or oldMinH ~= minHeight then
        self:setStyle ( UIComponent.STYLE_MIN_SIZE, { minWidth, minHeight } )
        self:setSize ( self:getSize () )
    end
end

---
-- Returns the minWidth and minHeight.
---@return minWidth
---@return minHeight
function UIComponent:getMinSize ()
    unpack ( self:getStyle ( UIComponent.STYLE_MIN_SIZE, { 0, 0 } ) )
end

---
-- Sets the object's parent, inheriting its color and transform.
-- If you set a parent, you want to add itself to the parent.
---@param parent parent
function UIComponent:setParent ( parent )
    if parent == self.parent then
        return
    end

    local oldParent = self.parent
    self.parent = parent
    if oldParent and oldParent.isGroup then
        oldParent:removeChild ( self )
    end

    self:invalidateLayout ()
    UIComponent.__super.setParent ( self, parent )

    if parent and parent.isGroup then
        parent:addChild ( self )
    end
end

---
-- Set the layout.
---@param layout layout
function UIComponent:setLayout ( layout )
    if self._layout ~= layout then
        self._layout = layout
        self:invalidateLayout ()
    end
end

---
-- Return the layout.
---@return layout
function UIComponent:getLayout ()
    return self._layout
end

---
-- Set the excludeLayout.
---@param excludeLayout excludeLayout
function UIComponent:setExcludeLayout ( excludeLayout )
    if self._excludeLayout ~= excludeLayout then
        self._excludeLayout = excludeLayout
        self:invalidateLayout ()
    end
end

---
-- Set the enabled state.
---@param enabled enabled
function UIComponent:setEnabled ( enabled )
    if self._enabled ~= enabled then
        self._enabled = enabled
        self:dispatchEvent ( UIEvent.enabled_changed )
    end
end

---
-- Returns the enabled.
---@return enabled
function UIComponent:isEnabled ()
    return self._enabled
end

---
-- Returns the parent enabled.
---@return enabled
function UIComponent:isComponentEnabled ()
    if not self._enabled then
        return false
    end

    local parent = self.parent
    if parent and parent.isComponentEnabled then
        return parent:isComponentEnabled ()
    end
    return true
end

---
-- Set the focus.
---@param focus focus
function UIComponent:setFocus ( focus )
    if self:isFocus () ~= focus then
        local focusMgr = self:getFocusMgr ()
        if focus then
            focusMgr:setFocusObject ( self )
        else
            focusMgr:setFocusObject ( nil )
        end
    end
end

---
-- Returns the focus.
---@return focus
function UIComponent:isFocus ()
    local focusMgr = self:getFocusMgr ()
    return focusMgr:getFocusObject () == self
end

---
-- Sets the focus enabled.
---@param focusEnabled focusEnabled
function UIComponent:setFocusEnabled ( focusEnabled )
    if self._focusEnabled ~= focusEnabled then
        self._focusEnabled = focusEnabled
        if not self._focusEnabled then
            self:setFocus ( false )
        end
    end
end

---
-- Returns the focus.
---@return focus
function UIComponent:isFocusEnabled ()
    return self._focusEnabled
end

---
-- Sets the theme.
---@param theme theme
function UIComponent:setTheme ( theme )
    if self._theme ~= theme then
        self._theme = theme
        self:invalidate ()
        self:dispatchEvent ( UIEvent.theme_changed )
    end
end

---
-- Returns the theme.
---@return theme
function UIComponent:getTheme ()
    if self._theme then
        return self._theme
    end

    if self._themeName then
        local globalTheme = self:getThemeMgr ():getTheme ()
        return globalTheme[ self._themeName ]
    end
end

---
-- Returns the ThemeMgr.
---@return ThemeMgr
function UIComponent:getThemeMgr ()
    return ThemeMgr.getInstance ()
end

---
-- Set the themeName.
---@param themeName themeName
function UIComponent:setThemeName ( themeName )
    if self._themeName ~= themeName then
        self._themeName = themeName
        self:invalidate ()
        self:dispatchEvent ( UIEvent.theme_changed ) -- dispatchEvent
    end
end

---
-- Return the themeName.
---@return themeName
function UIComponent:getThemeName ()
    return self._themeName
end

---
-- Sets the style of the component.
---@param name style name
---@param value style value
function UIComponent:setStyle ( name, value )
    if self._styles[ name ] ~= value then
        self._styles[ name ] = value
        self:dispatchEvent ( UIEvent.style_changed, { styleName = name, styleValue = value } )
    end
end

---
-- Returns the style.
---@param name style name
---@param default default value.
---@return style value
function UIComponent:getStyle ( name, default )
    -- not initialized pattern
    self._styles = self._styles or {}

    if self._styles[ name ] ~= nil then
        return self._styles[ name ]
    end

    local theme = self:getTheme ()

    while theme do
        if theme[ name ] ~= nil then
            return theme[ name ]
        end

        if theme[ "parentStyle" ] then
            local parentStyle = theme[ "parentStyle" ]
            local globalTheme = self:getThemeMgr ():getTheme ()
            theme = globalTheme[ parentStyle ]
        else
            break
        end
    end

    local globalTheme = self:getThemeMgr ():getTheme ()
    return globalTheme[ "common" ][ name ] or default
end

---
-- Returns the focusMgr.
---@return focusMgr
function UIComponent:getFocusMgr ()
    return GlobalManager.get ( FocusMgr )
end

---
-- Returns the layoutMgr.
---@return layoutMgr
function UIComponent:getLayoutMgr ()
    return GlobalManager.get ( LayoutMgr )
end

---
-- This event handler is called enabled changed.
---@param e Touch Event
function UIComponent:onEnabledChanged ( e )
    if self:isEnabled () then
        self:setColor ( unpack ( self:getStyle ( UIComponent.STYLE_NORMAL_COLOR ) ) )
    else
        self:setColor ( unpack ( self:getStyle ( UIComponent.STYLE_DISABLED_COLOR ) ) )
    end
end

---
-- This event handler is called when resize.
---@param e Resize Event
function UIComponent:onResize ( e )
end

---
-- This event handler is called when theme changed.
---@param e Event
function UIComponent:onThemeChanged ( e )
end

---
-- This event handler is called when touch.
---@param e Touch Event
function UIComponent:onTouchCommon ( e )
    if not self:isComponentEnabled () then
        e:stop ()
        return
    end
    if e.type == UIEvent.touch_down then
        if self:isFocusEnabled () then
            local focusMgr = self:getFocusMgr ()
            focusMgr:setFocusObject ( self )
        end
    end
end

---
-- This event handler is called when focus.
---@param e focus Event
function UIComponent:onFocusIn ( e )
    self:drawFocus ( true )
end

---
-- This event handler is called when focus.
---@param e focus Event
function UIComponent:onFocusOut ( e )
    self:drawFocus ( false )
end

---
-- return prop.
---@return MOAIGraphicsProp
function UIComponent:getMoaiProp ()
	return self._prop
end

return UIComponent