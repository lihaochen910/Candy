
local MoveHelper = CLASS: MoveHelper ( candy.Component )
	:MODEL {}
	:SIGNAL ( {
		accepted = "",
		cancelled = ""
	} )

candy.registerComponent ( "MoveHelper", MoveHelper )

local _activeMover = false

function MoveHelper:__init ()
	self.moveN = 0
	self.moveE = 0
	self.moveW = 0
	self.moveS = 0
	self.moveSpeed = 1
	self.moved = false
	self.grabCamera = false
	self.cameraLoc = false
end

function MoveHelper:onStart ( ent )
	local parentEntity = ent:getParent ()

	if not parentEntity then
		return
	end

	self:startEditing ()
end

function MoveHelper:onDetach ( ent )
	if _activeMover == self then
		self:stopEditing ()
	end
end

function MoveHelper:startEditing ()
	if _activeMover then
		_activeMover:stopEditing ()
	end

	_activeMover = self

	candy.affirmInputListenerCategory ( "EditTool" )
	candy.installInputListener ( self, {
		category = "EditTool"
	} )
	candy.setInputListenerCategorySolo ( "all", "EditTool", true )

	local target = self:getEntity ():getParent ()
	self.originalLoc = {
		target:getLoc ()
	}

	self:setGrabCamera ( self.grabCamera )
	self:addCoroutine ( "actionUpdate" )
end

function MoveHelper:stopEditing ()
	if _activeMover == self then
		_activeMover = false
	end

	candy.setInputListenerCategorySolo ( "all", "EditTool", false )
	candy.uninstallInputListener ( self )
	self:setGrabCamera ( false )
	self:findAndStopCoroutine ( "actionUpdate" )
end

function MoveHelper:onKeyEvent ( key, down )
	if key == "w" then
		self.moveN = down and 1 or 0
	elseif key == "s" then
		self.moveS = down and 1 or 0
	elseif key == "a" then
		self.moveW = down and 1 or 0
	elseif key == "d" then
		self.moveE = down and 1 or 0
	elseif key == "f" and down then
		self:setGrabCamera ( not self.grabCamera )
	elseif key == "escape" and down then
		self:cancel ( true )
	elseif  ( key == "enter" or key == "return" ) and down then
		self:accept ()
	end
end

function MoveHelper:accept ()
	self.accepted ()
	self:getEntity ():destroy ()
end

function MoveHelper:cancel ( twostep )
	local target = self:getEntity ():getParent ()

	target:setLoc ( unpack ( self.originalLoc ) )

	local moved = self.moved
	self.moved = false

	if twostep and moved then
		return
	end

	self.cancelled ()

	self.moved = false

	self:getEntity ():destroy ()
end

function MoveHelper:onMouseMove ( x, y )
end

function MoveHelper:onMouseDown ( btn, x, y )
end

function MoveHelper:onMouseUp ( btn, x, y )
end

function MoveHelper:onMouseWheel ( x, y )
end

function MoveHelper:setGrabCamera ( grab )
	grab = grab ~= false

	if self.grabCamera == grab then
		return
	end

	self.grabCamera = grab
	local camera = getCamera ()

	if grab then
		self.cameraLoc = {
			camera:getLoc ()
		}
	elseif self.cameraLoc then
		camera:setLoc ( unpack ( self.cameraLoc ) )
	end

	local cc = getCameraController ()
	local fc = camera:com ( "CameraFocusController" )

	if self.grabCamera then
		fc:setActive ( false )
	else
		fc:setActive ( true )
	end
end

function MoveHelper:actionUpdate ()
	local camera = getCamera ()
	local ent = self:getEntity ()
	local target = ent:getParent ()

	while true do
		coroutine.yield ()

		local x, y, z = target:getWorldLoc ()

		if self.grabCamera then
			camera:setLoc ( x, y, z )
		end

		local speed = self.moveSpeed

		if candy.isShiftDown () then
			speed = speed * 2
		end

		local dx =  ( self.moveE - self.moveW ) * speed
		local dy =  ( self.moveN - self.moveS ) * speed
		local dz = 0

		if candy.isCtrlDown () then
			dy = dz
			dz = dy
		end

		if dx ~= 0 or dy ~= 0 or dz ~= 0 then
			self.moved = true

			target:addLoc ( dx, dy, dz )
		end

		ent:setAlpha ( wave ( 2, 0.5, 1 ) )
	end
end

return MoveHelper