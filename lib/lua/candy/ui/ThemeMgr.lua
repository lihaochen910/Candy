-- import
local SignalModule = require 'candy.signal'
local GlobalManagerModule = require 'candy.GlobalManager'
local GlobalManager = GlobalManagerModule.GlobalManager

---@class ThemeMgr : GlobalManager
local ThemeMgr = CLASS: ThemeMgr ( GlobalManager )

---
-- Constructor.
function ThemeMgr:__init()
    assert ( rawget ( ThemeMgr, _singleton ) == nil )
    self.theme = require "candy.ui.BaseTheme"
end

---
-- Set the theme of widget.
---@param theme theme of widget
function ThemeMgr:setTheme ( theme )
    if self.theme ~= theme then
        self.theme = theme
        SignalModule.emitGlobalSignal ( UIEvent.theme_changed )
    end
end

---
-- override the theme of widget.
---@param theme theme of widget
function ThemeMgr:overrideTheme ( theme )
    local newTheme = {}
    local copyTheme = function ( srcTheme )
        for k, v in pairs( srcTheme ) do
            if newTheme[ k ] ~= nil then
                local style = newTheme[ k ]
                for k2, v2 in pairs ( v ) do
                    style[ k2 ] = v2
                end
            else
                newTheme[ k ] = table.simplecopy ( v )
            end
        end
    end

    copyTheme ( self.theme )
    copyTheme ( theme )

    self:setTheme ( newTheme )
end

---
-- Return the theme of widget.
---@return theme
function ThemeMgr:getTheme ()
    return self.theme
end

ThemeMgr ()

return ThemeMgr