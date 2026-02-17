@tool
class_name FKQuest
extends Resource
## Defines a quest/mission with objectives, rewards, and branching paths.

## Unique identifier.
@export var id: String = ""
## Display name shown to players.
@export var display_name: String = ""
## Short summary shown in quest log.
@export_multiline var summary: String = ""
## Full description/lore.
@export_multiline var description: String = ""
## Quest icon.
@export var icon: Texture2D

## --- Type ---
@export_enum("Main Story", "Side Quest", "Daily", "Repeatable", "Hidden", "Tutorial") var quest_type: String = "Side Quest"
## Quest chain this belongs to (empty = standalone).
@export var quest_chain: String = ""
## Order within the quest chain.
@export var chain_order: int = 0

## --- Requirements ---
## Minimum level to accept this quest.
@export var level_requirement: int = 1
## Quests that must be completed before this one is available.
@export var prerequisite_quests: Array[String] = []
## Items required to start this quest.
@export var required_items_to_start: Array[Dictionary] = []
## Classes that can accept this quest. Empty = all.
@export var class_restrictions: Array[String] = []

## --- Objectives ---
## Array of quest objectives. Each is a dictionary:
## {
##   "id": "obj_1",
##   "type": "kill" | "collect" | "talk" | "reach" | "escort" | "interact" | "custom",
##   "description": "Defeat 5 Slimes",
##   "target": "slime",
##   "count": 5,
##   "optional": false,
##   "hidden": false,  # hidden until discovered
##   "zone": ""        # specific zone where objective must be completed
## }
@export var objectives: Array[Dictionary] = []

## --- Rewards ---
## Experience points awarded on completion.
@export var exp_reward: int = 0
## Gold awarded on completion.
@export var gold_reward: int = 0
## Items awarded on completion. Array of {"item": FKItem, "quantity": int}.
@export var item_rewards: Array[Dictionary] = []
## Abilities unlocked on completion.
@export var ability_rewards: Array[Resource] = []  # FKAbility resources
## Quest unlocked on completion (next quest in chain).
@export var unlocks_quest: String = ""

## --- Optional/Bonus ---
## Bonus rewards for completing optional objectives.
@export var bonus_exp: int = 0
@export var bonus_gold: int = 0
@export var bonus_items: Array[Dictionary] = []

## --- Settings ---
## Time limit in seconds (0 = no time limit).
@export var time_limit: float = 0.0
## Can this quest be abandoned?
@export var abandonable: bool = true
## Can this quest be repeated after completion?
@export var repeatable: bool = false
## Cooldown before quest can be repeated (in seconds, 0 = immediate).
@export var repeat_cooldown: float = 0.0
## Does failing/abandoning this quest have consequences?
@export var fail_consequences: Dictionary = {}

## --- Dialogue ---
## Dialogue shown when accepting the quest.
@export var accept_dialogue: Resource  # FKDialogue
## Dialogue shown when turning in the quest.
@export var complete_dialogue: Resource  # FKDialogue
## Dialogue shown while quest is in progress.
@export var progress_dialogue: Resource  # FKDialogue

## Check if all non-optional objectives are met given a progress dictionary.
## progress maps objective_id -> current_count.
func is_complete(progress: Dictionary) -> bool:
	for obj in objectives:
		if obj.get("optional", false):
			continue
		var obj_id: String = obj.get("id", "")
		var required: int = obj.get("count", 1)
		var current: int = progress.get(obj_id, 0)
		if current < required:
			return false
	return true

## Check if all objectives including optional are met.
func is_fully_complete(progress: Dictionary) -> bool:
	for obj in objectives:
		var obj_id: String = obj.get("id", "")
		var required: int = obj.get("count", 1)
		var current: int = progress.get(obj_id, 0)
		if current < required:
			return false
	return true

func _to_string() -> String:
	return display_name if display_name else id
