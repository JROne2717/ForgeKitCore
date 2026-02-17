@tool
extends AcceptDialog
## Visual node-graph editor for FKSkillTree resources.
## Allows drag-and-drop skill tree editing with Passive, Ability, and Milestone nodes.
## Connections represent prerequisites between skills.

var editor_plugin: EditorPlugin
var _tree_resource: Resource  # FKSkillTree  - typed as Resource to avoid circular deps
var _graph_edit: GraphEdit
var _context_menu: PopupMenu
var _file_dialog: FileDialog
var _browse_target_edit: LineEdit  # The LineEdit that the file dialog will fill
var _next_node_id: int = 0
var _node_map: Dictionary = {}  # Maps String id -> GraphNode reference
var _tier_count_spin: SpinBox
var _points_per_tier_spin: SpinBox

# Node type colors
const TYPE_COLORS: Dictionary = {
	"passive": Color(0.2, 0.7, 0.65),
	"ability": Color(0.85, 0.55, 0.15),
	"milestone": Color(0.85, 0.75, 0.2),
}

const SLOT_TYPE_FLOW: int = 0


func _ready() -> void:
	title = "Skill Tree Editor"
	min_size = Vector2i(1100, 700)
	get_ok_button().visible = false
	add_cancel_button("Close")
	_build_ui()


func _build_ui() -> void:
	var root_vbox := VBoxContainer.new()
	root_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(root_vbox)

	# --- Toolbar ---
	var toolbar := HBoxContainer.new()
	toolbar.custom_minimum_size = Vector2(0, 36)
	root_vbox.add_child(toolbar)

	var save_btn := Button.new()
	save_btn.text = "Save"
	save_btn.custom_minimum_size = Vector2(70, 0)
	save_btn.pressed.connect(_save_tree)
	toolbar.add_child(save_btn)

	toolbar.add_child(VSeparator.new())

	var node_types: Array[Dictionary] = [
		{"label": "+ Passive", "type": "passive"},
		{"label": "+ Ability", "type": "ability"},
		{"label": "+ Milestone", "type": "milestone"},
	]
	for nt in node_types:
		var btn := Button.new()
		btn.text = nt["label"]
		var node_type: String = nt["type"]
		btn.pressed.connect(_add_node_at_center.bind(node_type))
		toolbar.add_child(btn)

	toolbar.add_child(VSeparator.new())

	var layout_btn := Button.new()
	layout_btn.text = "Auto Layout"
	layout_btn.pressed.connect(_auto_layout)
	toolbar.add_child(layout_btn)

	toolbar.add_child(VSeparator.new())

	var delete_btn := Button.new()
	delete_btn.text = "Delete Selected"
	delete_btn.pressed.connect(_delete_selected_nodes)
	toolbar.add_child(delete_btn)

	toolbar.add_child(VSeparator.new())

	# Tier settings
	var tier_label := Label.new()
	tier_label.text = "Tiers:"
	toolbar.add_child(tier_label)

	_tier_count_spin = SpinBox.new()
	_tier_count_spin.min_value = 1
	_tier_count_spin.max_value = 20
	_tier_count_spin.value = 5
	_tier_count_spin.custom_minimum_size = Vector2(60, 0)
	toolbar.add_child(_tier_count_spin)

	var pts_label := Label.new()
	pts_label.text = "Pts/Tier:"
	toolbar.add_child(pts_label)

	_points_per_tier_spin = SpinBox.new()
	_points_per_tier_spin.min_value = 1
	_points_per_tier_spin.max_value = 50
	_points_per_tier_spin.value = 5
	_points_per_tier_spin.custom_minimum_size = Vector2(60, 0)
	toolbar.add_child(_points_per_tier_spin)

	# --- GraphEdit ---
	_graph_edit = GraphEdit.new()
	_graph_edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_graph_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_graph_edit.right_disconnects = true
	_graph_edit.custom_minimum_size = Vector2(0, 500)
	root_vbox.add_child(_graph_edit)

	# Signals
	_graph_edit.connection_request.connect(_on_connection_request)
	_graph_edit.disconnection_request.connect(_on_disconnection_request)
	_graph_edit.delete_nodes_request.connect(_on_delete_nodes_request)

	# Right-click context menu
	_graph_edit.gui_input.connect(_on_graph_gui_input)


# =============================================================================
# LOAD / SAVE
# =============================================================================

func load_skill_tree(resource: Resource) -> void:
	_tree_resource = resource
	var display: String = str(resource.get("display_name"))
	if display.is_empty():
		display = str(resource.get("id"))
	title = "Skill Tree Editor - " + display
	_clear_graph()

	# Load tree settings
	if "tier_count" in resource:
		_tier_count_spin.value = resource.get("tier_count")
	if "points_per_tier" in resource:
		_points_per_tier_spin.value = resource.get("points_per_tier")

	var raw_nodes: Variant = resource.get("nodes")
	if raw_nodes == null:
		push_warning("ForgeKit: Skill tree has null nodes property.")
		return

	var nodes_array: Array = raw_nodes
	if nodes_array.is_empty():
		push_warning("ForgeKit: Skill tree nodes array is empty.")
		return

	# Determine next ID counter
	_next_node_id = 0
	for node_data: Variant in nodes_array:
		var data: Dictionary = node_data
		var id_str: String = data.get("id", "")
		if id_str.begins_with("node_"):
			var num_str: String = id_str.substr(5)
			if num_str.is_valid_int():
				var num: int = num_str.to_int()
				if num >= _next_node_id:
					_next_node_id = num + 1

	# Phase 1: Create all graph nodes
	var needs_layout: bool = false
	for node_data: Variant in nodes_array:
		var data: Dictionary = node_data
		var type: String = data.get("type", "passive")
		var graph_node: GraphNode = _create_node_by_type(type, data)

		# Position
		var pos_data: Variant = data.get("position", null)
		if pos_data is Dictionary:
			var pos_dict: Dictionary = pos_data
			var px: float = pos_dict.get("x", 0.0)
			var py: float = pos_dict.get("y", 0.0)
			graph_node.position_offset = Vector2(px, py)
		elif pos_data is Vector2:
			graph_node.position_offset = pos_data
		else:
			needs_layout = true

		var node_id: String = data.get("id", "")
		graph_node.name = node_id
		_node_map[node_id] = graph_node
		_graph_edit.add_child(graph_node)

	# Phase 2: Create connections from prerequisites
	# Connections flow: prerequisite -> dependent (from prereq output to dependent input)
	for node_data: Variant in nodes_array:
		var data: Dictionary = node_data
		var node_id: String = data.get("id", "")
		var prereqs: Array = data.get("prerequisites", [])
		for prereq_id: Variant in prereqs:
			var pid: String = str(prereq_id)
			if _node_map.has(pid) and _node_map.has(node_id):
				_graph_edit.connect_node(pid, 0, node_id, 0)

	# Phase 3: Auto-layout if any nodes lacked position data
	if needs_layout:
		_auto_layout()


func _save_tree() -> void:
	if not _tree_resource:
		return

	var new_nodes: Array[Dictionary] = []
	var connection_list: Array = _graph_edit.get_connection_list()

	# Build incoming connections lookup: to_id -> Array of from_ids
	var incoming_map: Dictionary = {}
	for conn: Variant in connection_list:
		var c: Dictionary = conn
		var to_id: String = String(c["to_node"])
		var from_id: String = String(c["from_node"])
		if not incoming_map.has(to_id):
			incoming_map[to_id] = []
		incoming_map[to_id].append(from_id)

	# Iterate graph nodes
	for child: Node in _graph_edit.get_children():
		if not child is GraphNode:
			continue
		var gn: GraphNode = child
		var node_id: String = gn.name
		var type: String = gn.get_meta("node_type", "passive")

		var node_dict: Dictionary = {}
		node_dict["id"] = node_id
		node_dict["type"] = type
		# Store position as Vector2 instead of nested Dictionary for reliable serialization
		node_dict["position"] = Vector2(gn.position_offset.x, gn.position_offset.y)

		# Name
		node_dict["name"] = _read_meta_line(gn, "name_edit")

		# Tier
		var tier_spin: Variant = gn.get_meta("tier_spin", null)
		if tier_spin and tier_spin is SpinBox:
			node_dict["tier"] = int((tier_spin as SpinBox).value)

		# Cost and max_rank
		var cost_spin: Variant = gn.get_meta("cost_spin", null)
		if cost_spin and cost_spin is SpinBox:
			node_dict["cost"] = int((cost_spin as SpinBox).value)

		var rank_spin: Variant = gn.get_meta("rank_spin", null)
		if rank_spin and rank_spin is SpinBox:
			node_dict["max_rank"] = int((rank_spin as SpinBox).value)

		# Resource reference (description text for milestone, resource path for passive/ability)
		match type:
			"passive", "ability":
				var res_edit: Variant = gn.get_meta("resource_edit", null)
				if res_edit and res_edit is LineEdit:
					var res_path: String = (res_edit as LineEdit).text
					if not res_path.is_empty() and ResourceLoader.exists(res_path):
						node_dict["resource"] = load(res_path)
				var desc_edit: Variant = gn.get_meta("desc_edit", null)
				if desc_edit and desc_edit is LineEdit:
					node_dict["description"] = (desc_edit as LineEdit).text
			"milestone":
				var desc_edit: Variant = gn.get_meta("desc_edit", null)
				if desc_edit and desc_edit is LineEdit:
					node_dict["description"] = (desc_edit as LineEdit).text

		# Prerequisites from incoming connections  - typed Array for reliable serialization
		var raw_prereqs: Array = incoming_map.get(node_id, [])
		var prereqs: Array[String] = []
		for p: Variant in raw_prereqs:
			prereqs.append(String(p))
		node_dict["prerequisites"] = prereqs

		new_nodes.append(node_dict)

	_tree_resource.set("nodes", new_nodes)
	_tree_resource.set("tier_count", int(_tier_count_spin.value))
	_tree_resource.set("points_per_tier", int(_points_per_tier_spin.value))
	ResourceSaver.save(_tree_resource)

	if editor_plugin:
		editor_plugin.get_editor_interface().get_resource_filesystem().scan()


func _read_meta_line(gn: GraphNode, key: String) -> String:
	var edit: Variant = gn.get_meta(key, null)
	if edit and edit is LineEdit:
		return (edit as LineEdit).text
	return ""


# =============================================================================
# GRAPH NODE FACTORIES
# =============================================================================

func _create_node_by_type(type: String, data: Dictionary) -> GraphNode:
	match type:
		"passive":
			return _create_passive_node(data)
		"ability":
			return _create_ability_node(data)
		"milestone":
			return _create_milestone_node(data)
		_:
			return _create_passive_node(data)


func _create_passive_node(data: Dictionary) -> GraphNode:
	var gn := GraphNode.new()
	gn.title = "Passive Skill"
	gn.set_meta("node_type", "passive")
	gn.custom_minimum_size = Vector2(300, 0)
	_style_node(gn, "passive")

	# Slot 0: Name  - IN + OUT
	var name_hbox := HBoxContainer.new()
	var name_label := Label.new()
	name_label.text = "Name:"
	name_label.custom_minimum_size = Vector2(50, 0)
	name_hbox.add_child(name_label)
	var name_edit := LineEdit.new()
	name_edit.text = data.get("name", "")
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_edit.placeholder_text = "Skill name"
	name_hbox.add_child(name_edit)
	gn.add_child(name_hbox)
	gn.set_meta("name_edit", name_edit)

	# Slot 1: Resource path + browse button  - no ports
	var res_hbox := HBoxContainer.new()
	var res_label := Label.new()
	res_label.text = "Skill:"
	res_label.custom_minimum_size = Vector2(50, 0)
	res_hbox.add_child(res_label)
	var res_edit := LineEdit.new()
	var res_val: Variant = data.get("resource", null)
	if res_val and res_val is Resource:
		res_edit.text = (res_val as Resource).resource_path
	res_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	res_edit.placeholder_text = "res://rpg_data/fk_passive_skill/..."
	res_hbox.add_child(res_edit)
	var browse_btn := Button.new()
	browse_btn.text = "..."
	browse_btn.tooltip_text = "Browse for passive skill resource"
	browse_btn.custom_minimum_size = Vector2(28, 0)
	browse_btn.pressed.connect(_open_resource_browser.bind(res_edit, "res://rpg_data/fk_passive_skill/", "passive"))
	res_hbox.add_child(browse_btn)
	gn.add_child(res_hbox)
	gn.set_meta("resource_edit", res_edit)

	# Slot 2: Cost + Max Rank  - no ports
	var stats_hbox := HBoxContainer.new()
	var cost_label := Label.new()
	cost_label.text = "Cost:"
	stats_hbox.add_child(cost_label)
	var cost_spin := SpinBox.new()
	cost_spin.min_value = 1
	cost_spin.max_value = 99
	cost_spin.value = data.get("cost", 1)
	cost_spin.custom_minimum_size = Vector2(55, 0)
	stats_hbox.add_child(cost_spin)
	gn.set_meta("cost_spin", cost_spin)

	var rank_label := Label.new()
	rank_label.text = "  Rank:"
	stats_hbox.add_child(rank_label)
	var rank_spin := SpinBox.new()
	rank_spin.min_value = 1
	rank_spin.max_value = 10
	rank_spin.value = data.get("max_rank", 1)
	rank_spin.custom_minimum_size = Vector2(55, 0)
	stats_hbox.add_child(rank_spin)
	gn.set_meta("rank_spin", rank_spin)
	gn.add_child(stats_hbox)

	# Slot 3: Tier  - no ports
	var tier_hbox := HBoxContainer.new()
	var tier_label := Label.new()
	tier_label.text = "Tier:"
	tier_label.custom_minimum_size = Vector2(50, 0)
	tier_hbox.add_child(tier_label)
	var tier_spin := SpinBox.new()
	tier_spin.min_value = 0
	tier_spin.max_value = 20
	tier_spin.value = data.get("tier", 0)
	tier_spin.custom_minimum_size = Vector2(55, 0)
	tier_hbox.add_child(tier_spin)
	gn.set_meta("tier_spin", tier_spin)
	gn.add_child(tier_hbox)

	# Slot 4: Description  - no ports
	var desc_hbox := HBoxContainer.new()
	var desc_label := Label.new()
	desc_label.text = "Desc:"
	desc_label.custom_minimum_size = Vector2(50, 0)
	desc_hbox.add_child(desc_label)
	var desc_edit := LineEdit.new()
	desc_edit.text = data.get("description", "")
	desc_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_edit.placeholder_text = "Description"
	desc_hbox.add_child(desc_edit)
	gn.add_child(desc_hbox)
	gn.set_meta("desc_edit", desc_edit)

	# Port config: slot 0 = in + out, rest = no ports
	gn.set_slot(0, true, SLOT_TYPE_FLOW, Color.WHITE, true, SLOT_TYPE_FLOW, Color.WHITE)
	gn.set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)
	gn.set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)
	gn.set_slot(3, false, 0, Color.WHITE, false, 0, Color.WHITE)
	gn.set_slot(4, false, 0, Color.WHITE, false, 0, Color.WHITE)

	return gn


func _create_ability_node(data: Dictionary) -> GraphNode:
	var gn := GraphNode.new()
	gn.title = "Ability Unlock"
	gn.set_meta("node_type", "ability")
	gn.custom_minimum_size = Vector2(300, 0)
	_style_node(gn, "ability")

	# Slot 0: Name  - IN + OUT
	var name_hbox := HBoxContainer.new()
	var name_label := Label.new()
	name_label.text = "Name:"
	name_label.custom_minimum_size = Vector2(50, 0)
	name_hbox.add_child(name_label)
	var name_edit := LineEdit.new()
	name_edit.text = data.get("name", "")
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_edit.placeholder_text = "Ability name"
	name_hbox.add_child(name_edit)
	gn.add_child(name_hbox)
	gn.set_meta("name_edit", name_edit)

	# Slot 1: Resource path + browse button  - no ports
	var res_hbox := HBoxContainer.new()
	var res_label := Label.new()
	res_label.text = "Ability:"
	res_label.custom_minimum_size = Vector2(50, 0)
	res_hbox.add_child(res_label)
	var res_edit := LineEdit.new()
	var res_val: Variant = data.get("resource", null)
	if res_val and res_val is Resource:
		res_edit.text = (res_val as Resource).resource_path
	res_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	res_edit.placeholder_text = "res://rpg_data/fk_ability/..."
	res_hbox.add_child(res_edit)
	var browse_btn := Button.new()
	browse_btn.text = "..."
	browse_btn.tooltip_text = "Browse for ability resource"
	browse_btn.custom_minimum_size = Vector2(28, 0)
	browse_btn.pressed.connect(_open_resource_browser.bind(res_edit, "res://rpg_data/fk_ability/", "ability"))
	res_hbox.add_child(browse_btn)
	gn.add_child(res_hbox)
	gn.set_meta("resource_edit", res_edit)

	# Slot 2: Cost + Max Rank  - no ports
	var stats_hbox := HBoxContainer.new()
	var cost_label := Label.new()
	cost_label.text = "Cost:"
	stats_hbox.add_child(cost_label)
	var cost_spin := SpinBox.new()
	cost_spin.min_value = 1
	cost_spin.max_value = 99
	cost_spin.value = data.get("cost", 1)
	cost_spin.custom_minimum_size = Vector2(55, 0)
	stats_hbox.add_child(cost_spin)
	gn.set_meta("cost_spin", cost_spin)

	var rank_label := Label.new()
	rank_label.text = "  Rank:"
	stats_hbox.add_child(rank_label)
	var rank_spin := SpinBox.new()
	rank_spin.min_value = 1
	rank_spin.max_value = 10
	rank_spin.value = data.get("max_rank", 1)
	rank_spin.custom_minimum_size = Vector2(55, 0)
	stats_hbox.add_child(rank_spin)
	gn.set_meta("rank_spin", rank_spin)
	gn.add_child(stats_hbox)

	# Slot 3: Tier  - no ports
	var tier_hbox := HBoxContainer.new()
	var tier_label := Label.new()
	tier_label.text = "Tier:"
	tier_label.custom_minimum_size = Vector2(50, 0)
	tier_hbox.add_child(tier_label)
	var tier_spin := SpinBox.new()
	tier_spin.min_value = 0
	tier_spin.max_value = 20
	tier_spin.value = data.get("tier", 0)
	tier_spin.custom_minimum_size = Vector2(55, 0)
	tier_hbox.add_child(tier_spin)
	gn.set_meta("tier_spin", tier_spin)
	gn.add_child(tier_hbox)

	# Slot 4: Description  - no ports
	var desc_hbox := HBoxContainer.new()
	var desc_label := Label.new()
	desc_label.text = "Desc:"
	desc_label.custom_minimum_size = Vector2(50, 0)
	desc_hbox.add_child(desc_label)
	var desc_edit := LineEdit.new()
	desc_edit.text = data.get("description", "")
	desc_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_edit.placeholder_text = "Description"
	desc_hbox.add_child(desc_edit)
	gn.add_child(desc_hbox)
	gn.set_meta("desc_edit", desc_edit)

	# Port config
	gn.set_slot(0, true, SLOT_TYPE_FLOW, Color.WHITE, true, SLOT_TYPE_FLOW, Color.WHITE)
	gn.set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)
	gn.set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)
	gn.set_slot(3, false, 0, Color.WHITE, false, 0, Color.WHITE)
	gn.set_slot(4, false, 0, Color.WHITE, false, 0, Color.WHITE)

	return gn


func _create_milestone_node(data: Dictionary) -> GraphNode:
	var gn := GraphNode.new()
	gn.title = "Milestone"
	gn.set_meta("node_type", "milestone")
	gn.custom_minimum_size = Vector2(280, 0)
	_style_node(gn, "milestone")

	# Slot 0: Name  - IN + OUT
	var name_hbox := HBoxContainer.new()
	var name_label := Label.new()
	name_label.text = "Name:"
	name_label.custom_minimum_size = Vector2(50, 0)
	name_hbox.add_child(name_label)
	var name_edit := LineEdit.new()
	name_edit.text = data.get("name", "")
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_edit.placeholder_text = "Milestone name"
	name_hbox.add_child(name_edit)
	gn.add_child(name_hbox)
	gn.set_meta("name_edit", name_edit)

	# Slot 1: Info label  - no ports
	var info_label := Label.new()
	info_label.text = "Must unlock to progress past this tier"
	info_label.add_theme_font_size_override("font_size", 11)
	info_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.6))
	gn.add_child(info_label)

	# Slot 2: Tier  - no ports
	var tier_hbox := HBoxContainer.new()
	var tier_label := Label.new()
	tier_label.text = "Tier:"
	tier_label.custom_minimum_size = Vector2(50, 0)
	tier_hbox.add_child(tier_label)
	var tier_spin := SpinBox.new()
	tier_spin.min_value = 0
	tier_spin.max_value = 20
	tier_spin.value = data.get("tier", 0)
	tier_spin.custom_minimum_size = Vector2(55, 0)
	tier_hbox.add_child(tier_spin)
	gn.set_meta("tier_spin", tier_spin)
	gn.add_child(tier_hbox)

	# Slot 3: Description  - no ports
	var desc_hbox := HBoxContainer.new()
	var desc_label := Label.new()
	desc_label.text = "Desc:"
	desc_label.custom_minimum_size = Vector2(50, 0)
	desc_hbox.add_child(desc_label)
	var desc_edit := LineEdit.new()
	desc_edit.text = data.get("description", "")
	desc_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_edit.placeholder_text = "Description"
	desc_hbox.add_child(desc_edit)
	gn.add_child(desc_hbox)
	gn.set_meta("desc_edit", desc_edit)

	# Port config
	gn.set_slot(0, true, SLOT_TYPE_FLOW, Color.WHITE, true, SLOT_TYPE_FLOW, Color.WHITE)
	gn.set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)
	gn.set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)
	gn.set_slot(3, false, 0, Color.WHITE, false, 0, Color.WHITE)

	return gn


func _style_node(gn: GraphNode, type: String) -> void:
	var color: Color = TYPE_COLORS.get(type, Color.WHITE)

	var title_style := StyleBoxFlat.new()
	title_style.bg_color = color
	title_style.corner_radius_top_left = 6
	title_style.corner_radius_top_right = 6
	title_style.content_margin_left = 10
	title_style.content_margin_right = 10
	title_style.content_margin_top = 6
	title_style.content_margin_bottom = 6
	gn.add_theme_stylebox_override("titlebar", title_style)

	var selected_style := StyleBoxFlat.new()
	selected_style.bg_color = color.lightened(0.2)
	selected_style.corner_radius_top_left = 6
	selected_style.corner_radius_top_right = 6
	selected_style.content_margin_left = 10
	selected_style.content_margin_right = 10
	selected_style.content_margin_top = 6
	selected_style.content_margin_bottom = 6
	gn.add_theme_stylebox_override("titlebar_selected", selected_style)


# =============================================================================
# CONNECTION HANDLING
# =============================================================================

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	# No self-connections
	if from_node == to_node:
		return
	# Allow multiple connections (multiple prereqs), but prevent duplicate connections
	for conn: Variant in _graph_edit.get_connection_list():
		var c: Dictionary = conn
		if String(c["from_node"]) == String(from_node) and String(c["to_node"]) == String(to_node):
			return  # Already connected
	_graph_edit.connect_node(from_node, from_port, to_node, to_port)


func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	_graph_edit.disconnect_node(from_node, from_port, to_node, to_port)


# =============================================================================
# NODE MANAGEMENT
# =============================================================================

func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	for node_name: StringName in nodes:
		var node: GraphNode = _graph_edit.get_node_or_null(NodePath(node_name))
		if not node:
			continue
		# Remove all connections to/from this node
		var conns_to_remove: Array[Dictionary] = []
		for conn: Variant in _graph_edit.get_connection_list():
			var c: Dictionary = conn
			if String(c["from_node"]) == String(node_name) or String(c["to_node"]) == String(node_name):
				conns_to_remove.append(c)
		for c in conns_to_remove:
			_graph_edit.disconnect_node(c["from_node"], c["from_port"], c["to_node"], c["to_port"])
		_node_map.erase(String(node_name))
		node.queue_free()


func _add_node_at_center(type: String) -> void:
	var node_id: String = _generate_node_id()
	var data: Dictionary = {"id": node_id, "type": type, "name": "", "cost": 1, "max_rank": 1, "tier": 0}

	var gn: GraphNode = _create_node_by_type(type, data)
	gn.name = node_id

	# Place near center of visible area
	var center: Vector2 = (_graph_edit.scroll_offset + _graph_edit.size / 2.0) / _graph_edit.zoom
	gn.position_offset = center

	_node_map[node_id] = gn
	_graph_edit.add_child(gn)


func _generate_node_id() -> String:
	var id: String = "node_" + str(_next_node_id)
	_next_node_id += 1
	while _node_map.has(id):
		id = "node_" + str(_next_node_id)
		_next_node_id += 1
	return id


# =============================================================================
# CONTEXT MENU
# =============================================================================

func _on_graph_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			_show_context_menu(mb.global_position)


func _show_context_menu(global_pos: Vector2) -> void:
	if _context_menu:
		_context_menu.queue_free()
		_context_menu = null

	_context_menu = PopupMenu.new()
	_context_menu.add_item("Add Passive Skill Node", 0)
	_context_menu.add_item("Add Ability Unlock Node", 1)
	_context_menu.add_item("Add Milestone Node", 2)
	_context_menu.add_separator()
	_context_menu.add_item("Delete Selected Nodes", 99)
	_context_menu.id_pressed.connect(_on_context_menu_selected.bind(global_pos))
	add_child(_context_menu)
	# Convert viewport-relative position to screen coordinates.
	# Since this editor is inside an AcceptDialog (a Window), global_pos from
	# gui_input is relative to the window viewport, not the screen.
	var screen_pos: Vector2i = Vector2i(global_pos) + position
	_context_menu.position = screen_pos
	_context_menu.popup()


func _on_context_menu_selected(id: int, click_pos: Vector2) -> void:
	# Handle delete action
	if id == 99:
		_delete_selected_nodes()
		return

	var types: Array[String] = ["passive", "ability", "milestone"]
	if id < 0 or id >= types.size():
		return

	var type: String = types[id]
	var node_id: String = _generate_node_id()
	var data: Dictionary = {"id": node_id, "type": type, "name": "", "cost": 1, "max_rank": 1, "tier": 0}

	var gn: GraphNode = _create_node_by_type(type, data)
	gn.name = node_id

	# Convert click position to graph coordinates
	var local_pos: Vector2 = click_pos - _graph_edit.global_position
	var graph_pos: Vector2 = (_graph_edit.scroll_offset + local_pos) / _graph_edit.zoom
	gn.position_offset = graph_pos

	_node_map[node_id] = gn
	_graph_edit.add_child(gn)


# =============================================================================
# DELETE SELECTED NODES
# =============================================================================

func _delete_selected_nodes() -> void:
	var selected_names: Array[StringName] = []
	for child: Node in _graph_edit.get_children():
		if child is GraphNode and (child as GraphNode).selected:
			selected_names.append(StringName(child.name))
	if selected_names.is_empty():
		return
	_on_delete_nodes_request(selected_names)


# =============================================================================
# RESOURCE BROWSER
# =============================================================================

func _open_resource_browser(target_edit: LineEdit, default_dir: String, res_type: String) -> void:
	_browse_target_edit = target_edit

	if _file_dialog:
		_file_dialog.queue_free()
		_file_dialog = null

	_file_dialog = FileDialog.new()
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.filters = PackedStringArray(["*.tres ; Resource Files"])
	_file_dialog.title = "Select " + res_type.capitalize() + " Resource"
	_file_dialog.min_size = Vector2i(700, 500)

	# Try to start in the appropriate directory
	if DirAccess.dir_exists_absolute(default_dir):
		_file_dialog.current_dir = default_dir
	elif DirAccess.dir_exists_absolute("res://rpg_data/"):
		_file_dialog.current_dir = "res://rpg_data/"

	# If the LineEdit already has a valid path, start there
	if not target_edit.text.is_empty() and ResourceLoader.exists(target_edit.text):
		_file_dialog.current_path = target_edit.text

	_file_dialog.file_selected.connect(_on_resource_file_selected)
	add_child(_file_dialog)
	_file_dialog.popup_centered()


func _on_resource_file_selected(path: String) -> void:
	if _browse_target_edit and is_instance_valid(_browse_target_edit):
		_browse_target_edit.text = path
	_browse_target_edit = null


# =============================================================================
# AUTO-LAYOUT (Tier-Based)
# =============================================================================

func _auto_layout() -> void:
	var H_SPACING: float = 300.0
	var V_SPACING: float = 180.0

	# Group nodes by tier
	var tier_groups: Dictionary = {}  # tier_int -> Array[String] of node IDs

	for id: String in _node_map:
		var gn: Variant = _node_map[id]
		if not (gn is GraphNode):
			continue
		var tier_spin: Variant = (gn as GraphNode).get_meta("tier_spin", null)
		var tier: int = 0
		if tier_spin and tier_spin is SpinBox:
			tier = int((tier_spin as SpinBox).value)

		if not tier_groups.has(tier):
			tier_groups[tier] = []
		tier_groups[tier].append(id)

	# Sort tiers
	var tier_keys: Array = tier_groups.keys()
	tier_keys.sort()

	# Position nodes
	var col: int = 0
	for tier: Variant in tier_keys:
		var tier_int: int = tier
		var node_ids: Array = tier_groups[tier_int]
		for row in range(node_ids.size()):
			var node_id: String = node_ids[row]
			var gn: Variant = _node_map.get(node_id, null)
			if gn and gn is GraphNode:
				(gn as GraphNode).position_offset = Vector2(col * H_SPACING, row * V_SPACING)
		col += 1


# =============================================================================
# UTILITIES
# =============================================================================

func _clear_graph() -> void:
	_graph_edit.clear_connections()
	for child: Node in _graph_edit.get_children():
		if child is GraphNode:
			child.queue_free()
	_node_map.clear()
	_next_node_id = 0
