# FKDatabase API

FKDatabase scans the `rpg_data/` directories, loads all ForgeKit resources into memory, and provides lookup by type and ID. It is the main way to access resources at runtime.

Source: `addons/forgekit/utils/fk_database.gd`

## Setup

```gdscript
var db = FKDatabase.new()
```

FKDatabase scans `res://rpg_data/` on initialization. Each subdirectory (`rpg_stat/`, `rpg_class/`, etc.) is loaded and cached.

## Loading Resources by Type and ID

```gdscript
# Generic lookup - returns Resource, cast to the expected type
var warrior: FKClass = db.get_resource("FKClass", "warrior") as FKClass
var fireball: FKAbility = db.get_resource("FKAbility", "fireball") as FKAbility
var slime: FKEnemy = db.get_resource("FKEnemy", "slime") as FKEnemy
```

The first argument is the class name (matching the `class_name` on the resource script). The second is the `id` property of the resource.

## Loading All Resources of a Type

```gdscript
var all_items: Array = db.get_all_resources("FKItem")
var all_quests: Array = db.get_all_resources("FKQuest")
```

Returns all cached resources of the specified type.

## Database Summary

```gdscript
var summary: Dictionary = db.get_summary()
# Returns: {"FKStat": 6, "FKClass": 3, "FKEnemy": 4, ...}
```

Returns a Dictionary mapping type names to resource counts.

## Common Runtime Patterns

### Stat Calculation

```gdscript
var warrior: FKClass = db.get_resource("FKClass", "warrior") as FKClass
var stats_at_10: Dictionary = warrior.get_stats_at_level(10)
# stats_at_10 = {"strength": 42, "dexterity": 28, ...}

var exp_needed: int = warrior.get_exp_for_level(11)
```

### Derived Stat Calculation

```gdscript
var evasion: FKDerivedStat = db.get_resource("FKDerivedStat", "evasion") as FKDerivedStat
var base_stats: Dictionary = {"dexterity": 20, "luck": 10}
var evasion_value: float = evasion.calculate(base_stats)
```

### Ability Damage

```gdscript
var fireball: FKAbility = db.get_resource("FKAbility", "fireball") as FKAbility
var player_stats: Dictionary = {"intelligence": 25, "wisdom": 15}
var damage: float = fireball.calculate_power(player_stats)
```

### Enemy AI

```gdscript
var enemy: FKEnemy = db.get_resource("FKEnemy", "goblin") as FKEnemy
var hp_percent: float = float(current_hp) / float(enemy.max_hp)
var chosen_ability: Resource = enemy.select_ability(hp_percent)
```

`select_ability()` evaluates the enemy's `ai_patterns` array against the current HP percentage and returns an FKAbility resource.

### Loot Rolling

```gdscript
var loot_table: FKLootTable = db.get_resource("FKLootTable", "forest_drops") as FKLootTable
var drops: Array = loot_table.roll()
for drop in drops:
    var item: FKItem = drop["item"]
    var qty: int = drop["quantity"]
    print("Dropped: %s x%d" % [item.display_name, qty])
```

### Encounter Rolling

```gdscript
var enc_table: FKEncounterTable = db.get_resource("FKEncounterTable", "forest_encounters") as FKEncounterTable
var steps_until: int = enc_table.roll_steps()
var encounter: Dictionary = enc_table.roll_encounter()
var enemies: Array = encounter["enemies"]
var count: int = encounter["count"]
```

### Dialogue Traversal

```gdscript
var dialogue: FKDialogue = db.get_resource("FKDialogue", "blacksmith_intro") as FKDialogue
var current_node: Dictionary = dialogue.get_start_node()

# Display text, then advance
var next_node: Dictionary = dialogue.get_next_node(current_node["id"])

# Handle choices
if current_node["type"] == "choice":
    var choices: Array = current_node["choices"]
    # Present choices to the player, get their selection index
    var selected_next: String = choices[player_choice]["next"]
    current_node = dialogue.get_node_by_id(selected_next)
```

### Quest Progress

```gdscript
var quest: FKQuest = db.get_resource("FKQuest", "slay_slimes") as FKQuest
var progress: Dictionary = {"obj_kill": 5, "obj_collect": 3, "obj_talk": 1}

if quest.is_complete(progress):
    print("Quest complete! Awarding %d EXP and %d Gold" % [quest.exp_reward, quest.gold_reward])
```

`is_complete()` checks required objectives. `is_fully_complete()` checks both required and optional objectives.

## How FKDatabase Finds Resources

FKDatabase uses directory convention, not class inspection. It scans each `rpg_data/rpg_<type>/` directory and loads all `.tres` files found there. This means:

- Resources are found by directory, not by their script class.
- Subclassed resources (e.g., a `MyItem` extending `FKItem`) stored in `rpg_data/rpg_item/` will be found and returned as their actual type.
- Resources placed outside the expected directories will not be found by FKDatabase.
- The `_get_resource_dir()` helper in `fk_dock.gd` handles the mapping between class names and directory names.

See [Architecture](../concepts/architecture.md) for more on the directory convention.
