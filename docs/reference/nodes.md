# Runtime Nodes Reference

Runtime nodes are part of the Advanced layer. They are not included in the current release (v0.1.2). This page documents what is planned for v0.2 and beyond.

If you are using Core only, you write your own runtime code that reads from ForgeKit resources via FKDatabase. The resource types provide helper methods (like `FKLootTable.roll()` and `FKEnemy.select_ability()`) that you can use directly.

---

## Planned Nodes (v0.2)

### Battle Manager

Handles turn-based and action real-time combat. Reads from FKEnemy, FKAbility, FKPassiveSkill, and FKClass resources.

Planned features:
- Turn order calculation from stats
- Ability execution with damage formulas
- Status effect application
- Elemental weakness/resistance handling
- Victory/defeat conditions
- EXP and gold distribution

### Dialogue Player

Walks through an FKDialogue resource and presents it to the player. Handles branching, choices, conditions, and actions.

Planned features:
- Text display with configurable speed
- Choice presentation
- Condition evaluation
- Action execution hooks
- Portrait and emotion switching

### Quest Tracker

Manages active quests, tracks objective progress, and handles completion.

Planned features:
- Quest acceptance and abandonment
- Objective progress tracking
- Prerequisite checking
- Reward distribution
- Chain progression

### Inventory Manager

Manages the player's item collection. Works with FKItem resources.

Planned features:
- Add/remove items with stacking
- Equipment slots per FKSettings configuration
- Stat modifier calculation from equipped items
- Class restriction checking
- Weight/capacity limits (optional)

### Save/Load UI

Wraps FKSaveSystem with a ready-made save slot interface.

Planned features:
- Save slot selection
- Save/load with preview data
- Auto-save support
- Slot management (copy, delete)

### Encounter Trigger

Area-based and step-based random encounter triggering. Reads from FKEncounterTable.

Planned features:
- Area3D overlap detection for area-based encounters
- Step counter for step-based encounters
- Encounter rate modification (repel items, abilities)
- Level-based encounter filtering

---

## Using Core Without Advanced

All ForgeKit resources have methods you can call directly:

```gdscript
# Roll a loot table
var loot_table: FKLootTable = db.get_resource("FKLootTable", "forest_drops")
var drops = loot_table.roll()

# Pick an enemy ability
var enemy: FKEnemy = db.get_resource("FKEnemy", "goblin")
var ability = enemy.select_ability(current_hp / max_hp)

# Calculate ability damage
var power = ability.calculate_power(attacker_stats)

# Check quest completion
var quest: FKQuest = db.get_resource("FKQuest", "rat_problem")
if quest.is_complete(player_progress):
    pass  # award rewards

# Calculate derived stats
var derived: FKDerivedStat = db.get_resource("FKDerivedStat", "evasion")
var evasion_value = derived.calculate(character_base_stats)

# Get class stats at level
var warrior: FKClass = db.get_resource("FKClass", "warrior")
var stats_at_10 = warrior.get_stats_at_level(10)
var xp_needed = warrior.get_exp_for_level(11)

# Walk a dialogue tree
var dialogue: FKDialogue = db.get_resource("FKDialogue", "blacksmith_intro")
var current_node = dialogue.get_start_node()
# ... present text, handle choices, call get_node_by_id() for branching
```

The Advanced nodes just wrap these calls with scene tree integration, signals, and UI. If you prefer to write your own systems, Core gives you everything you need.
