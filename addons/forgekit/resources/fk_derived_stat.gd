@tool
class_name FKDerivedStat
extends Resource
## A stat calculated from other base stats (e.g., Evasion = Dexterity * 0.5 + Luck * 0.3).

## Unique identifier for this derived stat.
@export var id: String = ""
## Display name shown to players.
@export var display_name: String = ""
## Description of what this derived stat does.
@export_multiline var description: String = ""
## The base stats and their weights that feed into this derived stat.
## Each entry maps a stat ID to its multiplier weight.
@export var stat_weights: Dictionary = {}
## A flat bonus added after calculating from base stats.
@export var flat_bonus: float = 0.0
## Minimum possible value.
@export var min_value: float = 0.0
## Maximum possible value.
@export var max_value: float = 9999.0
## Icon for this stat (optional).
@export var icon: Texture2D

## --- Custom ---
## Store any additional data your project needs. ForgeKit will not touch this.
@export var custom_data: Dictionary = {}

## Calculate the derived value from a dictionary of stat_id -> current_value.
func calculate(base_stats: Dictionary) -> float:
	var total: float = flat_bonus
	for stat_id in stat_weights:
		if base_stats.has(stat_id):
			total += base_stats[stat_id] * stat_weights[stat_id]
	return clampf(total, min_value, max_value)

func _to_string() -> String:
	return display_name if display_name else id
