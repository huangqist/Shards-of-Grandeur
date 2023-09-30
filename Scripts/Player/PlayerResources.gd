extends Node2D

@export var playerInfo: PlayerInfo
@export var inventory: Inventory
@export var questInventory: QuestInventory
@export var loaded: bool = false

var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func load_data(save_path):
	playerInfo = PlayerInfo.new()
	var newPlayerInfo = playerInfo.load_data(save_path)
	if newPlayerInfo != null:
		playerInfo = newPlayerInfo
		playerInfo.combatant.stats = playerInfo.stats.copy() # copy stats to Combatant obj
		if playerInfo.combatant.currentHp == -1: # if -1, set to maxHp
			playerInfo.combatant.currentHp = playerInfo.stats.maxHp
	player = PlayerFinder.player
	if player != null:
		player.position = playerInfo.position
		player.disableMovement = playerInfo.disableMovement
	inventory = Inventory.new()
	var newInv = inventory.load_data(save_path)
	if newInv != null:
		inventory = newInv
	questInventory = QuestInventory.new()
	var newQuestInv = questInventory.load_data(save_path)
	if newQuestInv != null:
		questInventory = newQuestInv
	loaded = true

func save_data(save_path):
	if player != null and playerInfo != null:
		playerInfo.position = player.position
		playerInfo.disableMovement = player.disableMovement
		playerInfo.save_data(save_path, playerInfo)
	if inventory != null:
		inventory.save_data(save_path, inventory)
	if questInventory != null:
		questInventory.save_data(save_path, questInventory)
	
func new_game(save_path):
	playerInfo = PlayerInfo.new()
	playerInfo.save_data(save_path, playerInfo)
	inventory = Inventory.new()
	inventory.save_data(save_path, inventory)
	questInventory = QuestInventory.new()
	questInventory.save_data(save_path, questInventory)
	loaded = true
