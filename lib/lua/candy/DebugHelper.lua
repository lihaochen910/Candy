local os = MOAIEnvironment.osBrand

DebugHelper = {
	startCrittercism = function (self, k1, k2, k3)
		if os == "iOS" then
			MOAICrittercism.init(k1, k2, k3)

			self.crittercism = true
		end
	end,
	setCodeMark = function (self, s, ...)
		if self.crittercism then
			MOAICrittercism.leaveBreadcrumb(string.format(s, ...))
		end
	end,
	reportUsage = function (self)
		print("---------")
		print("FPS:", MOAISim.getPerformance())
		print("Objects:", MOAISim.getLuaObjectCount())
		print("Memory:")
		table.foreach(MOAISim.getMemoryUsage(), print)
		print("--------")

		if game.scenes then
			for k, s in pairs(game.scenes) do
				local count = table.len(s.objects)

				if count > 0 then
					printf("Object in scene \"%s\": %d", s.name, count)
				end
			end
		end

		print("--------")
	end,
	setDebugEnabled = function (self, d)
		self.debugEnabled = d or false

		if not self.debugger then
			require("clidebugger")

			self.debugger = clidebugger
		end

		MOAIDebugLines.setStyle(MOAIDebugLines.PARTITION_CELLS, 2, 1, 1, 1)
		MOAIDebugLines.setStyle(MOAIDebugLines.PARTITION_PADDED_CELLS, 1, 0.5, 0.5, 0.5)
		MOAIDebugLines.setStyle(MOAIDebugLines.PROP_WORLD_BOUNDS, 2, 0.75, 0.75, 0.75)
	end,
	pause = function (self, msg)
		if self.debugger then
			return self.debugger.pause(msg)
		end
	end,
	exitOnError = function (self, enabled)
		enabled = enabled ~= false

		if enabled then
			MOAISim.setTraceback(function (msg)
				print(debug.traceback(msg, 2))
				os.exit()
			end)
		end
	end
}

Profiler = {
	coroWrapped = false,
	start = function (self, time, reportPath)
		local ProFi = require("ProFi")
		self.ProFi = ProFi

		if not self.coroWrapped then
			self.coroWrapped = true
			local MOAICoroutineIT = MOAICoroutine.getInterfaceTable()
			local _run = MOAICoroutineIT.run

			function MOAICoroutineIT:run(func, ...)
				return _run(self, function (...)
					ProFi:start()

					return func(...)
				end, ...)
			end
		end

		if time then
			laterCall(time, function ()
				self:stop()

				if reportPath then
					self:writeReport(reportPath)
				end
			end)
		end

		_stat("start profiler...")
		ProFi:start()
	end,
	stop = function (self)
		self.ProFi:stop()
		_stat("stop profiler...")
	end,
	writeReport = function (self, path)
		_statf("writing profiler report to : %s", path)
		self.ProFi:writeReport(path)
	end
}

local tracingCoroutines = setmetatable ( {}, {
	__mode = "kv"
} )

function _reportTracingCoroutines ()
	local count = {}
	local countActive = {}

	for coro, tb in pairs ( tracingCoroutines ) do
		count[ tb ] = ( count[ tb ] or 0 ) + 1

		print ( tb )

		if coro:isBusy () then
			countActive[ tb ] = (countActive[ tb ] or 0) + 1
		else
			print ( "inactive coro" )
			print ( tb )
		end
	end

	for tb, c in pairs ( count ) do
		if c > 1 then
			print ( "------CORO COUNT:", c, countActive[ tb ] )
			print ( tb )
		end
	end
end

local oldNew = MOAICoroutine.new
function MOAICoroutine.new ( f, ... )
	local coro = oldNew ( f, ... )
	tracingCoroutines[ coro ] = debug.traceback ( 3 )
	return coro
end

function tracebackMOAICoroutine ( coro )
	return tracingCoroutines[ coro ]
end

---@class DebugCommand
local DebugCommand = CLASS: DebugCommand ()
	:MODEL {}

function DebugCommand:onExec ()
end

function DebugCommand:finish ()
end

function DebugCommand:fail ()
end

function enableInfiniteLoopChecking ()
	local function _callback ( funcInfo )
		local funcInfo = debug.getinfo ( 2, "Sl" )

		return print ( ">>", funcInfo.source, funcInfo.currentline )
	end

	local MOAICoroutineIT = MOAICoroutine.getInterfaceTable ()
	local _run = MOAICoroutineIT.run

	function MOAICoroutineIT:run ( func, ... )
		return _run ( self, function ( ... )
			debug.sethook ( _callback, "l" )
			return func ( ... )
		end, ... )
	end

	debug.sethook ( _callback, "l" )
end

local function defaultErrorHandler ( status)
	print ( "ERROR:", status )
	print ( debug.traceback ( 2 ) )
end

local function _innerTry ( errFunc, ok, ... )
	if ok then
		return ...
	end

	local status = ...
	errFunc = errFunc or defaultErrorHandler
	errFunc ( status )

	return nil
end

function try ( func, errFunc )
	return _innerTry ( errFunc, pcall ( func ) )
end

function singletraceback ( level )
	local info = debug.getinfo ( ( level or 2 ) + 1, "nSl" )
	return info and string.format ( "%s:%d", info.source, info.currentline ) or "???"
end

local trackingMOAIClasses = {}
local trackingMOAIObjects = {}

function trackMOAIObject ( clas )
	trackingMOAIClasses[ clas ] = true
	local oldNew = clas.new
	local t = table.weak_k ()
	trackingMOAIObjects[ clas ] = t

	function clas.new ( ... )
		local obj = oldNew ( ... )
		t[ obj ] = debug.traceback ( 3 )
		return obj
	end
end

function reportTrackingMOAIClasses ()
	print ( "___report moai class tracking:", clas )

	for clas in pairs ( trackingMOAIClasses ) do
		reportTrackingMOAIObject ( clas )
	end

	print ( "" )
end

function reportTrackingMOAIObject ( clas )
	local t = trackingMOAIObjects[ clas ]

	if not t then
		_log ( "not tracking", clas )
		return false
	end

	_log ( "allocated moai object:", clas )

	for obj, trace in pairs ( t ) do
		_log ( obj )
		_log ( trace )
	end

	_log ( "----" )
end

return {}