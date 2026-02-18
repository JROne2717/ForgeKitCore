@tool
class_name FKEnemy
extends Resource
## Defines an enemy/monster in the RPG system.

## Unique identifier.
@export var id: String = ""
## Display name shown to players.
@export var display_name: String = ""
## Description/lore text.
@export_multiline var description: String = ""
## Enemy sprite/portrait.
@export var icon: Texture2D
## Battle sprite (the actual in-combat visual).
@export var battle_sprite: Texture2D

## --- Stats ---
## Base stats for this enemy. Maps stat ID -> value.
@export var base_stats: Dictionary = {}
## Max HP.
@export var max_hp: int = 100
## Max MP.
@export var max_mp: int = 20
## Level of this enemy.
@export var level: int = 1

## --- Combat Behavior ---
## Abilities this enemy can use.
@export var abilities: Array[Resource] = []  # FKAbility resources
## AI behavior pattern for ability selection.
## Each entry: {"ability_index": 0, "weight": 50, "condition": "hp_above_50"}.
@export var ai_patterns: Array[Dictionary] = []
## Element weaknesses (takes more damage). Maps element -> multiplier.
@export var weaknesses: Dictionary = {}
## Element resistances (takes less damage). Maps element -> multiplier.
@export var resistances: Dictionary = {}
## Status immunities.
@export var status_immunities: Array[String] = []
## Can this enemy flee?
@export var can_flee: bool = false

## --- Rewards ---
## Experience points awarded on defeat.
@export var exp_reward: int = 10
## Gold/currency awarded on defeat.
@export var gold_reward: int = 5
## Gold reward variance percentage.
@export var gold_variance: float = 0.2
## Loot table for item drops.
@export var loot_table: Resource  # FKLootTable
## Guaranteed drops (always given on defeat).
@export var guaranteed_drops: Array[Resource] = []  # FKItem resources

## --- Classification ---
@export_enum("Normal", "Elite", "Mini Boss", "Boss", "Raid Boss") var enemy_tier: String = "Normal"
## Type tags for categorization (e.g., "undead", "beast", "humanoid").
@export var type_tags: Array[String] = []
## Is this enemy a boss (disables flee)?
@export var is_boss: bool = false

## --- Custom ---
## Store any additional data your project needs. ForgeKit will not touch this.
@export var custom_data: Dictionary = {}

## Select an ability based on AI patterns and current state.
func select_ability(current_hp_percent: float) -> Resource:
	if abilities.is_empty():
		return null
	if ai_patterns.is_empty():
		return abilities[randi() % abilities.size()]

	var valid_patterns: Array[Dictionary] = []
	var total_weight := 0.0
	for pattern in ai_patterns:
		if _check_condition(pattern.get("condition", ""), current_hp_percent):
			valid_patterns.append(pattern)
			total_weight += pattern.get("weight", 1.0)

	if valid_patterns.is_empty():
		return abilities[randi() % abilities.size()]

	var roll := randf() * total_weight
	var cumulative := 0.0
	for pattern in valid_patterns:
		cumulative += pattern.get("weight", 1.0)
		if roll <= cumulative:
			var idx: int = pattern.get("ability_index", 0)
			if idx >= 0 and idx < abilities.size():
				return abilities[idx]
	return abilities[0]


func _check_condition(condition: String, hp_percent: float) -> bool:
	match condition:
		"", "always":
			return true
		"hp_above_50":
			return hp_percent > 0.5
		"hp_below_50":
			return hp_percent <= 0.5
		"hp_below_25":
			return hp_percent <= 0.25
		"hp_full":
			return hp_percent >= 1.0
		_:
			return true

func _to_string() -> String:
	return display_name if display_name else id
