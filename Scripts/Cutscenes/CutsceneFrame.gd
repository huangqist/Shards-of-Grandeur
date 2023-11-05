extends Resource
class_name CutsceneFrame

@export var frameLength: float = 1
@export var actorTweens: Array[ActorTween] = []
@export var actorAnims: Array[ActorSpriteAnim] = []
@export var endTextBoxSpeaker: String = ''
@export var endTextBoxTexts: Array[String] = []
@export var endTextBoxPauses: bool = true
var endTextTriggered: bool = false

func _init(
	i_frameLength = 1,
	i_actorTweens: Array[ActorTween] = [],
	i_actorAnims: Array[ActorSpriteAnim] = [],
	i_endTextSpeaker = '',
	i_endTexts: Array[String] = [],
	i_endTextPauses = true
):
	frameLength = i_frameLength
	actorTweens = i_actorTweens
	actorAnims = i_actorAnims
	endTextBoxSpeaker = i_endTextSpeaker
	endTextBoxTexts = i_endTexts
	endTextBoxPauses = i_endTextPauses
	endTextTriggered = false
	
func get_text_was_triggered() -> bool:
	return endTextTriggered

func set_text_was_triggered(triggered: bool = true):
	endTextTriggered = triggered
	
