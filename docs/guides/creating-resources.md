# Creating Resources

This page walks through creating each of the 14 resource types. For property-level details, see the [Resource Types Reference](../reference/resources.md).

All resources are created from the ForgeKit dock's Resources tab. Click the "Create New" button under the relevant type, choose a save location (the default `rpg_data/rpg_<type>/` directory is recommended), and edit properties in the Inspector.

## Recommended Creation Order

Resources reference each other. Creating them in this order avoids forward references:

1. Stats and Derived Stats
2. Abilities
3. Passive Skills
4. Skill Trees (references passives and abilities)
5. Classes (references abilities, passives, skill trees)
6. Items
7. Enemies (references abilities, loot tables)
8. Loot Tables (references items)
9. Encounter Tables (references enemies)
10. Zones (references encounter tables, dialogues)
11. Dialogues
12. Quests (references dialogues, items, abilities)

This is not strict. You can create resources in any order and fill in references later.

---

## Stats

Stats are the foundation. They define attributes like Strength, Dexterity, and Intelligence.

1. Click "Create New" under Stats.
2. Save as `rpg_data/rpg_stat/strength.tres`.
3. In the Inspector, set:
   - **id**: `strength`
   - **display_name**: `Strength`
   - **description**: `Physical power. Affects melee damage.`
   - **min_value**: `1`
   - **max_value**: `999`
   - **default_value**: `10`

The `id` is how other resources reference this stat (in `base_stats` dictionaries, `scaling_stat` fields, etc.). Use snake_case.

## Derived Stats

Derived stats are calculated from weighted base stats. For example, Evasion might be `DEX * 0.5 + LCK * 0.3`.

1. Click "Create New" under Derived Stats.
2. Save as `rpg_data/rpg_derived_stat/evasion.tres`.
3. Set:
   - **id**: `evasion`
   - **display_name**: `Evasion`
   - **stat_weights**: `{"dexterity": 0.5, "luck": 0.3}`
   - **flat_bonus**: `0.0`

At runtime, call `derived_stat.calculate(base_stats)` where `base_stats` is a Dictionary mapping stat IDs to values. The formula is: sum of (stat_value * weight) + flat_bonus.

---

## Abilities

Abilities are active skills used in combat.

1. Click "Create New" under Abilities.
2. Save as `rpg_data/rpg_ability/fireball.tres`.
3. Set:
   - **id**: `fireball`
   - **display_name**: `Fireball`
   - **ability_type**: `Magical`
   - **target_type**: `All Enemies`
   - **element**: `Fire`
   - **mp_cost**: `15`
   - **base_power**: `40.0`
   - **scaling_stat**: `intelligence`
   - **scaling_multiplier**: `1.2`
   - **variance**: `0.1`

For abilities that inflict status effects, add entries to the `status_effects` array:

```
{"status": "poison", "chance": 0.5, "duration": 3}
```

This means a 50% chance to inflict poison for 3 turns.

Use the [Damage Formula Tester](../reference/tools.md#damage-formula-tester) to verify your power/scaling values produce reasonable damage ranges.

---

## Passive Skills

Passive skills provide permanent or conditional bonuses.

1. Click "Create New" under Passive Skills.
2. Save as `rpg_data/rpg_passive_skill/iron_body.tres`.
3. Set:
   - **id**: `iron_body`
   - **display_name**: `Iron Body`
   - **stat_bonuses**: `{"vitality": 5}`
   - **stat_percent_bonuses**: `{"vitality": 0.1}`
   - **activation_condition**: `Always`

This gives +5 flat Vitality and +10% Vitality at all times. Other conditions include `In Battle`, `HP Below 25%`, `HP Full`, `Alone`, and `Custom` (with a free-form `custom_condition` string your runtime code evaluates).

---

## Skill Trees

Skill trees organize abilities and passives into unlockable progression paths. Each node in the tree is either a passive skill, an ability unlock, or a milestone.

For anything beyond trivial trees, use the [Visual Skill Tree Editor](skill-tree-editor.md) instead of editing the `nodes` array manually.

To create a skill tree manually:

1. Click "Create New" under Skill Trees.
2. Save as `rpg_data/rpg_skill_tree/warrior_tree.tres`.
3. Set **tier_count** and **points_per_tier** (minimum points spent in lower tiers before the next tier unlocks).
4. Add entries to the `nodes` array. Each node is a Dictionary:

```
{
    "id": "power_strike_1",
    "name": "Power Strike I",
    "description": "Unlocks Power Strike",
    "type": "ability",
    "cost": 1,
    "max_rank": 1,
    "prerequisites": [],
    "tier": 0
}
```

The `prerequisites` array lists node IDs that must be unlocked first. The `type` field is `"passive"`, `"ability"`, or `"milestone"`.

---

## Classes

Classes define character archetypes.

1. Click "Create New" under Classes.
2. Save as `rpg_data/rpg_class/warrior.tres`.
3. Set:
   - **id**: `warrior`
   - **display_name**: `Warrior`
   - **base_stats**: `{"strength": 15, "dexterity": 10, "intelligence": 5, "wisdom": 5, "vitality": 12, "luck": 8}`
   - **stat_growth_per_level**: `{"strength": 3, "dexterity": 2, "intelligence": 1, "wisdom": 1, "vitality": 2, "luck": 1}`
   - **equippable_types**: `["sword", "shield", "heavy_armor"]`
   - **exp_curve**: `Quadratic`

For `abilities_by_level`, map level numbers to arrays of ability resource paths:

```
{1: ["res://rpg_data/rpg_ability/slash.tres"], 5: ["res://rpg_data/rpg_ability/power_strike.tres"]}
```

Assign a skill tree by dragging an FKSkillTree resource into the `skill_tree` field in the Inspector.

At runtime, `get_stats_at_level(10)` returns the calculated stats at level 10, and `get_exp_for_level(11)` returns the experience required for level 11.

**Note:** Do not call `get_class()` on an FKClass resource. That is a built-in Godot method that returns the engine class name. Use the `id` and `display_name` properties directly. See [Troubleshooting](../troubleshooting.md).

---

## Items

Items cover weapons, armor, consumables, key items, materials, and currency.

1. Click "Create New" under Items.
2. Save as `rpg_data/rpg_item/iron_sword.tres`.
3. Set:
   - **id**: `iron_sword`
   - **display_name**: `Iron Sword`
   - **item_type**: `Weapon`
   - **sub_type**: `Sword`
   - **equipment_slot**: `main_hand`
   - **stat_modifiers**: `{"strength": 5, "dexterity": 2}`
   - **buy_price**: `100`
   - **sell_price**: `50`
   - **rarity**: `Common`

For consumables:

- Set **item_type** to `Consumable`.
- Set **use_effects**: `{"heal_hp": 50}` or `{"cure_poison": true}`.
- Set **consumable** to `true` if the item is used up on use.
- Set **usable_in_battle** and **usable_in_field** as appropriate.

For equipment, **class_restrictions** limits which classes can equip the item. An empty array means all classes can use it.

---

## Enemies

1. Click "Create New" under Enemies.
2. Save as `rpg_data/rpg_enemy/goblin.tres`.
3. Set:
   - **id**: `goblin`
   - **display_name**: `Goblin`
   - **base_stats**: `{"strength": 8, "dexterity": 12, "intelligence": 3}`
   - **max_hp**: `45`
   - **max_mp**: `10`
   - **level**: `3`
   - **exp_reward**: `15`
   - **gold_reward**: `8`
   - **enemy_tier**: `Normal`

Add abilities by dragging FKAbility resources into the `abilities` array.

### AI Patterns

The `ai_patterns` array controls which ability an enemy uses. Each entry is a Dictionary:

```
{"ability_index": 0, "weight": 50, "condition": "hp_above_50"}
{"ability_index": 1, "weight": 80, "condition": "hp_below_25"}
```

`ability_index` maps to the position in the `abilities` array. `weight` is the selection weight (higher = more likely). `condition` filters when the pattern is eligible.

Built-in conditions: `always`, `hp_above_50`, `hp_below_50`, `hp_below_25`, `hp_full`. Unknown condition strings default to true.

At runtime, `enemy.select_ability(current_hp_percent)` picks an ability based on the patterns and the enemy's current HP percentage.

### Weaknesses and Resistances

`weaknesses` and `resistances` are Dictionaries mapping element names to multipliers:

- `{"fire": 2.0}` means this enemy takes double fire damage.
- `{"ice": 0.5}` means this enemy takes half ice damage.

Assign a loot table by dragging an FKLootTable resource into the `loot_table` field.

---

## Loot Tables

Loot tables control what items enemies drop.

1. Click "Create New" under Loot Tables.
2. Save as `rpg_data/rpg_loot_table/goblin_drops.tres`.
3. Add entries to the `entries` array:

```
{
    "item": <drag an FKItem resource here>,
    "weight": 100,
    "min_quantity": 1,
    "max_quantity": 3,
    "drop_chance": 0.5
}
```

- **weight**: Relative selection weight. Higher values mean the item is picked more often compared to other entries.
- **drop_chance**: Absolute chance (0 to 1) applied after weight selection. 0.5 means a 50% chance the drop actually occurs.
- **min_quantity** / **max_quantity**: Random quantity range.

Set **roll_count** to control how many times the table is rolled per drop event. Set **guaranteed_drops** to ensure a minimum number of items always drop (picks the highest-weighted entries).

At runtime, `loot_table.roll()` returns an array of `{"item": FKItem, "quantity": int}`.

---

## Encounter Tables

Encounter tables define what enemy groups appear in a zone.

1. Click "Create New" under Encounter Tables.
2. Save as `rpg_data/rpg_encounter_table/forest_encounters.tres`.
3. Add entries:

```
{
    "enemies": [<FKEnemy resource>],
    "weight": 100,
    "min_count": 1,
    "max_count": 3
}
```

4. Set:
   - **base_steps**: `30` (average steps between encounters)
   - **step_variance**: `0.5` (encounters happen between 15 and 45 steps)
   - **max_enemies_per_battle**: `4`

At runtime, `roll_steps()` returns the step count until the next encounter, and `roll_encounter()` returns the enemy group.

---

## Zones

Zones represent game areas like towns, dungeons, and overworld maps.

1. Click "Create New" under Zones.
2. Save as `rpg_data/rpg_zone/emerald_forest.tres`.
3. Set:
   - **id**: `emerald_forest`
   - **display_name**: `Emerald Forest`
   - **zone_type**: `Dungeon`
   - **has_encounters**: `true`

Assign an encounter table by dragging an FKEncounterTable resource into the `encounter_table` field.

### Connections

The `connections` array links zones together:

```
{"zone_id": "forest_cave", "direction": "north", "requirement": "has_key"}
```

`requirement` is a free-form string your runtime code evaluates. Leave it empty for unconditional connections.

### NPCs

```
{"name": "Shopkeeper", "type": "shop", "dialogue": <FKDialogue resource>, "position": Vector2(100, 200)}
```

### Points of Interest

```
{"id": "chest_1", "type": "chest", "contents": <FKLootTable resource>, "position": Vector2(300, 150), "one_time": true}
```

Set `one_time` to `true` for chests and pickups that should not respawn.

---

## Dialogues

Dialogues are branching conversation trees. For anything with branching, use the [Visual Dialogue Editor](dialogue.md). For simple linear conversations, you can edit the `nodes` array directly.

Each node in the `nodes` array is a Dictionary with a `type` field:

**Text** (shows dialogue, advances to next):
```
{"id": "node_0", "type": "text", "speaker": "Elder", "text": "Welcome, hero!", "next": "node_1"}
```

**Choice** (presents options):
```
{
    "id": "node_1", "type": "choice", "text": "How can I help?",
    "choices": [
        {"text": "Tell me about the quest", "next": "node_2"},
        {"text": "Nevermind", "next": "node_end"}
    ]
}
```

**Condition** (branches on game state):
```
{"id": "node_3", "type": "condition", "condition": "has_item:old_key", "true_next": "node_4", "false_next": "node_5"}
```

**Action** (triggers a game action):
```
{"id": "node_4", "type": "action", "action": "give_item:potion", "next": "node_5"}
```

**End** (terminates the conversation):
```
{"id": "node_end", "type": "end"}
```

Condition and action strings use a `key:value` format. The Core layer stores them as strings but does not evaluate them. Your runtime code (or the Advanced dialogue player) handles evaluation.

---

## Quests

For a detailed walkthrough of quest chains, see the [Quest Guide](quests.md).

1. Click "Create New" under Quests.
2. Save as `rpg_data/rpg_quest/slay_slimes.tres`.
3. Set:
   - **id**: `slay_slimes`
   - **display_name**: `Slime Slayer`
   - **quest_type**: `Side Quest`

### Objectives

Add entries to the `objectives` array:

```
[
    {"id": "obj_kill", "type": "kill", "description": "Defeat 5 Slimes", "target": "slime", "count": 5},
    {"id": "obj_collect", "type": "collect", "description": "Gather 3 Herbs", "target": "herb", "count": 3},
    {"id": "obj_talk", "type": "talk", "description": "Return to Elder", "target": "elder", "count": 1}
]
```

The `target` must match the `id` of the relevant FKEnemy, FKItem, or NPC.

### Rewards

- **exp_reward** / **gold_reward**: Flat rewards on completion.
- **item_rewards**: `[{"item": <FKItem resource>, "quantity": 2}]`
- **ability_rewards**: Array of FKAbility resources unlocked on completion.

### Dialogue Links

- **accept_dialogue**: Conversation where the NPC offers the quest.
- **progress_dialogue**: What the NPC says mid-quest.
- **complete_dialogue**: Conversation when the player turns in the quest.

### Quest Chains

Set `quest_chain` to a shared string (e.g., `"rat_extermination"`) and `chain_order` to the sequence number (0, 1, 2, ...). Use `prerequisite_quests` to list quest IDs that must be completed first.

---

## FKSettings

FKSettings is the project-wide configuration resource. There should be one per project, typically generated by the [Setup Tab](setup-tab.md).

You can edit it directly in the Inspector at `rpg_data/rpg_settings/game_settings.tres`. It stores stats, elements, equipment slots, economy settings, and battle system configuration.

Other resources reference the values stored here (e.g., equipment slots in FKItem should match the slots defined in FKSettings).

---

## Tips

- Use snake_case for all `id` fields. IDs are how resources reference each other.
- Drag `.tres` files from the FileSystem dock into Inspector fields to set resource references. This is easier than typing paths.
- Use the [Data Validator](../reference/tools.md#data-validation) after creating a batch of resources to catch broken references and missing fields.
- If you are creating resources in code rather than the Inspector, be aware of the Array[Dictionary] serialization gotcha. See [Troubleshooting](../troubleshooting.md).
