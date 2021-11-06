-- module
local UIResourceManagerModule = {}

--------------------------------------------------------------------
-- UIResourceProvider
--------------------------------------------------------------------
---@class UIResourceProvider
local UIResourceProvider = CLASS: UIResourceProvider ()
	:MODEL {}

local providerSeq = 0

function UIResourceProvider:__init ()
	self.priority = 0
	self.__seq = providerSeq
	providerSeq = providerSeq + 1
end

function UIResourceProvider:request ( id )
end

--------------------------------------------------------------------
-- UIResourceManager
--------------------------------------------------------------------
---@class UIResourceManager
local UIResourceManager = CLASS: UIResourceManager ()

function UIResourceManager:__init ()
	self.resourceProviders = {}
	self._global = false
end

function UIResourceManager:registerProvider ( resType, provider, priority )
	local list = self.resourceProviders[ resType ]

	if not list then
		list = {}
		self.resourceProviders[ resType ] = list
	end

	provider.priority = priority or 0

	table.insert ( list, provider )
	table.sort ( list, function  ( a, b )
		local pa = a.priority
		local pb = b.priority

		if pa == pb then
			return b.__seq < a.__seq
		end

		return pb < pa
	end )
end

function UIResourceManager:request ( resType, id )
	local list = self.resourceProviders[ resType ]

	if list then
		for i, provider in ipairs ( list ) do
			local res = provider:request ( id )

			if res then
				return res
			end
		end
	end

	if not self._global then
		return getUIManager ():requestResource ( resType, id )
	end
end


UIResourceManagerModule.UIResourceProvider = UIResourceProvider
UIResourceManagerModule.UIResourceManager = UIResourceManager

return UIResourceManagerModule