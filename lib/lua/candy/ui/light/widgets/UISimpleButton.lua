-- import
local UIButton = require 'candy.ui.light.widgets.UIButton'
local EntityModule = require 'candy.Entity'

---@class UISimpleButton : UIButton
local UISimpleButton = CLASS: UISimpleButton ( UIButton )
	:MODEL {}

function UISimpleButton:getMinSizeHint ()
	return 80, 40
end

EntityModule.registerEntity ( "UISimpleButton", UISimpleButton )

return UISimpleButton