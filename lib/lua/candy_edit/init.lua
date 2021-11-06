--require 'candy.env'

--------------------------------------------------------------------
-- candysetLogLevel( 'status' )

module ( 'candy_edit', package.seeall )

--------------------------------------------------------------------
--CORE
--------------------------------------------------------------------
--require 'mock_edit.common.signals'
--require 'mock_edit.common.ModelHelper'
--require 'mock_edit.common.ClassManager'
require 'candy_edit.common.EditorCommand'
--require 'mock_edit.common.DeployTarget'
--require 'mock_edit.common.bridge'
require 'candy_edit.common.utils'


--------------------------------------------------------------------
--EDITOR UI HELPER
--------------------------------------------------------------------
--require 'mock_edit.UIHelper'


--------------------------------------------------------------------
--Editor related
--------------------------------------------------------------------
require 'candy_edit.EditorCanvas'


--------------------------------------------------------------------
--DEPLOY TARGETs
--------------------------------------------------------------------
--require 'mock_edit.deploy.DeployTargetIOS'


--------------------------------------------------------------------
--Editor Related Res
--------------------------------------------------------------------
--require 'mock_edit.common.resloader'


--------------------------------------------------------------------
--require 'mock_edit.AssetHelper'



--------------------------------------------------------------------
--COMMANDS
--------------------------------------------------------------------
--require 'mock_edit.commands'
require 'candy_edit.gizmos'
--require 'mock_edit.tools'

--require 'mock_edit.defaults'

--require 'mock_edit.drag'

--require 'mock_edit.sqscript'


--candy_allowAssetCacheWeakMode( false )
--candyTEXTURE_ASYNC_LOAD = false

--MOAISim.getInputMgr().configuration = 'CANDY'

return