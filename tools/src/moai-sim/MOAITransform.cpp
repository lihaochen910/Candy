// Copyright (c) 2010-2017 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#include "pch.h"
#include <moai-sim/MOAITransform.h>
#include <moai-sim/MOAISim.h>

//================================================================//
// local
//================================================================//

//----------------------------------------------------------------//
/**	@lua	addLoc
	@text	Adds a delta to the transform's location.
	
	@in		MOAITransform self
	@in		number xDelta
	@in		number yDelta
	@in		number zDelta
	@out	nil
*/
int MOAITransform::_addLoc ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	ZLVec3D loc = self->GetLoc ();
	
	loc.mX += state.GetValue < float >( 2, 0.0f );
	loc.mY += state.GetValue < float >( 3, 0.0f );
	loc.mZ += state.GetValue < float >( 4, 0.0f );
	
	self->SetLoc ( loc );
	self->ScheduleUpdate ();
	
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	addPiv
	@text	Adds a delta to the transform's pivot.
	
	@in		MOAITransform self
	@in		number xDelta
	@in		number yDelta
	@in		number zDelta
	@out	nil
*/
int MOAITransform::_addPiv ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	ZLVec3D piv = self->GetPiv ();
	
	piv.mX += state.GetValue < float >( 2, 0.0f );
	piv.mY += state.GetValue < float >( 3, 0.0f );
	piv.mZ += state.GetValue < float >( 4, 0.0f );
	
	self->SetPiv ( piv );
	self->ScheduleUpdate ();
	
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	addRot
	@text	Adds a delta to the transform's rotation
	
	@in		MOAITransform self
	@in		number xDelta		In degrees.
	@in		number yDelta		In degrees.
	@in		number zDelta		In degrees.
	@out	nil
*/
int MOAITransform::_addRot ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	ZLVec3D rot = self->GetRot ();
	rot.mX += state.GetValue < float >( 2, 0.0f );
	rot.mY += state.GetValue < float >( 3, 0.0f );
	rot.mZ += state.GetValue < float >( 4, 0.0f );
	
	self->SetRot ( rot );
	self->ScheduleUpdate ();
	
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	addScl
	@text	Adds a delta to the transform's scale
	
	@in		MOAITransform self
	@in		number xSclDelta
	@opt	number ySclDelta		Default value is xSclDelta.
	@opt	number zSclDelta		Default value is 0.
	@out	nil
*/
int MOAITransform::_addScl ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	ZLVec3D scl = self->GetScl ();
	
	float xSclDelta = state.GetValue < float >( 2, 0.0f );
	float ySclDelta = state.GetValue < float >( 3, xSclDelta );
	float zSclDelta = state.GetValue < float >( 4, 0.0f );
	
	scl.mX += xSclDelta;
	scl.mY += ySclDelta;
	scl.mZ += zSclDelta;
	
	self->SetScl ( scl );
	self->ScheduleUpdate ();
	
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	getLoc
	@text	Returns the transform's current location.
	
	@in		MOAITransform self
	@out	number xLoc
	@out	number yLoc
	@out	number zLoc
*/
int	MOAITransform::_getLoc ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	lua_pushnumber ( state, self->mLoc.mX );
	lua_pushnumber ( state, self->mLoc.mY );
	lua_pushnumber ( state, self->mLoc.mZ );

	return 3;
}

//----------------------------------------------------------------//
/**	@lua	getLocX
	@text	Returns the transform's current location X.
	
	@in		MOAITransform self
	@out	number xLoc
*/
int	MOAITransform::_getLocX ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	lua_pushnumber ( state, self->mLoc.mX );

	return 1;
}

//----------------------------------------------------------------//
/**	@lua	getLocY
	@text	Returns the transform's current location Y.
	
	@in		MOAITransform self
	@out	number yLoc
*/
int	MOAITransform::_getLocY ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	lua_pushnumber ( state, self->mLoc.mY );

	return 1;
}

//----------------------------------------------------------------//
/**	@lua	getLocZ
	@text	Returns the transform's current location Z.
	
	@in		MOAITransform self
	@out	number zLoc
*/
int	MOAITransform::_getLocZ ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	lua_pushnumber ( state, self->mLoc.mZ );

	return 1;
}

//----------------------------------------------------------------//
/**	@lua	getPiv
	@text	Returns the transform's current pivot.
	
	@in		MOAITransform self
	@out	number xPiv
	@out	number yPiv
	@out	number zPiv
*/
int	MOAITransform::_getPiv ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	lua_pushnumber ( state, self->mPiv.mX );
	lua_pushnumber ( state, self->mPiv.mY );
	lua_pushnumber ( state, self->mPiv.mZ );

	return 3;
}

//----------------------------------------------------------------//
/**	@lua	getPivX
	@text	Returns the transform's current pivot X.
	
	@in		MOAITransform self
	@out	number xPiv
*/
int	MOAITransform::_getPivX ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	lua_pushnumber ( state, self->mPiv.mX );

	return 1;
}

//----------------------------------------------------------------//
/**	@lua	getPivY
	@text	Returns the transform's current pivot Y.
	
	@in		MOAITransform self
	@out	number yPiv
*/
int	MOAITransform::_getPivY ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	lua_pushnumber ( state, self->mPiv.mY );

	return 1;
}

//----------------------------------------------------------------//
/**	@lua	getPivZ
	@text	Returns the transform's current pivot Z.
	
	@in		MOAITransform self
	@out	number zPiv
*/
int	MOAITransform::_getPivZ ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	lua_pushnumber ( state, self->mPiv.mZ );

	return 1;
}

//----------------------------------------------------------------//
/**	@lua	getRot
	@text	Returns the transform's current rotation.
	
	@in		MOAITransform self
	@out	number xRot			Rotation in degrees.
	@out	number yRot			Rotation in degrees.
	@out	number zRot			Rotation in degrees.
*/
int	MOAITransform::_getRot ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	lua_pushnumber ( state, self->mRot.mX );
	lua_pushnumber ( state, self->mRot.mY );
	lua_pushnumber ( state, self->mRot.mZ );

	return 3;
}

//----------------------------------------------------------------//
/**	@lua	getRotX
	@text	Returns the transform's current rotation X.
	
	@in		MOAITransform self
	@out	number xRot			Rotation in degrees.
*/
int	MOAITransform::_getRotX ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	lua_pushnumber ( state, self->mRot.mX );

	return 1;
}

//----------------------------------------------------------------//
/**	@lua	getRotY
	@text	Returns the transform's current rotation Y.
	
	@in		MOAITransform self
	@out	number yRot			Rotation in degrees.
*/
int	MOAITransform::_getRotY ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	lua_pushnumber ( state, self->mRot.mY );

	return 1;
}

//----------------------------------------------------------------//
/**	@lua	getRotZ
	@text	Returns the transform's current rotation Z.
	
	@in		MOAITransform self
	@out	number zRot			Rotation in degrees.
*/
int	MOAITransform::_getRotZ ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	lua_pushnumber ( state, self->mRot.mZ );

	return 1;
}

//----------------------------------------------------------------//
/**	@lua	getScl
	@text	Returns the transform's current scale.
	
	@in		MOAITransform self
	@out	number xScl
	@out	number yScl
	@out	number zScl
*/
int	MOAITransform::_getScl ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	lua_pushnumber ( state, self->mScale.mX );
	lua_pushnumber ( state, self->mScale.mY );
	lua_pushnumber ( state, self->mScale.mZ );

	return 3;
}

//----------------------------------------------------------------//
/**	@lua	getSclX
	@text	Returns the transform's current scale X.
	
	@in		MOAITransform self
	@out	number xScl
*/
int	MOAITransform::_getSclX ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	lua_pushnumber ( state, self->mScale.mX );

	return 1;
}

//----------------------------------------------------------------//
/**	@lua	getSclY
	@text	Returns the transform's current scale Y.
	
	@in		MOAITransform self
	@out	number yScl
*/
int	MOAITransform::_getSclY ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	lua_pushnumber ( state, self->mScale.mY );

	return 1;
}

//----------------------------------------------------------------//
/**	@lua	getSclZ
	@text	Returns the transform's current scale Z.
	
	@in		MOAITransform self
	@out	number zScl
*/
int	MOAITransform::_getSclZ ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	lua_pushnumber ( state, self->mScale.mZ );

	return 1;
}

//----------------------------------------------------------------//
/**	@lua	move
	@text	Animate the transform by applying a delta. Creates and returns
			a MOAIEaseDriver initialized to apply the delta.
	
	@in		MOAITransform self
	@in		number xDelta		Delta to be added to x.
	@in		number yDelta		Delta to be added to y.
	@in		number zDelta		Delta to be added to z.
	@in		number xRotDelta	Delta to be added to x rot (in degrees).
	@in		number yRotDelta	Delta to be added to y rot (in degrees).
	@in		number zRotDelta	Delta to be added to z rot (in degrees).
	@in		number xSclDelta	Delta to be added to x scale.
	@in		number ySclDelta	Delta to be added to y scale.
	@in		number zSclDelta	Delta to be added to z scale.
	@in		number length		Length of animation in seconds.
	@opt	number mode			The ease mode. One of MOAIEaseType.EASE_IN, MOAIEaseType.EASE_OUT, MOAIEaseType.FLAT MOAIEaseType.LINEAR,
								MOAIEaseType.SMOOTH, MOAIEaseType.SOFT_EASE_IN, MOAIEaseType.SOFT_EASE_OUT, MOAIEaseType.SOFT_SMOOTH. Defaults to MOAIEaseType.SMOOTH.

	@out	MOAIEaseDriver easeDriver
*/
int MOAITransform::_move ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	float delay		= state.GetValue < float >( 11, 0.0f );
	
	if ( delay > 0.0f ) {
	
		u32 mode = state.GetValue < u32 >( 12, ZLInterpolate::kSmooth );
		
		MOAIEaseDriver* action = new MOAIEaseDriver ();
		
		action->ParseForMove ( state, 2, self, 9, mode,
			MOAITransformAttr::Pack ( ATTR_X_LOC ), 0.0f,
			MOAITransformAttr::Pack ( ATTR_Y_LOC ), 0.0f,
			MOAITransformAttr::Pack ( ATTR_Z_LOC ), 0.0f,
			MOAITransformAttr::Pack ( ATTR_X_ROT ), 0.0f,
			MOAITransformAttr::Pack ( ATTR_Y_ROT ), 0.0f,
			MOAITransformAttr::Pack ( ATTR_Z_ROT ), 0.0f,
			MOAITransformAttr::Pack ( ATTR_X_SCL ), 0.0f,
			MOAITransformAttr::Pack ( ATTR_Y_SCL ), 0.0f,
			MOAITransformAttr::Pack ( ATTR_Z_SCL ), 0.0f
		);
		
		action->SetSpan ( delay );
		action->Start ( 0, false );
		action->PushLuaUserdata ( state );
		
		return 1;
	}

	if ( !state.CheckVector ( 2, 9, 0, 0 )) { // TODO: epsilon?

		self->mLoc.mX += state.GetValue < float >( 2, 0.0f );
		self->mLoc.mY += state.GetValue < float >( 3, 0.0f );
		self->mLoc.mZ += state.GetValue < float >( 4, 0.0f );
		
		self->mRot.mX += state.GetValue < float >( 5, 0.0f );
		self->mRot.mY += state.GetValue < float >( 6, 0.0f );
		self->mRot.mZ += state.GetValue < float >( 7, 0.0f );
		
		self->mScale.mX += state.GetValue < float >( 8, 0.0f );
		self->mScale.mY += state.GetValue < float >( 9, 0.0f );
		self->mScale.mZ += state.GetValue < float >( 10, 0.0f );
		
		self->ScheduleUpdate ();
	}

	return 0;
}

//----------------------------------------------------------------//
/**	@lua	moveLoc
	@text	Animate the transform by applying a delta. Creates and returns
			a MOAIEaseDriver initialized to apply the delta.
	
	@in		MOAITransform self
	@in		number xDelta		Delta to be added to x.
	@in		number yDelta		Delta to be added to y.
	@in		number zDelta		Delta to be added to z.
	@in		number length		Length of animation in seconds.
	@opt	number mode			The ease mode. One of MOAIEaseType.EASE_IN, MOAIEaseType.EASE_OUT, MOAIEaseType.FLAT MOAIEaseType.LINEAR,
								MOAIEaseType.SMOOTH, MOAIEaseType.SOFT_EASE_IN, MOAIEaseType.SOFT_EASE_OUT, MOAIEaseType.SOFT_SMOOTH. Defaults to MOAIEaseType.SMOOTH.

	@out	MOAIEaseDriver easeDriver
*/
int MOAITransform::_moveLoc ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	float delay		= state.GetValue < float >( 5, 0.0f );
	
	if ( delay > 0.0f ) {
	
		u32 mode = state.GetValue < u32 >( 6, ZLInterpolate::kSmooth );
		
		MOAIEaseDriver* action = new MOAIEaseDriver ();
		
		action->ParseForMove ( state, 2, self, 3, mode,
			MOAITransformAttr::Pack ( ATTR_X_LOC ), 0.0f,
			MOAITransformAttr::Pack ( ATTR_Y_LOC ), 0.0f,
			MOAITransformAttr::Pack ( ATTR_Z_LOC ), 0.0f
		);
		
		action->SetSpan ( delay );
		action->Start ( 0, false );
		action->PushLuaUserdata ( state );

		return 1;
	}
	
	if ( !state.CheckVector ( 2, 3, 0, 0 )) { // TODO: epsilon?
	
		self->mLoc.mX += state.GetValue < float >( 2, 0.0f );
		self->mLoc.mY += state.GetValue < float >( 3, 0.0f );
		self->mLoc.mZ += state.GetValue < float >( 4, 0.0f );
		self->ScheduleUpdate ();
	}
	
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	movePiv
	@text	Animate the transform by applying a delta. Creates and returns
			a MOAIEaseDriver initialized to apply the delta.
	
	@in		MOAITransform self
	@in		number xDelta		Delta to be added to xPiv.
	@in		number yDelta		Delta to be added to yPiv.
	@in		number zDelta		Delta to be added to zPiv.
	@in		number length		Length of animation in seconds.
	@opt	number mode			The ease mode. One of MOAIEaseType.EASE_IN, MOAIEaseType.EASE_OUT, MOAIEaseType.FLAT MOAIEaseType.LINEAR,
								MOAIEaseType.SMOOTH, MOAIEaseType.SOFT_EASE_IN, MOAIEaseType.SOFT_EASE_OUT, MOAIEaseType.SOFT_SMOOTH. Defaults to MOAIEaseType.SMOOTH.

	@out	MOAIEaseDriver easeDriver
*/
int MOAITransform::_movePiv ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	float delay		= state.GetValue < float >( 5, 0.0f );
	
	if ( delay > 0.0f ) {
	
		u32 mode = state.GetValue < u32 >( 6, ZLInterpolate::kSmooth );
		
		MOAIEaseDriver* action = new MOAIEaseDriver ();
		
		action->ParseForMove ( state, 2, self, 3, mode,
			MOAITransformAttr::Pack ( ATTR_X_PIV ), 0.0f,
			MOAITransformAttr::Pack ( ATTR_Y_PIV ), 0.0f,
			MOAITransformAttr::Pack ( ATTR_Z_PIV ), 0.0f
		);
		
		action->SetSpan ( delay );
		action->Start ( 0, false );
		action->PushLuaUserdata ( state );

		return 1;
	}
	
	if ( !state.CheckVector ( 2, 3, 0, 0 )) { // TODO: epsilon?
	
		self->mPiv.mX += state.GetValue < float >( 2, 0.0f );
		self->mPiv.mY += state.GetValue < float >( 3, 0.0f );
		self->mPiv.mZ += state.GetValue < float >( 4, 0.0f );
		self->ScheduleUpdate ();
	}

	return 0;
}

//----------------------------------------------------------------//
/**	@lua	moveRot
	@text	Animate the transform by applying a delta. Creates and returns
			a MOAIEaseDriver initialized to apply the delta.
	
	@in		MOAITransform self
	@in		number xDelta		Delta to be added to xRot (in degrees).
	@in		number yDelta		Delta to be added to yRot (in degrees).
	@in		number zDelta		Delta to be added to zRot (in degrees).
	@in		number length		Length of animation in seconds.
	@opt	number mode			The ease mode. One of MOAIEaseType.EASE_IN, MOAIEaseType.EASE_OUT, MOAIEaseType.FLAT MOAIEaseType.LINEAR,
								MOAIEaseType.SMOOTH, MOAIEaseType.SOFT_EASE_IN, MOAIEaseType.SOFT_EASE_OUT, MOAIEaseType.SOFT_SMOOTH. Defaults to MOAIEaseType.SMOOTH.

	@out	MOAIEaseDriver easeDriver
*/
int MOAITransform::_moveRot ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	float delay		= state.GetValue < float >( 5, 0.0f );
	
	if ( delay > 0.0f ) {
	
		u32 mode = state.GetValue < u32 >( 6, ZLInterpolate::kSmooth );
		
		MOAIEaseDriver* action = new MOAIEaseDriver ();
		
		action->ParseForMove ( state, 2, self, 3, mode,
			MOAITransformAttr::Pack ( ATTR_X_ROT ), 0.0f,
			MOAITransformAttr::Pack ( ATTR_Y_ROT ), 0.0f,
			MOAITransformAttr::Pack ( ATTR_Z_ROT ), 0.0f
		);
		
		action->SetSpan ( delay );
		action->Start ( 0, false );
		action->PushLuaUserdata ( state );

		return 1;
	}
	
	if ( !state.CheckVector ( 2, 3, 0, 0 )) { // TODO: epsilon?
	
		self->mRot.mX += state.GetValue < float >( 2, 0.0f );
		self->mRot.mY += state.GetValue < float >( 3, 0.0f );
		self->mRot.mZ += state.GetValue < float >( 4, 0.0f );
		self->ScheduleUpdate ();
	}

	return 0;
}

//----------------------------------------------------------------//
/**	@lua	moveScl
	@text	Animate the transform by applying a delta. Creates and returns
			a MOAIEaseDriver initialized to apply the delta.
	
	@in		MOAITransform self
	@in		number xSclDelta	Delta to be added to x scale.
	@in		number ySclDelta	Delta to be added to y scale.
	@in		number zSclDelta	Delta to be added to z scale.
	@in		number length		Length of animation in seconds.
	@opt	number mode			The ease mode. One of MOAIEaseType.EASE_IN, MOAIEaseType.EASE_OUT, MOAIEaseType.FLAT MOAIEaseType.LINEAR,
								MOAIEaseType.SMOOTH, MOAIEaseType.SOFT_EASE_IN, MOAIEaseType.SOFT_EASE_OUT, MOAIEaseType.SOFT_SMOOTH. Defaults to MOAIEaseType.SMOOTH.

	@out	MOAIEaseDriver easeDriver
*/
int MOAITransform::_moveScl ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )

	float delay		= state.GetValue < float >( 5, 0.0f );

	if ( delay > 0.0f ) {
	
		u32 mode = state.GetValue < u32 >( 6, ZLInterpolate::kSmooth );
		
		MOAIEaseDriver* action = new MOAIEaseDriver ();
		
		action->ParseForMove ( state, 2, self, 3, mode,
			MOAITransformAttr::Pack ( ATTR_X_SCL ), 0.0f,
			MOAITransformAttr::Pack ( ATTR_Y_SCL ), 0.0f,
			MOAITransformAttr::Pack ( ATTR_Z_SCL ), 0.0f
		);
		
		action->SetSpan ( delay );
		action->Start ( 0, false );
		action->PushLuaUserdata ( state );

		return 1;
	}
	
	if ( !state.CheckVector ( 2, 3, 0, 0 )) { // TODO: epsilon?
	
		self->mScale.mX += state.GetValue < float >( 2, 0.0f );
		self->mScale.mY += state.GetValue < float >( 3, 0.0f );
		self->mScale.mZ += state.GetValue < float >( 4, 0.0f );
		self->ScheduleUpdate ();
	}
	
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	seek
	@text	Animate the transform by applying a delta. Delta is computed
			given a target value. Creates and returns a MOAIEaseDriver
			initialized to apply the delta.
	
	@in		MOAITransform self
	@in		number xGoal		Desired resulting value for x.
	@in		number yGoal		Desired resulting value for y.
	@in		number zGoal		Desired resulting value for z.
	@in		number xRotGoal		Desired resulting value for x rot (in degrees).
	@in		number yRotGoal		Desired resulting value for y rot (in degrees).
	@in		number zRotGoal		Desired resulting value for z rot (in degrees).
	@in		number xSclGoal		Desired resulting value for x scale.
	@in		number ySclGoal		Desired resulting value for y scale.
	@in		number zSclGoal		Desired resulting value for z scale.
	@in		number length		Length of animation in seconds.
	@opt	number mode			The ease mode. One of MOAIEaseType.EASE_IN, MOAIEaseType.EASE_OUT, MOAIEaseType.FLAT MOAIEaseType.LINEAR,
								MOAIEaseType.SMOOTH, MOAIEaseType.SOFT_EASE_IN, MOAIEaseType.SOFT_EASE_OUT, MOAIEaseType.SOFT_SMOOTH. Defaults to MOAIEaseType.SMOOTH.

	@out	MOAIEaseDriver easeDriver
*/
int MOAITransform::_seek ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	float delay		= state.GetValue < float >( 11, 0.0f );
	
	if ( delay > 0.0f ) {
		
		u32 mode = state.GetValue < u32 >( 12, ZLInterpolate::kSmooth );

		MOAIEaseDriver* action = new MOAIEaseDriver ();
		
		action->ParseForSeek ( state, 2, self, 9, mode,
			MOAITransformAttr::Pack ( ATTR_X_LOC ), self->mLoc.mX, 0.0f,
			MOAITransformAttr::Pack ( ATTR_Y_LOC ), self->mLoc.mY, 0.0f,
			MOAITransformAttr::Pack ( ATTR_Z_LOC ), self->mLoc.mZ, 0.0f,
			MOAITransformAttr::Pack ( ATTR_X_ROT ), self->mRot.mX, 0.0f,
			MOAITransformAttr::Pack ( ATTR_Y_ROT ), self->mRot.mY, 0.0f,
			MOAITransformAttr::Pack ( ATTR_Z_ROT ), self->mRot.mZ, 0.0f,
			MOAITransformAttr::Pack ( ATTR_X_SCL ), self->mScale.mX, 1.0f,
			MOAITransformAttr::Pack ( ATTR_Y_SCL ), self->mScale.mY, 1.0f,
			MOAITransformAttr::Pack ( ATTR_Z_SCL ), self->mScale.mZ, 1.0f
		);
		
		action->SetSpan ( delay );
		action->Start ( 0, false );
		action->PushLuaUserdata ( state );

		return 1;
	}
	
	ZLVec3D loc = state.GetVec3D < float >( 2, 0.0f );
	ZLVec3D rot = state.GetVec3D < float >( 5, 0.0f );
	ZLVec3D scl = state.GetVec3D < float >( 8, 1.0f );
	
	if ( !loc.Compare( self->mLoc ) || !rot.Compare( self->mRot ) || !scl.Compare( self->mScale )) {
		self->SetLoc ( loc );
		self->SetRot ( rot );
		self->SetScl ( scl );
		self->ScheduleUpdate ();
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	seekLoc
	@text	Animate the transform by applying a delta. Delta is computed
			given a target value. Creates and returns a MOAIEaseDriver
			initialized to apply the delta.
	
	@in		MOAITransform self
	@in		number xGoal		Desired resulting value for x.
	@in		number yGoal		Desired resulting value for y.
	@in		number zGoal		Desired resulting value for z.
	@in		number length		Length of animation in seconds.
	@opt	number mode			The ease mode. One of MOAIEaseType.EASE_IN, MOAIEaseType.EASE_OUT, MOAIEaseType.FLAT MOAIEaseType.LINEAR,
								MOAIEaseType.SMOOTH, MOAIEaseType.SOFT_EASE_IN, MOAIEaseType.SOFT_EASE_OUT, MOAIEaseType.SOFT_SMOOTH. Defaults to MOAIEaseType.SMOOTH.

	@out	MOAIEaseDriver easeDriver
*/
int MOAITransform::_seekLoc ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )

	float delay		= state.GetValue < float >( 5, 0.0f );
	
	if ( delay > 0.0f ) {

		u32 mode = state.GetValue < u32 >( 6, ZLInterpolate::kSmooth );		
		
		MOAIEaseDriver* action = new MOAIEaseDriver ();
		
		action->ParseForSeek ( state, 2, self, 3, mode,
			MOAITransformAttr::Pack ( ATTR_X_LOC ), self->mLoc.mX, 0.0f,
			MOAITransformAttr::Pack ( ATTR_Y_LOC ), self->mLoc.mY, 0.0f,
			MOAITransformAttr::Pack ( ATTR_Z_LOC ), self->mLoc.mZ, 0.0f
		);
		
		action->SetSpan ( delay );
		action->Start ( 0, false );
		action->PushLuaUserdata ( state );

		return 1;
	}
	
	ZLVec3D loc = state.GetVec3D < float >( 2, 0.0f );
	if ( !loc.Compare ( self->mLoc )) {
		self->SetLoc ( loc );
		self->ScheduleUpdate ();
	}
	
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	seekPiv
	@text	Animate the transform by applying a delta. Delta is computed
			given a target value. Creates and returns a MOAIEaseDriver
			initialized to apply the delta.
	
	@in		MOAITransform self
	@in		number xGoal		Desired resulting value for xPiv.
	@in		number yGoal		Desired resulting value for yPiv.
	@in		number zGoal		Desired resulting value for zPiv.
	@in		number length		Length of animation in seconds.
	@opt	number mode			The ease mode. One of MOAIEaseType.EASE_IN, MOAIEaseType.EASE_OUT, MOAIEaseType.FLAT MOAIEaseType.LINEAR,
								MOAIEaseType.SMOOTH, MOAIEaseType.SOFT_EASE_IN, MOAIEaseType.SOFT_EASE_OUT, MOAIEaseType.SOFT_SMOOTH. Defaults to MOAIEaseType.SMOOTH.

	@out	MOAIEaseDriver easeDriver
*/
int MOAITransform::_seekPiv ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )

	float delay		= state.GetValue < float >( 5, 0.0f );
	
	if ( delay > 0.0f ) {

		u32 mode = state.GetValue < u32 >( 6, ZLInterpolate::kSmooth );		
		
		MOAIEaseDriver* action = new MOAIEaseDriver ();
		
		action->ParseForSeek ( state, 2, self, 3, mode,
			MOAITransformAttr::Pack ( ATTR_X_PIV ), self->mPiv.mX, 0.0f,
			MOAITransformAttr::Pack ( ATTR_Y_PIV ), self->mPiv.mY, 0.0f,
			MOAITransformAttr::Pack ( ATTR_Z_PIV ), self->mPiv.mZ, 0.0f
		);
		
		action->SetSpan ( delay );
		action->Start ( 0, false );
		action->PushLuaUserdata ( state );

		return 1;
	}
	
	ZLVec3D piv = state.GetVec3D < float >( 2, 0.0f );
	if ( !piv.Compare ( self->mPiv )) {
		self->SetPiv ( piv );
		self->ScheduleUpdate ();
	}
	
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	seekRot
	@text	Animate the transform by applying a delta. Delta is computed
			given a target value. Creates and returns a MOAIEaseDriver
			initialized to apply the delta.
	
	@in		MOAITransform self
	@in		number xRotGoal		Desired resulting value for x rot (in degrees).
	@in		number yRotGoal		Desired resulting value for y rot (in degrees).
	@in		number zRotGoal		Desired resulting value for z rot (in degrees).
	@in		number length		Length of animation in seconds.
	@opt	number mode			The ease mode. One of MOAIEaseType.EASE_IN, MOAIEaseType.EASE_OUT, MOAIEaseType.FLAT MOAIEaseType.LINEAR,
								MOAIEaseType.SMOOTH, MOAIEaseType.SOFT_EASE_IN, MOAIEaseType.SOFT_EASE_OUT, MOAIEaseType.SOFT_SMOOTH. Defaults to MOAIEaseType.SMOOTH.

	@out	MOAIEaseDriver easeDriver
*/
int MOAITransform::_seekRot ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )

	float delay		= state.GetValue < float >( 5, 0.0f );
	
	if ( delay > 0.0f ) {
	
		u32 mode = state.GetValue < u32 >( 6, ZLInterpolate::kSmooth );
		
		MOAIEaseDriver* action = new MOAIEaseDriver ();
		
		action->ParseForSeek ( state, 2, self, 3, mode,
			MOAITransformAttr::Pack ( ATTR_X_ROT ), self->mRot.mX, 0.0f,
			MOAITransformAttr::Pack ( ATTR_Y_ROT ), self->mRot.mY, 0.0f,
			MOAITransformAttr::Pack ( ATTR_Z_ROT ), self->mRot.mZ, 0.0f
		);
		
		action->SetSpan ( delay );
		action->Start ( 0, false );
		action->PushLuaUserdata ( state );

		return 1;
	}
	
	ZLVec3D rot = state.GetVec3D < float >( 2, 0.0f );
	if ( !rot.Compare ( self->mRot )) {
		self->SetRot ( rot );
		self->ScheduleUpdate ();
	}
	
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	seekScl
	@text	Animate the transform by applying a delta. Delta is computed
			given a target value. Creates and returns a MOAIEaseDriver
			initialized to apply the delta.
	
	@in		MOAITransform self
	@in		number xSclGoal		Desired resulting value for x scale.
	@in		number ySclGoal		Desired resulting value for y scale.
	@in		number zSclGoal		Desired resulting value for z scale.
	@in		number length		Length of animation in seconds.
	@opt	number mode			The ease mode. One of MOAIEaseType.EASE_IN, MOAIEaseType.EASE_OUT, MOAIEaseType.FLAT MOAIEaseType.LINEAR,
								MOAIEaseType.SMOOTH, MOAIEaseType.SOFT_EASE_IN, MOAIEaseType.SOFT_EASE_OUT, MOAIEaseType.SOFT_SMOOTH. Defaults to MOAIEaseType.SMOOTH.

	@out	MOAIEaseDriver easeDriver
*/
int MOAITransform::_seekScl ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )

	float delay		= state.GetValue < float >( 5, 0.0f );
	
	if ( delay > 0.0f ) {
	
		u32 mode = state.GetValue < u32 >( 6, ZLInterpolate::kSmooth );

		MOAIEaseDriver* action = new MOAIEaseDriver ();
		
		action->ParseForSeek ( state, 2, self, 3, mode,
			MOAITransformAttr::Pack ( ATTR_X_SCL ), self->mScale.mX, 1.0f,
			MOAITransformAttr::Pack ( ATTR_Y_SCL ), self->mScale.mY, 1.0f,
			MOAITransformAttr::Pack ( ATTR_Z_SCL ), self->mScale.mZ, 1.0f
		);
		
		action->SetSpan ( delay );
		action->Start ( 0, false );
		action->PushLuaUserdata ( state );

		return 1;
	}
	
	ZLVec3D scl = state.GetVec3D < float >( 2, 1.0f );
	if ( !scl.Compare ( self->mScale )) {
		self->SetScl ( scl );
		self->ScheduleUpdate ();
	}
	
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setLoc
	@text	Sets the transform's location.
	
	@in		MOAITransform self
	@opt	number x				Default value is 0.
	@opt	number y				Default value is 0.
	@opt	number z				Default value is 0.
	@out	nil
*/
int MOAITransform::_setLoc ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	ZLVec3D loc = state.GetVec3D < float >( 2, 0.0f );
	
	if ( !loc.Compare ( self->mLoc )) {
		self->SetLoc ( loc );
		self->ScheduleUpdate ();
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setLocX
	@text	Sets the transform's location X.
	
	@in		MOAITransform self
	@opt	number x				Default value is 0.
	@out	nil
*/
int MOAITransform::_setLocX ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	float locX = state.GetValue < float >( 2, 0.0f );
	
	if ( locX != self->mLoc.mX ) {
		self->SetLoc ( locX, self->mLoc.mY, self->mLoc.mZ );
		self->ScheduleUpdate ();
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setLocY
	@text	Sets the transform's location Y.
	
	@in		MOAITransform self
	@opt	number y				Default value is 0.
	@out	nil
*/
int MOAITransform::_setLocY ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	float locY = state.GetValue < float >( 2, 0.0f );
	
	if ( locY != self->mLoc.mY ) {
		self->SetLoc ( self->mLoc.mX, locY, self->mLoc.mZ );
		self->ScheduleUpdate ();
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setLocZ
	@text	Sets the transform's location Z.
	
	@in		MOAITransform self
	@opt	number z				Default value is 0.
	@out	nil
*/
int MOAITransform::_setLocZ ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	float locZ = state.GetValue < float >( 2, 0.0f );
	
	if ( locZ != self->mLoc.mZ ) {
		self->SetLoc ( self->mLoc.mX, self->mLoc.mY, locZ );
		self->ScheduleUpdate ();
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setPiv
	@text	Sets the transform's pivot.
	
	@in		MOAITransform self
	@opt	number xPiv			Default value is 0.
	@opt	number yPiv			Default value is 0.
	@opt	number zPiv			Default value is 0.
	@out	nil
*/
int MOAITransform::_setPiv ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	ZLVec3D piv = state.GetVec3D < float >( 2, 0.0f );
	
	if ( !piv.Compare ( self->mPiv )) {
		self->SetPiv ( piv );
		self->ScheduleUpdate ();
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setPivX
	@text	Sets the transform's pivot X.
	
	@in		MOAITransform self
	@opt	number xPiv			Default value is 0.
	@out	nil
*/
int MOAITransform::_setPivX ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	float pivX = state.GetValue < float >( 2, 0.0f );
	
	if ( pivX != ( self->mPiv.mX )) {
		self->SetPiv ( pivX, self->mPiv.mY, self->mPiv.mZ );
		self->ScheduleUpdate ();
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setPivY
	@text	Sets the transform's pivot Y.
	
	@in		MOAITransform self
	@opt	number yPiv			Default value is 0.
	@out	nil
*/
int MOAITransform::_setPivY ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	float pivY = state.GetValue < float >( 2, 0.0f );
	
	if ( pivY != ( self->mPiv.mY )) {
		self->SetPiv ( self->mPiv.mX, pivY, self->mPiv.mZ );
		self->ScheduleUpdate ();
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setPivZ
	@text	Sets the transform's pivot Z.
	
	@in		MOAITransform self
	@opt	number zPiv			Default value is 0.
	@out	nil
*/
int MOAITransform::_setPivZ ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	float pivZ = state.GetValue < float >( 2, 0.0f );
	
	if ( pivZ != ( self->mPiv.mZ )) {
		self->SetPiv ( self->mPiv.mX, self->mPiv.mY, pivZ );
		self->ScheduleUpdate ();
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setRot
	@text	Sets the transform's rotation.
	
	@in		MOAITransform self
	@opt	number xRot			Default value is 0.
	@opt	number yRot			Default value is 0.
	@opt	number zRot			Default value is 0.
	@out	nil
*/
int MOAITransform::_setRot ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	ZLVec3D rot = state.GetVec3D < float >( 2, 0.0f );
	
	if ( !rot.Compare ( self->mRot )) {
		self->SetRot ( rot );
		self->ScheduleUpdate ();
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setRotX
	@text	Sets the transform's rotation X.
	
	@in		MOAITransform self
	@opt	number xRot			Default value is 0.
	@out	nil
*/
int MOAITransform::_setRotX ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	float rotX = state.GetValue < float >( 2, 0.0f );
	
	if ( rotX != self->mRot.mX ) {
		self->SetRot ( rotX, self->mRot.mY, self->mRot.mZ );
		self->ScheduleUpdate ();
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setRotY
	@text	Sets the transform's rotation Y.
	
	@in		MOAITransform self
	@opt	number yRot			Default value is 0.
	@out	nil
*/
int MOAITransform::_setRotY ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	float rotY = state.GetValue < float >( 2, 0.0f );
	
	if ( rotY != self->mRot.mY ) {
		self->SetRot ( self->mRot.mX, rotY, self->mRot.mZ );
		self->ScheduleUpdate ();
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setRotZ
	@text	Sets the transform's rotation Z.
	
	@in		MOAITransform self
	@opt	number zRot			Default value is 0.
	@out	nil
*/
int MOAITransform::_setRotZ ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	float rotZ = state.GetValue < float >( 2, 0.0f );
	
	if ( rotZ != self->mRot.mZ ) {
		self->SetRot ( self->mRot.mX, self->mRot.mY, rotZ );
		self->ScheduleUpdate ();
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setScl
	@text	Sets the transform's scale.
	
	@in		MOAITransform self
	@in		number xScl
	@opt	number yScl			Default value is xScl.
	@opt	number zScl			Default value is 1.
	@out	nil
*/
int MOAITransform::_setScl ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	ZLVec3D scl;
	
	scl.mX = state.GetValue < float >( 2, 0.0f );
	scl.mY = state.GetValue < float >( 3, scl.mX );
	scl.mZ = state.GetValue < float >( 4, 1.0f );
	
	if ( !scl.Compare ( self->mScale )) {
		self->SetScl ( scl );
		self->ScheduleUpdate ();
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setSclX
	@text	Sets the transform's scale X.
	
	@in		MOAITransform self
	@in		number xScl			Default value is 1.	
	@out	nil
*/
int MOAITransform::_setSclX ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	float sclX = state.GetValue < float >( 2, 1.0f );
	
	if ( sclX != self->mScale.mX ) {
		self->SetScl ( sclX, self->mScale.mY, self->mScale.mZ );
		self->ScheduleUpdate ();
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setSclY
	@text	Sets the transform's scale Y.
	
	@in		MOAITransform self
	@in		number yScl			Default value is 1.	
	@out	nil
*/
int MOAITransform::_setSclY ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	float sclY = state.GetValue < float >( 2, 1.0f );
	
	if ( sclY != self->mScale.mY ) {
		self->SetScl ( self->mScale.mX, sclY, self->mScale.mZ );
		self->ScheduleUpdate ();
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setSclZ
	@text	Sets the transform's scale Z.
	
	@in		MOAITransform self
	@in		number zScl			Default value is 1.	
	@out	nil
*/
int MOAITransform::_setSclZ ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )
	
	float sclZ = state.GetValue < float >( 2, 1.0f );
	
	if ( sclZ != self->mScale.mZ ) {
		self->SetScl ( self->mScale.mX, self->mScale.mY, sclZ );
		self->ScheduleUpdate ();
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setShearByX
	@text	Sets the shear for the Y and Z axes by X.
	
	@in		MOAITransform self
	@in		number yx			Default value is 0.
	@opt	number zx			Default value is 0.
	@out	nil
*/
int MOAITransform::_setShearByX ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )

	self->mShearYX = state.GetValue < float >( 2, 0.0f );
	self->mShearZX = state.GetValue < float >( 3, 0.0f );

	self->ScheduleUpdate ();

	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setShearByY
	@text	Sets the shear for the X and Z axes by Y.
	
	@in		MOAITransform self
	@in		number xy			Default value is 0.
	@opt	number zy			Default value is 0.
	@out	nil
*/
int MOAITransform::_setShearByY ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )

	self->mShearXY = state.GetValue < float >( 2, 0.0f );
	self->mShearZY = state.GetValue < float >( 3, 0.0f );

	self->ScheduleUpdate ();

	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setShearByZ
	@text	Sets the shear for the X and Y axes by Z.
	
	@in		MOAITransform self
	@in		number xz			Default value is 0.
	@opt	number yz			Default value is 0.
	@out	nil
*/
int MOAITransform::_setShearByZ ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAITransform, "U" )

	self->mShearXZ = state.GetValue < float >( 2, 0.0f );
	self->mShearYZ = state.GetValue < float >( 3, 0.0f );

	self->ScheduleUpdate ();

	return 0;
}

//================================================================//
// MOAITransform
//================================================================//

//----------------------------------------------------------------//
float MOAITransform::ClampEuler ( float r ) {

	if ( r >= 360.0f ) {
		r = ( float )fmod ( r, 360.0f );
	}
	else if ( r < 0.0f ) {
		r = 360.0f + ( float )fmod ( r, 360.0f );
	}
	return r;
}

//----------------------------------------------------------------//
ZLAffine3D MOAITransform::GetBillboardMtx ( const ZLAffine3D& faceCameraMtx ) const {

	ZLAffine3D billboardMtx = this->GetLocalToWorldMtx ();
		
	ZLVec3D piv;
	ZLVec3D worldLoc;
	
	// world space location for prop
	worldLoc.mX = billboardMtx.m [ ZLAffine3D::C3_R0 ];
	worldLoc.mY = billboardMtx.m [ ZLAffine3D::C3_R1 ];
	worldLoc.mZ = billboardMtx.m [ ZLAffine3D::C3_R2 ];
	
	// just the rotate/scale matrices
	billboardMtx.m [ ZLAffine3D::C3_R0 ] = 0.0f;
	billboardMtx.m [ ZLAffine3D::C3_R1 ] = 0.0f;
	billboardMtx.m [ ZLAffine3D::C3_R2 ] = 0.0f;
	
	// remove original pivot
	piv = this->mPiv;
	billboardMtx.Transform ( piv );
	worldLoc.Add ( piv );
	
	// orient to face the camera
	billboardMtx.Append ( faceCameraMtx );
	
	// add new pivot
	piv = this->mPiv;
	billboardMtx.Transform ( piv );
	worldLoc.Sub ( piv );
	
	// remove the original pivot
	billboardMtx.m [ ZLAffine3D::C3_R0 ] = worldLoc.mX;
	billboardMtx.m [ ZLAffine3D::C3_R1 ] = worldLoc.mY;
	billboardMtx.m [ ZLAffine3D::C3_R2 ] = worldLoc.mZ;
	
	return billboardMtx;
}

//----------------------------------------------------------------//
MOAITransform::MOAITransform () :
	mShearYX ( 0.0f ),
	mShearZX ( 0.0f ),
	mShearXY ( 0.0f ),
	mShearZY ( 0.0f ),
	mShearXZ ( 0.0f ),
	mShearYZ ( 0.0f ),
	mPiv ( 0.0f, 0.0f, 0.0f ),
	mLoc ( 0.0f, 0.0f, 0.0f ),
	mScale ( 1.0f, 1.0f, 1.0f ),
	mRot ( 0.0f, 0.0f, 0.0f ),
	mEulerOrder ( EULER_XYZ ) {
	
	RTTI_BEGIN
		RTTI_EXTEND ( MOAITransformBase )
	RTTI_END
}

//----------------------------------------------------------------//
MOAITransform::~MOAITransform () {
}

//----------------------------------------------------------------//
void MOAITransform::RegisterLuaClass ( MOAILuaState& state ) {
	
	MOAITransformBase::RegisterLuaClass ( state );
	
	state.SetField ( -1, "ATTR_X_PIV",			MOAITransformAttr::Pack ( ATTR_X_PIV ));
	state.SetField ( -1, "ATTR_Y_PIV",			MOAITransformAttr::Pack ( ATTR_Y_PIV ));
	state.SetField ( -1, "ATTR_Z_PIV",			MOAITransformAttr::Pack ( ATTR_Z_PIV ));
	state.SetField ( -1, "ATTR_X_LOC",			MOAITransformAttr::Pack ( ATTR_X_LOC ));
	state.SetField ( -1, "ATTR_Y_LOC",			MOAITransformAttr::Pack ( ATTR_Y_LOC ));
	state.SetField ( -1, "ATTR_Z_LOC",			MOAITransformAttr::Pack ( ATTR_Z_LOC ));
	state.SetField ( -1, "ATTR_X_ROT",			MOAITransformAttr::Pack ( ATTR_X_ROT ));
	state.SetField ( -1, "ATTR_Y_ROT",			MOAITransformAttr::Pack ( ATTR_Y_ROT ));
	state.SetField ( -1, "ATTR_Z_ROT",			MOAITransformAttr::Pack ( ATTR_Z_ROT ));
	state.SetField ( -1, "ATTR_X_SCL",			MOAITransformAttr::Pack ( ATTR_X_SCL ));
	state.SetField ( -1, "ATTR_Y_SCL",			MOAITransformAttr::Pack ( ATTR_Y_SCL ));
	state.SetField ( -1, "ATTR_Z_SCL",			MOAITransformAttr::Pack ( ATTR_Z_SCL ));
	state.SetField ( -1, "ATTR_ROTATE_QUAT",	MOAITransformAttr::Pack ( ATTR_ROTATE_QUAT ));
	state.SetField ( -1, "ATTR_TRANSLATE",		MOAITransformAttr::Pack ( ATTR_TRANSLATE ));
}

//----------------------------------------------------------------//
void MOAITransform::RegisterLuaFuncs ( MOAILuaState& state ) {
	
	MOAITransformBase::RegisterLuaFuncs ( state );
	
	luaL_Reg regTable [] = {
		{ "addLoc",				_addLoc },
		{ "addPiv",				_addPiv },
		{ "addRot",				_addRot },
		{ "addScl",				_addScl },
		{ "getLoc",				_getLoc },
		{ "getLocX",			_getLocX },
		{ "getLocY",			_getLocY },
		{ "getLocZ",			_getLocZ },
		{ "getPiv",				_getPiv },
		{ "getPivX",			_getPivX },
		{ "getPivY",			_getPivY },
		{ "getPivZ",			_getPivZ },
		{ "getRot",				_getRot },
		{ "getRotX",			_getRotX },
		{ "getRotY",			_getRotY },
		{ "getRotZ",			_getRotZ },
		{ "getScl",				_getScl },
		{ "getSclX",			_getSclX },
		{ "getSclY",			_getSclY },
		{ "getSclZ",			_getSclZ },
		{ "move",				_move },
		{ "moveLoc",			_moveLoc },
		{ "movePiv",			_movePiv },
		{ "moveRot",			_moveRot },
		{ "moveScl",			_moveScl },
		{ "seek",				_seek },
		{ "seekLoc",			_seekLoc },
		{ "seekPiv",			_seekPiv },
		{ "seekRot",			_seekRot },
		{ "seekScl",			_seekScl },
		{ "setLoc",				_setLoc },
		{ "setLocX",			_setLocX },
		{ "setLocY",			_setLocY },
		{ "setLocZ",			_setLocZ },
		{ "setPiv",				_setPiv },
		{ "setPivX",			_setPivX },
		{ "setPivY",			_setPivY },
		{ "setPivZ",			_setPivZ },
		{ "setRot",				_setRot },
		{ "setRotX",			_setRotX },
		{ "setRotY",			_setRotY },
		{ "setRotZ",			_setRotZ },
		{ "setScl",				_setScl },
		{ "setSclX",			_setSclX },
		{ "setSclY",			_setSclY },
		{ "setSclZ",			_setSclZ },
		{ "setShearByX",		_setShearByX },
		{ "setShearByY",		_setShearByY },
		{ "setShearByZ",		_setShearByZ },
		{ NULL, NULL }
	};
	
	luaL_register ( state, 0, regTable );
}

//----------------------------------------------------------------//
void MOAITransform::SerializeIn ( MOAILuaState& state, MOAIDeserializer& serializer ) {
	UNUSED ( serializer );
	
	this->mPiv.mX		= state.GetFieldValue < float >( -1, "mPiv.mX", 0.0f );
	this->mPiv.mY		= state.GetFieldValue < float >( -1, "mPiv.mY", 0.0f );
	
	this->mLoc.mX		= state.GetFieldValue < float >( -1, "mLoc.mX", 0.0f );
	this->mLoc.mY		= state.GetFieldValue < float >( -1, "mLoc.mY", 0.0f );
	
	this->mScale.mX		= state.GetFieldValue < float >( -1, "mScale.mX", 1.0f );
	this->mScale.mY		= state.GetFieldValue < float >( -1, "mScale.mY", 1.0f );
	
	this->mRot.mZ		= state.GetFieldValue < float >( -1, "mDegrees", 0.0f );
}

//----------------------------------------------------------------//
void MOAITransform::SerializeOut ( MOAILuaState& state, MOAISerializer& serializer ) {
	UNUSED ( serializer );

	state.SetField ( -1, "mPiv.mX", this->mPiv.mX );
	state.SetField ( -1, "mPiv.mY", this->mPiv.mY );
	
	state.SetField ( -1, "mLoc.mX", this->mLoc.mX );
	state.SetField ( -1, "mLoc.mY", this->mLoc.mY );
	
	state.SetField ( -1, "mScale.mX", this->mScale.mX );
	state.SetField ( -1, "mScale.mY", this->mScale.mY );
	
	state.SetField ( -1, "mDegrees", this->mRot.mZ );
}

//----------------------------------------------------------------//
void MOAITransform::SetLoc ( float x, float y, float z ) {

	this->mLoc.mX = x;
	this->mLoc.mY = y;
	this->mLoc.mZ = z;
}

//----------------------------------------------------------------//
void MOAITransform::SetPiv ( float x, float y, float z ) {

	this->mPiv.mX = x;
	this->mPiv.mY = y;
	this->mPiv.mZ = z;
}

//----------------------------------------------------------------//
void MOAITransform::SetRot ( float x, float y, float z ) {

	this->mRot.mX = x;
	this->mRot.mY = y;
	this->mRot.mZ = z;
}

//----------------------------------------------------------------//
void MOAITransform::SetScl ( float x, float y, float z ) {

	this->mScale.mX = x;
	this->mScale.mY = y;
	this->mScale.mZ = z;
}

//================================================================//
// ::implementation::
//================================================================//

//----------------------------------------------------------------//
bool MOAITransform::MOAINode_ApplyAttrOp ( u32 attrID, MOAIAttribute& attr, u32 op ) {

	if ( MOAITransformAttr::Check ( attrID )) {

		switch ( UNPACK_ATTR ( attrID )) {
		
			case ATTR_X_PIV:
				this->mPiv.mX = attr.Apply ( this->mPiv.mX, op, MOAIAttribute::ATTR_READ_WRITE );
				return true;
				
			case ATTR_Y_PIV:
				this->mPiv.mY = attr.Apply ( this->mPiv.mY, op, MOAIAttribute::ATTR_READ_WRITE );
				return true;
				
			case ATTR_Z_PIV:
				this->mPiv.mZ = attr.Apply ( this->mPiv.mZ, op, MOAIAttribute::ATTR_READ_WRITE );
				return true;
				
			case ATTR_X_LOC:
				this->mLoc.mX = attr.Apply ( this->mLoc.mX, op, MOAIAttribute::ATTR_READ_WRITE );
				return true;
				
			case ATTR_Y_LOC:
				this->mLoc.mY = attr.Apply ( this->mLoc.mY, op, MOAIAttribute::ATTR_READ_WRITE );
				return true;
				
			case ATTR_Z_LOC:
				this->mLoc.mZ = attr.Apply ( this->mLoc.mZ, op, MOAIAttribute::ATTR_READ_WRITE );
				return true;
				
			case ATTR_X_ROT:
				this->mRot.mX = attr.Apply ( this->mRot.mX, op, MOAIAttribute::ATTR_READ_WRITE );
				return true;
				
			case ATTR_Y_ROT:
				this->mRot.mY = attr.Apply ( this->mRot.mY, op, MOAIAttribute::ATTR_READ_WRITE );
				return true;
				
			case ATTR_Z_ROT:
				this->mRot.mZ = attr.Apply ( this->mRot.mZ, op, MOAIAttribute::ATTR_READ_WRITE );
				return true;
				
			case ATTR_X_SCL:
				this->mScale.mX = attr.Apply ( this->mScale.mX, op, MOAIAttribute::ATTR_READ_WRITE );
				return true;
				
			case ATTR_Y_SCL:
				this->mScale.mY = attr.Apply ( this->mScale.mY, op, MOAIAttribute::ATTR_READ_WRITE );
				return true;
				
			case ATTR_Z_SCL:
				this->mScale.mZ = attr.Apply ( this->mScale.mZ, op, MOAIAttribute::ATTR_READ_WRITE );
				return true;
				
			case ATTR_ROTATE_QUAT: {
			
				// TODO: cache rotation as quat to support read/write, delta adds?

				attr.SetFlags ( MOAIAttribute::ATTR_READ_WRITE );

				if ( op == MOAIAttribute::ADD ) {

					ZLQuaternion quat ( this->mRot.mX, this->mRot.mY, this->mRot.mZ );
					quat = attr.Apply ( quat, op, MOAIAttribute::ATTR_WRITE );
					quat.Get ( this->mRot.mX, this->mRot.mY, this->mRot.mZ );
				}
				else if ( op != MOAIAttribute::CHECK ) {

					ZLQuaternion quat ( 0.0f, 0.0f, 0.0f, 0.0f );
					quat = attr.Apply ( quat, op, MOAIAttribute::ATTR_WRITE );
					quat.Get ( this->mRot.mX, this->mRot.mY, this->mRot.mZ );
				}
				return true;
			}
			case ATTR_TRANSLATE:
				this->mLoc = attr.Apply ( this->mLoc, op, MOAIAttribute::ATTR_READ_WRITE );
				return true;
		}
	}
	return MOAITransformBase::MOAINode_ApplyAttrOp ( attrID, attr, op );
}

//----------------------------------------------------------------//
void MOAITransform::MOAITransformBase_BuildLocalToWorldMtx ( ZLAffine3D& localToWorldMtx ) {

	float xRot = ClampEuler ( this->mRot.mX ) * ( float )D2R;
	float yRot = ClampEuler ( this->mRot.mY ) * ( float )D2R;
	float zRot = ClampEuler ( this->mRot.mZ ) * ( float )D2R;

	if ( this->mEulerOrder == EULER_XYZ ) {

		localToWorldMtx.ScRoTr (
			this->mScale.mX,
			this->mScale.mY,
			this->mScale.mZ,
			xRot,
			yRot,
			zRot,
			this->mLoc.mX,
			this->mLoc.mY,
			this->mLoc.mZ
		);
	}
	else {
	
		localToWorldMtx.Scale ( this->mScale.mX, this->mScale.mY, this->mScale.mZ );
	
		ZLAffine3D euler [ 3 ];
		
		euler [ 0 ].RotateX ( xRot );
		euler [ 1 ].RotateY ( yRot );
		euler [ 2 ].RotateZ ( zRot );
		
		u32 idx = this->mEulerOrder & 0x03;
		localToWorldMtx.Append ( euler [ idx ]);
		
		idx = ( this->mEulerOrder >> 0x02 ) & 0x03;
		localToWorldMtx.Append ( euler [ idx ]);
		
		idx = ( this->mEulerOrder >> 0x04 ) & 0x03;
		localToWorldMtx.Append ( euler [ idx ]);
		
		localToWorldMtx.m [ ZLAffine3D::C3_R0 ] = this->mLoc.mX;
		localToWorldMtx.m [ ZLAffine3D::C3_R1 ] = this->mLoc.mY;
		localToWorldMtx.m [ ZLAffine3D::C3_R2 ] = this->mLoc.mZ;
	}
	
	ZLAffine3D shear;
	shear.Shear ( this->mShearYX, this->mShearZX, this->mShearXY, this->mShearZY, this->mShearXZ, this->mShearYZ );
	localToWorldMtx.Prepend ( shear );
	
	if (( this->mPiv.mX != 0.0f ) || ( this->mPiv.mY != 0.0f ) || ( this->mPiv.mZ != 0.0f )) {
		
		ZLAffine3D pivot;
		pivot.Translate ( -this->mPiv.mX, -this->mPiv.mY, -this->mPiv.mZ );
		localToWorldMtx.Prepend ( pivot );
	}
}
