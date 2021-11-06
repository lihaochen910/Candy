-- import
local SignalModule = require 'candy.signal'

local pairs = pairs
local ipairs = ipairs
local setmetatable = setmetatable
local unpack = unpack
local insert = table.insert
local remove = table.remove
local yield = coroutine.yield
local select = select
local _block = MOAICoroutine.blockOnAction

local function blockCurrentCoroutine ( action )
	local thread = MOAICoroutine.currentThread ()

	if action:getParent () == thread then
		while action:isBusy () do
			coroutine.yield ()
		end
	else
		return _block ( action )
	end
end

local emitSignal = SignalModule.emitSignal
local signalDisconnect = SignalModule.signalDisconnect
local signalConnect = SignalModule.signalConnect
local signalConnectMethod = SignalModule.signalConnectMethod
local signalConnectFunc = SignalModule.signalConnectFunc
local getGlobalSignal = SignalModule.getGlobalSignal
local isSignal = SignalModule.isSignal

---@class Actor
local Actor = CLASS: Actor ()
    :MODEL {}

function Actor:__init ()
	self.state = ""
	self.msgListeners = {}
	self.coroutines = false
end

function Actor:connect ( sig, slot )
	return self:connectForObject ( self, sig, slot )
end

function Actor:disconnect ( sig )
	return self:disconnectForObject ( self, sig )
end

function Actor:connectForObject ( obj, sig, slot )
	local connectedSignals = self.connectedSignals

	if not connectedSignals then
		connectedSignals = {}
		self.connectedSignals = connectedSignals
	end

	local st = type ( sig )

	if st == "string" then
		sig = getGlobalSignal ( sig )
	end

	if not isSignal ( sig ) then
		return _error ( "not a valid signal" )
	end

	local tt = type ( slot )

	if tt == "function" then
		local func = slot
		signalConnectFunc ( sig, func )
		insert ( connectedSignals, { obj, sig, func } )
	elseif tt == "string" then
		local methodName = slot
		if type ( obj[ methodName ] ) ~= "function" then
			error ( "Method not found:" .. methodName, 2 )
		end

		signalConnectMethod ( sig, obj, methodName )
		insert ( connectedSignals, { obj, sig, obj } )
	else
		error ( "invalid slot type:" .. tt )
	end
end

function Actor:disconnectForObject ( obj, sig )
	local connectedSignals = self.connectedSignals

	if not connectedSignals then
		return
	end

	local st = type ( sig )

	if st == "string" then
		sig = getGlobalSignal ( sig )
	end

	if not isSignal ( sig ) then
		return _error ( "not a valid signal" )
	end

	local newConnectedSignals = {}

	for i, entry in ipairs ( connectedSignals ) do
		local owner, sig0, key = unpack ( entry )
		if sig0 == sig and owner == obj then
			signalDisconnect ( sig, key )
		else
			insert ( newConnectedSignals, entry )
		end
	end

	self.connectedSignals = newConnectedSignals
end

function Actor:emit ( sig, ... )
	return emitSignal ( sig, ... )
end

function Actor:disconnectAll ()
	local connectedSignals = self.connectedSignals

	if not connectedSignals then
		return
	end

	for i, entry in ipairs ( connectedSignals ) do
		local owner, sig, obj = unpack ( entry )
		signalDisconnect ( sig, obj )
	end

	self.connectedSignals = false
end

function Actor:disconnectAllForObject ( owner )
	local connectedSignals = self.connectedSignals

	if not connectedSignals then
		return
	end

	local newSignals = {}

	for i, entry in ipairs ( connectedSignals ) do
		local owner1, sig, obj = unpack ( entry )
		if owner == owner1 then
			signalDisconnect ( sig, obj )
		else
			insert ( newSignals, entry )
		end
	end

	self.connectedSignals = newSignals
end

function Actor:addMsgListener ( listener, append )
	if append then
		insert ( self.msgListeners, listener )
	else
		insert ( self.msgListeners, 1, listener )
	end
	return listener
end

function Actor:removeMsgListener ( listener )
	if not listener then
		return
	end

	local msgListeners = self.msgListeners
	local idx = table.index ( msgListeners, listener )

	if idx then
		msgListeners[ idx ] = false
	end
end

function Actor:clearMsgListeners ()
	self.msgListeners = {}
end

function Actor:tell ( msg, data, source )
	for i, listener in pairs ( self.msgListeners ) do
		if listener then
			local r = listener ( msg, data, source )
			if r == "cancel" then
				break
			end
		end
	end
end

local function _coroutineFuncWrapper ( coro, func, ... )
	func ( ... )
end

local function _coroutineMethodWrapper ( coro, func, obj, ... )
	func ( obj, ... )
end

function Actor:_weakHoldCoroutine ( newCoro )
	local coroutines = self.coroutines

	if not coroutines then
		coroutines = {
			[ newCoro ] = true
		}
		self.coroutines = coroutines
		return newCoro
	end

	local dead = {}

	for coro in pairs ( coroutines ) do
		if coro:isDone () then
			dead[ coro ] = true
			coro._func = nil
		end
	end

	for coro in pairs ( dead ) do
		coroutines[ coro ] = nil
	end

	coroutines[ newCoro ] = true
	return newCoro
end

function Actor:findCoroutine ( method )
	if self.coroutines then
		for coro in pairs ( self.coroutines ) do
			if coro._func == method and not coro:isDone () then
				return coro
			end
		end
	end

	return nil
end

function Actor:findAllCoroutines ( method )
	local found = {}

	if self.coroutines then
		for coro in pairs ( self.coroutines ) do
			if coro._func == method and not coro:isDone () then
				table.insert ( found, coro )
			end
		end
	end

	return found
end

function Actor:findAndStopCoroutine ( method )
	if self.coroutines then
		for coro in pairs ( self.coroutines ) do
			if coro._func == method and not coro:isDone () then
				coro:stop ()
				coro._func = nil
			end
		end
	end
end

function Actor:hasRunningCoroutine ( method )
	if not self.coroutines then
		return false
	end

	for coro in pairs ( self.coroutines ) do
		if coro._func == method and not coro:isDone () then
			return true
		end
	end
end

function Actor:replaceCoroutine ( method, ... )
	self:findAndStopCoroutine ( method )
	return self:addCoroutine ( method, ... )
end

function Actor:replaceDaemonCoroutine ( method )
	self:findAndStopCoroutine ( method )
	return self:addDaemonCoroutine ( method )
end

function Actor:affirmCoroutine ( method, ... )
	local coro = self:findCoroutine ( method )

	if coro and coro:isBusy () then
		return coro
	end

	return self:addCoroutine ( method, ... )
end

local newCoroutine = MOAICoroutine.new
function Actor:_createCoroutine ( defaultParent, func, obj, ... )
	local coro = newCoroutine ()

	if defaultParent then
		coro:setDefaultParent ( true )
	end

	local tt = type ( func )

	if tt == "string" then
		local _func = obj[ func ]
		assert ( type ( _func ) == "function", "method not found:" .. func )
		coro._func = func
		coro:run ( _coroutineMethodWrapper, coro, _func, obj, ... )
	elseif tt == "function" then
		coro._func = func
		coro:run ( _coroutineFuncWrapper, coro, func, ... )
	else
		error ( "unknown coroutine func type:" .. tt )
	end

	local coro = self:_weakHoldCoroutine ( coro )
	return coro
end

function Actor:addCoroutineP ( func, ... )
	return self:addCoroutinePFor ( self, func, ... )
end

function Actor:addCoroutine ( func, ... )
	return self:addCoroutineFor ( self, func, ... )
end

function Actor:addCoroutinePFor ( obj, func, ... )
	return self:_createCoroutine ( true, func, obj, ... )
end

function Actor:addCoroutineFor ( obj, func, ... )
	return self:_createCoroutine ( false, func, obj, ... )
end

function Actor:getCurrentCoroutine ()
	return MOAICoroutine.currentThread ()
end

local function _coroDaemonInner ( obj, f, ... )
	local inner = self:addCoroutineFor ( obj, f, ... )
end

local function _coroDaemon ( self, obj, f, ... )
	local inner = self:addCoroutineFor ( obj, f, ... )
	while inner:isBusy () do
		yield ()
	end
end

function Actor:addDaemonCoroutine ( f, ... )
	return self:addDaemonCoroutineFor ( self, f, ... )
end

function Actor:addDaemonCoroutineFor ( obj, f, ... )
	local daemon = MOAICoroutine.new ()
	daemon:setDefaultParent ( true )
	daemon:run ( _coroDaemon, self, obj, f, ... )
	return self:_weakHoldCoroutine ( daemon )
end

function Actor:clearCoroutines ()
	if not self.coroutines then
		return
	end

	for coro in pairs ( self.coroutines ) do
		coro:stop ()
		coro._func = nil
	end

	self.coroutines = false
end

function Actor:setState ( state )
	local state0 = self.state

	if state0 == state then
		return
	end

	self.state = state

	self:tell ( "state.change", { state, state0 } )

	local onStateChange = self.onStateChange
	if onStateChange then
		onStateChange ( self, state, state0 )
	end
end

function Actor:getState ()
	return self.state
end

function Actor:inState ( ... )
	for i = 1, select ( "#", ... ) do
		local s = select ( i, ... )

		if s == self.state then
			return s
		end
	end

	return false
end

local stringfind = string.find
local function _isStartWith ( a, b, b1, ... )
	if stringfind ( a, b ) == 1 then
		return true
	end

	if b1 then
		return _isStartWith ( a, b1, ... )
	end

	return false
end

function Actor:inStateGroup ( s1, ... )
	return _isStartWith ( self.state, s1, ... )
end

function Actor:waitStateEnter ( ... )
	local count = select ( "#", ... )

	if count == 1 then
		local s = select ( 1, ... )

		while true do
			local ss = self.state

			if ss == s then
				return ss
			end

			yield ()
		end
	else
		while true do
			local ss = self.state

			for i = 1, count do
				if ss == select ( i, ... ) then
					return ss
				end
			end

			yield ()
		end
	end
end

function Actor:waitStateExit ( s )
	while self.state == s do
		yield ()
	end

	return self.state
end

function Actor:waitStateChange ()
	local s = self.state
	while s == self.state do
		yield ()
	end
	return self.state
end

function Actor:waitFieldEqual ( name, v )
	while true do
		if self[ name ] == v then
			return true
		end
		yield ()
	end
end

function Actor:waitFieldNotEqual ( name, v )
	while true do
		if self[ name ] ~= v then
			return true
		end
		yield ()
	end
end

function Actor:waitFieldTrue ( name )
	while true do
		if self[ name ] then
			return true
		end
		yield ()
	end
end

function Actor:waitFieldFalse ( name )
	while true do
		if not self[ name ] then
			return true
		end
		yield ()
	end
end

function Actor:waitGlobalSignal ( signame )
	local sig = getGlobalSignal ( signame )
	return self:waitSignal ( sig )
end

function Actor:waitSignal ( sig )
	assert ( isSignal ( sig ) )

	local seq0 = sig:getSeq ()
	while true do
		yield ()
		if sig:getSeq () ~= seq0 then
			break
		end
	end
end

function Actor:waitFrames ( f )
	for i = 1, f do
		yield ()
	end
end

local timerCache = {}
function Actor:waitTime ( t )
	if t > 1000 then
		error ( "??? wrong wait time ???" .. t )
	end

	local timer = remove ( timerCache, 1 )

	if not timer then
		timer = MOAITimer.new ()
	else
		timer:setTime ( 0 )
	end

	timer:setSpan ( t )
	timer:start ()
	blockCurrentCoroutine ( timer )
	insert ( timerCache, timer )
end

function Actor:timeoutSignal ( sig, t )
	local result = nil

	local function f ( ... )
		result = {
			...
		}
	end

	connectSignalFunc ( sig, f )

	local t0 = self:getTime ()
	while not result do
		if t <= self:getTime () - t0 then
			break
		end
		yield ()
	end

	disconnectSignal ( sig, f )

	if result then
		return true, unpack ( result )
	else
		return false
	end
end

local currentThread = MOAICoroutine.currentThread

function Actor:pauseThisThread ( noyield )
	local th = currentThread ()

	if th then
		th:pause ()
		if not noyield then
			return yield ()
		end
	else
		error ( "no thread to pause" )
	end
end

function Actor:wait ( a )
	local tt = type ( a )

	if tt == "number" then
		return self:waitTime ( a )
	elseif tt == "table" then
		return self:waitActionBoth ( a )
	elseif tt == "string" then
		return self:waitSignal ( a )
	elseif a then
		return blockCurrentCoroutine ( a )
	end
end

function Actor:skip ( duration )
	local elapsed = 0
	while duration > elapsed do
		elapsed = elapsed + yield ()
	end
end

return Actor