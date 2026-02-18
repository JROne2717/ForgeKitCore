@tool
extends AcceptDialog
## Damage formula tester for ForgeKit.
## Allows testing ability damage calculations with customizable attacker/defender stats.

var editor_plugin: EditorPlugin

# Ability settings controls
var _base_power_spin: SpinBox
var _scaling_stat_option: OptionButton
var _scale_mult_spin: SpinBox
var _variance_spin: SpinBox
var _crit_bonus_spin: SpinBox
var _hit_count_spin: SpinBox

# Attacker stat controls
var _attacker_stats_container: VBoxContainer
var _stat_spinboxes: Dictionary = {}  # stat_id -> SpinBox

# Defender controls
var _def_spin: SpinBox
var _element_res_spin: SpinBox

# Result labels
var _damage_label: Label
var _breakdown_label: Label
var _crit_label: Label
var _dps_label: Label
var _range_label: Label

# Stat data
var _stat_ids: Array[String] = []


func _ready() -> void:
	title = "Damage Formula Tester"
	min_size = Vector2i(900, 650)
	get_ok_button().visible = false
	add_cancel_button("Close")
	_load_stats()
	_build_ui()
	_recalculate()


func _load_stats() -> void:
	_stat_ids.clear()
	var stat_dir: String = "res://rpg_data/rpg_stat/"
	if not DirAccess.dir_exists_absolute(stat_dir):
		# Fallback defaults
		_stat_ids = ["strength", "dexterity", "intelligence", "wisdom", "vitality"]
		return

	var dir := DirAccess.open(stat_dir)
	if not dir:
		_stat_ids = ["strength", "dexterity", "intelligence", "wisdom", "vitality"]
		return

	dir.list_dir_begin()
	var file: String = dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var res: Resource = load(stat_dir + file)
			if res and "id" in res:
				var stat_id: String = res.get("id")
				if not stat_id.is_empty():
					_stat_ids.append(stat_id)
		file = dir.get_next()

	if _stat_ids.is_empty():
		_stat_ids = ["strength", "dexterity", "intelligence", "wisdom", "vitality"]


func _build_ui() -> void:
	var root_vbox := VBoxContainer.new()
	root_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(root_vbox)

	# --- Top section: 3 columns ---
	var columns := HBoxContainer.new()
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(columns)

	# Column 1: Ability Settings
	var ability_col := VBoxContainer.new()
	ability_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(ability_col)

	var ability_header := Label.new()
	ability_header.text = "Ability Settings"
	ability_header.add_theme_font_size_override("font_size", 14)
	ability_col.add_child(ability_header)

	_base_power_spin = _add_spin_row(ability_col, "Base Power:", 0.0, 9999.0, 50.0, 1.0)
	_base_power_spin.value_changed.connect(func(_v: float): _recalculate())

	# Scaling stat dropdown
	var stat_hbox := HBoxContainer.new()
	var stat_label := Label.new()
	stat_label.text = "Scaling Stat:"
	stat_label.custom_minimum_size = Vector2(90, 0)
	stat_hbox.add_child(stat_label)
	_scaling_stat_option = OptionButton.new()
	_scaling_stat_option.add_item("(None)", 0)
	for i in range(_stat_ids.size()):
		_scaling_stat_option.add_item(_stat_ids[i].capitalize(), i + 1)
	_scaling_stat_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scaling_stat_option.item_selected.connect(func(_idx: int): _recalculate())
	stat_hbox.add_child(_scaling_stat_option)
	ability_col.add_child(stat_hbox)

	_scale_mult_spin = _add_spin_row(ability_col, "Scale Mult:", 0.0, 10.0, 1.0, 0.1)
	_scale_mult_spin.value_changed.connect(func(_v: float): _recalculate())

	_variance_spin = _add_spin_row(ability_col, "Variance:", 0.0, 1.0, 0.1, 0.05)
	_variance_spin.value_changed.connect(func(_v: float): _recalculate())

	_crit_bonus_spin = _add_spin_row(ability_col, "Crit Bonus:", 0.0, 5.0, 0.0, 0.05)
	_crit_bonus_spin.value_changed.connect(func(_v: float): _recalculate())

	_hit_count_spin = _add_spin_row(ability_col, "Hit Count:", 1.0, 20.0, 1.0, 1.0)
	_hit_count_spin.value_changed.connect(func(_v: float): _recalculate())

	var load_ability_btn := Button.new()
	load_ability_btn.text = "Load from Ability..."
	load_ability_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	load_ability_btn.pressed.connect(_on_load_ability)
	ability_col.add_child(load_ability_btn)

	columns.add_child(VSeparator.new())

	# Column 2: Attacker Stats
	var attacker_col := VBoxContainer.new()
	attacker_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(attacker_col)

	var attacker_header := Label.new()
	attacker_header.text = "Attacker Stats"
	attacker_header.add_theme_font_size_override("font_size", 14)
	attacker_col.add_child(attacker_header)

	_attacker_stats_container = VBoxContainer.new()
	attacker_col.add_child(_attacker_stats_container)

	# Create a SpinBox for each stat
	for stat_id: String in _stat_ids:
		var spin: SpinBox = _add_spin_row(_attacker_stats_container, stat_id.capitalize() + ":", 0.0, 999.0, 10.0, 1.0)
		spin.value_changed.connect(func(_v: float): _recalculate())
		_stat_spinboxes[stat_id] = spin

	columns.add_child(VSeparator.new())

	# Column 3: Defender Stats
	var defender_col := VBoxContainer.new()
	defender_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(defender_col)

	var defender_header := Label.new()
	defender_header.text = "Defender / Enemy"
	defender_header.add_theme_font_size_override("font_size", 14)
	defender_col.add_child(defender_header)

	_def_spin = _add_spin_row(defender_col, "Defense:", 0.0, 999.0, 10.0, 1.0)
	_def_spin.value_changed.connect(func(_v: float): _recalculate())

	_element_res_spin = _add_spin_row(defender_col, "Element Mod:", 0.0, 5.0, 1.0, 0.1)
	_element_res_spin.value_changed.connect(func(_v: float): _recalculate())

	var element_info := Label.new()
	element_info.text = "1.0 = neutral, 2.0 = weak\n0.5 = resist, 0.0 = immune"
	element_info.add_theme_font_size_override("font_size", 10)
	element_info.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	defender_col.add_child(element_info)

	defender_col.add_child(HSeparator.new())

	var load_enemy_btn := Button.new()
	load_enemy_btn.text = "Load from Enemy..."
	load_enemy_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	load_enemy_btn.pressed.connect(_on_load_enemy)
	defender_col.add_child(load_enemy_btn)

	# --- Results Section ---
	root_vbox.add_child(HSeparator.new())

	var results_header := Label.new()
	results_header.text = "Results"
	results_header.add_theme_font_size_override("font_size", 15)
	root_vbox.add_child(results_header)

	var results_panel := PanelContainer.new()
	results_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(results_panel)

	var results_vbox := VBoxContainer.new()
	results_panel.add_child(results_vbox)

	_damage_label = Label.new()
	_damage_label.text = "Average Damage: ---"
	_damage_label.add_theme_font_size_override("font_size", 18)
	results_vbox.add_child(_damage_label)

	_range_label = Label.new()
	_range_label.text = "Range: --- to ---"
	_range_label.add_theme_font_size_override("font_size", 13)
	results_vbox.add_child(_range_label)

	_breakdown_label = Label.new()
	_breakdown_label.text = "Breakdown: ---"
	_breakdown_label.add_theme_font_size_override("font_size", 12)
	_breakdown_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	results_vbox.add_child(_breakdown_label)

	_crit_label = Label.new()
	_crit_label.text = "Crit Damage: ---"
	_crit_label.add_theme_font_size_override("font_size", 13)
	results_vbox.add_child(_crit_label)

	_dps_label = Label.new()
	_dps_label.text = "Total (all hits): ---"
	_dps_label.add_theme_font_size_override("font_size", 13)
	results_vbox.add_child(_dps_label)

	root_vbox.add_child(HSeparator.new())

	var recalc_btn := Button.new()
	recalc_btn.text = "Recalculate"
	recalc_btn.custom_minimum_size = Vector2(120, 0)
	recalc_btn.pressed.connect(_recalculate)
	root_vbox.add_child(recalc_btn)


# =============================================================================
# CALCULATION
# =============================================================================

func _recalculate() -> void:
	var base_power: float = _base_power_spin.value
	var scale_mult: float = _scale_mult_spin.value
	var variance: float = _variance_spin.value
	var crit_bonus: float = _crit_bonus_spin.value
	var hit_count: int = int(_hit_count_spin.value)
	var def_val: float = _def_spin.value
	var element_mod: float = _element_res_spin.value

	# Get scaling stat value
	var stat_value: float = 0.0
	var scaling_stat_name: String = "(none)"
	var selected_idx: int = _scaling_stat_option.selected
	if selected_idx > 0 and selected_idx <= _stat_ids.size():
		var stat_id: String = _stat_ids[selected_idx - 1]
		scaling_stat_name = stat_id.capitalize()
		if _stat_spinboxes.has(stat_id):
			stat_value = _stat_spinboxes[stat_id].value

	# Step 1: Raw power
	var raw_power: float = base_power + (stat_value * scale_mult)

	# Step 2: Defense reduction
	var after_defense: float = raw_power * (100.0 / (100.0 + def_val))

	# Step 3: Element modifier
	var after_element: float = after_defense * element_mod

	# Step 4: Variance range
	var min_damage: float = after_element * (1.0 - variance)
	var max_damage: float = after_element * (1.0 + variance)
	var avg_damage: float = after_element

	# Step 5: Crit damage
	var crit_multiplier: float = 1.5 + crit_bonus
	var crit_damage: float = max_damage * crit_multiplier

	# Step 6: Total across hits
	var total_avg: float = avg_damage * hit_count
	var total_min: float = min_damage * hit_count
	var total_max: float = max_damage * hit_count

	# Update labels
	_damage_label.text = "Average Damage: " + str(snapped(avg_damage, 0.1))

	_range_label.text = "Range: " + str(snapped(min_damage, 0.1)) + " to " + str(snapped(max_damage, 0.1))

	var breakdown_parts: Array[String] = []
	breakdown_parts.append("base(" + str(base_power) + ")")
	if stat_value > 0 and scale_mult > 0:
		breakdown_parts.append("+ " + scaling_stat_name + "(" + str(stat_value) + ") x " + str(scale_mult))
	breakdown_parts.append("= raw(" + str(snapped(raw_power, 0.1)) + ")")
	breakdown_parts.append("x def_mod(" + str(snapped(100.0 / (100.0 + def_val), 0.01)) + ")")
	if element_mod != 1.0:
		breakdown_parts.append("x elem(" + str(element_mod) + ")")
	_breakdown_label.text = "Breakdown: " + " ".join(breakdown_parts)

	_crit_label.text = "Crit Damage: " + str(snapped(crit_damage, 0.1)) + " (x" + str(snapped(crit_multiplier, 0.01)) + ")"

	if hit_count > 1:
		_dps_label.text = "Total (" + str(hit_count) + " hits): " + str(snapped(total_avg, 0.1)) + " avg (" + str(snapped(total_min, 0.1)) + " - " + str(snapped(total_max, 0.1)) + ")"
		_dps_label.visible = true
	else:
		_dps_label.visible = false


# =============================================================================
# LOAD FROM RESOURCE
# =============================================================================

func _on_load_ability() -> void:
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_RESOURCES
	dialog.title = "Select Ability Resource"
	dialog.add_filter("*.tres ; Godot Resource")

	var default_dir: String = "res://rpg_data/rpg_ability/"
	if DirAccess.dir_exists_absolute(default_dir):
		dialog.current_dir = default_dir
	else:
		dialog.current_dir = "res://"

	dialog.file_selected.connect(func(path: String):
		var res: Resource = load(path)
		if res:
			_apply_ability(res)
		dialog.queue_free()
	)
	dialog.canceled.connect(func(): dialog.queue_free())

	if editor_plugin:
		editor_plugin.get_editor_interface().get_base_control().add_child(dialog)
	else:
		add_child(dialog)
	dialog.popup_centered(Vector2i(600, 400))


func _apply_ability(res: Resource) -> void:
	if "base_power" in res:
		_base_power_spin.value = res.get("base_power")
	if "scaling_stat" in res:
		var stat: String = res.get("scaling_stat")
		_scaling_stat_option.select(0)  # Default to none
		for i in range(_stat_ids.size()):
			if _stat_ids[i] == stat:
				_scaling_stat_option.select(i + 1)
				break
	if "scaling_multiplier" in res:
		_scale_mult_spin.value = res.get("scaling_multiplier")
	if "variance" in res:
		_variance_spin.value = res.get("variance")
	if "crit_bonus" in res:
		_crit_bonus_spin.value = res.get("crit_bonus")
	if "hit_count" in res:
		_hit_count_spin.value = res.get("hit_count")

	_recalculate()


func _on_load_enemy() -> void:
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_RESOURCES
	dialog.title = "Select Enemy Resource"
	dialog.add_filter("*.tres ; Godot Resource")

	var default_dir: String = "res://rpg_data/rpg_enemy/"
	if DirAccess.dir_exists_absolute(default_dir):
		dialog.current_dir = default_dir
	else:
		dialog.current_dir = "res://"

	dialog.file_selected.connect(func(path: String):
		var res: Resource = load(path)
		if res:
			_apply_enemy(res)
		dialog.queue_free()
	)
	dialog.canceled.connect(func(): dialog.queue_free())

	if editor_plugin:
		editor_plugin.get_editor_interface().get_base_control().add_child(dialog)
	else:
		add_child(dialog)
	dialog.popup_centered(Vector2i(600, 400))


func _apply_enemy(res: Resource) -> void:
	# Try to find a defense stat value from base_stats
	if "base_stats" in res:
		var stats: Dictionary = res.get("base_stats")
		# Look for common defense stat names
		for def_name: String in ["defense", "def", "vitality", "endurance"]:
			if stats.has(def_name):
				_def_spin.value = stats[def_name]
				break

	# Check element resistances/weaknesses for a general modifier
	if "resistances" in res:
		var resistances: Dictionary = res.get("resistances")
		if not resistances.is_empty():
			# Use the first resistance value as the element modifier
			var first_key: String = str(resistances.keys()[0])
			var mod_val: Variant = resistances[first_key]
			if mod_val is float or mod_val is int:
				_element_res_spin.value = float(mod_val)

	if "weaknesses" in res:
		var weaknesses: Dictionary = res.get("weaknesses")
		if not weaknesses.is_empty():
			var first_key: String = str(weaknesses.keys()[0])
			var mod_val: Variant = weaknesses[first_key]
			if mod_val is float or mod_val is int:
				_element_res_spin.value = float(mod_val)

	_recalculate()


# =============================================================================
# UI HELPERS
# =============================================================================

func _add_spin_row(parent: Control, label_text: String, min_val: float, max_val: float, default_val: float, step: float) -> SpinBox:
	var hbox := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(90, 0)
	hbox.add_child(label)

	var spin := SpinBox.new()
	spin.min_value = min_val
	spin.max_value = max_val
	spin.value = default_val
	spin.step = step
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spin.custom_minimum_size = Vector2(70, 0)
	hbox.add_child(spin)

	parent.add_child(hbox)
	return spin
