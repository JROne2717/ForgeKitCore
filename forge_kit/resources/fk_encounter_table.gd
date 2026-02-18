@tool
class_name FKEncounterTable
extends Resource
## Defines a random encounter table for a zone or area.

## Unique identifier.
@export var id: String = ""
## Display name.
@export var display_name: String = ""

## --- Encounter Entries ---
## Array of encounter entries. Each entry is a dictionary:
## {
##   "enemies": [FKEnemy, FKEnemy],  # enemies in this encounter group
##   "weight": 100,                     # relative weight
##   "min_count": 1,                    # minimum enemies from this group
##   "max_count": 3,                    # maximum enemies from this group
##   "level_range": Vector2i(1, 5),     # level range override (0,0 = use enemy default)
##   "condition": ""                     # optional condition string
## }
@export var entries: Array[Dictionary] = []

## --- Encounter Settings ---
## Base steps between encounters.
@export var base_steps: int = 30
## Variance in steps (e.g., 0.5 means 50% to 150% of base_steps).
@export var step_variance: float = 0.5
## Can encounters be avoided (with flee/repel items)?
@export var avoidable: bool = true
## Maximum number of enemies per battle.
@export var max_enemies_per_battle: int = 4
## Minimum player level for encounters to trigger (-1 = always).
@export var min_player_level: int = -1
## Maximum player level for encounters (-1 = no cap).
@export var max_player_level: int = -1

## --- Custom ---
## Store any additional data your project needs. ForgeKit will not touch this.
@export var custom_data: Dictionary = {}

## Roll a random encounter and return {"enemies": [FKEnemy], "count": int}.
func roll_encounter() -> Dictionary:
	if entries.is_empty():
		return {}

	var total_weight := 0.0
	for entry in entries:
		total_weight += entry.get("weight", 1.0)
	if total_weight <= 0:
		return {}

	var roll := randf() * total_weight
	var cumulative := 0.0
	for entry in entries:
		cumulative += entry.get("weight", 1.0)
		if roll <= cumulative:
			var enemies: Array = entry.get("enemies", [])
			var min_count: int = entry.get("min_count", 1)
			var max_count: int = entry.get("max_count", 1)
			var count := clampi(randi_range(min_count, max_count), 1, max_enemies_per_battle)
			return {"enemies": enemies, "count": count}

	return {}

## Calculate steps until next encounter with variance.
func roll_steps() -> int:
	var variance_amount := base_steps * step_variance
	return maxi(1, int(base_steps + randf_range(-variance_amount, variance_amount)))

func _to_string() -> String:
	return display_name if display_name else id
