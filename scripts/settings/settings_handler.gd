extends Node
signal settings_changed

@export var gameSettings: GameSettings = GameSettings.new()
@export var isMobile: bool = false

var save_path: String = 'user://'

func _init():
	load_data()

func save_data() -> int:
	return gameSettings.save_data(save_path, gameSettings)
	
func load_data():
	var newGameSettings: GameSettings = gameSettings.load_data(save_path)
	if newGameSettings != null:
		gameSettings = newGameSettings
	gameSettings.apply_from_stored_inputs()
