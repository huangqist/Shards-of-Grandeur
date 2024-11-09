extends Resource
class_name CombatantAiLayer

## the amount of weight this layer has on the final decision of the AI
@export var weight: float = 1.0

## sub-layers that act as additional weighting on this layer
@export var subLayers: Array[CombatantAiLayer] = []

static func get_runes_on_combatant_move_triggers(user: CombatantNode, move: Move, effectType: Move.MoveEffectType, orbs: int, target: CombatantNode, battleState: BattleState, runes: Array[Rune]) -> Array[Rune]:
	var triggeredRunes: Array[Rune] = []
	var untriggeredRunes: Array[Rune] = runes.duplicate(false)
	
	var hasRunesToCheck: bool = true
	while hasRunesToCheck:
		var runeTriggered: bool = false
		for rune: Rune in untriggeredRunes:
			if rune.caster != null and will_move_effect_trigger_rune(user, move, effectType, orbs, target, battleState, rune, len(triggeredRunes) > 0):
				triggeredRunes.append(rune)
				runeTriggered = true
		for rune: Rune in triggeredRunes:
			untriggeredRunes.erase(rune)
		if not runeTriggered or len(untriggeredRunes) == 0:
			hasRunesToCheck = false
	
	return triggeredRunes

static func will_move_effect_trigger_rune(user: CombatantNode, move: Move, effectType: Move.MoveEffectType, orbs: int, target: CombatantNode, battleState: BattleState, rune: Rune, othersTriggered: bool) -> bool:
	var moveEffect: MoveEffect = move.get_effect_of_type(effectType)
	if effectType == Move.MoveEffectType.SURGE:
		moveEffect = moveEffect.apply_surge_changes(absi(orbs))
	
	if rune is DamageRune:
		return (not rune.isHealRune and moveEffect.power > 0) or (rune.isHealRune and moveEffect.power < 0)
	
	if rune is BoostRune:
		if moveEffect.targetStatChanges != null and moveEffect.targetStatChanges.has_stat_changes():
			return true
		if target == user and moveEffect.selfStatChanges != null and moveEffect.selfStatChanges.has_stat_changes():
			return true
	
	if rune is StatusRune:
		if moveEffect.statusEffect != null and not (moveEffect.selfGetsStatus and user != target):
			if target.combatant.statusEffect == null or moveEffect.statusEffect.overwritesOtherStatuses:
				return true
	
	if rune is SurgeRune and user == target:
		return effectType == Move.MoveEffectType.SURGE
	
	if rune is ChainRune:
		return othersTriggered
	
	return false

func _init(
	i_weight: float = 1.0,
	i_subLayers: Array[CombatantAiLayer] = [],
) -> void:
	weight = i_weight
	subLayers = i_subLayers

## get the weight for a combination of move effect and target
func weight_move_effect_on_target(user: CombatantNode, move: Move, effectType: Move.MoveEffectType, orbs: int, target: CombatantNode, targets: Array[CombatantNode], battleState: BattleState) -> float:
	if move == null or target == null:
		return -1
	var effect: MoveEffect = move.get_effect_of_type(effectType)
	if effect == null:
		return -1
	
	var subLayersWeight: float = 1
	for layer: CombatantAiLayer in subLayers:
		if layer == null:
			continue
		
		var subLayerWeight: float = layer.weight_move_effect_on_target(user, move, effectType, orbs, target, targets, battleState)
		if subLayerWeight < 0:
			subLayersWeight = -1
		else:
			subLayerWeight = lerpf(1, subLayerWeight, weight)
			subLayersWeight *= subLayerWeight
	return subLayersWeight

func set_move_used(move: Move, effectType: Move.MoveEffectType) -> void:
	pass # NOTE subclasses that care about what move was used should implement this method

func copy(copyStorage: bool = false) -> CombatantAiLayer:
	return CombatantAiLayer.new(weight, copy_sublayers(copyStorage))

func copy_sublayers(copyStorage: bool = false) -> Array[CombatantAiLayer]:
	var newLayers: Array[CombatantAiLayer] = []
	for layer: CombatantAiLayer in subLayers:
		newLayers.append(layer.copy(copyStorage))
	return newLayers
