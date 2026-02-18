@tool
class_name FKPassiveSkill
extends Resource
## A passive skill that provides permanent or conditional bonuses.

## Unique identifier.
@export var id: String = ""
## Display name shown to players.
@export var display_name: String = ""
## Description of what this passive does.
@export_multiline var description: String = ""
## Icon for this passive skill.
@export var icon: Texture2D

## --- Effects ---
## Stat bonuses provided. Maps stat ID -> flat bonus value.
@export var stat_bonuses: Dictionary = {}
## Percentage stat bonuses. Maps stat ID -> percentage (e.g., 0.1 = +10%).
@export var stat_percent_bonuses: Dictionary = {}
## Element resistance bonuses. Maps element -> resistance value.
@export var element_resistances: Dictionary = {}
## Status effect resistances. Maps status -> resistance chance (0-1).
@export var status_resistances: Dictionary = {}
## Special flags (e.g., "double_exp", "reduce_encounter_rate", "auto_revive").
@export var special_flags: Array[String] = []

## --- Conditions ---
## When this passive activates.
@export_enum("Always", "In Battle", "In Field", "HP Below 25%", "HP Full", "Alone", "Custom") var activation_condition: String = "Always"
## Custom condition expression (used when activation_condition = "Custom").
@export var custom_condition: String = ""

## --- Requirements ---
## Level required to unlock this passive.
@export var level_requirement: int = 1
## Other passives required before this one (prerequisite IDs).
@export var prerequisites: Array[String] = []
## Maximum rank/level of this passive (for upgradeable passives).
@export var max_rank: int = 1

## --- Custom ---
## Store any additional data your project needs. ForgeKit will not touch this.
@export var custom_data: Dictionary = {}

func _to_string() -> String:
	return display_name if display_name else id
