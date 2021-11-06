// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#include "pch.h"
#include <moai-sim/MOAIColor.h>
#include <moai-sim/MOAIFrameBuffer.h>
#include <moai-sim/MOAIGfxMgr.h>
#include <moai-sim/MOAIGfxResourceClerk.h>
#include <moai-sim/MOAIImage.h>
#include <moai-sim/MOAIRenderable.h>
#include <moai-sim/MOAIRenderMgr.h>

//================================================================//
// local
//================================================================//

//----------------------------------------------------------------//
/**	@lua	setClearColor
	@text	At the start of each frame the device will by default automatically
			render a background color.  Using this function you can set the
			background color that is drawn each frame.  If you specify no arguments
			to this function, then automatic redraw of the background color will
			be turned off (i.e. the previous render will be used as the background).

	@overload

		@in		MOAIClearableView self
		@opt	number red			The red value of the color.
		@opt	number green		The green value of the color.
		@opt	number blue			The blue value of the color.
		@opt	number alpha		The alpha value of the color.
		@out	nil
	
	@overload
		
		@in		MOAIClearableView self
		@in		MOAIColor color
		@out	nil
*/
int MOAIClearableView::_setClearColor ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIClearableView, "U" )
	
	MOAIColor* color = state.GetLuaObject < MOAIColor >( 2, true );
	if ( color ) {
		self->SetClearColor ( color );
		self->mClearFlags |= ZGL_CLEAR_COLOR_BUFFER_BIT;
		return 0;
	}
	
	// don't clear the color
	self->mClearFlags &= ~ZGL_CLEAR_COLOR_BUFFER_BIT;
	self->SetClearColor ( 0 );

	if ( state.GetTop () > 1 ) {
	
		float r = state.GetValue < float >( 2, 0.0f );
		float g = state.GetValue < float >( 3, 0.0f );
		float b = state.GetValue < float >( 4, 0.0f );
		float a = state.GetValue < float >( 5, 1.0f );
		
		self->mClearColor = ZLColor::PackRGBA ( r, g, b, a );
		self->mClearFlags |= ZGL_CLEAR_COLOR_BUFFER_BIT;
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setClearDepth
	@text	At the start of each frame the buffer will by default automatically
			clear the depth buffer.  This function sets whether or not the depth
			buffer should be cleared at the start of each frame.

	@in		MOAIClearableView self
	@in		boolean clearDepth	Whether to clear the depth buffer each frame.
	@out	nil
*/
int MOAIClearableView::_setClearDepth ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIClearableView, "U" )
	
	bool clearDepth = state.GetValue < bool >( 2, false );
	
	if ( clearDepth ) {
		self->mClearFlags |= ZGL_CLEAR_DEPTH_BUFFER_BIT;
	}
	else {
		self->mClearFlags &= ~ZGL_CLEAR_DEPTH_BUFFER_BIT;
	}
	return 0;
}

//================================================================//
// MOAIClearableView
//================================================================//

//----------------------------------------------------------------//
void MOAIClearableView::ClearSurface () {

	if ( this->mClearFlags & ZGL_CLEAR_COLOR_BUFFER_BIT ) {
	
		ZLColorVec clearColor;
		
		if ( this->mClearColorNode ) {
			clearColor = this->mClearColorNode->GetColorTrait ();
		}
		else {
			clearColor.SetRGBA ( this->mClearColor );
		}
		
		MOAIGfxMgr::GetDrawingAPI ().ClearColor (
			clearColor.mR,
			clearColor.mG,
			clearColor.mB,
			clearColor.mA
		);
	}

	MOAIGfxMgr::Get ().ClearSurface ( this->mClearFlags );
}

//----------------------------------------------------------------//
MOAIClearableView::MOAIClearableView () :
	mClearFlags ( ZGL_CLEAR_COLOR_BUFFER_BIT ),
	mClearColor ( 0 ),
	mClearColorNode ( 0 ) {
	
	RTTI_BEGIN
		RTTI_EXTEND ( MOAILuaObject )
	RTTI_END
}

//----------------------------------------------------------------//
MOAIClearableView::~MOAIClearableView () {

	this->SetClearColor ( 0 );
}

//----------------------------------------------------------------//
bool MOAIClearableView::IsOpaque () const {

	ZLColorVec clearColor;
		
	if ( this->mClearColorNode ) {
		clearColor = this->mClearColorNode->GetColorTrait ();
	}
	else {
		clearColor.SetRGBA ( this->mClearColor );
	}
	return clearColor.IsOpaque ();
}

//----------------------------------------------------------------//
void MOAIClearableView::RegisterLuaClass ( MOAILuaState& state ) {
	UNUSED ( state );
}

//----------------------------------------------------------------//
void MOAIClearableView::RegisterLuaFuncs ( MOAILuaState& state ) {

	luaL_Reg regTable [] = {
		{ "setClearColor",				_setClearColor },
		{ "setClearDepth",				_setClearDepth },
		{ NULL, NULL }
	};

	luaL_register ( state, 0, regTable );
}

//----------------------------------------------------------------//
void MOAIClearableView::SetClearColor ( MOAIColor* color ) {

	if ( this->mClearColorNode != color ) {
		this->LuaRelease ( this->mClearColorNode );
		this->LuaRetain ( color );
		this->mClearColorNode = color;
	}
}


//================================================================//
// local
//================================================================//

//----------------------------------------------------------------//
/**	@lua	setClearColor
	@text	At the start of each frame the device will by default automatically
			render a background color.  Using this function you can set the
			background color that is drawn each frame.  If you specify no arguments
			to this function, then automatic redraw of the background color will
			be turned off (i.e. the previous render will be used as the background).
	@overload
		@in		MOAIFrameBufferRenderCommand self
		@opt	number red			The red value of the color.
		@opt	number green		The green value of the color.
		@opt	number blue			The blue value of the color.
		@opt	number alpha		The alpha value of the color.
		@out	nil
	
	@overload
		
		@in		MOAIFrameBufferRenderCommand self
		@in		MOAIColor color
		@out	nil
*/
int MOAIFrameBufferRenderCommand::_setClearColor ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIFrameBufferRenderCommand, "U" )
	
	MOAIColor* colorNode = state.GetLuaObject < MOAIColor >( 2, true );
	if ( colorNode ) {
		self->SetClearColorNode ( colorNode );
		self->mClearFlags |= ZGL_CLEAR_COLOR_BUFFER_BIT;
		return 0;
	}
	
	// don't clear the color
	self->mClearFlags &= ~ZGL_CLEAR_COLOR_BUFFER_BIT;
	self->SetClearColorNode ( 0 );

	if ( state.GetTop () > 1 ) {
	
		float r = state.GetValue < float >( 2, 0.0f );
		float g = state.GetValue < float >( 3, 0.0f );
		float b = state.GetValue < float >( 4, 0.0f );
		float a = state.GetValue < float >( 5, 1.0f );
		
		self->mClearColor = ZLColor::PackRGBA ( r, g, b, a );
		self->mClearFlags |= ZGL_CLEAR_COLOR_BUFFER_BIT;
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setClearDepth
	@text	At the start of each frame the buffer will by default automatically
			clear the depth buffer.  This function sets whether or not the depth
			buffer should be cleared at the start of each frame.
	@in		MOAIFrameBufferRenderCommand self
	@in		boolean clearDepth	Whether to clear the depth buffer each frame.
	@out	nil
*/
int MOAIFrameBufferRenderCommand::_setClearDepth ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIFrameBufferRenderCommand, "U" )
	
	bool clearDepth = state.GetValue < bool >( 2, false );
	
	if ( clearDepth ) {
		self->mClearFlags |= ZGL_CLEAR_DEPTH_BUFFER_BIT;
	}
	else {
		self->mClearFlags &= ~ZGL_CLEAR_DEPTH_BUFFER_BIT;
	}
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	setClearStencil
	@text	At the start of each frame the buffer will by default automatically
			clear the Stencil buffer.  This function sets whether or not the Stencil
			buffer should be cleared at the start of each frame.
	@in		MOAIFrameBufferRenderCommand self
	@in		boolean clearStencil	Whether to clear the Stencil buffer each frame.
	@out	nil
*/
int MOAIFrameBufferRenderCommand::_setClearStencil ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIFrameBufferRenderCommand, "U" )
	
	bool clearStencil = state.GetValue < bool >( 2, false );
	
	if ( clearStencil ) {
		self->mClearFlags |= ZGL_CLEAR_STENCIL_BUFFER_BIT;
	}
	else {
		self->mClearFlags &= ~ZGL_CLEAR_STENCIL_BUFFER_BIT;
	}
	return 0;
}


//----------------------------------------------------------------//
/**	@lua	setEnabled
	@text	setEnabled
	
	@in		MOAIFrameBufferRenderCommand self
	@in		boolean enabled ( default is true )
	@out	nil
*/
int MOAIFrameBufferRenderCommand::_setEnabled ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIFrameBufferRenderCommand, "U" )
	self->mEnabled = state.GetValue < bool >( 2, true );
	return 0;
}

//----------------------------------------------------------------//
/**	@lua	isEnabled
	@text	check enabled
	
	@in		MOAIFrameBufferRenderCommand self
	@out	boolean enabled
*/
int MOAIFrameBufferRenderCommand::_isEnabled ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIFrameBufferRenderCommand, "U" )
	state.Push( self->mEnabled );
	return 1;
}


//----------------------------------------------------------------//
/**	@lua	setFrameBuffer
	@text	Sets the table to be used for rendering. This should be
			an array indexed from 1 consisting of MOAIRenderable objects
			and sub-tables. Objects will be rendered in order starting
			from index 1 and continuing until 'nil' is encountered.
	
	@in		MOAIFrameBufferRenderCommand self
	@in		MOAIFrameBuffer buffer
	@out	nil
*/
int MOAIFrameBufferRenderCommand::_setFrameBuffer ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIFrameBufferRenderCommand, "UU" )
	
	MOAIFrameBuffer* buffer = state.GetLuaObject < MOAIFrameBuffer >( 2, true );

	self->mFrameBuffer.Set ( *self, buffer );

	return 0;
}


//----------------------------------------------------------------//
/**	@lua	setRenderTable
	@text	Sets the table to be used for rendering. This should be
			an array indexed from 1 consisting of MOAIRenderable objects
			and sub-tables. Objects will be rendered in order starting
			from index 1 and continuing until 'nil' is encountered.
	
	@in		MOAIFrameBufferRenderCommand self
	@in		table renderTable
	@out	nil
*/
int MOAIFrameBufferRenderCommand::_setRenderTable ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIFrameBufferRenderCommand, "U" )
	self->mRenderTable.SetRef ( state, 2 );
	return 0;
}

//----------------------------------------------------------------//
MOAIFrameBufferRenderCommand::MOAIFrameBufferRenderCommand () :
	mClearFlags ( ZGL_CLEAR_COLOR_BUFFER_BIT ),
	mClearColor ( 0 ),
	mClearColorNode ( 0 ),
	mEnabled    ( true ) {
	
	RTTI_BEGIN
		RTTI_EXTEND ( MOAILuaObject )
	RTTI_END
}

//----------------------------------------------------------------//
MOAIFrameBufferRenderCommand::~MOAIFrameBufferRenderCommand () {
	this->SetClearColorNode( 0 );
	this->mFrameBuffer.Set ( *this, 0 );
}

//----------------------------------------------------------------//
void MOAIFrameBufferRenderCommand::RegisterLuaClass ( MOAILuaState& state ) {

	UNUSED( state );
}

//----------------------------------------------------------------//
void MOAIFrameBufferRenderCommand::RegisterLuaFuncs ( MOAILuaState& state ) {

	luaL_Reg regTable [] = {
		{ "setClearDepth",				_setClearDepth },
		{ "setClearColor",				_setClearColor },
		{ "setClearStencil",			_setClearStencil },
		{ "setEnabled",					_setEnabled },
		{ "isEnabled",					_isEnabled },
		{ "setFrameBuffer",				_setFrameBuffer },
		{ "setRenderTable",				_setRenderTable },
		{ NULL, NULL }
	};

	luaL_register ( state, 0, regTable );
}

//----------------------------------------------------------------//
void MOAIFrameBufferRenderCommand::Render () {
	if ( !this->mFrameBuffer ) return;
	this->mFrameBuffer->Render ( this );
}

//----------------------------------------------------------------//
void MOAIFrameBufferRenderCommand::SetClearColorNode ( MOAIColor* color ) {

	if ( this->mClearColorNode != color ) {
		this->LuaRelease ( this->mClearColorNode );
		this->LuaRetain ( color );
		this->mClearColorNode = color;
	}
}


//================================================================//
// local
//================================================================//

//----------------------------------------------------------------//
/**	@lua	getGrabbedImage
	@text	Returns the image into which frame(s) will be (or were) grabbed (if any).

	@in		MOAIFrameBuffer self
	@opt	boolean discard			If true, image will be discarded from the frame buffer.
	@out	MOAIImage image			The frame grab image, or nil if none exists.
*/	
int MOAIFrameBuffer::_getGrabbedImage ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIFrameBuffer, "U" )
	
	bool discard = state.GetValue < bool >( 2, false );
	
	self->mFrameImage.PushRef ( state );
	
	if ( discard ) {
		self->mFrameImage.Set ( *self, 0 );
	}
	
	return 1;
}


//----------------------------------------------------------------//
/**	@lua	getPerformanceDrawCount	
	@text	Returns the number of draw calls last frame.	

	@in		MOAIFrameBuffer self
	@out	number count			Number of underlying graphics "draw" calls last frame.
*/	
int MOAIFrameBuffer::_getPerformanceDrawCount ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIFrameBuffer, "U" )
	lua_pushnumber ( L, self->mLastDrawCount );
	return 1;
}

//----------------------------------------------------------------//
/**	@lua	getRenderTable
	@text	Returns the table currently being used for rendering.
	
	@in		MOAIFrameBuffer self
	@out	table renderTable
*/
int MOAIFrameBuffer::_getRenderTable ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIFrameBuffer, "U" )
	state.Push ( self->mRenderTable );
	return 1;
}

//----------------------------------------------------------------//
/**	@lua	grabNextFrame
	@text	Save the next frame rendered to an image. If no image is
			provided, one will be created tp match the size of the frame
			buffer.

	@in		MOAIFrameBuffer self
	@opt	MOAIImage image			Image to save the backbuffer to
	@opt	function callback		The function to execute when the frame has been saved into the image specified
	@out	nil
*/
int MOAIFrameBuffer::_grabNextFrame ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIFrameBuffer, "U" )

	MOAIImage* image = state.GetLuaObject < MOAIImage >( 2, false );
	
	if ( image ) {
		self->mFrameImage.Set ( *self, image );
	}
	else if ( !self->mFrameImage ) {
	
		image = new MOAIImage ();
		image->Init ( self->mBufferWidth, self->mBufferHeight, ZLColor::RGBA_8888, MOAIImage::TRUECOLOR );
		self->mFrameImage.Set ( *self, image );
	}
	
	self->mGrabNextFrame = self->mFrameImage != 0;
	
	if ( self->mGrabNextFrame ) {
		self->mOnFrameFinish.SetRef ( *self, state, 3 );
	}
	else{
		self->mOnFrameFinish.Clear ();
	}

	return 0;
}

//----------------------------------------------------------------//
/**	@lua	isPendingGrab
	@text	True if a frame grab has been requested but not yet grabbed.
	
	@in		MOAIFrameBuffer self
	@out	table renderTable
*/
int MOAIFrameBuffer::_isPendingGrab ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIFrameBuffer, "U" )
	state.Push ( self->mGrabNextFrame );
	return 1;
}

//----------------------------------------------------------------//
/**	@lua	setRenderTable
	@text	Sets the table to be used for rendering. This should be
			an array indexed from 1 consisting of MOAIRenderable objects
			and sub-tables. Objects will be rendered in order starting
			from index 1 and continuing until 'nil' is encountered.
	
	@in		MOAIFrameBuffer self
	@in		table renderTable
	@out	nil
*/
int MOAIFrameBuffer::_setRenderTable ( lua_State* L ) {
	MOAI_LUA_SETUP ( MOAIFrameBuffer, "U" )
	self->mRenderTable.SetRef ( state, 2 );
	return 0;
}

//================================================================//
// MOAIFrameBuffer
//================================================================//

//----------------------------------------------------------------//
void MOAIFrameBuffer::DetectGLFrameBufferID () {

	this->mGLFrameBufferID = MOAIGfxMgr::GetDrawingAPI ().GetCurrentFramebuffer ();
}

//----------------------------------------------------------------//
ZLRect MOAIFrameBuffer::GetBufferRect () const {

	ZLRect rect;
	rect.mXMin = 0;
	rect.mYMin = 0;
	rect.mXMax = ( float )this->mBufferWidth;
	rect.mYMax = ( float )this->mBufferHeight;
	
	return rect;
}

//----------------------------------------------------------------//
void MOAIFrameBuffer::GrabImage ( MOAIImage* image ) {
	UNUSED ( image ); // TODO: doesn't work now?

	// TODO: all this is extremely hinky. this assumes that the framebuffer is RGBA_8888, which it
	// may not be. it also does two extra allocations and copies. what *should* happen is that we
	// grab the pixels directly into the image if the format matches, and create an extra buffer
	// only if we need to convert. we should also implement/use a mirror operation inside of MOAIImage
	// so we don't have to do it here.

//	unsigned char* buffer = ( unsigned char* ) malloc ( this->mBufferWidth * this->mBufferHeight * 4 );
//
//	zglReadPixels ( 0, 0, this->mBufferWidth, this->mBufferHeight, buffer );
//
//	//image is flipped vertically, flip it back
//	int index,indexInvert;
//	for ( u32 y = 0; y < ( this->mBufferHeight / 2 ); ++y ) {
//		for ( u32 x = 0; x < this->mBufferWidth; ++x ) {
//			for ( u32 i = 0; i < 4; ++i ) {
//
//				index = i + ( x * 4 ) + ( y * this->mBufferWidth * 4 );
//				indexInvert = i + ( x * 4 ) + (( this->mBufferHeight - 1 - y ) * this->mBufferWidth * 4 );
//
//				unsigned char temp = buffer [ indexInvert ];
//				buffer [ indexInvert ] = buffer [ index ];
//				buffer [ index ] = temp;
//			}
//		}
//	}
//
//	image->Init ( buffer, this->mBufferWidth, this->mBufferHeight, ZLColor::RGBA_8888 );
//	free ( buffer );
}

//----------------------------------------------------------------//
MOAIFrameBuffer::MOAIFrameBuffer () :
	mBufferWidth ( 0 ),
	mBufferHeight ( 0 ),
	mBufferScale ( 1.0f ),
	mLandscape ( false ),
	mGLFrameBufferID ( 0 ),
	mGrabNextFrame ( false ),
	mRenderCounter ( 0 ),
	mLastDrawCount ( 0 ) {
	
	RTTI_BEGIN
		RTTI_EXTEND ( MOAIClearableView )
	RTTI_END
}

//----------------------------------------------------------------//
MOAIFrameBuffer::~MOAIFrameBuffer () {

	MOAIGfxResourceClerk::DeleteOrDiscardHandle ( this->mGLFrameBufferID, false );
	this->mFrameImage.Set ( *this, 0 );
}

//----------------------------------------------------------------//
void MOAIFrameBuffer::OnReadPixels ( const ZLCopyOnWrite& buffer, void * userdata ) {
	UNUSED ( userdata );

	this->mGrabNextFrame = false;
	MOAIImage* image = this->mFrameImage;
	
	if ( image ) {

		image->Init ( buffer.GetBuffer (), this->mBufferWidth, this->mBufferHeight, ZLColor::RGBA_8888 );

		if ( this->mOnFrameFinish ) {
			MOAIScopedLuaState state = MOAILuaRuntime::Get ().State ();
			if ( this->mOnFrameFinish.PushRef ( state )) {
				this->mFrameImage.PushRef ( state );
				state.DebugCall ( 1, 0 );
			}
		}
	}
}

//----------------------------------------------------------------//
void MOAIFrameBuffer::RegisterLuaClass ( MOAILuaState& state ) {

	MOAIClearableView::RegisterLuaClass ( state );
}

//----------------------------------------------------------------//
void MOAIFrameBuffer::RegisterLuaFuncs ( MOAILuaState& state ) {

	MOAIClearableView::RegisterLuaFuncs ( state );

	luaL_Reg regTable [] = {
		{ "getGrabbedImage",			_getGrabbedImage },
		{ "grabNextFrame",				_grabNextFrame },
		{ "getPerformanceDrawCount",	_getPerformanceDrawCount },
		{ "getRenderTable",				_getRenderTable },
		{ "isPendingGrab",				_isPendingGrab },
		{ "setRenderTable",				_setRenderTable },
		{ NULL, NULL }
	};

	luaL_register ( state, 0, regTable );
}

//----------------------------------------------------------------//
void MOAIFrameBuffer::Render ( MOAIFrameBufferRenderCommand* command ) {

	MOAIGfxMgr& gfxMgr = MOAIGfxMgr::Get ();
	//this->mLastDrawCount = gfxMgr.GetDrawCount ();

	gfxMgr.mGfxState.BindFrameBuffer ( this );
	
	//disable scissor rect for clear
	gfxMgr.mGfxState.SetScissorRect ();
	if ( command ) {
		u32 clearFlags = this->mClearFlags;
		u32 clearColor = this->mClearColor;
		MOAIColor* clearColorNode = this->mClearColorNode;
		this->mClearFlags = command->mClearFlags;
		this->mClearColor = command->mClearColor;
		this->mClearColorNode = command->mClearColorNode;
		this->ClearSurface ();
		if ( command->mRenderTable ) {
			MOAIScopedLuaState state = MOAILuaRuntime::Get ().State ();
			state.Push ( command->mRenderTable );
			this->RenderTable ( state, -1 );
			state.Pop ( 1 );
		}
		this->mClearFlags = clearFlags;
		this->mClearColor = clearColor;
		this->mClearColorNode = clearColorNode;
	}
	else {
		this->ClearSurface ();
		if ( this->mRenderTable ) {
			MOAIScopedLuaState state = MOAILuaRuntime::Get ().State ();
			state.Push ( this->mRenderTable );
			this->RenderTable ( state, -1 );
			state.Pop ( 1 );
		}
	}

	gfxMgr.mVertexCache.FlushBufferedPrims ();

	// since we're doing this on the render thread, set it every time until we get a callback
	if ( this->mGrabNextFrame ) {

		ZLGfx& gfx = MOAIGfxMgr::GetDrawingAPI ();
		gfx.ReadPixels ( 0, 0, this->mBufferWidth, this->mBufferHeight, ZGL_PIXEL_FORMAT_RGBA, ZGL_PIXEL_TYPE_UNSIGNED_BYTE, 4, this, 0 );
	}
	
	this->mRenderCounter++;
	//this->mLastDrawCount = gfxMgr.GetDrawCount () - this->mLastDrawCount;
}

//----------------------------------------------------------------//
void MOAIFrameBuffer::RenderTable ( MOAILuaState& state, int idx ) {

	MOAIRenderMgr& renderMgr = MOAIRenderMgr::Get ();
	idx = state.AbsIndex ( idx );

	int n = 1;
	while ( n ) {
		
		lua_rawgeti ( state, idx, n++ );
		
		int valType = lua_type ( state, -1 );
			
		if ( valType == LUA_TUSERDATA ) {
			MOAIRenderable* renderable = state.GetLuaObject < MOAIRenderable >( -1, false );
			if ( renderable ) {
				renderMgr.SetRenderable ( renderable );
				renderable->Render ();
			}
		}
		else if ( valType == LUA_TTABLE ) {
			this->RenderTable ( state, -1 );
		}
		else {
			n = 0;
		}
		
		lua_pop ( state, 1 );
	}
}

//----------------------------------------------------------------//
void MOAIFrameBuffer::SetBufferSize ( u32 width, u32 height ) {

	this->mBufferWidth = width;
	this->mBufferHeight = height;
}

//----------------------------------------------------------------//
void MOAIFrameBuffer::SetGLFrameBufferID ( ZLGfxHandle* frameBufferID ){
  this->mGLFrameBufferID = frameBufferID;
}

//----------------------------------------------------------------//
ZLRect MOAIFrameBuffer::WndRectToDevice ( ZLRect rect ) const {

	rect.Bless ();

	if ( this->mLandscape ) {
	
		float width = ( float )this->mBufferWidth;
		
		float xMin = rect.mYMin;
		float yMin = width - rect.mXMax;
		float xMax = rect.mYMax;
		float yMax = width - rect.mXMin;
		
		rect.mXMin = xMin;
		rect.mYMin = yMin;
		rect.mXMax = xMax;
		rect.mYMax = yMax;
	}
	else {
	
		float height = ( float )this->mBufferHeight;
		
		float xMin = rect.mXMin;
		float yMin = height - rect.mYMax;
		float xMax = rect.mXMax;
		float yMax = height - rect.mYMin;
		
		rect.mXMin = xMin;
		rect.mYMin = yMin;
		rect.mXMax = xMax;
		rect.mYMax = yMax;
	}

	rect.Scale ( this->mBufferScale, this->mBufferScale );
	return rect;
}