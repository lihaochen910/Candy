-- import
local Config = require "candy.Config"

--------------------------------------------------------------------------------
-- MOAI SDK
--------------------------------------------------------------------------------

-- Setting the FPS
MOAISim.setStep ( 1 / 60 )

-- Setting of the operation of the Loop.
MOAISim.clearLoopFlags ()
MOAISim.setCpuBudget ( 2 )
MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_ALLOW_BOOST )
MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_ALLOW_SPIN + MOAISim.SIM_LOOP_ALLOW_BOOST )


-- Sets the boost threshold
-- MOAISim.setBoostThreshold ( 0 )
MOAISim.setLongDelayThreshold ( 10 )
MOAISim.setBoostThreshold ( 2 )
MOAISim.setStepMultiplier ( 1 )

--------------------------------------------------------------------------------
-- Flower
--------------------------------------------------------------------------------

-- Resources setting
-- candy.Resources.addResourceDirectory ( "assets" )

-- Set the window size
-- if candy.isDesktop () then

--     local brand = MOAIEnvironment.osBrand

--     if brand == 'Windows' then
--         candy.setDefaultWindowSize ( "desktop1920x1080", true, false ) -- windows
--     else
--         candy.setDefaultWindowSize ( "desktop2560x1440", true, true ) -- *nix system
--     end
-- end


-- Set the window title
Config.WINDOW_TITLE = "Game" .. ' - ' .. MOAIEnvironment.osBrand

-- Ver
Config.VERSION = "0.1"

-- Config.WINDOW_WIDTH = 320
-- Config.WINDOW_HEIGHT = 480

-- default y behavior; set to true to have y=0 be the bottom of the screen
Config.VIEWPORT_YFLIP = false

-- Optional table of arguments for setBlendMode on new images.
-- Empty table gives default behavior.
Config.BLEND_MODE = nil

-- High quality rendering of Label
-- When enabled, it may take a long time to display the label.
Config.LABEL_HIGH_QUALITY_ENABLED = true

-- Set the default font
Config.FONT_NAME = "fonts/VL-PGothic.ttf"

-- Set the default font charcodes
-- Optimized by setting the loadable string in advance.
Config.FONT_CHARCODES = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-"

-- Default font points
-- Config.FONT_POINTS = 24

-- Set the default font filter
Config.FONT_FILTER = MOAITexture.GL_LINEAR
-- Config.FONT_FILTER = MOAITexture.GL_NEAREST

-- Set the texture filter of default
Config.TEXTURE_DEFAULT_FILTER = MOAITexture.GL_LINEAR
-- Config.TEXTURE_DEFAULT_FILTER = MOAITexture.GL_NEAREST

-- Setting of the behavior of the InputMgr
-- Whether to fire a touch event on the desktop environment
Config.TOUCH_EVENT_ENABLED = true

-- Whether to fire a mouse event on the desktop environment
Config.MOUSE_EVENT_ENABLED = true

--------------------------------------------------------------------------------
-- Logger
--------------------------------------------------------------------------------

-- info log
-- candy.Logger.LOG_LEVELS.INFO = true

-- warn log
-- candy.Logger.LOG_LEVELS.WARN = true

-- error log
-- candy.Logger.LOG_LEVELS.ERROR = true

-- debug log
-- candy.Logger.LOG_LEVELS.DEBUG = true

-- trace log
-- candy.Logger.LOG_LEVELS.TRACE = true

_G.CANDY_LOG_LEVEL = 'status'

_G.MOAI_LOG_LEVEL = 'status'

--------------------------------------------------------------------------------
-- Debugging
--------------------------------------------------------------------------------

-- Show bounds of MOAIProp
-- flower.DebugUtils.showDebugLines()

-- Start performance log
-- flower.DebugUtils.startPerformanceLog()

return Config