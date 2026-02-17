@tool
extends AcceptDialog
## Visual node-graph editor for FKDialogue resources.
## Allows drag-and-drop dialogue tree editing with Text, Choice, Condition, Action, and End nodes.

var editor_plugin: EditorPlugin
var _dialogue_resource: Resource  # FKDialogue  - typed as Resource to avoid circular deps
var _graph_edit: GraphEdit
var _context_menu: PopupMenu
var _next_node_id: int = 0
var _node_map: Dictionary = {}  # Maps String id -> GraphNode reference

# Node type colors
const TYPE_COLORS: Dictionary = {
	"text": Color(0.25, 0.52, 0.85),
	"choice": Color(0.85, 0.65, 0.15),
	"condition": Color(0.6, 0.25, 0.82),
	"action": Color(0.25, 0.72, 0.35),
	"end": Color(0.75, 0.25, 0.25),
}

const SLOT_TYPE_FLOW: int = 0


func _ready() -> void:
	title = "Dialogue Editor"
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
	save_btn.pressed.connect(_save_dialogue)
	toolbar.add_child(save_btn)

	toolbar.add_child(VSeparator.new())

	var node_types: Array[Dictionary] = [
		{"label": "+ Text", "type": "text"},
		{"label": "+ Choice", "type": "choice"},
		{"label": "+ Condition", "type": "condition"},
		{"label": "+ Action", "type": "action"},
		{"label": "+ End", "type": "end"},
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

func load_dialogue(resource: Resource) -> void:
	_dialogue_resource = resource
	var display: String = str(resource.get("display_name"))
	if display.is_empty():
		display = str(resource.get("id"))
	title = "Dialogue Editor - " + display
	_clear_graph()

	var nodes_array: Array = resource.get("nodes")
	if nodes_array == null or nodes_array.is_empty():
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
		var type: String = data.get("type", "text")
		var graph_node: GraphNode = _create_node_by_type(type, data)

		# Position
		var pos_data: Variant = data.get("position", null)
		if pos_data is Dictionary:
			var pos_dict: Dictionary = pos_data
			var px: float = pos_dict.get("x", 0.0)
			var py: float = pos_dict.get("y", 0.0)
			graph_node.position_offset = Vector2(px, py)
		else:
			needs_layout = true

		var node_id: String = data.get("id", "")
		graph_node.name = node_id
		_node_map[node_id] = graph_node
		_graph_edit.add_child(graph_node)

	# Phase 2: Create connections
	for node_data: Variant in nodes_array:
		var data: Dictionary = node_data
		var from_id: String = data.get("id", "")
		var type: String = data.get("type", "text")

		match type:
			"text", "action":
				var next_id: String = data.get("next", "")
				if not next_id.is_empty() and _node_map.has(next_id):
					_graph_edit.connect_node(from_id, 0, next_id, 0)
			"choice":
				var choices: Array = data.get("choices", [])
				for i in range(choices.size()):
					var choice: Dictionary = choices[i]
					var next_id: String = choice.get("next", "")
					if not next_id.is_empty() and _node_map.has(next_id):
						# Choice output ports start at slot index 3 (after speaker, text, label)
						_graph_edit.connect_node(from_id, i + 3, next_id, 0)
			"condition":
				var true_next: String = data.get("true_next", "")
				var false_next: String = data.get("false_next", "")
				if not true_next.is_empty() and _node_map.has(true_next):
					_graph_edit.connect_node(from_id, 1, true_next, 0)
				if not false_next.is_empty() and _node_map.has(false_next):
					_graph_edit.connect_node(from_id, 2, false_next, 0)

	# Phase 3: Auto-layout if any nodes lacked position data
	if needs_layout:
		_auto_layout()


func _save_dialogue() -> void:
	if not _dialogue_resource:
		return

	var new_nodes: Array[Dictionary] = []
	var connection_list: Array = _graph_edit.get_connection_list()

	# Build connection lookup: "from_id:port" -> "to_id"
	var connection_map: Dictionary = {}
	for conn: Variant in connection_list:
		var c: Dictionary = conn
		var key: String = String(c["from_node"]) + ":" + str(c["from_port"])
		connection_map[key] = String(c["to_node"])

	# Iterate graph nodes
	for child: Node in _graph_edit.get_children():
		if not child is GraphNode:
			continue
		var gn: GraphNode = child
		var node_id: String = gn.name
		var type: String = gn.get_meta("node_type", "text")

		var node_dict: Dictionary = {}
		node_dict["id"] = node_id
		node_dict["type"] = type
		node_dict["position"] = {"x": gn.position_offset.x, "y": gn.position_offset.y}

		match type:
			"text":
				node_dict["speaker"] = _read_meta_line(gn, "speaker_edit")
				node_dict["text"] = _read_meta_text(gn, "text_edit")
				node_dict["emotion"] = _read_meta_line(gn, "emotion_edit")
				var next_target: String = connection_map.get(node_id + ":0", "")
				if not next_target.is_empty():
					node_dict["next"] = next_target
			"choice":
				node_dict["speaker"] = _read_meta_line(gn, "speaker_edit")
				node_dict["text"] = _read_meta_text(gn, "text_edit")
				var choices: Array = []
				var choice_count: int = gn.get_meta("choice_count", 0)
				for i in range(choice_count):
					var choice_dict: Dictionary = {}
					var ct_edit: Variant = gn.get_meta("choice_text_" + str(i), null)
					var cc_edit: Variant = gn.get_meta("choice_cond_" + str(i), null)
					choice_dict["text"] = ct_edit.text if ct_edit else ""
					choice_dict["condition"] = cc_edit.text if cc_edit else ""
					var slot_idx: int = i + 3
					choice_dict["next"] = connection_map.get(node_id + ":" + str(slot_idx), "")
					choices.append(choice_dict)
				node_dict["choices"] = choices
			"condition":
				node_dict["condition"] = _read_meta_line(gn, "condition_edit")
				node_dict["true_next"] = connection_map.get(node_id + ":1", "")
				node_dict["false_next"] = connection_map.get(node_id + ":2", "")
			"action":
				node_dict["action"] = _read_meta_line(gn, "action_edit")
				var next_target: String = connection_map.get(node_id + ":0", "")
				if not next_target.is_empty():
					node_dict["next"] = next_target
			"end":
				pass

		new_nodes.append(node_dict)

	_dialogue_resource.set("nodes", new_nodes)
	ResourceSaver.save(_dialogue_resource)

	if editor_plugin:
		editor_plugin.get_editor_interface().get_resource_filesystem().scan()


func _read_meta_line(gn: GraphNode, key: String) -> String:
	var edit: Variant = gn.get_meta(key, null)
	if edit and edit is LineEdit:
		return (edit as LineEdit).text
	return ""


func _read_meta_text(gn: GraphNode, key: String) -> String:
	var edit: Variant = gn.get_meta(key, null)
	if edit and edit is TextEdit:
		return (edit as TextEdit).text
	return ""


# =============================================================================
# GRAPH NODE FACTORIES
# =============================================================================

func _create_node_by_type(type: String, data: Dictionary) -> GraphNode:
	match type:
		"text":
			return _create_text_node(data)
		"choice":
			return _create_choice_node(data)
		"condition":
			return _create_condition_node(data)
		"action":
			return _create_action_node(data)
		"end":
			return _create_end_node(data)
		_:
			return _create_text_node(data)


func _create_text_node(data: Dictionary) -> GraphNode:
	var gn := GraphNode.new()
	gn.title = "Text"
	gn.set_meta("node_type", "text")
	gn.custom_minimum_size = Vector2(280, 0)
	_style_node(gn, "text")

	# Slot 0: Speaker
	var speaker_hbox := HBoxContainer.new()
	var speaker_label := Label.new()
	speaker_label.text = "Speaker:"
	speaker_label.custom_minimum_size = Vector2(60, 0)
	speaker_hbox.add_child(speaker_label)
	var speaker_edit := LineEdit.new()
	speaker_edit.text = data.get("speaker", "")
	speaker_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	speaker_edit.placeholder_text = "Speaker name"
	speaker_hbox.add_child(speaker_edit)
	gn.add_child(speaker_hbox)
	gn.set_meta("speaker_edit", speaker_edit)

	# Slot 1: Text content
	var text_edit := TextEdit.new()
	text_edit.text = data.get("text", "")
	text_edit.custom_minimum_size = Vector2(0, 60)
	text_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_edit.placeholder_text = "Dialogue text..."
	gn.add_child(text_edit)
	gn.set_meta("text_edit", text_edit)

	# Slot 2: Emotion
	var emotion_hbox := HBoxContainer.new()
	var emotion_label := Label.new()
	emotion_label.text = "Emotion:"
	emotion_label.custom_minimum_size = Vector2(60, 0)
	emotion_hbox.add_child(emotion_label)
	var emotion_edit := LineEdit.new()
	emotion_edit.text = data.get("emotion", "")
	emotion_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	emotion_edit.placeholder_text = "e.g. happy, sad"
	emotion_hbox.add_child(emotion_edit)
	gn.add_child(emotion_hbox)
	gn.set_meta("emotion_edit", emotion_edit)

	# Slots: 0 = in + out, 1 = none, 2 = none
	gn.set_slot(0, true, SLOT_TYPE_FLOW, Color.WHITE, true, SLOT_TYPE_FLOW, Color.WHITE)
	gn.set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)
	gn.set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)

	return gn


func _create_choice_node(data: Dictionary) -> GraphNode:
	var gn := GraphNode.new()
	gn.title = "Choice"
	gn.set_meta("node_type", "choice")
	gn.custom_minimum_size = Vector2(350, 0)
	_style_node(gn, "choice")

	# Slot 0: Speaker
	var speaker_hbox := HBoxContainer.new()
	var speaker_label := Label.new()
	speaker_label.text = "Speaker:"
	speaker_label.custom_minimum_size = Vector2(60, 0)
	speaker_hbox.add_child(speaker_label)
	var speaker_edit := LineEdit.new()
	speaker_edit.text = data.get("speaker", "")
	speaker_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	speaker_edit.placeholder_text = "Speaker name"
	speaker_hbox.add_child(speaker_edit)
	gn.add_child(speaker_hbox)
	gn.set_meta("speaker_edit", speaker_edit)

	# Slot 1: Prompt text
	var text_edit := TextEdit.new()
	text_edit.text = data.get("text", "")
	text_edit.custom_minimum_size = Vector2(0, 45)
	text_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_edit.placeholder_text = "Prompt text..."
	gn.add_child(text_edit)
	gn.set_meta("text_edit", text_edit)

	# Slot 2: "Choices:" label
	var choices_label := Label.new()
	choices_label.text = "Choices:"
	choices_label.add_theme_font_size_override("font_size", 12)
	gn.add_child(choices_label)

	# Slots 0-2: input on 0 only, no outputs
	gn.set_slot(0, true, SLOT_TYPE_FLOW, Color.WHITE, false, 0, Color.WHITE)
	gn.set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)
	gn.set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)

	# Add existing choices
	var choices: Array = data.get("choices", [])
	var choice_count: int = 0
	for choice_data: Variant in choices:
		var cd: Dictionary = choice_data
		_add_choice_row(gn, cd.get("text", ""), cd.get("condition", ""), choice_count)
		choice_count += 1

	# If no choices, add one empty one
	if choice_count == 0:
		_add_choice_row(gn, "", "", 0)
		choice_count = 1

	gn.set_meta("choice_count", choice_count)

	# Add Choice button (last child  - no port)
	var add_btn := Button.new()
	add_btn.text = "+ Add Choice"
	add_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_btn.pressed.connect(_on_add_choice.bind(gn))
	gn.add_child(add_btn)
	gn.set_meta("add_choice_btn", add_btn)
	# Set slot on add button to have no ports
	var btn_slot: int = gn.get_child_count() - 1
	gn.set_slot(btn_slot, false, 0, Color.WHITE, false, 0, Color.WHITE)

	return gn


func _add_choice_row(gn: GraphNode, choice_text: String, condition_text: String, index: int) -> void:
	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var text_edit := LineEdit.new()
	text_edit.text = choice_text
	text_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_edit.placeholder_text = "Choice text"
	hbox.add_child(text_edit)

	var cond_edit := LineEdit.new()
	cond_edit.text = condition_text
	cond_edit.custom_minimum_size = Vector2(80, 0)
	cond_edit.placeholder_text = "condition"
	hbox.add_child(cond_edit)

	var del_btn := Button.new()
	del_btn.text = "x"
	del_btn.custom_minimum_size = Vector2(28, 0)
	del_btn.pressed.connect(_on_remove_choice.bind(gn, index))
	hbox.add_child(del_btn)

	# Insert before the "+ Add Choice" button if it exists
	var add_btn: Variant = gn.get_meta("add_choice_btn", null)
	if add_btn and add_btn is Button:
		var btn_idx: int = (add_btn as Button).get_index()
		gn.add_child(hbox)
		gn.move_child(hbox, btn_idx)
	else:
		gn.add_child(hbox)

	gn.set_meta("choice_text_" + str(index), text_edit)
	gn.set_meta("choice_cond_" + str(index), cond_edit)

	# Set slot: right output for this choice
	var slot_idx: int = hbox.get_index()
	gn.set_slot(slot_idx, false, 0, Color.WHITE, true, SLOT_TYPE_FLOW, TYPE_COLORS["choice"])


func _on_add_choice(gn: GraphNode) -> void:
	var count: int = gn.get_meta("choice_count", 0)
	_add_choice_row(gn, "", "", count)
	count += 1
	gn.set_meta("choice_count", count)
	# Re-set the add button slot to have no ports
	var add_btn: Variant = gn.get_meta("add_choice_btn", null)
	if add_btn and add_btn is Button:
		var btn_slot: int = (add_btn as Button).get_index()
		gn.set_slot(btn_slot, false, 0, Color.WHITE, false, 0, Color.WHITE)


func _on_remove_choice(gn: GraphNode, index: int) -> void:
	var count: int = gn.get_meta("choice_count", 0)
	if count <= 1:
		return  # Keep at least one choice

	# Disconnect all connections from this node first
	var node_name: String = gn.name
	var conns_to_remove: Array[Dictionary] = []
	for conn: Variant in _graph_edit.get_connection_list():
		var c: Dictionary = conn
		if String(c["from_node"]) == node_name or String(c["to_node"]) == node_name:
			conns_to_remove.append(c)
	for c in conns_to_remove:
		_graph_edit.disconnect_node(c["from_node"], c["from_port"], c["to_node"], c["to_port"])

	# Rebuild the choice node
	_rebuild_choice_node(gn, index)


func _rebuild_choice_node(gn: GraphNode, remove_index: int) -> void:
	# Collect current choice data
	var old_count: int = gn.get_meta("choice_count", 0)
	var choices_data: Array[Dictionary] = []
	for i in range(old_count):
		if i == remove_index:
			continue
		var ct: Variant = gn.get_meta("choice_text_" + str(i), null)
		var cc: Variant = gn.get_meta("choice_cond_" + str(i), null)
		choices_data.append({
			"text": ct.text if ct else "",
			"condition": cc.text if cc else "",
		})

	# Remove choice rows and add button (children from index 3 onward)
	var to_remove: Array[Node] = []
	for i in range(gn.get_child_count()):
		if i >= 3:
			to_remove.append(gn.get_child(i))
	for child in to_remove:
		gn.remove_child(child)
		child.queue_free()

	# Clear old meta
	for i in range(old_count):
		if gn.has_meta("choice_text_" + str(i)):
			gn.remove_meta("choice_text_" + str(i))
		if gn.has_meta("choice_cond_" + str(i)):
			gn.remove_meta("choice_cond_" + str(i))
	gn.remove_meta("add_choice_btn")

	# Re-add choices
	var new_count: int = 0
	for cd in choices_data:
		_add_choice_row(gn, cd["text"], cd["condition"], new_count)
		new_count += 1

	gn.set_meta("choice_count", new_count)

	# Re-add the Add Choice button
	var add_btn := Button.new()
	add_btn.text = "+ Add Choice"
	add_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_btn.pressed.connect(_on_add_choice.bind(gn))
	gn.add_child(add_btn)
	gn.set_meta("add_choice_btn", add_btn)
	var btn_slot: int = gn.get_child_count() - 1
	gn.set_slot(btn_slot, false, 0, Color.WHITE, false, 0, Color.WHITE)


func _create_condition_node(data: Dictionary) -> GraphNode:
	var gn := GraphNode.new()
	gn.title = "Condition"
	gn.set_meta("node_type", "condition")
	gn.custom_minimum_size = Vector2(260, 0)
	_style_node(gn, "condition")

	# Slot 0: Condition expression
	var cond_hbox := HBoxContainer.new()
	var cond_label := Label.new()
	cond_label.text = "If:"
	cond_label.custom_minimum_size = Vector2(30, 0)
	cond_hbox.add_child(cond_label)
	var cond_edit := LineEdit.new()
	cond_edit.text = data.get("condition", "")
	cond_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cond_edit.placeholder_text = "e.g. has_item:key"
	cond_hbox.add_child(cond_edit)
	gn.add_child(cond_hbox)
	gn.set_meta("condition_edit", cond_edit)

	# Slot 1: True branch
	var true_label := Label.new()
	true_label.text = "True >"
	true_label.add_theme_color_override("font_color", Color(0.3, 0.85, 0.3))
	gn.add_child(true_label)

	# Slot 2: False branch
	var false_label := Label.new()
	false_label.text = "False >"
	false_label.add_theme_color_override("font_color", Color(0.85, 0.3, 0.3))
	gn.add_child(false_label)

	# Slots
	gn.set_slot(0, true, SLOT_TYPE_FLOW, Color.WHITE, false, 0, Color.WHITE)
	gn.set_slot(1, false, 0, Color.WHITE, true, SLOT_TYPE_FLOW, Color(0.3, 0.85, 0.3))
	gn.set_slot(2, false, 0, Color.WHITE, true, SLOT_TYPE_FLOW, Color(0.85, 0.3, 0.3))

	return gn


func _create_action_node(data: Dictionary) -> GraphNode:
	var gn := GraphNode.new()
	gn.title = "Action"
	gn.set_meta("node_type", "action")
	gn.custom_minimum_size = Vector2(260, 0)
	_style_node(gn, "action")

	# Slot 0: Action expression
	var action_hbox := HBoxContainer.new()
	var action_label := Label.new()
	action_label.text = "Do:"
	action_label.custom_minimum_size = Vector2(30, 0)
	action_hbox.add_child(action_label)
	var action_edit := LineEdit.new()
	action_edit.text = data.get("action", "")
	action_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_edit.placeholder_text = "e.g. give_item:potion"
	action_hbox.add_child(action_edit)
	gn.add_child(action_hbox)
	gn.set_meta("action_edit", action_edit)

	# Slot 0: in + out
	gn.set_slot(0, true, SLOT_TYPE_FLOW, Color.WHITE, true, SLOT_TYPE_FLOW, Color.WHITE)

	return gn


func _create_end_node(data: Dictionary) -> GraphNode:
	var gn := GraphNode.new()
	gn.title = "End"
	gn.set_meta("node_type", "end")
	gn.custom_minimum_size = Vector2(120, 0)
	_style_node(gn, "end")

	# Slot 0: END label
	var end_label := Label.new()
	end_label.text = "END"
	end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_label.add_theme_font_size_override("font_size", 14)
	gn.add_child(end_label)

	# Slot 0: input only
	gn.set_slot(0, true, SLOT_TYPE_FLOW, Color.WHITE, false, 0, Color.WHITE)

	return gn


func _style_node(gn: GraphNode, type: String) -> void:
	var color: Color = TYPE_COLORS.get(type, Color.WHITE)

	# Titlebar style
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = color
	title_style.corner_radius_top_left = 6
	title_style.corner_radius_top_right = 6
	title_style.content_margin_left = 10
	title_style.content_margin_right = 10
	title_style.content_margin_top = 6
	title_style.content_margin_bottom = 6
	gn.add_theme_stylebox_override("titlebar", title_style)

	# Selected titlebar
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
	# Disconnect existing outgoing connection from this port (one output -> one target)
	_disconnect_outgoing(String(from_node), from_port)
	_graph_edit.connect_node(from_node, from_port, to_node, to_port)


func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	_graph_edit.disconnect_node(from_node, from_port, to_node, to_port)


func _disconnect_outgoing(from_name: String, from_port: int) -> void:
	for conn: Variant in _graph_edit.get_connection_list():
		var c: Dictionary = conn
		if String(c["from_node"]) == from_name and int(c["from_port"]) == from_port:
			_graph_edit.disconnect_node(c["from_node"], c["from_port"], c["to_node"], c["to_port"])
			return


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
	var data: Dictionary = {"id": node_id, "type": type}

	# Default values
	if type == "choice":
		data["choices"] = [{"text": "", "condition": "", "next": ""}]

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
	_context_menu.add_item("Add Text Node", 0)
	_context_menu.add_item("Add Choice Node", 1)
	_context_menu.add_item("Add Condition Node", 2)
	_context_menu.add_item("Add Action Node", 3)
	_context_menu.add_item("Add End Node", 4)
	_context_menu.id_pressed.connect(_on_context_menu_selected.bind(global_pos))
	add_child(_context_menu)
	# Convert viewport-relative position to screen coordinates.
	# Since this editor is inside an AcceptDialog (a Window), global_pos from
	# gui_input is relative to the window viewport, not the screen.
	var screen_pos: Vector2i = Vector2i(global_pos) + position
	_context_menu.position = screen_pos
	_context_menu.popup()


func _on_context_menu_selected(id: int, click_pos: Vector2) -> void:
	var types: Array[String] = ["text", "choice", "condition", "action", "end"]
	if id < 0 or id >= types.size():
		return

	var type: String = types[id]
	var node_id: String = _generate_node_id()
	var data: Dictionary = {"id": node_id, "type": type}
	if type == "choice":
		data["choices"] = [{"text": "", "condition": "", "next": ""}]

	var gn: GraphNode = _create_node_by_type(type, data)
	gn.name = node_id

	# Convert click position to graph coordinates
	var local_pos: Vector2 = click_pos - _graph_edit.global_position
	var graph_pos: Vector2 = (_graph_edit.scroll_offset + local_pos) / _graph_edit.zoom
	gn.position_offset = graph_pos

	_node_map[node_id] = gn
	_graph_edit.add_child(gn)


# =============================================================================
# AUTO-LAYOUT (BFS)
# =============================================================================

func _auto_layout() -> void:
	var H_SPACING: float = 350.0
	var V_SPACING: float = 200.0

	# Build adjacency
	var children_map: Dictionary = {}
	var parent_count: Dictionary = {}

	for id: String in _node_map:
		children_map[id] = []
		parent_count[id] = 0

	for conn: Variant in _graph_edit.get_connection_list():
		var c: Dictionary = conn
		var from_id: String = String(c["from_node"])
		var to_id: String = String(c["to_node"])
		if children_map.has(from_id):
			children_map[from_id].append(to_id)
		if parent_count.has(to_id):
			parent_count[to_id] = parent_count[to_id] + 1

	# Find roots (no incoming)
	var roots: Array[String] = []
	for id: String in parent_count:
		if parent_count[id] == 0:
			roots.append(id)

	if roots.is_empty() and not _node_map.is_empty():
		roots.append(_node_map.keys()[0])

	# BFS
	var visited: Dictionary = {}
	var layers: Dictionary = {}
	var layer_nodes: Dictionary = {}
	var queue: Array[String] = []

	for root_id: String in roots:
		queue.append(root_id)
		layers[root_id] = 0
		visited[root_id] = true

	while not queue.is_empty():
		var current: String = queue.pop_front()
		var current_layer: int = layers[current]

		if not layer_nodes.has(current_layer):
			layer_nodes[current_layer] = []
		layer_nodes[current_layer].append(current)

		var targets: Array = children_map.get(current, [])
		for target_id: Variant in targets:
			var tid: String = target_id
			if not visited.has(tid):
				visited[tid] = true
				layers[tid] = current_layer + 1
				queue.append(tid)

	# Place unvisited nodes
	var max_layer: int = 0
	for l: Variant in layer_nodes:
		var li: int = l
		if li > max_layer:
			max_layer = li
	for id: String in _node_map:
		if not visited.has(id):
			max_layer += 1
			layers[id] = max_layer
			if not layer_nodes.has(max_layer):
				layer_nodes[max_layer] = []
			layer_nodes[max_layer].append(id)

	# Apply positions
	for layer_idx: Variant in layer_nodes:
		var li: int = layer_idx
		var node_ids: Array = layer_nodes[li]
		for row in range(node_ids.size()):
			var node_id: String = node_ids[row]
			var gn: Variant = _node_map.get(node_id, null)
			if gn and gn is GraphNode:
				(gn as GraphNode).position_offset = Vector2(li * H_SPACING, row * V_SPACING)


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
