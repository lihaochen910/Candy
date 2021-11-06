-- module
local DebugDrawModule = {}

-- class
local DebugDrawCommand
local DebugDrawQueue
local DebugDrawQueueGroup

---------------------------------------------------------------------
local drawAnimCurve		= MOAIDraw.drawAnimCurve
-- local drawAxisGrid    = MOAIDraw.drawAxisGrid
local drawBezierCurve	= MOAIDraw.drawBezierCurve
local drawBoxOutline	= MOAIDraw.drawBoxOutline
local drawCircle		= MOAIDraw.drawCircle
local drawEllipse		= MOAIDraw.drawEllipse
-- local drawGrid        = MOAIDraw.drawGrid
local drawLine			= MOAIDraw.drawLine
local drawPoints		= MOAIDraw.drawPoints
local drawRay			= MOAIDraw.drawRay
local drawRect			= MOAIDraw.drawRect
local drawText			= MOAIDraw.drawText
local drawTexture		= MOAIDraw.drawTexture
local fillCircle		= MOAIDraw.fillCircle
local fillEllipse		= MOAIDraw.fillEllipse
local fillFan			= MOAIDraw.fillFan
local fillRect			= MOAIDraw.fillRect
local setBlendMode		= MOAIDraw.setBlendMode
local setBlendMode		= MOAIDraw.setBlendMode
local setPenColor 		= MOAIDraw.setPenColor
local drawArrow 		= MOAIDraw.drawArrow
local fillArrow 		= MOAIDraw.fillArrow
local DEBUGDRAW_ENABLED = false
local dummpyDrawCommand = nil
local insert = table.insert

--------------------------------------------------------------------
--extra
local drawArrow       = MOAIDraw.drawArrow
local fillArrow       = MOAIDraw.fillArrow


---------------------------------------------------------------------
local insert = table.insert

---------------------------------------------------------------------
---@class DebugDrawCommand
DebugDrawCommand = CLASS: DebugDrawCommand ()
	:MODEL {}

function DebugDrawCommand:__init ()
	self.color = { 0,0,1,1 }
end

function DebugDrawCommand:setColor ( r,g,b,a )
	self.color = { r,g,b,a }
end

function DebugDrawCommand:draw ()
	setPenColor ( unpack ( self.color ) )
	return self:onDraw ()
end

function DebugDrawCommand:onDraw ()
end


--------------------------------------------------------------------
---@class DebugDrawQueue
DebugDrawQueue = CLASS: DebugDrawQueue ()
	:MODEL {}

function DebugDrawQueue:__init ()
	self.defaultGroup = DebugDrawQueueGroup ()
	self.namedGroups = table.weak ()
	-- self.scriptDeck = MOAIScriptDeck.new ()
	self.scriptDeck = MOAIDrawDeck.new ()
	self.scriptDeck:setDrawCallback ( function ( idx, xOff, yOff, xScale, yScale )
		return self:draw ()
	end )
	self.prop = MOAIGraphicsProp.new ()
	self.prop:setDeck ( self.scriptDeck )
	self.prop:setBounds ( 
		-1000000, 1000000,
		-1000000, 1000000,
		-1000000, 1000000
	)
end

function DebugDrawQueue:getMoaiProp ()
	return self.prop
end

function DebugDrawQueue:update ( dt )
	local dead = {}
	for k, group in pairs ( self.namedGroups ) do
		if group:update ( dt ) == 'overdue' then
			dead[ k ] = true
		end
	end
	for k in pairs ( dead ) do
		self.namedGroups[ k ] = nil
	end
end

function DebugDrawQueue:getDebugDrawGroup ( key )
	local group = self.namedGroups[ key ]
	if not group then
		group = DebugDrawQueueGroup ()
		self.namedGroups[ key ] = group
	end
	return group
end

function DebugDrawQueue:clearDebugDrawGroup ( key )
	self.namedGroups[ key ] = nil
end

function DebugDrawQueue:clear ( clearGroups )
	self.defaultGroup:clear ()
	if clearGroups then
		self.namedGroups = {}
	end
end

function DebugDrawQueue:draw ()
	self.defaultGroup:draw ()
	for k, group in pairs ( self.namedGroups ) do
		group:draw ()
	end
end


--------------------------------------------------------------------
---@class DebugDrawQueueGroup
DebugDrawQueueGroup = CLASS: DebugDrawQueueGroup ()
	:MODEL {}

function DebugDrawQueueGroup:__init ()
	self.queue  = {}
	self.duration = 0
	self.elapsed = 0
end

function DebugDrawQueueGroup:setDuration ( duration )
	self.duration = duration
end

function DebugDrawQueueGroup:update ( dt )
	self.elapsed = self.elapsed + dt
	if self.duration > 0 and self.duration < self.elapsed then
		return 'overdue'
	end
end

function DebugDrawQueueGroup:append ( command )
	insert ( self.queue, command )
	return command
end

function DebugDrawQueueGroup:clear ( clearGroups )
	self.queue = {}
end

function DebugDrawQueueGroup:draw ()
	for i, command in ipairs ( self.queue ) do
		command:draw ()
	end
end

function DebugDrawQueueGroup:drawRect ( x, y, x1, y1 )
	return self:append ( DebugDrawCommandRect ( x,y,x1,y1 ) )
end

function DebugDrawQueueGroup:drawCircle ( x, y, radius )
	return self:append ( DebugDrawCommandCircle ( x,y,radius ) )
end

function DebugDrawQueueGroup:drawLine ( x, y, x1, y1 )
	return self:append ( DebugDrawCommandLine ( x,y,x1,y1 ) )
end

function DebugDrawQueueGroup:drawArrow ( x, y, x1, y1, size, angle )
	return self:append ( DebugDrawCommandArrow ( x,y,x1,y1, size or 10, angle ) )
end

function DebugDrawQueueGroup:drawRay ( x, y, dx, dy )
	return self:append ( DebugDrawCommandRay ( x,y,dx, dy ) )
end

function DebugDrawQueueGroup:drawScript ( func )
	return self:append ( DebugDrawCommandScript ( func ) )
end

--------------------------------------------------------------------
local DebugDrawQueueDummyGroup = CLASS: DebugDrawQueueDummyGroup ( DebugDrawQueueGroup )
	:MODEL {}

function DebugDrawQueueDummyGroup:append ( command )
	--do nothing
end


--------------------------------------------------------------------
local DebugDrawCommandCircle = CLASS: DebugDrawCommandCircle ( DebugDrawCommand )
	:MODEL {}

function DebugDrawCommandCircle:__init ( x, y, radius )
	self.x = x
	self.y = y
	self.radius = radius
end

function DebugDrawCommandCircle:onDraw ()
	return drawCircle ( self.x, self.y, self.radius )
end

--------------------------------------------------------------------
local DebugDrawCommandRect = CLASS: DebugDrawCommandRect ( DebugDrawCommand )
	:MODEL {}

function DebugDrawCommandRect:__init ( x, y, x1, y1 )
	self.x = x
	self.y = y
	self.x1 = x1
	self.y1 = y1
end

function DebugDrawCommandRect:onDraw ()
	return drawRect ( self.x, self.y, self.x1, self.y1 )
end


--------------------------------------------------------------------
local DebugDrawCommandLine = CLASS: DebugDrawCommandLine ( DebugDrawCommand )
	:MODEL {}

function DebugDrawCommandLine:__init ( x, y, x1, y1 )
	self.x = x
	self.y = y
	self.x1 = x1
	self.y1 = y1
end

function DebugDrawCommandLine:onDraw ()
	return drawLine ( self.x, self.y, self.x1, self.y1 )
end

--------------------------------------------------------------------
local DebugDrawCommandArrow = CLASS: DebugDrawCommandArrow ( DebugDrawCommand )
	:MODEL {}

function DebugDrawCommandArrow:__init ( x, y, x1, y1, size, angle )
	self.x = x
	self.y = y
	self.x1 = x1
	self.y1 = y1
	self.size = size
	self.angle = angle
end

function DebugDrawCommandArrow:onDraw ()
	return drawArrow ( self.x, self.y, self.x1, self.y1, self.size, self.angle )
end


--------------------------------------------------------------------
local DebugDrawCommandRay = CLASS: DebugDrawCommandRay ( DebugDrawCommand )
	:MODEL {}

function DebugDrawCommandRay:__init ( x, y, dx, dy)
	self.x = x
	self.y = y
	self.dx = dx
	self.dy = dy
end

function DebugDrawCommandRay:onDraw ()
	return drawRay( self.x, self.y, self.dx, self.dy )
end


--------------------------------------------------------------------
local DebugDrawCommandScript = CLASS: DebugDrawCommandScript ( DebugDrawCommand )
	:MODEL {}

function DebugDrawCommandScript:__init ( func )
	self.func = func
end

function DebugDrawCommandScript:onDraw ()
	return self.func ()
end




--------------------------------------------------------------------
local dummyGroup = DebugDrawQueueDummyGroup ()
local currentDebugDrawQueue = false
local currentDebugDrawQueueGroup = dummyGroup

local function setCurrentDebugDrawQueue ( queue )
	currentDebugDrawQueue = queue
	currentDebugDrawQueueGroup = queue and queue.defaultGroup or dummyGroup
end


--------------------------------------------------------------------
local _DebugDraw = {}

function _DebugDraw.drawCircle ( x, y, radius )
	return currentDebugDrawQueueGroup:drawCircle ( x, y, radius )
end

function _DebugDraw.drawLine ( x, y, x1, y1 )
	return currentDebugDrawQueueGroup:drawLine ( x, y, x1, y1 )
end

function _DebugDraw.drawArrow ( x, y, x1, y1, size, angle )
	return currentDebugDrawQueueGroup:drawArrow ( x, y, x1, y1, size, angle )
end

function _DebugDraw.drawRect ( x, y, x1, y1 )
	return currentDebugDrawQueueGroup:drawRect ( x, y, x1, y1 )
end

function _DebugDraw.drawRay ( x, y, dx, dy )
	return currentDebugDrawQueueGroup:drawRay ( x, y, dx, dy )
end

function _DebugDraw.drawScript ( func )
	return currentDebugDrawQueueGroup:drawScript ( func )
end

function _DebugDraw.getGroup ( key, duration )
	if currentDebugDrawQueue then
		local group = currentDebugDrawQueue:getDebugDrawGroup ( key )
		if duration then
			group:setDuration ( duration )
		end
		return group
	else
		return dummyGroup
	end
end

function _DebugDraw.clearGroup ( key )
	if currentDebugDrawQueue then
		return currentDebugDrawQueue:clearDebugDrawGroup ( key )
	else
		return dummyGroup
	end
end


DebugDrawModule.DebugDrawCommand = DebugDrawCommand
DebugDrawModule.DebugDrawQueue = DebugDrawQueue
DebugDrawModule.DebugDrawQueueGroup = DebugDrawQueueGroup
DebugDrawModule.DebugDrawQueueDummyGroup = DebugDrawQueueDummyGroup
DebugDrawModule.DebugDrawCommandCircle = DebugDrawCommandCircle
DebugDrawModule.DebugDrawCommandRect = DebugDrawCommandRect
DebugDrawModule.DebugDrawCommandLine = DebugDrawCommandLine
DebugDrawModule.DebugDrawCommandArrow = DebugDrawCommandArrow
DebugDrawModule.DebugDrawCommandRay = DebugDrawCommandRay
DebugDrawModule.DebugDrawCommandScript = DebugDrawCommandScript
DebugDrawModule.setCurrentDebugDrawQueue = setCurrentDebugDrawQueue
DebugDrawModule._DebugDraw = _DebugDraw

return DebugDrawModule