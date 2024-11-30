@tool
extends Resource
class_name StoryRequirements

@export_category("Acts")

## 0 == Prologue
@export var minAct: int = 0

## 0 == Prologue. -1 == no max
@export var maxAct: int = -1

@export_category("Stats")

## minimum stats required (only stat categories and level are checked in this object). null == no min stat requirements
@export var minStats: Stats = null

## maximum stats allowed. null for no max, -1 for a stat category or level == no max for that category
@export var maxStats: Stats = null

@export_category("Prerequisites")

## specified by "<Quest Name>" for completion of the whole quest, or "<Quest Name>#<Step Name>" for a specific step
@export var prereqQuests: Array[String] = []

## specified by a cutscene ID
@export var prereqCutscenes: Array[String] = []

## specified by "<NPC ID>#<dialogue ID>"
@export var prereqDialogues: Array[String] = []

## specified by "<map name>"
@export var prereqPlacesVisited: Array[String] = []

## specified by "<static encounter ID>"
@export var prereqSpecialBattles: Array[String] = []

## specified by "<enemy save name>"
@export var prereqDefeatedEnemies: Array[String] = []

## specified by "<puzzle ID>"
@export var prereqPuzzles: Array[String] = []

## specified by "<base combatant save name>#<evolution save name>"
@export var prereqDiscoveredEvolutions: Array[String] = []

## specified by "<follower ID>"
@export var prereqHavingFollowers: Array[String] = []

@export var prereqHasItems: Array[InventorySlot] = []

@export_category("Invalidations")

## specified by "<Quest Name>" for completion of the whole quest, or "<Quest Name>#<Step Name>" for a specific step
@export var invalidAfterCompletingQuests: Array[String] = []

## specified by "<Quest Name>" for completion of the whole quest, or "<Quest Name>#<Step Name>" for a specific step
@export var invalidAfterFailingQuests: Array[String] = []

## specified by a cutscene ID
@export var invalidAfterCutscenes: Array[String] = []

## specified by "<NPC ID>#<dialogue ID>"
@export var invalidAfterDialogues: Array[String] = []

## specified by "<map name>"
@export var invalidAfterVistingPlaces: Array[String] = []

## specified by "<static encounter ID>"
@export var invalidAfterSpecialBattles: Array[String] = []

## specified by "<puzzle ID>"
@export var invalidAfterSolvingPuzzles: Array[String] = []

## specified by "<follower ID>"
@export var invalidFromHavingFollowers: Array[String] = []

@export var invalidFromHavingItems: Array[InventorySlot] = []

func _init(
	i_minAct: int = 0,
	i_maxAct: int = -1,
	i_minStats: Stats = null,
	i_maxStats: Stats = null,
	i_prereqQuests: Array[String] = [],
	i_prereqCutscenes: Array[String] = [],
	i_prereqDialogues: Array[String] = [],
	i_prereqPlaces: Array[String] = [],
	i_prereqBattles: Array[String] = [],
	i_prereqDefeatedEnemies: Array[String] = [],
	i_prereqPuzzles: Array[String] = [],
	i_prereqEvos: Array[String] = [],
	i_prereqFollowers: Array[String] = [],
	i_prereqItems: Array[InventorySlot] = [],
	i_invalidCompletedQuests: Array[String] = [],
	i_invalidFailedQuests: Array[String] = [],
	i_invalidCutscenes: Array[String] = [],
	i_invalidDialogues: Array[String] = [],
	i_invalidPlacesVisited: Array[String] = [],
	i_invalidBattles: Array[String] = [],
	i_invalidPuzzles: Array[String] = [],
	i_invalidFollowers: Array[String] = [],
	i_invalidItems: Array[InventorySlot] = [],
):
	minAct = i_minAct
	maxAct = i_maxAct
	minStats = i_minStats
	maxStats = i_maxStats
	prereqQuests = i_prereqQuests
	prereqCutscenes = i_prereqCutscenes
	prereqDialogues = i_prereqDialogues
	prereqPlacesVisited = i_prereqPlaces
	prereqSpecialBattles = i_prereqBattles
	prereqDefeatedEnemies = i_prereqDefeatedEnemies
	prereqPuzzles = i_prereqPuzzles
	prereqDiscoveredEvolutions = i_prereqEvos
	prereqHavingFollowers = i_prereqFollowers
	prereqHasItems = i_prereqItems
	invalidAfterCompletingQuests = i_invalidCompletedQuests
	invalidAfterFailingQuests = i_invalidFailedQuests
	invalidAfterCutscenes = i_invalidCutscenes
	invalidAfterDialogues = i_invalidDialogues
	invalidAfterVistingPlaces = i_invalidPlacesVisited
	invalidAfterSpecialBattles = i_invalidBattles
	invalidAfterSolvingPuzzles = i_invalidPuzzles
	invalidFromHavingFollowers = i_invalidFollowers
	invalidFromHavingItems = i_invalidItems

func is_valid() -> bool:
	if Engine.is_editor_hint():
		return true
	
	if PlayerResources.questInventory.currentAct < minAct or (maxAct >= 0 and PlayerResources.questInventory.currentAct > maxAct):
		return false
	
	if minStats != null:
		if PlayerResources.playerInfo.stats.level < minStats.level or \
				PlayerResources.playerInfo.stats.physAttack < minStats.physAttack or \
				PlayerResources.playerInfo.stats.magicAttack < minStats.magicAttack or \
				PlayerResources.playerInfo.stats.affinity < minStats.affinity or \
				PlayerResources.playerInfo.stats.resistance < minStats.resistance or \
				PlayerResources.playerInfo.stats.speed < minStats.speed:
			return false
	
	if maxStats != null:
		if (PlayerResources.playerInfo.stats.level > maxStats.level and maxStats.level >= 0) or \
				(PlayerResources.playerInfo.stats.physAttack > maxStats.physAttack and maxStats.physAttack >= 0) or \
				(PlayerResources.playerInfo.stats.magicAttack > maxStats.magicAttack and maxStats.magicAttack >= 0) or \
				(PlayerResources.playerInfo.stats.affinity > maxStats.affinity and maxStats.affinity >= 0) or \
				(PlayerResources.playerInfo.stats.resistance > maxStats.resistance and maxStats.resistance >= 0) or \
				(PlayerResources.playerInfo.stats.speed > maxStats.speed and maxStats.speed >= 0):
			return false
	
	if not PlayerResources.questInventory.has_completed_prereqs(prereqQuests):
		return false
	
	for cutscene: String in prereqCutscenes:
		if not PlayerResources.playerInfo.has_seen_cutscene(cutscene):
			return false
	
	for dialogue: String in prereqDialogues:
		var npcSaveName = dialogue.split('#')[0]
		var dialogueId = dialogue.split('#')[1]
		if not PlayerResources.playerInfo.has_seen_dialogue(npcSaveName, dialogueId):
			return false
	
	for place: String in prereqPlacesVisited:
		if not PlayerResources.playerInfo.has_visited_place(place):
			return false
	
	for battle: String in prereqSpecialBattles:
		if not PlayerResources.playerInfo.has_completed_special_battle(battle):
			return false
			
	for enemy: String in prereqDefeatedEnemies:
		if not PlayerResources.playerInfo.has_defeated_enemy(enemy):
			return false
	
	for puzzle: String in prereqPuzzles:
		if not PlayerResources.playerInfo.has_solved_puzzle(puzzle):
			return false
	
	for fullEvoSaveName: String in prereqDiscoveredEvolutions:
		if not PlayerResources.playerInfo.has_found_evolution(fullEvoSaveName):
			return false
	
	for followerId: String in prereqHavingFollowers:
		if not PlayerResources.playerInfo.has_active_follower(followerId):
			return false
	
	for inventorySlot: InventorySlot in prereqHasItems:
		var slot: InventorySlot = PlayerResources.inventory.get_slot_for_item(inventorySlot.item)
		if slot != null:
			if slot.count < inventorySlot.count:
				return false
		else:
			return false
	
	if PlayerResources.questInventory.has_reached_status_for_one_quest_of(invalidAfterCompletingQuests, QuestTracker.Status.COMPLETED):
		return false
		
	if PlayerResources.questInventory.has_reached_status_for_one_quest_of(invalidAfterFailingQuests, QuestTracker.Status.FAILED):
		return false
	
	for cutscene: String in invalidAfterCutscenes:
		if PlayerResources.playerInfo.has_seen_cutscene(cutscene):
			return false
	
	for dialogue: String in invalidAfterDialogues:
		var npcSaveName = dialogue.split('#')[0]
		var dialogueId = dialogue.split('#')[1]
		if PlayerResources.playerInfo.has_seen_dialogue(npcSaveName, dialogueId):
			return false
	
	for place: String in invalidAfterVistingPlaces:
		if PlayerResources.playerInfo.has_visited_place(place):
			return false
	
	for battle: String in invalidAfterSpecialBattles:
		if PlayerResources.playerInfo.has_completed_special_battle(battle):
			return false
			
	for puzzle: String in invalidAfterSolvingPuzzles:
		if PlayerResources.playerInfo.has_solved_puzzle(puzzle):
			return false
	
	for followerId: String in invalidFromHavingFollowers:
		if PlayerResources.playerInfo.has_active_follower(followerId):
			return false
	
	for inventorySlot: InventorySlot in invalidFromHavingItems:
		var slot: InventorySlot = PlayerResources.inventory.get_slot_for_item(inventorySlot.item)
		if slot != null:
			if slot.count >= inventorySlot.count:
				return false
	
	return true
