module 'candy_edit'

CLASS: Gizmo ( candy.EditorActor )
	:MODEL{}

function Gizmo:__init()
	self.items = {}
end

function Gizmo:enableConstantSize()
	self.parent:addConstantSizeGizmo( self )
end

function Gizmo:setTarget( object )
end

function Gizmo:setTransform( transform )
	inheritTransform( self._prop, transform )
end

function Gizmo:updateCanvas()
	self.parent:updateCanvas()
end

function Gizmo:onDestroy()
	self.parent.constantSizeGizmos[ self ] = nil
end

function Gizmo:addCanvasItem( item )
	local view = self:getCurrentView()
	view:addCanvasItem( item )
	self.items[ item ] = true
	return item
end

function Gizmo:removeCanvasItem( item )
	if item then
		item:destroyWithChildrenNow()
	end
end

function Gizmo:onDestroy()
	for item in pairs( self.items ) do
		item:destroyWithChildrenNow()
	end
end

function Gizmo:isPickable()
	return false
end

--------------------------------------------------------------------
CLASS: GizmoManager ( SceneEventListener )
	:MODEL{}

function GizmoManager:__init()
	self.normalGizmoMap   = {}
	self.selectedGizmoMap = {}
	self.constantSizeGizmos = {}
	self.gizmoVisible = true
end

function GizmoManager:onLoad()
	local view = self.parent
	local cameraListenerNode = MOAIScriptNode.new()
	cameraListenerNode:setCallback( function() self:updateConstantSize() end )
	local cameraCom = view:getCameraComponent()
	cameraListenerNode:setNodeLink( cameraCom.zoomControlNode )
	if cameraCom:isPerspective() then
		cameraListenerNode:setNodeLink( cameraCom:getMoaiCamera() )
	end
	self.cameraListenerNode = cameraListenerNode
	self:scanScene()
end

function GizmoManager:onDestroy()

end

function GizmoManager:updateConstantSizeForGizmo( giz )
	local view = self.parent
	local cameraCom = view:getCameraComponent()
	local factorZoom = 1 / cameraCom:getZoom()
	local factorDistance = 1
	if cameraCom:isPerspective() then
		--TODO
	end
	local scl = factorZoom * factorDistance
	giz:setScl( scl, scl, scl )
	giz:forceUpdate()
end

function GizmoManager:updateConstantSize()
	for giz in pairs( self.constantSizeGizmos ) do
		self:updateConstantSizeForGizmo( giz )
	end
end

function GizmoManager:_attachChildActor( child )
	linkLocalVisible( self:getProp(), child:getProp() )
end

function GizmoManager:onSelectionChanged( selection )
	--clear selection gizmos
	for ent, giz in pairs( self.selectedGizmoMap ) do
		giz:destroyWithChildrenNow()
	end
	self.selectedGizmoMap = {}
	local actorSet = {}
	for i, e in ipairs( selection ) do
		actorSet[ e ] = true
	end
	local topActorSet = findTopLevelActors( actorSet )
	for e in pairs( topActorSet ) do
		if isInstance( e, candy.Actor ) then
			self:buildForActor( e, true )
		end
	end
end

function GizmoManager:onActorEvent( ev, actor, com )
	if ev == 'clear' then
		self:clear()
		return
	end

	if actor.FLAG_EDITOR_OBJECT then return end

	if ev == 'add' then
		self:buildForActor( actor ) 
	elseif ev == 'remove' then
		self:removeForActor( actor )
	elseif ev == 'attach' then
		self:buildForObject( com )
	elseif ev == 'detach' then
		self:removeForObject( com )
	end
end

function GizmoManager:addConstantSizeGizmo( giz )
	self.constantSizeGizmos[ giz ] = true	
	self:updateConstantSizeForGizmo( giz )
end

function GizmoManager:refresh()
	self:clear()
	self:scanScene()
	self:updateConstantSize()
end

function GizmoManager:scanScene()
	local actors = table.simplecopy( self.scene.actors )
	for e in pairs( actors ) do
		self:buildForActor( e, false )
	end
end

function GizmoManager:buildForActor( actor, selected )
	if actor.components then
		if not ( actor.FLAG_INTERNAL or actor.FLAG_EDITOR_OBJECT ) then
			self:buildForObject( actor, selected )
			for c in pairs( actor.components ) do
				if not ( c.FLAG_EDITOR_OBJECT ) then
					self:buildForObject( c, selected )
				end
			end
			for child in pairs( actor.children ) do
				self:buildForActor( child, selected )
			end
		end
	end
end

function GizmoManager:buildForObject( obj, selected )
	local onBuildGizmo
	if selected then 
		onBuildGizmo = obj.onBuildSelectedGizmo
	else
		onBuildGizmo = obj.onBuildGizmo
	end
	if onBuildGizmo then
		local giz = onBuildGizmo( obj )
		if giz then
			if not isInstance( giz, Gizmo ) then
				_warn( 'Invalid gizmo type given by', obj:getClassName() )
				return
			end
			if selected then
				local giz0 = self.selectedGizmoMap[ obj ]
				if giz0 then giz0:destroyWithChildrenNow() end
				self.selectedGizmoMap[ obj ] = giz
			else
				local giz0 = self.normalGizmoMap[ obj ]
				if giz0 then giz0:destroyWithChildrenNow() end
				self.normalGizmoMap[ obj ] = giz
				giz:setVisible( self.gizmoVisible )
			end
			self:addChild( giz )
			if obj:isInstance( candy.Actor ) then
				inheritVisible( giz:getProp(), obj:getProp() )
			elseif obj._actor then
				inheritVisible( giz:getProp(), obj._actor:getProp() )
			end
			giz:setTarget( obj )
		end
	end
end

function GizmoManager:setGizmoVisible( vis )
	self.gizmoVisible = vis
	for _, giz in pairs( self.normalGizmoMap ) do
		giz:setVisible( vis )
	end
end


function GizmoManager:isGizmoVisible()
	return self.gizmoVisible
end


function GizmoManager:removeForObject( obj )
	local giz = self.normalGizmoMap[ obj ]
	if giz then
		giz:destroyWithChildrenNow()
		self.normalGizmoMap[ obj ] = nil
	end
end

function GizmoManager:removeForActor( actor )
	for com in pairs( actor.components ) do
		self:removeForObject( com )
	end
	for child in pairs( actor.children ) do
		self:removeForActor( child )
	end
	self:removeForObject( actor )
end

function GizmoManager:clear()
	self:clearChildrenNow()
	self.normalGizmoMap   = {}
	self.selectedGizmoMap = {}
end


function GizmoManager:pickPoint( x,y )
	--TODO
end

function GizmoManager:pickRect( x,y, x1, y1  )
	--TODO
end
