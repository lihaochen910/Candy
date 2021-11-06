-- import
local UIWidgetModule = require 'candy.ui.light.UIWidget'
local UIWidget = UIWidgetModule.UIWidget
local UIImageRenderer = require 'candy.ui.light.renderers.UIImageRenderer'
local EntityModule = require 'candy.Entity'

---@class UIImage : UIWidget
local UIImage = CLASS: UIImage ( UIWidget )
	:MODEL {
		Field "image" :asset_pre ( getSupportedTextureAssetTypes () ):getset ( "Image" ),
		"----",
		Field "resetSize" :action ( "resetSize" )
	}

EntityModule.registerEntity ( "UIImage", UIImage )

function UIImage:__init ()
	self.image = false ---@type Texture
	self.layoutPolicy = { "expand", "expand" }
	self.trackingPointer = false
end

function UIImage:getDefaultRendererClass ()
	return UIImageRenderer
end

function UIImage:getImage ( t )
	return self.image
end

function UIImage:setImage ( t )
	self.image = t
	self:invalidateContent ()
end

function UIImage:getContentData ( key, role )
	if key == "image" then
		return self.image
	end
end

function UIImage:getMinSizeHint ()
	return 20, 20
end

function UIImage:resetSize ()
	if self.image then
		local tex = self:loadAsset ( self.image )
		self:setSize ( tex:getOutputSize () )
	end
end

return UIImage