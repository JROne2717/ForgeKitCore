@tool
extends AcceptDialog
## Data validation dialog for ForgeKit resources.
## Scans all resources in rpg_data/ and reports errors, warnings, and balance issues.

var editor_plugin: EditorPlugin
var _results_label: RichTextLabel
var _summary_label: Label
var _error_count: int = 0
var _warning_count: int = 0
var _plain_text: String = ""

# All known resource types and their scripts
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


func _ready() -> void:
	title = "ForgeKit Data Validator"
	min_size = Vector2i(800, 600)
	get_ok_button().visible = false
	add_cancel_button("Close")
	_build_ui()


func _build_ui() -> void:
	var root_vbox := VBoxContainer.new()
	root_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(root_vbox)

	# Toolbar
	var toolbar := HBoxContainer.new()
	toolbar.custom_minimum_size = Vector2(0, 36)
	root_vbox.add_child(toolbar)

	var run_btn := Button.new()
	run_btn.text = "Run Validation"
	run_btn.custom_minimum_size = Vector2(120, 0)
	run_btn.pressed.connect(_run_validation)
	toolbar.add_child(run_btn)

	var copy_btn := Button.new()
	copy_btn.text = "Copy Results"
	copy_btn.custom_minimum_size = Vector2(100, 0)
	copy_btn.pressed.connect(_copy_results)
	toolbar.add_child(copy_btn)

	toolbar.add_child(VSeparator.new())

	_summary_label = Label.new()
	_summary_label.text = "Click 'Run Validation' to scan all resources."
	_summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(_summary_label)

	# Results
	_results_label = RichTextLabel.new()
	_results_label.bbcode_enabled = true
	_results_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_results_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_results_label.custom_minimum_size = Vector2(0, 400)
	_results_label.scroll_following = true
	root_vbox.add_child(_results_label)


# =============================================================================
# VALIDATION ENGINE
# =============================================================================

func _run_validation() -> void:
	_error_count = 0
	_warning_count = 0
	_plain_text = ""
	_results_label.clear()
	_results_label.text = ""

	_add_header("ForgeKit Data Validation Report")
	_add_info("Scanning res://rpg_data/ ...")

	# Load all resources by type
	var all_resources: Dictionary = {}  # type_name -> Array of {resource, path}
	var all_ids: Dictionary = {}  # type_name -> Dictionary of {id -> path}

	for type_name: String in RESOURCE_TYPES:
		var dir_path: String = "res://rpg_data/" + type_name.to_snake_case() + "/"
		var resources: Array = []

		if DirAccess.dir_exists_absolute(dir_path):
			var dir := DirAccess.open(dir_path)
			if dir:
				dir.list_dir_begin()
				var file: String = dir.get_next()
				while file != "":
					if file.ends_with(".tres"):
						var full_path: String = dir_path + file
						var res: Resource = load(full_path)
						if res:
							resources.append({"resource": res, "path": full_path})
					file = dir.get_next()

		all_resources[type_name] = resources

		# Build ID lookup
		var id_map: Dictionary = {}
		for entry: Variant in resources:
			var e: Dictionary = entry
			var res: Resource = e["resource"]
			if "id" in res:
				var res_id: String = res.get("id")
				if res_id and not res_id.is_empty():
					if id_map.has(res_id):
						_add_error(type_name + ": Duplicate ID '" + res_id + "' found in:\n  - " + str(id_map[res_id]) + "\n  - " + str(e["path"]))
					else:
						id_map[res_id] = e["path"]
		all_ids[type_name] = id_map

	# Run validation checks per type
	_add_header("Checking Required Fields...")
	for type_name: String in all_resources:
		for entry: Variant in all_resources[type_name]:
			var e: Dictionary = entry
			var res: Resource = e["resource"]
			var path: String = e["path"]
			_validate_required_fields(res, type_name, path)

	_add_header("Checking Resource References...")
	for type_name: String in all_resources:
		for entry: Variant in all_resources[type_name]:
			var e: Dictionary = entry
			var res: Resource = e["resource"]
			var path: String = e["path"]
			_validate_resource_refs(res, type_name, path)

	_add_header("Checking String ID References...")
	for type_name: String in all_resources:
		for entry: Variant in all_resources[type_name]:
			var e: Dictionary = entry
			var res: Resource = e["resource"]
			var path: String = e["path"]
			_validate_string_id_refs(res, type_name, path, all_ids)

	_add_header("Checking Empty Collections...")
	for type_name: String in all_resources:
		for entry: Variant in all_resources[type_name]:
			var e: Dictionary = entry
			var res: Resource = e["resource"]
			var path: String = e["path"]
			_validate_empty_collections(res, type_name, path)

	_add_header("Balance Warnings...")
	for type_name: String in all_resources:
		for entry: Variant in all_resources[type_name]:
			var e: Dictionary = entry
			var res: Resource = e["resource"]
			var path: String = e["path"]
			_validate_balance(res, type_name, path)

	# Summary
	_add_header("Summary")
	var total_resources: int = 0
	for type_name: String in all_resources:
		var count: int = all_resources[type_name].size()
		total_resources += count
		if count > 0:
			_add_info(type_name + ": " + str(count) + " resource(s)")

	_add_info("")
	if _error_count == 0 and _warning_count == 0:
		_add_info("[color=green]All " + str(total_resources) + " resources passed validation![/color]")
	else:
		_add_info("Total: " + str(total_resources) + " resources scanned.")

	_summary_label.text = str(_error_count) + " error(s), " + str(_warning_count) + " warning(s)"


func _validate_required_fields(res: Resource, type_name: String, path: String) -> void:
	var label: String = type_name + " (" + path.get_file() + ")"

	# All FK types should have id and display_name
	if "id" in res:
		var id_val: String = res.get("id")
		if id_val.is_empty():
			_add_error(label + ": 'id' is empty")

	if "display_name" in res:
		var dn_val: String = res.get("display_name")
		if dn_val.is_empty():
			_add_warning(label + ": 'display_name' is empty")


func _validate_resource_refs(res: Resource, type_name: String, path: String) -> void:
	var label: String = type_name + " (" + path.get_file() + ")"

	match type_name:
		"FKEnemy":
			# loot_table (Resource)
			_check_resource_ref_field(res, "loot_table", label, false)
			# abilities (Array[Resource])
			_check_resource_array_field(res, "abilities", label)
			# guaranteed_drops (Array[Resource])
			_check_resource_array_field(res, "guaranteed_drops", label)

		"FKClass":
			# skill_tree (Resource)
			_check_resource_ref_field(res, "skill_tree", label, false)
			# passive_skills (Array[Resource])
			_check_resource_array_field(res, "passive_skills", label)

		"FKZone":
			# encounter_table (Resource)
			_check_resource_ref_field(res, "encounter_table", label, false)

		"FKQuest":
			# accept_dialogue, complete_dialogue, progress_dialogue
			_check_resource_ref_field(res, "accept_dialogue", label, false)
			_check_resource_ref_field(res, "complete_dialogue", label, false)
			_check_resource_ref_field(res, "progress_dialogue", label, false)
			# ability_rewards (Array[Resource])
			_check_resource_array_field(res, "ability_rewards", label)

		"FKLootTable":
			# entries[].item
			if "entries" in res:
				var entries: Array = res.get("entries")
				for i in range(entries.size()):
					var entry: Dictionary = entries[i]
					var item: Variant = entry.get("item", null)
					if item == null:
						_add_error(label + ": entries[" + str(i) + "].item is null")
					elif item is Resource:
						if (item as Resource).resource_path.is_empty():
							_add_error(label + ": entries[" + str(i) + "].item has no resource path")

		"FKEncounterTable":
			# entries[].enemies
			if "entries" in res:
				var entries: Array = res.get("entries")
				for i in range(entries.size()):
					var entry: Dictionary = entries[i]
					var enemies: Variant = entry.get("enemies", [])
					if enemies is Array:
						for j in range((enemies as Array).size()):
							var enemy: Variant = (enemies as Array)[j]
							if enemy == null:
								_add_error(label + ": entries[" + str(i) + "].enemies[" + str(j) + "] is null")


func _check_resource_ref_field(res: Resource, field: String, label: String, required: bool) -> void:
	if not (field in res):
		return
	var val: Variant = res.get(field)
	if val == null:
		if required:
			_add_error(label + ": '" + field + "' is null (required)")
		# Optional refs being null is fine
		return
	if val is Resource:
		var ref_res: Resource = val
		if ref_res.resource_path.is_empty():
			_add_warning(label + ": '" + field + "' resource has no saved path")


func _check_resource_array_field(res: Resource, field: String, label: String) -> void:
	if not (field in res):
		return
	var arr: Variant = res.get(field)
	if arr == null or not (arr is Array):
		return
	var typed_arr: Array = arr
	for i in range(typed_arr.size()):
		var item: Variant = typed_arr[i]
		if item == null:
			_add_error(label + ": '" + field + "[" + str(i) + "]' is null")
		elif item is Resource:
			if (item as Resource).resource_path.is_empty():
				_add_warning(label + ": '" + field + "[" + str(i) + "]' has no saved path")


func _validate_string_id_refs(res: Resource, type_name: String, path: String, all_ids: Dictionary) -> void:
	var label: String = type_name + " (" + path.get_file() + ")"

	match type_name:
		"FKSkillTree":
			# nodes[].prerequisites[] should reference valid node IDs within the same tree
			if "nodes" in res:
				var nodes: Array = res.get("nodes")
				var node_ids: Dictionary = {}
				for node: Variant in nodes:
					var nd: Dictionary = node
					var nid: String = nd.get("id", "")
					if not nid.is_empty():
						node_ids[nid] = true

				for node: Variant in nodes:
					var nd: Dictionary = node
					var nid: String = nd.get("id", "")
					var prereqs: Array = nd.get("prerequisites", [])
					for prereq: Variant in prereqs:
						var pid: String = str(prereq)
						if not node_ids.has(pid):
							_add_error(label + ": node '" + nid + "' has prerequisite '" + pid + "' which doesn't exist in this skill tree")

		"FKQuest":
			# prerequisite_quests[] should reference valid FKQuest IDs
			if "prerequisite_quests" in res:
				var prereqs: Array = res.get("prerequisite_quests")
				var quest_ids: Dictionary = all_ids.get("FKQuest", {})
				for prereq: Variant in prereqs:
					var pid: String = str(prereq)
					if not quest_ids.has(pid):
						_add_warning(label + ": prerequisite quest '" + pid + "' not found in rpg_data")

		"FKZone":
			# connections[].zone_id should reference valid FKZone IDs
			if "connections" in res:
				var connections: Array = res.get("connections")
				var zone_ids: Dictionary = all_ids.get("FKZone", {})
				for conn: Variant in connections:
					var cd: Dictionary = conn
					var zone_id: String = cd.get("zone_id", "")
					if not zone_id.is_empty() and not zone_ids.has(zone_id):
						_add_warning(label + ": connection to zone '" + zone_id + "' not found in rpg_data")


func _validate_empty_collections(res: Resource, type_name: String, path: String) -> void:
	var label: String = type_name + " (" + path.get_file() + ")"

	match type_name:
		"FKLootTable":
			if "entries" in res:
				var entries: Array = res.get("entries")
				if entries.is_empty():
					_add_warning(label + ": loot table has no entries")

		"FKEncounterTable":
			if "entries" in res:
				var entries: Array = res.get("entries")
				if entries.is_empty():
					_add_warning(label + ": encounter table has no entries")

		"FKSkillTree":
			if "nodes" in res:
				var nodes: Array = res.get("nodes")
				if nodes.is_empty():
					_add_warning(label + ": skill tree has no nodes")

		"FKDialogue":
			if "nodes" in res:
				var nodes: Array = res.get("nodes")
				if nodes.is_empty():
					_add_warning(label + ": dialogue has no nodes")

		"FKClass":
			if "base_stats" in res:
				var stats: Dictionary = res.get("base_stats")
				if stats.is_empty():
					_add_warning(label + ": class has no base stats defined")


func _validate_balance(res: Resource, type_name: String, path: String) -> void:
	var label: String = type_name + " (" + path.get_file() + ")"

	match type_name:
		"FKEnemy":
			if "exp_reward" in res:
				var exp_val: int = res.get("exp_reward")
				if exp_val <= 0:
					_add_warning(label + ": enemy has 0 exp reward")
			if "gold_reward" in res:
				var gold_val: int = res.get("gold_reward")
				if gold_val <= 0:
					_add_warning(label + ": enemy has 0 gold reward")

		"FKItem":
			if "buy_price" in res and "sell_price" in res:
				var buy: int = res.get("buy_price")
				var sell: int = res.get("sell_price")
				if buy > 0 and sell == 0:
					_add_warning(label + ": item has buy price (" + str(buy) + ") but 0 sell price")
				if sell > buy and buy > 0:
					_add_warning(label + ": item sell price (" + str(sell) + ") exceeds buy price (" + str(buy) + ")")

		"FKAbility":
			if "ability_type" in res and "base_power" in res:
				var atype: String = res.get("ability_type")
				var power: float = res.get("base_power")
				if atype in ["Physical", "Magical", "Hybrid"] and power <= 0.0:
					_add_warning(label + ": " + atype + " ability has 0 base power")
			if "mp_cost" in res and "hp_cost" in res and "tp_cost" in res:
				var mp: int = res.get("mp_cost")
				var hp: int = res.get("hp_cost")
				var tp: int = res.get("tp_cost")
				if mp == 0 and hp == 0 and tp == 0:
					var atype: String = res.get("ability_type") if "ability_type" in res else ""
					if atype in ["Physical", "Magical", "Hybrid", "Healing"]:
						_add_warning(label + ": ability has no cost (MP/HP/TP all 0)")


# =============================================================================
# OUTPUT HELPERS
# =============================================================================

func _add_error(text: String) -> void:
	_error_count += 1
	_results_label.append_text("[color=red]ERROR: " + text + "[/color]\n")
	_plain_text += "ERROR: " + text + "\n"


func _add_warning(text: String) -> void:
	_warning_count += 1
	_results_label.append_text("[color=yellow]WARNING: " + text + "[/color]\n")
	_plain_text += "WARNING: " + text + "\n"


func _add_info(text: String) -> void:
	_results_label.append_text(text + "\n")
	_plain_text += text + "\n"


func _add_header(text: String) -> void:
	_results_label.append_text("\n[color=cyan][b]--- " + text + " ---[/b][/color]\n")
	_plain_text += "\n--- " + text + " ---\n"


func _copy_results() -> void:
	DisplayServer.clipboard_set(_plain_text)
	_summary_label.text = "Results copied to clipboard!"
