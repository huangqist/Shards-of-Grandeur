extends CharacterBody2D
class_name OverworldEnemy

@export var combatant: Combatant
@export var disableMovement: bool = false
@export var maxSpeed: float = 40
@export var runningMaxSpeed: float = 80
@export var overrideSpeeds: bool = false
@export var chaseRange: float = 48
@export var runningChaseRange: float = 96
@export var overrideRanges: bool = false
@export var chaseSwapCooldownSecs: float = 1
@export var patrolling: bool = true
@export var patrolWaitSecs: float = 1.0
@export var enemyData: OverworldEnemyData = OverworldEnemyData.new()

var spawner: EnemySpawner = null
var homePoint: Vector2
var patrolRange: float = 48.0
var despawnRange: float = 960.0
var encounteredPlayer: bool = false
var waitUntilNavReady: bool = false
var runningChaseMode: bool = false
var lastPlayerChaseUpdateTime: float = 0

var encounterColliderOffset: Vector2 = Vector2.ZERO

@onready var enemySprite: AnimatedSprite2D = get_node("AnimatedEnemySprite")
@onready var navAgent: NavigationAgent2D = get_node("NavAgent")
@onready var chaseRangeShape: CollisionShape2D = get_node("ChaseRange/ChaseRangeShape")
@onready var encounterColliderShape: CollisionShape2D = get_node('EnemyEncounterCollider/EncounterColliderShape')
@onready var collisionShape: CollisionShape2D = get_node('CollisionShape')

# NOTE: for saving data, the complete filepath comes from the EnemySpawner itself to preserve spawner state
# so all that needs to be used for save/load functionality is the save_path coming through

func _ready():
	combatant = enemyData.combatant
	enemySprite.sprite_frames = combatant.get_sprite_frames()
	var combatantOverworld: CombatantOverworld = combatant.get_sprite_obj().combatantOverworld
	if combatantOverworld != null:
		if not overrideSpeeds:
			maxSpeed = combatantOverworld.maxSpeed
			runningMaxSpeed = combatantOverworld.runningMaxSpeed
		if not overrideRanges:
			chaseRange = combatantOverworld.chaseRange
			runningChaseRange = combatantOverworld.runningChaseRange
		var colliderRect: RectangleShape2D = collisionShape.shape as RectangleShape2D
		colliderRect.size = combatantOverworld.encounterCollisionSize - Vector2(1, 1) # 1 px smaller than encounter collider
		collisionShape.position = combatantOverworld.encounterCollisionCenter
		var encounterColliderRect: RectangleShape2D = encounterColliderShape.shape as RectangleShape2D
		encounterColliderRect.size = combatantOverworld.encounterCollisionSize
		encounterColliderShape.position = combatantOverworld.encounterCollisionCenter
		encounterColliderOffset = combatantOverworld.encounterCollisionCenter
	
	position = get_point_around_home() # throw out position and load from random point near home
	#position = enemyData.position
	disableMovement = enemyData.disableMovement
	navAgent.navigation_layers = combatant.get_nav_layer()
	navAgent.radius = (max(combatant.get_max_size().x, combatant.get_max_size().y) / 2) - 1
	SignalBus.player_run_toggled.connect(_player_running_changed)
	update_chase_mode(SignalBus.lastPlayerRunVal or enemyData.runningChase)
	update_speed()
	if patrolling:
		get_next_patrol_target()

func _process(delta):
	if spawner != null and (PlayerFinder.player.global_position - global_position).length() > despawnRange:
		spawner.delete_enemy()
		return
	
	if waitUntilNavReady:
		get_next_patrol_target()
	
	if not disableMovement and SceneLoader.mapLoader != null and SceneLoader.mapLoader.mapNavReady and not PlayerFinder.player.disableMovement:
		if not patrolling:
			navAgent.target_position = PlayerFinder.player.position
		var nextPos = navAgent.get_next_path_position()
		var vel = nextPos - position
		if vel.length() > navAgent.max_speed * delta:
			vel = vel.normalized() * navAgent.max_speed * delta
		position += vel
		if vel.x < 0:
			enemySprite.flip_h = false
		if vel.x > 0:
			enemySprite.flip_h = true
			encounterColliderShape.position.x = -1 * encounterColliderOffset.x
			collisionShape.position.x = -1 * encounterColliderOffset.x
		if vel.length() > 0:
			enemySprite.play('walk')
		else:
			enemySprite.play('stand')

func get_next_patrol_target():
	if SceneLoader.mapLoader != null and not SceneLoader.mapLoader.mapNavReady:
		waitUntilNavReady = true
		return
		
	waitUntilNavReady = false
	
	if patrolRange == 0:
		disableMovement = true
		return
		
	navAgent.target_position = get_point_around_home()

func get_point_around_home() -> Vector2:
	# generate random point on unit circle and ensure it's exactly on the circle, multiplied by a random radius
	# all for a random position inside a circle of size `patrolRange` centered around the home point
	var angleRadians = randf_range(0, 2 * PI)
	var radius: float = randf_range(0, patrolRange / 2.0) # range is diameter, so half that
	return homePoint + Vector2(cos(angleRadians), sin(angleRadians)).normalized() * radius

func pause_movement():
	disableMovement = true
	enemySprite.play('stand')

func unpause_movement():
	if patrolRange != 0:
		disableMovement = false

func chase_player():
	patrolling = false
	navAgent.avoidance_enabled = true

func stop_chasing_player():
	patrolling = true
	navAgent.avoidance_enabled = false
	get_next_patrol_target()

func update_chase_mode(playerRunning: bool) -> void:
	runningChaseMode = playerRunning # comment this out to disable running chase mode entirely
	var rangeCircle: CircleShape2D = chaseRangeShape.shape as CircleShape2D
	rangeCircle.radius = (chaseRange if not runningChaseMode else runningChaseRange) + \
			(max(combatant.get_max_size().x, combatant.get_max_size().y) / 2)

func update_speed() -> void:
	navAgent.max_speed = runningMaxSpeed if runningChaseMode and not patrolling else maxSpeed

func _player_running_changed(playerRunning: bool) -> void:
	# if the enemy patrolling, or if it's chasing the player and the player starts to run, update the chase mode
	if patrolling or (not patrolling and playerRunning and not runningChaseMode):
		update_chase_mode(playerRunning)
		update_speed()

func _on_chase_range_area_entered(area):
	if area.name == "PlayerEventCollider":
		chase_player()
		update_speed()
		lastPlayerChaseUpdateTime = Time.get_unix_time_from_system()

func _on_chase_range_area_exited(area):
	if area.name == "PlayerEventCollider":
		stop_chasing_player()
		update_speed()
		var updateTime: float = Time.get_unix_time_from_system()
		lastPlayerChaseUpdateTime = updateTime
		if runningChaseMode:
			await get_tree().create_timer(chaseSwapCooldownSecs).timeout
			if lastPlayerChaseUpdateTime == updateTime and patrolling:
				update_chase_mode(false)
				update_speed()

func _on_nav_agent_navigation_finished():
	await get_tree().create_timer(patrolWaitSecs).timeout
	get_next_patrol_target()

func _on_nav_agent_target_reached():
	await get_tree().create_timer(patrolWaitSecs).timeout
	get_next_patrol_target()

func _on_encounter_collider_area_entered(area):
	if area.name == "PlayerEventCollider" and spawner != null:
		if not PlayerFinder.player.inCutscene:
			# start battle encounter
			spawner.spawnerData.spawnedLastEncounter = true
			PlayerResources.playerInfo.encounter = enemyData.encounter
			encounteredPlayer = true
			PlayerFinder.player.start_battle()
			SceneLoader.pause_autonomous_movers()
		else:
			 # despawn enemy if encountered during a cutscene
			if spawner != null:
				spawner.delete_enemy()
			else:
				queue_free()
