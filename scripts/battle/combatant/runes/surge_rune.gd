extends Rune
class_name SurgeRune

func get_rune_type() -> String:
	return 'Surge Rune'

func get_rune_trigger_description() -> String:
	return 'After Surging A Move'

func does_rune_trigger(combatant: Combatant, otherCombatants: Array[Combatant], state: BattleState, timing: BattleCommand.ApplyTiming) -> bool:
	if timing == BattleCommand.ApplyTiming.AFTER_DMG_CALC:
		if len(state.turnList) > 0 and state.turnList[0] == combatant and combatant.command != null:
			return combatant.command.moveEffectType == Move.MoveEffectType.SURGE
	return false

func copy(copyStorage: bool = false) -> SurgeRune:
	return SurgeRune.new(orbChange, category, element, power, lifesteal, statChanges.duplicate(), statusEffect.duplicate(), surgeChanges.duplicate(), caster if copyStorage else null, runeSpriteAnim, triggerAnim)
