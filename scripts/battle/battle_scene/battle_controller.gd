extends Node2D
class_name BattleController

@export var state: BattleState = BattleState.new()

var battleLoaded: bool = false
var battleEnded: bool = false

@onready var tilemap: TileMap = get_node("TileMap")

@onready var combatantNodes: Array[Node] = get_tree().get_nodes_in_group("CombatantNode")
@onready var playerCombatant: CombatantNode = get_node("TileMap/PlayerCombatant")
@onready var minionCombatant: CombatantNode = get_node("TileMap/MinionCombatant")
@onready var enemyCombatant1: CombatantNode = get_node("TileMap/EnemyCombatant1")
@onready var enemyCombatant2: CombatantNode = get_node("TileMap/EnemyCombatant2")
@onready var enemyCombatant3: CombatantNode = get_node("TileMap/EnemyCombatant3")

@onready var battleUI: BattleUI = get_node("BattleCam")
@onready var battlePanels: BattlePanels = get_node("BattleCam/UIPanels")
@onready var turnExecutor: TurnExecutor = get_node("TurnExecutor")

# Called when the node enters the scene tree for the first time.
func _ready():
	battleLoaded = false
	SaveHandler.load_data()
	call_deferred('load_into_battle')

func load_into_battle():
	var newBattle: bool = state.enemyCombatant1 == null
	if newBattle: # new battle
		playerCombatant.combatant = PlayerResources.playerInfo.combatant.copy()
		minionCombatant.combatant = null
		
		if PlayerResources.playerInfo.encounteredName == null or PlayerResources.playerInfo.encounteredName == '':
			PlayerResources.playerInfo.encounteredName = 'ant' # TEMP failsafe - could be improved?
		
		enemyCombatant1.combatant = Combatant.load_combatant_resource(PlayerResources.playerInfo.encounteredName)
		
		var encounteredLv: int = PlayerResources.playerInfo.encounteredLevel
		enemyCombatant1.initialCombatantLv = enemyCombatant1.combatant.stats.level
		enemyCombatant1.combatant.level_up_nonplayer(encounteredLv)
		
		var rngBeginnerNoEnemy: float = randf() - 0.75 + (0.05 * (6 - max(playerCombatant.combatant.stats.level, 6))) if playerCombatant.combatant.stats.level < 10 else 1.0
		# if level < 10, give a 25% chance to have a second combatant + 5% per level up to 50%, before team table calc
		var eCombatant2Idx: int = WeightedThing.pick_item(enemyCombatant1.combatant.teamTable)
		if enemyCombatant1.combatant.teamTable[eCombatant2Idx].string != '' and rngBeginnerNoEnemy > 0.5:
			enemyCombatant2.combatant = Combatant.load_combatant_resource(enemyCombatant1.combatant.teamTable[eCombatant2Idx].string)
			enemyCombatant2.initialCombatantLv = enemyCombatant2.combatant.stats.level
			enemyCombatant2.combatant.level_up_nonplayer(encounteredLv)
		else:
			enemyCombatant2.combatant = null
		
		rngBeginnerNoEnemy = randf() - 0.6 + (0.1 * (6 - max(playerCombatant.combatant.stats.level, 6))) if playerCombatant.combatant.stats.level < 15 else 1.0
		# if level < 15, give a 0% chance to have a third combatant + 10% per level after 1 up to 50%, before team table calc
		var eCombatant3Idx: int = WeightedThing.pick_item(enemyCombatant1.combatant.teamTable)
		if enemyCombatant1.combatant.teamTable[eCombatant3Idx].string != '' and rngBeginnerNoEnemy > 0.5:
			enemyCombatant3.combatant = Combatant.load_combatant_resource(enemyCombatant1.combatant.teamTable[eCombatant3Idx].string)
			enemyCombatant3.initialCombatantLv = enemyCombatant3.combatant.stats.level
			enemyCombatant3.combatant.level_up_nonplayer(encounteredLv)
		else:
			enemyCombatant3.combatant = null
		enemyCombatant3.leftSide = false
	else:
		playerCombatant.combatant = state.playerCombatant
		minionCombatant.combatant = state.minionCombatant
		enemyCombatant1.combatant = state.enemyCombatant1
		enemyCombatant2.combatant = state.enemyCombatant2
		enemyCombatant3.combatant = state.enemyCombatant3
		
	playerCombatant.leftSide = true
	playerCombatant.spriteFacesRight = true
	playerCombatant.role = CombatantNode.Role.ALLY
	
	minionCombatant.leftSide = true
	minionCombatant.role = CombatantNode.Role.ALLY
	
	enemyCombatant1.role = CombatantNode.Role.ENEMY
	enemyCombatant2.role = CombatantNode.Role.ENEMY
	enemyCombatant3.role = CombatantNode.Role.ENEMY
	
	battleUI.commandingMinion = state.commandingMinion
	battleUI.prevMenu = state.prevMenu
	
	for node in combatantNodes:
		node.load_combatant_node()
	
	if state.menu == BattleState.Menu.SUMMON and PlayerResources.inventory.count_of(Item.Type.SHARD) == 0:
		state.menu = BattleState.Menu.PRE_BATTLE
	
	battleUI.set_menu_state(state.menu, false)
	
func summon_minion(shard: Shard):
	minionCombatant.combatant = PlayerResources.minions.get_minion(shard.combatantSaveName)
	minionCombatant.initialCombatantLv = minionCombatant.combatant.stats.level
	minionCombatant.combatant.level_up_nonplayer(playerCombatant.combatant.stats.level)
	minionCombatant.load_combatant_node()

func get_all_combatant_nodes() -> Array[CombatantNode]:
	var allCombatantNodes: Array[CombatantNode] = []
	for node in combatantNodes:
		allCombatantNodes.append(node as CombatantNode)
	return allCombatantNodes

func save_data(save_path):
	if battleEnded:
		state.delete_data(SaveHandler.save_file_location) # same as save_path in save/load data functions
	else:
		state.menu = battleUI.menuState
		state.prevMenu = battleUI.prevMenu
		state.playerCombatant = playerCombatant.combatant
		state.minionCombatant = minionCombatant.combatant
		state.enemyCombatant1 = enemyCombatant1.combatant
		state.enemyCombatant2 = enemyCombatant2.combatant
		state.enemyCombatant3 = enemyCombatant3.combatant
		state.commandingMinion = battleUI.commandingMinion
		state.fobButtonEnabled = battlePanels.flowOfBattle.get_fob_button_enabled()
		state.turnList = turnExecutor.turnQueue.combatants.duplicate(false)
		state.save_data(save_path, state)

func load_data(save_path):
	var newState = state.load_data(save_path)
	if newState != null:
		state = newState
		battlePanels.flowOfBattle.set_fob_button_enabled(state.fobButtonEnabled)
		turnExecutor.turnQueue = TurnQueue.new(state.turnList, false)
		if not battleLoaded:
			battleLoaded = true

func reset_intermediate_state_strs():
	state.calcdStateStrings = []
	state.calcdStateIndex = 0

func end_battle():
	PlayerResources.copy_combatant_to_info(PlayerResources.playerInfo.combatant)
	battleEnded = true
	PlayerResources.playerInfo.combatant.statChanges.reset()
	PlayerResources.playerInfo.combatant.statusEffect = null # clear status after battle (?)
	if minionCombatant.combatant != null:
		minionCombatant.combatant.currentHp = minionCombatant.combatant.stats.maxHp # reset to max HP for next time minion will be summoned
		minionCombatant.combatant.statChanges.reset()
		minionCombatant.combatant.statusEffect = null # clear status after battle (?)
	SaveHandler.save_data()
	tilemap.queue_free() # free tilemap first to avoid tilemap nav layer errors
	SceneLoader.load_overworld()