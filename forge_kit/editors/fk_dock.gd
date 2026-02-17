@tool
extends Control
## Main ForgeKit dock that appears in the Godot editor.
## Provides quick-access buttons for creating and managing all RPG resources and scenes.

var editor_plugin: EditorPlugin

var _tab_container: TabContainer
var _quick_setup_panel: VBoxContainer
var _setup_log_label: RichTextLabel
var _setup_button: Button
var _setup_panel: VBoxContainer
var _resource_panel: VBoxContainer
var _scene_panel: VBoxContainer
var _database_panel: VBoxContainer

# Setup tab references
var _genre_option: OptionButton
var _game_name_edit: LineEdit
var _stat_checks: Dictionary = {}
var _custom_stat_edit: LineEdit
var _stat_list_container: VBoxContainer
var _derived_container: VBoxContainer
var _element_checks: Dictionary = {}
var _custom_element_edit: LineEdit
var _element_list_container: VBoxContainer
var _slot_checks: Dictionary = {}
var _custom_slot_edit: LineEdit
var _slot_list_container: VBoxContainer
var _currency_edit: LineEdit
var _sell_ratio_spin: SpinBox
var _battle_type_option: OptionButton
var _party_size_spin: SpinBox
var _max_enemies_spin: SpinBox
var _exp_dist_option: OptionButton
var _flee_check: CheckBox
var _max_level_spin: SpinBox
var _setup_apply_log: RichTextLabel

const GENRE_PRESETS := {
	"Classic JRPG": {
		"stats": ["strength", "dexterity", "intelligence", "wisdom", "vitality", "luck"],
		"derived": {"physical_attack": {"weights": {"strength": 1.5, "dexterity": 0.3}}, "magic_attack": {"weights": {"intelligence": 1.5, "wisdom": 0.3}}, "evasion": {"weights": {"dexterity": 0.5, "luck": 0.3}}, "heal_power": {"weights": {"wisdom": 1.5, "intelligence": 0.2}}},
		"elements": ["Fire", "Ice", "Lightning", "Holy", "Dark", "Wind", "Earth", "Water"],
		"slots": ["main_hand", "off_hand", "head", "body", "accessory_1", "accessory_2"],
		"currency": "Gold", "sell_ratio": 0.5,
		"battle_type": "Turn-Based", "party_size": 4, "max_enemies": 4,
		"exp_dist": "Full to All", "allow_flee": true, "max_level": 99,
	},
	"Action RPG": {
		"stats": ["strength", "dexterity", "intelligence", "vitality", "luck"],
		"derived": {"physical_attack": {"weights": {"strength": 1.5, "dexterity": 0.5}}, "magic_attack": {"weights": {"intelligence": 2.0}}, "evasion": {"weights": {"dexterity": 0.8}}, "heal_power": {"weights": {"intelligence": 1.2, "vitality": 0.3}}},
		"elements": ["Fire", "Ice", "Lightning", "Dark"],
		"slots": ["main_hand", "off_hand", "head", "body", "legs", "feet", "ring", "necklace"],
		"currency": "Gold", "sell_ratio": 0.4,
		"battle_type": "Action Real-Time", "party_size": 1, "max_enemies": 8,
		"exp_dist": "Active Only", "allow_flee": true, "max_level": 99,
	},
	"Tactical RPG": {
		"stats": ["strength", "dexterity", "intelligence", "wisdom", "vitality", "luck", "movement"],
		"derived": {"physical_attack": {"weights": {"strength": 1.5}}, "magic_attack": {"weights": {"intelligence": 1.5}}, "evasion": {"weights": {"dexterity": 0.4, "luck": 0.2}}, "heal_power": {"weights": {"wisdom": 1.5}}},
		"elements": ["Fire", "Ice", "Lightning", "Holy", "Dark", "Wind"],
		"slots": ["main_hand", "off_hand", "head", "body", "accessory_1"],
		"currency": "Gold", "sell_ratio": 0.5,
		"battle_type": "Tactical Grid", "party_size": 6, "max_enemies": 8,
		"exp_dist": "Active Only", "allow_flee": false, "max_level": 50,
	},
	"Dungeon Crawler": {
		"stats": ["strength", "dexterity", "intelligence", "wisdom", "vitality", "luck"],
		"derived": {"physical_attack": {"weights": {"strength": 1.5, "dexterity": 0.2}}, "magic_attack": {"weights": {"intelligence": 1.5, "wisdom": 0.5}}, "evasion": {"weights": {"dexterity": 0.5, "luck": 0.3}}, "heal_power": {"weights": {"wisdom": 1.5, "intelligence": 0.3}}},
		"elements": ["Fire", "Ice", "Lightning", "Holy", "Dark"],
		"slots": ["main_hand", "off_hand", "head", "body", "legs", "feet", "ring", "necklace"],
		"currency": "Gold", "sell_ratio": 0.3,
		"battle_type": "Turn-Based", "party_size": 5, "max_enemies": 6,
		"exp_dist": "Split Evenly", "allow_flee": true, "max_level": 99,
	},
	"Open World": {
		"stats": ["strength", "dexterity", "intelligence", "vitality", "charisma", "luck"],
		"derived": {"physical_attack": {"weights": {"strength": 1.5, "dexterity": 0.3}}, "magic_attack": {"weights": {"intelligence": 2.0}}, "evasion": {"weights": {"dexterity": 0.6, "luck": 0.2}}, "heal_power": {"weights": {"intelligence": 1.0, "vitality": 0.5}}},
		"elements": ["Fire", "Ice", "Lightning", "Nature", "Dark"],
		"slots": ["main_hand", "off_hand", "head", "body", "legs", "feet", "ring", "necklace", "cape"],
		"currency": "Coin", "sell_ratio": 0.4,
		"battle_type": "Action Real-Time", "party_size": 3, "max_enemies": 6,
		"exp_dist": "Full to All", "allow_flee": true, "max_level": 60,
	},
	"Autobattler": {
		"stats": ["strength", "dexterity", "intelligence", "vitality", "luck"],
		"derived": {"physical_attack": {"weights": {"strength": 1.8}}, "magic_attack": {"weights": {"intelligence": 1.8}}, "evasion": {"weights": {"dexterity": 0.4, "luck": 0.4}}, "heal_power": {"weights": {"intelligence": 1.2, "vitality": 0.3}}},
		"elements": ["Fire", "Ice", "Lightning", "Nature", "Dark", "Holy"],
		"slots": ["main_hand", "body", "accessory_1", "accessory_2", "accessory_3"],
		"currency": "Gold", "sell_ratio": 0.5,
		"battle_type": "Autobattle", "party_size": 6, "max_enemies": 6,
		"exp_dist": "Full to All", "allow_flee": false, "max_level": 30,
	},
}

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

const SCENE_TEMPLATES := {
	"Battle Scene": "res://addons/forge_kit/scenes/templates/battle_scene.tscn",
	"Overworld Scene": "res://addons/forge_kit/scenes/templates/overworld_scene.tscn",
	"Title Screen": "res://addons/forge_kit/scenes/templates/title_screen.tscn",
	"Game Over Screen": "res://addons/forge_kit/scenes/templates/game_over_screen.tscn",
	"Dialogue Scene": "res://addons/forge_kit/scenes/templates/dialogue_scene.tscn",
	"Shop Scene": "res://addons/forge_kit/scenes/templates/shop_scene.tscn",
	"Inventory Screen": "res://addons/forge_kit/scenes/templates/inventory_screen.tscn",
	"Party Menu": "res://addons/forge_kit/scenes/templates/party_menu.tscn",
	"Save/Load Screen": "res://addons/forge_kit/scenes/templates/save_load_screen.tscn",
}

const RESOURCE_DESCRIPTIONS := {
	"FKStat": "Base stats like Strength, Dexterity, Intelligence",
	"FKDerivedStat": "Calculated stats like Evasion, Crit Rate",
	"FKClass": "Character classes/jobs with stat growth",
	"FKEnemy": "Monsters and enemies with AI patterns",
	"FKItem": "Weapons, armor, consumables, key items",
	"FKAbility": "Active skills and spells",
	"FKPassiveSkill": "Passive bonuses and traits",
	"FKSkillTree": "Skill trees with unlockable nodes",
	"FKLootTable": "Drop tables with weighted random items",
	"FKEncounterTable": "Random encounter tables for zones",
	"FKZone": "Game areas with encounters and NPCs",
	"FKDialogue": "Branching dialogue trees",
	"FKQuest": "Quests with objectives and rewards",
}

const RESOURCE_CATEGORIES := {
	"Characters": ["FKStat", "FKDerivedStat", "FKClass"],
	"Combat": ["FKEnemy", "FKAbility", "FKPassiveSkill", "FKSkillTree"],
	"Items & Loot": ["FKItem", "FKLootTable"],
	"World": ["FKZone", "FKEncounterTable"],
	"Story": ["FKDialogue", "FKQuest"],
}


func _get_resource_dir(res_type: String) -> String:
	return "res://rpg_data/rpg_" + res_type.trim_prefix("FK").to_snake_case() + "/"


func _ready() -> void:
	name = "ForgeKit"
	custom_minimum_size = Vector2(250, 400)
	_build_ui()


func _build_ui() -> void:
	# Title
	var title_label := Label.new()
	title_label.text = "ForgeKit"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 18)
	add_child(title_label)

	# Separator
	var sep := HSeparator.new()
	add_child(sep)

	# Tab container
	_tab_container = TabContainer.new()
	_tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tab_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(_tab_container)

	_build_quick_setup_tab()
	_build_setup_tab()
	_build_resource_tab()
	_build_scene_tab()
	_build_database_tab()

	# Force layout
	_apply_layout()


func _apply_layout() -> void:
	var vbox := VBoxContainer.new()
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Re-parent children into vbox
	var children := get_children()
	for child in children:
		remove_child(child)
		vbox.add_child(child)

	# Use a MarginContainer for padding
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(vbox)
	add_child(margin)


func _build_quick_setup_tab() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "Quick Setup"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_tab_container.add_child(scroll)

	_quick_setup_panel = VBoxContainer.new()
	_quick_setup_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_quick_setup_panel)

	# Welcome header
	var header := Label.new()
	header.text = "Welcome to ForgeKit!"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 16)
	_quick_setup_panel.add_child(header)

	_quick_setup_panel.add_child(HSeparator.new())

	# Explanation
	var info := Label.new()
	info.text = "Get started fast! Click the button below to generate a complete starter RPG dataset including stats, classes, enemies, items, abilities, passive skills, a skill tree, loot tables, encounters, a zone, dialogue, and a quest.\n\nEverything is fully editable afterwards. This gives you a working foundation to build your RPG from."
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_theme_font_size_override("font_size", 12)
	_quick_setup_panel.add_child(info)

	_quick_setup_panel.add_child(HSeparator.new())

	# What you get summary
	var summary_label := Label.new()
	summary_label.text = "This will create:"
	summary_label.add_theme_font_size_override("font_size", 13)
	_quick_setup_panel.add_child(summary_label)

	var items_text := Label.new()
	items_text.text = "  - 6 Base Stats + 4 Derived Stats\n  - 8 Abilities (attacks, spells, heals)\n  - 5 Passive Skills + 1 Skill Tree\n  - 3 Classes (Warrior, Mage, Rogue)\n  - 8 Items (weapons, armor, potions)\n  - 4 Enemies (Slime to Dragon boss)\n  - 2 Loot Tables + 1 Encounter Table\n  - 1 Zone, 1 Dialogue, 1 Quest"
	items_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	items_text.add_theme_font_size_override("font_size", 11)
	_quick_setup_panel.add_child(items_text)

	_quick_setup_panel.add_child(HSeparator.new())

	# Setup button
	_setup_button = Button.new()
	_setup_button.text = "Run Quick Setup"
	_setup_button.custom_minimum_size = Vector2(0, 45)
	_setup_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_setup_button.pressed.connect(_run_quick_setup)
	_quick_setup_panel.add_child(_setup_button)

	# Check if data already exists
	if DirAccess.dir_exists_absolute("res://rpg_data/"):
		var warning := Label.new()
		warning.text = "rpg_data/ folder detected. Running setup again will overwrite existing starter resources."
		warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		warning.add_theme_font_size_override("font_size", 11)
		warning.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
		_quick_setup_panel.add_child(warning)

	_quick_setup_panel.add_child(HSeparator.new())

	# Log area
	_setup_log_label = RichTextLabel.new()
	_setup_log_label.name = "SetupLog"
	_setup_log_label.custom_minimum_size = Vector2(0, 200)
	_setup_log_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_setup_log_label.text = ""
	_setup_log_label.scroll_following = true
	_quick_setup_panel.add_child(_setup_log_label)


func _log_setup(msg: String) -> void:
	if _setup_log_label:
		_setup_log_label.text += msg + "\n"


func _make_resource(script_path: String, props: Dictionary, save_path: String) -> Resource:
	var script: GDScript = load(script_path)
	var res: Resource = script.new()
	for key in props:
		res.set(key, props[key])
	# Ensure directory exists
	var dir_path: String = save_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	ResourceSaver.save(res, save_path)
	return res


func _run_quick_setup() -> void:
	_setup_button.disabled = true
	_setup_button.text = "Setting up..."
	if _setup_log_label:
		_setup_log_label.text = ""

	var base: String = "res://addons/forge_kit/resources/"

	# ===== STATS =====
	_log_setup("[b]Creating Stats...[/b]")

	var stat_defs: Array[Dictionary] = [
		{"id": "strength", "display_name": "Strength", "description": "Physical power. Affects melee damage and carrying capacity.", "default_value": 10.0, "color": Color(0.9, 0.3, 0.3)},
		{"id": "dexterity", "display_name": "Dexterity", "description": "Agility and reflexes. Affects speed, evasion, and ranged attacks.", "default_value": 10.0, "color": Color(0.3, 0.9, 0.3)},
		{"id": "intelligence", "display_name": "Intelligence", "description": "Mental acuity. Affects magic damage and MP pool.", "default_value": 10.0, "color": Color(0.3, 0.3, 0.9)},
		{"id": "wisdom", "display_name": "Wisdom", "description": "Spiritual insight. Affects healing power and magic resistance.", "default_value": 10.0, "color": Color(0.7, 0.3, 0.9)},
		{"id": "vitality", "display_name": "Vitality", "description": "Physical endurance. Affects HP and defense.", "default_value": 10.0, "color": Color(0.9, 0.6, 0.2)},
		{"id": "luck", "display_name": "Luck", "description": "Fortune and fate. Affects critical hits, loot drops, and evasion.", "default_value": 10.0, "color": Color(0.9, 0.9, 0.2)},
	]

	for stat in stat_defs:
		var path: String = "res://rpg_data/rpg_stat/" + stat["id"] + ".tres"
		_make_resource(base + "fk_stat.gd", stat, path)
		_log_setup("  + Stat: " + stat["display_name"])

	# ===== DERIVED STATS =====
	_log_setup("[b]Creating Derived Stats...[/b]")

	var derived_defs: Array[Dictionary] = [
		{"id": "physical_attack", "display_name": "Physical Attack", "description": "Total physical damage output.", "stat_weights": {"strength": 1.5, "dexterity": 0.3}, "flat_bonus": 0.0},
		{"id": "magic_attack", "display_name": "Magic Attack", "description": "Total magical damage output.", "stat_weights": {"intelligence": 1.5, "wisdom": 0.3}, "flat_bonus": 0.0},
		{"id": "evasion", "display_name": "Evasion", "description": "Chance to dodge attacks.", "stat_weights": {"dexterity": 0.5, "luck": 0.3}, "flat_bonus": 0.0, "max_value": 100.0},
		{"id": "heal_power", "display_name": "Heal Power", "description": "Effectiveness of healing abilities.", "stat_weights": {"wisdom": 1.5, "intelligence": 0.2}, "flat_bonus": 0.0},
	]

	for ds in derived_defs:
		var path: String = "res://rpg_data/rpg_derived_stat/" + ds["id"] + ".tres"
		_make_resource(base + "fk_derived_stat.gd", ds, path)
		_log_setup("  + Derived Stat: " + ds["display_name"])

	# ===== ABILITIES =====
	_log_setup("[b]Creating Abilities...[/b]")

	var ability_defs: Array[Dictionary] = [
		{"id": "slash", "display_name": "Slash", "description": "A basic sword strike.", "ability_type": "Physical", "target_type": "Single Enemy", "element": "None", "mp_cost": 0, "base_power": 15.0, "scaling_stat": "strength", "scaling_multiplier": 1.0, "level_requirement": 1},
		{"id": "power_strike", "display_name": "Power Strike", "description": "A powerful focused blow that deals heavy damage.", "ability_type": "Physical", "target_type": "Single Enemy", "element": "None", "mp_cost": 8, "base_power": 35.0, "scaling_stat": "strength", "scaling_multiplier": 1.5, "level_requirement": 5},
		{"id": "fireball", "display_name": "Fireball", "description": "Hurls a ball of fire at all enemies.", "ability_type": "Magical", "target_type": "All Enemies", "element": "Fire", "mp_cost": 12, "base_power": 25.0, "scaling_stat": "intelligence", "scaling_multiplier": 1.3, "level_requirement": 3},
		{"id": "ice_shard", "display_name": "Ice Shard", "description": "Launches a razor-sharp shard of ice at one enemy.", "ability_type": "Magical", "target_type": "Single Enemy", "element": "Ice", "mp_cost": 6, "base_power": 20.0, "scaling_stat": "intelligence", "scaling_multiplier": 1.2, "level_requirement": 1},
		{"id": "heal", "display_name": "Heal", "description": "Restores HP to a single ally.", "ability_type": "Healing", "target_type": "Single Ally", "element": "None", "mp_cost": 5, "base_power": 30.0, "scaling_stat": "wisdom", "scaling_multiplier": 1.5, "level_requirement": 1},
		{"id": "group_heal", "display_name": "Group Heal", "description": "Restores HP to all allies.", "ability_type": "Healing", "target_type": "All Allies", "element": "None", "mp_cost": 15, "base_power": 20.0, "scaling_stat": "wisdom", "scaling_multiplier": 1.2, "level_requirement": 8},
		{"id": "shield_bash", "display_name": "Shield Bash", "description": "Bashes an enemy with your shield. May stun.", "ability_type": "Physical", "target_type": "Single Enemy", "element": "None", "mp_cost": 5, "base_power": 20.0, "scaling_stat": "strength", "scaling_multiplier": 0.8, "level_requirement": 3},
		{"id": "poison_sting", "display_name": "Poison Sting", "description": "A venomous strike that may poison the target.", "ability_type": "Physical", "target_type": "Single Enemy", "element": "None", "mp_cost": 4, "base_power": 12.0, "scaling_stat": "dexterity", "scaling_multiplier": 1.0, "level_requirement": 2},
	]

	for ab in ability_defs:
		var path: String = "res://rpg_data/rpg_ability/" + ab["id"] + ".tres"
		_make_resource(base + "fk_ability.gd", ab, path)
		_log_setup("  + Ability: " + ab["display_name"])

	# Assign status_effects separately as typed arrays so Godot serializes them.
	var shield_bash_fx: Array[Dictionary] = []
	shield_bash_fx.append({"status": "stun", "chance": 0.3, "duration": 1})
	var shield_bash_res: Resource = load("res://rpg_data/rpg_ability/shield_bash.tres")
	shield_bash_res.set("status_effects", shield_bash_fx)
	ResourceSaver.save(shield_bash_res, "res://rpg_data/rpg_ability/shield_bash.tres")

	var poison_sting_fx: Array[Dictionary] = []
	poison_sting_fx.append({"status": "poison", "chance": 0.5, "duration": 3})
	var poison_sting_res: Resource = load("res://rpg_data/rpg_ability/poison_sting.tres")
	poison_sting_res.set("status_effects", poison_sting_fx)
	ResourceSaver.save(poison_sting_res, "res://rpg_data/rpg_ability/poison_sting.tres")

	# ===== PASSIVE SKILLS =====
	_log_setup("[b]Creating Passive Skills...[/b]")

	var passive_defs: Array[Dictionary] = [
		{"id": "iron_body", "display_name": "Iron Body", "description": "Toughens the body, increasing vitality.", "stat_bonuses": {"vitality": 3}, "activation_condition": "Always", "level_requirement": 1, "max_rank": 3},
		{"id": "keen_eye", "display_name": "Keen Eye", "description": "Sharpens reflexes, boosting dexterity.", "stat_bonuses": {"dexterity": 3}, "activation_condition": "Always", "level_requirement": 1, "max_rank": 3},
		{"id": "arcane_mind", "display_name": "Arcane Mind", "description": "Expands magical capacity, increasing intelligence.", "stat_bonuses": {"intelligence": 3}, "activation_condition": "Always", "level_requirement": 1, "max_rank": 3},
		{"id": "last_stand", "display_name": "Last Stand", "description": "When HP is low, strength increases dramatically.", "stat_percent_bonuses": {"strength": 0.25}, "activation_condition": "HP Below 25%", "level_requirement": 5, "max_rank": 1},
		{"id": "lucky_star", "display_name": "Lucky Star", "description": "Fortune smiles upon you. Increases luck.", "stat_bonuses": {"luck": 5}, "activation_condition": "Always", "level_requirement": 3, "max_rank": 2},
	]

	for ps in passive_defs:
		var path: String = "res://rpg_data/rpg_passive_skill/" + ps["id"] + ".tres"
		_make_resource(base + "fk_passive_skill.gd", ps, path)
		_log_setup("  + Passive Skill: " + ps["display_name"])

	# ===== SKILL TREE =====
	_log_setup("[b]Creating Skill Tree...[/b]")

	var iron_body_ref: Resource = load("res://rpg_data/rpg_passive_skill/iron_body.tres")
	var keen_eye_ref: Resource = load("res://rpg_data/rpg_passive_skill/keen_eye.tres")
	var last_stand_ref: Resource = load("res://rpg_data/rpg_passive_skill/last_stand.tres")
	var power_strike_ref: Resource = load("res://rpg_data/rpg_ability/power_strike.tres")
	var shield_bash_ref: Resource = load("res://rpg_data/rpg_ability/shield_bash.tres")

	# Build the nodes as a properly typed Array[Dictionary] so Godot serializes it.
	# Passing an untyped Array from a Dictionary literal through _make_resource causes
	# Godot's ResourceSaver to silently drop the nodes property.
	var tree_nodes: Array[Dictionary] = []
	tree_nodes.append({"id": "node_0", "name": "Iron Body I", "description": "Toughen your body.", "type": "passive", "resource": iron_body_ref, "cost": 1, "max_rank": 3, "prerequisites": [] as Array[String], "tier": 0, "position": Vector2(0, 0)})
	tree_nodes.append({"id": "node_1", "name": "Keen Eye I", "description": "Sharpen your reflexes.", "type": "passive", "resource": keen_eye_ref, "cost": 1, "max_rank": 3, "prerequisites": [] as Array[String], "tier": 0, "position": Vector2(0, 180)})
	tree_nodes.append({"id": "node_2", "name": "Power Strike", "description": "Unlock the Power Strike ability.", "type": "ability", "resource": power_strike_ref, "cost": 2, "max_rank": 1, "prerequisites": ["node_0"] as Array[String], "tier": 1, "position": Vector2(300, 0)})
	tree_nodes.append({"id": "node_3", "name": "Shield Bash", "description": "Unlock the Shield Bash ability.", "type": "ability", "resource": shield_bash_ref, "cost": 2, "max_rank": 1, "prerequisites": ["node_1"] as Array[String], "tier": 1, "position": Vector2(300, 180)})
	tree_nodes.append({"id": "node_4", "name": "Combat Mastery", "description": "Prove your martial prowess.", "type": "milestone", "cost": 3, "max_rank": 1, "prerequisites": ["node_2", "node_3"] as Array[String], "tier": 2, "position": Vector2(600, 90)})
	tree_nodes.append({"id": "node_5", "name": "Last Stand", "description": "When near death, fight harder.", "type": "passive", "resource": last_stand_ref, "cost": 2, "max_rank": 1, "prerequisites": ["node_4"] as Array[String], "tier": 2, "position": Vector2(600, 270)})

	# Create the base resource first (without nodes), then assign nodes explicitly.
	var warrior_tree_props: Dictionary = {
		"id": "warrior_tree", "display_name": "Warrior Skill Tree",
		"description": "The path of the warrior  - grow stronger through discipline and combat mastery.",
		"tier_count": 3, "points_per_tier": 3, "max_points": -1,
	}
	var tree_path: String = "res://rpg_data/rpg_skill_tree/warrior_tree.tres"
	var tree_res: Resource = _make_resource(base + "fk_skill_tree.gd", warrior_tree_props, tree_path)
	tree_res.set("nodes", tree_nodes)
	ResourceSaver.save(tree_res, tree_path)
	_log_setup("  + Skill Tree: Warrior Skill Tree")

	# ===== ITEMS =====
	_log_setup("[b]Creating Items...[/b]")

	var item_defs: Array[Dictionary] = [
		{"id": "potion", "display_name": "Potion", "description": "Restores 50 HP.", "item_type": "Consumable", "sub_type": "Potion", "use_effects": {"heal_hp": 50}, "usable_in_battle": true, "usable_in_field": true, "consumable": true, "buy_price": 25, "sell_price": 12, "rarity": "Common"},
		{"id": "ether", "display_name": "Ether", "description": "Restores 30 MP.", "item_type": "Consumable", "sub_type": "Potion", "use_effects": {"heal_mp": 30}, "usable_in_battle": true, "usable_in_field": true, "consumable": true, "buy_price": 50, "sell_price": 25, "rarity": "Common"},
		{"id": "antidote", "display_name": "Antidote", "description": "Cures poison.", "item_type": "Consumable", "sub_type": "Medicine", "use_effects": {"cure_poison": true}, "usable_in_battle": true, "usable_in_field": true, "consumable": true, "buy_price": 15, "sell_price": 7, "rarity": "Common"},
		{"id": "iron_sword", "display_name": "Iron Sword", "description": "A sturdy iron blade.", "item_type": "Weapon", "sub_type": "Sword", "equipment_slot": "main_hand", "stat_modifiers": {"strength": 5}, "buy_price": 150, "sell_price": 75, "rarity": "Common"},
		{"id": "wooden_staff", "display_name": "Wooden Staff", "description": "A staff carved from enchanted wood.", "item_type": "Weapon", "sub_type": "Staff", "equipment_slot": "main_hand", "stat_modifiers": {"intelligence": 5}, "buy_price": 120, "sell_price": 60, "rarity": "Common"},
		{"id": "iron_dagger", "display_name": "Iron Dagger", "description": "A lightweight iron dagger, fast and precise.", "item_type": "Weapon", "sub_type": "Dagger", "equipment_slot": "main_hand", "stat_modifiers": {"strength": 3, "dexterity": 3}, "buy_price": 100, "sell_price": 50, "rarity": "Common"},
		{"id": "leather_armor", "display_name": "Leather Armor", "description": "Basic leather protection.", "item_type": "Armor", "sub_type": "Light Armor", "equipment_slot": "body", "stat_modifiers": {"vitality": 3}, "buy_price": 80, "sell_price": 40, "rarity": "Common"},
		{"id": "iron_shield", "display_name": "Iron Shield", "description": "A small but solid iron shield.", "item_type": "Armor", "sub_type": "Shield", "equipment_slot": "off_hand", "stat_modifiers": {"vitality": 2}, "buy_price": 90, "sell_price": 45, "rarity": "Common"},
	]

	for it in item_defs:
		var path: String = "res://rpg_data/rpg_item/" + it["id"] + ".tres"
		_make_resource(base + "fk_item.gd", it, path)
		_log_setup("  + Item: " + it["display_name"])

	# ===== CLASSES =====
	_log_setup("[b]Creating Classes...[/b]")

	var warrior_tree_ref: Resource = load("res://rpg_data/rpg_skill_tree/warrior_tree.tres")
	var warrior_passives: Array[Resource] = [
		load("res://rpg_data/rpg_passive_skill/iron_body.tres"),
		load("res://rpg_data/rpg_passive_skill/last_stand.tres"),
	]

	var class_defs: Array[Dictionary] = [
		{
			"id": "warrior", "display_name": "Warrior",
			"description": "A mighty frontline fighter with high strength and vitality. Excels at melee combat and protecting allies.",
			"base_stats": {"strength": 15, "dexterity": 8, "intelligence": 4, "wisdom": 5, "vitality": 14, "luck": 6},
			"stat_growth_per_level": {"strength": 3.0, "dexterity": 1.5, "intelligence": 0.5, "wisdom": 1.0, "vitality": 3.0, "luck": 1.0},
			"equippable_types": ["sword", "shield", "heavy_armor", "light_armor"],
			"skill_tree": warrior_tree_ref,
			"passive_skills": warrior_passives,
			"exp_curve": "Quadratic", "base_exp": 100, "exp_scale": 1.5, "max_level": 99,
		},
		{
			"id": "mage", "display_name": "Mage",
			"description": "A scholar of the arcane arts with devastating magical abilities but fragile defenses.",
			"base_stats": {"strength": 4, "dexterity": 6, "intelligence": 16, "wisdom": 12, "vitality": 6, "luck": 8},
			"stat_growth_per_level": {"strength": 0.5, "dexterity": 1.0, "intelligence": 3.5, "wisdom": 2.5, "vitality": 1.0, "luck": 1.5},
			"equippable_types": ["staff", "robe", "light_armor"],
			"exp_curve": "Quadratic", "base_exp": 100, "exp_scale": 1.5, "max_level": 99,
		},
		{
			"id": "rogue", "display_name": "Rogue",
			"description": "A swift and cunning fighter who relies on speed, critical hits, and dirty tricks.",
			"base_stats": {"strength": 8, "dexterity": 16, "intelligence": 6, "wisdom": 5, "vitality": 8, "luck": 14},
			"stat_growth_per_level": {"strength": 1.5, "dexterity": 3.5, "intelligence": 1.0, "wisdom": 0.5, "vitality": 1.5, "luck": 3.0},
			"equippable_types": ["dagger", "light_armor"],
			"exp_curve": "Quadratic", "base_exp": 100, "exp_scale": 1.5, "max_level": 99,
		},
	]

	for cl in class_defs:
		var path: String = "res://rpg_data/rpg_class/" + cl["id"] + ".tres"
		_make_resource(base + "fk_class.gd", cl, path)
		_log_setup("  + Class: " + cl["display_name"])

	# ===== ENEMIES =====
	_log_setup("[b]Creating Enemies...[/b]")

	var enemy_defs: Array[Dictionary] = [
		{
			"id": "slime", "display_name": "Slime",
			"description": "A wobbly blob of goo. Weak but numerous.",
			"base_stats": {"strength": 4, "dexterity": 3, "intelligence": 1, "wisdom": 1, "vitality": 5, "luck": 2},
			"max_hp": 30, "max_mp": 0, "level": 1,
			"exp_reward": 8, "gold_reward": 5,
			"enemy_tier": "Normal", "type_tags": ["slime", "beast"],
		},
		{
			"id": "goblin", "display_name": "Goblin",
			"description": "A small, cunning creature that fights dirty.",
			"base_stats": {"strength": 8, "dexterity": 10, "intelligence": 4, "wisdom": 3, "vitality": 8, "luck": 6},
			"max_hp": 55, "max_mp": 5, "level": 3,
			"exp_reward": 20, "gold_reward": 15,
			"enemy_tier": "Normal", "type_tags": ["humanoid", "goblin"],
		},
		{
			"id": "skeleton", "display_name": "Skeleton",
			"description": "An undead warrior risen from the grave.",
			"base_stats": {"strength": 12, "dexterity": 7, "intelligence": 2, "wisdom": 2, "vitality": 10, "luck": 3},
			"max_hp": 80, "max_mp": 0, "level": 5,
			"weaknesses": {"Holy": 2.0, "Fire": 1.5},
			"resistances": {"Dark": 0.5, "Ice": 0.75},
			"status_immunities": ["poison"],
			"exp_reward": 35, "gold_reward": 25,
			"enemy_tier": "Normal", "type_tags": ["undead"],
		},
		{
			"id": "dragon", "display_name": "Dragon",
			"description": "A fearsome ancient dragon. Approach with extreme caution.",
			"base_stats": {"strength": 30, "dexterity": 15, "intelligence": 20, "wisdom": 18, "vitality": 35, "luck": 10},
			"max_hp": 500, "max_mp": 100, "level": 15,
			"weaknesses": {"Ice": 1.5},
			"resistances": {"Fire": 0.25},
			"exp_reward": 500, "gold_reward": 300,
			"enemy_tier": "Boss", "type_tags": ["dragon", "boss"], "is_boss": true,
		},
	]

	for en in enemy_defs:
		var path: String = "res://rpg_data/rpg_enemy/" + en["id"] + ".tres"
		_make_resource(base + "fk_enemy.gd", en, path)
		_log_setup("  + Enemy: " + en["display_name"])

	# ===== LOOT TABLES =====
	_log_setup("[b]Creating Loot Tables...[/b]")

	# Load item references for loot tables
	var potion_ref: Resource = load("res://rpg_data/rpg_item/potion.tres")
	var ether_ref: Resource = load("res://rpg_data/rpg_item/ether.tres")
	var antidote_ref: Resource = load("res://rpg_data/rpg_item/antidote.tres")
	var iron_sword_ref: Resource = load("res://rpg_data/rpg_item/iron_sword.tres")
	var leather_armor_ref: Resource = load("res://rpg_data/rpg_item/leather_armor.tres")

	# Build loot table entries as typed arrays so Godot serializes them properly.
	var common_entries: Array[Dictionary] = []
	common_entries.append({"item": potion_ref, "weight": 60, "min_quantity": 1, "max_quantity": 2, "drop_chance": 0.5})
	common_entries.append({"item": ether_ref, "weight": 25, "min_quantity": 1, "max_quantity": 1, "drop_chance": 0.3})
	common_entries.append({"item": antidote_ref, "weight": 15, "min_quantity": 1, "max_quantity": 1, "drop_chance": 0.25})

	var common_loot: Dictionary = {
		"id": "common_drops", "display_name": "Common Drops",
		"roll_count": 1, "allow_duplicates": false, "guaranteed_drops": 0,
	}
	var common_path: String = "res://rpg_data/rpg_loot_table/common_drops.tres"
	var common_res: Resource = _make_resource(base + "fk_loot_table.gd", common_loot, common_path)
	common_res.set("entries", common_entries)
	ResourceSaver.save(common_res, common_path)
	_log_setup("  + Loot Table: Common Drops")

	var boss_entries: Array[Dictionary] = []
	boss_entries.append({"item": iron_sword_ref, "weight": 40, "min_quantity": 1, "max_quantity": 1, "drop_chance": 0.8})
	boss_entries.append({"item": leather_armor_ref, "weight": 30, "min_quantity": 1, "max_quantity": 1, "drop_chance": 0.6})
	boss_entries.append({"item": potion_ref, "weight": 30, "min_quantity": 2, "max_quantity": 5, "drop_chance": 1.0})

	var boss_loot: Dictionary = {
		"id": "boss_drops", "display_name": "Boss Drops",
		"roll_count": 2, "allow_duplicates": true, "guaranteed_drops": 1,
	}
	var boss_path: String = "res://rpg_data/rpg_loot_table/boss_drops.tres"
	var boss_res: Resource = _make_resource(base + "fk_loot_table.gd", boss_loot, boss_path)
	boss_res.set("entries", boss_entries)
	ResourceSaver.save(boss_res, boss_path)
	_log_setup("  + Loot Table: Boss Drops")

	# ===== ENCOUNTER TABLE =====
	_log_setup("[b]Creating Encounter Table...[/b]")

	var slime_ref: Resource = load("res://rpg_data/rpg_enemy/slime.tres")
	var goblin_ref: Resource = load("res://rpg_data/rpg_enemy/goblin.tres")
	var skeleton_ref: Resource = load("res://rpg_data/rpg_enemy/skeleton.tres")

	# Build encounter entries as typed arrays so Godot serializes them properly.
	var encounter_entries: Array[Dictionary] = []
	encounter_entries.append({"enemies": [slime_ref], "weight": 50, "min_count": 1, "max_count": 3})
	encounter_entries.append({"enemies": [goblin_ref], "weight": 30, "min_count": 1, "max_count": 2})
	encounter_entries.append({"enemies": [skeleton_ref], "weight": 15, "min_count": 1, "max_count": 1})
	encounter_entries.append({"enemies": [slime_ref, goblin_ref], "weight": 5, "min_count": 1, "max_count": 2})

	var forest_encounters: Dictionary = {
		"id": "forest_encounters", "display_name": "Forest Encounters",
		"base_steps": 25, "step_variance": 0.5, "avoidable": true, "max_enemies_per_battle": 4,
	}
	var encounters_path: String = "res://rpg_data/rpg_encounter_table/forest_encounters.tres"
	var encounters_res: Resource = _make_resource(base + "fk_encounter_table.gd", forest_encounters, encounters_path)
	encounters_res.set("entries", encounter_entries)
	ResourceSaver.save(encounters_res, encounters_path)
	_log_setup("  + Encounter Table: Forest Encounters")

	# ===== ZONE =====
	_log_setup("[b]Creating Zone...[/b]")

	var encounter_table_ref: Resource = load("res://rpg_data/rpg_encounter_table/forest_encounters.tres")

	var forest_zone: Dictionary = {
		"id": "forest", "display_name": "Emerald Forest",
		"description": "A dense forest filled with monsters. Adventurers come here to train and gather herbs.",
		"zone_type": "Overworld",
		"encounter_table": encounter_table_ref,
		"has_encounters": true,
		"recommended_level_min": 1, "recommended_level_max": 5,
		"allow_save": true, "allow_teleport": true,
		"weather": "None", "lighting": "Dynamic",
	}
	_make_resource(base + "fk_zone.gd", forest_zone, "res://rpg_data/rpg_zone/forest.tres")
	_log_setup("  + Zone: Emerald Forest")

	# ===== DIALOGUE =====
	_log_setup("[b]Creating Dialogue...[/b]")

	# Build dialogue nodes as typed Array[Dictionary] so Godot serializes them properly.
	var dialogue_nodes: Array[Dictionary] = []
	dialogue_nodes.append({"id": "node_0", "type": "text", "speaker": "Village Elder", "text": "Welcome, young adventurer! Our village has been troubled by monsters in the Emerald Forest.", "next": "node_1"})
	var choice_list: Array[Dictionary] = []
	choice_list.append({"text": "I'll take care of it!", "next": "node_accept"})
	choice_list.append({"text": "Tell me more about the monsters.", "next": "node_info"})
	choice_list.append({"text": "Not right now.", "next": "node_decline"})
	dialogue_nodes.append({"id": "node_1", "type": "choice", "speaker": "Village Elder", "text": "Will you help us deal with the slime infestation?", "choices": choice_list})
	dialogue_nodes.append({"id": "node_accept", "type": "text", "speaker": "Village Elder", "text": "Wonderful! Defeat 5 slimes and bring back 3 potions you find. Return to me when you're done.", "next": "node_end"})
	dialogue_nodes.append({"id": "node_info", "type": "text", "speaker": "Village Elder", "text": "Slimes are weak creatures, but they appear in groups. Goblins are trickier - they're fast and cunning. Be careful out there!", "next": "node_1"})
	dialogue_nodes.append({"id": "node_decline", "type": "text", "speaker": "Village Elder", "text": "I understand. Come back when you're ready. The forest isn't going anywhere... though the monsters keep multiplying.", "next": "node_end"})
	dialogue_nodes.append({"id": "node_end", "type": "end"})

	var elder_dialogue: Dictionary = {
		"id": "elder_intro", "display_name": "Elder Introduction",
		"speaker_name": "Village Elder",
		"skippable": true, "text_speed": 1.0,
	}
	var dialogue_path: String = "res://rpg_data/rpg_dialogue/elder_intro.tres"
	var dialogue_res: Resource = _make_resource(base + "fk_dialogue.gd", elder_dialogue, dialogue_path)
	dialogue_res.set("nodes", dialogue_nodes)
	ResourceSaver.save(dialogue_res, dialogue_path)
	_log_setup("  + Dialogue: Elder Introduction")

	# ===== QUEST =====
	_log_setup("[b]Creating Quest...[/b]")

	# Build quest objectives as typed Array[Dictionary] so Godot serializes them properly.
	var quest_objectives: Array[Dictionary] = []
	quest_objectives.append({"id": "kill_slimes", "type": "kill", "description": "Defeat 5 Slimes", "target": "slime", "count": 5, "optional": false, "hidden": false})
	quest_objectives.append({"id": "collect_potions", "type": "collect", "description": "Collect 3 Potions", "target": "potion", "count": 3, "optional": false, "hidden": false})
	quest_objectives.append({"id": "report_elder", "type": "talk", "description": "Report to the Village Elder", "target": "elder", "count": 1, "optional": false, "hidden": false})

	var slime_quest: Dictionary = {
		"id": "slime_slayer", "display_name": "Slime Slayer",
		"summary": "The Village Elder needs help clearing slimes from the Emerald Forest.",
		"description": "Slimes have been multiplying in the Emerald Forest, threatening the village's safety. The Elder has asked you to defeat 5 slimes and collect 3 potions dropped by the creatures, then report back.",
		"quest_type": "Side Quest",
		"level_requirement": 1,
		"exp_reward": 50, "gold_reward": 100,
		"abandonable": true, "repeatable": false,
	}
	var quest_path: String = "res://rpg_data/rpg_quest/slime_slayer.tres"
	var quest_res: Resource = _make_resource(base + "fk_quest.gd", slime_quest, quest_path)
	quest_res.set("objectives", quest_objectives)
	ResourceSaver.save(quest_res, quest_path)
	_log_setup("  + Quest: Slime Slayer")

	# ===== DONE =====
	_log_setup("")
	_log_setup("[b]Quick Setup Complete![/b]")
	_log_setup("Created 45 resources across all categories.")
	_log_setup("")
	_log_setup("Next steps:")
	_log_setup("  1. Switch to the Database tab and hit Refresh")
	_log_setup("  2. Click any resource to view/edit in the Inspector")
	_log_setup("  3. Use the Scenes tab to create battle, overworld, or menu scenes")
	_log_setup("  4. Customize everything to fit your RPG!")

	_setup_button.text = "Setup Complete!"

	# Trigger filesystem scan
	if editor_plugin:
		editor_plugin.get_editor_interface().get_resource_filesystem().scan()


func _build_setup_tab() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "Setup"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_tab_container.add_child(scroll)

	_setup_panel = VBoxContainer.new()
	_setup_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_setup_panel)

	# Header
	var header := Label.new()
	header.text = "ForgeKit Setup"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 16)
	_setup_panel.add_child(header)

	var info := Label.new()
	info.text = "Configure your game's core systems. Pick a genre preset to auto-fill, then customize to your liking."
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_theme_font_size_override("font_size", 11)
	_setup_panel.add_child(info)

	_setup_panel.add_child(HSeparator.new())

	# === 1. GAME PROFILE ===
	_add_section_label("Game Profile")

	var name_hbox := HBoxContainer.new()
	_setup_panel.add_child(name_hbox)
	var name_label := Label.new()
	name_label.text = "Game Name:"
	name_label.custom_minimum_size = Vector2(90, 0)
	name_hbox.add_child(name_label)
	_game_name_edit = LineEdit.new()
	_game_name_edit.text = "My RPG"
	_game_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_hbox.add_child(_game_name_edit)

	var genre_hbox := HBoxContainer.new()
	_setup_panel.add_child(genre_hbox)
	var genre_label := Label.new()
	genre_label.text = "Genre:"
	genre_label.custom_minimum_size = Vector2(90, 0)
	genre_hbox.add_child(genre_label)
	_genre_option = OptionButton.new()
	_genre_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for genre_name in GENRE_PRESETS:
		_genre_option.add_item(genre_name)
	_genre_option.item_selected.connect(_on_genre_selected)
	genre_hbox.add_child(_genre_option)

	_setup_panel.add_child(HSeparator.new())

	# === 2. STAT BUILDER ===
	_add_section_label("Base Stats")
	var stat_info := Label.new()
	stat_info.text = "Check the stats your game uses. Add custom ones below."
	stat_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stat_info.add_theme_font_size_override("font_size", 11)
	_setup_panel.add_child(stat_info)

	_stat_list_container = VBoxContainer.new()
	_setup_panel.add_child(_stat_list_container)

	var all_stats: Array[String] = ["strength", "dexterity", "intelligence", "wisdom", "vitality", "luck", "charisma", "movement", "perception", "endurance"]
	for stat_name in all_stats:
		var cb := CheckBox.new()
		cb.text = stat_name.capitalize()
		cb.button_pressed = stat_name in ["strength", "dexterity", "intelligence", "wisdom", "vitality", "luck"]
		_stat_list_container.add_child(cb)
		_stat_checks[stat_name] = cb

	var add_stat_hbox := HBoxContainer.new()
	_setup_panel.add_child(add_stat_hbox)
	_custom_stat_edit = LineEdit.new()
	_custom_stat_edit.placeholder_text = "custom stat name"
	_custom_stat_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_stat_hbox.add_child(_custom_stat_edit)
	var add_stat_btn := Button.new()
	add_stat_btn.text = "Add"
	add_stat_btn.pressed.connect(_on_add_custom_stat)
	add_stat_hbox.add_child(add_stat_btn)

	_setup_panel.add_child(HSeparator.new())

	# === 3. DERIVED STATS ===
	_add_section_label("Derived Stats")
	var derived_info := Label.new()
	derived_info.text = "Auto-configured from genre preset. Edit in the Inspector after generating."
	derived_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	derived_info.add_theme_font_size_override("font_size", 11)
	_setup_panel.add_child(derived_info)

	_derived_container = VBoxContainer.new()
	_setup_panel.add_child(_derived_container)
	_refresh_derived_display(GENRE_PRESETS["Classic JRPG"]["derived"])

	_setup_panel.add_child(HSeparator.new())

	# === 4. ELEMENT SYSTEM ===
	_add_section_label("Elements")
	var elem_info := Label.new()
	elem_info.text = "Choose which elements exist in your game."
	elem_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	elem_info.add_theme_font_size_override("font_size", 11)
	_setup_panel.add_child(elem_info)

	_element_list_container = VBoxContainer.new()
	_setup_panel.add_child(_element_list_container)

	var all_elements: Array[String] = ["Fire", "Ice", "Lightning", "Holy", "Dark", "Wind", "Earth", "Water", "Nature"]
	for elem in all_elements:
		var cb := CheckBox.new()
		cb.text = elem
		cb.button_pressed = elem in ["Fire", "Ice", "Lightning", "Holy", "Dark"]
		_element_list_container.add_child(cb)
		_element_checks[elem] = cb

	var add_elem_hbox := HBoxContainer.new()
	_setup_panel.add_child(add_elem_hbox)
	_custom_element_edit = LineEdit.new()
	_custom_element_edit.placeholder_text = "custom element"
	_custom_element_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_elem_hbox.add_child(_custom_element_edit)
	var add_elem_btn := Button.new()
	add_elem_btn.text = "Add"
	add_elem_btn.pressed.connect(_on_add_custom_element)
	add_elem_hbox.add_child(add_elem_btn)

	_setup_panel.add_child(HSeparator.new())

	# === 5. EQUIPMENT SLOTS ===
	_add_section_label("Equipment Slots")
	var slot_info := Label.new()
	slot_info.text = "Define what gear slots characters have."
	slot_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	slot_info.add_theme_font_size_override("font_size", 11)
	_setup_panel.add_child(slot_info)

	_slot_list_container = VBoxContainer.new()
	_setup_panel.add_child(_slot_list_container)

	var all_slots: Array[String] = ["main_hand", "off_hand", "head", "body", "legs", "feet", "ring", "necklace", "cape", "accessory_1", "accessory_2", "accessory_3"]
	for slot_name in all_slots:
		var cb := CheckBox.new()
		cb.text = slot_name.replace("_", " ").capitalize()
		cb.button_pressed = slot_name in ["main_hand", "off_hand", "head", "body", "accessory_1", "accessory_2"]
		_slot_list_container.add_child(cb)
		_slot_checks[slot_name] = cb

	var add_slot_hbox := HBoxContainer.new()
	_setup_panel.add_child(add_slot_hbox)
	_custom_slot_edit = LineEdit.new()
	_custom_slot_edit.placeholder_text = "custom slot (snake_case)"
	_custom_slot_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_slot_hbox.add_child(_custom_slot_edit)
	var add_slot_btn := Button.new()
	add_slot_btn.text = "Add"
	add_slot_btn.pressed.connect(_on_add_custom_slot)
	add_slot_hbox.add_child(add_slot_btn)

	_setup_panel.add_child(HSeparator.new())

	# === 6. ECONOMY ===
	_add_section_label("Economy")

	var curr_hbox := HBoxContainer.new()
	_setup_panel.add_child(curr_hbox)
	var curr_label := Label.new()
	curr_label.text = "Currency:"
	curr_label.custom_minimum_size = Vector2(90, 0)
	curr_hbox.add_child(curr_label)
	_currency_edit = LineEdit.new()
	_currency_edit.text = "Gold"
	_currency_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	curr_hbox.add_child(_currency_edit)

	var sell_hbox := HBoxContainer.new()
	_setup_panel.add_child(sell_hbox)
	var sell_label := Label.new()
	sell_label.text = "Sell Ratio:"
	sell_label.custom_minimum_size = Vector2(90, 0)
	sell_hbox.add_child(sell_label)
	_sell_ratio_spin = SpinBox.new()
	_sell_ratio_spin.min_value = 0.1
	_sell_ratio_spin.max_value = 1.0
	_sell_ratio_spin.step = 0.05
	_sell_ratio_spin.value = 0.5
	_sell_ratio_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sell_hbox.add_child(_sell_ratio_spin)

	_setup_panel.add_child(HSeparator.new())

	# === 7. BATTLE SYSTEM ===
	_add_section_label("Battle System")

	var bt_hbox := HBoxContainer.new()
	_setup_panel.add_child(bt_hbox)
	var bt_label := Label.new()
	bt_label.text = "Type:"
	bt_label.custom_minimum_size = Vector2(90, 0)
	bt_hbox.add_child(bt_label)
	_battle_type_option = OptionButton.new()
	_battle_type_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for bt in ["Turn-Based", "Active Time Battle", "Autobattle", "Tactical Grid", "Action Real-Time"]:
		_battle_type_option.add_item(bt)
	bt_hbox.add_child(_battle_type_option)

	var ps_hbox := HBoxContainer.new()
	_setup_panel.add_child(ps_hbox)
	var ps_label := Label.new()
	ps_label.text = "Party Size:"
	ps_label.custom_minimum_size = Vector2(90, 0)
	ps_hbox.add_child(ps_label)
	_party_size_spin = SpinBox.new()
	_party_size_spin.min_value = 1
	_party_size_spin.max_value = 12
	_party_size_spin.value = 4
	_party_size_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ps_hbox.add_child(_party_size_spin)

	var me_hbox := HBoxContainer.new()
	_setup_panel.add_child(me_hbox)
	var me_label := Label.new()
	me_label.text = "Max Enemies:"
	me_label.custom_minimum_size = Vector2(90, 0)
	me_hbox.add_child(me_label)
	_max_enemies_spin = SpinBox.new()
	_max_enemies_spin.min_value = 1
	_max_enemies_spin.max_value = 20
	_max_enemies_spin.value = 4
	_max_enemies_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	me_hbox.add_child(_max_enemies_spin)

	var ed_hbox := HBoxContainer.new()
	_setup_panel.add_child(ed_hbox)
	var ed_label := Label.new()
	ed_label.text = "EXP Dist.:"
	ed_label.custom_minimum_size = Vector2(90, 0)
	ed_hbox.add_child(ed_label)
	_exp_dist_option = OptionButton.new()
	_exp_dist_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for ed in ["Full to All", "Split Evenly", "Active Only"]:
		_exp_dist_option.add_item(ed)
	ed_hbox.add_child(_exp_dist_option)

	_flee_check = CheckBox.new()
	_flee_check.text = "Allow Flee from Battles"
	_flee_check.button_pressed = true
	_setup_panel.add_child(_flee_check)

	var ml_hbox := HBoxContainer.new()
	_setup_panel.add_child(ml_hbox)
	var ml_label := Label.new()
	ml_label.text = "Max Level:"
	ml_label.custom_minimum_size = Vector2(90, 0)
	ml_hbox.add_child(ml_label)
	_max_level_spin = SpinBox.new()
	_max_level_spin.min_value = 1
	_max_level_spin.max_value = 999
	_max_level_spin.value = 99
	_max_level_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ml_hbox.add_child(_max_level_spin)

	_setup_panel.add_child(HSeparator.new())

	# === APPLY BUTTON ===
	var apply_btn := Button.new()
	apply_btn.text = "Save Settings"
	apply_btn.custom_minimum_size = Vector2(0, 40)
	apply_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	apply_btn.pressed.connect(_on_apply_setup)
	_setup_panel.add_child(apply_btn)

	_setup_apply_log = RichTextLabel.new()
	_setup_apply_log.custom_minimum_size = Vector2(0, 100)
	_setup_apply_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_setup_apply_log.text = ""
	_setup_apply_log.scroll_following = true
	_setup_panel.add_child(_setup_apply_log)


func _add_section_label(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	_setup_panel.add_child(label)


func _on_genre_selected(index: int) -> void:
	var genre_name: String = _genre_option.get_item_text(index)
	if not GENRE_PRESETS.has(genre_name):
		return
	var preset: Dictionary = GENRE_PRESETS[genre_name]

	# Auto-fill stats
	var preset_stats: Array = preset.get("stats", [])
	for stat_id in _stat_checks:
		var cb: CheckBox = _stat_checks[stat_id]
		cb.button_pressed = stat_id in preset_stats

	# Auto-fill derived stats display
	_refresh_derived_display(preset.get("derived", {}))

	# Auto-fill elements
	var preset_elements: Array = preset.get("elements", [])
	for elem in _element_checks:
		var cb: CheckBox = _element_checks[elem]
		cb.button_pressed = elem in preset_elements

	# Auto-fill slots
	var preset_slots: Array = preset.get("slots", [])
	for slot_id in _slot_checks:
		var cb: CheckBox = _slot_checks[slot_id]
		cb.button_pressed = slot_id in preset_slots

	# Auto-fill economy
	_currency_edit.text = preset.get("currency", "Gold")
	_sell_ratio_spin.value = preset.get("sell_ratio", 0.5)

	# Auto-fill battle system
	var bt_text: String = preset.get("battle_type", "Turn-Based")
	for i in range(_battle_type_option.item_count):
		if _battle_type_option.get_item_text(i) == bt_text:
			_battle_type_option.selected = i
			break

	_party_size_spin.value = preset.get("party_size", 4)
	_max_enemies_spin.value = preset.get("max_enemies", 4)

	var ed_text: String = preset.get("exp_dist", "Full to All")
	for i in range(_exp_dist_option.item_count):
		if _exp_dist_option.get_item_text(i) == ed_text:
			_exp_dist_option.selected = i
			break

	_flee_check.button_pressed = preset.get("allow_flee", true)
	_max_level_spin.value = preset.get("max_level", 99)


func _refresh_derived_display(derived: Dictionary) -> void:
	for child in _derived_container.get_children():
		child.queue_free()

	if derived.is_empty():
		var none_label := Label.new()
		none_label.text = "  (none configured)"
		none_label.add_theme_font_size_override("font_size", 11)
		_derived_container.add_child(none_label)
		return

	for derived_id in derived:
		var entry: Dictionary = derived[derived_id]
		var weights: Dictionary = entry.get("weights", {})
		var parts: Array[String] = []
		for stat_id in weights:
			parts.append(stat_id.capitalize() + " x" + str(weights[stat_id]))
		var formula_text: String = " + ".join(parts) if not parts.is_empty() else "none"
		var label := Label.new()
		label.text = "  " + derived_id.replace("_", " ").capitalize() + " = " + formula_text
		label.add_theme_font_size_override("font_size", 11)
		_derived_container.add_child(label)


func _on_add_custom_stat() -> void:
	var stat_name: String = _custom_stat_edit.text.strip_edges().to_lower().replace(" ", "_")
	if stat_name.is_empty() or _stat_checks.has(stat_name):
		return
	var cb := CheckBox.new()
	cb.text = stat_name.capitalize()
	cb.button_pressed = true
	_stat_list_container.add_child(cb)
	_stat_checks[stat_name] = cb
	_custom_stat_edit.text = ""


func _on_add_custom_element() -> void:
	var elem_name: String = _custom_element_edit.text.strip_edges().capitalize()
	if elem_name.is_empty() or _element_checks.has(elem_name):
		return
	var cb := CheckBox.new()
	cb.text = elem_name
	cb.button_pressed = true
	_element_list_container.add_child(cb)
	_element_checks[elem_name] = cb
	_custom_element_edit.text = ""


func _on_add_custom_slot() -> void:
	var slot_name: String = _custom_slot_edit.text.strip_edges().to_lower().replace(" ", "_")
	if slot_name.is_empty() or _slot_checks.has(slot_name):
		return
	var cb := CheckBox.new()
	cb.text = slot_name.replace("_", " ").capitalize()
	cb.button_pressed = true
	_slot_list_container.add_child(cb)
	_slot_checks[slot_name] = cb
	_custom_slot_edit.text = ""


func _on_apply_setup() -> void:
	if _setup_apply_log:
		_setup_apply_log.text = ""

	var base: String = "res://addons/forge_kit/resources/"

	# Gather selected stats
	var selected_stats: Array[String] = []
	for stat_id in _stat_checks:
		var cb: CheckBox = _stat_checks[stat_id]
		if cb.button_pressed:
			selected_stats.append(stat_id)

	# Gather selected elements
	var selected_elements: Array[String] = []
	for elem in _element_checks:
		var cb: CheckBox = _element_checks[elem]
		if cb.button_pressed:
			selected_elements.append(elem)

	# Gather selected slots
	var selected_slots: Array[String] = []
	for slot_id in _slot_checks:
		var cb: CheckBox = _slot_checks[slot_id]
		if cb.button_pressed:
			selected_slots.append(slot_id)

	# Get derived stats from current genre preset
	var genre_name: String = _genre_option.get_item_text(_genre_option.selected)
	var preset: Dictionary = GENRE_PRESETS.get(genre_name, {})
	var derived: Dictionary = preset.get("derived", {})

	# Build settings resource
	var settings_props: Dictionary = {
		"game_name": _game_name_edit.text,
		"genre": genre_name,
		"base_stats": selected_stats,
		"derived_stats": derived,
		"elements": selected_elements,
		"equipment_slots": selected_slots,
		"currency_name": _currency_edit.text,
		"sell_ratio": _sell_ratio_spin.value,
		"battle_type": _battle_type_option.get_item_text(_battle_type_option.selected),
		"party_size": int(_party_size_spin.value),
		"max_enemies": int(_max_enemies_spin.value),
		"exp_distribution": _exp_dist_option.get_item_text(_exp_dist_option.selected),
		"allow_flee": _flee_check.button_pressed,
		"max_level": int(_max_level_spin.value),
	}

	var settings_path: String = "res://rpg_data/rpg_settings/game_settings.tres"
	_make_resource(base + "fk_settings.gd", settings_props, settings_path)
	_log_setup_apply("Saved: game_settings.tres")

	# Generate stat resources
	_log_setup_apply("Creating Stats...")
	for stat_id in selected_stats:
		var stat_path: String = "res://rpg_data/rpg_stat/" + stat_id + ".tres"
		if not ResourceLoader.exists(stat_path):
			var props: Dictionary = {
				"id": stat_id,
				"display_name": stat_id.capitalize(),
				"description": stat_id.capitalize() + " stat.",
				"default_value": 10.0,
			}
			_make_resource(base + "fk_stat.gd", props, stat_path)
			_log_setup_apply("  + " + stat_id.capitalize())
		else:
			_log_setup_apply("  ~ " + stat_id.capitalize() + " (exists)")

	# Generate derived stat resources
	_log_setup_apply("Creating Derived Stats...")
	for derived_id in derived:
		var d_path: String = "res://rpg_data/rpg_derived_stat/" + derived_id + ".tres"
		if not ResourceLoader.exists(d_path):
			var weights: Dictionary = derived[derived_id].get("weights", {})
			var props: Dictionary = {
				"id": derived_id,
				"display_name": derived_id.replace("_", " ").capitalize(),
				"description": "Derived stat.",
				"stat_weights": weights,
			}
			_make_resource(base + "fk_derived_stat.gd", props, d_path)
			_log_setup_apply("  + " + derived_id.replace("_", " ").capitalize())
		else:
			_log_setup_apply("  ~ " + derived_id.replace("_", " ").capitalize() + " (exists)")

	_log_setup_apply("")
	_log_setup_apply("Settings saved! Stats and derived stats generated.")
	_log_setup_apply("Your config is at: res://rpg_data/rpg_settings/")
	_log_setup_apply("")
	_log_setup_apply("Tip: Use Quick Setup or Resources tab to create")
	_log_setup_apply("classes, items, enemies, and more.")

	if editor_plugin:
		editor_plugin.get_editor_interface().get_resource_filesystem().scan()


func _log_setup_apply(msg: String) -> void:
	if _setup_apply_log:
		_setup_apply_log.text += msg + "\n"


func _build_resource_tab() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "Resources"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_tab_container.add_child(scroll)

	_resource_panel = VBoxContainer.new()
	_resource_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_resource_panel)

	# Info label
	var info := Label.new()
	info.text = "Create and manage ForgeKit resources.\nResources are saved as .tres files."
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_theme_font_size_override("font_size", 11)
	_resource_panel.add_child(info)

	_resource_panel.add_child(HSeparator.new())

	# Build categorized buttons
	for category in RESOURCE_CATEGORIES:
		var cat_label := Label.new()
		cat_label.text = category
		cat_label.add_theme_font_size_override("font_size", 14)
		_resource_panel.add_child(cat_label)

		for res_type in RESOURCE_CATEGORIES[category]:
			var hbox := HBoxContainer.new()
			hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_resource_panel.add_child(hbox)

			var create_btn := Button.new()
			create_btn.text = "New " + res_type.trim_prefix("FK")
			create_btn.tooltip_text = RESOURCE_DESCRIPTIONS.get(res_type, "")
			create_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			create_btn.pressed.connect(_on_create_resource.bind(res_type))
			hbox.add_child(create_btn)

			var browse_btn := Button.new()
			browse_btn.text = "..."
			browse_btn.tooltip_text = "Browse existing " + res_type + " resources"
			browse_btn.pressed.connect(_on_browse_resources.bind(res_type))
			hbox.add_child(browse_btn)

		_resource_panel.add_child(HSeparator.new())

	# Visual Editors section
	var editors_label := Label.new()
	editors_label.text = "Visual Editors"
	editors_label.add_theme_font_size_override("font_size", 14)
	_resource_panel.add_child(editors_label)

	var dialogue_editor_btn := Button.new()
	dialogue_editor_btn.text = "Open Dialogue Editor..."
	dialogue_editor_btn.tooltip_text = "Visual node-graph editor for dialogue trees"
	dialogue_editor_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dialogue_editor_btn.pressed.connect(_on_open_dialogue_editor)
	_resource_panel.add_child(dialogue_editor_btn)

	var skill_tree_editor_btn := Button.new()
	skill_tree_editor_btn.text = "Open Skill Tree Editor..."
	skill_tree_editor_btn.tooltip_text = "Visual node-graph editor for skill trees"
	skill_tree_editor_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skill_tree_editor_btn.pressed.connect(_on_open_skill_tree_editor)
	_resource_panel.add_child(skill_tree_editor_btn)

	var damage_formula_btn := Button.new()
	damage_formula_btn.text = "Damage Formula Tester..."
	damage_formula_btn.tooltip_text = "Test and preview damage calculations"
	damage_formula_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	damage_formula_btn.pressed.connect(_on_open_damage_formula)
	_resource_panel.add_child(damage_formula_btn)

	_resource_panel.add_child(HSeparator.new())


func _build_scene_tab() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "Scenes"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_tab_container.add_child(scroll)

	_scene_panel = VBoxContainer.new()
	_scene_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_scene_panel)

	var info := Label.new()
	info.text = "Generate pre-built scene templates.\nScenes are copied to your project."
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_theme_font_size_override("font_size", 11)
	_scene_panel.add_child(info)

	_scene_panel.add_child(HSeparator.new())

	for scene_name in SCENE_TEMPLATES:
		var btn := Button.new()
		btn.text = "Create " + scene_name
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_create_scene.bind(scene_name))
		_scene_panel.add_child(btn)

	_scene_panel.add_child(HSeparator.new())

	# Custom scene generator section
	var custom_label := Label.new()
	custom_label.text = "Scene Generator"
	custom_label.add_theme_font_size_override("font_size", 14)
	_scene_panel.add_child(custom_label)

	var gen_btn := Button.new()
	gen_btn.text = "Open Scene Generator..."
	gen_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gen_btn.pressed.connect(_on_open_scene_generator)
	_scene_panel.add_child(gen_btn)


func _build_database_tab() -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "Database"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_tab_container.add_child(scroll)

	_database_panel = VBoxContainer.new()
	_database_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_database_panel)

	var info := Label.new()
	info.text = "View all ForgeKit resources in your project.\nOrganized by type for quick access."
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_theme_font_size_override("font_size", 11)
	_database_panel.add_child(info)

	_database_panel.add_child(HSeparator.new())

	var refresh_btn := Button.new()
	refresh_btn.text = "Refresh Database"
	refresh_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	refresh_btn.pressed.connect(_refresh_database)
	_database_panel.add_child(refresh_btn)

	var validate_btn := Button.new()
	validate_btn.text = "Validate All Resources"
	validate_btn.tooltip_text = "Scan all resources for errors, broken refs, and balance issues"
	validate_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	validate_btn.pressed.connect(_on_open_validation)
	_database_panel.add_child(validate_btn)

	var import_export_btn := Button.new()
	import_export_btn.text = "Import / Export JSON"
	import_export_btn.tooltip_text = "Export resources to JSON or import from JSON files"
	import_export_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	import_export_btn.pressed.connect(_on_open_import_export)
	_database_panel.add_child(import_export_btn)

	_database_panel.add_child(HSeparator.new())

	# Placeholder for database listings  - populated on refresh
	var listing := VBoxContainer.new()
	listing.name = "DatabaseListing"
	_database_panel.add_child(listing)


# --- Signal Handlers ---

func _on_create_resource(res_type: String) -> void:
	var script_path: String = RESOURCE_TYPES.get(res_type, "")
	if script_path.is_empty():
		push_warning("ForgeKit: Unknown resource type: " + res_type)
		return

	# Create a file dialog to save the new resource
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.access = FileDialog.ACCESS_RESOURCES
	dialog.title = "Save New " + res_type
	dialog.add_filter("*.tres ; Godot Resource")

	# Set default directory
	var default_dir := _get_resource_dir(res_type)
	if not DirAccess.dir_exists_absolute(default_dir):
		DirAccess.make_dir_recursive_absolute(default_dir)
	dialog.current_dir = default_dir
	dialog.current_file = "new_" + res_type.trim_prefix("FK").to_snake_case() + ".tres"

	dialog.file_selected.connect(func(path: String):
		var script := load(script_path)
		var resource: Resource = script.new()
		# Set default ID from filename
		var file_name := path.get_file().get_basename()
		if resource.has_method("set") and "id" in resource:
			resource.id = file_name
		if "display_name" in resource:
			resource.display_name = file_name.capitalize()
		ResourceSaver.save(resource, path)
		if editor_plugin:
			editor_plugin.get_editor_interface().get_resource_filesystem().scan()
			# Open the resource for editing
			editor_plugin.get_editor_interface().edit_resource(load(path))
		dialog.queue_free()
	)
	dialog.canceled.connect(func(): dialog.queue_free())

	if editor_plugin:
		editor_plugin.get_editor_interface().get_base_control().add_child(dialog)
	else:
		add_child(dialog)
	dialog.popup_centered(Vector2i(600, 400))


func _on_browse_resources(res_type: String) -> void:
	# Open a file dialog to browse existing resources of this type
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_RESOURCES
	dialog.title = "Browse " + res_type + " Resources"
	dialog.add_filter("*.tres ; Godot Resource")

	var default_dir := _get_resource_dir(res_type)
	if DirAccess.dir_exists_absolute(default_dir):
		dialog.current_dir = default_dir
	else:
		dialog.current_dir = "res://"

	dialog.file_selected.connect(func(path: String):
		if editor_plugin:
			editor_plugin.get_editor_interface().edit_resource(load(path))
		dialog.queue_free()
	)
	dialog.canceled.connect(func(): dialog.queue_free())

	if editor_plugin:
		editor_plugin.get_editor_interface().get_base_control().add_child(dialog)
	else:
		add_child(dialog)
	dialog.popup_centered(Vector2i(600, 400))


func _on_create_scene(scene_name: String) -> void:
	var template_path: String = SCENE_TEMPLATES.get(scene_name, "")
	if template_path.is_empty():
		push_warning("ForgeKit: Unknown scene template: " + scene_name)
		return

	# Check if template exists
	if not ResourceLoader.exists(template_path):
		# Generate the scene on-the-fly from the scene generator
		_generate_scene_template(scene_name, template_path)

	# File dialog to pick save location
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.access = FileDialog.ACCESS_RESOURCES
	dialog.title = "Save " + scene_name
	dialog.add_filter("*.tscn ; Godot Scene")

	var default_dir := "res://scenes/"
	if not DirAccess.dir_exists_absolute(default_dir):
		DirAccess.make_dir_recursive_absolute(default_dir)
	dialog.current_dir = default_dir
	dialog.current_file = scene_name.to_snake_case().replace(" ", "_") + ".tscn"

	dialog.file_selected.connect(func(path: String):
		# Load and duplicate the template
		if ResourceLoader.exists(template_path):
			var scene: PackedScene = load(template_path)
			ResourceSaver.save(scene, path)
		else:
			# Create a basic scene
			_create_basic_scene(scene_name, path)

		if editor_plugin:
			editor_plugin.get_editor_interface().get_resource_filesystem().scan()
			editor_plugin.get_editor_interface().open_scene_from_path(path)
		dialog.queue_free()
	)
	dialog.canceled.connect(func(): dialog.queue_free())

	if editor_plugin:
		editor_plugin.get_editor_interface().get_base_control().add_child(dialog)
	else:
		add_child(dialog)
	dialog.popup_centered(Vector2i(600, 400))


func _on_open_scene_generator() -> void:
	var generator_script = load("res://addons/forge_kit/editors/fk_scene_generator_dialog.gd")
	var generator_window = generator_script.new()
	generator_window.editor_plugin = editor_plugin
	if editor_plugin:
		editor_plugin.get_editor_interface().get_base_control().add_child(generator_window)
	else:
		add_child(generator_window)
	generator_window.popup_centered(Vector2i(500, 600))


func _on_open_dialogue_editor() -> void:
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_RESOURCES
	dialog.title = "Select Dialogue Resource"
	dialog.add_filter("*.tres ; Godot Resource")

	var default_dir := "res://rpg_data/rpg_dialogue/"
	if DirAccess.dir_exists_absolute(default_dir):
		dialog.current_dir = default_dir
	else:
		dialog.current_dir = "res://"

	dialog.file_selected.connect(func(path: String):
		var resource: Resource = load(path)
		if resource and "nodes" in resource:
			_open_dialogue_graph_editor(resource)
		dialog.queue_free()
	)
	dialog.canceled.connect(func(): dialog.queue_free())

	if editor_plugin:
		editor_plugin.get_editor_interface().get_base_control().add_child(dialog)
	else:
		add_child(dialog)
	dialog.popup_centered(Vector2i(600, 400))


func _open_dialogue_graph_editor(resource: Resource) -> void:
	var editor_script = load("res://addons/forge_kit/editors/fk_dialogue_graph_editor.gd")
	var editor_window = editor_script.new()
	editor_window.editor_plugin = editor_plugin
	if editor_plugin:
		editor_plugin.get_editor_interface().get_base_control().add_child(editor_window)
	else:
		add_child(editor_window)
	editor_window.load_dialogue(resource)
	editor_window.popup_centered(Vector2i(1100, 700))


func _on_open_skill_tree_editor() -> void:
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_RESOURCES
	dialog.title = "Select Skill Tree Resource"
	dialog.add_filter("*.tres ; Godot Resource")

	var default_dir := "res://rpg_data/rpg_skill_tree/"
	if DirAccess.dir_exists_absolute(default_dir):
		dialog.current_dir = default_dir
	else:
		dialog.current_dir = "res://"

	dialog.file_selected.connect(func(path: String):
		var resource: Resource = load(path)
		if resource and "nodes" in resource:
			_open_skill_tree_graph_editor(resource)
		dialog.queue_free()
	)
	dialog.canceled.connect(func(): dialog.queue_free())

	if editor_plugin:
		editor_plugin.get_editor_interface().get_base_control().add_child(dialog)
	else:
		add_child(dialog)
	dialog.popup_centered(Vector2i(600, 400))


func _open_skill_tree_graph_editor(resource: Resource) -> void:
	var editor_script = load("res://addons/forge_kit/editors/fk_skill_tree_graph_editor.gd")
	var editor_window = editor_script.new()
	editor_window.editor_plugin = editor_plugin
	if editor_plugin:
		editor_plugin.get_editor_interface().get_base_control().add_child(editor_window)
	else:
		add_child(editor_window)
	editor_window.load_skill_tree(resource)
	editor_window.popup_centered(Vector2i(1100, 700))


func _on_open_damage_formula() -> void:
	var formula_script = load("res://addons/forge_kit/editors/fk_damage_formula_dialog.gd")
	var formula_window = formula_script.new()
	formula_window.editor_plugin = editor_plugin
	if editor_plugin:
		editor_plugin.get_editor_interface().get_base_control().add_child(formula_window)
	else:
		add_child(formula_window)
	formula_window.popup_centered(Vector2i(900, 650))


func _on_open_validation() -> void:
	var validation_script = load("res://addons/forge_kit/editors/fk_validation_dialog.gd")
	var validation_window = validation_script.new()
	validation_window.editor_plugin = editor_plugin
	if editor_plugin:
		editor_plugin.get_editor_interface().get_base_control().add_child(validation_window)
	else:
		add_child(validation_window)
	validation_window.popup_centered(Vector2i(800, 600))


func _on_open_import_export() -> void:
	var ie_script = load("res://addons/forge_kit/editors/fk_import_export_dialog.gd")
	var ie_window = ie_script.new()
	ie_window.editor_plugin = editor_plugin
	if editor_plugin:
		editor_plugin.get_editor_interface().get_base_control().add_child(ie_window)
	else:
		add_child(ie_window)
	ie_window.popup_centered(Vector2i(700, 500))


func _refresh_database() -> void:
	var listing := _database_panel.get_node_or_null("DatabaseListing")
	if not listing:
		return

	# Clear existing
	for child in listing.get_children():
		child.queue_free()

	# Scan for resources
	for category in RESOURCE_CATEGORIES:
		var cat_label := Label.new()
		cat_label.text = category
		cat_label.add_theme_font_size_override("font_size", 13)
		listing.add_child(cat_label)

		for res_type in RESOURCE_CATEGORIES[category]:
			var dir_path: String = _get_resource_dir(res_type)
			var count := 0
			if DirAccess.dir_exists_absolute(dir_path):
				var dir := DirAccess.open(dir_path)
				if dir:
					dir.list_dir_begin()
					var file := dir.get_next()
					while file != "":
						if file.ends_with(".tres"):
							count += 1
							# Add clickable entry
							var btn := Button.new()
							btn.text = "  " + file.get_basename()
							btn.flat = true
							btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
							btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
							var full_path: String = dir_path + file
							btn.pressed.connect(func():
								if editor_plugin:
									editor_plugin.get_editor_interface().edit_resource(load(full_path))
							)
							listing.add_child(btn)
						file = dir.get_next()

			if count == 0:
				var empty_label := Label.new()
				empty_label.text = "  (no " + res_type.trim_prefix("FK") + " resources)"
				empty_label.add_theme_font_size_override("font_size", 11)
				empty_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
				listing.add_child(empty_label)

		listing.add_child(HSeparator.new())


func _generate_scene_template(scene_name: String, path: String) -> void:
	_create_basic_scene(scene_name, path)


func _create_basic_scene(scene_name: String, path: String) -> void:
	var root: Node
	match scene_name:
		"Battle Scene":
			root = _create_battle_scene()
		"Overworld Scene":
			root = _create_overworld_scene()
		"Title Screen":
			root = _create_title_screen()
		"Game Over Screen":
			root = _create_game_over_screen()
		"Dialogue Scene":
			root = _create_dialogue_scene()
		"Shop Scene":
			root = _create_shop_scene()
		"Inventory Screen":
			root = _create_inventory_screen()
		"Party Menu":
			root = _create_party_menu()
		"Save/Load Screen":
			root = _create_save_load_screen()
		_:
			root = Control.new()
			root.name = scene_name.to_pascal_case().replace(" ", "")

	var scene := PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, path)
	root.queue_free()


# --- Scene Builders ---

func _create_battle_scene() -> Control:
	var root := Control.new()
	root.name = "BattleScene"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Background
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.1, 0.1, 0.2)
	root.add_child(bg)
	bg.owner = root

	# Enemy container
	var enemy_area := HBoxContainer.new()
	enemy_area.name = "EnemyArea"
	enemy_area.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	enemy_area.position = Vector2(200, 50)
	enemy_area.custom_minimum_size = Vector2(600, 200)
	root.add_child(enemy_area)
	enemy_area.owner = root

	# Party container
	var party_area := HBoxContainer.new()
	party_area.name = "PartyArea"
	party_area.position = Vector2(200, 280)
	party_area.custom_minimum_size = Vector2(600, 150)
	root.add_child(party_area)
	party_area.owner = root

	# Battle UI panel
	var ui_panel := PanelContainer.new()
	ui_panel.name = "BattleUI"
	ui_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	ui_panel.offset_top = -200
	root.add_child(ui_panel)
	ui_panel.owner = root

	var ui_hbox := HBoxContainer.new()
	ui_hbox.name = "UILayout"
	ui_panel.add_child(ui_hbox)
	ui_hbox.owner = root

	# Command menu
	var cmd_vbox := VBoxContainer.new()
	cmd_vbox.name = "CommandMenu"
	cmd_vbox.custom_minimum_size = Vector2(200, 0)
	ui_hbox.add_child(cmd_vbox)
	cmd_vbox.owner = root

	for cmd in ["Attack", "Magic", "Items", "Defend", "Flee"]:
		var btn := Button.new()
		btn.name = cmd + "Button"
		btn.text = cmd
		cmd_vbox.add_child(btn)
		btn.owner = root

	# Party status
	var status_vbox := VBoxContainer.new()
	status_vbox.name = "PartyStatus"
	status_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ui_hbox.add_child(status_vbox)
	status_vbox.owner = root

	var status_label := Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "HP: 100/100  MP: 50/50"
	status_vbox.add_child(status_label)
	status_label.owner = root

	# Battle log
	var log_panel := RichTextLabel.new()
	log_panel.name = "BattleLog"
	log_panel.custom_minimum_size = Vector2(300, 0)
	log_panel.text = "Battle started!"
	log_panel.scroll_following = true
	ui_hbox.add_child(log_panel)
	log_panel.owner = root

	return root


func _create_overworld_scene() -> Node2D:
	var root := Node2D.new()
	root.name = "OverworldScene"

	# Camera
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	camera.position_smoothing_enabled = true
	root.add_child(camera)
	camera.owner = root

	# TileMap placeholder
	var tilemap := Node2D.new()
	tilemap.name = "TileMapLayer"
	root.add_child(tilemap)
	tilemap.owner = root

	# Player spawn
	var player_spawn := Marker2D.new()
	player_spawn.name = "PlayerSpawn"
	root.add_child(player_spawn)
	player_spawn.owner = root

	# NPC container
	var npcs := Node2D.new()
	npcs.name = "NPCs"
	root.add_child(npcs)
	npcs.owner = root

	# Interactables container
	var interactables := Node2D.new()
	interactables.name = "Interactables"
	root.add_child(interactables)
	interactables.owner = root

	# Encounter zones container
	var encounters := Node2D.new()
	encounters.name = "EncounterZones"
	root.add_child(encounters)
	encounters.owner = root

	# Zone transitions
	var transitions := Node2D.new()
	transitions.name = "ZoneTransitions"
	root.add_child(transitions)
	transitions.owner = root

	# HUD layer
	var hud := CanvasLayer.new()
	hud.name = "HUD"
	root.add_child(hud)
	hud.owner = root

	return root


func _create_title_screen() -> Control:
	var root := Control.new()
	root.name = "TitleScreen"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.name = "Background"
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.05, 0.15)
	root.add_child(bg)
	bg.owner = root

	var center := VBoxContainer.new()
	center.name = "CenterContainer"
	center.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	center.custom_minimum_size = Vector2(400, 300)
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(center)
	center.owner = root

	var title := Label.new()
	title.name = "TitleLabel"
	title.text = "Your RPG Title"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	center.add_child(title)
	title.owner = root

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 40)
	center.add_child(spacer)
	spacer.owner = root

	for btn_name in ["New Game", "Continue", "Options", "Quit"]:
		var btn := Button.new()
		btn.name = btn_name.replace(" ", "") + "Button"
		btn.text = btn_name
		btn.custom_minimum_size = Vector2(200, 40)
		center.add_child(btn)
		btn.owner = root

	return root


func _create_game_over_screen() -> Control:
	var root := Control.new()
	root.name = "GameOverScreen"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.name = "Background"
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.1, 0.0, 0.0)
	root.add_child(bg)
	bg.owner = root

	var center := VBoxContainer.new()
	center.name = "CenterContainer"
	center.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(center)
	center.owner = root

	var label := Label.new()
	label.name = "GameOverLabel"
	label.text = "Game Over"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	center.add_child(label)
	label.owner = root

	var retry_btn := Button.new()
	retry_btn.name = "RetryButton"
	retry_btn.text = "Retry"
	retry_btn.custom_minimum_size = Vector2(200, 40)
	center.add_child(retry_btn)
	retry_btn.owner = root

	var title_btn := Button.new()
	title_btn.name = "TitleButton"
	title_btn.text = "Return to Title"
	title_btn.custom_minimum_size = Vector2(200, 40)
	center.add_child(title_btn)
	title_btn.owner = root

	return root


func _create_dialogue_scene() -> Control:
	var root := Control.new()
	root.name = "DialogueScene"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Dialogue box at bottom
	var panel := PanelContainer.new()
	panel.name = "DialoguePanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top = -180
	root.add_child(panel)
	panel.owner = root

	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	margin.owner = root

	var vbox := VBoxContainer.new()
	vbox.name = "Layout"
	margin.add_child(vbox)
	vbox.owner = root

	var speaker := Label.new()
	speaker.name = "SpeakerName"
	speaker.text = "Speaker Name"
	speaker.add_theme_font_size_override("font_size", 18)
	vbox.add_child(speaker)
	speaker.owner = root

	var text := RichTextLabel.new()
	text.name = "DialogueText"
	text.text = "Dialogue text goes here..."
	text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text.fit_content = true
	vbox.add_child(text)
	text.owner = root

	# Choice container
	var choices := VBoxContainer.new()
	choices.name = "ChoiceContainer"
	choices.visible = false
	vbox.add_child(choices)
	choices.owner = root

	# Portrait
	var portrait := TextureRect.new()
	portrait.name = "Portrait"
	portrait.position = Vector2(16, -180)
	portrait.custom_minimum_size = Vector2(128, 128)
	portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	root.add_child(portrait)
	portrait.owner = root

	# Advance indicator
	var indicator := Label.new()
	indicator.name = "AdvanceIndicator"
	indicator.text = "▼"
	indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	indicator.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	indicator.offset_left = -40
	indicator.offset_top = -30
	panel.add_child(indicator)
	indicator.owner = root

	return root


func _create_shop_scene() -> Control:
	var root := Control.new()
	root.name = "ShopScene"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.name = "Background"
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.15, 0.1, 0.05)
	root.add_child(bg)
	bg.owner = root

	var hbox := HBoxContainer.new()
	hbox.name = "Layout"
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 8)
	root.add_child(hbox)
	hbox.owner = root

	# Shop inventory panel
	var shop_panel := PanelContainer.new()
	shop_panel.name = "ShopPanel"
	shop_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(shop_panel)
	shop_panel.owner = root

	var shop_vbox := VBoxContainer.new()
	shop_vbox.name = "ShopLayout"
	shop_panel.add_child(shop_vbox)
	shop_vbox.owner = root

	var shop_label := Label.new()
	shop_label.text = "Shop"
	shop_label.add_theme_font_size_override("font_size", 20)
	shop_vbox.add_child(shop_label)
	shop_label.owner = root

	var shop_list := ItemList.new()
	shop_list.name = "ShopItemList"
	shop_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shop_vbox.add_child(shop_list)
	shop_list.owner = root

	var buy_btn := Button.new()
	buy_btn.name = "BuyButton"
	buy_btn.text = "Buy"
	shop_vbox.add_child(buy_btn)
	buy_btn.owner = root

	# Player inventory panel
	var inv_panel := PanelContainer.new()
	inv_panel.name = "InventoryPanel"
	inv_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(inv_panel)
	inv_panel.owner = root

	var inv_vbox := VBoxContainer.new()
	inv_vbox.name = "InventoryLayout"
	inv_panel.add_child(inv_vbox)
	inv_vbox.owner = root

	var inv_label := Label.new()
	inv_label.text = "Your Items"
	inv_label.add_theme_font_size_override("font_size", 20)
	inv_vbox.add_child(inv_label)
	inv_label.owner = root

	var inv_list := ItemList.new()
	inv_list.name = "InventoryItemList"
	inv_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inv_vbox.add_child(inv_list)
	inv_list.owner = root

	var sell_btn := Button.new()
	sell_btn.name = "SellButton"
	sell_btn.text = "Sell"
	inv_vbox.add_child(sell_btn)
	sell_btn.owner = root

	# Gold display
	var gold_label := Label.new()
	gold_label.name = "GoldLabel"
	gold_label.text = "Gold: 0"
	gold_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	gold_label.add_theme_font_size_override("font_size", 18)
	root.add_child(gold_label)
	gold_label.owner = root

	return root


func _create_inventory_screen() -> Control:
	var root := Control.new()
	root.name = "InventoryScreen"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := PanelContainer.new()
	bg.name = "Background"
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	bg.owner = root

	var main_vbox := VBoxContainer.new()
	main_vbox.name = "MainLayout"
	bg.add_child(main_vbox)
	main_vbox.owner = root

	# Header with tabs
	var header := HBoxContainer.new()
	header.name = "Header"
	main_vbox.add_child(header)
	header.owner = root

	for tab_name in ["All", "Weapons", "Armor", "Consumables", "Key Items"]:
		var btn := Button.new()
		btn.name = tab_name.replace(" ", "") + "Tab"
		btn.text = tab_name
		btn.toggle_mode = true
		header.add_child(btn)
		btn.owner = root

	# Item list and details split
	var content := HSplitContainer.new()
	content.name = "Content"
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(content)
	content.owner = root

	var item_list := ItemList.new()
	item_list.name = "ItemList"
	item_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(item_list)
	item_list.owner = root

	var detail_panel := VBoxContainer.new()
	detail_panel.name = "ItemDetails"
	detail_panel.custom_minimum_size = Vector2(300, 0)
	content.add_child(detail_panel)
	detail_panel.owner = root

	var item_name := Label.new()
	item_name.name = "ItemName"
	item_name.text = "Item Name"
	item_name.add_theme_font_size_override("font_size", 20)
	detail_panel.add_child(item_name)
	item_name.owner = root

	var item_desc := RichTextLabel.new()
	item_desc.name = "ItemDescription"
	item_desc.text = "Item description..."
	item_desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	item_desc.fit_content = true
	detail_panel.add_child(item_desc)
	item_desc.owner = root

	var use_btn := Button.new()
	use_btn.name = "UseButton"
	use_btn.text = "Use"
	detail_panel.add_child(use_btn)
	use_btn.owner = root

	var equip_btn := Button.new()
	equip_btn.name = "EquipButton"
	equip_btn.text = "Equip"
	detail_panel.add_child(equip_btn)
	equip_btn.owner = root

	var drop_btn := Button.new()
	drop_btn.name = "DropButton"
	drop_btn.text = "Drop"
	detail_panel.add_child(drop_btn)
	drop_btn.owner = root

	return root


func _create_party_menu() -> Control:
	var root := Control.new()
	root.name = "PartyMenu"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := PanelContainer.new()
	bg.name = "Background"
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	bg.owner = root

	var hbox := HBoxContainer.new()
	hbox.name = "Layout"
	bg.add_child(hbox)
	hbox.owner = root

	# Menu options
	var menu := VBoxContainer.new()
	menu.name = "MenuOptions"
	menu.custom_minimum_size = Vector2(200, 0)
	hbox.add_child(menu)
	menu.owner = root

	for opt in ["Status", "Equipment", "Skills", "Items", "Formation", "Save", "Quit"]:
		var btn := Button.new()
		btn.name = opt + "Button"
		btn.text = opt
		btn.custom_minimum_size = Vector2(0, 40)
		menu.add_child(btn)
		btn.owner = root

	# Party member list
	var party_list := VBoxContainer.new()
	party_list.name = "PartyList"
	party_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(party_list)
	party_list.owner = root

	# Placeholder party member panels
	for i in range(4):
		var member := PanelContainer.new()
		member.name = "PartyMember" + str(i + 1)
		member.custom_minimum_size = Vector2(0, 80)
		party_list.add_child(member)
		member.owner = root

		var member_hbox := HBoxContainer.new()
		member.add_child(member_hbox)
		member_hbox.owner = root

		var portrait := TextureRect.new()
		portrait.name = "Portrait"
		portrait.custom_minimum_size = Vector2(64, 64)
		member_hbox.add_child(portrait)
		portrait.owner = root

		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		member_hbox.add_child(info)
		info.owner = root

		var name_label := Label.new()
		name_label.text = "Character " + str(i + 1)
		info.add_child(name_label)
		name_label.owner = root

		var hp_label := Label.new()
		hp_label.text = "HP: 100/100"
		info.add_child(hp_label)
		hp_label.owner = root

		var mp_label := Label.new()
		mp_label.text = "MP: 50/50"
		info.add_child(mp_label)
		mp_label.owner = root

	return root


func _create_save_load_screen() -> Control:
	var root := Control.new()
	root.name = "SaveLoadScreen"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := PanelContainer.new()
	bg.name = "Background"
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	bg.owner = root

	var vbox := VBoxContainer.new()
	vbox.name = "Layout"
	bg.add_child(vbox)
	vbox.owner = root

	var title := Label.new()
	title.name = "Title"
	title.text = "Save / Load"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)
	title.owner = root

	# Mode toggle
	var mode_hbox := HBoxContainer.new()
	mode_hbox.name = "ModeToggle"
	mode_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(mode_hbox)
	mode_hbox.owner = root

	var save_btn := Button.new()
	save_btn.name = "SaveModeButton"
	save_btn.text = "Save"
	save_btn.toggle_mode = true
	save_btn.button_pressed = true
	mode_hbox.add_child(save_btn)
	save_btn.owner = root

	var load_btn := Button.new()
	load_btn.name = "LoadModeButton"
	load_btn.text = "Load"
	load_btn.toggle_mode = true
	mode_hbox.add_child(load_btn)
	load_btn.owner = root

	# Save slots
	var scroll := ScrollContainer.new()
	scroll.name = "SlotScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)
	scroll.owner = root

	var slot_list := VBoxContainer.new()
	slot_list.name = "SlotList"
	slot_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(slot_list)
	slot_list.owner = root

	for i in range(10):
		var slot := PanelContainer.new()
		slot.name = "Slot" + str(i + 1)
		slot.custom_minimum_size = Vector2(0, 60)
		slot_list.add_child(slot)
		slot.owner = root

		var slot_label := Label.new()
		slot_label.text = "Slot " + str(i + 1) + " - Empty"
		slot.add_child(slot_label)
		slot_label.owner = root

	# Back button
	var back_btn := Button.new()
	back_btn.name = "BackButton"
	back_btn.text = "Back"
	back_btn.custom_minimum_size = Vector2(200, 40)
	vbox.add_child(back_btn)
	back_btn.owner = root

	return root
