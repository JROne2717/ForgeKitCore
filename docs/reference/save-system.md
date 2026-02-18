# FKSaveSystem API

FKSaveSystem provides JSON-based save and load functionality with multiple save slots and metadata. It handles serialization to disk and slot management.

Source: `addons/forgekit/utils/fk_save_system.gd`

## Saving

```gdscript
var save_data: Dictionary = {
    "player_name": "Hero",
    "level": 15,
    "playtime": 3600,
    "hp": 250,
    "mp": 80,
    "inventory": ["potion", "sword_1", "shield_1"],
    "quest_progress": {"slay_slimes": {"obj_kill": 5}},
    "current_zone": "forest_1",
    "position": {"x": 100, "y": 200}
}
FKSaveSystem.save_game(1, save_data)  # Save to slot 1
```

The Dictionary can contain any JSON-serializable data. Structure it however your game needs. FKSaveSystem does not enforce a schema.

The slot number identifies the save file. Saving to an occupied slot overwrites the previous data.

## Loading

```gdscript
var loaded: Dictionary = FKSaveSystem.load_game(1)
if not loaded.is_empty():
    var player_name: String = loaded["player_name"]
    var level: int = loaded["level"]
```

Returns an empty Dictionary if the slot does not exist or the file cannot be read.

## Slot Management

### Check Which Slots Are Used

```gdscript
var used: Array[int] = FKSaveSystem.get_used_slots()
# Returns: [1, 3] if slots 1 and 3 have save data
```

### Get Slot Metadata

```gdscript
var info: Dictionary = FKSaveSystem.get_slot_info(1)
# Returns: {"save_time": "2025-01-15T10:30:00", "player_name": "Hero", "level": 15, ...}
```

Slot info includes the save timestamp and a subset of the save data. Use this for displaying save slot previews (player name, level, playtime) without loading the full save.

### Delete a Save Slot

```gdscript
FKSaveSystem.delete_slot(1)
```

Permanently removes the save data for that slot.

## File Location

Save files are stored as JSON in the user data directory (`user://`). Each slot is a separate file. The exact path follows Godot's `user://` convention, which varies by platform:

- **Windows**: `%APPDATA%\Godot\app_userdata\<project_name>\`
- **macOS**: `~/Library/Application Support/Godot/app_userdata/<project_name>/`
- **Linux**: `~/.local/share/godot/app_userdata/<project_name>/`

## What to Store

FKSaveSystem saves whatever Dictionary you give it. A typical save includes:

- Player state (name, level, stats, HP, MP, position)
- Inventory (item IDs and quantities)
- Quest progress (quest ID to objective progress mapping)
- Game flags (NPCs talked to, chests opened, events triggered)
- Current zone or scene path
- Playtime

ForgeKit resources themselves are not saved. They are static data defined at design time. What you save is the player's runtime state that references those resources by ID.

## Integration with the Save/Load Scene Template

The Save/Load scene template (generated from the Scenes tab) provides a UI with 10 save slots and a save/load toggle. It is a starting point for the visual layer. You still need to connect it to FKSaveSystem calls in your own script.

A typical flow:

1. Player opens the save/load screen.
2. Call `FKSaveSystem.get_used_slots()` and `FKSaveSystem.get_slot_info()` for each used slot to populate the UI.
3. When the player selects a slot and clicks Save, gather your game state into a Dictionary and call `FKSaveSystem.save_game(slot, data)`.
4. When the player selects a slot and clicks Load, call `FKSaveSystem.load_game(slot)` and restore your game state from the returned Dictionary.
