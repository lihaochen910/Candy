----------------------------------------------------------------------------------------------------
-- Skeletal implementation of SoundMgr.
----------------------------------------------------------------------------------------------------

-- import
local Resources = require "candy.asset.Resources"

-- module
local AudioManagerModule = {}

--------------------------------------------------------------------
-- BaseSoundMgr
--------------------------------------------------------------------
---@class BaseSoundMgr
local BaseSoundMgr = CLASS: BaseSoundMgr ()

---
-- Constructor.
function BaseSoundMgr:__init ()
end

function BaseSoundMgr:loadSound ( filePath )
end

function BaseSoundMgr:getSound ( filePath )
end

function BaseSoundMgr:play ( sound, volume, looping )
end

function BaseSoundMgr:pause ( sound )
end

function BaseSoundMgr:stop ( sound )
end

function BaseSoundMgr:setVolume ( volume )
end

function BaseSoundMgr:getVolume ()
end

--------------------------------------------------------------------
-- UntzSoundMgr
--------------------------------------------------------------------
local UntzSoundMgr = CLASS: UntzSoundMgr ( BaseSoundMgr )

--- sampleRate
UntzSoundMgr.SAMPLE_RATE = nil

--- numFrames
UntzSoundMgr.NUM_FRAMES = nil

-- The maximum number of simultaneous playback
UntzSoundMgr.MAX_SFX_COUNT = 40

UntzSoundMgr.DEFAULT_MUSIC_CHANNEL = 1

UntzSoundMgr.NULL_MUSIC_PLACE_HOLDER = "noneMusic"

---
-- Constructor.
---@param sampleRate sample rate
---@param numFrames num frames
function UntzSoundMgr:__init ( sampleRate, numFrames )
    if not MOAIUntzSystem._initialized then
        sampleRate = sampleRate or UntzSoundMgr.SAMPLE_RATE
        numFrames = numFrames or UntzSoundMgr.NUM_FRAMES
        MOAIUntzSystem.initialize ( sampleRate, numFrames )
        MOAIUntzSystem._initialized = true
    end
    
    self._soundMap = {}
    self._playingMusic = {}
    self._playingSFX = {}
end

---
-- Load the MOAIUntzSound.
---@param filePath file path.
---@return sound
function UntzSoundMgr:loadSound ( filePath )
    local sound = MOAIUntzSound.new ()
    sound:load ( filePath )
    sound:setVolume ( 1 )
    sound:setLooping ( false )
    return sound
end

---
-- Return the MOAIUntzSound cached.
---@param filePath file path.
---@return sound
function UntzSoundMgr:getSound ( filePath )
    filePath = Resources.getResourceFilePath ( filePath )
    
    if not self._soundMap[ filePath ] then
        self._soundMap[ filePath ] = self:loadSound ( filePath )
    end
    
    return self._soundMap[ filePath ]
end

---
-- Release the MOAIUntzSound.
---@param filePath file path.
---@return cached sound.
function UntzSoundMgr:release ( filePath )
    local sound = self._soundMap[ filePath ]
    self._soundMap[ filePath ] = nil
    return sound
end

---
-- Play the sound.
---@param sound file path or object.
---@param volume (Optional)volume. Default value is 1.
---@param looping (Optional)looping flag. Default value is 'false'.
---@return Sound object
function UntzSoundMgr:play ( sound, volume, looping )
    sound = type ( sound ) == "string" and self:getSound ( sound ) or sound
    volume = volume or 1
    looping = looping and true or false
    
    sound:setVolume ( volume )
    sound:setLooping ( looping )
    sound:play ()
    return sound
end

---
-- Play the music.
---@param sound file path or object.
---@param channel (Optional)channel. The music channel to play in.
---@param volume (Optional)volume. Default value is 1.
---@param looping (Optional)looping flag. Default value is 'true'.
---@return Sound/Animation object
function UntzSoundMgr:playMusic ( sound, channel, volume, looping, fadeTime )
    sound = type ( sound ) == "string" and self:getSound ( sound ) or sound
    channel = channel or UntzSoundMgr.DEFAULT_MUSIC_CHANNEL
    volume = volume or 1
    looping = looping or true
    fadeTime = fadeTime or 0
    
    sound:setVolume ( volume )
    sound:setLooping ( looping )

    if fadeTime == 0 then
        if self._playingMusic[ channel ] and self._playingMusic[ channel ] ~= UntzSoundMgr.NULL_MUSIC_PLACE_HOLDER then
            self._playingMusic[ channel ]:stop ()
        end
        self._playingMusic[ channel ] = sound
        sound:play ()
        return sound
    else
        if self._playingMusic[ channel ] and self._playingMusic[ channel ] ~= UntzSoundMgr.NULL_MUSIC_PLACE_HOLDER then
            
            if self._playingMusic[ channel ]:getPosition () >= self._playingMusic[ channel ]:getLength () then
                self._playingMusic[ channel ] = sound
                sound:setVolume ( 0 )
                sound:play ()
                return flower.Animation(sound):seekAttr(MOAIUntzSound.ATTR_VOLUME, 1, fadeTime):play()
            else
                return flower.Animation(self._playingMusic[ channel ])
                    :seekAttr(MOAIUntzSound.ATTR_VOLUME, 0, fadeTime)
                    :callFunc( function ()
                        self._playingMusic[ channel ]:stop ()
                        self._playingMusic[ channel ] = sound
                        sound:setVolume ( 0 )
                        sound:play ()
                        flower.Animation(sound):seekAttr(MOAIUntzSound.ATTR_VOLUME, 1, fadeTime):play()
                    end )
                    :play()
            end
        else
            self._playingMusic[ channel ] = sound
            sound:setVolume( 0 )
            sound:play ()
            return flower.Animation(sound):seekAttr(MOAIUntzSound.ATTR_VOLUME, 1, fadeTime):play()
        end
    end
end

---
-- Play the sound FX.
---@param sound file path or object.
---@param volume (Optional)volume. Default value is 1.
---@return Sound object
function UntzSoundMgr:playSFX ( sfx, volume )
    return self:play ( sfx, volume, false )
end

---
-- Pause the sound.
---@param sound file path or object.
function UntzSoundMgr:pause ( sound )
    sound = type ( sound ) == "string" and self:getSound ( sound ) or sound
    sound:pause ()
end

---
-- Pause the music.
---@param channel The music channel to play in.
---@param isPause TODO.
---@param fadeTime TODO.
function UntzSoundMgr:pauseMusic ( channel, isPause, fadeTime )
    channel = channel or UntzSoundMgr.DEFAULT_MUSIC_CHANNEL
    fadeTime = fadeTime or 1
    if self._playingMusic[ channel ] and self._playingMusic[ channel ] ~= UntzSoundMgr.NULL_MUSIC_PLACE_HOLDER then
        if fadeTime == 0 then
            self._playingMusic[ channel ]:pause ()
        else
            flower.Animation(self._playingMusic[ channel ])
                :seekAttr(MOAIUntzSound.ATTR_VOLUME, 0, fadeTime)
                :callFunc(function ()
                    self._playingMusic[ channel ]:pause ()
                end)
                :play()
        end
    end
end

---
-- Stop the sound.
---@param sound file path or object.
function UntzSoundMgr:stop ( sound )
    sound = type ( sound ) == "string" and self:getSound ( sound ) or sound
    sound:stop ()
end

---
-- Stop the music.
---@param channel The music channel to play in.
---@param isPause TODO.
---@param fadeTime TODO.
function UntzSoundMgr:stopMusic ( channel, fadeTime )
    channel = channel or UntzSoundMgr.DEFAULT_MUSIC_CHANNEL
    fadeTime = fadeTime or 1
    if self._playingMusic[ channel ] and self._playingMusic[ channel ] ~= UntzSoundMgr.NULL_MUSIC_PLACE_HOLDER then
        if fadeTime == 0 then
            self._playingMusic[ channel ]:stop ()
        else
            flower.Animation(self._playingMusic[ channel ])
                :seekAttr(MOAIUntzSound.ATTR_VOLUME, 0, fadeTime)
                :callFunc(function ()
                    self._playingMusic[ channel ]:stop ()
                end)
                :play()
        end
    end
end

---
-- Set the system level volume.
---@param volume
function UntzSoundMgr:setVolume ( volume )
    MOAIUntzSystem.setVolume ( volume )
end

---
-- Return the system level volume.
---@return volume
function UntzSoundMgr:getVolume ()
    return MOAIUntzSystem.getVolume ()
end


AudioManagerModule.BaseSoundMgr = BaseSoundMgr
AudioManagerModule.UntzSoundMgr = UntzSoundMgr

return AudioManagerModule