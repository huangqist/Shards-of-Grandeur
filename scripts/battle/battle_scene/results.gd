extends Control
class_name Results

@export var battleUI: BattleUI
var result: WinCon.TurnResult = WinCon.TurnResult.NOTHING
var okPressed: bool = false
var animFinished: bool = false

var ignoreOkPressed: bool = false

@onready var textBoxText: RichTextLabel = get_node("TextBoxText")
@onready var okBtn: Button = get_node("OkButton")

# Called when the node enters the scene tree for the first time.
func _ready():
	textBoxText.text = '' # clear editor testing text

func initial_focus():
	okBtn.grab_focus()

func show_text(newText: String):
	textBoxText.text = TextUtils.rich_text_substitute(newText, Vector2i(32, 32))
	ignoreOkPressed = false

func _on_ok_button_pressed(queued: bool = false) -> void:
	if ignoreOkPressed:
		return
	
	ignoreOkPressed = true
	if battleUI.menuState == BattleState.Menu.PRE_BATTLE or battleUI.menuState == BattleState.Menu.PRE_ROUND or battleUI.menuState == BattleState.Menu.POST_ROUND:
		# if no win has been determined yet, check on this post-battle results display step
		if result == WinCon.TurnResult.NOTHING and battleUI.menuState == BattleState.Menu.POST_ROUND:
			result = PlayerResources.playerInfo.encounter.get_win_con_result(battleUI.battleController.get_all_combatant_nodes(), battleUI.battleController.state)
			update_battle_ui_with_results()
		if not animFinished:
			battleUI.battleController.battleAnimationManager.skip_intermediate_animations(battleUI.battleController.state, battleUI.menuState)
		if battleUI.battleController.turnExecutor.advance_precalcd_text(): # if was final
			battleUI.advance_intermediate_state(result)
		return # don't fall-through and potentially run the results code below
	
	if animFinished:
		okPressed = false
		okBtn.disabled = false
		animFinished = false
		
		if battleUI.menuState == BattleState.Menu.RESULTS:
			# update HP tags just to be safe, in case we missed any updates
			battleUI.update_hp_tags() # TODO: I think this can be taken out?
			
			# wait one frame to ensure that all emitted signals related to animations have been emitted
			await get_tree().process_frame
			
			result = battleUI.battleController.turnExecutor.finish_turn()
			
			update_battle_ui_with_results()
			if result != WinCon.TurnResult.NOTHING:
				battleUI.set_menu_state(BattleState.Menu.POST_ROUND)
	else:
		okPressed = true
		okBtn.disabled = true

func update_battle_ui_with_results():
	if result != WinCon.TurnResult.NOTHING:
		battleUI.playerWins = result == WinCon.TurnResult.PLAYER_WIN
		battleUI.escapes = result == WinCon.TurnResult.ESCAPE

func _on_battle_animation_manager_combatant_animation_start() -> void:
	animFinished = false

func _on_battle_animation_manager_combatant_animation_complete() -> void:
	animFinished = true
	ignoreOkPressed = false
	if okPressed:
		_on_ok_button_pressed(true)
