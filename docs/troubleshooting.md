# Troubleshooting

Known issues, common mistakes, and Godot quirks that affect ForgeKit.

---

## Array[Dictionary] Serialization

This is the most common gotcha. Godot's ResourceSaver silently drops untyped nested arrays in certain cases.

**Symptom:** You save a resource with Array[Dictionary] data (loot entries, quest objectives, dialogue nodes, AI patterns, etc.), close and reopen the editor, and the array is empty.

**Cause:** The array was not properly typed, or it was assigned before the resource was fully initialized.

**Fix:** When creating resources in code, build typed arrays with `.append()`, assign them after the resource is created, then re-save:

```gdscript
var quest = FKQuest.new()
quest.id = "my_quest"

# Build the array separately with append
var objectives: Array[Dictionary] = []
var obj: Dictionary = {
    "id": "kill_rats",
    "type": "kill",
    "target": "rat",
    "count": 5
}
objectives.append(obj)

# Assign after creation
quest.objectives = objectives

# Save
ResourceSaver.save(quest, "res://rpg_data/rpg_quest/my_quest.tres")
```

If you create resources through the Inspector (the normal workflow), this is handled for you. The issue only appears when you build resources in code.

---

## GraphEdit Port Indices vs Slot Indices

**Symptom:** Connections in the dialogue or skill tree editor go to the wrong node or port.

**Cause:** `connect_node()` in GraphEdit uses port indices (the nth *enabled* port), not slot indices (the nth slot on the node). If you have disabled ports, the numbering shifts.

**Fix:** When debugging connection issues, count only the enabled ports. The visual editor handles this correctly, but if you are modifying graph data manually, be aware of the difference.

---

## AcceptDialog Coordinate Conversion

**Symptom:** Popup dialogs opened from the dock appear in the wrong position, or click coordinates are offset inside dialog windows.

**Cause:** `InputEvent.global_position` inside a Window is viewport-relative, not screen-relative. If you are calculating positions for popups or context menus, the coordinates will be wrong.

**Fix:** Convert with `Vector2i(global_pos) + position` where `position` is the window's screen position.

---

## GraphNode Position Property

**Symptom:** Moving nodes in the visual editor does not persist, or nodes snap back to their original position.

**Cause:** Using the wrong property. GraphNode has `position`, `offset`, and `position_offset`. Only `position_offset` is the correct one for GraphEdit layouts.

**Fix:** Always use `position_offset` when reading or writing GraphNode positions in the dialogue and skill tree editors.

---

## Database Tab - Clicking Resources Does Nothing

**Symptom:** You click a resource name in the Database tab and nothing happens. No error, no Inspector change.

**Cause:** This was a bug in v0.1.0 caused by a Godot lambda capture issue. The click handler used an inline lambda that captured a loop variable by reference. By the time you clicked, the variable pointed to the last item in the loop.

**Fix:** Fixed in v0.1.2. The handler now uses `.bind()` to capture the path by value. If you are on an older version, update.

---

## get_class() vs get_char_class()

**Symptom:** Calling `get_class()` on an FKClass resource returns "Resource" instead of your class data.

**Cause:** `get_class()` is a built-in Godot method on Object. It returns the engine class name, not your RPG class data.

**Fix:** ForgeKit uses the property name `id` and `display_name` on FKClass. Access those directly. If you wrote a helper that wraps FKClass, name it something like `get_char_class()` to avoid the collision.

---

## Data Directories Use rpg_ Prefix

**Symptom:** Creating resources in a directory named `fk_stat/` or `stat/` and they do not show up in the Database tab.

**Cause:** ForgeKit expects directories under `rpg_data/` with the `rpg_` prefix. The `_get_resource_dir()` helper generates paths like `rpg_data/rpg_stat/`, `rpg_data/rpg_item/`, etc.

**Fix:** Use the correct directory names. Quick Setup creates them automatically. If you are creating directories manually, follow the `rpg_<type>` pattern.

---

## Missing Editor Icons

**Symptom:** Resource type icons in the editor are missing or show the default Resource icon.

**Cause:** The icons directory was not included, or the SVG files were not imported by Godot.

**Fix:** Make sure `addons/forgekit/icons/` exists and contains the SVG files. After copying them in, let Godot reimport (it does this automatically on focus). You may need to restart the editor.

---

## Quick Setup Overwrites Existing Resources

**Symptom:** Running Quick Setup a second time replaces your modified resources.

**Cause:** Quick Setup checks if files exist before creating them, but if the directory structure has been modified or files were moved, it may not detect them correctly.

**Fix:** Only run Quick Setup once on a fresh project. If you need to regenerate specific resources, create them individually through the Resources tab instead.

---

## Custom Data Not Showing in Inspector

**Symptom:** The `custom_data` Dictionary field exists but you cannot see or edit its contents in the Inspector.

**Cause:** Godot's Inspector does show Dictionary properties, but the UX for nested data is not great. Complex nested structures may be hard to edit visually.

**Fix:** For simple key-value pairs, the Inspector works fine - click the Dictionary field to expand it and add entries. For complex data, consider editing the `.tres` file directly in a text editor, or setting values in code with a tool script.
