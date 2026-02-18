# ForgeKit for Godot

ForgeKit is an opinionated game framework for Godot 4.x. It provides a structured data model, editor tooling, and optional runtime systems to reduce boilerplate and keep RPG projects consistent as they grow.

The current release (v0.1.2) includes the RPG Core module with 14 structured resource types and editor tooling. Advanced runtime systems are planned and distributed separately.

## Documentation

Full documentation is available in the [/docs](docs/README.md) directory:

- [Quickstart guide](docs/quickstart.md)
- [Architecture overview](docs/concepts/architecture.md)
- [Extensibility guide](docs/concepts/extensibility.md)
- [Dialogue walkthrough](docs/guides/dialogue.md)
- [Quest walkthrough](docs/guides/quests.md)
- [Resource type reference](docs/reference/resources.md)
- [Troubleshooting](docs/troubleshooting.md)

## Design Philosophy

ForgeKit enforces structure by default. Resource schemas, directory conventions, and editor tooling assume a consistent layout.

The trade-off is less ad-hoc flexibility at the start of a project. The benefit is predictable tooling behavior, version-control friendly data, and easier onboarding for additional developers.

This project prioritizes long-term maintainability over maximum configurability in v0.x.

ForgeKit is designed for projects that want structure early rather than building custom data schemas from scratch.

## Core vs Advanced

ForgeKit is split into two layers:

- **Core** - Data model and editor tooling. Resource type definitions, the editor dock, visual editors, FKDatabase, FKSaveSystem. Free and open source.
- **Advanced** - Runtime gameplay systems. Battle manager, dialogue player, quest tracker, inventory manager, encounter triggers. Distributed separately.

Core functions independently. Advanced depends on Core. There are no reverse dependencies.

## Features (v0.1.2)

### 14 Resource Types

All game data is stored as `.tres` files under `res://rpg_data/`. Version-control friendly, editable in the Inspector.

| Resource | Description |
|----------|-------------|
| **FKStat** | Base stats with min/max/default values |
| **FKDerivedStat** | Calculated stats from weighted base stats |
| **FKClass** | Character classes with stat growth, equippable types, abilities by level, EXP curves |
| **FKEnemy** | Enemies with stats, AI behavior, weaknesses/resistances, loot tables, rewards |
| **FKItem** | Weapons, armor, consumables, key items with stat modifiers, equipment slots, rarity |
| **FKAbility** | Active abilities with damage formulas, targeting, costs, status effects, scaling |
| **FKPassiveSkill** | Passive bonuses with conditional activation |
| **FKSkillTree** | Skill trees with tiered nodes, prerequisites, point costs |
| **FKLootTable** | Weighted loot tables with guaranteed drops and quantity ranges |
| **FKEncounterTable** | Random encounters with enemy groups, step-based triggering, level ranges |
| **FKZone** | Game areas with encounters, NPCs, connections, music, weather |
| **FKDialogue** | Branching dialogue trees with choices, conditions, actions |
| **FKQuest** | Quests with objectives, rewards, prerequisites, chains |
| **FKSettings** | Project-wide config: stats, elements, equipment slots, economy, battle type |

Every resource type includes a `custom_data: Dictionary` field for project-specific extensions.

### Editor Dock

Five-tab dock panel integrated into the Godot editor:

- **Quick Setup** - Generates 45 starter resources in one click
- **Setup** - Genre presets (6 presets) and project configuration (stats, elements, slots, economy, battle system)
- **Resources** - Create and browse resources by type, access visual editors
- **Scenes** - Generate scene templates
- **Database** - View all resources, click to edit in Inspector

### Quick Setup

Generates a complete starter dataset: 6 stats, 4 derived stats, 3 classes, 4 enemies, 8 items, 8 abilities, 5 passives, 1 skill tree, 2 loot tables, 1 encounter table, 1 zone, 1 dialogue, 1 quest. All interconnected.

### Visual Editors

**Dialogue Graph Editor** - Node-graph editor for dialogue trees. Five node types (text, choice, condition, action, end). Drag connections between nodes, edit inline, auto-layout.

**Skill Tree Editor** - Node-graph editor for skill trees. Three node types (passive, ability, milestone). Define prerequisites with connections, configure tiers and point costs.

### Additional Tools

- **Damage Formula Tester** - Configure and test ability damage calculations in real time. Load from existing FKAbility or FKEnemy resources.
- **Data Validation** - Scan all resources for missing fields, duplicate IDs, broken references, and balance issues.
- **JSON Import/Export** - Export resources to JSON, import from JSON. Handles nested resources and vectors.
- **Scene Generator** - Create scenes from 13 types (dungeon, town, arena, etc.) with configurable components.
- **Scene Templates** - 9 pre-built templates: battle, overworld, title screen, game over, dialogue, shop, inventory, party menu, save/load.

### Utilities

- **FKDatabase** - Scans `rpg_data/` directories, caches resources, provides lookup by type and ID.
- **FKSaveSystem** - JSON-based save/load with multiple slots and metadata.

### Data Layout

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

## Installation

1. Download or clone this repository.
2. Copy `addons/forge_kit/` into your project's `addons/` directory.
3. Open the project in Godot 4.x.
4. Go to Project > Project Settings > Plugins.
5. Enable ForgeKit.
6. The dock appears in the right panel.

## Requirements

- Godot 4.2 or later
- GDScript (no C# required)

## License

MIT License. See [LICENSE](LICENSE) for full terms.

## Links

- [Patreon](https://patreon.com/JROne2717)
- [Discord](https://discord.gg/EbD9r95FA4)

## Author

Created by JROne2717
