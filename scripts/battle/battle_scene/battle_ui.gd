extends Camera2D
class_name BattleUI

@export var menuState: BattleState.Menu = BattleState.Menu.SUMMON
@export var commandingMinion: bool = false
@export var battleController: BattleController

var commandingCombatant: CombatantNode = null
var prevMenu: BattleState.Menu = BattleState.Menu.SUMMON
var playerWins: bool = true
var escapes: bool = false

var previousFocus: Control = null
var fobFocusMode: bool = false

@onready var summonMenu: SummonMenu = get_node_or_null("BattleTextBox/TextContainer/MarginContainer/Summon")
@onready var allCommands: AllCommands = get_node_or_null("BattleTextBox/TextContainer/MarginContainer/AllCommands")
@onready var moves: MovesMenu = get_node_or_null("BattleTextBox/TextContainer/MarginContainer/Moves")
@onready var targets: TargetsMenu = get_node_or_null("BattleTextBox/TextContainer/MarginContainer/Targets")
@onready var surge: SurgeMenu = get_node_or_null('BattleTextBox/TextContainer/MarginContainer/Surge')
@onready var results: Results = get_node_or_null("BattleTextBox/TextContainer/MarginContainer/Results")
@onready var battleComplete: BattleCompleteMenu = get_node_or_null("BattleTextBox/TextContainer/MarginContainer/BattleComplete")

@onready var battlePanels: BattlePanels = get_node_or_null("UIPanels")
@onready var summonMinionPanel: SummonMinionPanel = get_node_or_null("UIPanels/SummonMinionPanel")
@onready var inventoryPanel: InventoryMenu = get_node_or_null("UIPanels/InventoryPanelNode")
@onready var statsPanel: StatsMenu = get_node_or_null("UIPanels/StatsPanelNode")

func _ready():
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	
func set_menu_state(newState: BattleState.Menu, savePrevState: bool = true):
	if savePrevState:
		prevMenu = menuState
	menuState = newState
	commandingCombatant = battleController.minionCombatant if commandingMinion else battleController.playerCombatant
	apply_menu_state()

func apply_menu_state():
	summonMenu.visible = menuState == BattleState.Menu.SUMMON
	if summonMenu.visible:
		summonMenu.initial_focus()
	
	if prevMenu == BattleState.Menu.SUMMON: # if PREVIOUS menu was summoning, reset the filter
		inventoryPanel.selectedFilter = Item.Type.ALL
		battlePanels.flowOfBattle.set_fob_button_enabled() # show the FoB button again
	
	allCommands.visible = menuState == BattleState.Menu.ALL_COMMANDS or menuState == BattleState.Menu.ITEMS
	if allCommands.visible:
		allCommands.commandingMinion = commandingMinion
		allCommands.commandingCombatant = commandingCombatant
		allCommands.load_all_commands()
	if menuState == BattleState.Menu.ITEMS:
		open_inventory(false)
	
	moves.visible = menuState == BattleState.Menu.CHARGE_MOVES or menuState == BattleState.Menu.SURGE_MOVES
	if moves.visible:
		battleController.state.moveEffectType = Move.MoveEffectType.CHARGE if menuState == BattleState.Menu.CHARGE_MOVES else Move.MoveEffectType.SURGE
		moves.load_moves()
	
	targets.visible = menuState == BattleState.Menu.PICK_TARGETS
	if targets.visible:
		targets.referringMenu = prevMenu
		targets.load_targets()

	surge.visible = menuState == BattleState.Menu.SURGE_SPEND
	if surge.visible:
		surge.load_surge()

	results.visible = menuState == BattleState.Menu.RESULTS \
			or menuState == BattleState.Menu.PRE_BATTLE or menuState == BattleState.Menu.PRE_ROUND \
			or menuState == BattleState.Menu.POST_ROUND
	if results.visible:
		results.initial_focus()
		battleController.reset_intermediate_state_strs()
		battleController.turnExecutor.update_turn_text()
		return # returns specifically here because of skipping post-round text
		
	battleComplete.visible = menuState == BattleState.Menu.BATTLE_COMPLETE
	if battleComplete.visible:
		battleComplete.playerWins = playerWins
		battleComplete.playerEscapes = escapes
		battleComplete.rewards = battleController.state.rewards
		if playerWins and len(battleComplete.rewards) == 0:
			if PlayerResources.playerInfo.staticEncounter != null && PlayerResources.playerInfo.staticEncounter.useStaticRewards:
				for reward in PlayerResources.playerInfo.staticEncounter.rewards:
					battleComplete.rewards.append(reward)
			else:
				for combatantNode in battleController.get_all_combatant_nodes():
					if combatantNode.role == CombatantNode.Role.ENEMY and combatantNode.combatant != null:
						var dropIdx: int = WeightedThing.pick_item(combatantNode.combatant.dropTable)
						if dropIdx > -1:
							battleComplete.rewards.append( \
									combatantNode.combatant.dropTable[dropIdx].reward.scale_reward_by_level(combatantNode.initialCombatantLv, combatantNode.combatant.stats.level) \
							)
			for combatantNode in battleController.get_all_combatant_nodes():
				if combatantNode.role == CombatantNode.Role.ENEMY and combatantNode.combatant != null:
					PlayerResources.questInventory.progress_quest(combatantNode.combatant.save_name(), QuestStep.Type.DEFEAT)
			battleController.state.rewards = battleComplete.rewards
			if PlayerResources.playerInfo.staticEncounter != null:
				PlayerResources.playerInfo.set_special_battle_completed(PlayerResources.playerInfo.staticEncounter.specialBattleId)
				PlayerResources.playerInfo.staticEncounter = null
		battleComplete.load_battle_over_menu()
	
	if menuState == BattleState.Menu.LEVEL_UP:
		open_stats(PlayerResources.playerInfo.combatant, true)

func advance_intermediate_state(result: TurnExecutor.TurnResult = TurnExecutor.TurnResult.NOTHING):
	if menuState == BattleState.Menu.PRE_BATTLE or menuState == BattleState.Menu.PRE_ROUND or menuState == BattleState.Menu.POST_ROUND:
		var newMenuState: BattleState.Menu = BattleState.Menu.ALL_COMMANDS # default: advance from PRE_BATTLE to ALL_COMMANDS
		if menuState == BattleState.Menu.PRE_ROUND:
			set_menu_state(BattleState.Menu.RESULTS) # prevent recursion by just setting here
			battleController.turnExecutor.play_turn() # start the first turn
			return
		if menuState == BattleState.Menu.POST_ROUND:
			if result == TurnExecutor.TurnResult.NOTHING: # check again before completing round
				result = battleController.turnExecutor.check_battle_end_conditions()
			if result != TurnExecutor.TurnResult.NOTHING:
				newMenuState = BattleState.Menu.BATTLE_COMPLETE
			else:
				round_complete()
				return
		set_menu_state(newMenuState)
		initial_focus()

func start_pre_battle():
	for combatantNode in battleController.get_all_combatant_nodes():
		# apply pre-battle effects
		if combatantNode.is_alive():
			if combatantNode.combatant.stats.equippedWeapon != null:
				combatantNode.combatant.stats.equippedWeapon.apply_effects(combatantNode.combatant, BattleCommand.ApplyTiming.BEFORE_BATTLE)
			if combatantNode.combatant.stats.equippedArmor != null:
				combatantNode.combatant.stats.equippedArmor.apply_effects(combatantNode.combatant, BattleCommand.ApplyTiming.BEFORE_BATTLE)
	set_menu_state(BattleState.Menu.PRE_BATTLE)
	initial_focus()

func return_to_player_command():
	commandingMinion = battleController.minionCombatant.is_alive() and not battleController.playerCombatant.is_alive()
	commandingCombatant = battleController.minionCombatant if commandingMinion else battleController.playerCombatant
	inventoryPanel.slotQueuedForBattleUse = null
	set_menu_state(BattleState.Menu.ALL_COMMANDS)

func complete_command():
	if not commandingMinion and battleController.minionCombatant.is_alive():
		commandingMinion = true
		set_menu_state(BattleState.Menu.ALL_COMMANDS)
	else:
		battleController.turnExecutor.start_simulation()
		set_menu_state(BattleState.Menu.PRE_ROUND)

func update_hp_tags():
	for combatantNode in battleController.get_all_combatant_nodes():
		combatantNode.update_hp_tag()
	battleController.update_combatant_focus_neighbors()

func update_downed():
	for combatantNode in battleController.get_all_combatant_nodes():
		if combatantNode.combatant != null:
			combatantNode.combatant.update_downed()
		combatantNode.visible = combatantNode.is_alive()
	battleController.update_combatant_focus_neighbors()

func round_complete():
	battleController.state.turnNumber += 1
	battlePanels.flowOfBattle.set_fob_button_enabled()
	return_to_player_command()

func end_battle():
	battleController.end_battle()

func initial_focus():
	if summonMenu.visible:
		summonMenu.initial_focus()
	if allCommands.visible:
		allCommands.initial_focus()
	if moves.visible:
		moves.initial_focus()
	if targets.visible:
		targets.initial_focus()
	if surge.visible:
		surge.initial_focus()
	if results.visible:
		results.initial_focus()
	if battleComplete.visible:
		battleComplete.okBtn.grab_focus()

func restore_focus():
	if summonMinionPanel.visible and summonMinionPanel.statsShowMinion != null:
		summonMinionPanel.initial_focus()
		return
	
	if previousFocus == null:
		initial_focus()
	else:
		previousFocus.grab_focus()

func open_inventory(forSummon: bool):
	if not forSummon:
		inventoryPanel.summoning = forSummon
		inventoryPanel.lockFilters = forSummon
		if forSummon:
			inventoryPanel.selectedFilter = Item.Type.SHARD
		else:
			if commandingMinion and battleController.playerCombatant.is_alive():
				inventoryPanel.slotQueuedForBattleUse = battleController.playerCombatant.combatant.command.slot
		inventoryPanel.toggle()
	else:
		summonMinionPanel.load_summon_minion_panel()

func _on_inventory_panel_node_item_used(slot: InventorySlot):
	if menuState == BattleState.Menu.SUMMON:
		PlayerResources.inventory.trash_item(slot)
		var shard = slot.item as Shard
		battleController.summon_minion(shard.combatantSaveName, shard)
		start_pre_battle()
	if menuState == BattleState.Menu.ITEMS:
		commandingCombatant.combatant.command = \
				BattleCommand.new(BattleCommand.Type.USE_ITEM, null, slot, [])
		set_menu_state(BattleState.Menu.PICK_TARGETS)
		targets.initial_focus()
	inventoryPanel.toggle()

func open_stats(combatant: Combatant, levelUp: bool = false):
	statsPanel.levelUp = levelUp
	statsPanel.newLvs = battleComplete.gainedLevels
	statsPanel.stats = combatant.stats
	statsPanel.curHp = combatant.currentHp
	statsPanel.readOnly = not levelUp
	statsPanel.visible = false # force it to be turned on
	statsPanel.isPlayer = combatant == PlayerResources.playerInfo.combatant or combatant == battleController.playerCombatant.combatant
	statsPanel.toggle()

func _on_stats_panel_node_back_pressed():
	if menuState == BattleState.Menu.LEVEL_UP:
		end_battle()
	restore_focus()

func _on_combatant_details_clicked(combatantNode: CombatantNode):
	#open_stats(combatantNode.combatant) # disable for testing/designing
	pass

func _on_summon_minion_panel_back_pressed():
	summonMenu.initial_focus()

func _on_inventory_panel_node_back_pressed():
	if menuState == BattleState.Menu.SUMMON:
		summonMenu.initial_focus()
	if menuState == BattleState.Menu.ITEMS:
		allCommands.inventoryBtn.grab_focus()

func _on_quests_panel_node_back_pressed():
	restore_focus()

func _on_focus_changed(control: Control):
	if control == battlePanels.flowOfBattle.fobButton and previousFocus != battlePanels.flowOfBattle.fobButton:
		battlePanels.flowOfBattle.fobButton.focus_neighbor_bottom = battlePanels.flowOfBattle.fobButton.get_path_to(previousFocus)
	if not statsPanel.visible and not inventoryPanel.visible and \
		not battlePanels.pauseMenu.visible and not battlePanels.questsMenu.visible and \
		not battlePanels.summonMinionPanel.visible and not fobFocusMode:
		previousFocus = control

func _on_summon_minion_panel_show_stats_for_minion(minion: Combatant):
	statsPanel.readOnly = true
	statsPanel.isMinionStats = true
	statsPanel.minion = minion
	statsPanel.stats = minion.stats
	statsPanel.savedStats = null
	statsPanel.toggle()

func _on_summon_minion_panel_minion_summoned(minion: Combatant, shardSlot: InventorySlot):
	var shard = null
	if shardSlot:
		PlayerResources.inventory.trash_item(shardSlot)
		shard = shardSlot.item as Shard
	battleController.summon_minion(minion.save_name(), shard)
	start_pre_battle()
