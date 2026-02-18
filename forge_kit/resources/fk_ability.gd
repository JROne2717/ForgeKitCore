@tool
class_name FKAbility
extends Resource
## Defines an active ability/spell (e.g., Fireball, Heal, Power Strike).

## Unique identifier.
@export var id: String = ""
## Display name shown to players.
@export var display_name: String = ""
## Description of this ability.
@export_multiline var description: String = ""
## Icon for this ability.
@export var icon: Texture2D

## --- Type & Targeting ---
@export_enum("Physical", "Magical", "Hybrid", "Healing", "Buff", "Debuff", "Utility") var ability_type: String = "Physical"
@export_enum("Single Enemy", "All Enemies", "Single Ally", "All Allies", "Self", "Random Enemy", "Random Ally", "All") var target_type: String = "Single Enemy"
## Element type (e.g., "Fire", "Ice", "Lightning", "Holy", "Dark", "None").
@export var element: String = "None"

## --- Costs ---
## MP cost to use this ability.
@export var mp_cost: int = 0
## HP cost to use this ability.
@export var hp_cost: int = 0
## TP/Special gauge cost.
@export var tp_cost: int = 0
## Cooldown in turns.
@export var cooldown: int = 0
## Number of uses per battle (-1 = unlimited).
@export var uses_per_battle: int = -1

## --- Damage / Healing ---
## Base power value for damage or healing calculation.
@export var base_power: float = 0.0
## Stat that scales this ability's power (e.g., "strength", "intelligence").
@export var scaling_stat: String = ""
## Scaling multiplier applied to the scaling stat.
@export var scaling_multiplier: float = 1.0
## Variance percentage (e.g., 0.1 = +/- 10% random variation).
@export var variance: float = 0.1
## Critical hit chance bonus (added to base crit rate).
@export var crit_bonus: float = 0.0
## Number of hits (for multi-hit abilities).
@export var hit_count: int = 1

## --- Status Effects ---
## Status effects applied on hit. Array of dictionaries: {"status": "poison", "chance": 0.5, "duration": 3}.
@export var status_effects: Array[Dictionary] = []
## Stat buffs/debuffs applied. Array of dictionaries: {"stat": "attack", "modifier": 0.25, "duration": 3}.
@export var stat_modifiers: Array[Dictionary] = []

## --- Animation & Visuals ---
## Animation to play when used.
@export var animation_name: String = ""
## Sound effect to play.
@export var sound_effect: AudioStream
## Particle effect scene.
@export var particle_effect: PackedScene

## --- Requirements ---
## Minimum level to learn/use.
@export var level_requirement: int = 1
## Classes that can use this ability. Empty means all.
@export var class_restrictions: Array[String] = []

## --- Custom ---
## Store any additional data your project needs. ForgeKit will not touch this.
@export var custom_data: Dictionary = {}

## Calculate the final power of this ability given a stat dictionary.
func calculate_power(stats: Dictionary) -> float:
	var power := base_power
	if scaling_stat and stats.has(scaling_stat):
		power += stats[scaling_stat] * scaling_multiplier
	# Apply variance
	var rand_factor := 1.0 + randf_range(-variance, variance)
	return power * rand_factor

func _to_string() -> String:
	return display_name if display_name else id
