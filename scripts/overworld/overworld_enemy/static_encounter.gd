extends EnemyEncounter
class_name StaticEncounter

@export var combatant1Level: int = 1
@export var combatant1Moves: Array[Move] = []
@export var combatant1Ai: CombatantAi = null
@export var combatant1ShardSummoned: bool = false
@export var combatant2: Combatant = null
@export var combatant2StatAllocStrat: StatAllocationStrategy = null
@export var combatant2Level: int = 1
@export var combatant2Armor: Armor = null
@export var combatant2Weapon: Weapon = null
@export var combatant2Moves: Array[Move] = []
@export var combatant2Ai: CombatantAi = null
@export var combatant2ShardSummoned: bool = false
@export var combatant3: Combatant = null
@export var combatant3StatAllocStrat: StatAllocationStrategy = null
@export var combatant3Level: int = 1
@export var combatant3Armor: Armor = null
@export var combatant3Weapon: Weapon = null
@export var combatant3Moves: Array[Move] = []
@export var combatant3Ai: CombatantAi = null
@export var combatant3ShardSummoned: bool = false
@export var autoAlly: Combatant = null
@export var autoAllyStatAllocStrat: StatAllocationStrategy = null
@export var autoAllyLevel: int = 1
@export var autoAllyArmor: Armor = null
@export var autoAllyWeapon: Weapon = null
@export var autoAllyMoves: Array[Move] = []
@export var autoAllyShardSummoned: bool = false
@export var specialBattleId: String = ''
@export var bossBattle: bool = false
@export var canEscape: bool = true
@export var rewards: Array[Reward] = []
@export var useStaticRewards: bool = false
@export var battleMusic: AudioStream = null

func _init(
	i_combatant1 = null,
	i_combatant1Weapon: Weapon = null,
	i_combatant1Armor: Armor = null,
	i_combatant1StatAllocStrat: StatAllocationStrategy = null,
	i_specialRules = SpecialRules.NONE,
	i_winCon = null,
	i_customWinText = '',
	i_combatant1Lv = 1,
	i_combatant1Moves: Array[Move] = [],
	i_combatant1Ai: CombatantAi = null,
	i_combatant1ShardSummoned = false,
	i_combatant2 = null,
	i_combatant2StatAllocStrat: StatAllocationStrategy = null,
	i_combatant2Lv = 1,
	i_combatant2Armor = null,
	i_combatant2Weapon = null,
	i_combatant2Moves: Array[Move] = [],
	i_combatant2Ai: CombatantAi = null,
	i_combatant2ShardSummoned = false,
	i_combatant3 = null,
	i_combatant3StatAllocStrat: StatAllocationStrategy = null,
	i_combatant3Lv = 1,
	i_combatant3Armor = null,
	i_combatant3Weapon = null,
	i_combatant3Moves: Array[Move] = [],
	i_combatant3Ai: CombatantAi = null,
	i_combatant3ShardSummoned = false,
	i_autoAlly = null,
	i_autoAllyStatAllocStrat: StatAllocationStrategy = null,
	i_autoAllyLv = 1,
	i_autoAllyArmor = null,
	i_autoAllyWeapon = null,
	i_autoAllyMoves: Array[Move] = [],
	i_autoAllyShardSummoned = false,
	i_specialBattleId = '',
	i_canEscape = true,
	i_rewards: Array[Reward] = [],
	i_useRewards = false,
	i_battleMusic = null,
):
	super(i_combatant1, i_combatant1Weapon, i_combatant1Armor, i_combatant1StatAllocStrat, i_specialRules, i_winCon, i_customWinText)
	combatant1Level = i_combatant1Lv
	combatant1Armor = i_combatant1Armor
	combatant1Weapon = i_combatant1Weapon
	combatant1Moves = i_combatant1Moves
	combatant1Ai = i_combatant1Ai
	combatant1ShardSummoned = i_combatant1ShardSummoned

	combatant2 = i_combatant2
	combatant2StatAllocStrat = i_combatant2StatAllocStrat
	combatant2Level = i_combatant2Lv
	combatant2Armor = i_combatant2Armor
	combatant2Weapon = i_combatant2Weapon
	combatant2Moves = i_combatant2Moves
	combatant2Ai = i_combatant2Ai
	combatant2ShardSummoned = i_combatant2ShardSummoned
	
	combatant3 = i_combatant3
	combatant3StatAllocStrat = i_combatant3StatAllocStrat
	combatant3Level = i_combatant3Lv
	combatant3Armor = i_combatant3Armor
	combatant3Weapon = i_combatant3Weapon
	combatant3Moves = i_combatant3Moves
	combatant3Ai = i_combatant3Ai
	combatant3ShardSummoned = i_combatant3ShardSummoned

	autoAlly = i_autoAlly
	autoAllyStatAllocStrat = i_autoAllyStatAllocStrat
	autoAllyLevel = i_autoAllyLv
	autoAllyArmor = i_autoAllyArmor
	autoAllyWeapon = i_autoAllyWeapon
	autoAllyMoves = i_autoAllyMoves
	autoAllyShardSummoned = i_autoAllyShardSummoned
	
	specialBattleId = i_specialBattleId
	canEscape = i_canEscape
	rewards = i_rewards
	useStaticRewards = i_useRewards
	battleMusic = i_battleMusic
