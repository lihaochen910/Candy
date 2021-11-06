----------------------------------------------------------------------------------------------------
-- CandyEditor library is a lightweight library for Moai Editor.
----------------------------------------------------------------------------------------------------

-- module
local candy_editor = {}

----------------------------------------------------------------------------------------------------
-- Classes
-- @section Classes
----------------------------------------------------------------------------------------------------

---
-- PythonBridge.
-- @see candy_editor.PythonBridge
local pythonBridgeModule = require 'candy_editor.PythonBridge'
candy_editor.emitPythonSignal     = pythonBridgeModule.emitPythonSignal
candy_editor.emitPythonSignalNow  = pythonBridgeModule.emitPythonSignalNow
candy_editor.connectPythonSignal  = pythonBridgeModule.connectPythonSignal
candy_editor.registerPythonSignal = pythonBridgeModule.registerPythonSignal

candy_editor.sizeOfPythonObject   = pythonBridgeModule.sizeOfPythonObject
candy_editor.newPythonDict        = pythonBridgeModule.newPythonDict
candy_editor.newPythonList        = pythonBridgeModule.newPythonList
candy_editor.appendPythonList     = pythonBridgeModule.appendPythonList
candy_editor.deletePythonList     = pythonBridgeModule.deletePythonList
candy_editor.getDict              = pythonBridgeModule.getDict
candy_editor.setDict              = pythonBridgeModule.setDict

candy_editor.throwPythonException = pythonBridgeModule.throwPythonException
candy_editor.getTime              = pythonBridgeModule.getTime
candy_editor.generateGUID         = pythonBridgeModule.generateGUID
candy_editor.showAlertMessage	  = pythonBridgeModule.showAlertMessage
candy_editor.pyLogInfo   		  = pythonBridgeModule.pyLogInfo
candy_editor.pyLogWarn   		  = pythonBridgeModule.pyLogWarn
candy_editor.pyLogError			  = pythonBridgeModule.pyLogError

candy_editor.importPythonModule   = pythonBridgeModule.importModule

candy_editor.emitPythonSignal     = pythonBridgeModule.emitPythonSignal
candy_editor.emitPythonSignalNow  = pythonBridgeModule.emitPythonSignalNow
candy_editor.connectPythonSignal  = pythonBridgeModule.connectPythonSignal
candy_editor.registerPythonSignal = pythonBridgeModule.registerPythonSignal

candy_editor.sizeOfPythonObject   = pythonBridgeModule.sizeOfPythonObject
candy_editor.newPythonDict        = pythonBridgeModule.newPythonDict
candy_editor.newPythonList        = pythonBridgeModule.newPythonList
candy_editor.appendPythonList     = pythonBridgeModule.appendPythonList
candy_editor.deletePythonList     = pythonBridgeModule.deletePythonList
candy_editor.getDict              = pythonBridgeModule.getDict
candy_editor.setDict              = pythonBridgeModule.setDict

candy_editor.throwPythonException = pythonBridgeModule.throwPythonException
candy_editor.getTime              = pythonBridgeModule.getTime
candy_editor.generateGUID         = pythonBridgeModule.generateGUID
candy_editor.showAlertMessage     = pythonBridgeModule.showAlertMessage

candy_editor.importPythonModule   = pythonBridgeModule.importModule

candy_editor.tableToDict 		= pythonBridgeModule.tableToDict
candy_editor.tableToList		= pythonBridgeModule.tableToList
candy_editor.dictToTable		= pythonBridgeModule.dictToTable
candy_editor.dictToTablePlain	= pythonBridgeModule.dictToTablePlain
candy_editor.listToTable		= pythonBridgeModule.listToTable
candy_editor.unpackPythonList	= pythonBridgeModule.unpackPythonList

candy_editor.app = pythonBridgeModule.app

candy_editor.changeSelection 	= pythonBridgeModule.changeSelection
candy_editor.addSelection		= pythonBridgeModule.addSelection
candy_editor.removeSelection 	= pythonBridgeModule.removeSelection
candy_editor.toggleSelection 	= pythonBridgeModule.toggleSelection
candy_editor.toggleSelection 	= pythonBridgeModule.toggleSelection
candy_editor.getSelection 	    = pythonBridgeModule.getSelection

candy_editor.getProject     = pythonBridgeModule.getProject
candy_editor.getApp		    = pythonBridgeModule.getApp
candy_editor.getModule 	    = pythonBridgeModule.getModule
candy_editor.findDataFile   = pythonBridgeModule.findDataFile

candy_editor.loadLuaWithEnv 	= pythonBridgeModule.loadLuaWithEnv
candy_editor.loadLuaDelegate 	= pythonBridgeModule.loadLuaDelegate

candy_editor.renderTable      = pythonBridgeModule.renderTable
candy_editor.manualRenderAll  = pythonBridgeModule.manualRenderAll

candy_editor.registerLuaEditorCommand = pythonBridgeModule.registerLuaEditorCommand
candy_editor.doCommand 				  = pythonBridgeModule.doCommand
candy_editor.undoCommand 			  = pythonBridgeModule.undoCommand

candy_editor.registerModelProvider    = pythonBridgeModule.registerModelProvider
candy_editor.registerObjectEnumerator = pythonBridgeModule.registerObjectEnumerator

---
-- RenderContext.
-- @see candy_editor.RenderContext
local renderContextModule = require 'candy_editor.EditorRenderContext'
candy_editor.EditorRenderContext = renderContextModule.EditorRenderContext
candy_editor.createRenderContext = renderContextModule.createRenderContext
candy_editor.addContextChangeListeners = renderContextModule.addContextChangeListeners
candy_editor.removeContextChangeListener = renderContextModule.removeContextChangeListener
candy_editor.changeRenderContext = renderContextModule.changeRenderContext
candy_editor.getCurrentRenderContextKey = renderContextModule.getCurrentRenderContextKey
candy_editor.getCurrentRenderContext = renderContextModule.getCurrentRenderContext
candy_editor.getRenderContext = renderContextModule.getRenderContext
candy_editor.setCurrentRenderContextActionRoot = renderContextModule.setCurrentRenderContextActionRoot
candy_editor.setRenderContextActionRoot = renderContextModule.setRenderContextActionRoot
candy_editor.getKeyName = renderContextModule.getKeyName


return candy_editor