extends Node2D
class_name StatsMenu

signal attempt_equip_weapon_to(stats: Stats)
signal attempt_equip_armor_to(stats: Stats)
signal back_pressed

@export var stats: Stats = null
@export var curHp: int = -1
@export var levelUp: bool = false
@export var readOnly: bool = false
@export var isPlayer: bool = false

var isMinionStats: bool = false
var minion: Combatant = null
var savedStats: Stats = null
var savedCurHp: int = -1
var savedLvUp: bool = false
var savedIsPlayer: bool = false
var changingCombatant: bool = false

@onready var animatedCombatantSprite: AnimatedSprite2D = get_node("StatsPanel/Panel/AnimatedCombatantSprite")
@onready var statsTitle: RichTextLabel = get_node("StatsPanel/Panel/StatsTitle")
@onready var levelUpLabel: RichTextLabel = get_node("StatsPanel/Panel/LevelUpLabel")
@onready var statlinePanel: StatLinePanel = get_node("StatsPanel/Panel/StatLinePanel")
@onready var moveListPanel: MoveListPanel = get_node("StatsPanel/Panel/MoveListPanel")
@onready var equipmentPanel: EquipmentPanel = get_node("StatsPanel/Panel/EquipmentPanel")
@onready var minionsPanel: MinionsPanel = get_node("StatsPanel/Panel/MinionsPanel")
@onready var backButton: Button = get_node("StatsPanel/Panel/BackButton")
@onready var editMovesPanel: EditMovesPanel = get_node("StatsPanel/Panel/EditMovesPanel")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func toggle():
	visible = not visible
	if visible:
		load_stats_panel()
		backButton.grab_focus()
	else:
		back_pressed.emit()

func load_stats_panel():
	if stats == null:
		return
	
	var dispName: String = stats.displayName
	if minion != null:
		dispName = minion.disp_name()
	
	var spriteFrames: SpriteFrames = PlayerResources.playerInfo.combatant.spriteFrames
	if minion != null:
		spriteFrames = minion.spriteFrames
	animatedCombatantSprite.sprite_frames = spriteFrames
	animatedCombatantSprite.play('walk')
	
	statsTitle.text = '[center]' + dispName + ' - Stats[/center]'
	levelUpLabel.visible = levelUp
	statlinePanel.stats = stats
	statlinePanel.curHp = curHp
	statlinePanel.readOnly = readOnly
	statlinePanel.load_statline_panel(changingCombatant)
	moveListPanel.moves = stats.moves
	moveListPanel.movepool = stats.movepool
	moveListPanel.readOnly = readOnly
	moveListPanel.load_move_list_panel()
	equipmentPanel.weapon = stats.equippedWeapon
	equipmentPanel.armor = stats.equippedArmor
	equipmentPanel.statsPanel = self
	equipmentPanel.load_equipment_panel()
	minionsPanel.minion = minion
	minionsPanel.readOnly = readOnly
	minionsPanel.load_minions_panel()
	changingCombatant = false

func restore_previous_stats_panel():
	stats = savedStats
	minion = null
	curHp = savedCurHp
	levelUp = savedLvUp
	isPlayer = savedIsPlayer
	isMinionStats = false
	changingCombatant = true
	load_stats_panel()

func reset_panel_to_player():
	if isMinionStats:
		restore_previous_stats_panel()

func _on_back_button_pressed():
	if not isMinionStats:
		toggle()
		back_pressed.emit()
	else:
		restore_previous_stats_panel()

func _on_move_list_panel_move_details_visiblity_changed(newVisible: bool):
	backButton.disabled = newVisible

func _on_minions_panel_stats_clicked(combatant: Combatant):
	savedStats = stats
	savedCurHp = curHp
	savedLvUp = levelUp
	savedIsPlayer = isPlayer
	if combatant != null and combatant.stats != null:
		minion = combatant
		stats = combatant.stats
		curHp = -1
		levelUp = false
		isPlayer = false
		isMinionStats = true
		changingCombatant = true
		load_stats_panel()

func _on_move_list_panel_edit_moves():
	editMovesPanel.moves = stats.moves
	editMovesPanel.movepool = stats.movepool
	editMovesPanel.level = stats.level
	editMovesPanel.load_edit_moves_panel()
	backButton.disabled = true

func _on_edit_moves_panel_back_pressed():
	backButton.disabled = false	
	backButton.grab_focus()

func _on_edit_moves_panel_replace_move(slot: int, newMove: Move):
	if slot >= len(stats.moves):
		for i in range(4):
			if slot == i:
				stats.moves.append(newMove)
			elif i >= len(stats.moves):
				stats.moves.append(null)
	else:
		stats.moves[slot] = newMove
	load_stats_panel()

func _on_equipment_panel_attempt_equip_weapon():
	if not readOnly:
		attempt_equip_weapon_to.emit(stats)

func _on_equipment_panel_attempt_equip_armor():
	if not readOnly:
		attempt_equip_armor_to.emit(stats)
