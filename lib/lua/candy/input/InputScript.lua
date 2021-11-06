-- import
local ComponentModule = require 'candy.Component'

---@class InputScript : Component
local InputScript = CLASS: InputScript ( ComponentModule.Component )

--[[
	each InputScript will hold a listener to responding input sensor
	filter [ mouse, keyboard, touch, joystick ]
]]

function InputScript:__init ( option )
	self.option = option
end

function InputScript:onAttach ( entity )
	installInputListener ( entity, self.option )		-- InputListener.lua function
end

function InputScript:onDetach ( entity )
	uninstallInputListener ( entity )		-- InputListener.lua function
end

function InputScript:getInputDevice ()
	return self.inputDevice
end

return InputScript