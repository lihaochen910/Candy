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



module( 'candy_editor', package.seeall )



