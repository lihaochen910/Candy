--------------------------------------------------------------------
--Setup package path
--------------------------------------------------------------------
package.path = package.path
	.. ( ';' .. CANDY_PROJECT_SCRIPT_LIB_PATH .. '/?.lua' )
	.. ( ';' .. CANDY_PROJECT_SCRIPT_LIB_PATH .. '/?/init.lua' )
	.. ( ';' .. CANDY_PROJECT_ENV_LUA_PATH .. '/?.lua' )
	.. ( ';' .. CANDY_PROJECT_ENV_LUA_PATH .. '/?/init.lua' )
	.. ( ';' .. CANDY_LIB_LUA_PATH .. '/?.lua' )
	.. ( ';' .. CANDY_LIB_LUA_PATH .. '/?/init.lua' )

_G.inspect = require ( "inspect" ).inspect

--print ( inspect ( python, { depth = 2 } ) )

--------------------------------------------------------------------
----Debug Library
--------------------------------------------------------------------
require ( "candy.mobdebug" ).start ( "localhost", 8172 )
_G.CANDY_LOG_LEVEL = 'status'
_G.MOAI_LOG_LEVEL = 'status'

--------------------------------------------------------------------
----Create Global
--------------------------------------------------------------------
rawset ( _G, '_C', {} )

_G.utf8 = require '3rdparty.utf8.utf8'

_G.candy = require 'candy'
--print ( "create _G.candy", candy )

_G.candy_editor = require 'candy_editor'
--print ( "create _G.candy_editor", candy_editor )

_G.candy_edit = require 'candy_edit'
--print ( "create _G.candy_edit", candy_edit )

candy.game = candy.Game ()
_G.game = candy.game