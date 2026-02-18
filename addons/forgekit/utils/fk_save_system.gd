class_name FKSaveSystem
extends RefCounted
## Simple save/load system for RPG game data.
## Handles saving and loading player progress, inventory, quest state, etc.

const SAVE_DIR := "user://saves/"
const SAVE_EXTENSION := ".rpgsave"

## Save game data to a slot.
static func save_game(slot: int, data: Dictionary) -> Error:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

	var path := SAVE_DIR + "slot_" + str(slot) + SAVE_EXTENSION
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return FileAccess.get_open_error()

	# Add metadata
	data["_save_time"] = Time.get_datetime_string_from_system()
	data["_save_version"] = 1

	var json := JSON.stringify(data, "\t")
	file.store_string(json)
	return OK


## Load game data from a slot.
static func load_game(slot: int) -> Dictionary:
	var path := SAVE_DIR + "slot_" + str(slot) + SAVE_EXTENSION
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}

	var json_text := file.get_as_text()
	var json := JSON.new()
	if json.parse(json_text) != OK:
		return {}

	return json.data if json.data is Dictionary else {}


## Check if a save slot has data.
static func slot_exists(slot: int) -> bool:
	var path := SAVE_DIR + "slot_" + str(slot) + SAVE_EXTENSION
	return FileAccess.file_exists(path)


## Get save slot info (time, etc.) without loading full data.
static func get_slot_info(slot: int) -> Dictionary:
	var data := load_game(slot)
	if data.is_empty():
		return {}
	return {
		"save_time": data.get("_save_time", "Unknown"),
		"player_name": data.get("player_name", "Unknown"),
		"level": data.get("level", 0),
		"playtime": data.get("playtime", 0),
	}


## Delete a save slot.
static func delete_slot(slot: int) -> Error:
	var path := SAVE_DIR + "slot_" + str(slot) + SAVE_EXTENSION
	if FileAccess.file_exists(path):
		return DirAccess.remove_absolute(path)
	return OK


## Get all save slot numbers that have data.
static func get_used_slots() -> Array[int]:
	var slots: Array[int] = []
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		return slots

	var dir := DirAccess.open(SAVE_DIR)
	if not dir:
		return slots

	dir.list_dir_begin()
	var file := dir.get_next()
	while file != "":
		if file.begins_with("slot_") and file.ends_with(SAVE_EXTENSION):
			var slot_str := file.trim_prefix("slot_").trim_suffix(SAVE_EXTENSION)
			if slot_str.is_valid_int():
				slots.append(int(slot_str))
		file = dir.get_next()
	slots.sort()
	return slots
