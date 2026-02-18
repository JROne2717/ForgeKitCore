# Resource Types Reference

ForgeKit v0.1.2 includes 14 resource types. All are `@tool` scripts with `class_name`, extending `Resource`. All include a `custom_data: Dictionary` for project-specific extensions.

Resources are stored as `.tres` files in `res://rpg_data/rpg_<type>/`.

---

## FKStat

Base stat definition (Strength, Dexterity, etc.).

| Property | Type | Default | Notes |
|----------|------|---------|-------|
| id | String | "" | Unique identifier |
| display_name | String | "" | Shown to players |
| description | String | "" | Multiline |
| min_value | float | 0.0 | |
| max_value | float | 999.0 | |
| default_value | float | 10.0 | Starting value |
| icon | Texture2D | null | |
| color | Color | WHITE | UI display color |
| custom_data | Dictionary | {} | |

Directory: `rpg_data/rpg_stat/`

---

## FKDerivedStat

Calculated from weighted base stats (e.g., Evasion = DEX * 0.5 + LCK * 0.3).

| Property | Type | Default | Notes |
|----------|------|---------|-------|
| id | String | "" | |
| display_name | String | "" | |
| description | String | "" | Multiline |
| stat_weights | Dictionary | {} | Maps stat ID to multiplier |
| flat_bonus | float | 0.0 | Added after calculation |
| min_value | float | 0.0 | |
| max_value | float | 9999.0 | |
| icon | Texture2D | null | |
| custom_data | Dictionary | {} | |

**Methods:** `calculate(base_stats: Dictionary) -> float`

Directory: `rpg_data/rpg_derived_stat/`

---

## FKClass

Character class/job definition.

| Property | Type | Default | Notes |
|----------|------|---------|-------|
| id | String | "" | |
| display_name | String | "" | |
| description | String | "" | Multiline |
| icon | Texture2D | null | |
| base_stats | Dictionary | {} | Maps stat ID to starting value |
| stat_growth_per_level | Dictionary | {} | Maps stat ID to growth per level |
| equippable_types | Array[String] | [] | Equipment types this class can use |
| abilities_by_level | Dictionary | {} | Maps level (int) to ability path array |
| passive_skills | Array[Resource] | [] | FKPassiveSkill references |
| skill_tree | Resource | null | FKSkillTree reference |
| exp_curve | String enum | "Quadratic" | Linear, Quadratic, Cubic, Custom |
| base_exp | int | 100 | XP for level 2 |
| exp_scale | float | 1.5 | Scaling factor |
| max_level | int | 99 | |
| custom_data | Dictionary | {} | |

**Methods:** `get_exp_for_level(level: int) -> int`, `get_stats_at_level(level: int) -> Dictionary`

**Gotcha:** Use `get_char_class()` if you need to reference this type, not `get_class()`. Godot reserves `get_class()`.

Directory: `rpg_data/rpg_class/`

---

## FKEnemy

Enemy/monster definition.

| Property | Type | Default | Notes |
|----------|------|---------|-------|
| id | String | "" | |
| display_name | String | "" | |
| description | String | "" | Multiline |
| icon | Texture2D | null | Portrait |
| battle_sprite | Texture2D | null | In-combat visual |
| base_stats | Dictionary | {} | Maps stat ID to value |
| max_hp | int | 100 | |
| max_mp | int | 20 | |
| level | int | 1 | |
| abilities | Array[Resource] | [] | FKAbility references |
| ai_patterns | Array[Dictionary] | [] | See AI patterns below |
| weaknesses | Dictionary | {} | Element to multiplier |
| resistances | Dictionary | {} | Element to multiplier |
| status_immunities | Array[String] | [] | |
| can_flee | bool | false | |
| exp_reward | int | 10 | |
| gold_reward | int | 5 | |
| gold_variance | float | 0.2 | +/- percentage |
| loot_table | Resource | null | FKLootTable reference |
| guaranteed_drops | Array[Resource] | [] | FKItem references |
| enemy_tier | String enum | "Normal" | Normal, Elite, Mini Boss, Boss, Raid Boss |
| type_tags | Array[String] | [] | e.g., "undead", "beast" |
| is_boss | bool | false | |
| custom_data | Dictionary | {} | |

**AI pattern format:** `{"ability_index": 0, "weight": 50, "condition": "hp_above_50"}`

Built-in conditions: `always`, `hp_above_50`, `hp_below_50`, `hp_below_25`, `hp_full`. Unknown conditions default to true.

**Methods:** `select_ability(current_hp_percent: float) -> Resource`

Directory: `rpg_data/rpg_enemy/`

---

## FKItem

Items - weapons, armor, consumables, key items, etc.

| Property | Type | Default | Notes |
|----------|------|---------|-------|
| id | String | "" | |
| display_name | String | "" | |
| description | String | "" | Multiline |
| icon | Texture2D | null | |
| item_type | String enum | "Consumable" | Weapon, Armor, Accessory, Consumable, Material, Key Item, Currency |
| sub_type | String | "" | Free-form (e.g., "Sword", "Staff") |
| stat_modifiers | Dictionary | {} | Stat ID to bonus value when equipped |
| equipment_slot | String | "" | e.g., "main_hand", "body" |
| class_restrictions | Array[String] | [] | Empty = all classes |
| level_requirement | int | 0 | |
| use_effects | Dictionary | {} | Effect type to value |
| usable_in_battle | bool | false | |
| usable_in_field | bool | false | |
| consumable | bool | true | Consumed on use |
| cooldown_turns | int | 0 | |
| buy_price | int | 0 | |
| sell_price | int | 0 | |
| max_stack | int | 99 | 1 = not stackable |
| rarity | String enum | "Common" | Common, Uncommon, Rare, Epic, Legendary, Unique |
| sellable | bool | true | |
| droppable | bool | true | |
| tradeable | bool | true | |
| custom_data | Dictionary | {} | |

Directory: `rpg_data/rpg_item/`

---

## FKAbility

Active abilities and spells.

| Property | Type | Default | Notes |
|----------|------|---------|-------|
| id | String | "" | |
| display_name | String | "" | |
| description | String | "" | Multiline |
| icon | Texture2D | null | |
| ability_type | String enum | "Physical" | Physical, Magical, Hybrid, Healing, Buff, Debuff, Utility |
| target_type | String enum | "Single Enemy" | Single Enemy, All Enemies, Single Ally, All Allies, Self, Random Enemy, Random Ally, All |
| element | String | "None" | |
| mp_cost | int | 0 | |
| hp_cost | int | 0 | |
| tp_cost | int | 0 | |
| cooldown | int | 0 | Turns |
| uses_per_battle | int | -1 | -1 = unlimited |
| base_power | float | 0.0 | |
| scaling_stat | String | "" | Stat ID |
| scaling_multiplier | float | 1.0 | |
| variance | float | 0.1 | +/- percentage |
| crit_bonus | float | 0.0 | |
| hit_count | int | 1 | |
| status_effects | Array[Dictionary] | [] | `{"status": "poison", "chance": 0.5, "duration": 3}` |
| stat_modifiers | Array[Dictionary] | [] | `{"stat": "attack", "modifier": 0.25, "duration": 3}` |
| animation_name | String | "" | |
| sound_effect | AudioStream | null | |
| particle_effect | PackedScene | null | |
| level_requirement | int | 1 | |
| class_restrictions | Array[String] | [] | |
| custom_data | Dictionary | {} | |

**Methods:** `calculate_power(stats: Dictionary) -> float`

Directory: `rpg_data/rpg_ability/`

---

## FKPassiveSkill

Passive bonuses and traits.

| Property | Type | Default | Notes |
|----------|------|---------|-------|
| id | String | "" | |
| display_name | String | "" | |
| description | String | "" | Multiline |
| icon | Texture2D | null | |
| stat_bonuses | Dictionary | {} | Stat ID to flat bonus |
| stat_percent_bonuses | Dictionary | {} | Stat ID to percentage (0.1 = +10%) |
| element_resistances | Dictionary | {} | Element to resistance value |
| status_resistances | Dictionary | {} | Status to resistance chance (0-1) |
| special_flags | Array[String] | [] | e.g., "double_exp", "auto_revive" |
| activation_condition | String enum | "Always" | Always, In Battle, In Field, HP Below 25%, HP Full, Alone, Custom |
| custom_condition | String | "" | Used when activation_condition = "Custom" |
| level_requirement | int | 1 | |
| prerequisites | Array[String] | [] | Other passive IDs |
| max_rank | int | 1 | |
| custom_data | Dictionary | {} | |

Directory: `rpg_data/rpg_passive_skill/`

---

## FKSkillTree

Skill tree with unlockable nodes.

| Property | Type | Default | Notes |
|----------|------|---------|-------|
| id | String | "" | |
| display_name | String | "" | |
| description | String | "" | Multiline |
| icon | Texture2D | null | |
| nodes | Array[Dictionary] | [] | See node format below |
| tier_count | int | 5 | |
| points_per_tier | int | 5 | Points needed in lower tiers to unlock next |
| max_points | int | -1 | -1 = level-based |
| custom_data | Dictionary | {} | |

**Node format:** `{"id": "node_1", "name": "Power Strike I", "description": "...", "type": "passive" or "ability", "resource": FKPassiveSkill or FKAbility, "cost": 1, "max_rank": 3, "prerequisites": ["other_node_id"], "position": Vector2(0, 0), "tier": 1}`

**Methods:** `get_nodes_in_tier(tier: int) -> Array[Dictionary]`, `can_unlock_node(node_id, unlocked_nodes, available_points) -> bool`

Directory: `rpg_data/rpg_skill_tree/`

---

## FKLootTable

Weighted random item drops.

| Property | Type | Default | Notes |
|----------|------|---------|-------|
| id | String | "" | |
| display_name | String | "" | |
| entries | Array[Dictionary] | [] | See entry format below |
| roll_count | int | 1 | Rolls per drop event |
| allow_duplicates | bool | true | |
| guaranteed_drops | int | 0 | Picks top weighted entries |
| custom_data | Dictionary | {} | |

**Entry format:** `{"item": FKItem, "weight": 100, "min_quantity": 1, "max_quantity": 1, "drop_chance": 1.0}`

**Methods:** `roll() -> Array[Dictionary]` returns `[{"item": FKItem, "quantity": int}]`

Directory: `rpg_data/rpg_loot_table/`

---

## FKEncounterTable

Random encounter definitions for zones.

| Property | Type | Default | Notes |
|----------|------|---------|-------|
| id | String | "" | |
| display_name | String | "" | |
| entries | Array[Dictionary] | [] | See entry format below |
| base_steps | int | 30 | Steps between encounters |
| step_variance | float | 0.5 | 0.5 = 50%-150% of base |
| avoidable | bool | true | |
| max_enemies_per_battle | int | 4 | |
| min_player_level | int | -1 | -1 = always |
| max_player_level | int | -1 | -1 = no cap |
| custom_data | Dictionary | {} | |

**Entry format:** `{"enemies": [FKEnemy, FKEnemy], "weight": 100, "min_count": 1, "max_count": 3, "level_range": Vector2i(1, 5), "condition": ""}`

**Methods:** `roll_encounter() -> Dictionary`, `roll_steps() -> int`

Directory: `rpg_data/rpg_encounter_table/`

---

## FKZone

Game zone/area/map definition.

| Property | Type | Default | Notes |
|----------|------|---------|-------|
| id | String | "" | |
| display_name | String | "" | |
| description | String | "" | Multiline |
| icon | Texture2D | null | Map/thumbnail |
| zone_type | String enum | "Overworld" | Overworld, Town, Dungeon, Indoor, Battle Arena, Safe Zone, Custom |
| encounter_table | Resource | null | FKEncounterTable |
| has_encounters | bool | true | |
| connections | Array[Dictionary] | [] | `{"zone_id": "town_1", "direction": "north", "requirement": "", "position": Vector2(0, 0)}` |
| npcs | Array[Dictionary] | [] | `{"name": "Shopkeeper", "type": "shop", "dialogue": FKDialogue, "position": Vector2(0, 0)}` |
| points_of_interest | Array[Dictionary] | [] | `{"id": "chest_1", "type": "chest", "contents": FKLootTable, "position": Vector2(0, 0), "one_time": true}` |
| bgm | AudioStream | null | |
| ambiance | AudioStream | null | |
| bgm_volume | float | -1.0 | -1 = use default |
| recommended_level_min | int | 1 | |
| recommended_level_max | int | 99 | |
| allow_save | bool | true | |
| allow_teleport | bool | true | |
| scene_path | String | "" | Path to the zone's scene file |
| weather | String enum | "None" | None, Rain, Snow, Fog, Sandstorm, Custom |
| lighting | String enum | "Dynamic" | Day, Night, Dynamic, Always Dark, Always Bright |
| custom_data | Dictionary | {} | |

Directory: `rpg_data/rpg_zone/`

---

## FKDialogue

Dialogue tree with branching conversations.

| Property | Type | Default | Notes |
|----------|------|---------|-------|
| id | String | "" | |
| display_name | String | "" | |
| speaker_name | String | "" | |
| speaker_portrait | Texture2D | null | |
| nodes | Array[Dictionary] | [] | See node format below |
| local_variables | Dictionary | {} | Persist within this conversation |
| auto_advance | bool | false | |
| text_speed | float | 1.0 | |
| skippable | bool | true | |
| custom_data | Dictionary | {} | |

**Node format:** `{"id": "node_0", "type": "text"|"choice"|"condition"|"action"|"end", "speaker": "NPC", "portrait": Texture2D, "text": "Hello!", "choices": [{"text": "Option", "next": "node_2", "condition": ""}], "next": "node_1", "condition": "has_item:key_1", "true_next": "node_3", "false_next": "node_4", "action": "give_item:potion", "emotion": "happy"}`

**Methods:** `get_start_node() -> Dictionary`, `get_node_by_id(node_id) -> Dictionary`, `get_next_node(current_id) -> Dictionary`

Directory: `rpg_data/rpg_dialogue/`

---

## FKQuest

Quest/mission with objectives and rewards.

| Property | Type | Default | Notes |
|----------|------|---------|-------|
| id | String | "" | |
| display_name | String | "" | |
| summary | String | "" | Multiline, shown in quest log |
| description | String | "" | Multiline, full lore |
| icon | Texture2D | null | |
| quest_type | String enum | "Side Quest" | Main Story, Side Quest, Daily, Repeatable, Hidden, Tutorial |
| quest_chain | String | "" | Links quests in same chain |
| chain_order | int | 0 | Order within chain |
| level_requirement | int | 1 | |
| prerequisite_quests | Array[String] | [] | Quest IDs |
| required_items_to_start | Array[Dictionary] | [] | |
| class_restrictions | Array[String] | [] | |
| objectives | Array[Dictionary] | [] | See format in quest guide |
| exp_reward | int | 0 | |
| gold_reward | int | 0 | |
| item_rewards | Array[Dictionary] | [] | `{"item": FKItem, "quantity": int}` |
| ability_rewards | Array[Resource] | [] | FKAbility references |
| unlocks_quest | String | "" | Next quest ID in chain |
| bonus_exp | int | 0 | For optional objectives |
| bonus_gold | int | 0 | |
| bonus_items | Array[Dictionary] | [] | |
| time_limit | float | 0.0 | Seconds, 0 = none |
| abandonable | bool | true | |
| repeatable | bool | false | |
| repeat_cooldown | float | 0.0 | Seconds |
| fail_consequences | Dictionary | {} | |
| accept_dialogue | Resource | null | FKDialogue |
| complete_dialogue | Resource | null | FKDialogue |
| progress_dialogue | Resource | null | FKDialogue |
| custom_data | Dictionary | {} | |

**Methods:** `is_complete(progress: Dictionary) -> bool`, `is_fully_complete(progress: Dictionary) -> bool`

Directory: `rpg_data/rpg_quest/`

---

## FKSettings

Project-wide RPG configuration. One per project, generated by Setup tab.

| Property | Type | Default | Notes |
|----------|------|---------|-------|
| game_name | String | "My RPG" | |
| genre | String enum | "Classic JRPG" | Classic JRPG, Action RPG, Tactical RPG, Dungeon Crawler, Open World, Autobattler |
| base_stats | Array[String] | ["strength", "dexterity", ...] | 6 defaults |
| derived_stats | Dictionary | {} | Maps derived ID to weights/flat config |
| elements | Array[String] | ["Fire", "Ice", ...] | 5 defaults |
| element_chart | Dictionary | {} | Weakness relationships |
| equipment_slots | Array[String] | ["main_hand", "off_hand", ...] | 8 defaults |
| currency_name | String | "Gold" | |
| sell_ratio | float | 0.5 | |
| battle_type | String enum | "Turn-Based" | Turn-Based, Active Time Battle, Autobattle, Tactical Grid, Action Real-Time |
| party_size | int | 4 | |
| max_enemies | int | 4 | |
| exp_distribution | String enum | "Full to All" | Full to All, Split Evenly, Active Only |
| allow_flee | bool | true | |
| max_level | int | 99 | |
| custom_data | Dictionary | {} | |

Directory: `rpg_data/rpg_settings/`
