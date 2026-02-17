class_name FKDatabase
extends RefCounted
## Utility class for loading and managing all RPG resources from the project.
## Provides a centralized way to access all game data at runtime.

## Cached resources by type and ID.
var _cache: Dictionary = {}

## Base path where RPG data is stored.
var base_path: String = "res://rpg_data/"

## Load all resources of a given type from disk.
func load_all(resource_type: String) -> Array[Resource]:
	var dir_path := base_path + resource_type.to_snake_case() + "/"
	var results: Array[Resource] = []

	if not DirAccess.dir_exists_absolute(dir_path):
		return results

	var dir := DirAccess.open(dir_path)
	if not dir:
		return results

	dir.list_dir_begin()
	var file := dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var res := load(dir_path + file)
			if res:
				results.append(res)
				# Cache by ID if it has one
				if "id" in res and res.id:
					if not _cache.has(resource_type):
						_cache[resource_type] = {}
					_cache[resource_type][res.id] = res
		file = dir.get_next()
	return results


## Get a specific resource by type and ID (loads from cache or disk).
func get_resource(resource_type: String, id: String) -> Resource:
	# Check cache first
	if _cache.has(resource_type) and _cache[resource_type].has(id):
		return _cache[resource_type][id]

	# Load all of this type to populate cache
	load_all(resource_type)

	# Try again
	if _cache.has(resource_type) and _cache[resource_type].has(id):
		return _cache[resource_type][id]

	return null


## Shorthand accessors for common types.
func get_stat(id: String) -> FKStat:
	return get_resource("FKStat", id) as FKStat

func get_char_class(id: String) -> FKClass:
	return get_resource("FKClass", id) as FKClass

func get_enemy(id: String) -> FKEnemy:
	return get_resource("FKEnemy", id) as FKEnemy

func get_item(id: String) -> FKItem:
	return get_resource("FKItem", id) as FKItem

func get_ability(id: String) -> FKAbility:
	return get_resource("FKAbility", id) as FKAbility

func get_quest(id: String) -> FKQuest:
	return get_resource("FKQuest", id) as FKQuest

func get_dialogue(id: String) -> FKDialogue:
	return get_resource("FKDialogue", id) as FKDialogue

func get_zone(id: String) -> FKZone:
	return get_resource("FKZone", id) as FKZone


## Get all stats.
func get_all_stats() -> Array[Resource]:
	return load_all("FKStat")

## Get all classes.
func get_all_classes() -> Array[Resource]:
	return load_all("FKClass")

## Get all enemies.
func get_all_enemies() -> Array[Resource]:
	return load_all("FKEnemy")

## Get all items.
func get_all_items() -> Array[Resource]:
	return load_all("FKItem")

## Get all abilities.
func get_all_abilities() -> Array[Resource]:
	return load_all("FKAbility")

## Get all quests.
func get_all_quests() -> Array[Resource]:
	return load_all("FKQuest")

## Clear the cache to force reload from disk.
func clear_cache() -> void:
	_cache.clear()


## Get a summary of all resources in the database.
func get_summary() -> Dictionary:
	var types := ["FKStat", "FKDerivedStat", "FKClass", "FKEnemy", "FKItem",
		"FKAbility", "FKPassiveSkill", "FKSkillTree", "FKLootTable",
		"FKEncounterTable", "FKZone", "FKDialogue", "FKQuest"]
	var summary := {}
	for t in types:
		summary[t] = load_all(t).size()
	return summary
