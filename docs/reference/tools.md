# Editor Tools Reference

ForgeKit includes several tools accessible from the dock. This page covers the Damage Formula Tester, Data Validation, and JSON Import/Export.

For visual editors, see the [Dialogue Editor](../guides/dialogue.md) and [Skill Tree Editor](../guides/skill-tree-editor.md) guides. For scene generation, see [Scene Generator](scene-generator.md).

---

## Damage Formula Tester

Tests and tunes ability damage calculations in real time. Useful for verifying that your power values, scaling multipliers, and defense curves produce reasonable damage ranges.

### Opening

1. Open the ForgeKit dock and go to the Resources tab.
2. Scroll to "Visual Editors" at the bottom.
3. Click "Damage Formula Tester..."

The tester opens as a popup with three columns and a results section.

### Layout

**Ability Settings (left column):**

| Field | Description |
|-------|-------------|
| Base Power | The base damage value of the ability |
| Scaling Stat | Which attacker stat scales the ability |
| Scale Multiplier | How much the scaling stat contributes |
| Variance | Random damage variance (0.1 = +/- 10%) |
| Crit Bonus | Additional crit multiplier above the base 1.5x |
| Hit Count | Number of hits per ability use |

**Attacker Stats (middle column):**

A SpinBox for each stat defined in your project. These are auto-loaded from `rpg_data/rpg_stat/`. Adjust them to simulate different character builds.

**Defender Stats (right column):**

| Field | Description |
|-------|-------------|
| Defense | The defender's defense value |
| Element Modifier | 1.0 = neutral, 2.0 = weakness (double damage), 0.5 = resistance (half damage), 0.0 = immune |

### Damage Formula

The tester uses this formula:

1. **Raw Power** = Base Power + (Stat Value * Scale Multiplier)
2. **After Defense** = Raw Power * (100 / (100 + Defense))
3. **After Element** = After Defense * Element Modifier
4. **Min Damage** = After Element * (1 - Variance)
5. **Max Damage** = After Element * (1 + Variance)
6. **Crit Damage** = Max Damage * (1.5 + Crit Bonus)

All values update in real time as you adjust the inputs.

### Loading from Resources

- **Load from Ability** - Click to pick any FKAbility `.tres` file. Auto-fills base power, scaling stat, multiplier, variance, crit bonus, and hit count from the resource.
- **Load from Enemy** - Click to pick any FKEnemy `.tres` file. Auto-fills the defense value and element modifiers from the enemy's stats.

This lets you test specific ability-vs-enemy matchups without entering values manually.

### Tuning Tips

- Test abilities against both low-defense and high-defense enemies to verify the damage curve feels right.
- The defense formula has diminishing returns: going from 0 to 100 defense halves damage, but going from 100 to 200 only reduces it by another third.
- If damage feels flat across different character builds, increase the scaling multiplier. If it scales too aggressively, reduce it.

---

## Data Validation

Scans all ForgeKit resources and reports errors, warnings, and balance issues. Run this after creating or modifying a batch of resources.

### Opening

1. Open the ForgeKit dock and go to the Database tab.
2. Click "Validate All Resources."
3. In the popup, click "Run Validation."

### What Gets Checked

The validator runs six categories of checks:

**1. Missing Required Fields**
- Every resource must have a non-empty `id`.
- Resources with an empty `display_name` trigger a warning.

**2. Duplicate IDs**
- Flags any two resources of the same type that share the same `id`.

**3. Broken Resource References**
- Checks all resource-typed fields: enemy loot tables, enemy abilities, class skill trees, class passive skills, zone encounter tables, quest dialogues, quest ability rewards, loot table items, encounter table enemies.
- Flags null references and resources with no saved path.

**4. Broken String ID References**
- Skill tree node prerequisites must reference existing node IDs within the same tree.
- Quest `prerequisite_quests` must reference existing quest IDs.
- Zone connection `zone_id` values must reference existing zone IDs.

**5. Empty Collections**
- Loot tables with no entries.
- Encounter tables with no entries.
- Skill trees with no nodes.
- Dialogues with no nodes.
- Classes with no base stats.

**6. Balance Warnings**
- Enemies with 0 EXP or 0 gold reward.
- Items with a buy price but 0 sell price, or sell price exceeding buy price.
- Physical, Magical, or Hybrid abilities with 0 base power.
- Abilities with no cost (MP, HP, and TP all 0).

### Output

Results are color-coded:

- **Red** - Error. Likely to cause problems at runtime.
- **Yellow** - Warning. May be intentional but worth reviewing.
- **Cyan** - Section headers.

Click "Copy Results" to copy the full report as plain text to your clipboard.

---

## JSON Import/Export

Exports ForgeKit resources as JSON and imports them back. Useful for backups, sharing between projects, and bulk editing in external tools.

### Opening

1. Open the ForgeKit dock and go to the Database tab.
2. Click "Import / Export JSON."

### Exporting

1. Select a resource type from the dropdown, or leave as "All Types" to export everything.
2. Click "Export to JSON..."
3. Choose where to save the `.json` file.

**What gets exported:**

- All `@export` properties from each resource.
- Resource references are stored as file paths: `{"_resource_path": "res://rpg_data/rpg_item/potion.tres"}`.
- Vector2, Vector2i, and Color values are stored as readable dictionaries.
- Each entry includes a `_type` field identifying the resource type.

### Importing

1. Click "Import from JSON..."
2. Select a previously exported `.json` file.
3. Resources are recreated as `.tres` files in the appropriate `rpg_data/` subdirectories.

**Import behavior:**

- Resources are saved to `res://rpg_data/{type_snake_case}/{id}.tres`.
- Existing files with the same name are overwritten.
- Resource path references are resolved back to actual resource files. The referenced files must already exist.
- Directories are created automatically if they do not exist.

The log shows each imported resource and any errors encountered during import.

### Use Cases

- **Backups** - Export all resources before making large-scale changes.
- **Sharing** - Send game data to collaborators as a single JSON file.
- **Bulk editing** - Export to JSON, edit in a text editor or spreadsheet tool, then import back.
- **Migration** - Move resources between Godot projects.
