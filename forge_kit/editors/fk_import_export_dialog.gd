@tool
extends AcceptDialog
## Import/Export dialog for ForgeKit resources.
## Exports resources to JSON and imports from JSON files.

var editor_plugin: EditorPlugin
var _type_option: OptionButton
var _log_label: RichTextLabel

const RESOURCE_TYPES := {
	"FKStat": "res://addons/forge_kit/resources/fk_stat.gd",
	"FKDerivedStat": "res://addons/forge_kit/resources/fk_derived_stat.gd",
	"FKClass": "res://addons/forge_kit/resources/fk_class.gd",
	"FKEnemy": "res://addons/forge_kit/resources/fk_enemy.gd",
	"FKItem": "res://addons/forge_kit/resources/fk_item.gd",
	"FKAbility": "res://addons/forge_kit/resources/fk_ability.gd",
	"FKPassiveSkill": "res://addons/forge_kit/resources/fk_passive_skill.gd",
	"FKSkillTree": "res://addons/forge_kit/resources/fk_skill_tree.gd",
	"FKLootTable": "res://addons/forge_kit/resources/fk_loot_table.gd",
	"FKEncounterTable": "res://addons/forge_kit/resources/fk_encounter_table.gd",
	"FKZone": "res://addons/forge_kit/resources/fk_zone.gd",
	"FKDialogue": "res://addons/forge_kit/resources/fk_dialogue.gd",
	"FKQuest": "res://addons/forge_kit/resources/fk_quest.gd",
}

# Properties to skip during serialization (internal/non-exportable)
const SKIP_PROPERTIES := ["resource_local_to_scene", "resource_path", "resource_name",
	"resource_scene_unique_id", "script", "RefCounted", "resource"]


func _ready() -> void:
	title = "ForgeKit Import / Export"
	min_size = Vector2i(700, 500)
	get_ok_button().visible = false
	add_cancel_button("Close")
	_build_ui()


func _build_ui() -> void:
	var root_vbox := VBoxContainer.new()
	root_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(root_vbox)

	# --- Export Section ---
	var export_label := Label.new()
	export_label.text = "Export Resources to JSON"
	export_label.add_theme_font_size_override("font_size", 15)
	root_vbox.add_child(export_label)

	var export_hbox := HBoxContainer.new()
	root_vbox.add_child(export_hbox)

	var type_label := Label.new()
	type_label.text = "Type:"
	export_hbox.add_child(type_label)

	_type_option = OptionButton.new()
	_type_option.add_item("All Types", 0)
	var idx: int = 1
	for type_name: String in RESOURCE_TYPES:
		_type_option.add_item(type_name, idx)
		idx += 1
	_type_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	export_hbox.add_child(_type_option)

	var export_btn := Button.new()
	export_btn.text = "Export to JSON..."
	export_btn.custom_minimum_size = Vector2(140, 0)
	export_btn.pressed.connect(_on_export)
	export_hbox.add_child(export_btn)

	root_vbox.add_child(HSeparator.new())

	# --- Import Section ---
	var import_label := Label.new()
	import_label.text = "Import Resources from JSON"
	import_label.add_theme_font_size_override("font_size", 15)
	root_vbox.add_child(import_label)

	var import_info := Label.new()
	import_info.text = "Import will create new .tres files in rpg_data/ folders.\nExisting files with the same name will be overwritten."
	import_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	import_info.add_theme_font_size_override("font_size", 11)
	root_vbox.add_child(import_info)

	var import_btn := Button.new()
	import_btn.text = "Import from JSON..."
	import_btn.custom_minimum_size = Vector2(140, 0)
	import_btn.pressed.connect(_on_import)
	root_vbox.add_child(import_btn)

	root_vbox.add_child(HSeparator.new())

	# --- Log ---
	var log_header := Label.new()
	log_header.text = "Log"
	log_header.add_theme_font_size_override("font_size", 13)
	root_vbox.add_child(log_header)

	_log_label = RichTextLabel.new()
	_log_label.bbcode_enabled = true
	_log_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_log_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_log_label.custom_minimum_size = Vector2(0, 200)
	_log_label.scroll_following = true
	root_vbox.add_child(_log_label)


# =============================================================================
# EXPORT
# =============================================================================

func _on_export() -> void:
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.title = "Export Resources to JSON"
	dialog.add_filter("*.json ; JSON File")
	dialog.current_file = "forgekit_export.json"

	dialog.file_selected.connect(func(path: String):
		_do_export(path)
		dialog.queue_free()
	)
	dialog.canceled.connect(func(): dialog.queue_free())

	if editor_plugin:
		editor_plugin.get_editor_interface().get_base_control().add_child(dialog)
	else:
		add_child(dialog)
	dialog.popup_centered(Vector2i(600, 400))


func _do_export(json_path: String) -> void:
	_log("Starting export...")

	var selected_idx: int = _type_option.selected
	var types_to_export: Array[String] = []

	if selected_idx == 0:
		# All types
		for type_name: String in RESOURCE_TYPES:
			types_to_export.append(type_name)
	else:
		var selected_text: String = _type_option.get_item_text(selected_idx)
		types_to_export.append(selected_text)

	var export_data: Array[Dictionary] = []
	var total_count: int = 0

	for type_name: String in types_to_export:
		var dir_path: String = "res://rpg_data/" + type_name.to_snake_case() + "/"
		if not DirAccess.dir_exists_absolute(dir_path):
			continue

		var dir := DirAccess.open(dir_path)
		if not dir:
			continue

		dir.list_dir_begin()
		var file: String = dir.get_next()
		while file != "":
			if file.ends_with(".tres"):
				var full_path: String = dir_path + file
				var res: Resource = load(full_path)
				if res:
					var serialized: Dictionary = _serialize_resource(res, type_name)
					serialized["_type"] = type_name
					serialized["_source_path"] = full_path
					export_data.append(serialized)
					total_count += 1
			file = dir.get_next()

	# Write JSON
	var json_str: String = JSON.stringify(export_data, "\t")
	var file := FileAccess.open(json_path, FileAccess.WRITE)
	if file:
		file.store_string(json_str)
		file.close()
		_log_success("Exported " + str(total_count) + " resources to: " + json_path)
	else:
		_log_error("Failed to write file: " + json_path)


func _serialize_resource(res: Resource, type_name: String) -> Dictionary:
	var data: Dictionary = {}
	var prop_list: Array = res.get_property_list()

	for prop_info: Variant in prop_list:
		var pi: Dictionary = prop_info
		var prop_name: String = pi.get("name", "")
		var usage: int = pi.get("usage", 0)

		# Only export properties with PROPERTY_USAGE_STORAGE flag
		if not (usage & PROPERTY_USAGE_STORAGE):
			continue
		if prop_name in SKIP_PROPERTIES:
			continue
		if prop_name.is_empty():
			continue

		var value: Variant = res.get(prop_name)
		data[prop_name] = _serialize_value(value)

	return data


func _serialize_value(value: Variant) -> Variant:
	if value == null:
		return null

	if value is Resource:
		var res: Resource = value
		if res.resource_path and not res.resource_path.is_empty():
			return {"_resource_path": res.resource_path}
		return null

	if value is Vector2:
		var v: Vector2 = value
		return {"_type_hint": "Vector2", "x": v.x, "y": v.y}

	if value is Vector2i:
		var v: Vector2i = value
		return {"_type_hint": "Vector2i", "x": v.x, "y": v.y}

	if value is Color:
		var c: Color = value
		return {"_type_hint": "Color", "r": c.r, "g": c.g, "b": c.b, "a": c.a}

	if value is Array:
		var arr: Array = value
		var result: Array = []
		for item: Variant in arr:
			result.append(_serialize_value(item))
		return result

	if value is Dictionary:
		var dict: Dictionary = value
		var result: Dictionary = {}
		for key: Variant in dict:
			result[str(key)] = _serialize_value(dict[key])
		return result

	# Primitives: int, float, String, bool
	return value


# =============================================================================
# IMPORT
# =============================================================================

func _on_import() -> void:
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.title = "Import Resources from JSON"
	dialog.add_filter("*.json ; JSON File")

	dialog.file_selected.connect(func(path: String):
		_do_import(path)
		dialog.queue_free()
	)
	dialog.canceled.connect(func(): dialog.queue_free())

	if editor_plugin:
		editor_plugin.get_editor_interface().get_base_control().add_child(dialog)
	else:
		add_child(dialog)
	dialog.popup_centered(Vector2i(600, 400))


func _do_import(json_path: String) -> void:
	_log("Starting import from: " + json_path)

	var file := FileAccess.open(json_path, FileAccess.READ)
	if not file:
		_log_error("Failed to open file: " + json_path)
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json := JSON.new()
	var err: Error = json.parse(json_text)
	if err != OK:
		_log_error("JSON parse error at line " + str(json.get_error_line()) + ": " + json.get_error_message())
		return

	var data: Variant = json.data
	if not (data is Array):
		_log_error("Expected JSON root to be an array")
		return

	var entries: Array = data
	var success_count: int = 0
	var fail_count: int = 0

	for entry_data: Variant in entries:
		if not (entry_data is Dictionary):
			_log_error("Skipping non-dictionary entry")
			fail_count += 1
			continue

		var entry: Dictionary = entry_data
		var type_name: String = entry.get("_type", "")
		if type_name.is_empty():
			_log_error("Entry missing '_type' field, skipping")
			fail_count += 1
			continue

		if not RESOURCE_TYPES.has(type_name):
			_log_error("Unknown type '" + type_name + "', skipping")
			fail_count += 1
			continue

		var result: Resource = _deserialize_resource(entry, type_name)
		if not result:
			_log_error("Failed to deserialize " + type_name + " entry")
			fail_count += 1
			continue

		# Determine save path
		var res_id: String = ""
		if "id" in result:
			res_id = result.get("id")
		if res_id.is_empty():
			res_id = "imported_" + str(randi())

		var save_dir: String = "res://rpg_data/" + type_name.to_snake_case() + "/"
		if not DirAccess.dir_exists_absolute(save_dir):
			DirAccess.make_dir_recursive_absolute(save_dir)

		var save_path: String = save_dir + res_id + ".tres"
		var save_err: Error = ResourceSaver.save(result, save_path)
		if save_err == OK:
			success_count += 1
			_log("  Imported: " + type_name + " -> " + save_path)
		else:
			fail_count += 1
			_log_error("  Failed to save: " + save_path)

	_log_success("Import complete: " + str(success_count) + " succeeded, " + str(fail_count) + " failed")

	# Trigger filesystem scan
	if editor_plugin:
		editor_plugin.get_editor_interface().get_resource_filesystem().scan()


func _deserialize_resource(data: Dictionary, type_name: String) -> Resource:
	var script_path: String = RESOURCE_TYPES.get(type_name, "")
	if script_path.is_empty():
		return null

	var script: Variant = load(script_path)
	if not script:
		return null

	var res: Resource = script.new()
	if not res:
		return null

	for key: String in data:
		if key.begins_with("_"):
			continue  # Skip meta fields (_type, _source_path)
		if not (key in res):
			continue  # Skip unknown properties

		var raw_value: Variant = data[key]
		var deserialized: Variant = _deserialize_value(raw_value)
		res.set(key, deserialized)

	return res


func _deserialize_value(value: Variant) -> Variant:
	if value == null:
		return null

	if value is Dictionary:
		var dict: Dictionary = value

		# Check for resource path reference
		if dict.has("_resource_path"):
			var res_path: String = dict["_resource_path"]
			if ResourceLoader.exists(res_path):
				return load(res_path)
			return null

		# Check for type hints
		var type_hint: String = dict.get("_type_hint", "")
		match type_hint:
			"Vector2":
				return Vector2(dict.get("x", 0.0), dict.get("y", 0.0))
			"Vector2i":
				return Vector2i(int(dict.get("x", 0)), int(dict.get("y", 0)))
			"Color":
				return Color(dict.get("r", 1.0), dict.get("g", 1.0), dict.get("b", 1.0), dict.get("a", 1.0))

		# Regular dictionary  - deserialize values recursively
		var result: Dictionary = {}
		for k: String in dict:
			result[k] = _deserialize_value(dict[k])
		return result

	if value is Array:
		var arr: Array = value
		var result: Array = []
		for item: Variant in arr:
			result.append(_deserialize_value(item))
		return result

	# Primitives pass through
	return value


# =============================================================================
# LOG HELPERS
# =============================================================================

func _log(text: String) -> void:
	_log_label.append_text(text + "\n")


func _log_success(text: String) -> void:
	_log_label.append_text("[color=green]" + text + "[/color]\n")


func _log_error(text: String) -> void:
	_log_label.append_text("[color=red]" + text + "[/color]\n")
