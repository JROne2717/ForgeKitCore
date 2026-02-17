@tool
class_name FKClass
extends Resource
## Defines a character class/job (e.g., Warrior, Mage, Rogue).

## Unique identifier for this class.
@export var id: String = ""
## Display name shown to players.
@export var display_name: String = ""
## Description of this class.
@export_multiline var description: String = ""
## Icon/portrait for this class.
@export var icon: Texture2D

## --- Base Stats ---
## Starting stat values for this class. Maps stat ID -> value.
@export var base_stats: Dictionary = {}
## Stat growth per level. Maps stat ID -> growth amount.
@export var stat_growth_per_level: Dictionary = {}

## --- Equipment ---
## Equipment types this class can use (e.g., ["sword", "shield", "heavy_armor"]).
@export var equippable_types: Array[String] = []

## --- Abilities ---
## Abilities learned at specific levels. Maps level (int) -> Array of ability resource paths.
@export var abilities_by_level: Dictionary = {}
## Passive skills this class has access to.
@export var passive_skills: Array[Resource] = []  # FKPassiveSkill resources
## Skill tree for this class (optional).
@export var skill_tree: Resource  # FKSkillTree

## --- Progression ---
## Experience curve type.
@export_enum("Linear", "Quadratic", "Cubic", "Custom") var exp_curve: String = "Quadratic"
## Base experience needed for level 2.
@export var base_exp: int = 100
## Experience scaling factor.
@export var exp_scale: float = 1.5
## Maximum level for this class.
@export var max_level: int = 99

## Calculate experience needed for a given level.
func get_exp_for_level(level: int) -> int:
	match exp_curve:
		"Linear":
			return base_exp * level
		"Quadratic":
			return int(base_exp * pow(level, exp_scale))
		"Cubic":
			return int(base_exp * pow(level, 3.0) * 0.01)
		_:
			return base_exp * level

## Get stats at a given level.
func get_stats_at_level(level: int) -> Dictionary:
	var stats := {}
	for stat_id in base_stats:
		var base: float = base_stats[stat_id]
		var growth: float = stat_growth_per_level.get(stat_id, 0.0)
		stats[stat_id] = base + growth * (level - 1)
	return stats

func _to_string() -> String:
	return display_name if display_name else id
