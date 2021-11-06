
---@class SimpleAnimator : Animator
local SimpleAnimator = CLASS: SimpleAnimator ( Animator )
	:MODEL {
		Field ( "data" ):asset ( "animator_data" ):no_edit (),
		Field ( "embedData" ):string ()
	}

return SimpleAnimator