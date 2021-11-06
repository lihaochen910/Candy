-- import
local BTControllerModule = require 'candy.ai.BTController'
local BTAction = BTControllerModule.BTAction

-- module
local BTActionCommonModule = {}

---@class BTActionReset : BTAction
local BTActionReset = CLASS: BTActionReset ( BTAction )
	:register ( "bt_reset" )

function BTActionReset:start ( context )
	context:getController ():resetEvaluate ()
end

---@class BTActionStop : BTAction
local BTActionStop = CLASS: BTActionStop ( BTAction )
	:register ( "bt_stop" )

function BTActionStop:start ( context )
	context:getController ():stop ()
end

---@class BTActionCoroutine : BTAction
local BTActionCoroutine = CLASS: BTActionCoroutine ( BTAction )
	:MODEL {}
BTActionCoroutine:register ( "coroutine" )

function BTActionCoroutine:start ( context )
	local ent = context:getControllerEntity ()
	local coroutineName = self:getArgS ( "method" )
	local target = false
	local targetName = self:getArgS ( "target", false )

	if not targetName then
		target = ent
	else
		target = ent:com ( targetName )
	end

	if not target then
		_error ( "no coroutine target", targetName, ent )
	end

	local coro = target:addCoroutine ( coroutineName )
	self.coroutine = coro
end

function BTActionCoroutine:step ( context, dt )
	if self.coroutine:isBusy () then
		return "running"
	else
		return "ok"
	end
end

function BTActionCoroutine:stop ( context )
	self.coroutine:stop ()
end


BTActionCommonModule.BTActionReset = BTActionReset
BTActionCommonModule.BTActionStop = BTActionStop
BTActionCommonModule.BTActionCoroutine = BTActionCoroutine

return BTActionCommonModule