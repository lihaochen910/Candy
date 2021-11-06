-- import
local AssetLibraryModule = require 'candy.AssetLibrary'

local DEADLOCK_THRESHOLD = 100
local DEADLOCK_TRACK = 10
local DEADLOCK_TRACK_ENABLED = true
local unpack = unpack

local function tovalue ( v )
	v = v:trim ()

	if value == "true" then
		return true, true
	elseif value == "false" then
		return true, false
	elseif value == "nil" then
		return true, nil
	else
		local n = tonumber ( v )

		if n then
			return true, n
		end

		local s = v:match ( "^' ( .* )'$" )

		if s then
			return true, s
		end

		local s = v:match ( "^\" ( .* )\"$" )

		if s then
			return true, s
		end
	end

	return false
end

local function buildFSMScheme ( scheme )
	assert ( scheme, "FSM Data required" )

	local trackedStates = {}
	local stateFuncs = {}

	local function parseExprJump ( msg )
		local content = msg:match ( "%s*if%s*% ( ( .* )% )%s*" )

		if not content then
			return nil
		end

		content = content:trim ()

		local valueFunc, err = loadEvalScriptWithEnv ( content )
		if not valueFunc then
			_warn ( "failed compiling condition expr:", err )

			return false
		else
			return valueFunc
		end
	end

	for name, stateBody in pairs ( scheme ) do
		local id = stateBody.id
		local jump = stateBody.jump
		local outStates = stateBody.next
		local localName = stateBody.localName
		local stepName = id .. "__step"
		local exitName = id .. "__exit"
		local enterName = id .. "__enter"
		local coroName = id .. "__coroutine"
		local exprJump = false

		if jump then
			for msg, target in pairs ( jump ) do
				local exprFunc = parseExprJump ( msg )

				if exprFunc then
					exprJump = exprJump or {}
					exprJump[ msg ] = exprFunc
				end
			end

			if exprJump then
				for msg, exprFunc in pairs ( exprJump ) do
					local target = jump[ msg ]
					jump[ msg ] = nil
					jump[ exprFunc ] = target
				end
			end
		end

		local function stateStep ( controller, dt, switchCount )
			local nextState, transMsg, transMsgArg = nil
			local forceJumping = controller.forceJumping

			if forceJumping then
				controller.forceJumping = false
				transMsgArg = forceJumping[ 3 ]
				transMsg = forceJumping[ 2 ]
				nextState = forceJumping[ 1 ]
			else
				local out = true

				if controller._currentStateCoroutine then
					out = false
				else
					local coroOut = controller._currentStateCoroutineResult

					if coroOut then
						out = coroOut
						controller._currentStateCoroutineResult = false
					end
				end

				local step = controller[ stepName ]

				if step then
					out = step ( controller, dt )
					dt = 0
				elseif step == nil then
					controller[ stepName ] = false
				end

				if out and outStates then
					nextState = outStates[ out ]

					if not nextState then
						_error ( "! error in state:" .. name )

						if type ( out ) ~= "string" then
							return error ( "output state name expected" )
						end

						error ( "output state not found:" .. tostring ( out ) )
					end
				else
					local pollMsg = controller.pollMsg

					while true do
						transMsg, transMsgArg = pollMsg ( controller )

						if not transMsg then
							return
						end

						nextState = jump and jump[ transMsg ]

						if nextState then
							break
						end
					end
				end
			end

			if DEADLOCK_TRACK_ENABLED then
				switchCount = switchCount + 1

				if switchCount == DEADLOCK_THRESHOLD then
					trackedStates = {}
				elseif DEADLOCK_THRESHOLD < switchCount then
					table.insert ( trackedStates, name )

					if switchCount > DEADLOCK_THRESHOLD + DEADLOCK_TRACK then
						_log ( "state switch deadlock:", switchCount )

						for i, s in ipairs ( trackedStates ) do
							_log ( i, s )
						end

						if getG ( "debugstop" ) then
							debugStop ()
						end

						error ( "TERMINATED" )
					end
				end
			end

			local nextStateBody, nextStateName = nil

			if controller:acceptStateChange ( nextState ) == false then
				return
			end

			local tt = type ( nextState )

			if tt == "string" then
				nextStateName = nextState
				local exit = controller[ exitName ]

				if exit then
					exit ( controller, nextStateName, transMsg, transMsgArg )
				elseif exit == nil then
					controller[ exitName ] = false
				end

				if controller._currentStateCoroutine then
					controller:_terminateFSMStateCoroutine ()
				end
			else
				local l = #nextState
				nextStateName = nextState[ l ]
				local exit = controller[ exitName ]

				if exit then
					exit ( controller, nextStateName, transMsg, transMsgArg )
				elseif exit == nil then
					controller[ exitName ] = false
				end

				if controller._currentStateCoroutine then
					controller:_terminateFSMStateCoroutine ()
				end

				for i = 1, l - 1 do
					local funcName = nextState[ i ]
					local func = controller[ funcName ]

					if func then
						func ( controller, name, nextStateName, transMsg, transMsgArg )
					end
				end
			end

			controller:setState ( nextStateName )

			nextStateBody = scheme[ nextStateName ]

			if not nextStateBody then
				error ( "state body not found:" .. nextStateName, 2 )
			end

			local enterName = nextStateBody.enterName
			local coroName = nextStateBody.coroName
			local nextFunc = nextStateBody.func
			controller.currentStateFunc = nextFunc
			controller.currentExprJump = nextStateBody.exprJump
			local enter = controller[ enterName ]

			if enter then
				enter ( controller, name, transMsg, transMsgArg )
			elseif enter == nil then
				controller[ enterName ] = false
			end

			local coroFunc = controller[ coroName ]

			if coroFunc then
				controller:_startFSMStateCoroutine ( coroFunc, controller, name, transMsg, transMsgArg )
			else
				controller[ coroName ] = false
			end

			controller:updateExprJump ()

			return nextFunc ( controller, dt, switchCount )
		end

		stateBody.func = stateStep
		stateBody.stepName = stepName
		stateBody.enterName = enterName
		stateBody.coroName = coroName
		stateBody.exitName = exitName
		stateBody.exprJump = exprJump
	end

	local startFunc = scheme.start.func
	local startEnterName = scheme.start.enterName
	local startExprJump = scheme.start.exprJump

	scheme[ 0 ] = function  ( controller, dt )
		controller.currentStateFunc = startFunc
		controller.currentExprJump = startExprJump
		local f = controller[ startEnterName ]

		if f then
			f ( controller )
		end

		controller:updateExprJump ()

		return startFunc ( controller, dt, 0 )
	end
end

local function FSMSchemeLoader ( node )
	local path = node:getObjectFile ( "def" )
	local scheme = dofile ( path )

	buildFSMScheme ( scheme )

	return scheme
end

AssetLibraryModule.registerAssetLoader ( "fsm_scheme", FSMSchemeLoader )
