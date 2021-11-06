----------------------------------------------------------------------------------------------------
-- Candy library is a lightweight library for Moai SDK.
----------------------------------------------------------------------------------------------------

-- module
local candy = {}

----------------------------------------------------------------------------------------------------
-- Fields
----------------------------------------------------------------------------------------------------

--- Default game instance.
candy.game = false

--- Set UI Library type
candy.UI_LIBRARY = 'flower' -- flower or light

----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------
candy.init = function ( path, fromEditor, extra )
	candy.game:loadConfig ( path, fromEditor, extra )
end

candy.printAllActors = function ()
	_log('candy.printAllActors()', 'start!')

	affirmSceneGUID(candy.game:getMainSceneSession():getScene())

	for a in pairs(candy.game:getMainSceneSession():getScene().entities) do
		print(a:getName(), a:getClassName(), a.__guid, a.FLAG_EDITOR_OBJECT)
		for c in pairs(a.components) do
			print(c:getClassName(), c.__guid, c.FLAG_INTERNAL)
		end
	end
end

-- setmetatable ( package.loaded, {
-- 	__newindex = function ( t, k, v )
-- 		print ( "Writing to package.loaded", k, v )
-- 		print ( debug.traceback ( 2 ) )
-- 		rawset ( t, k, v )
-- 	end
-- } )

----------------------------------------------------------------------------------------------------
-- Classes
-- @section Classes
----------------------------------------------------------------------------------------------------
require 'candy.utils'

---
-- Config class.
-- @see candy.Config
candy.Config = require "candy.Config"

---
-- Signal.
-- @see candy.signal
local signalModule = require 'candy.signal'
candy.newSignal             		= signalModule.newSignal
candy.isSignal              		= signalModule.isSignal
candy.signalConnect         		= signalModule.signalConnect
candy.signalConnectMethod   		= signalModule.signalConnectMethod
candy.signalConnectFunc     		= signalModule.signalConnectFunc
candy.signalEmit            		= signalModule.signalEmit
candy.signalDisconnect      		= signalModule.signalDisconnect
candy.registerSignal        		= signalModule.registerGlobalSignal
candy.registerGlobalSignal  		= signalModule.registerGlobalSignal
candy.registerSignals       		= signalModule.registerGlobalSignals
candy.registerGlobalSignals 		= signalModule.registerGlobalSignals
candy.getSignal             		= signalModule.getGlobalSignal
candy.connectSignalFunc     		= signalModule.connectGlobalSignalFunc
candy.connectSignalMethod   		= signalModule.connectGlobalSignalMethod
candy.disconnectSignal      		= signalModule.disconnectGlobalSignal
candy.emitSignal            		= signalModule.emitGlobalSignal
candy.getGlobalSignal             	= signalModule.getGlobalSignal
candy.getGlobalSignalSeq          	= signalModule.getGlobalSignalSeq
candy.connectGlobalSignalFunc     	= signalModule.connectGlobalSignalFunc
candy.connectGlobalSignalMethod   	= signalModule.connectGlobalSignalMethod
candy.disconnectGlobalSignal      	= signalModule.disconnectGlobalSignal
candy.emitGlobalSignal            	= signalModule.emitGlobalSignal

---
-- class.
-- @see candy.class
local classModule = require 'candy.Class'
candy.CLASS 				= classModule.CLASS
candy._rawClass 			= classModule._rawClass
candy.Field 				= classModule.Field
candy.FieldGroup 			= classModule.FieldGroup
candy.Model 				= classModule.Model
candy.MoaiModel 			= classModule.MoaiModel
candy.newClass 				= classModule.newClass
candy.updateAllSubClasses 	= classModule.updateAllSubClasses
candy.isClass 				= classModule.isClass
candy.isSubclass 			= classModule.isSubclass
candy.isSubclassInstance 	= classModule.isSubclassInstance
candy.isClassInstance 		= classModule.isClassInstance
candy.isInstance 			= classModule.isInstance
candy.affirmInstance 		= classModule.affirmInstance
candy.getClass 				= classModule.getClass

_G.CLASS 		= classModule.CLASS
_G.Field 		= classModule.Field
_G.FieldGroup 	= classModule.FieldGroup
_G.Model 		= classModule.Model
_G._ENUM 		= classModule._ENUM
_G._ENUM_I 		= classModule._ENUM_I
_G._ENUM_V 		= classModule._ENUM_V
_G._ENUM_NAME 	= classModule._ENUM_NAME
_G.findClass	= classModule.findClass

local classHelperModule = require 'candy.ClassHelpers'
candy.wrapMethod 				= classHelperModule.wrapMethod
candy.wrapMethods 				= classHelperModule.wrapMethods
candy.wrapAttrGetter 			= classHelperModule.wrapAttrGetter
candy.wrapAttrGetterBoolean 	= classHelperModule.wrapAttrGetterBoolean
candy.wrapAttrSetter 			= classHelperModule.wrapAttrSetter
candy.wrapAttrSeeker 			= classHelperModule.wrapAttrSeeker
candy.wrapAttrMover 			= classHelperModule.wrapAttrMover
candy.wrapAttrGetSet 			= classHelperModule.wrapAttrGetSet
candy.wrapAttrGetSet2 			= classHelperModule.wrapAttrGetSet2
candy.wrapAttrGetSetSeekMove 	= classHelperModule.wrapAttrGetSetSeekMove

candy.ObjectPooling = require 'candy.ObjectPooling'

---
-- Serializer.
-- @see candy.Serializer
local serializerModule = require 'candy.Serializer'
candy.SerializeObjectMap 			= serializerModule.SerializeObjectMap
candy.serialize   					= serializerModule.serialize
candy.deserialize 					= serializerModule.deserialize
candy.clone       					= serializerModule._cloneObject
candy.serializeToString  			= serializerModule.serializeToString
candy.serializeToFile  				= serializerModule.serializeToFile
candy.deserializeFromString 		= serializerModule.deserializeFromString
candy.deserializeFromFile 			= serializerModule.deserializeFromFile
candy.checkSerializationFile 		= serializerModule.checkSerializationFile
candy.createEmptySerialization 		= serializerModule.createEmptySerialization
candy._serializeObject             	= serializerModule._serializeObject
candy._cloneObject                 	= serializerModule._cloneObject
candy._deserializeObject           	= serializerModule._deserializeObject
candy._prepareObjectMap            	= serializerModule._prepareObjectMap
candy._deserializeObjectMapData 	= serializerModule._deserializeObjectMapData
candy._deserializeObjectMap        	= serializerModule._deserializeObjectMap
candy._deserializeField     		= serializerModule._deserializeField
candy._serializeField       		= serializerModule._serializeField
candy.isTupleValue          		= serializerModule.isTupleValue
candy.isAtomicValue         		= serializerModule.isAtomicValue
candy.makeNameSpacedId      		= serializerModule.makeId
candy.makeNameSpace         		= serializerModule.makeNamespace
candy.clearNamespaceCache   		= serializerModule.clearNamespaceCache

local jsonHelperModule = require 'candy.helper.JSONHelper'
candy.encodeJSON 		= jsonHelperModule.encodeJSON
candy.decodeJSON 		= jsonHelperModule.decodeJSON
candy.loadJSONText 		= jsonHelperModule.loadJSONText
candy.loadJSONFile 		= jsonHelperModule.loadJSONFile
candy.tryLoadJSONFile 	= jsonHelperModule.tryLoadJSONFile
candy.saveJSONFile 		= jsonHelperModule.saveJSONFile

---
-- MOAIHelpers.
-- @see candy.helper.MOAIHelpers
local moaiHelpersModule = require 'candy.helper.MOAIHelpers'
candy.checkOS 						= moaiHelpersModule.checkOS
candy.checkLanguage 				= moaiHelpersModule.checkLanguage
candy.getDeviceScreenSpec 			= moaiHelpersModule.getDeviceScreenSpec
candy.getResolutionByDevice 		= moaiHelpersModule.getResolutionByDevice
candy.getDeviceResolution 			= moaiHelpersModule.getDeviceResolution
candy.extractMoaiInstanceMethods 	= moaiHelpersModule.extractMoaiInstanceMethods
candy.injectMoaiClass 				= moaiHelpersModule.injectMoaiClass
candy.openURLInBrowser 				= moaiHelpersModule.openURLInBrowser
candy.openRateURL 					= moaiHelpersModule.openRateURL
candy.grabNextFrame 				= moaiHelpersModule.grabNextFrame
candy.grabCurrentFrameToFile 		= moaiHelpersModule.grabCurrentFrameToFile
candy.saveMOAIGridTiles 			= moaiHelpersModule.saveMOAIGridTiles
candy.loadMOAIGridTiles 			= moaiHelpersModule.loadMOAIGridTiles
candy.saveImageBase64 				= moaiHelpersModule.saveImageBase64
candy.loadImageBase64 				= moaiHelpersModule.loadImageBase64
candy.resizeMOAIGrid 				= moaiHelpersModule.resizeMOAIGrid
candy.subdivideMOAIGrid 			= moaiHelpersModule.subdivideMOAIGrid

local moaiPropHelpersModule = require 'candy.helper.MOAIPropHelpers'
candy.extractColor 					= moaiPropHelpersModule.extractColor
candy.inheritLoc 					= moaiPropHelpersModule.inheritLoc
candy.linkRot 						= moaiPropHelpersModule.linkRot
candy.linkScl 						= moaiPropHelpersModule.linkScl
candy.linkLoc 						= moaiPropHelpersModule.linkLoc
candy.linkWorldLoc 					= moaiPropHelpersModule.linkWorldLoc
candy.linkWorldScl 					= moaiPropHelpersModule.linkWorldScl
candy.linkPiv 						= moaiPropHelpersModule.linkPiv
candy.linkTransform 				= moaiPropHelpersModule.linkTransform
candy.linkPartition 				= moaiPropHelpersModule.linkPartition
candy.linkIndex 					= moaiPropHelpersModule.linkIndex
candy.linkBlendMode 				= moaiPropHelpersModule.linkBlendMode
candy.clearLinkPartition 			= moaiPropHelpersModule.clearLinkPartition
candy.clearLinkIndex 				= moaiPropHelpersModule.clearLinkIndex
candy.clearLinkBlendMode 			= moaiPropHelpersModule.clearLinkBlendMode
candy.inheritTransform 				= moaiPropHelpersModule.inheritTransform
candy.inheritColor 					= moaiPropHelpersModule.inheritColor
candy.linkColor 					= moaiPropHelpersModule.linkColor
candy.linkColorTrait 				= moaiPropHelpersModule.linkColorTrait
candy.inheritVisible 				= moaiPropHelpersModule.inheritVisible
candy.linkVisible 					= moaiPropHelpersModule.linkVisible
candy.linkLocalVisible 				= moaiPropHelpersModule.linkLocalVisible
candy.clearInheritVisible 			= moaiPropHelpersModule.clearInheritVisible
candy.inheritTransformColor 		= moaiPropHelpersModule.inheritTransformColor
candy.inheritTransformColorVisible 	= moaiPropHelpersModule.inheritTransformColorVisible
candy.inheritPartition 				= moaiPropHelpersModule.inheritPartition
candy.linkShader 					= moaiPropHelpersModule.linkShader
candy.clearLinkRot 					= moaiPropHelpersModule.clearLinkRot
candy.clearLinkScl 					= moaiPropHelpersModule.clearLinkScl
candy.clearLinkLoc 					= moaiPropHelpersModule.clearLinkLoc
candy.clearLinkPiv 					= moaiPropHelpersModule.clearLinkPiv
candy.clearLinkColor 				= moaiPropHelpersModule.clearLinkColor
candy.clearInheritColor 			= moaiPropHelpersModule.clearInheritColor
candy.clearLinkTransform 			= moaiPropHelpersModule.clearLinkTransform
candy.clearInheritTransform 		= moaiPropHelpersModule.clearInheritTransform
candy.clearLinkShader 				= moaiPropHelpersModule.clearLinkShader
candy.alignPropPivot 				= moaiPropHelpersModule.alignPropPivot
candy.setupMoaiTransform 			= moaiPropHelpersModule.setupMoaiTransform
candy.syncWorldLoc 					= moaiPropHelpersModule.syncWorldLoc
candy.syncWorldRot 					= moaiPropHelpersModule.syncWorldRot
candy.syncWorldScl 					= moaiPropHelpersModule.syncWorldScl
candy.syncWorldTransform 			= moaiPropHelpersModule.syncWorldTransform
candy.setPropBlend 					= moaiPropHelpersModule.setPropBlend
candy.setupMoaiProp 				= moaiPropHelpersModule.setupMoaiProp
candy.wrapWithMoaiTransformMethods 	= moaiPropHelpersModule.wrapWithMoaiTransformMethods
candy.wrapWithMoaiPropMethods 		= moaiPropHelpersModule.wrapWithMoaiPropMethods


local profilerHelperModule = require 'candy.helper.ProfilerHelper'
candy.startProfiler = profilerHelperModule.startProfiler
candy.stopProfiler 	= profilerHelperModule.stopProfiler
candy.runProfiler 	= profilerHelperModule.runProfiler

local guidHelperModule = require 'candy.helper.GUIDHelper'
candy.affirmGUID      = guidHelperModule.affirmGUID
candy.affirmSceneGUID = guidHelperModule.affirmSceneGUID
candy.reallocGUID     = guidHelperModule.reallocGUID

---
-- LogHelper.
-- @see candy.LogHelper
local logHelperModule = require 'candy.LogHelper'

local debugHelperModule = require 'candy.DebugHelper'

---
-- Envirmoment.
-- @see candy.env
local envModule = require 'candy.env'
candy.getProjectPath 	= envModule.getProjectPath
candy.getGameConfigPath = envModule.getGameConfigPath
candy.setupEnvironment 	= envModule.setupEnvironment
candy.loadGameConfig 	= envModule.loadGameConfig
candy.saveGameConfig 	= envModule.saveGameConfig

candy.Actor = require 'candy.Actor'

---
-- GlobalManager.
-- @see candy.GlobalManager
local globalManagerModule = require 'candy.GlobalManager'
candy.GlobalManager 			= globalManagerModule.GlobalManager
candy.getGlobalManagerRegistry 	= globalManagerModule.getGlobalManagerRegistry

---
-- Task.
-- @see candy.task.Task
local taskModule = require 'candy.task.Task'
candy.TaskManager 		= taskModule.TaskManager
candy.TaskGroup 		= taskModule.TaskGroup
candy.TaskQueue 		= taskModule.TaskQueue
candy.Task 				= taskModule.Task
candy.getTaskManager 	= taskModule.getTaskManager
candy.isTaskGroupBusy 	= taskModule.isTaskGroupBusy
candy.getTaskGroup 		= taskModule.getTaskGroup
candy.getTaskProgress 	= taskModule.getTaskProgress

local asyncDataTaskModule = require 'candy.task.AsyncDataTask'
candy.AsyncDataLoadTask = asyncDataTaskModule.AsyncDataLoadTask
candy.AsyncDataSaveTask = asyncDataTaskModule.AsyncDataSaveTask

candy.AsyncImageLoadTask = require 'candy.task.AsyncImageLoadTask'

local asyncTextureLoadTaskModule = require 'candy.task.AsyncTextureLoadTask'
candy.AsyncTextureLoadTask 			= asyncTextureLoadTaskModule.AsyncTextureLoadTask
candy.isTextureLoadTaskBusy 		= asyncTextureLoadTaskModule.isTextureLoadTaskBusy
candy.setTextureThreadTaskGroupSize = asyncTextureLoadTaskModule.setTextureThreadTaskGroupSize

_G.getActiveLocale = function ()
	return 'en'
end

local namedColorsModule = require 'candy.tools.NamedColors'
candy.getNamedColor 	= namedColorsModule.getNamedColor
candy.getNamedColorHex 	= namedColorsModule.getNamedColorHex

---
-- AssetLibrary.
-- @see candy.AssetLibrary
local assetLibraryModule = require 'candy.AssetLibrary'
candy.AssetNode 			= assetLibraryModule.AssetNode
candy.isAssetLoading 		= assetLibraryModule.isAssetLoading
candy.hasAsset 				= assetLibraryModule.hasAsset
candy.canPreload 			= assetLibraryModule.canPreload
candy.AdHocAsset 			= assetLibraryModule.AdHocAsset
candy.isAdHocAsset 			= assetLibraryModule.isAdHocAsset
candy.loadAsset 			= assetLibraryModule.loadAsset
candy.tryLoadAsset 			= assetLibraryModule.tryLoadAsset
candy.forceLoadAsset 		= assetLibraryModule.forceLoadAsset
candy.getCachedAsset 		= assetLibraryModule.getCachedAsset
candy.releaseAsset 			= assetLibraryModule.releaseAsset
candy.updateAssetNode 		= assetLibraryModule.updateAssetNode
candy.registerAssetNode 	= assetLibraryModule.registerAssetNode
candy.unregisterAssetNode 	= assetLibraryModule.unregisterAssetNode
candy.getAssetNode 			= assetLibraryModule.getAssetNode
candy.checkAsset 			= assetLibraryModule.checkAsset
candy.matchAssetType 		= assetLibraryModule.matchAssetType
candy.getAssetType 			= assetLibraryModule.getAssetType

local resourceHolderModule = require 'candy.ResourceHolder'
candy.setDefaultResourceHolder 		= resourceHolderModule.setDefaultResourceHolder
candy.pushResourceHolder 			= resourceHolderModule.pushResourceHolder
candy.popResourceHolder 			= resourceHolderModule.popResourceHolder
candy.getGlobalResourceHolder 		= resourceHolderModule.getGlobalResourceHolder
candy.releaseGlobalResourceHolder 	= resourceHolderModule.releaseGlobalResourceHolder
candy.ResourceHolder 				= resourceHolderModule.ResourceHolder
candy.loadAndHoldAsset 				= resourceHolderModule.loadAndHoldAsset
candy.loadAsset 					= resourceHolderModule.loadAsset
candy.loadStaticAsset 				= resourceHolderModule.loadStaticAsset

candy.Resources = require "candy.asset.Resources"
candy.DeckMgr = require "candy.asset.DeckMgr"

local basicAssetModule = require 'candy.asset.BasicAsset'
candy.loadAssetDataTable = basicAssetModule.loadAssetDataTable
candy.loadTextData 		 = basicAssetModule.loadTextData
candy.saveTextData 		 = basicAssetModule.saveTextData

candy.DataAsset = require 'candy.asset.DataAsset'

local dataSheetAssetModule = require 'candy.asset.DataSheetAsset'
candy.DataSheetAccessor 		= dataSheetAssetModule.DataSheetAccessor
candy.DataSheetDictAccessor 	= dataSheetAssetModule.DataSheetDictAccessor
candy.DataSheetListAccessor 	= dataSheetAssetModule.DataSheetListAccessor
candy.DataSheetListRowAccessor 	= dataSheetAssetModule.DataSheetListRowAccessor

local sceneAssetModule = require 'candy.asset.SceneAsset'
candy.SceneSerializer 			= sceneAssetModule.SceneSerializer
candy.SceneDeserializer 		= sceneAssetModule.SceneDeserializer
candy.serializeScene 			= sceneAssetModule.serializeScene
candy.deserializeScene 			= sceneAssetModule.deserializeScene
candy.serializeSceneToFile 		= sceneAssetModule.serializeSceneToFile
candy.makeActorCopyData 		= sceneAssetModule.makeActorCopyData
candy.makeActorPasteData 		= sceneAssetModule.makeActorPasteData
candy.makeActorCloneData 		= sceneAssetModule.makeActorCloneData
candy.copyAndPasteActor 		= sceneAssetModule.copyAndPasteActor
candy.makeActorGroupPasteData 	= sceneAssetModule.makeActorGroupPasteData
candy.makeComponentCopyData 	= sceneAssetModule.makeComponentCopyData
candy.makeComponentPasteData 	= sceneAssetModule.makeComponentPasteData
candy.serializeActor 			= sceneAssetModule.serializeActor
candy.deserializeActor 			= sceneAssetModule.deserializeActor
candy.setSceneGroupFilter 		= sceneAssetModule.setSceneGroupFilter
candy.matchSceneGroupFilter 	= sceneAssetModule.matchSceneGroupFilter
candy.loadSceneDataFromPath 	= sceneAssetModule.loadSceneDataFromPath

local sceneAssetWalkerModule = require 'candy.asset.SceneAssetWalker'
candy.collectAssetFromObject = sceneAssetWalkerModule.collectAssetFromObject
candy.collectAssetFromEntity = sceneAssetWalkerModule.collectAssetFromEntity
candy.collectAssetFromGroup = sceneAssetWalkerModule.collectAssetFromGroup
candy.collectAssetFromScene = sceneAssetWalkerModule.collectAssetFromScene
candy.collectGroupAssetDependency = sceneAssetWalkerModule.collectGroupAssetDependency

candy.PrefabAsset = require 'candy.asset.PrefabAsset'

local protoAssetModule = require 'candy.asset.ProtoAsset'
candy.findProtoInstances 				= protoAssetModule.findProtoInstances
candy.hasProtoHistory 					= protoAssetModule.hasProtoHistory
candy.getProtoHistory 					= protoAssetModule.getProtoHistory
candy.getFirstProto 					= protoAssetModule.getFirstProto
candy.getLastProto 						= protoAssetModule.getLastProto
candy.findTopEntityProtoInstance 		= protoAssetModule.findTopEntityProtoInstance
candy.findEntityProtoInstance 			= protoAssetModule.findEntityProtoInstance
candy.findProtoInstance 				= protoAssetModule.findProtoInstance
candy.findTopProtoInstance 				= protoAssetModule.findTopProtoInstance
candy.markProtoInstanceOverrided 		= protoAssetModule.markProtoInstanceOverrided
candy.markProtoInstanceFieldsOverrided 	= protoAssetModule.markProtoInstanceFieldsOverrided
candy.isProtoInstanceOverrided 			= protoAssetModule.isProtoInstanceOverrided
candy.resetProtoInstanceOverridedField 	= protoAssetModule.resetProtoInstanceOverridedField
candy.clearProtoInstanceOverrideState 	= protoAssetModule.clearProtoInstanceOverrideState
candy.Proto 							= protoAssetModule.Proto
candy.ProtoManager 						= protoAssetModule.ProtoManager

local textureBaseModule = require 'candy.asset.TextureBase'
candy.getSupportedTextureAssetTypes = textureBaseModule.getSupportedTextureAssetTypes
candy.addSupportedTextureAssetType 	= textureBaseModule.addSupportedTextureAssetType
candy.TextureInstanceBase 			= textureBaseModule.TextureInstanceBase

local textureModule = require 'candy.asset.Texture'
candy.makeSolidTexture 				= textureModule.makeSolidTexture
candy.getTexturePlaceHolderImage 	= textureModule.getTexturePlaceHolderImage
candy.getWhiteTexture 				= textureModule.getWhiteTexture
candy.getEmptyTexture 				= textureModule.getEmptyTexture
candy.getBlackTexture 				= textureModule.getBlackTexture
candy.getTextureLibrary 			= textureModule.getTextureLibrary
candy.preloadTextureGroup 			= textureModule.preloadTextureGroup
candy.initTextureLibrary 			= textureModule.initTextureLibrary
candy.loadTextureLibrary 			= textureModule.loadTextureLibrary
candy.TextureLibrary 				= textureModule.TextureLibrary
candy.TextureGroup 					= textureModule.TextureGroup
candy.TextureInstance 				= textureModule.TextureInstance
candy.Texture 						= textureModule.Texture
candy.reportLoadedMoaiTextures 		= textureModule.reportLoadedMoaiTextures
candy.getLoadedMoaiTextures 		= textureModule.getLoadedMoaiTextures

local multiTextureModule = require 'candy.asset.MultiTexture'
candy.MultiTextureInstance 		= multiTextureModule.MultiTextureInstance
candy.createMultiTexture 		= multiTextureModule.createMultiTexture
candy.MultiTextureConfigLoader 	= multiTextureModule.MultiTextureConfigLoader

candy.RenderTargetTexture = require 'candy.asset.RenderTargetTexture'

local deck2DModule = require 'candy.asset.Deck2D'
candy.getLoadedDecks 		= deck2DModule.getLoadedDecks
candy.Deck2D 				= deck2DModule.Deck2D
candy.Quad2D 				= deck2DModule.Quad2D
candy.Tileset 				= deck2DModule.Tileset
candy.TileMapTerrainBrush 	= deck2DModule.TileMapTerrainBrush
candy.QuadArray 			= deck2DModule.QuadArray
candy.SubQuad 				= deck2DModule.SubQuad
candy.StretchPatch 			= deck2DModule.StretchPatch
candy.PolygonDeck 			= deck2DModule.PolygonDeck
candy.CylinderDeck 			= deck2DModule.CylinderDeck
candy.Deck2DPack 			= deck2DModule.Deck2DPack
candy.Deck2DPackLoader 		= deck2DModule.Deck2DPackLoader
candy.Deck2DPackUnloader 	= deck2DModule.Deck2DPackUnloader

candy.Font = require 'candy.asset.Font'

local textStyleModule = require 'candy.asset.TextStyle'
candy.TextStyle = textStyleModule.TextStyle
candy.StyleSheet = textStyleModule.StyleSheet

local shaderConfigModule = require 'candy.asset.ShaderConfig'
candy.ShaderConfig 	= shaderConfigModule.ShaderConfig
candy.ShaderBuilder = shaderConfigModule.ShaderBuilder

local shaderModule = require 'candy.asset.Shader'
candy.buildShaderProgramFromString 	= shaderModule.buildShaderProgramFromString
candy.ShaderProgram 				= shaderModule.ShaderProgram
candy.Shader 						= shaderModule.Shader
candy.getLoadedShaderPrograms 		= shaderModule.getLoadedShaderPrograms
candy.reportShader 					= shaderModule.reportShader
candy.MultiShader 					= shaderModule.MultiShader

local shaderScriptModule = require 'candy.asset.ShaderScript'
candy._loadShaderScript 	= shaderScriptModule._loadShaderScript
candy.ShaderScriptConfig 	= shaderScriptModule.ShaderScriptConfig
candy.buildMasterShader 	= shaderScriptModule.buildMasterShader
candy.buildShader 			= shaderScriptModule.buildShader

candy.Viewport = require 'candy.Viewport'

local renderTargetModule = require 'candy.RenderTarget'
candy.RenderTarget 			= renderTargetModule.RenderTarget
candy.DeviceRenderTarget 	= renderTargetModule.DeviceRenderTarget
candy.TextureRenderTarget 	= renderTargetModule.TextureRenderTarget


local debugDrawModule = require 'candy.DebugDrawQueue'
candy.DebugDrawCommand 			= debugDrawModule.DebugDrawCommand
candy.DebugDrawQueue 			= debugDrawModule.DebugDrawQueue
candy.DebugDrawQueueGroup 		= debugDrawModule.DebugDrawQueueGroup
candy.DebugDrawQueueDummyGroup 	= debugDrawModule.DebugDrawQueueDummyGroup
candy.DebugDrawCommandCircle 	= debugDrawModule.DebugDrawCommandCircle
candy.DebugDrawCommandRect 		= debugDrawModule.DebugDrawCommandRect
candy.DebugDrawCommandLine 		= debugDrawModule.DebugDrawCommandLine
candy.DebugDrawCommandArrow 	= debugDrawModule.DebugDrawCommandArrow
candy.DebugDrawCommandRay 		= debugDrawModule.DebugDrawCommandRay
candy.DebugDrawCommandScript 	= debugDrawModule.DebugDrawCommandScript
candy.setCurrentDebugDrawQueue 	= debugDrawModule.setCurrentDebugDrawQueue
candy._DebugDraw 				= debugDrawModule._DebugDraw

--------------------------------------------------------------------
-- Animator
EnumAnimCurveTweenMode = {
	{ "constant", MOAIAnimCurve.SPAN_MODE_CONSTANT },
	{ "linear", MOAIAnimCurve.SPAN_MODE_LINEAR },
	{ "bezier", MOAIAnimCurve.SPAN_MODE_BEZIER }
}

local animatorTargetIdModule = require "candy.animator.AnimatorTargetId"
candy.AnimatorTargetId 			= animatorTargetIdModule.AnimatorTargetId
candy.AnimatorTargetPath 		= animatorTargetIdModule.AnimatorTargetPath
candy.AnimatorComponentId 		= animatorTargetIdModule.AnimatorComponentId
candy.AnimatorChildEntityId 	= animatorTargetIdModule.AnimatorChildEntityId
candy.AnimatorThisEntityId 		= animatorTargetIdModule.AnimatorThisEntityId
candy.AnimatorGlobalEntityId 	= animatorTargetIdModule.AnimatorGlobalEntityId

candy.AnimatorState = require "candy.animator.AnimatorState"

local animatorClipModule = require "candy.animator.AnimatorClip"
candy.AnimatorClipSubNode 		= animatorClipModule.AnimatorClipSubNode
candy.AnimatorClipSubNodeSpan 	= animatorClipModule.AnimatorClipSubNode
candy.AnimatorKey 				= animatorClipModule.AnimatorKey
candy.AnimatorTrack 			= animatorClipModule.AnimatorTrack
candy.AnimatorTrackGroup 		= animatorClipModule.AnimatorTrackGroup
candy.AnimatorClipMarker 		= animatorClipModule.AnimatorClipMarker
candy.AnimatorClip 				= animatorClipModule.AnimatorClip
candy.AnimatorClipGroup 		= animatorClipModule.AnimatorClipGroup

local animatorClipTreeModule = require "candy.animator.AnimatorClipTree"
candy.AnimatorClipTreeState 	= animatorClipTreeModule.AnimatorClipTreeState
candy.AnimatorClipTreeNode 		= animatorClipTreeModule.AnimatorClipTreeNode
candy.AnimatorClipTreeNodeRoot 	= animatorClipTreeModule.AnimatorClipTreeNodeRoot
candy.AnimatorClipTreeTrack 	= animatorClipTreeModule.AnimatorClipTreeTrack
candy.AnimatorClipTree 			= animatorClipTreeModule.AnimatorClipTree

candy.AnimatorData = require "candy.animator.AnimatorData"
candy.Animator = require "candy.animator.Animator"

local embedAnimatorModule = require "candy.animator.EmbedAnimator"
candy.ExportAnimatorParam 	= embedAnimatorModule.ExportAnimatorParam
candy.EmbedAnimator 		= embedAnimatorModule.EmbedAnimator

candy.AnimatorEditorSupport = require "candy.animator.AnimatorEditorSupport"

local animatorEventTrackModule = require "candy.animator.AnimatorEventTrack"
candy.AnimatorEventTrack 	= animatorEventTrackModule.AnimatorEventTrack
candy.AnimatorEventKey 		= animatorEventTrackModule.AnimatorEventKey

local animatorValueTrackModule = require "candy.animator.AnimatorValueTrack"
candy.AnimatorValueTrack 	= animatorValueTrackModule.AnimatorValueTrack
candy.AnimatorValueKey 		= animatorValueTrackModule.AnimatorValueKey
candy.AnimatorKeyNumber 	= animatorValueTrackModule.AnimatorKeyNumber
candy.AnimatorKeyInt 		= animatorValueTrackModule.AnimatorKeyInt
candy.AnimatorKeyBoolean 	= animatorValueTrackModule.AnimatorKeyBoolean
candy.AnimatorKeyString 	= animatorValueTrackModule.AnimatorKeyString

candy.CustomAnimatorTrack = require "candy.animator.CustomAnimatorTrack"

local animatorKeyVecModule = require "candy.animator.AnimatorKeyVec"
candy.AnimatorKeyVec2 = animatorKeyVecModule.AnimatorKeyVec2
candy.AnimatorKeyVec3 = animatorKeyVecModule.AnimatorKeyVec3

candy.AnimatorKeyColor = require "candy.animator.AnimatorKeyColor"
candy.AnimatorTrackAttr = require "candy.animator.AnimatorTrackAttr"
candy.AnimatorTrackField = require "candy.animator.AnimatorTrackField"
candy.AnimatorTrackFieldNumber = require "candy.animator.AnimatorTrackFieldNumber"
candy.AnimatorTrackFieldInt = require "candy.animator.AnimatorTrackFieldInt"

local animatorTrackFieldVecModule = require "candy.animator.AnimatorTrackFieldVec"
candy.AnimatorTrackVecComponent 	= animatorTrackFieldVecModule.AnimatorTrackVecComponent
candy.AnimatorTrackFieldVecCommon 	= animatorTrackFieldVecModule.AnimatorTrackFieldVecCommon
candy.AnimatorTrackFieldVec3 		= animatorTrackFieldVecModule.AnimatorTrackFieldVec3
candy.AnimatorTrackFieldVec2 		= animatorTrackFieldVecModule.AnimatorTrackFieldVec2

local animatorTrackFieldColorModule = require "candy.animator.AnimatorTrackFieldColor"
candy.AnimatorTrackColorComponent 	= animatorTrackFieldColorModule.AnimatorTrackColorComponent
candy.AnimatorTrackFieldColor 		= animatorTrackFieldColorModule.AnimatorTrackFieldColor

candy.AnimatorTrackFieldDiscrete = require "candy.animator.AnimatorTrackFieldDiscrete"
candy.AnimatorTrackFieldBoolean = require "candy.animator.AnimatorTrackFieldBoolean"
candy.AnimatorTrackFieldString = require "candy.animator.AnimatorTrackFieldString"

local animatorKeyVecModule = require "candy.animator.AnimatorTrackFieldEnum"
candy.AnimatorKeyFieldEnum 		= animatorKeyVecModule.AnimatorKeyFieldEnum
candy.AnimatorTrackFieldEnum 	= animatorKeyVecModule.AnimatorTrackFieldEnum

local animatorTrackFieldAssetModule = require "candy.animator.AnimatorTrackFieldAsset"
candy.AnimatorKeyFieldAsset 	= animatorTrackFieldAssetModule.AnimatorKeyFieldAsset
candy.AnimatorTrackFieldAsset 	= animatorTrackFieldAssetModule.AnimatorTrackFieldAsset

function getAnimatorTrackFieldClass ( ftype )
	if ftype == "number" then
		return candy.AnimatorTrackFieldNumber
	elseif ftype == "int" then
		return candy.AnimatorTrackFieldInt
	elseif ftype == "boolean" then
		return candy.AnimatorTrackFieldBoolean
	elseif ftype == "string" then
		return candy.AnimatorTrackFieldString
	elseif ftype == "vec2" then
		return candy.AnimatorTrackFieldVec2
	elseif ftype == "vec3" then
		return candy.AnimatorTrackFieldVec3
	elseif ftype == "color" then
		return candy.AnimatorTrackFieldColor
	elseif ftype == "@asset" then
		return candy.AnimatorTrackFieldAsset
	elseif ftype == "@enum" then
		return candy.AnimatorTrackFieldEnum
	end
	return false
end

candy.AnimatorClipTreeNodePlay = require "candy.animator.AnimatorClipTreeNodePlay"
candy.AnimatorClipTreeNodeThrottle = require "candy.animator.AnimatorClipTreeNodeThrottle"

local animatorClipTreeNodeSelectModule = require "candy.animator.AnimatorClipTreeNodeSelect"
candy.AnimatorClipTreeNodeSelect 			= animatorClipTreeNodeSelectModule.AnimatorClipTreeNodeSelect
candy.AnimatorClipTreeNodeSelectCase 		= animatorClipTreeNodeSelectModule.AnimatorClipTreeNodeSelectCase
candy.AnimatorClipTreeNodeSelectCaseDefault = animatorClipTreeNodeSelectModule.AnimatorClipTreeNodeSelectCaseDefault

candy.AnimatorClipTreeNodeQueuedSelect = require "candy.animator.AnimatorClipTreeNodeQueueSelect"

local animatorAnimatorTrackModule = require "candy.animator.tracks.AnimatorAnimatorTrack"
candy.AnimatorAnimatorKey 				= animatorAnimatorTrackModule.AnimatorAnimatorKey
candy.AnimatorAnimatorTrack 			= animatorAnimatorTrackModule.AnimatorAnimatorTrack
candy.AnimatorClipSpeedAnimatorTrack 	= animatorAnimatorTrackModule.AnimatorClipSpeedAnimatorTrack

local entityMessageAnimatorTrackModule = require "candy.animator.tracks.EntityMsgAnimatorTrack"
candy.EntityMessageAnimatorKey 		= entityMessageAnimatorTrackModule.EntityMessageAnimatorKey
candy.EntityMessageAnimatorTrack 	= entityMessageAnimatorTrackModule.EntityMessageAnimatorTrack

local scriptAnimatorTrackModule = require "candy.animator.tracks.ScriptAnimatorTrack"
candy.ScriptAnimatorKey 	= scriptAnimatorTrackModule.ScriptAnimatorKey
candy.ScriptAnimatorTrack 	= scriptAnimatorTrackModule.ScriptAnimatorTrack

candy.AnimatorFSM = require "candy.animator.AnimatorFSM"

--------------------------------------------------------------------
local keymapsModule = require 'candy.input.Keymaps'
candy.KeyMaps 	= keymapsModule.KeyMaps
candy.getKeyMap = keymapsModule.getKeyMap

local inputDeviceModule = require 'candy.input.InputDevice'
candy.DefaultInputOption 		= inputDeviceModule.DefaultInputOption
candy.getInputDevice 			= inputDeviceModule.getInputDevice
candy.TouchState 				= inputDeviceModule.TouchState
candy.InputDevice 				= inputDeviceModule.InputDevice
candy.getDefaultInputDevice 	= inputDeviceModule.getDefaultInputDevice
candy.disableUserInput 			= inputDeviceModule.disableUserInput
candy.enableUserInput 			= inputDeviceModule.enableUserInput
candy.isUserInputEnabled 		= inputDeviceModule.isUserInputEnabled
candy.getTouchState 			= inputDeviceModule.getTouchState
candy.addTouchListener 			= inputDeviceModule.addTouchListener
candy.removeTouchListener 		= inputDeviceModule.removeTouchListener
candy.isMouseDown 				= inputDeviceModule.isMouseDown
candy.isMouseUp 				= inputDeviceModule.isMouseUp
candy.pollMouseHit 				= inputDeviceModule.pollMouseHit
candy.getMouseLoc 				= inputDeviceModule.getMouseLoc
candy.getMouseDelta 			= inputDeviceModule.getMouseDelta
candy.addMouseListener 			= inputDeviceModule.addMouseListener
candy.removeMouseListener 		= inputDeviceModule.removeMouseListener
candy.setMouseRandomness 		= inputDeviceModule.setMouseRandomness
candy.isKeyDown 				= inputDeviceModule.isKeyDown
candy.isKeyUp 					= inputDeviceModule.isKeyUp
candy.isShiftDown 				= inputDeviceModule.isShiftDown
candy.isCtrlDown 				= inputDeviceModule.isCtrlDown
candy.isAltDown 				= inputDeviceModule.isAltDown
candy.isMetaDown 				= inputDeviceModule.isMetaDown
candy.getModifierKeyStates 		= inputDeviceModule.getModifierKeyStates
candy.pollKeyHit 				= inputDeviceModule.pollKeyHit
candy.isKeyHit 					= inputDeviceModule.isKeyHit
candy.addKeyboardListener 		= inputDeviceModule.addKeyboardListener
candy.removeKeyboardListener 	= inputDeviceModule.removeKeyboardListener
candy.getAccelerometerData 		= inputDeviceModule.getAccelerometerData
candy.getGyroscopeData 			= inputDeviceModule.getGyroscopeData
candy.addCompassListener 		= inputDeviceModule.addCompassListener
candy.removeCompassListener 	= inputDeviceModule.removeCompassListener
candy.getCompassHeading 		= inputDeviceModule.getCompassHeading
candy.getLocation 				= inputDeviceModule.getLocation
candy._sendTouchEvent 			= inputDeviceModule._sendTouchEvent
candy._sendMouseEvent 			= inputDeviceModule._sendMouseEvent
candy._sendKeyEvent 			= inputDeviceModule._sendKeyEvent
candy._sendJoystickEvent 		= inputDeviceModule._sendJoystickEvent
candy._sendMotionEvent 			= inputDeviceModule._sendMotionEvent
candy._sendLevelEvent 			= inputDeviceModule._sendLevelEvent

local inputListenerModule = require 'candy.input.InputListener'
candy.InputListenerCategory 			= inputListenerModule.InputListenerCategory
candy.affirmInputListenerCategory 		= inputListenerModule.affirmInputListenerCategory
candy.getInputListenerCategory 			= inputListenerModule.getInputListenerCategory
candy.setInputListenerCategoryActive 	= inputListenerModule.setInputListenerCategoryActive
candy.isInputListenerCategoryActive 	= inputListenerModule.isInputListenerCategoryActive
candy.getSoloInputListenerCategory 		= inputListenerModule.getSoloInputListenerCategory
candy.setInputListenerCategorySolo 		= inputListenerModule.setInputListenerCategorySolo
candy.installInputListener 				= inputListenerModule.installInputListener
candy.uninstallInputListener 			= inputListenerModule.uninstallInputListener
candy.setInputListenerActive 			= inputListenerModule.setInputListenerActive
candy.getInputListener 					= inputListenerModule.getInputListener
candy.isInputListenerActive 			= inputListenerModule.isInputListenerActive

---
-- InputCommandMapping.
-- @see candy.input.InputCommandMapping
local inputCommandMappingModule = require 'candy.input.InputCommandMapping'
candy.InputCommandMapping 				= inputCommandMappingModule.InputCommandMapping
candy.InputCommandMappingManager 		= inputCommandMappingModule.InputCommandMappingManager
candy.getInputCommandMappingManager 	= inputCommandMappingModule.getInputCommandMappingManager
candy.isNavigationInputCommand 			= inputCommandMappingModule.isNavigationInputCommand
candy.getDefaultInputCommandMapping 	= inputCommandMappingModule.getDefaultInputCommandMapping
candy.getDefaultUIInputCommandMapping 	= inputCommandMappingModule.getDefaultUIInputCommandMapping
candy.getInputCommandMapping 			= inputCommandMappingModule.getInputCommandMapping
candy.affirmInputCommandMapping 		= inputCommandMappingModule.affirmInputCommandMapping
candy.isInputCommandDown 				= inputCommandMappingModule.isInputCommandDown
candy.isInputCommandUp 					= inputCommandMappingModule.isInputCommandUp

local joystickManagerModule = require 'candy.input.JoystickManager'
candy.getJoystickManager 		= joystickManagerModule.getJoystickManager
candy.JoystickMapping 			= joystickManagerModule.JoystickMapping
candy.JoystickState 			= joystickManagerModule.JoystickState
candy.JoystickManager 			= joystickManagerModule.JoystickManager
candy.DummyJoystickManager 		= joystickManagerModule.DummyJoystickManager
candy.setBasicUIJoystickButtons = joystickManagerModule.setBasicUIJoystickButtons
candy.isConfirmButton 			= joystickManagerModule.isConfirmButton
candy.isCancelButton 			= joystickManagerModule.isCancelButton

local inputRecorderModule = require 'candy.input.InputRecorder'
candy.InputEventRecorder 		= inputRecorderModule.InputEventRecorder
candy.InputEventPlayer 			= inputRecorderModule.InputEventPlayer
candy.playOrRecordInputEvent 	= inputRecorderModule.playOrRecordInputEvent

candy.InputScript = require 'candy.input.InputScript'


--------------------------------------------------------------------
-- Audio API
--------------------------------------------------------------------
local audioManagerModule = require 'candy.AudioManager'

local audio = {}

--- SoundMgr
audio.soundMgr = nil

---
-- Initializes the module.
---@param soundMgr (option) soundMgr object.
function audio.init ( soundMgr )
    if not audio.soundMgr then
        if soundMgr then
            audio.soundMgr = soundMgr
        elseif MOAIUntzSystem then
            audio.soundMgr = audioManagerModule.UntzSoundMgr ()
        else
            
        end
    end
end

---
-- Play the sound.
---@param sound file path or object.
---@param volume (Optional)volume. Default value is 1.
---@param looping (Optional)looping flag. Default value is 'false'.
---@return Sound object
function audio.play ( sound, volume, looping )
    return audio.soundMgr:play ( sound, volume, looping )
end

---
-- Pause the sound.
---@param sound file path or object.
function audio.pause ( sound )
    audio.soundMgr:pause ( sound )
end

---
-- Stop the sound.
---@param sound file path or object.
function audio.stop ( sound )
    audio.soundMgr:stop ( sound )
end

---
-- Set the system level volume.
---@param volume volume(0 <= volume <= 1)
function audio.setVolume ( volume )
    audio.soundMgr:setVolume ( volume )
end

---
-- Return the system level volume.
---@return volume
function audio.getVolume ( volume )
    audio.soundMgr:getVolume ()
end

---
-- Return SoundMgr a singleton.
---@return soundMgr
function audio.getSoundMgr ()
    return audio.soundMgr
end

candy.audio = audio

---
-- Entity.
-- @see candy.Entity
local entityModule = require 'candy.Entity'
candy.Entity 					= entityModule.Entity
candy.registerEntity 			= entityModule.registerEntity
candy.getEntityRegistry 		= entityModule.getEntityRegistry
candy.getEntityType 			= entityModule.getEntityType
candy.buildEntityCategories 	= entityModule.buildEntityCategories
candy.cloneEntity 				= entityModule.cloneEntity

candy.EntityTag = require 'candy.EntityTag'

---
-- EntityGroup.
-- @see candy.EntityGroup
candy.EntityGroup = require 'candy.EntityGroup'

---
-- EntityComponent.
-- @see candy.EntityComponent
local entityComponentModule = require 'candy.Component'
candy.Component 					= entityComponentModule.Component
candy.registerComponent 			= entityComponentModule.registerComponent
candy.registerEntityWithComponent 	= entityComponentModule.registerEntityWithComponent
candy.getComponentRegistry 			= entityComponentModule.getComponentRegistry
candy.getComponentType 				= entityComponentModule.getComponentType
candy.buildComponentCategories 		= entityComponentModule.buildComponentCategories

candy.Layer = require 'candy.Layer'

candy.Behaviour = require 'candy.common.Behaviour'
candy.UpdateListener = require 'candy.common.UpdateListener'

---
-- SceneComponent.
-- @see candy.SceneComponent
candy.SceneComponent = require 'candy.SceneComponent'

candy.EditorEntity = require 'candy.EditorEntity'

---
-- GlobalEntity.
-- @see candy.GlobalEntity
local globalEntityModule = require 'candy.GlobalEntity'
candy.GlobalEntity = globalEntityModule.GlobalEntity
candy.SingleEntity = globalEntityModule.SingleEntity
candy.SimpleEntity = globalEntityModule.SimpleEntity

candy.Scene = require 'candy.Scene'
candy.SceneSession = require 'candy.SceneSession'

local sceneManagerModule = require 'candy.SceneManager'
candy.SceneManagerFactory = sceneManagerModule.SceneManagerFactory
candy.SceneManager = sceneManagerModule.SceneManager

---
-- RenderManager.
-- @see candy.RenderManager
local renderManagerModule = require 'candy.RenderManager'
candy.getRenderManager 				= renderManagerModule.getRenderManager
candy.GlobalTextureItem 			= renderManagerModule.GlobalTextureItem
candy.RenderManager 				= renderManagerModule.RenderManager
candy.createTableRenderLayer 		= renderManagerModule.createTableRenderLayer
candy.createTableViewRenderLayer 	= renderManagerModule.createTableViewRenderLayer
candy.createPartitionRenderLayer 	= renderManagerModule.createPartitionRenderLayer

local renderContextModule = require 'candy.RenderContext'
candy.RenderContext 		= renderContextModule.RenderContext
candy.DummyRenderContext 	= renderContextModule.DummyRenderContext

candy.GameRenderContext = require 'candy.GameRenderContext'
candy.Game = require 'candy.Game'


---
-- RenderMaterial.
-- @see candy.RenderMaterial
local renderMaterialModule = require 'candy.gfx.asset.RenderMaterial'
candy.RenderMaterialInstance 	= renderMaterialModule.RenderMaterialInstance
candy.RenderMaterial 			= renderMaterialModule.RenderMaterial
candy.getDefaultRenderMaterial 	= renderMaterialModule.getDefaultRenderMaterial

---
-- Camera.
-- @see candy.Camera
candy.Camera = require 'candy.gfx.Camera'

local cameraManagerModule = require 'candy.gfx.CameraManager'
candy.CameraManager 	= cameraManagerModule.CameraManager
candy.getCameraManager 	= cameraManagerModule.getCameraManager

local cameraPassModule = require 'candy.gfx.CameraPass'
candy.CameraPass 			= cameraPassModule.CameraPass
candy.SceneCameraPass 		= cameraPassModule.SceneCameraPass
candy.CallbackCameraPass 	= cameraPassModule.CallbackCameraPass

candy.RenderComponent = require 'candy.gfx.RenderComponent'
candy.GraphicsPropComponent = require 'candy.gfx.GraphicsPropComponent'

candy.DeckComponent = require 'candy.gfx.DeckComponent'
candy.DeckComponentArray = require 'candy.gfx.DeckComponentArray'
candy.DeckComponentGrid = require 'candy.gfx.DeckComponentGrid'
candy.TextLabel = require 'candy.gfx.TextLabel'

candy.PatchSprite = require 'candy.gfx.PatchSprite'
candy.DrawScript = require 'candy.gfx.DrawScript'

local geometryModule = require 'candy.gfx.Geometry'
candy.GeometryComponent 	= geometryModule.GeometryComponent
candy.GeometryRect 			= geometryModule.GeometryRect
candy.GeometryCircle 		= geometryModule.GeometryCircle
candy.GeometryRay 			= geometryModule.GeometryRay
candy.GeometryBoxOutline 	= geometryModule.GeometryBoxOutline
candy.GeometryLineStrip 	= geometryModule.GeometryLineStrip
candy.GeometryPolygon 		= geometryModule.GeometryPolygon

candy.TexturePlane = require 'candy.gfx.TexturePlane'
candy.PatchTexturePlane = require 'candy.gfx.PatchTexturePlane'
candy.TiledTexturePlane = require 'candy.gfx.TiledTexturePlane'

local tileMapModule = require 'candy.gfx.TileMap'
candy.TileMapGrid 			= tileMapModule.TileMapGrid
candy.TileMapLayer 			= tileMapModule.TileMapLayer
candy.TileMapParam 			= tileMapModule.TileMapParam
candy.TileMapResizeParam 	= tileMapModule.TileMapResizeParam
candy.TileMap 				= tileMapModule.TileMap

local tileMap2DModule = require 'candy.gfx.TileMap2D'
candy.TileMap2DLayer 	= tileMap2DModule.TileMap2DLayer
candy.TileMap2D 		= tileMap2DModule.TileMap2D

local namedTileMapModule = require 'candy.gfx.NamedTileMap'
candy.NamedTileGrid 	= namedTileMapModule.NamedTileGrid
candy.NamedTileMapLayer = namedTileMapModule.NamedTileMapLayer

local codeTileMapLayerModule = require 'candy.gfx.CodeTileMapLayer'
candy.CodeTileGrid 		= codeTileMapLayerModule.CodeTileGrid
candy.CodeTileMapLayer 	= codeTileMapLayerModule.CodeTileMapLayer

candy.TilemapBrush = require 'candy.tools.TilemapBrush'

--------------------------------------------------------------------
-- Physics
candy.PhysicsBodyDef = require "candy.physics.2D.PhysicsBodyDef"
candy.PhysicsMaterial = require "candy.physics.2D.PhysicsMaterial"
candy.PhysicsBody = require "candy.physics.2D.PhysicsBody"
candy.PhysicsShape = require "candy.physics.2D.PhysicsShape"
candy.PhysicsJoint = require "candy.physics.2D.PhysicsJoint"

local physicsTriggerModule = require "candy.physics.2D.PhysicsTrigger"
candy.TriggerObjectBase = physicsTriggerModule.TriggerObjectBase
candy.TriggerObject 	= physicsTriggerModule.TriggerObject

local physicsTriggerAreaModule = require "candy.physics.2D.PhysicsTriggerArea"
candy.TriggerAreaBase 	= physicsTriggerAreaModule.TriggerAreaBase
candy.TriggerAreaCircle = physicsTriggerAreaModule.TriggerAreaCircle
candy.TriggerAreaBox 	= physicsTriggerAreaModule.TriggerAreaBox

candy.PhysicsShapeBox = require "candy.physics.2D.PhysicsShapeBox"
candy.PhysicsShapeCircle = require "candy.physics.2D.PhysicsShapeCircle"

local physicsShapePolygonModule = require "candy.physics.2D.PhysicsShapePolygon"
candy.Box2DShapeGroupProxy 	= physicsShapePolygonModule.Box2DShapeGroupProxy
candy.PhysicsShapePolygon 	= physicsShapePolygonModule.PhysicsShapePolygon

candy.PhysicsShapeChain = require "candy.physics.2D.PhysicsShapeChain"
candy.PhysicsShapeBevelBox = require "candy.physics.2D.PhysicsShapeBevelBox"
candy.PhysicsShapePie = require "candy.physics.2D.PhysicsShapePie"
candy.PhysicsJointDistance = require "candy.physics.2D.PhysicsJointDistance"
candy.PhysicsJointFriction = require "candy.physics.2D.PhysicsJointFriction"


--------------------------------------------------------------------
-- AI
candy.FSMScheme = require "candy.ai.FSMScheme"
candy.FSMController = require "candy.ai.FSMController"
candy.ScriptedFSMController = require "candy.ai.ScriptedFSMController"
candy.BTScheme = require "candy.ai.BTScheme"
candy.BTScript = require "candy.ai.BTScript"

local btControllerModule = require "candy.ai.BTController"
candy.BTAction 						= btControllerModule.BTAction
candy.BTContext 					= btControllerModule.BTContext
candy.BehaviorTree 					= btControllerModule.BehaviorTree
candy.BTNode 						= btControllerModule.BTNode
candy.BTActionNode 					= btControllerModule.BTActionNode
candy.BTLoggingNode 				= btControllerModule.BTLoggingNode
candy.BTMsgSendingNode 				= btControllerModule.BTMsgSendingNode
candy.BTCondition 					= btControllerModule.BTCondition
candy.BTConditionNot 				= btControllerModule.BTConditionNot
candy.BTCompositedNode 				= btControllerModule.BTCompositedNode
candy.BTPrioritySelector 			= btControllerModule.BTPrioritySelector
candy.BTRootNode 					= btControllerModule.BTRootNode
candy.BTSequenceSelector 			= btControllerModule.BTSequenceSelector
candy.BTRandomSelector 				= btControllerModule.BTRandomSelector
candy.BTShuffledSequenceSelector 	= btControllerModule.BTShuffledSequenceSelector
candy.BTConcurrentAndSelector 		= btControllerModule.BTConcurrentAndSelector
candy.BTConcurrentOrSelector 		= btControllerModule.BTConcurrentOrSelector
candy.BTConcurrentEitherSelector 	= btControllerModule.BTConcurrentEitherSelector
candy.BTDecorator 					= btControllerModule.BTDecorator
candy.BTDecoratorNot 				= btControllerModule.BTDecoratorNot
candy.BTDecoratorAlwaysOK 			= btControllerModule.BTDecoratorAlwaysOK
candy.BTDecoratorAlwaysFail 		= btControllerModule.BTDecoratorAlwaysFail
candy.BTDecoratorAlwaysIgnore 		= btControllerModule.BTDecoratorAlwaysIgnore
candy.BTDecoratorRepeatUntil 		= btControllerModule.BTDecoratorRepeatUntil
candy.BTDecoratorRepeatFor 			= btControllerModule.BTDecoratorRepeatFor
candy.BTDecoratorRepeatWhile 		= btControllerModule.BTDecoratorRepeatWhile
candy.BTDecoratorRepeatForever 		= btControllerModule.BTDecoratorRepeatForever
candy.BTDecoratorWeight 			= btControllerModule.BTDecoratorWeight
candy.BTDecoratorProb 				= btControllerModule.BTDecoratorProb
candy.BTController 					= btControllerModule.BTController
candy.BehaviorTreeNodeTypes 		= btControllerModule.BehaviorTreeNodeTypes

local btActionCommonModule = require "candy.ai.BTActionCommon"
candy.BTActionReset 	= btActionCommonModule.BTActionReset
candy.BTActionStop 		= btActionCommonModule.BTActionStop
candy.BTActionCoroutine = btActionCommonModule.BTActionCoroutine

-- candy.AITEXTUBOX = require "candy.ai.SteerController"
local pathFinderModule = require "candy.ai.PathFinder"
candy.getPathFinderManager 	= pathFinderModule.getPathFinderManager
candy.PathFinderManager 	= pathFinderModule.PathFinderManager
candy.PathGraph 			= pathFinderModule.PathGraph
candy.PathFinder 			= pathFinderModule.PathFinder

candy.PathGraphNavMesh2D = require "candy.ai.PathGraphNavMesh2D"

local waypointPathGraphModule = require "candy.ai.WaypointPathGraph"
candy.WaypointGraphContainer 	= waypointPathGraphModule.WaypointGraphContainer
candy.Waypoint 					= waypointPathGraphModule.Waypoint
candy.WaypointPathGraph 		= waypointPathGraphModule.WaypointPathGraph
candy.WaypointPathFinder 		= waypointPathGraphModule.WaypointPathFinder


--------------------------------------------------------------------
-- hanappe UI
--------------------------------------------------------------------
if candy.UI_LIBRARY == 'flower' then
UIEvent = _ENUM_V {
	"resize", --- UIComponent: Resize Event
	"theme_changed", --- UIComponent: Theme changed Event
	"style_changed", --- UIComponent: Style changed Event
	"enabled_changed", --- UIComponent: Enabled changed Event
	"focus_in", --- UIComponent: FocusIn Event
	"focus_out", --- UIComponent: FocusOut Event
	"click", --- Button: Click Event
	"cancel", --- Button: Click Event
	"selected_changed", --- Button: Selected changed Event
	"down", --- Button: down Event
	"up", --- Button: up Event
	"value_changed", --- Slider: value changed Event
	"stick_changed", --- Joystick: Event type when you change the position of the stick
	"msg_show", --- MsgBox: msgShow Event
	"msg_hide", --- MsgBox: msgHide Event
	"msg_end", --- MsgBox: msgEnd Event
	"spool_stop", --- MsgBox: spoolStop Event
	"item_changed", --- ListBox: selectedChanged
	"item_enter", --- ListBox: enter
	"item_click", --- ListBox: itemClick
	"scroll", --- ScrollGroup: scroll
	"validate_all_complete",
	"touch_down",
	"touch_up",
	"touch_move",
	"touch_cancel",
}

candy.BaseTheme = require 'candy.ui.BaseTheme'
candy.ThemeMgr 	= require 'candy.ui.ThemeMgr'
candy.FocusMgr 	= require 'candy.ui.FocusMgr'
candy.LayoutMgr = require 'candy.ui.LayoutMgr'
candy.TextAlign = require 'candy.ui.TextAlign'

candy.Label 				= require 'candy.ui.Label'
candy.Image 				= require 'candy.ui.Image'
candy.UIComponent 			= require 'candy.ui.UIComponent'
candy.UILayer 				= require 'candy.ui.UILayer'
candy.UIGroup 				= require 'candy.ui.UIGroup'
candy.UIView 				= require 'candy.ui.UIView'
candy.UILayout 				= require 'candy.ui.UILayout'
candy.UILabel 				= require 'candy.ui.UILabel'
candy.BoxLayout 			= require 'candy.ui.BoxLayout'
candy.Button 				= require 'candy.ui.Button'
candy.ImageButton 			= require 'candy.ui.ImageButton'
candy.CheckBox 				= require 'candy.ui.CheckBox'
candy.Panel 				= require 'candy.ui.Panel'
candy.TextLabel 			= candy.UILabel
candy.TextBox 				= require 'candy.ui.TextBox'
candy.TextInput 			= require 'candy.ui.TextInput'
candy.MsgBox 				= require 'candy.ui.MsgBox'
candy.ListBox 				= require 'candy.ui.ListBox'
candy.ListItem 				= require 'candy.ui.ListItem'
candy.Slider 				= require 'candy.ui.Slider'
candy.Spacer 				= require 'candy.ui.Spacer'
candy.ScrollGroup 			= require 'candy.ui.ScrollGroup'
candy.ScrollView 			= require 'candy.ui.ScrollView'
candy.PanelView 			= require 'candy.ui.PanelView'
candy.TextView 				= require 'candy.ui.TextView'
candy.ListView 				= require 'candy.ui.ListView'
candy.ListViewLayout 		= require 'candy.ui.ListViewLayout'
candy.BaseItemRenderer 		= require 'candy.ui.BaseItemRenderer'
candy.LabelItemRenderer 	= require 'candy.ui.LabelItemRenderer'
candy.CheckBoxItemRenderer 	= require 'candy.ui.CheckBoxItemRenderer'
candy.WidgetItemRenderer 	= require 'candy.ui.WidgetItemRenderer'
end

--------------------------------------------------------------------
-- Light UI
--------------------------------------------------------------------
if candy.UI_LIBRARY == 'light' then
EnumUILayoutPolicy = _ENUM_V {
	"expand",
	"minimum",
	"fixed"
}
EnumUILayoutAlignmentH = _ENUM_V {
	"left",
	"center",
	"right"
}
EnumUILayoutAlignmentV = _ENUM_V {
	"top",
	"middle",
	"bottom"
}

candy.UICommon = require 'candy.ui.light.UICommon'

local uiCursorModule = require 'candy.ui.light.UICursor'
candy.UICursor 				= uiCursorModule.UICursor
candy.UIGraphicsPropCursor 	= uiCursorModule.UIGraphicsPropCursor
candy.UITexturePlaneCursor 	= uiCursorModule.UITexturePlaneCursor
candy.UIDefaultCursor 		= uiCursorModule.UIDefaultCursor
candy.UICursorSimple 		= uiCursorModule.UICursorSimple
candy.UICursorManager 		= uiCursorModule.UICursorManager
candy.getUICursorManager 	= uiCursorModule.getUICursorManager
candy.setCursor 			= uiCursorModule.setCursor
candy.registerCursor 		= uiCursorModule.registerCursor

candy.UIPointer = require 'candy.ui.light.UIPointer'

local uiStyleModule = require 'candy.ui.light.UIStyle'
candy.UIStyleSheet 		= uiStyleModule.UIStyleSheet
candy.UIStyleRawItem 	= uiStyleModule.UIStyleRawItem

candy.UIStyleAccessor = require 'candy.ui.light.UIStyleAccessor'
candy.UIStyleBase = require 'candy.ui.light.UIStyleBase'
candy.UIEvent = require 'candy.ui.light.UIEvent'
_G.UIEvent = candy.UIEvent

local uiMsgModule = require 'candy.ui.light.UIMsg'
candy.UIMsgSourceBase 	= uiMsgModule.UIMsgSourceBase
candy.UIMsgTarget 		= uiMsgModule.UIMsgTarget
candy.UIMsgSource 		= uiMsgModule.UIMsgSource

local uiWidgetFXModule = require 'candy.ui.light.UIWidgetFX'
candy.UIWidgetFX 		= uiWidgetFXModule.UIWidgetFX
candy.UIWidgetFXHolder 	= uiWidgetFXModule.UIWidgetFXHolder

local uiWidgetModule = require 'candy.ui.light.UIWidget'
candy.UIWidgetBase 	= uiWidgetModule.UIWidgetBase
candy.UIWidget 		= uiWidgetModule.UIWidget

candy.UIWidgetElement = require 'candy.ui.light.UIWidgetElement'
candy.UIWidgetRenderer = require 'candy.ui.light.UIWidgetRenderer'

local uiLayoutModule = require 'candy.ui.light.UILayout'
candy.UILayoutEntry = uiLayoutModule.UILayoutEntry
candy.UILayout 		= uiLayoutModule.UILayout

candy.UILayoutItem = require 'candy.ui.light.UILayoutItem'
candy.UIFocusManager = require 'candy.ui.light.UIFocusManager'

local uiResourceManagerModule = require 'candy.ui.light.UIResourceManager'
candy.UIResourceProvider 	= uiResourceManagerModule.UIResourceProvider
candy.UIResourceManager 	= uiResourceManagerModule.UIResourceManager

candy.UIView = require 'candy.ui.light.UIView'

local uiViewMappingModule = require 'candy.ui.light.UIViewMapping'
candy.UIViewMapping 	= uiViewMappingModule.UIViewMapping
candy.UIViewMappingRect = uiViewMappingModule.UIViewMappingRect

candy.UIFocusCursor = require 'candy.ui.light.UIFocusCursor'
candy.UIManager = require 'candy.ui.light.UIManager'

local uiBoxLayoutModule = require 'candy.ui.light.UIBoxLayout'
candy.UIBoxLayout 	= uiBoxLayoutModule.UIBoxLayout
candy.UIHBoxLayout 	= uiBoxLayoutModule.UIHBoxLayout
candy.UIVBoxLayout 	= uiBoxLayoutModule.UIVBoxLayout

candy.UIGridLayout = require 'candy.ui.light.UIGridLayout'
candy.UIFocusConnection = require 'candy.ui.light.UIFocusConnection'
candy.UIWidgetGroup = require 'candy.ui.light.UIWidgetGroup'
candy.UISpacer = require 'candy.ui.light.UISpacer'

candy.UIWidgetElementText = require 'candy.ui.light.renderers.UIWidgetElementText'
candy.UIWidgetElementImage = require 'candy.ui.light.renderers.UIWidgetElementImage'
candy.UIWidgetElementGeometry = require 'candy.ui.light.renderers.UIWidgetElementGeometry'
candy.UIWidgetElementScript = require 'candy.ui.light.renderers.UIWidgetElementScript'
candy.UICommonStyleWidgetRenderer = require 'candy.ui.light.renderers.UICommonStyleWidgetRenderer'
candy.UIFrameRenderer = require 'candy.ui.light.renderers.UIFrameRenderer'
candy.UITextAreaRenderer = require 'candy.ui.light.renderers.UITextAreaRenderer'
candy.UIButtonRenderer = require 'candy.ui.light.renderers.UIButtonRenderer'
candy.UIImageRenderer = require 'candy.ui.light.renderers.UIImageRenderer'

candy.UIImage = require 'candy.ui.light.widgets.UIImage'
candy.UILabel = require 'candy.ui.light.widgets.UILabel'
candy.UITextArea = require 'candy.ui.light.widgets.UITextArea'
candy.UIFrame = require 'candy.ui.light.widgets.UIFrame'
candy.UIScrollArea = require 'candy.ui.light.widgets.UIScrollArea'

local uiButtonBaseModule = require 'candy.ui.light.widgets.UIButtonBase'
candy.UIButtonBase = uiButtonBaseModule.UIButtonBase
candy.UIButtonMsg = uiButtonBaseModule.UIButtonMsg

candy.UIButton = require 'candy.ui.light.widgets.UIButton'
candy.UISimpleButton = require 'candy.ui.light.widgets.UISimpleButton'
candy.UIToggleButton = require 'candy.ui.light.widgets.UIToggleButton'

local uiCheckBoxModule = require 'candy.ui.light.widgets.UICheckBox'
candy.UICheckBoxRenderer = uiCheckBoxModule.UICheckBoxRenderer
candy.UICheckBox = uiCheckBoxModule.UICheckBox

local uiListViewModule = require 'candy.ui.light.widgets.UIListView'
candy.UIListItem = uiListViewModule.UIListItem
candy.UIListView = uiListViewModule.UIListView

local uiTextEditModule = require 'candy.ui.light.widgets.UITextEdit'
candy.UITextSelectionRenderer = uiTextEditModule.UITextSelectionRenderer
candy.UITextEditCursor = uiTextEditModule.UITextEditCursor
candy.UITextEditRenderer = uiTextEditModule.UITextEditRenderer
candy.UITextEdit = uiTextEditModule.UITextEdit

local uiSliderModule = require 'candy.ui.light.widgets.UISlider'
candy.UISliderHandle = uiSliderModule.UISliderHandle
candy.UISliderSlot = uiSliderModule.UISliderSlot
candy.UISlider = uiSliderModule.UISlider
candy.UIHSlider = uiSliderModule.UIHSlider
candy.UIVSlider = uiSliderModule.UIVSlider

local uiScrollBarModule = require 'candy.ui.light.widgets.UIScrollBar'
candy.UISlider = uiScrollBarModule.UIScrollBar
candy.UIHSlider = uiScrollBarModule.UIHScrollBar
candy.UIVSlider = uiScrollBarModule.UIVScrollBar

local uiFormLayoutModule = require 'candy.ui.light.widgets.UIFormLayout'
candy.UIFormLayoutLabel = uiFormLayoutModule.UIFormLayoutLabel
candy.UIFormLayoutItem = uiFormLayoutModule.UIFormLayoutItem
candy.UIFormLayout = uiFormLayoutModule.UIFormLayout
end

return candy