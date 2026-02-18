@tool
class_name FKDialogue
extends Resource
## Defines a dialogue tree with branching conversations, choices, and conditions.

## Unique identifier.
@export var id: String = ""
## Display name (e.g., character name or conversation topic).
@export var display_name: String = ""
## Speaker/NPC name.
@export var speaker_name: String = ""
## Speaker portrait.
@export var speaker_portrait: Texture2D

## --- Dialogue Nodes ---
## Array of dialogue nodes. Each node is a dictionary:
## {
##   "id": "node_0",
##   "type": "text" | "choice" | "condition" | "action" | "end",
##   "speaker": "NPC Name",
##   "portrait": Texture2D or null,
##   "text": "Hello, adventurer!",
##   "choices": [
##     {"text": "Tell me more", "next": "node_2", "condition": ""},
##     {"text": "Goodbye", "next": "node_end"}
##   ],
##   "next": "node_1",              # for linear text nodes
##   "condition": "has_item:key_1", # for condition nodes
##   "true_next": "node_3",
##   "false_next": "node_4",
##   "action": "give_item:potion",  # for action nodes
##   "emotion": "happy"             # optional emotion tag
## }
@export var nodes: Array[Dictionary] = []

## --- Variables ---
## Local dialogue variables that persist within this conversation.
@export var local_variables: Dictionary = {}

## --- Settings ---
## Auto-advance text (no player input needed).
@export var auto_advance: bool = false
## Text speed multiplier (1.0 = normal).
@export var text_speed: float = 1.0
## Can the player skip this dialogue?
@export var skippable: bool = true

## --- Custom ---
## Store any additional data your project needs. ForgeKit will not touch this.
@export var custom_data: Dictionary = {}

## Get the starting node.
func get_start_node() -> Dictionary:
	if nodes.is_empty():
		return {}
	return nodes[0]

## Find a node by its ID.
func get_node_by_id(node_id: String) -> Dictionary:
	for node in nodes:
		if node.get("id", "") == node_id:
			return node
	return {}

## Get the next node from a given node (for linear progression).
func get_next_node(current_id: String) -> Dictionary:
	var current := get_node_by_id(current_id)
	if current.is_empty():
		return {}
	var next_id: String = current.get("next", "")
	if next_id.is_empty():
		return {}
	return get_node_by_id(next_id)

func _to_string() -> String:
	return display_name if display_name else id
