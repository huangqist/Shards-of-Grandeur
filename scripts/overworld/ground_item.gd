extends Interactable
class_name GroundItem

@export var pickedUpItem: PickedUpItem = null
@export var disguiseSprite: Texture = null
@export var storyRequirements: Array[StoryRequirements] = []
@export var startsQuest: Quest = null
@export var invisible: bool = false
@export var particleTextures: Array[Texture2D] = []

@onready var sprite: Sprite2D = get_node('Sprite2D')
@onready var staticBody: StaticBody2D = get_node('StaticBody2D')
@onready var particleEmitter: Particles = get_node('ParticleEmitter')
@onready var pickUpSprite: AnimatedSprite2D = get_node('PickUpSprite')

var disabled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if pickedUpItem == null or pickedUpItem.item == null:
		printerr('GroundItem ERR: no item defined')
		queue_free()
	
	_story_reqs_updated()
	if PlayerResources.playerInfo.has_picked_up(saveName):
		set_disabled(true)
	
	show_pick_up_sprite(false)
	PlayerResources.story_requirements_updated.connect(_story_reqs_updated)
	
	if invisible:
		sprite.texture = null
	elif disguiseSprite != null:
		sprite.texture = disguiseSprite
	else:
		sprite.texture = pickedUpItem.item.itemSprite
	
	if len(particleTextures) > 0:
		var newPreset: ParticlePreset = particleEmitter.preset.duplicate(false)
		newPreset.particleTextures = particleTextures
		particleEmitter.preset = newPreset
	particleEmitter.set_make_particles(true)

func show_pick_up_sprite(showSprite: bool = true):
	pickUpSprite.visible = showSprite
	if showSprite:
		pickUpSprite.play('default')
	else:
		pickUpSprite.stop()

func interact(_args: Array = []):
	if not PlayerResources.playerInfo.has_picked_up(saveName):
		PlayerFinder.player.pick_up(self)

func set_disabled(value: bool):
	disabled = value
	visible = not value
	if disabled:
		staticBody.collision_layer = 0b00
	else:
		staticBody.collision_layer = 0b01

func _on_area_entered(area):
	if not disabled and area.name == 'PlayerEventCollider':
		# add this ground item to the list of ground items the player can pick up
		enter_player_range()
		show_pick_up_sprite()

func _on_area_exited(area):
	if area.name == 'PlayerEventCollider' and self in PlayerFinder.player.interactables:
		# remove item from the running to be picked up
		exit_player_range()
		show_pick_up_sprite(false)

func _story_reqs_updated():
	visible = len(storyRequirements) == 0 # false if any requirements, otherwise true
	for requirement in storyRequirements:
		visible = requirement.is_valid() or visible
	if PlayerResources.playerInfo.has_picked_up(saveName):
		visible = false
	set_disabled(not visible)
	if disabled:
		exit_player_range()
		show_pick_up_sprite(false)

func finished_dialogue():
	var playerPickedUp: bool = false
	if PlayerFinder.player.interactableDialogues[0] is PickedUpItem:
		var pickedUp: PickedUpItem = PlayerFinder.player.interactableDialogues[0] as PickedUpItem
		playerPickedUp = pickedUp.wasPickedUp
		
	if playerPickedUp:
		PlayerResources.playerInfo.pickedUpItems.append(saveName)
		set_disabled(true)
		exit_player_range()
