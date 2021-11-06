// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#ifndef	MOAIFRAMEBUFFERTEXTURE_H
#define	MOAIFRAMEBUFFERTEXTURE_H

#include <moai-sim/MOAIFrameBuffer.h>
#include <moai-sim/MOAISingleTexture.h>

//================================================================//
// MOAIFrameBufferTexture
//================================================================//
/**	@lua	MOAIFrameBufferTexture
	@text	This is an implementation of a frame buffer that may be
			attached to a MOAILayer for offscreen rendering. It is
			also a texture that may be bound and used like any other.
*/
class MOAIFrameBufferTexture :
	public MOAIFrameBuffer,
	public MOAISingleTexture {
private:
	
	ZLGfxHandle*		mGLColorBufferID;
	ZLGfxHandle*		mGLDepthBufferID;
	ZLGfxHandle*		mGLStencilBufferID;
	
	u32					mColorFormat;
	u32					mDepthFormat;
	u32					mStencilFormat;
	
	//----------------------------------------------------------------//
	static int			_init					( lua_State* L );
	
	//----------------------------------------------------------------//
	bool				OnGPUCreate					();
	void				OnGPUDeleteOrDiscard		( bool shouldDelete );

public:
	
	friend class MOAIGfxMgr;
	friend class MOAISingleTexture;
	
	DECL_LUA_FACTORY ( MOAIFrameBufferTexture )
	
	//----------------------------------------------------------------//
	void				Init						( u32 width, u32 height, u32 colorFormat, u32 depthFormat, u32 stencilFormat );
						MOAIFrameBufferTexture		();
						~MOAIFrameBufferTexture		();
	void				RegisterLuaClass			( MOAILuaState& state );
	void				RegisterLuaFuncs			( MOAILuaState& state );
	void				Render						( MOAIFrameBufferRenderCommand* command );
	void				SerializeIn					( MOAILuaState& state, MOAIDeserializer& serializer );
	void				SerializeOut				( MOAILuaState& state, MOAISerializer& serializer );
};

#endif
