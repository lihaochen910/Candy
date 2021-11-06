module ( 'candy', package.seeall )

-- module
local candy = {}

rawset ( _G, '_C', {} )

require 'engine.Class'
require 'engine.ClassHelpers'

require 'engine.helper.MOAIHelpers'
require 'engine.helper.MOAIPropHelpers'
require 'engine.helper.JSONHelper'
require 'engine.helper.ProfilerHelper'
require 'engine.helper.GUIDHelper'

require 'engine.env'

require 'engine.utils'
require 'engine.signal'
require 'engine.LogHelper'

require 'engine.Serializer'

require 'engine.AssetLibrary'
require 'engine.asset.init'

require 'engine.Viewport'
require 'engine.RenderTarget'
require 'engine.Layer'

require 'engine.DebugDrawQueue'

require 'engine.input.Keymaps'
require 'engine.input.InputDevice'
require 'engine.input.InputListener'

require 'engine.Game'
require 'engine.Scene'
require 'engine.SceneSession'
require 'engine.Actor'
require 'engine.ActorGroup'
require 'engine.Component'
require 'engine.EditorEntity'

require 'engine.gfx.init'

require 'engine.input.InputScript'

_G.Scene = candy.Scene
_G.Actor = candy.Actor
_G.Camera = candy.Camera

_C.game = candy.game

candy.init = function (path, fromEditor, extra)
	candy.game:loadConfig(path, fromEditor, extra)
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

candy.setActionRoot = function(root)
	assert(root, 'root not be nil')
	print("candy.setActionRoot() currentRoot", MOAIActionMgr.getRoot())
	MOAIActionMgr.setRoot(root)
	print("candy.setActionRoot() after currentRoot", MOAIActionMgr.getRoot())
end

candy.setCustomActionRoot = function()
	print("candy.setCustomActionRoot() currentRoot", MOAIActionMgr.getRoot())
	MOAIActionMgr.setRoot(MOAIAction.new())
	print("candy.setCustomActionRoot() after currentRoot", MOAIActionMgr.getRoot())
end

candy.setNilActionRoot = function()
	print("candy.setNilActionRoot() currentRoot",MOAIActionMgr.getRoot())
   MOAIActionMgr.setRoot(nil)
	print("candy.setNilActionRoot() after currentRoot",MOAIActionMgr.getRoot())
end

-- print("Candy.lua run check.")
-- print("MOAISim.getActionMgr()", MOAISim.getActionMgr())
-- print("MOAISim.getActionMgr():getRoot()", MOAISim.getActionMgr():getRoot())
-- print("MOAIActionMgr.getRoot()", MOAIActionMgr.getRoot())
-- candy.setNilActionRoot()


-- for c in pairs(entity.components) do
--     print(entity:getName(), c.__guid, c.FLAG_EDITOR_OBJECT)
-- end

-- game:addLayer('default', 'last')

-- game:getLayer('default').default = true

-- game:init()

-- game.mainScene = Scene()

-- game.mainScene:start()

-- local entity = Actor()

-- game.mainScene:addActor(entity)

-- require 'testComponent'

-- local testComponent = TestComponent()

-- entity:attach(testComponent)

CLASS: TestComponent(Component)
	:MODEL{
		Field 'active'           :boolean() :isset('Active');
		Field 'zoom'             :number()  :getset('Zoom')   :range(0) :meta{ step = 0.1};
		Field 'clearColor'       :type( 'color' ) :getset( 'ClearColor' );
	}

function TestComponent:__init()
	self.name = "TestComponent"
	self.zoom = 0
	self.clearColor = {0,0,0,0}
end

function TestComponent:onUpdate(dt)
	_log("TestComponent.onUpdate()", dt)
end

function TestComponent:setActive(active) end
function TestComponent:setZoom(z) self.zoom = zoom end
function TestComponent:getZoom() return self.zoom end
function TestComponent:setClearColor(color) self.clearColor = color end
function TestComponent:getClearColor() return self.clearColor end

registerComponent( 'TestComponent', TestComponent )

CLASS: TestComponent_2(TestComponent)
CLASS: TestComponent_3(TestComponent)

CLASS: TestActor(Actor)
function TestActor:__init()
	self.name = "TestActor"
	self:attach(TestComponent())
	self:attach(TestComponent_2())
	self:attach(TestComponent_3())

	self.prevUpdateTime = 0
end

function TestActor:onUpdate()
	if self:getTime() - self.prevUpdateTime >= 1 then
		self.prevUpdateTime = self:getTime()
		_log("TestActor:onUpdate(dt)", dt, self:getTime())
	end
end

registerActor('TestActor', TestActor)


local SPEED = 10

CLASS: MoveComponent( DrawScript )

function MoveComponent:onAttach(entity)
	-- entity:_insertPropToLayer(entity._prop)
	-- self.__super:onAttach(entity)
end

function MoveComponent:onUpdate( dt )

	-- self.__super:onUpdate( dt )

	-- local camera = game.mainCamera
	local camera = self:getOwner()

	if isKeyDown( 'w' ) then
		print( "isKeyDown( 'w' )" )
		camera:addLoc ( 0, SPEED * dt, 0 )
	end
	if isKeyDown( 's' ) then
		camera:addLoc ( 0, -SPEED * dt, 0 )
	end
	if isKeyDown( 'a' ) then
		camera:addLoc ( -SPEED * dt, 0, 0 )
	end
	if isKeyDown( 'd' ) then
		camera:addLoc ( SPEED * dt, 0, 0 )
	end
	if isKeyDown( 'up' ) then
		camera:addLoc ( 0, 0, SPEED * dt )
	end
	if isKeyDown( 'down' ) then
		camera:addLoc ( 0, 0, -SPEED * dt )
	end

	-- print ( camera:getWorldLoc() )
end

function MoveComponent:onDraw()
	print ('MoveComponent:onDraw()')

	MOAIDraw.setPenColor( 0, 1, 0, 0.3 )
	MOAIDraw.drawRect( 0, 0, 100, 100 )

end


return candy