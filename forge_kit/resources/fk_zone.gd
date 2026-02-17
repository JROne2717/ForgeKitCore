@tool
class_name FKZone
extends Resource
## Defines a game zone/area/map with encounters, NPCs, and connections to other zones.

## Unique identifier.
@export var id: String = ""
## Display name shown to players.
@export var display_name: String = ""
## Description/lore text.
@export_multiline var description: String = ""
## Zone map/thumbnail image.
@export var icon: Texture2D

## --- Type ---
@export_enum("Overworld", "Town", "Dungeon", "Indoor", "Battle Arena", "Safe Zone", "Custom") var zone_type: String = "Overworld"

## --- Encounters ---
## Encounter table for random battles in this zone.
@export var encounter_table: Resource  # FKEncounterTable
## Does this zone have random encounters?
@export var has_encounters: bool = true

## --- Connections ---
## Connected zones. Array of dictionaries:
## {"zone_id": "town_1", "direction": "north", "requirement": "", "position": Vector2(0, 0)}
@export var connections: Array[Dictionary] = []

## --- NPCs & Points of Interest ---
## NPCs in this zone. Array of dictionaries:
## {"name": "Shopkeeper", "type": "shop", "dialogue": FKDialogue, "position": Vector2(0, 0)}
@export var npcs: Array[Dictionary] = []
## Points of interest (chests, switches, events). Array of dictionaries:
## {"id": "chest_1", "type": "chest", "contents": FKLootTable, "position": Vector2(0, 0), "one_time": true}
@export var points_of_interest: Array[Dictionary] = []

## --- Music & Ambiance ---
## Background music for this zone.
@export var bgm: AudioStream
## Ambient sound effect.
@export var ambiance: AudioStream
## Music volume override (-1 = use default).
@export var bgm_volume: float = -1.0

## --- Properties ---
## Recommended player level range.
@export var recommended_level_min: int = 1
@export var recommended_level_max: int = 99
## Can the player save in this zone?
@export var allow_save: bool = true
## Can the player use teleport/escape items?
@export var allow_teleport: bool = true
## Tilemap/scene file for this zone's layout.
@export var scene_path: String = ""

## --- Environmental ---
## Weather/time settings.
@export_enum("None", "Rain", "Snow", "Fog", "Sandstorm", "Custom") var weather: String = "None"
@export_enum("Day", "Night", "Dynamic", "Always Dark", "Always Bright") var lighting: String = "Dynamic"

func _to_string() -> String:
	return display_name if display_name else id
