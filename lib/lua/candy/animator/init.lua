

EnumAnimCurveTweenMode = {
	{
		"constant",
		MOAIAnimCurveEX.SPAN_MODE_CONSTANT
	},
	{
		"linear",
		MOAIAnimCurveEX.SPAN_MODE_LINEAR
	},
	{
		"bezier",
		MOAIAnimCurveEX.SPAN_MODE_BEZIER
	}
}

require ( "candy.animator.AnimatorTargetId" )
require ( "candy.animator.AnimatorState" )
require ( "candy.animator.AnimatorClip" )
require ( "candy.animator.AnimatorClipTree" )
require ( "candy.animator.AnimatorData" )
require ( "candy.animator.Animator" )
require ( "candy.animator.EmbedAnimator" )
require ( "candy.animator.AnimatorEditorSupport" )
require ( "candy.animator.AnimatorEventTrack" )
require ( "candy.animator.AnimatorValueTrack" )
require ( "candy.animator.CustomAnimatorTrack" )
require ( "candy.animator.AnimatorKeyVec" )
require ( "candy.animator.AnimatorKeyColor" )
require ( "candy.animator.AnimatorTrackAttr" )
require ( "candy.animator.AnimatorTrackField" )
require ( "candy.animator.AnimatorTrackFieldNumber" )
require ( "candy.animator.AnimatorTrackFieldInt" )
require ( "candy.animator.AnimatorTrackFieldVec" )
require ( "candy.animator.AnimatorTrackFieldColor" )
require ( "candy.animator.AnimatorTrackFieldDiscrete" )
require ( "candy.animator.AnimatorTrackFieldBoolean" )
require ( "candy.animator.AnimatorTrackFieldString" )
require ( "candy.animator.AnimatorTrackFieldEnum" )
require ( "candy.animator.AnimatorTrackFieldAsset" )

function getAnimatorTrackFieldClass ( ftype )
	if ftype == "number" then
		return AnimatorTrackFieldNumber
	elseif ftype == "int" then
		return AnimatorTrackFieldInt
	elseif ftype == "boolean" then
		return AnimatorTrackFieldBoolean
	elseif ftype == "string" then
		return AnimatorTrackFieldString
	elseif ftype == "vec2" then
		return AnimatorTrackFieldVec2
	elseif ftype == "vec3" then
		return AnimatorTrackFieldVec3
	elseif ftype == "color" then
		return AnimatorTrackFieldColor
	elseif ftype == "@asset" then
		return AnimatorTrackFieldAsset
	elseif ftype == "@enum" then
		return AnimatorTrackFieldEnum
	end

	return false
end

require ( "candy.animator.AnimatorClipTreeNodePlay" )
require ( "candy.animator.AnimatorClipTreeNodeThrottle" )
require ( "candy.animator.AnimatorClipTreeNodeSelect" )
require ( "candy.animator.AnimatorClipTreeNodeQueueSelect" )
require ( "candy.animator.tracks.AnimatorAnimatorTrack" )
require ( "candy.animator.tracks.EntityMsgAnimatorTrack" )
require ( "candy.animator.tracks.ScriptAnimatorTrack" )
require ( "candy.animator.AnimatorFSM" )
