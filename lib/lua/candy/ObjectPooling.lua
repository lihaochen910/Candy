local isInstance = isInstance
local insert = table.insert
local remove = table.remove

---@class ObjectPool
local ObjectPool = CLASS: ObjectPool ()
	:MODEL {}

function ObjectPool:__init ( targetClass, minSize, maxSize )
	assert ( isClass ( targetClass ), "Class expected" )

	local pool = {}
	self.pool = pool
	self.minPoolSize = minSize or 0
	self.maxPoolSize = maxSize or 64
	self.targetClass = targetClass

	local support = type ( targetClass.onPoolIn ) == "function" and type ( targetClass.onPoolOut ) == "function"
	assert ( support, "no ObjectPool function found in " .. tostring ( targetClass ) )
end

function ObjectPool:push ( object )
	local size = self:getSize()

	if self.maxPoolSize <= size then
		return false
	end

	object:onPoolIn ()
	insert ( self.pool, 1, object )

	return true
end

function ObjectPool:pop ()
	local object = remove ( self.pool, 1 )

	if object then
		object:onPoolOut ()
	end

	return object
end

function ObjectPool:request ()
	local o = self:pop ()

	if o then
		return o
	end

	o = self.targetClass ()
	return o
end

function ObjectPool:getSize ()
	return #self.pool
end

function ObjectPool:isEmpty ()
	return self:getSize () == 0
end

function ObjectPool:isFull ()
	return self.maxPoolSize <= self:getSize ()
end

function ObjectPool:clear ()
	self.pool = {}
end

function ObjectPool:fill ( size, ... )
	size = size or self.minPoolSize - self:getSize ()

	if size <= 0 then
		return
	end

	local targetClass = self.targetClass

	for i = 1, size do
		local o = targetClass ( ... )
		self:push ( o )
	end
end

return ObjectPool