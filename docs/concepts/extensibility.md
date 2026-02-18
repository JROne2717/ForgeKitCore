# Extensibility

ForgeKit enforces structure by default. Extension points exist where variability is expected, not everywhere.

There are several ways to extend the system without modifying plugin source code.

## custom_data Dictionary

Every resource type has a `custom_data: Dictionary` property. This is an open-ended extension point that exists for project-specific needs for anything the built-in properties do not cover.

ForgeKit never reads, writes, or validates this field. It is entirely yours.

```gdscript
# In the Inspector or via code:
my_item.custom_data = {
    "crafting_tier": 3,
    "flavor_text": "Smells like old leather.",
    "sell_to_npcs": ["blacksmith", "general_store"],
    "animation_override": "res://anims/special_sword.tres"
}
```

Use cases:
- Project-specific fields that do not belong in the base schema
- Temporary data for prototyping before committing to a proper property
- Integration points with other plugins or systems
- Tags, flags, or metadata for your own tools

The dictionary serializes normally with the `.tres` file. Standard Godot rules apply - keep values to built-in types (String, int, float, bool, Array, Dictionary, Vector2, Color, etc.) for reliable serialization.

## Subclassing Resources

All ForgeKit resources are regular GDScript resources. You can extend them:

```gdscript
# res://my_game/my_custom_item.gd
class_name MyItem
extends FKItem

@export var durability: int = 100
@export var repair_cost: int = 10
@export var socket_slots: int = 0
@export var socketed_gems: Array[Resource] = []

func is_broken() -> bool:
    return durability <= 0
```

This gives you full Inspector support for both the base FKItem properties and your custom additions. The ForgeKit dock, database browser, and visual editors will still recognize the resource as an FKItem since it extends it.

A few things to watch:

- Quick Setup generates base FKItem resources, not MyItem. You would either run Quick Setup first and then convert, or skip Quick Setup and create resources manually with your subclass.
- FKDatabase scans by directory, not by class. This keeps loading predictable even when using subclasses. Resources in `rpg_data/rpg_item/` will be found regardless of whether they are FKItem or MyItem.
- If you are using subclasses, save them with your subclass script attached. The `.tres` file header will reference your script path.

## String-Based Enums

Several properties use `@export_enum()` with hardcoded options (item types, rarity tiers, enemy tiers, zone types, etc.). If these do not fit your project, you have options:

1. **Use `sub_type` or similar String fields.** FKItem has a `sub_type` property that accepts any string. Many resources have free-form string fields alongside the enum.

2. **Subclass and override.** Create your own subclass and add a property with your own enum values. Ignore the base enum field.

3. **Use `custom_data`.** Store your own categorization in the dictionary.

4. **Edit the source.** ForgeKit is MIT licensed. If your project requires different enum values, you are free to modify them. The enum values are not used internally by the Core layer for any logic - they are purely data labels. The only exception is `FKSettings.battle_type` which the Advanced runtime layer will read. But in Core, they are all just stored strings.

A future improvement is to make more of these enums data-driven from FKSettings so projects can define their own types from the Setup tab.

## Working With FKDatabase

FKDatabase is the main way to access resources at runtime. It scans the `rpg_data/` directories and caches everything.

```gdscript
var db = FKDatabase.new()
db.load_all()

# Get all items
var items = db.get_resources("FKItem")

# Get a specific item by ID
var sword = db.get_resource("FKItem", "iron_sword")

# Get all enemies in a zone's encounter table
var zone = db.get_resource("FKZone", "dark_forest")
var encounters = zone.encounter_table
```

If you want to add your own resource types to the database, put them in a directory under `rpg_data/` and they will be picked up on the next scan. The directory name determines the category.

## Integration With Other Systems

ForgeKit resources are just Godot resources. Anything that works with resources works with ForgeKit:

- Other plugins can `load()` a `.tres` file and access its properties
- You can pass ForgeKit resources as signal arguments
- You can store them in Autoloads, node metadata, or anywhere else
- They work with Godot's built-in resource picker in the Inspector
- They serialize and deserialize with `ResourceSaver` and `ResourceLoader`

The resource scripts use `class_name` so you can type-check with `is FKItem`, `is FKEnemy`, etc.

## What You Should Not Do

- Do not add `class_name` to editor scripts (anything in `editors/`). Godot loads all class_name scripts at startup, and editor scripts reference EditorPlugin APIs that are not available at runtime.
- Do not use `preload()` for cross-referencing between Core and Advanced. Use `load()`. This allows Core to compile without Advanced present.
- Do not rename the `rpg_data/` directories or their `rpg_` prefix. The dock and database depend on this convention. If you need a different structure, modify `_get_resource_dir()` in `fk_dock.gd`.
