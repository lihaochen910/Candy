-- import
local ComponentModule = require 'candy.Component'
local Component = ComponentModule.Component
local InputListenerModule = require 'candy.input.InputListener'

---@class Behaviour : Component
local Behaviour = CLASS: Behaviour ( Component )
 	:MODEL {}
	:META {
		category = 'behaviour'
	}

--------------------------------------------------------------------
function Behaviour:installInputListener ( option )
	return InputListenerModule.installInputListener ( self, option )
end

function Behaviour:uninstallInputListener ()
	return InputListenerModule.uninstallInputListener ( self )
end

function Behaviour:setInputListenerActive ( act )
	return InputListenerModule.setInputListenerActive ( self, act ~= false )
end

function Behaviour:getInputListener ()
	return InputListenerModule.getInputListener ( self )
end

function Behaviour:isInputListenerActive ()
	return InputListenerModule.isInputListenerActive ( self )
end

--------------------------------------------------------------------
function Behaviour:installMsgListener ()
	local onMsg = self.onMsg
	if onMsg then
		self._msgListener = self._entity:addMsgListener ( function ( msg, data, src )
			return onMsg ( self, msg, data, src )
		end )
	end
end

function Behaviour:uninstallMsgListener ()
	if self._msgListener then
		self._entity:removeMsgListener( self._msgListener )
		self._msgListener = false
	end
end

--------------------------------------------------------------------
function Behaviour:onAttach ( entity )
	if self.onMsg then
		self:installMsgListener ()
	end
end

function Behaviour:onDetach ( entity )
	self:uninstallInputListener ()
	self:uninstallMsgListener ()
	self:clearCoroutines ()
end

function Behaviour:onStart ( entity )
	if self.onThread then
		self:addCoroutine ( 'onThread' )
	end	
end

function Behaviour:onSuspend ( sstate )
	if self:getInputListener () then
		sstate.inputListenerActive = self:isInputListenerActive ()
	end

	self:clearCoroutines ()
end

return Behaviour