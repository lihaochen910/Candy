module 'candy_edit'

--------------------------------------------------------------------

CLASS: PickingManager ()
	:MODEL{}

function PickingManager:__init()
	self.pickingPropToActor = {}
	self.actorToPickingProps = {} 
end

function PickingManager:addPickingProp( srcActor, prop )
	self.pickingPropToActor[ prop ] = srcActor
	local props = self.actorToPickingProps[ srcActor ]
	if not props then
		props = {}
		self.actorToPickingProps[ srcActor ] = props
	end
	props[ prop ] = true
end

function PickingManager:removePickingProp( prop )
	local src = self.pickingPropToActor[ prop ]
	self.pickingPropToActor[ prop ] = nil
	local props = self.actorToPickingProps[ src ]
	if props then props[ prop ] = nil end
end

function PickingManager:removeActor( srcActor )
	local props = self.actorToPickingProps[ srcActor ]
	if not props then return end
	local pickingPropToActor = self.pickingPropToActor
	for prop in pairs( props ) do
		pickingPropToActor[ prop ] = nil
	end
	self.actorToPickingProps[ srcActor ] = nil
end


function PickingManager:setTargetScene( scene )
	self.targetScene = scene
	self:scanScene()
end

function PickingManager:refresh()
	self:clear()
	self:scanScene()
end

function PickingManager:scanScene()
	local actors = table.simplecopy( self.targetScene.actors )
	for e in pairs( actors ) do
		self:buildForActor( e, false )
	end
end

function PickingManager:onActorEvent( ev, actor, com )
	if ev == 'clear' then
		self:clear()
		return
	end

	if ev == 'add' then
		self:buildForActor( actor ) 
	elseif ev == 'remove' then
		self:removeForActor( actor )
	elseif ev == 'attach' then
		if self:isActorPickable( actor ) then
			self:buildForObject( com, actor )
		end
	elseif ev == 'detach' then
		self:removeForObject( com, actor )
	end

end

function PickingManager:isActorPickable( actor )
	if not actor:isVisible() then return false end
	local defaultPickable = true
	if actor.FLAG_EDITOR_OBJECT then
		defaultPickable = false
	end

	local pickable
	local isPickable = actor.isPickable
	if isPickable then
		pickable = isPickable( actor )
	else
		pickable = defaultPickable
	end
	
	return pickable
end


function PickingManager:buildForActor( actor )
	if not self:isActorPickable( actor ) then return end
	self:buildForObject( actor, actor )
	for com in pairs( actor.components ) do
		if not ( com.FLAG_EDITOR_OBJECT ) then
			self:buildForObject( com, actor )
		end
	end
	for child in pairs( actor.children ) do
		self:buildForActor( child )
	end
end

function PickingManager:buildForObject( obj, srcActor )
	getPickingProp = obj.getPickingProp
	if getPickingProp then
		local prop = getPickingProp( obj )
		if prop then
			self:addPickingProp( srcActor, prop )
		end
	end
end

function PickingManager:removeForObject( obj, srcActor )
	getPickingProp = obj.getPickingProp
	if getPickingProp then
		local prop = getPickingProp( obj )
		if prop then
			self:removePickingProp( prop )
		end
	end
end

function PickingManager:removeForActor( actor )
	for com in pairs( actor.components ) do
		self:removeForObject( com, actor )
	end
	for child in pairs( actor.children ) do
		self:removeForActor( child )
	end
	self:removeForObject( actor, actor )
	self:removeActor( actor )
end

function PickingManager:clear()
	self.pickingPropToActor = {}
	self.actorToPickingProps = {}
end

local defaultSortMode = MOAILayer.SORT_Z_ASCENDING

function PickingManager:getVisibleLayers()
	local layers = {}
	for i, layer in ipairs( self.targetScene.layers ) do
		local srcLayer = layer.source
		if srcLayer:isEditorVisible() then			
			table.insert( layers, layer )
		end
	end
	return table.reversed( layers )
end

function PickingManager:findBestPickingTarget( e, pickingChild )
	local e0 = e
	--proto
	if e.__proto_history then
		while e do
			if e.PROTO_INSTANCE_STATE then break end
			e = e.parent
		end
	else
		while e do
			local name = e:getName()
			if name and name:sub(1,1) == '_' then
				if not e.parent then break end
				e = e.parent
			else
				break
			end
		end
	end
	--internal flag check
	local p = e
	while p do
		if p.FLAG_INTERNAL then e = p.parent end
		p = p.parent
	end
	if pickingChild then
		
	end
	return e
end

function PickingManager:correctPicked( picked )
	--1.convert parent+child selection to parent only
	picked = findTopLevelEntities( picked )
	--2.select instance root 
	local picked1 = {}
	for e in pairs( picked ) do
		e = self:findBestPickingTarget( e )
		if e then
			picked1[ e ] = true
		end
	end
	return picked1
end

function PickingManager:pickPoint( x, y, pad )
	-- print( 'picking', x, y )
	local pickingPropToActor = self.pickingPropToActor

	for i, layer in ipairs( self:getVisibleLayers() ) do
		local partition = layer:getPartition()
		local result = { partition:propListForRay( x, y, -1000, 0, 0, 1, defaultSortMode ) }
		for i, prop in ipairs( result ) do
			local actor = pickingPropToActor[ prop ]
			if actor and actor.getPickingTarget then
				actor = actor:getPickingTarget()
			end
			if actor and actor:isVisible() and ( not actor:isEditLocked() ) then --TODO: sorting & sub picking
				-- print( actor:getName() )
				actor = self:findBestPickingTarget( actor, true )
				return { actor }
			end
		end
	end
	return {}
end

function PickingManager:pickRect( x0, y0, x1, y1, pad )
	-- print( 'picking rect', x0, y0, x1, y1 )
	local picked = {}
	local pickingPropToActor = self.pickingPropToActor

	for i, layer in ipairs( self:getVisibleLayers() ) do
		local partition = layer:getPartition()
		local result = { partition:propListForRect( x0, y0, x1, y1, defaultSortMode ) }
		for i, prop in ipairs( result ) do
			local actor = pickingPropToActor[ prop ]
			if actor then --TODO: sub picking
				if actor.getPickingTarget then
					actor = actor:getPickingTarget()
				end
				if actor:isVisible() and ( not actor:isEditLocked()) then
					picked[ actor ] = true
				end
				-- print( actor:getName() )
			end
		end
	end
	picked = self:correctPicked( picked )
	return table.keys( picked )
end

function PickingManager:pickBox( x0, y0, z0, x1, y1, z1, pad )
	-- print( 'picking rect', x0, y0, x1, y1 )
	local picked = {}
	local pickingPropToActor = self.pickingPropToActor

	for i, layer in ipairs( self:getVisibleLayers() ) do
		local partition = layer:getPartition()
		local result = { partition:propListForBox( x0, y0, z0, x1, y1, z1, defaultSortMode ) }
		for i, prop in ipairs( result ) do
			local actor = pickingPropToActor[ prop ]
			if actor then --TODO: sub picking
				if actor.getPickingTarget then
					actor = actor:getPickingTarget()
				end
				if actor:isVisible() and ( not actor:isEditLocked()) then
					picked[ actor ] = true
				end
				-- print( actor:getName() )
			end
		end
	end
	picked = self:correctPicked( picked )
	return table.keys( picked )
end
