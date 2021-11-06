-- import
local ClassHelperModule = require 'candy.ClassHelpers'
local moaiHelpersModule = require 'candy.helper.MOAIHelpers'

-- module
local MOAIPropHelpersModule = {}

--------PriorityNameTable
local priorityNames = {}
function addPriorityName ( t )
	for k, v in pairs ( t ) do
		priorityNames[ k ] = v
	end
end

function getPriorityByName ( name )
	return priorityNames[ name ]
end

function getPriorityNameTable ()
	return priorityNames
end

MOAIPropHelpersModule.addPriorityName = addPriorityName
MOAIPropHelpersModule.getPriorityByName = getPriorityByName
MOAIPropHelpersModule.getPriorityNameTable = getPriorityNameTable

-------------------
local GL_FUNC_ADD 				= assert ( MOAIProp.GL_FUNC_ADD )
local GL_FUNC_SUBTRACT 			= assert ( MOAIProp.GL_FUNC_SUBTRACT )
local GL_FUNC_REVERSE_SUBTRACT 	= assert ( MOAIProp.GL_FUNC_REVERSE_SUBTRACT )

local GL_SRC_ALPHA              = assert ( MOAIProp.GL_SRC_ALPHA )
local GL_DST_COLOR 				= assert ( MOAIProp.GL_DST_COLOR )
local GL_DST_ALPHA 				= assert ( MOAIProp.GL_DST_ALPHA )
local GL_ONE_MINUS_SRC_ALPHA    = assert ( MOAIProp.GL_ONE_MINUS_SRC_ALPHA )
local GL_ONE_MINUS_DST_ALPHA    = assert ( MOAIProp.GL_ONE_MINUS_DST_ALPHA )
local GL_ZERO                   = assert ( MOAIProp.GL_ZERO )
local GL_ONE                    = assert ( MOAIProp.GL_ONE )

local DEPTH_TEST_DISABLE        = assert ( MOAIProp.DEPTH_TEST_DISABLE )
local DEPTH_TEST_NEVER          = assert ( MOAIProp.DEPTH_TEST_NEVER )
local DEPTH_TEST_ALWAYS         = assert ( MOAIProp.DEPTH_TEST_ALWAYS )
local DEPTH_TEST_LESS           = assert ( MOAIProp.DEPTH_TEST_LESS )
local DEPTH_TEST_LESS_EQUAL     = assert ( MOAIProp.DEPTH_TEST_LESS_EQUAL )
local DEPTH_TEST_GREATER        = assert ( MOAIProp.DEPTH_TEST_GREATER )
local DEPTH_TEST_GREATER_EQUAL  = assert ( MOAIProp.DEPTH_TEST_GREATER_EQUAL )
local DEPTH_TEST_NOTEQUAL  		= assert ( MOAIProp.DEPTH_TEST_NOTEQUAL )

local getBuiltinShader          = MOAIShaderMgr.getShader
local DECK2D_TEX_ONLY_SHADER    = MOAIShaderMgr.DECK2D_TEX_ONLY_SHADER
local DECK2D_SHADER             = MOAIShaderMgr.DECK2D_SHADER


----------ATTR HELPERS
local tmpNode  = MOAIColor.new ()

local getAttr  = tmpNode.getAttr
local setAttr  = tmpNode.setAttr
local seekAttr = tmpNode.seekAttr
local moveAttr = tmpNode.moveAttr

local yield = coroutine.yield

local INHERIT_TRANSFORM = MOAIProp.INHERIT_TRANSFORM
local TRANSFORM_TRAIT   = MOAIProp.TRANSFORM_TRAIT

local INHERIT_LOC       = MOAIProp.INHERIT_LOC
local ATTR_TRANSLATE    = MOAIProp.ATTR_TRANSLATE

local INHERIT_COLOR     = MOAIProp.INHERIT_COLOR
local COLOR_TRAIT       = MOAIProp.COLOR_TRAIT

local ATTR_ROTATE_QUAT  = MOAIProp.ATTR_ROTATE_QUAT

local ATTR_LOCAL_VISIBLE= MOAIProp.ATTR_LOCAL_VISIBLE
local ATTR_VISIBLE      = MOAIProp.ATTR_VISIBLE
local INHERIT_VISIBLE   = MOAIProp.INHERIT_VISIBLE

local ATTR_PARTITION 	= MOAIProp.ATTR_PARTITION
local ATTR_INDEX        = MOAIProp.ATTR_INDEX
local ATTR_SHADER       = MOAIGraphicsProp.ATTR_SHADER
local ATTR_BLEND_MODE   = MOAIGraphicsProp.ATTR_BLEND_MODE
local ATTR_SCISSOR_RECT = MOAIGraphicsProp.ATTR_SCISSOR_RECT

local ATTR_R_COL        = MOAIColor.ATTR_R_COL
local ATTR_G_COL        = MOAIColor.ATTR_G_COL
local ATTR_B_COL        = MOAIColor.ATTR_B_COL
local ATTR_A_COL        = MOAIColor.ATTR_A_COL

function extractColor ( m )
	local r = getAttr ( m, ATTR_R_COL )
	local g = getAttr ( m, ATTR_G_COL )
	local b = getAttr ( m, ATTR_B_COL )
	local a = getAttr ( m, ATTR_A_COL )
	return r,g,b,a
end

function inheritLoc ( p1, p2 )
	return p1:setAttrLink ( INHERIT_LOC, p2, TRANSFORM_TRAIT )
end

function linkRot ( p1, p2, x,y,z )
	if x~=false then p1:setAttrLink ( MOAIProp.ATTR_X_ROT, p2, MOAIProp.ATTR_X_ROT ) end
	if y~=false then p1:setAttrLink ( MOAIProp.ATTR_Y_ROT, p2, MOAIProp.ATTR_Y_ROT ) end
	if z~=false then p1:setAttrLink ( MOAIProp.ATTR_Z_ROT, p2, MOAIProp.ATTR_Z_ROT ) end
end

function linkScl ( p1, p2, x,y,z )
	if x~=false then p1:setAttrLink ( MOAIProp.ATTR_X_SCL, p2, MOAIProp.ATTR_X_SCL ) end
	if y~=false then p1:setAttrLink ( MOAIProp.ATTR_Y_SCL, p2, MOAIProp.ATTR_Y_SCL ) end
	if z~=false then p1:setAttrLink ( MOAIProp.ATTR_Z_SCL, p2, MOAIProp.ATTR_Z_SCL ) end
end

function linkLoc ( p1, p2, x,y,z )
	if x~=false then p1:setAttrLink( MOAIProp.ATTR_X_LOC, p2, MOAIProp.ATTR_X_LOC ) end
	if y~=false then p1:setAttrLink( MOAIProp.ATTR_Y_LOC, p2, MOAIProp.ATTR_Y_LOC ) end
	if z~=false then p1:setAttrLink( MOAIProp.ATTR_Z_LOC, p2, MOAIProp.ATTR_Z_LOC ) end
end


function linkWorldLoc ( p1, p2, x,y,z )
	if x~=false then p1:setAttrLink ( MOAIProp.ATTR_X_LOC, p2, MOAIProp.ATTR_WORLD_X_LOC ) end
	if y~=false then p1:setAttrLink ( MOAIProp.ATTR_Y_LOC, p2, MOAIProp.ATTR_WORLD_Y_LOC ) end
	if z~=false then p1:setAttrLink ( MOAIProp.ATTR_Z_LOC, p2, MOAIProp.ATTR_WORLD_Z_LOC ) end
end


function linkWorldScl ( p1, p2, x,y,z )
	if x~=false then p1:setAttrLink ( MOAIProp.ATTR_X_SCL, p2, MOAIProp.ATTR_WORLD_X_SCL ) end
	if y~=false then p1:setAttrLink ( MOAIProp.ATTR_Y_SCL, p2, MOAIProp.ATTR_WORLD_Y_SCL ) end
	if z~=false then p1:setAttrLink ( MOAIProp.ATTR_Z_SCL, p2, MOAIProp.ATTR_WORLD_Z_SCL ) end
end


function linkPiv ( p1, p2, x,y,z )
	if x~=false then p1:setAttrLink ( MOAIProp.ATTR_X_PIV, p2, MOAIProp.ATTR_X_PIV ) end
	if y~=false then p1:setAttrLink ( MOAIProp.ATTR_Y_PIV, p2, MOAIProp.ATTR_Y_PIV ) end
	if z~=false then p1:setAttrLink ( MOAIProp.ATTR_Z_PIV, p2, MOAIProp.ATTR_Z_PIV ) end
end

function linkTransform ( p1, p2 )
	linkLoc ( p1, p2 )
	linkScl ( p1, p2 )
	linkRot ( p1, p2 )
	linkPiv ( p1, p2 )
end

function linkPartition ( p1, p2 )
	return p1:setAttrLink ( ATTR_PARTITION, p2, ATTR_PARTITION )
end

function linkIndex ( p1, p2 )
	return p1:setAttrLink ( ATTR_INDEX, p2, ATTR_INDEX )
end

function linkBlendMode ( p1, p2 )
	p1:setAttrLink ( ATTR_BLEND_MODE, p2, ATTR_BLEND_MODE )
end

function clearLinkPartition ( p1 )
	return p1:clearAttrLink ( ATTR_PARTITION )
end

function clearLinkIndex ( p1 )
	return p1:clearAttrLink ( ATTR_INDEX )
end

function clearLinkBlendMode ( p1 )
	p1:clearAttrLink ( ATTR_BLEND_MODE )
end

function inheritTransform ( p1, p2 )
	return p1:setAttrLink ( INHERIT_TRANSFORM, p2, TRANSFORM_TRAIT )
end

function inheritColor ( p1, p2 )
	return p1:setAttrLink ( INHERIT_COLOR, p2, COLOR_TRAIT )
end

function linkColor ( p1, p2 )
	p1:setAttrLink ( ATTR_R_COL, p2, ATTR_R_COL )
	p1:setAttrLink ( ATTR_G_COL, p2, ATTR_G_COL )
	p1:setAttrLink ( ATTR_B_COL, p2, ATTR_B_COL )
	p1:setAttrLink ( ATTR_A_COL, p2, ATTR_A_COL )
end

function linkColorTrait ( p1, p2 )
	p1:setAttrLink ( COLOR_TRAIT, p2, COLOR_TRAIT )
end

function inheritVisible ( p1, p2 ) 
	return p1:setAttrLink ( INHERIT_VISIBLE, p2, ATTR_VISIBLE )
end

function linkVisible ( p1, p2 ) 
	return p1:setAttrLink ( ATTR_VISIBLE, p2, ATTR_VISIBLE )
end

function linkLocalVisible ( p1, p2 ) 
	return p1:setAttrLink ( ATTR_LOCAL_VISIBLE, p2, ATTR_LOCAL_VISIBLE )
end

function clearInheritVisible ( p1 )
	p1:clearAttrLink ( INHERIT_VISIBLE )
end

function inheritTransformColor ( p1, p2 )
	inheritTransform ( p1, p2 )
	return inheritColor ( p1, p2 )
end

function inheritTransformColorVisible ( p1, p2 )
	inheritTransformColor ( p1, p2 )
	return inheritVisible ( p1, p2 )
end

function inheritPartition ( p1, p2 )
	p1:setAttrLink ( ATTR_PARTITION, p2, ATTR_PARTITION )
end

function linkShader ( p1, p2 )
	p1:setAttrLink ( ATTR_SHADER, p2, ATTR_SHADER )
end

function linkScissorRect ( p1, p2 )
	p1:setAttrLink ( ATTR_SCISSOR_RECT, p2, ATTR_SCISSOR_RECT )
end

function clearLinkRot ( p1 )
	p1:clearAttrLink ( MOAIProp.ATTR_X_ROT )
	p1:clearAttrLink ( MOAIProp.ATTR_Y_ROT )
	p1:clearAttrLink ( MOAIProp.ATTR_Z_ROT )
end

function clearLinkScl ( p1 )
	p1:clearAttrLink ( MOAIProp.ATTR_X_SCL )
	p1:clearAttrLink ( MOAIProp.ATTR_Y_SCL )
	p1:clearAttrLink ( MOAIProp.ATTR_Z_SCL )
end

function clearLinkLoc ( p1 )
	p1:clearAttrLink ( MOAIProp.ATTR_X_LOC )
	p1:clearAttrLink ( MOAIProp.ATTR_Y_LOC )
	p1:clearAttrLink ( MOAIProp.ATTR_Z_LOC )
end

function clearLinkPiv ( p1 )
	p1:clearAttrLink ( MOAIProp.ATTR_X_PIV )
	p1:clearAttrLink ( MOAIProp.ATTR_Y_PIV )
	p1:clearAttrLink ( MOAIProp.ATTR_Z_PIV )
end

function clearLinkColor ( p1 )
	p1:clearAttrLink ( ATTR_R_COL )
	p1:clearAttrLink ( ATTR_G_COL )
	p1:clearAttrLink ( ATTR_B_COL )
	p1:clearAttrLink ( ATTR_A_COL )
	p1:clearAttrLink ( COLOR_TRAIT )
	p1:clearAttrLink ( INHERIT_COLOR )
end

function clearInheritColor ( p1 )
	p1:clearAttrLink ( INHERIT_COLOR )
end

function clearLinkTransform ( p1 )
	clearLinkLoc ( p1 )
	clearLinkScl ( p1 )
	clearLinkRot ( p1 )
	clearLinkPiv ( p1 )
end

function clearInheritTransform ( p1 )
	p1:clearAttrLink ( INHERIT_TRANSFORM )
end

function clearLinkShader ( p1 )
	p1:clearAttrLink ( ATTR_SHADER )
end

function clearLinkScissorRect ( p1 )
	p1:clearAttrLink ( ATTR_SCISSOR_RECT )
end

function inheritAllPropAttributes ( p1, p2 )
	inheritTransformColorVisible ( p1, p2 )
	p1:setAttrLink ( ATTR_PARTITION, p2, ATTR_PARTITION )
	p1:setAttrLink ( ATTR_SHADER, p2, ATTR_SHADER )
	p1:setAttrLink ( ATTR_BLEND_MODE, p2, ATTR_BLEND_MODE )
end

function alignPropPivot ( p, align )  --align prop's pivot against deck
	local x,y,z,x1,y1,z1 = p:getBounds ()
	if align == 'top' then
		p:setPivot ( x, y1 )
	end
	-- error('todo')
	--todo
end

local function genAttrFunctions ( id )
	local src = [[
		return function ( getAttr,setAttr,seekAttr,moveAttr,id )
			return 
				function ( obj )                     --get
					return getAttr ( obj,id )
				end,
				function ( obj,value )               --set
					return setAttr ( obj,id,value )
				end,
				function ( obj,value,time,easetype ) --seek
					return seekAttr ( obj,id,value,time,easetype )
				end,
				function ( obj,value,time,easetype ) --move
					return moveAttr ( obj,id,value,time,easetype )
				end
		end
	]]

	local tmpl = loadstring ( src )()
	return tmpl ( getAttr, setAttr, seekAttr, moveAttr, id )
end

getLocX,setLocX,seekLocX,moveLocX = genAttrFunctions ( MOAITransform.ATTR_X_LOC )
getLocY,setLocY,seekLocY,moveLocY = genAttrFunctions ( MOAITransform.ATTR_Y_LOC )
getLocZ,setLocZ,seekLocZ,moveLocZ = genAttrFunctions ( MOAITransform.ATTR_Z_LOC )

getRotX,setRotX,seekRotX,moveRotX = genAttrFunctions ( MOAITransform.ATTR_X_ROT )
getRotY,setRotY,seekRotY,moveRotY = genAttrFunctions ( MOAITransform.ATTR_Y_ROT )
getRotZ,setRotZ,seekRotZ,moveRotZ = genAttrFunctions ( MOAITransform.ATTR_Z_ROT )

getSclX,setSclX,seekSclX,moveSclX = genAttrFunctions ( MOAITransform.ATTR_X_SCL )
getSclY,setSclY,seekSclY,moveSclY = genAttrFunctions ( MOAITransform.ATTR_Y_SCL )
getSclZ,setSclZ,seekSclZ,moveSclZ = genAttrFunctions ( MOAITransform.ATTR_Z_SCL )

getPivX,setPivX,seekPivX,movePivX = genAttrFunctions ( MOAITransform.ATTR_X_PIV )
getPivY,setPivY,seekPivY,movePivY = genAttrFunctions ( MOAITransform.ATTR_Y_PIV )
getPivZ,setPivZ,seekPivZ,movePivZ = genAttrFunctions ( MOAITransform.ATTR_Z_PIV )

------------Apply transform & other common settings
local setScl, setRot, setLoc, setPiv = moaiHelpersModule.extractMoaiInstanceMethods (
	MOAITransform,
	'setScl', 'setRot', 'setLoc', 'setPiv'
)

function setupMoaiTransform ( prop, transform )
	local loc = transform.loc 
	local rot = transform.rot
	local scl = transform.scl 
	local piv = transform.piv

	if loc then setLoc ( prop, loc[1], loc[2], loc[3] ) end
	if rot then
		if type ( rot )=='number' then
			setRot ( prop, nil, nil, rot )
		else
			setRot ( prop, rot[1], rot[2], rot[3] ) 
		end
	end
	if scl then setScl ( prop, scl[1], scl[2], scl[3] ) end
	if piv then setPiv ( prop, piv[1], piv[2], piv[3] ) end

	return prop
end

-- function copyTransform( t1, t2 )
-- 	t1:setLoc( t2:getLoc() )
-- 	t1:setScl( t2:getScl() )
-- 	t1:setRot( t2:getRot() )
-- end

----TODO: replace this with C++ functions!!!
function syncWorldLoc ( t1, t2 )
	local x2,y2,z2 =  t2:getWorldLoc ()
	local x1,y1,z1 =  t1:getWorldLoc ()
	t1:addLoc ( x2-x1, y2-y1, z2-z1 )
end

function syncWorldRot ( t1, t2 )
	-- local rx2,ry2,rz2 = t2:getWorldDir ()
	-- local rx1,ry1,rz1 = t1:getWorldDir ()
	-- print ( rz1, rz2 )
	-- t1:addRot ( rx2-rx1, ry2-ry1, rz2-rz1 ) 
	local rz2 = t2:getWorldRot ()
	local rz1 = t1:getWorldRot ()
	t1:addRot ( 0,0, rz2-rz1 )
end

function syncWorldScl ( t1, t2 )
	local sx2,sy2,sz2 = t2:getWorldScl ()
	local sx1,sy1,sz1 = t1:getWorldScl ()
	local sx,sy,sz = t1:getScl ()
	local kx,ky,kz
	kx = sx1 ~= 0 and sx2/sx1 or 1
	ky = sy1 ~= 0 and sy2/sy1 or 1
	kz = sz1 ~= 0 and sz2/sz1 or 1
	t1:setScl ( sx*kx, sy*ky, sz*kz )
end

function syncWorldTransform ( t1, t2 )
	syncWorldLoc ( t1, t2 )
	syncWorldRot ( t1, t2 )
	syncWorldScl ( t1, t2 )
end

function setPropBlend ( prop, blend )
	if not blend then return prop:setBlendMode ( nil ) end
	if     blend == 'alpha'		then prop:setBlendMode ( GL_FUNC_ADD, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA ) 
	elseif blend == 'add'		then prop:setBlendMode ( GL_FUNC_ADD, GL_SRC_ALPHA, GL_ONE )
	elseif blend == 'multiply'	then prop:setBlendMode ( GL_FUNC_ADD, GL_DST_COLOR, GL_ZERO )
	elseif blend == 'normal'	then prop:setBlendMode ( GL_FUNC_ADD, GL_ONE, GL_ONE_MINUS_SRC_ALPHA )
	elseif blend == 'mask'		then prop:setBlendMode ( GL_FUNC_ADD, GL_ZERO, GL_SRC_ALPHA )
	elseif blend == 'dst_alpha'	then prop:setBlendMode ( GL_FUNC_ADD, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA )
	elseif blend == 'dst_add'	then prop:setBlendMode ( GL_FUNC_ADD, GL_DST_ALPHA, GL_ONE )
	elseif blend == 'alpha_reversed' then prop:setBlendMode ( GL_FUNC_ADD, GL_ONE_MINUS_SRC_ALPHA, GL_SRC_ALPHA )
	elseif blend == 'dst_alpha_reversed' then prop:setBlendMode ( GL_FUNC_ADD, GL_ONE_MINUS_DST_ALPHA, GL_DST_ALPHA )
	elseif blend == 'solid'		then prop:setBlendMode ( GL_FUNC_ADD, GL_ONE, GL_ZERO )
	elseif type ( blend ) == 'table' then
		local a, b, c = unpack ( blend )
		if c then
			assert ( a == GL_FUNC_ADD or a == GL_FUNC_SUBTRACT or a == GL_FUNC_REVERSE_SUBTRACT )
			prop:setBlendMode ( a, b, c )
		else
			prop:setBlendMode ( GL_FUNC_ADD, a, b )
		end
	end
end

function setupMoaiProp ( prop, option )
	---------------PRIORITY
	local priority = option.priority
	if priority then
		local tt = type ( priority )
		if tt == 'number' then
			prop:setPriority ( priority )
		elseif tt == 'string' then
			local p = priorityNames[ priority ]
			assert ( p, 'priority name not found:'..priority )
			prop:setPriority ( p )
		end
	end

	---------DEPTH MASK/Func
	local depthTest = option.depthTest
	if option.depthMask == false then prop:setDepthMask ( false ) end
	if depthTest then		
		if depthTest == 'always' then
			prop:setDepthTest ( DEPTH_TEST_ALWAYS )
		elseif depthTest == 'greater' then
			prop:setDepthTest ( DEPTH_TEST_GREATER )
		else 
			prop:setDepthTest ( DEPTH_TEST_LESS_EQUAL )
		end
	-- else
	-- 	prop:setDepthTest ( DEPTH_TEST_DISABLE )
	end
	
	---------BLEND MODE
	local blend = option.blend or 'alpha'
	setPropBlend ( prop, blend )
	
	----------SHADER
	local shader = option.shader
	if shader then
		local ts = type ( shader )
		if ts == 'string' then
			if shader == 'tex' then
				prop:setShader ( getBuiltinShader ( DECK2D_TEX_ONLY_SHADER ) )
			elseif shader == 'color-tex' then
				prop:setShader ( getBuiltinShader ( DECK2D_SHADER ) )
			end
		else
			prop:setShader ( shader )
		end
	end

	---------Deck
	local deck = option.deck
	if deck then 
		if type ( deck ) == 'string' then
			deck = candy.loadAsset ( deck )
			deck = deck and deck:getMoaiDeck ()
		end
		prop:setDeck ( deck )
	elseif option.texture then
		prop:setTexture ( option.texture )
	end

	---------COMMON
	if option.visible == false then prop:setVisible ( false ) end
	if option.color then prop:setColor ( unpack ( option.color ) ) end
	if option.index then prop:setIndex ( option.index ) end
	
	local transform = option.transform
	if transform then return setupMoaiTransform ( prop, transform ) end	
	
	return prop
end

-- moaiHelpersModule.injectMoaiClass ( MOAIProp, {
-- 	setupTransform = setupMoaiTransform,
-- 	setupProp      = setupMoaiProp
-- })


----------some method wrapper
function wrapWithMoaiTransformMethods ( clas, propName )
	local MOAITransformIT = MOAITransform.getInterfaceTable ()

	ClassHelperModule.wrapMoaiMethods ( MOAITransformIT, clas, propName, {
		"addLoc@",
		"addRot@",
		"addScl@",
		"addPiv@",
		"moveLoc@",
		"movePiv@",
		"moveRot@",
		"moveScl@",
		"setScl@",
		"setSclX@",
		"setSclY@",
		"setSclZ@",
		"setLoc@",
		"setLocX@",
		"setLocY@",
		"setLocZ@",
		"setRot@",
		"setRotX@",
		"setRotY@",
		"setRotZ@",
		"setPiv@",
		"setPivX@",
		"setPivY@",
		"setPivZ@",
		"getScl",
		"getSclX",
		"getSclY",
		"getSclZ",
		"getLoc",
		"getLocX",
		"getLocY",
		"getLocZ",
		"getRot",
		"getRotX",
		"getRotY",
		"getRotZ",
		"getPiv",
		"getPivX",
		"getPivY",
		"getPivZ",
		"getWorldScl",
		"getWorldLoc",
		"getWorldRot",
		"getWorldDir",
		"seekScl@",
		"seekLoc@",
		"seekRot@",
		"seekPiv@",
		"seekAttr@",
		"setAttr@",
		"moveAttr@",
		"forceUpdate",
		"scheduleUpdate",
		"worldToModel@",
		"modelToWorld@",
		"modelToWorld@",
		"setShearByX@",
		"setShearByY@",
		"setShearByZ@"
	} )

	ClassHelperModule.wrapAttrSeekMove ( clas, propName, MOAIProp.ATTR_X_LOC, "LocX" )
	ClassHelperModule.wrapAttrSeekMove ( clas, propName, MOAIProp.ATTR_Y_LOC, "LocY" )
	ClassHelperModule.wrapAttrSeekMove ( clas, propName, MOAIProp.ATTR_Z_LOC, "LocZ" )
	ClassHelperModule.wrapAttrSeekMove ( clas, propName, MOAIProp.ATTR_X_ROT, "RotX" )
	ClassHelperModule.wrapAttrSeekMove ( clas, propName, MOAIProp.ATTR_Y_ROT, "RotY" )
	ClassHelperModule.wrapAttrSeekMove ( clas, propName, MOAIProp.ATTR_Z_ROT, "RotZ" )
	ClassHelperModule.wrapAttrSeekMove ( clas, propName, MOAIProp.ATTR_X_SCL, "SclX" )
	ClassHelperModule.wrapAttrSeekMove ( clas, propName, MOAIProp.ATTR_Y_SCL, "SclY" )
	ClassHelperModule.wrapAttrSeekMove ( clas, propName, MOAIProp.ATTR_Z_SCL, "SclZ" )
	ClassHelperModule.wrapAttrSeekMove ( clas, propName, MOAIProp.ATTR_X_PIV, "PivX" )
	ClassHelperModule.wrapAttrSeekMove ( clas, propName, MOAIProp.ATTR_Y_PIV, "PivY" )
	ClassHelperModule.wrapAttrSeekMove ( clas, propName, MOAIProp.ATTR_Z_PIV, "PivZ" )

	function clas:getLocXY () return self:getLocX (), self:getLocY () end
	function clas:getLocXZ () return self:getLocX (), self:getLocZ () end
	function clas:getLocYZ () return self:getLocY (), self:getLocZ () end
	function clas:setLocXY ( x, y ) self:setLocX ( x ) self:setLocY ( y ) end
	function clas:setLocXZ ( x, z ) self:setLocX ( x ) self:setLocZ ( z ) end
	function clas:setLocYZ ( y, z ) self:setLocY ( y ) self:setLocZ ( z ) end

	function clas:getXY () return self:getLocXY () end
	function clas:getXZ () return self:getLocXZ () end
	function clas:getYZ () return self:getLocYZ () end
	function clas:setXY ( x, y ) return self:setLocXY ( x, y ) end
	function clas:setXZ ( x, z ) return self:setLocXZ ( x, z ) end
	function clas:setYZ ( y, z ) return self:setLocYZ ( y, z ) end

	function clas:getRotXY () return self:getRotX (), self:getRotY () end
	function clas:getRotXZ () return self:getRotX (), self:getRotZ () end
	function clas:getRotYZ () return self:getRotY (), self:getRotZ () end
	function clas:setRotXY ( x, y ) self:setRotX ( x ) self:setRotY ( y ) end
	function clas:setRotXZ ( x, z ) self:setRotX ( x ) self:setRotZ ( z ) end
	function clas:setRotYZ ( y, z ) self:setRotY ( y ) self:setRotZ ( z ) end

	function clas:getSclXY () return self:getSclX (), self:getSclY () end
	function clas:getSclXZ () return self:getSclX (), self:getSclZ () end
	function clas:getSclYZ () return self:getSclY (), self:getSclZ () end
	function clas:setSclXY ( x, y ) self:setSclX ( x ) self:setSclY ( y ) end
	function clas:setSclXZ ( x, z ) self:setSclX ( x ) self:setSclZ ( z ) end
	function clas:setSclYZ ( y, z ) self:setSclY ( y ) self:setSclZ ( z ) end

	function clas:getPivXY () return self:getPivX (), self:getPivY () end
	function clas:getPivXZ () return self:getPivX (), self:getPivZ () end
	function clas:getPivYZ () return self:getPivY (), self:getPivZ () end
	function clas:setPivXY ( x, y ) self:setPivX ( x ) self:setPivY ( y ) end
	function clas:setPivXZ ( x, z ) self:setPivX ( x ) self:setPivZ ( z ) end
	function clas:setPivYZ ( y, z ) self:setPivY ( y ) self:setPivZ ( z ) end

	return clas
end

function wrapWithMoaiPropMethods ( clas, propName )
	
	wrapWithMoaiTransformMethods ( clas, propName )

	local MOAIGraphicsPropIT = MOAIGraphicsProp.getInterfaceTable ()

	-- print ( inspect ( MOAIGraphicsPropIT, { depth = 1 } ) )

	ClassHelperModule.wrapMoaiMethods ( MOAIGraphicsPropIT, clas, propName, {
		-- "getAlpha",
		"getColor",
		-- "setAlpha@",
		"setColor@",
		-- "getFinalAlpha",
		-- "getFinalColor",
		"seekColor@",
		"isVisible",
		"setVisible@",
		"inside@",
		"setIndex@",
		"getIndex",
		"setBillboard@"
	} )

	ClassHelperModule.wrapAttrGetSetSeekMove ( clas, propName, MOAIProp.ATTR_R_COL, "ColorR" )
	ClassHelperModule.wrapAttrGetSetSeekMove ( clas, propName, MOAIProp.ATTR_G_COL, "ColorG" )
	ClassHelperModule.wrapAttrGetSetSeekMove ( clas, propName, MOAIProp.ATTR_B_COL, "ColorB" )
	ClassHelperModule.wrapAttrSeekMove ( clas, propName, MOAIProp.ATTR_A_COL, "Alpha" )
	ClassHelperModule.wrapAttrGetter ( clas, propName, MOAIProp.ATTR_WORLD_X_LOC, "getWorldLocX" )
	ClassHelperModule.wrapAttrGetter ( clas, propName, MOAIProp.ATTR_WORLD_Y_LOC, "getWorldLocY" )
	ClassHelperModule.wrapAttrGetter ( clas, propName, MOAIProp.ATTR_WORLD_Z_LOC, "getWorldLocZ" )

	return clas
end

function wrapWithMoaiTextLabelMethods ( clas, propName )

	local MOAITextLabelIT = MOAITextLabel.getInterfaceTable ()

	ClassHelperModule.wrapMoaiMethods ( MOAITextLabelIT, clas, propName, {
		"clearHighlights",
		"getAlignment",
		"getGlyphScale@",
		"getLineSpacing@",
		"getOverrunRules",
		"getRect",
		"getSizingRules",
		"getStyle",
		"getText",
		"getTextBounds",
		"hasOverrun",
		"more",
		"nextPage",
		"revealAll",
		"reserveCurves",
		"setAlignment",
		"setAutoFlip",
		"setBounds",
		"setCurve",
		"setGlyphScale",
		"setHighlight",
		"setLineSnap",
		"setLineSpacing",
		"setMargins",
		"setOverrunRules",
		"setRect",
		"setRectLimits",
		"setReveal",
		"setSpeed",
		"setSizingRules",
		"setStyle",
		"setText",
		"setWordBreak",
		"setYFlip",
		"spool",
		"setShader",
	} )
end

function traceMOAINew ( clas )
	local _new = clas.new

	function clas.new ()
		local obj = _new ()

		print ( "NEW MOAI Object:", obj )
		print ( debug.traceback () )

		return obj
	end
end


MOAIPropHelpersModule.extractColor = extractColor
MOAIPropHelpersModule.inheritLoc = inheritLoc
MOAIPropHelpersModule.linkRot = linkRot
MOAIPropHelpersModule.linkScl = linkScl
MOAIPropHelpersModule.linkLoc = linkLoc
MOAIPropHelpersModule.linkWorldLoc = linkWorldLoc
MOAIPropHelpersModule.linkWorldScl = linkWorldScl
MOAIPropHelpersModule.linkPiv = linkPiv
MOAIPropHelpersModule.linkTransform = linkTransform
MOAIPropHelpersModule.linkPartition = linkPartition
MOAIPropHelpersModule.linkIndex = linkIndex
MOAIPropHelpersModule.linkBlendMode = linkBlendMode
MOAIPropHelpersModule.clearLinkPartition = clearLinkPartition
MOAIPropHelpersModule.clearLinkIndex = clearLinkIndex
MOAIPropHelpersModule.clearLinkBlendMode = clearLinkBlendMode
MOAIPropHelpersModule.inheritTransform = inheritTransform
MOAIPropHelpersModule.inheritColor = inheritColor
MOAIPropHelpersModule.linkColor = linkColor
MOAIPropHelpersModule.linkColorTrait = linkColorTrait
MOAIPropHelpersModule.inheritVisible = inheritVisible
MOAIPropHelpersModule.linkVisible = linkVisible
MOAIPropHelpersModule.linkLocalVisible = linkLocalVisible
MOAIPropHelpersModule.clearInheritVisible = clearInheritVisible
MOAIPropHelpersModule.inheritTransformColor = inheritTransformColor
MOAIPropHelpersModule.inheritTransformColorVisible = inheritTransformColorVisible
MOAIPropHelpersModule.inheritPartition = inheritPartition
MOAIPropHelpersModule.linkShader = linkShader
MOAIPropHelpersModule.linkScissorRect = linkScissorRect
MOAIPropHelpersModule.clearLinkRot = clearLinkRot
MOAIPropHelpersModule.clearLinkScl = clearLinkScl
MOAIPropHelpersModule.clearLinkLoc = clearLinkLoc
MOAIPropHelpersModule.clearLinkPiv = clearLinkPiv
MOAIPropHelpersModule.clearLinkColor = clearLinkColor
MOAIPropHelpersModule.clearInheritColor = clearInheritColor
MOAIPropHelpersModule.clearLinkTransform = clearLinkTransform
MOAIPropHelpersModule.clearInheritTransform = clearInheritTransform
MOAIPropHelpersModule.clearLinkShader = clearLinkShader
MOAIPropHelpersModule.clearLinkScissorRect = clearLinkScissorRect
MOAIPropHelpersModule.alignPropPivot = alignPropPivot
MOAIPropHelpersModule.setupMoaiTransform = setupMoaiTransform
MOAIPropHelpersModule.syncWorldLoc = syncWorldLoc
MOAIPropHelpersModule.syncWorldRot = syncWorldRot
MOAIPropHelpersModule.syncWorldScl = syncWorldScl
MOAIPropHelpersModule.syncWorldTransform = syncWorldTransform
MOAIPropHelpersModule.setPropBlend = setPropBlend
MOAIPropHelpersModule.setupMoaiProp = setupMoaiProp
MOAIPropHelpersModule.wrapWithMoaiTransformMethods = wrapWithMoaiTransformMethods
MOAIPropHelpersModule.wrapWithMoaiPropMethods = wrapWithMoaiPropMethods

return MOAIPropHelpersModule