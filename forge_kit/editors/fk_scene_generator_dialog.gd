@tool
extends AcceptDialog
## A dialog for generating custom RPG scenes with configurable options.

var editor_plugin: EditorPlugin

var _scene_type_option: OptionButton
var _scene_name_edit: LineEdit
var _options_container: VBoxContainer
var _include_camera: CheckBox
var _include_hud: CheckBox
var _include_music: CheckBox
var _include_transitions: CheckBox
var _2d_3d_option: OptionButton

const SCENE_TYPES := [
	"Empty Scene",
	"Dungeon Room",
	"Town/Village",
	"World Map",
	"Boss Arena",
	"Cutscene",
	"Mini-game",
	"Character Select",
	"Level Up Screen",
	"Crafting Screen",
	"Quest Log",
	"Map Screen",
	"Bestiary",
]


func _ready() -> void:
	title = "ForgeKit Scene Generator"
	min_size = Vector2i(450, 500)
	_build_ui()
	get_ok_button().text = "Generate Scene"
	confirmed.connect(_on_confirmed)


func _build_ui() -> void:
	var vbox := VBoxContainer.new()
	add_child(vbox)

	# Scene name
	var name_label := Label.new()
	name_label.text = "Scene Name:"
	vbox.add_child(name_label)

	_scene_name_edit = LineEdit.new()
	_scene_name_edit.placeholder_text = "my_scene"
	vbox.add_child(_scene_name_edit)

	vbox.add_child(HSeparator.new())

	# Scene type
	var type_label := Label.new()
	type_label.text = "Scene Type:"
	vbox.add_child(type_label)

	_scene_type_option = OptionButton.new()
	for t in SCENE_TYPES:
		_scene_type_option.add_item(t)
	vbox.add_child(_scene_type_option)

	vbox.add_child(HSeparator.new())

	# Render mode
	var render_label := Label.new()
	render_label.text = "Render Mode:"
	vbox.add_child(render_label)

	_2d_3d_option = OptionButton.new()
	_2d_3d_option.add_item("2D")
	_2d_3d_option.add_item("3D")
	vbox.add_child(_2d_3d_option)

	vbox.add_child(HSeparator.new())

	# Options
	var options_label := Label.new()
	options_label.text = "Include Components:"
	vbox.add_child(options_label)

	_options_container = VBoxContainer.new()
	vbox.add_child(_options_container)

	_include_camera = CheckBox.new()
	_include_camera.text = "Camera"
	_include_camera.button_pressed = true
	_options_container.add_child(_include_camera)

	_include_hud = CheckBox.new()
	_include_hud.text = "HUD / UI Layer"
	_include_hud.button_pressed = true
	_options_container.add_child(_include_hud)

	_include_music = CheckBox.new()
	_include_music.text = "Music / Audio Players"
	_include_music.button_pressed = true
	_options_container.add_child(_include_music)

	_include_transitions = CheckBox.new()
	_include_transitions.text = "Scene Transitions"
	_include_transitions.button_pressed = false
	_options_container.add_child(_include_transitions)

	vbox.add_child(HSeparator.new())

	# Save location
	var save_label := Label.new()
	save_label.text = "Scenes are saved to res://scenes/"
	save_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(save_label)


func _on_confirmed() -> void:
	var scene_name := _scene_name_edit.text.strip_edges()
	if scene_name.is_empty():
		scene_name = "new_scene"

	var scene_type: String = SCENE_TYPES[_scene_type_option.selected]
	var is_3d := _2d_3d_option.selected == 1

	# Build the scene
	var root: Node
	if is_3d:
		root = _build_3d_scene(scene_name, scene_type)
	else:
		root = _build_2d_scene(scene_name, scene_type)

	# Save
	var dir_path := "res://scenes/"
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

	var save_path := dir_path + scene_name.to_snake_case() + ".tscn"
	var scene := PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, save_path)
	root.queue_free()

	if editor_plugin:
		editor_plugin.get_editor_interface().get_resource_filesystem().scan()
		editor_plugin.get_editor_interface().open_scene_from_path(save_path)


func _build_2d_scene(scene_name: String, scene_type: String) -> Node2D:
	var root := Node2D.new()
	root.name = scene_name.to_pascal_case()

	if _include_camera.button_pressed:
		var cam := Camera2D.new()
		cam.name = "Camera2D"
		cam.position_smoothing_enabled = true
		root.add_child(cam)
		cam.owner = root

	# Add scene-type specific nodes
	match scene_type:
		"Dungeon Room":
			_add_2d_dungeon_nodes(root)
		"Town/Village":
			_add_2d_town_nodes(root)
		"World Map":
			_add_2d_worldmap_nodes(root)
		"Boss Arena":
			_add_2d_boss_arena_nodes(root)
		"Cutscene":
			_add_2d_cutscene_nodes(root)

	if _include_hud.button_pressed:
		var hud := CanvasLayer.new()
		hud.name = "HUD"
		root.add_child(hud)
		hud.owner = root

	if _include_music.button_pressed:
		var bgm := AudioStreamPlayer.new()
		bgm.name = "BGM"
		root.add_child(bgm)
		bgm.owner = root

		var sfx := AudioStreamPlayer.new()
		sfx.name = "SFX"
		root.add_child(sfx)
		sfx.owner = root

	if _include_transitions.button_pressed:
		var transition := CanvasLayer.new()
		transition.name = "TransitionLayer"
		transition.layer = 100
		root.add_child(transition)
		transition.owner = root

		var fade := ColorRect.new()
		fade.name = "FadeRect"
		fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		fade.color = Color(0, 0, 0, 0)
		fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		transition.add_child(fade)
		fade.owner = root

	return root


func _build_3d_scene(scene_name: String, scene_type: String) -> Node3D:
	var root := Node3D.new()
	root.name = scene_name.to_pascal_case()

	if _include_camera.button_pressed:
		var cam := Camera3D.new()
		cam.name = "Camera3D"
		cam.position = Vector3(0, 5, 10)
		cam.rotation_degrees = Vector3(-30, 0, 0)
		root.add_child(cam)
		cam.owner = root

	# Basic lighting
	var light := DirectionalLight3D.new()
	light.name = "DirectionalLight"
	light.rotation_degrees = Vector3(-45, 45, 0)
	root.add_child(light)
	light.owner = root

	var env := WorldEnvironment.new()
	env.name = "WorldEnvironment"
	root.add_child(env)
	env.owner = root

	if _include_hud.button_pressed:
		var hud := CanvasLayer.new()
		hud.name = "HUD"
		root.add_child(hud)
		hud.owner = root

	if _include_music.button_pressed:
		var bgm := AudioStreamPlayer.new()
		bgm.name = "BGM"
		root.add_child(bgm)
		bgm.owner = root

	return root


func _add_2d_dungeon_nodes(root: Node2D) -> void:
	var tilemap := Node2D.new()
	tilemap.name = "TileMapLayer"
	root.add_child(tilemap)
	tilemap.owner = root

	var enemies := Node2D.new()
	enemies.name = "Enemies"
	root.add_child(enemies)
	enemies.owner = root

	var chests := Node2D.new()
	chests.name = "Chests"
	root.add_child(chests)
	chests.owner = root

	var doors := Node2D.new()
	doors.name = "Doors"
	root.add_child(doors)
	doors.owner = root

	var traps := Node2D.new()
	traps.name = "Traps"
	root.add_child(traps)
	traps.owner = root

	var spawn := Marker2D.new()
	spawn.name = "PlayerSpawn"
	root.add_child(spawn)
	spawn.owner = root

	var exit := Marker2D.new()
	exit.name = "Exit"
	exit.position = Vector2(500, 0)
	root.add_child(exit)
	exit.owner = root


func _add_2d_town_nodes(root: Node2D) -> void:
	var tilemap := Node2D.new()
	tilemap.name = "TileMapLayer"
	root.add_child(tilemap)
	tilemap.owner = root

	var buildings := Node2D.new()
	buildings.name = "Buildings"
	root.add_child(buildings)
	buildings.owner = root

	var npcs := Node2D.new()
	npcs.name = "NPCs"
	root.add_child(npcs)
	npcs.owner = root

	var shops := Node2D.new()
	shops.name = "ShopZones"
	root.add_child(shops)
	shops.owner = root

	var inn := Marker2D.new()
	inn.name = "InnMarker"
	root.add_child(inn)
	inn.owner = root

	var exits := Node2D.new()
	exits.name = "TownExits"
	root.add_child(exits)
	exits.owner = root


func _add_2d_worldmap_nodes(root: Node2D) -> void:
	var map_bg := Sprite2D.new()
	map_bg.name = "MapBackground"
	root.add_child(map_bg)
	map_bg.owner = root

	var locations := Node2D.new()
	locations.name = "Locations"
	root.add_child(locations)
	locations.owner = root

	var paths := Node2D.new()
	paths.name = "Paths"
	root.add_child(paths)
	paths.owner = root

	var player_marker := Marker2D.new()
	player_marker.name = "PlayerMarker"
	root.add_child(player_marker)
	player_marker.owner = root


func _add_2d_boss_arena_nodes(root: Node2D) -> void:
	var arena_bg := ColorRect.new()
	arena_bg.name = "ArenaBackground"
	arena_bg.size = Vector2(1920, 1080)
	arena_bg.color = Color(0.1, 0.05, 0.15)
	root.add_child(arena_bg)
	arena_bg.owner = root

	var boss_spawn := Marker2D.new()
	boss_spawn.name = "BossSpawn"
	boss_spawn.position = Vector2(960, 300)
	root.add_child(boss_spawn)
	boss_spawn.owner = root

	var party_spawn := Marker2D.new()
	party_spawn.name = "PartySpawn"
	party_spawn.position = Vector2(960, 700)
	root.add_child(party_spawn)
	party_spawn.owner = root

	var hazards := Node2D.new()
	hazards.name = "Hazards"
	root.add_child(hazards)
	hazards.owner = root


func _add_2d_cutscene_nodes(root: Node2D) -> void:
	var actors := Node2D.new()
	actors.name = "Actors"
	root.add_child(actors)
	actors.owner = root

	var animation_player := AnimationPlayer.new()
	animation_player.name = "CutsceneAnimations"
	root.add_child(animation_player)
	animation_player.owner = root

	var dialogue_layer := CanvasLayer.new()
	dialogue_layer.name = "DialogueLayer"
	root.add_child(dialogue_layer)
	dialogue_layer.owner = root
