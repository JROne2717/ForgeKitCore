@tool
extends EditorPlugin

var dock_instance: Control


func _enter_tree() -> void:
	# Register custom resource types
	_register_resources()
	# Create and add the main editor dock
	var dock_script = load("res://addons/forge_kit/editors/fk_dock.gd")
	dock_instance = dock_script.new()
	dock_instance.editor_plugin = self
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock_instance)


func _exit_tree() -> void:
	# Unregister custom types
	_unregister_resources()
	if dock_instance:
		remove_control_from_docks(dock_instance)
		dock_instance.queue_free()


func _register_resources() -> void:
	var base := "res://addons/forge_kit/"

	# Helper to safely load an icon
	var _load_icon := func(icon_name: String) -> Texture2D:
		var path := base + "icons/" + icon_name + ".svg"
		if ResourceLoader.exists(path):
			return load(path)
		return null

	add_custom_type("FKStat", "Resource", load(base + "resources/fk_stat.gd"), _load_icon.call("stat"))
	add_custom_type("FKDerivedStat", "Resource", load(base + "resources/fk_derived_stat.gd"), _load_icon.call("stat"))
	add_custom_type("FKClass", "Resource", load(base + "resources/fk_class.gd"), _load_icon.call("class"))
	add_custom_type("FKEnemy", "Resource", load(base + "resources/fk_enemy.gd"), _load_icon.call("enemy"))
	add_custom_type("FKItem", "Resource", load(base + "resources/fk_item.gd"), _load_icon.call("item"))
	add_custom_type("FKAbility", "Resource", load(base + "resources/fk_ability.gd"), _load_icon.call("ability"))
	add_custom_type("FKPassiveSkill", "Resource", load(base + "resources/fk_passive_skill.gd"), _load_icon.call("passive"))
	add_custom_type("FKSkillTree", "Resource", load(base + "resources/fk_skill_tree.gd"), _load_icon.call("skilltree"))
	add_custom_type("FKLootTable", "Resource", load(base + "resources/fk_loot_table.gd"), _load_icon.call("loot"))
	add_custom_type("FKEncounterTable", "Resource", load(base + "resources/fk_encounter_table.gd"), _load_icon.call("encounter"))
	add_custom_type("FKZone", "Resource", load(base + "resources/fk_zone.gd"), _load_icon.call("zone"))
	add_custom_type("FKDialogue", "Resource", load(base + "resources/fk_dialogue.gd"), _load_icon.call("dialogue"))
	add_custom_type("FKQuest", "Resource", load(base + "resources/fk_quest.gd"), _load_icon.call("quest"))
	add_custom_type("FKSettings", "Resource", load(base + "resources/fk_settings.gd"), _load_icon.call("stat"))


func _unregister_resources() -> void:
	remove_custom_type("FKStat")
	remove_custom_type("FKDerivedStat")
	remove_custom_type("FKClass")
	remove_custom_type("FKEnemy")
	remove_custom_type("FKItem")
	remove_custom_type("FKAbility")
	remove_custom_type("FKPassiveSkill")
	remove_custom_type("FKSkillTree")
	remove_custom_type("FKLootTable")
	remove_custom_type("FKEncounterTable")
	remove_custom_type("FKZone")
	remove_custom_type("FKDialogue")
	remove_custom_type("FKQuest")
	remove_custom_type("FKSettings")
