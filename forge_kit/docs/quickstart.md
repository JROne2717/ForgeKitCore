# Quickstart

Get ForgeKit running and create your first set of RPG resources. This takes about 10 minutes.

## Prerequisites

- Godot 4.x (tested on 4.2+)
- A Godot project (new or existing)

## Install

1. Download or clone the ForgeKit repository.
2. Copy the `addons/forge_kit/` folder into your project's `addons/` directory.
3. In the Godot editor, go to Project > Project Settings > Plugins.
4. Find ForgeKit in the list and set it to Active.

A "ForgeKit" dock panel should appear on the right side of the editor.

## Quick Setup

This is the fastest way to get started. It generates a full set of starter resources so you have something to work with immediately instead of creating everything from scratch.

1. Open the ForgeKit dock.
2. Click the "Quick Setup" tab.
3. Click "Run Quick Setup."

This creates a `res://rpg_data/` directory with 45 starter resources organized by type:

```
rpg_data/
  rpg_stat/         (6 base stats: STR, DEX, INT, WIS, VIT, LCK)
  rpg_derived_stat/ (derived stats: evasion, crit rate, etc.)
  rpg_class/        (3 starter classes: Warrior, Mage, Rogue)
  rpg_enemy/        (sample enemies)
  rpg_item/         (weapons, potions, armor)
  rpg_ability/      (attack skills, spells)
  rpg_passive_skill/
  rpg_skill_tree/
  rpg_loot_table/
  rpg_encounter_table/
  rpg_zone/
  rpg_dialogue/
  rpg_quest/
  rpg_settings/     (project-wide RPG configuration)
```

## Explore the Dock

The dock has five tabs:

- **Quick Setup** - One-click project scaffolding (you just used this).
- **Setup** - Configure project-wide settings like stats, elements, equipment slots.
- **Resources** - Create and browse individual resources by type. Open the dialogue and skill tree visual editors from here.
- **Scenes** - Generate scene templates for battles, overworld, title screen, etc.
- **Database** - View all ForgeKit resources in your project. Click any resource to open it in the Inspector.

## Edit a Resource

1. Go to the Database tab.
2. Click "Refresh Database" to scan your project.
3. Click any resource name (e.g., "Warrior" under Classes).
4. The Inspector panel shows that resource's properties. Edit them there.

All resources are standard Godot `.tres` files. You can also open them directly from the FileSystem dock.

## Next Steps

- Read the [Overview](concepts/overview.md) to understand what ForgeKit does and does not do.
- Follow the [Dialogue guide](guides/dialogue.md) to build a conversation tree.
- Follow the [Quests guide](guides/quests.md) to set up a quest chain.
- Check the [Resource Reference](reference/resources.md) for details on every resource type.
