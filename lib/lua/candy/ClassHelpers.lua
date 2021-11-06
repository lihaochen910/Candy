-- module
local ClassHelperModule = {}

local function _wrapMethod ( class, fieldname, methodname, arg, ... )
	local selfPart
	if fieldname:startwith ( ':' ) then
		selfPart = 'self' .. fieldname
	else
		selfPart = 'self.' .. fieldname
	end
	local debugName = string.gsub ( fieldname, '[%.% (%):]', '_') ..'_'..methodname
	local code = string.format (
				"local function %s ( self, ... ) return %s:%s ( ... ) end return %s ",
				debugName,
				selfPart,
				methodname,
				debugName
			)
	local f = loadstring (
				code
			) ()
	class[ methodname ] = f
end

local function _wrapMethods ( class, fieldname, methodnames )
	for i,n in ipairs (methodnames) do
		_wrapMethod ( class, fieldname, n )
	end
end

local match = string.match
local function _wrapMoaiMethod ( interfaceTable, class, fieldname, methodname, arg )
	local selfPart = nil

	if fieldname:startwith ( ":" ) then
		selfPart = "self" .. fieldname
	else
		selfPart = "self." .. fieldname
	end

	local methodname, tail = match ( methodname, "(%w+)(@?)" )
	local hasArg = tail and tail ~= ""
	local debugName = string.gsub ( fieldname, "[%.%(%):]", "_" ) .. "_" .. methodname
	local code = nil

	if hasArg then
		code = string.format ( [[
				local _func, print = ...
				local function %s( self, ... ) return _func( %s, ... ) end
				return %s 
				]], debugName, selfPart, debugName )
	else
		code = string.format ( [[
				local _func, print = ...
				local function %s( self ) return _func( %s ) end
				return %s 
				]], debugName, selfPart, debugName )
	end

	local func = assert ( interfaceTable[ methodname ], methodname .. " not found in " .. tostring ( interfaceTable ) )
	local f = loadstring ( code )( func, print )
	class[ methodname ] = f
end

local function _wrapMoaiMethods ( interfaceTable, class, fieldname, methodnames )
	for i, n in ipairs ( methodnames ) do
		_wrapMoaiMethod ( interfaceTable, class, fieldname, n )
	end
end

local MOAINodeIT = MOAINode.getInterfaceTable ()
local MOAINodeGetAttr = MOAINodeIT.getAttr
local MOAINodeSetAttr = MOAINodeIT.setAttr
local MOAINodeSetAttrUnsafe = MOAINodeIT.setAttrUnsafe
local MOAINodeSeekAttr = MOAINodeIT.seekAttr
local MOAINodeMoveAttr = MOAINodeIT.moveAttr

local function _wrapAttrGetter ( class, fieldname, attr, methodname )
	local selfPart
	if fieldname:startwith ( ':' ) then
		selfPart = 'self'..fieldname
	else
		selfPart = 'self.'..fieldname
	end
	local f = loadstring (
		string.format (
			[[
				local _func = ...
					return function ( self )
						return _func ( %s, %d )
					end
			]]
			, selfPart, attr )
	)
	class[ methodname ] = f ( MOAINodeGetAttr )
end

local function _wrapAttrGetterBoolean ( class, fieldname, attr, methodname )
	local selfPart
	if fieldname:startwith ( ':' ) then
		selfPart = 'self'..fieldname
	else
		selfPart = 'self.'..fieldname
	end
	local f = loadstring (
		string.format (
			[[
				local _func = ...
					return function ( self )
						return _func ( %s, %d ) ~= 0
					end
			]]
			,selfPart, attr )
	)
	class[ methodname ] = f ( MOAINodeGetAttr )
end

local function _wrapAttrSetter ( class, fieldname, attr, methodname, unsafe )
	local selfPart
	if fieldname:startwith ( ':' ) then
		selfPart = 'self' .. fieldname
	else
		selfPart = 'self.' .. fieldname
	end
	local f = loadstring (
		string.format (
			[[
				local _func = ...
					return function ( self, v )
						return _func ( %s, %d, v )
					end
			]]
			,selfPart, attr )
		)
	class[ methodname ] = f ( unsafe and MOAINodeSetAttrUnsafe or MOAINodeSetAttr )
end

function _wrapAttrSetterUnsafe ( class, fieldname, attr, methodname )
	return _wrapAttrSetter ( class, fieldname, attr, methodname, true )
end

local function _wrapAttrTweener ( tweenType, class, fieldname, attr, methodname )
	local selfPart = nil

	if fieldname:startwith ( ":" ) then
		selfPart = "self" .. fieldname
	else
		selfPart = "self." .. fieldname
	end

	local f = loadstring ( string.format (
			[[
				local _func = ...
				return function ( self, v, t, easeType )
					return _func ( %s, %d, v, t, easeType )
				end
			]], selfPart, attr ) )

	if tweenType == "seek" then
		class[ methodname ] = f ( MOAINodeSeekAttr )
	elseif tweenType == "move" then
		class[ methodname ] = f ( MOAINodeMoveAttr )
	else
		error ()
	end
end

local function _wrapAttrSeeker ( ... )
	return _wrapAttrTweener ( "seek", ... )
end

local function _wrapAttrMover ( ... )
	return _wrapAttrTweener ( "move", ... )
end

local function _wrapAttrGetSet ( class, fieldname, attr, propertyName )
	_wrapAttrGetter ( class, fieldname, attr, 'get' .. propertyName )
	_wrapAttrSetter ( class, fieldname, attr, 'set' .. propertyName )
end

local function _wrapAttrGetSet2 ( class, fieldname, attr, propertyName )
	_wrapAttrGetter ( class, fieldname, attr, 'get' .. propertyName )
	_wrapAttrSetter ( class, fieldname, attr, 'set' .. propertyName )
end

local function _wrapAttrSeekMove ( class, fieldname, attr, propertyName )
	_wrapAttrSeeker ( class, fieldname, attr, "seek" .. propertyName )
	_wrapAttrMover ( class, fieldname, attr, "move" .. propertyName )
end

local function _wrapAttrGetSetSeekMove ( class, fieldname, attr, propertyName )
	_wrapAttrGetter ( class, fieldname, attr, 'get' .. propertyName )
	_wrapAttrSetter ( class, fieldname, attr, 'set' .. propertyName )
	_wrapAttrSeeker ( class, fieldname, attr, 'seek' .. propertyName )
	_wrapAttrMover ( class, fieldname, attr, 'move' .. propertyName )
end


ClassHelperModule.wrapMethod = _wrapMethod
ClassHelperModule.wrapMethods = _wrapMethods
ClassHelperModule.wrapMoaiMethod = _wrapMoaiMethod
ClassHelperModule.wrapMoaiMethods = _wrapMoaiMethods
ClassHelperModule.wrapAttrGetter = _wrapAttrGetter
ClassHelperModule.wrapAttrGetterBoolean = _wrapAttrGetterBoolean
ClassHelperModule.wrapAttrSetter = _wrapAttrSetter
ClassHelperModule.wrapAttrSeeker = _wrapAttrSeeker
ClassHelperModule.wrapAttrMover = _wrapAttrMover
ClassHelperModule.wrapAttrGetSet = _wrapAttrGetSet
ClassHelperModule.wrapAttrGetSet2 = _wrapAttrGetSet2
ClassHelperModule.wrapAttrSeekMove = _wrapAttrSeekMove
ClassHelperModule.wrapAttrGetSetSeekMove = _wrapAttrGetSetSeekMove

return ClassHelperModule