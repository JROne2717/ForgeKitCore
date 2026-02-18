# Architecture

ForgeKit is intentionally opinionated. The resource types have fixed structures, the data directories follow a naming convention, and the editor tooling assumes those structures are in place.

RPG data becomes complex quickly. Without a consistent model, projects often drift into ad-hoc dictionaries, loosely defined resources, and scripts that only the original author fully understands. ForgeKit standardizes that layer early so the project stays predictable as it grows.

The trade-off is that you work within an established structure. The benefit is consistency across data, predictable tooling behavior, and easier onboarding for additional developers.

If a project needs behavior or data beyond the built-in properties, `custom_data` and subclassing are supported. See the [Extensibility](extensibility.md) page for details.

ForgeKit began with the data layer before any runtime systems were added. That early decision shaped the directory structure and editor tooling.

## Layer Diagram

```
Your Game Code
      |
      v
+------------------+     +------------------+
|  Advanced Layer   |---->|   Core Layer     |
| (runtime nodes)  |     | (data + editors) |
+------------------+     +------------------+
                                |
                                v
                          .tres files
                         (rpg_data/...)
```

Core defines the data. Advanced (or your own code) consumes it at runtime. The arrow only goes one direction - Advanced depends on Core, never the other way around.

## Core Layer

Everything you get in the free version.

**Resource types** (14 total): FKStat, FKDerivedStat, FKClass, FKEnemy, FKItem, FKAbility, FKPassiveSkill, FKSkillTree, FKLootTable, FKEncounterTable, FKZone, FKDialogue, FKQuest, FKSettings.

Each is a GDScript extending `Resource` with a `class_name`, `@tool` annotation, and typed `@export` properties. They are designed to be edited in the Inspector and serialized as `.tres` files.

**Editor dock** (`fk_dock.gd`): The main UI. Five tabs - Quick Setup, Setup, Resources, Scenes, Database. Handles resource creation, project scaffolding, and database browsing. This is the biggest file in the project at around 2300 lines.

**Visual editors**: The dialogue graph editor (`fk_dialogue_graph_editor.gd`) and skill tree editor (`fk_skill_tree_graph_editor.gd`) use Godot's GraphEdit for visual node-graph editing.

**Utilities**:
- `FKDatabase` (`utils/fk_database.gd`) - Scans `rpg_data/` directories and loads resources into memory. Provides lookup by type and ID.
- `FKSaveSystem` (`utils/fk_save_system.gd`) - JSON-based save/load for game state.

**Plugin entry point** (`plugin.gd`): Registers all 14 resource types with the editor and creates the dock.

## Advanced Layer

Not yet released. Planned for v0.2 onward.

Advanced files will live in `addons/forge_kit/advanced/`. When this folder does not exist, the dock does not show Advanced-related buttons. No errors, no missing features, no nag screens.

Advanced will include runtime nodes like:
- Battle manager (turn-based and action real-time)
- Dialogue player
- Quest tracker
- Inventory manager
- Encounter triggers

These nodes load data through FKDatabase and implement the actual gameplay logic. They are the "execution layer" that brings the Core data to life.

## Data Directory Convention

All resource files live under `res://rpg_data/`. Each type has its own subdirectory with an `rpg_` prefix:

```
rpg_data/
  rpg_stat/
  rpg_derived_stat/
  rpg_class/
  rpg_enemy/
  rpg_item/
  rpg_ability/
  rpg_passive_skill/
  rpg_skill_tree/
  rpg_loot_table/
  rpg_encounter_table/
  rpg_zone/
  rpg_dialogue/
  rpg_quest/
  rpg_settings/
```

The `_get_resource_dir()` helper in `fk_dock.gd` handles the mapping between class names and directory names. The prefix is `rpg_`, not `fk_`. This is intentional - the directories are named for the game content they hold, not the plugin.

## How Resources Reference Each Other

Resources reference each other through typed `@export` properties. For example, FKEnemy has:

```gdscript
@export var loot_table: Resource  # FKLootTable
@export var abilities: Array[Resource] = []  # FKAbility resources
```

The type is `Resource` (not the specific class) to avoid circular dependency issues in the editor. The comments document the expected type. This means the Inspector will show a generic resource picker, but the runtime code should cast to the expected type.

String-based references (like stat IDs in `base_stats` dictionaries) use the `id` property of the target resource. This is simpler for cases where you need to reference many resources without storing full resource paths.

## File Structure

```
addons/forge_kit/
  plugin.cfg          (plugin metadata, version)
  plugin.gd           (entry point, registers types)
  editors/
    fk_dock.gd        (main editor dock, ~2300 lines)
    fk_dialogue_graph_editor.gd
    fk_skill_tree_graph_editor.gd
    fk_damage_formula_dialog.gd
    fk_validation_dialog.gd
    fk_import_export_dialog.gd
    fk_scene_generator_dialog.gd
  resources/
    fk_stat.gd
    fk_derived_stat.gd
    fk_class.gd
    fk_enemy.gd
    fk_item.gd
    fk_ability.gd
    fk_passive_skill.gd
    fk_skill_tree.gd
    fk_loot_table.gd
    fk_encounter_table.gd
    fk_zone.gd
    fk_dialogue.gd
    fk_quest.gd
    fk_settings.gd
  utils/
    fk_database.gd
    fk_save_system.gd
  icons/
  scenes/
  docs/
```
