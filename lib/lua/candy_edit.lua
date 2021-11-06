----------------------------------------------------------------------------------------------------
-- CandyEdit library is a lightweight library for Moai Editor.
----------------------------------------------------------------------------------------------------

-- module
local candy_edit = {}

----------------------------------------------------------------------------------------------------
-- Classes
-- @section Classes
----------------------------------------------------------------------------------------------------

local candy = require 'candy'
candy.registerGlobalSignals {
    'asset.modified',
    'scene.entity_event'
}

--require 'mock_edit.common.signals'
--require 'mock_edit.common.ModelHelper'
--require 'mock_edit.common.ClassManager'

---
-- EditorCommand.
-- @see candy_edit.EditorCommand
local editorCommandModule = require 'candy_edit.common.EditorCommand'
candy_edit.EditorCommand 			= editorCommandModule.EditorCommand
candy_edit.EditorCommandNoHistory 	= editorCommandModule.EditorCommandNoHistory
candy_edit.EditorCommandNoUndo 		= editorCommandModule.EditorCommandNoUndo

--require 'mock_edit.common.DeployTarget'
--require 'mock_edit.common.bridge'
local utilsModule = require 'candy_edit.common.utils'
candy_edit.findTopLevelActors       	= utilsModule.findTopLevelActors
candy_edit.getTopLevelActorSelection 	= utilsModule.getTopLevelActorSelection
candy_edit.isEditorEntity             	= utilsModule.isEditorEntity
candy_edit.affirmGUID                 	= utilsModule.affirmGUID
candy_edit.affirmSceneGUID            	= utilsModule.affirmSceneGUID
candy_edit.affirmGUID			        = utilsModule.affirmGUID
candy_edit.isEditorEntity		        = utilsModule.isEditorEntity
candy_edit.getTopLevelActorSelection    = getTopLevelActorSelection

require 'candy_edit.common.AssetLibraryBridge'

candy_edit.SceneEventListener = require 'candy_edit.EditorCanvas.SceneEventListener'

candy_edit.CanvasView = require 'candy_edit.EditorCanvas.CanvasView'

local editorCanvasSceneModule = require 'candy_edit.EditorCanvas.EditorCanvasScene'
candy_edit.EditorCanvasCamera               = editorCanvasSceneModule.EditorCanvasCamera
candy_edit.EditorCanvasScene                = editorCanvasSceneModule.EditorCanvasScene
candy_edit.createEditorCanvasInputDevice    = editorCanvasSceneModule.createEditorCanvasInputDevice
candy_edit.createEditorCanvasScene          = editorCanvasSceneModule.createEditorCanvasScene

candy_edit.CanvasGrid = require 'candy_edit.EditorCanvas.CanvasGrid'
candy_edit.CanvasNavigate = require 'candy_edit.EditorCanvas.CanvasNavigate'

local canvasHandleModule = require 'candy_edit.EditorCanvas.CanvasHandle'
candy_edit.CanvasHandleLayer    = canvasHandleModule.CanvasHandleLayer
candy_edit.CanvasHandle         = canvasHandleModule.CanvasHandle

local gizmoModule = require 'candy_edit.EditorCanvas.GizmoManager'
candy_edit.Gizmo        = gizmoModule.Gizmo
candy_edit.GizmoManager = gizmoModule.GizmoManager

candy_edit.PickingManager = require 'candy_edit.EditorCanvas.PickingManager'

local canvasItemModule = require 'candy_edit.EditorCanvas.CanvasItem'
candy_edit.CanvasItemManager 	= canvasItemModule.CanvasItemManager
candy_edit.CanvasItem 			= canvasItemModule.CanvasItem

local canvasToolModule = require 'candy_edit.EditorCanvas.CanvasTool'
candy_edit.CanvasToolManager 	= canvasToolModule.CanvasToolManager
candy_edit.CanvasTool 			= canvasToolModule.CanvasTool
candy_edit.registerCanvasTool 	= canvasToolModule.registerCanvasTool

local sceneViewModule = require 'candy_edit.EditorCanvas.SceneView'
candy_edit.SceneViewDrag 		    = sceneViewModule.SceneViewDrag
candy_edit.SceneViewDragFactory     = sceneViewModule.SceneViewDragFactory
candy_edit.SceneView 			    = sceneViewModule.SceneView
candy_edit.SceneViewFactory 	    = sceneViewModule.SceneViewFactory
candy_edit.registerSceneViewFactory = sceneViewModule.registerSceneViewFactory
candy_edit.createSceneView 	        = sceneViewModule.createSceneView
candy_edit.CmdFocusSelection 	    = sceneViewModule.CmdFocusSelection

candy_edit.BoundGizmo = require 'candy_edit.gizmos.BoundGizmo'
candy_edit.IconGizmo = require 'candy_edit.gizmos.IconGizmo'
candy_edit.DrawScriptGizmo = require 'candy_edit.gizmos.DrawScriptGizmo'
--require 'mock_edit.gizmos.PhysicsShapeGizmo'
--require 'mock_edit.gizmos.WaypointGraphGizmo'
--require 'mock_edit.gizmos.PathGizmo'


return candy_edit