--------------------------------------------------------------------
---@class PickingManager
local PickingManager = CLASS: PickingManager ()
	:MODEL {}

function PickingManager:__init ()
	self.pickingPropToEntity = {}
	self.entityToPickingProps = {} 
end

function PickingManager:addPickingProp ( srcEntity, prop )
	self.pickingPropToEntity[ prop ] = srcEntity
	local props = self.entityToPickingProps[ srcEntity ]
	if not props then
		props = {}
		self.entityToPickingProps[ srcEntity ] = props
	end
	props[ prop ] = true
end

function PickingManager:removePickingProp ( prop )
	local src = self.pickingPropToEntity[ prop ]
	self.pickingPropToEntity[ prop ] = nil
	local props = self.entityToPickingProps[ src ]
	if props then props[ prop ] = nil end
end

function PickingManager:removeEntity ( srcEntity )
	local props = self.entityToPickingProps[ srcEntity ]
	if not props then return end
	local pickingPropToEntity = self.pickingPropToEntity
	for prop in pairs ( props ) do
		pickingPropToEntity[ prop ] = nil
	end
	self.entityToPickingProps[ srcEntity ] = nil
end


function PickingManager:setTargetScene ( scene )
	self.targetScene = scene
	self:scanScene ()
end

function PickingManager:refresh ()
	self:clear ()
	self:scanScene ()
end

function PickingManager:scanScene ()
	local entities = table.simplecopy ( self.targetScene.entities )
	for e in pairs ( entities ) do
		self:buildForEntity ( e, false )
	end
end

function PickingManager:onEntityEvent ( ev, entity, com )
	if ev == 'clear' then
		self:clear ()
		return
	end

	if ev == 'add' then
		self:buildForEntity ( entity ) 
	elseif ev == 'remove' then
		self:removeForEntity ( entity )
	elseif ev == 'attach' then
		if self:isEntityPickable ( entity ) then
			self:buildForObject ( com, entity )
		end
	elseif ev == 'detach' then
		self:removeForObject ( com, entity )
	end

end

function PickingManager:isEntityPickable ( entity )
	if not entity:isVisible () then return false end
	local defaultPickable = true
	if entity.FLAG_EDITOR_OBJECT then
		defaultPickable = false
	end

	local pickable
	local isPickable = entity.isPickable
	if isPickable then
		pickable = isPickable ( entity )
	else
		pickable = defaultPickable
	end
	
	return pickable
end


function PickingManager:buildForEntity ( entity )
	if not self:isEntityPickable ( entity ) then return end
	self:buildForObject ( entity, entity )
	for com in pairs ( entity.components ) do
		if not  ( com.FLAG_EDITOR_OBJECT ) then
			self:buildForObject ( com, entity )
		end
	end
	for child in pairs ( entity.children ) do
		self:buildForEntity ( child )
	end
end

function PickingManager:buildForObject ( obj, srcEntity )
	getPickingProp = obj.getPickingProp
	if getPickingProp then
		local prop = getPickingProp ( obj )
		if prop then
			self:addPickingProp ( srcEntity, prop )
		end
	end
end

function PickingManager:removeForObject ( obj, srcEntity )
	getPickingProp = obj.getPickingProp
	if getPickingProp then
		local prop = getPickingProp ( obj )
		if prop then
			self:removePickingProp ( prop )
		end
	end
end

function PickingManager:removeForEntity ( entity )
	for com in pairs ( entity.components ) do
		self:removeForObject ( com, entity )
	end
	for child in pairs ( entity.children ) do
		self:removeForEntity ( child )
	end
	self:removeForObject ( entity, entity )
	self:removeEntity ( entity )
end

function PickingManager:clear ()
	self.pickingPropToEntity = {}
	self.entityToPickingProps = {}
end

local defaultSortMode = MOAILayer.SORT_Z_ASCENDING

function PickingManager:getVisibleLayers ()
	local layers = {}
	for i, layer in ipairs ( self.targetScene.layers ) do
		local srcLayer = layer.source
		if srcLayer:isEditorVisible () then			
			table.insert ( layers, layer )
		end
	end
	return table.reversed ( layers )
end

function PickingManager:findBestPickingTarget ( e, pickingChild )
	local e0 = e
	--proto
	if e.__proto_history then
		while e do
			if e.PROTO_INSTANCE_STATE then break end
			e = e.parent
		end
	else
		while e do
			local name = e:getName ()
			if name and name:sub ( 1, 1 ) == '_' then
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

function PickingManager:correctPicked ( picked )
	--1.convert parent+child selection to parent only
	picked = findTopLevelEntities ( picked )
	--2.select instance root 
	local picked1 = {}
	for e in pairs ( picked ) do
		e = self:findBestPickingTarget ( e )
		if e then
			picked1[ e ] = true
		end
	end
	return picked1
end

function PickingManager:pickPoint ( x, y, pad )
	-- print ( 'picking', x, y )
	local pickingPropToEntity = self.pickingPropToEntity

	for i, layer in ipairs ( self:getVisibleLayers () ) do
		local partition = layer:getPartition ()
		local result = { partition:propListForRay ( x, y, -1000, 0, 0, 1, defaultSortMode ) }
		for i, prop in ipairs ( result ) do
			local entity = pickingPropToEntity[ prop ]
			if entity and entity.getPickingTarget then
				entity = entity:getPickingTarget ()
			end
			if entity and entity:isVisible () and  ( not entity:isEditLocked () ) then --TODO: sorting & sub picking
				-- print ( entity:getName () )
				entity = self:findBestPickingTarget ( entity, true )
				return { entity }
			end
		end
	end
	return {}
end

function PickingManager:pickRect ( x0, y0, x1, y1, pad )
	-- print ( 'picking rect', x0, y0, x1, y1 )
	local picked = {}
	local pickingPropToEntity = self.pickingPropToEntity

	for i, layer in ipairs ( self:getVisibleLayers () ) do
		local partition = layer:getPartition ()
		local result = { partition:propListForRect ( x0, y0, x1, y1, defaultSortMode ) }
		for i, prop in ipairs ( result ) do
			local entity = pickingPropToEntity[ prop ]
			if entity then --TODO: sub picking
				if entity.getPickingTarget then
					entity = entity:getPickingTarget ()
				end
				if entity:isVisible () and  ( not entity:isEditLocked ()) then
					picked[ entity ] = true
				end
				-- print ( entity:getName () )
			end
		end
	end
	picked = self:correctPicked ( picked )
	return table.keys ( picked )
end

function PickingManager:pickBox ( x0, y0, z0, x1, y1, z1, pad )
	-- print ( 'picking rect', x0, y0, x1, y1 )
	local picked = {}
	local pickingPropToEntity = self.pickingPropToEntity

	for i, layer in ipairs ( self:getVisibleLayers () ) do
		local partition = layer:getPartition ()
		local result = { partition:propListForBox ( x0, y0, z0, x1, y1, z1, defaultSortMode ) }
		for i, prop in ipairs ( result ) do
			local entity = pickingPropToEntity[ prop ]
			if entity then --TODO: sub picking
				if entity.getPickingTarget then
					entity = entity:getPickingTarget ()
				end
				if entity:isVisible () and  ( not entity:isEditLocked ()) then
					picked[ entity ] = true
				end
				-- print ( entity:getName () )
			end
		end
	end
	picked = self:correctPicked ( picked )
	return table.keys ( picked )
end

return PickingManager