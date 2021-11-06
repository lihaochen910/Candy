-- import
local UIStyleModule = require 'candy.ui.light.UIStyle'
local UIStyleSheet = UIStyleModule.UIStyleSheet

local _BaseStyleSheetSrc = [[
	style 'UIWidget' {
		background_color	= 'black';
		background_material = false;
		font				= 'default';
		font_size        	= 12;
		text_color 			= '#ffffbd';
		text_word_break		= false;
		text_align			= 'left';
		text_align_v		= 'top';
		border_width		= 2;
		border_style		= 'solid';
		border_color		= '#ffffff';
	}

	style 'UILabel' {
		font_size = 21;
		text_font_scale = 1;
		text_color = '#ffffbd';
	}

	style 'UIFrame' {
		background_sprite = image9( 'img/BorderNew.psd' );
		background_color = '#ffffbd';
		focus_cursor = 'none';
	}

	style 'UIButton' {
		text_font = FONT_NORMAL;	
		text_color = '#8B8975';
		text_font_size = 20;
		background_sprite = image9( 'img/button.png' );
		background_color = '#8B8975';
	}
]]

local _BaseStyleSheet = nil

function getBaseStyleSheet ()
	if not _BaseStyleSheet then
		_BaseStyleSheet = UIStyleSheet ()
		_BaseStyleSheet:load ( _BaseStyleSheetSrc )
	end

	return _BaseStyleSheet
end

return {}