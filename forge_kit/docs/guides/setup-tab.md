# Setup Tab

The Setup tab is the second tab in the ForgeKit dock. It configures project-wide RPG settings: stats, elements, equipment slots, economy, and battle system. It also provides genre presets that fill in reasonable defaults.

Use this after Quick Setup if you want to customize the generated settings, or instead of Quick Setup if you want full control from the start.

## Opening the Setup Tab

1. Open the ForgeKit dock.
2. Click the "Setup" tab (second from the left).

The tab is divided into sections: Game Profile, Base Stats, Derived Stats, Elements, Equipment Slots, Economy, and Battle System.

## Genre Presets

Selecting a genre auto-fills all fields with starting values. You can change any field after selecting a preset.

| Genre | Battle Type | Party Size | Stats | Elements | Max Level |
|-------|------------|------------|-------|----------|-----------|
| Classic JRPG | Turn-Based | 4 | 6 | 8 | 99 |
| Action RPG | Action Real-Time | 1 | 5 | 4 | 99 |
| Tactical RPG | Tactical Grid | 6 | 7 | 6 | 50 |
| Dungeon Crawler | Turn-Based | 5 | 6 | 5 | 99 |
| Open World | Action Real-Time | 3 | 6 | 5 | 60 |
| Autobattler | Autobattle | 6 | 5 | 6 | 30 |

Presets are starting points. Every field is editable after selection, and you can switch presets before saving without losing manual changes.

## Configuring Each Section

### Game Profile

- **Game Name** - Your project name. Stored in FKSettings.
- **Genre** - Select a preset or leave as-is for manual configuration.

### Base Stats

Check or uncheck the default stats (Strength, Dexterity, Intelligence, etc.). To add a custom stat, type a name in the text field and click "Add."

Each checked stat generates an FKStat resource when you save. Existing FKStat files are not overwritten.

### Derived Stats

Shown from the genre preset. These are stats calculated from weighted base stats (e.g., Evasion = DEX * 0.5 + LCK * 0.3). Each generates an FKDerivedStat resource when you save.

To customize weights and formulas, edit the generated FKDerivedStat resources directly in the Inspector after saving.

### Elements

Check or uncheck elements (Fire, Ice, Lightning, etc.). To add a custom element, type a name and click "Add."

Elements are stored as strings in FKSettings and referenced by FKAbility, FKEnemy (weaknesses/resistances), and FKPassiveSkill (element resistances).

### Equipment Slots

Check or uncheck slots (main_hand, off_hand, head, body, legs, feet, ring, necklace). Custom slots should use snake_case.

Equipment slots are stored in FKSettings and used by FKItem (equipment_slot field) and FKClass (equippable_types field).

### Economy

- **Currency Name** - The name shown to players (e.g., "Gold", "Credits", "Gil").
- **Sell Ratio** - What fraction of the buy price items sell for. 0.5 means items sell for half their buy price.

### Battle System

- **Battle Type** - Turn-Based, Active Time Battle, Autobattle, Tactical Grid, or Action Real-Time.
- **Party Size** - Maximum characters in the player's party.
- **Max Enemies** - Maximum enemies per battle.
- **EXP Distribution** - Full to All, Split Evenly, or Active Only.
- **Allow Flee** - Whether the player can escape from battles.
- **Max Level** - Level cap for the project.

## Saving

Click "Save Settings" at the bottom. This creates:

- An FKSettings resource at `res://rpg_data/rpg_settings/game_settings.tres` with all your configuration.
- An FKStat resource for each checked base stat (only new ones; existing files are not overwritten).
- An FKDerivedStat resource for each derived stat from the genre preset.

## When to Use Setup vs Quick Setup

**Quick Setup** generates 45 interconnected resources (stats, classes, enemies, items, etc.) for immediate experimentation. It runs the Setup configuration internally.

**Setup tab** gives you control over each setting individually. Use it when you know your project's stat list, element system, and battle type, and want to configure those before creating individual resources.

Both approaches are valid. Quick Setup is faster for prototyping. The Setup tab is better when you have a specific design in mind.
