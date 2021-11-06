-- import
local UIWidgetModule = require 'candy.ui.light.UIWidget'
local UIWidget = UIWidgetModule.UIWidget
local ComponentModule = require 'candy.Component'

-- module
local UIComboBoxModule = {}

--------------------------------------------------------------------
-- UIComboBoxDataItem
--------------------------------------------------------------------
---@class UIComboBoxDataItem
local UIComboBoxDataItem = CLASS: UIComboBoxDataItem ()
	:MODEL {}

function UIComboBoxDataItem:__init ( text, data )
	self.idx = false
	self.text = text
	self.data = data
end


--------------------------------------------------------------------
-- UIComboBoxDataItem
--------------------------------------------------------------------
---@class UIComboBox : UIWidget
local UIComboBox = CLASS: UIComboBox ( UIWidget )
	:MODEL {}
	:SIGNAL ( {
		selection_changed = "onSelectionChanged"
	} )

ComponentModule.registerComponent ( "UIComboBox", UIComboBox )

function UIComboBox:__init ()
	self.currentOption = 0
	self.items = {}
end

function UIComboBox:clear ()
	self.items = {}
	self:refresh ()
end

function UIComboBox:getSelection ()
end

function UIComboBox:refresh ()
end

function UIComboBox:onSelectionChanged ( selection )
end


UIComboBoxModule.UIComboBoxDataItem = UIComboBoxDataItem
UIComboBoxModule.UIComboBox = UIComboBox

return UIComboBoxModule