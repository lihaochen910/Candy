-- import
local TaskModule = require 'candy.task.Task'
local Task = TaskModule.Task
local isTaskGroupBusy = TaskModule.isTaskGroupBusy
local getTaskManager = TaskModule.getTaskManager


-- module
local AsyncTextureLoadTaskModule = {}

TEXTURE_ASYNC_LOAD = false
TextureThreadTaskGroupID = "texture_loading"

--------------------------------------------------------------------
-- AsyncTextureLoadTask
--------------------------------------------------------------------
---@class AsyncTextureLoadTask : Task
local AsyncTextureLoadTask = CLASS: AsyncTextureLoadTask ( Task )
    :MODEL {}

function AsyncTextureLoadTask:__init ( path, transform )
	self.path = path
	self.transform = transform
	self.autoAffirm = game:getUserObject ( "affirm_texture", true )
	self.retry = 3
end

function AsyncTextureLoadTask:setAutoAffirm ( affirm )
	self.autoAffirm = affirm
end

function AsyncTextureLoadTask:getDefaultGroupId ()
	return TextureThreadTaskGroupID
end

function AsyncTextureLoadTask:onExec ( queue )
	local texturePhase, imagePhase, dataPhase
	local dataBuffer = MOAIDataBuffer.new ()
	local image = MOAIImage.new ()
	self.dataBuffer = dataBuffer
	self.image = image

	function texturePhase ( image )
		local debugName = self.debugName or self.path

		if image and image:getSize () > 0 then
			self.texture:load ( image, debugName, true )
		else
			self.texture:load ( dataBuffer, self.imageTransform, debugName, true )
		end

		-- MOCKHelper.setTextureDebugName(self.texture, debugName)

		if self.autoAffirm then
			getRenderManager ():affirmGfxResource ( self.texture )
		end

		self.dataBuffer = nil
		return self:complete ()
	end

	function imagePhase ( databuffer )
		if databuffer and databuffer:getSize () > 0 then
			self.image:loadAsync ( databuffer, self:requestThreadTaskQueue (), texturePhase, self.imageTransform )
		else
			self.dataBuffer = nil

			return self:fail ()
		end
	end

	function dataPhase ()
		dataBuffer:loadAsync ( self.path, self:requestThreadTaskQueue (), imagePhase )
	end

	dataPhase ()
end

function AsyncTextureLoadTask:setTargetTexture ( tex )
	self.texture = tex
end

function AsyncTextureLoadTask:setDebugName ( name )
	self.debugName = name
end

function AsyncTextureLoadTask:onComplete ()
end

function AsyncTextureLoadTask:onFail ()
	_warn ( "failed load texture file:", self.debugName, self.path )
	self.texture:load ( getTexturePlaceHolderImage (), self.imageTransform, self.debugName or self.filename )
end

function AsyncTextureLoadTask:toString ()
	return "<textureLoadTask>" .. self.path .. "\t" .. ( self.debugName or "" )
end

local function isTextureLoadTaskBusy ()
	return isTaskGroupBusy ( TextureThreadTaskGroupID )
end

local function setTextureThreadTaskGroupSize ( size )
	local group = getTaskManager ():getGroup ( TextureThreadTaskGroupID )
	group:setSize ( size )
end


AsyncTextureLoadTaskModule.AsyncTextureLoadTask = AsyncTextureLoadTask
AsyncTextureLoadTaskModule.isTextureLoadTaskBusy = isTextureLoadTaskBusy
AsyncTextureLoadTaskModule.setTextureThreadTaskGroupSize = setTextureThreadTaskGroupSize

return AsyncTextureLoadTaskModule