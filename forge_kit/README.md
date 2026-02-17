# ForgeKit for Godot

A game creation toolkit for Godot 4.x. The current release includes a full RPG module with classes, enemies, items, abilities, stats, loot tables, encounters, zones, skill trees, dialogues, quests, and more.

## Features (v1.0.0)

### RPG Module - 14 Custom Resource Types

All game data is stored as Godot `.tres` resource files. They're version-control friendly, easy to edit, and show up in the Godot inspector.

| Resource | Description |
|----------|-------------|
| **FKStat** | Base stats (Strength, Dexterity, etc.) with min/max/default values |
| **FKDerivedStat** | Calculated stats from weighted base stats (Evasion = DEX * 0.5 + LCK * 0.3) |
| **FKClass** | Character classes with base stats, stat growth, equippable types, abilities by level, EXP curves |
| **FKEnemy** | Enemies with stats, AI behavior, weaknesses/resistances, loot tables, EXP/gold rewards |
| **FKItem** | Weapons, armor, consumables, key items with stats, equipment slots, rarity, economy values |
| **FKAbility** | Active abilities/spells with damage formulas, targeting, costs, status effects, scaling |
| **FKPassiveSkill** | Passive bonuses and traits with conditional activation |
| **FKSkillTree** | Skill trees with tiered nodes, prerequisites, and point costs |
| **FKLootTable** | Weighted random loot tables with guaranteed drops, roll counts, quantity ranges |
| **FKEncounterTable** | Random encounter tables with enemy groups, step-based triggering, level ranges |
| **FKZone** | Game areas/maps with encounter tables, NPCs, connections, music, weather |
| **FKDialogue** | Branching dialogue trees with choices, conditions, actions, speaker portraits |
| **FKQuest** | Quest system with objectives, rewards, prerequisites, dialogue hooks, quest chains |
| **FKSettings** | Project-wide config: genre, stats, elements, equipment slots, economy, battle system |

### Quick Setup

New to ForgeKit? The **Quick Setup** tab generates a complete starter RPG dataset with one click. It creates **45 interconnected resources** so you can see how everything fits together and start customizing right away:

- **6 Base Stats** - Strength, Dexterity, Intelligence, Wisdom, Vitality, Luck
- **4 Derived Stats** - Physical Attack, Magic Attack, Evasion, Heal Power
- **8 Abilities** - Slash, Power Strike, Fireball, Ice Shard, Heal, Group Heal, Shield Bash, Poison Sting
- **5 Passive Skills** - Iron Body, Keen Eye, Arcane Mind, Last Stand, Lucky Star
- **1 Skill Tree** - Warrior tree with 6 nodes across 3 tiers
- **3 Classes** - Warrior, Mage, Rogue with full stat growth curves
- **8 Items** - Potions, Ethers, Antidotes, Iron Sword, Wooden Staff, Iron Dagger, Leather Armor, Iron Shield
- **4 Enemies** - Slime, Goblin, Skeleton, Dragon (boss)
- **2 Loot Tables** - Common drops and boss drops with weighted chances
- **1 Encounter Table** - Forest encounters with varied enemy groups
- **1 Zone** - Emerald Forest with encounters, recommended levels, and settings
- **1 Dialogue** - Village Elder introduction with branching choices
- **1 Quest** - "Slime Slayer" with kill, collect, and talk objectives

### Setup Tab

Configure your game's core systems before creating any resources. Pick a genre preset and it auto-fills everything, then tweak what you want.

**6 Genre Presets:**
- Classic JRPG, Action RPG, Tactical RPG, Dungeon Crawler, Open World, Autobattler

**7 Configurable Sections:**
1. Game Profile
2. Stat Builder
3. Derived Stats
4. Element System
5. Equipment Slots
6. Economy
7. Battle System

### Editor Dock

An integrated dock panel in the Godot editor with five tabs:

- **Quick Setup** - One-click starter dataset with 45 resources
- **Setup** - Genre presets and core game configuration
- **Resources** - Create any resource type, browse existing ones, access visual editors
- **Scenes** - Generate pre-built scene templates
- **Database** - View all resources at a glance, validate data, import/export JSON

### Visual Dialogue Editor

A node-graph editor for building dialogue trees visually. No manual dictionary editing needed.

- 5 node types: Text (blue), Choice (gold), Condition (purple), Action (green), End (red)
- Drag-and-drop connections between nodes
- Edit speaker names, text, emotions, conditions, and actions inline
- Choice and condition branching with color-coded outputs
- Right-click context menu, toolbar buttons, auto-layout
- Positions save and restore between sessions

### Visual Skill Tree Editor

A node-graph editor for building skill trees with drag-and-drop prerequisite chains.

- 3 node types: Passive Skill (teal), Ability Unlock (orange), Milestone (gold)
- Connect nodes to define unlock requirements
- Edit names, resource paths, costs, ranks, tiers, and descriptions inline
- Tier-based auto-layout, configurable tier count and points-per-tier
- Right-click context menu, toolbar buttons
- Positions save and restore between sessions

### Damage Formula Tester

Test and tune ability damage formulas in real-time.

- Configure base power, scaling stat, multiplier, variance, crit bonus, hit count
- Attacker stats auto-load from your project's stat definitions
- Adjust defense and element resistance on the defender side
- Results update instantly as you change any value
- Load settings directly from FKAbility or FKEnemy resource files
- Uses standard RPG defense formula: `damage = raw_power * (100 / (100 + defense))`

### Data Validation

Scans all ForgeKit resources for errors, broken references, and balance issues.

- Checks for missing fields, duplicate IDs, broken references, empty collections, and balance problems
- Color-coded output (red errors, yellow warnings)
- Copy results to clipboard

### Import / Export JSON

Export and import ForgeKit resources as JSON files.

- Export all resources or filter by type
- Import from JSON to recreate `.tres` files
- Handles nested resources, vectors, colors, and resource references

### Scene Generator

Create custom scenes with configurable options:

- 13 scene types (Dungeon Room, Town, World Map, Boss Arena, and more)
- 2D or 3D rendering modes
- Optional camera, HUD, music, and transition components

### Pre-Built Scene Templates

9 ready-to-customize templates: Battle Scene, Overworld, Title Screen, Game Over, Dialogue, Shop, Inventory, Party Menu, Save/Load.

### Utility Systems

- **FKDatabase** - Runtime database for loading, caching, and querying resources by type and ID
- **FKSaveSystem** - JSON-based save/load with multiple slots and metadata

### Data Organization

Resources are organized into `res://rpg_data/` subdirectories:
```
res://rpg_data/
  rpg_settings/
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
```

---

## Community & Support

- **Patreon** - https://patreon.com/JROne2717
- **Discord** - https://discord.gg/tXZw3gDNSk

---

## Installation

1. Download or clone this repository
2. Copy the contents into your Godot project's `addons/forge_kit/` directory
3. Open your project in Godot 4.x
4. Go to **Project > Project Settings > Plugins**
5. Find "ForgeKit" and enable it
6. The ForgeKit dock will appear in the right panel

## Requirements

- Godot 4.2 or later
- GDScript (no C# required)

## Documentation

For a step-by-step guide covering every feature, see [HOW_TO_USE.md](HOW_TO_USE.md).

## License

MIT License. See [LICENSE](LICENSE) for full terms.

## Author

Created by **JROne2717**
