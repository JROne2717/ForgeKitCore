@tool
class_name FKStat
extends Resource
## A base stat used in the RPG system (e.g., Strength, Dexterity, Intelligence).

## Unique identifier for this stat.
@export var id: String = ""
## Display name shown to players.
@export var display_name: String = ""
## Description of what this stat does.
@export_multiline var description: String = ""
## Minimum possible value for this stat.
@export var min_value: float = 0.0
## Maximum possible value for this stat.
@export var max_value: float = 999.0
## Default starting value.
@export var default_value: float = 10.0
## Icon for this stat (optional).
@export var icon: Texture2D
## Color used in UI for this stat.
@export var color: Color = Color.WHITE

## --- Custom ---
## Store any additional data your project needs. ForgeKit will not touch this.
@export var custom_data: Dictionary = {}

func _to_string() -> String:
	return display_name if display_name else id
