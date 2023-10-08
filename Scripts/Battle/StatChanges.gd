extends Resource
class_name StatChanges

@export var physAttackMultiplier: float = 1.0
@export var magicAttackMultiplier: float = 1.0
@export var resistanceMultiplier: float = 1.0
@export var affinityMultiplier: float = 1.0
@export var speedMultiplier: float = 1.0

func _init(
	i_phys = 1.0,
	i_magic = 1.0,
	i_resistance = 1.0,
	i_affinity = 1.0,
	i_speed = 1.0,
):
	physAttackMultiplier = i_phys
	magicAttackMultiplier = i_magic
	resistanceMultiplier = i_resistance
	affinityMultiplier = i_affinity
	speedMultiplier = i_speed

func stack(changes: StatChanges):
	physAttackMultiplier += changes.physAttackMultiplier - 1.0
	magicAttackMultiplier += changes.magicAttackMultiplier - 1.0
	resistanceMultiplier += changes.resistanceMultiplier - 1.0
	affinityMultiplier += changes.affinityMultiplier - 1.0
	speedMultiplier += changes.speedMultiplier - 1.0

func apply(s: Stats) -> Stats:
	var newStats = s.copy()
	newStats.physAttack = roundi(newStats.physAttack * physAttackMultiplier)
	newStats.magicAttack = roundi(newStats.magicAttack * magicAttackMultiplier)
	newStats.resistance = roundi(newStats.resistance * resistanceMultiplier)
	newStats.affinity = roundi(newStats.affinity * affinityMultiplier)
	newStats.speed *= roundi(newStats.speed * speedMultiplier)
	return newStats

func has_stat_changes() -> bool:
	return physAttackMultiplier != 1.0 \
			or magicAttackMultiplier != 1.0 \
			or resistanceMultiplier != 1.0 \
			or affinityMultiplier != 1.0 \
			or speedMultiplier != 1.0

func get_phys_atk_multiplier() -> StatMultiplierText:
	return StatMultiplierText.new('Phys Atk', physAttackMultiplier)
	
func get_magic_atk_multiplier() -> StatMultiplierText:
	return StatMultiplierText.new('Magic Atk', magicAttackMultiplier)

func get_resistance_multiplier() -> StatMultiplierText:
	return StatMultiplierText.new('Resistance', resistanceMultiplier)

func get_affinity_multiplier() -> StatMultiplierText:
	return StatMultiplierText.new('Affinity', affinityMultiplier)

func get_speed_multiplier() -> StatMultiplierText:
	return StatMultiplierText.new('Speed', speedMultiplier)

func get_multipliers_text() -> Array[StatMultiplierText]:
	var texts: Array[StatMultiplierText] = []
	
	if physAttackMultiplier != 1.0:
		texts.append(get_phys_atk_multiplier())
	
	if magicAttackMultiplier != 1.0:
		texts.append(get_magic_atk_multiplier())
		
	if resistanceMultiplier != 1.0:
		texts.append(get_resistance_multiplier())
		
	if affinityMultiplier != 1.0:
		texts.append(get_affinity_multiplier())
		
	if speedMultiplier != 1.0:
		texts.append(get_speed_multiplier())
		
	return texts
