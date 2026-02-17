# How to Use ForgeKit

This guide walks you through building an RPG using the ForgeKit plugin, step by step.

---

## Table of Contents

1. [Installation](#1-installation)
2. [Quick Setup (Recommended for Beginners)](#2-quick-setup-recommended-for-beginners)
3. [Setup Tab (Genre Presets & Configuration)](#3-setup-tab-genre-presets--configuration)
4. [Getting Started (Manual Setup)](#4-getting-started-manual-setup)
5. [Creating Stats](#5-creating-stats)
6. [Creating Classes](#6-creating-classes)
7. [Creating Items](#7-creating-items)
8. [Creating Abilities](#8-creating-abilities)
9. [Creating Passive Skills and Skill Trees](#9-creating-passive-skills-and-skill-trees)
10. [Creating Enemies](#10-creating-enemies)
11. [Creating Loot Tables](#11-creating-loot-tables)
12. [Creating Encounter Tables](#12-creating-encounter-tables)
13. [Creating Zones](#13-creating-zones)
14. [Creating Dialogues](#14-creating-dialogues)
15. [Using the Visual Dialogue Editor](#15-using-the-visual-dialogue-editor)
16. [Using the Visual Skill Tree Editor](#16-using-the-visual-skill-tree-editor)
17. [Using the Damage Formula Tester](#17-using-the-damage-formula-tester)
18. [Using Data Validation](#18-using-data-validation)
19. [Using Import / Export JSON](#19-using-import--export-json)
20. [Creating Quests](#20-creating-quests)
21. [Creating Scenes](#21-creating-scenes)
22. [Using the Scene Generator](#22-using-the-scene-generator)
23. [Using the Database Browser](#23-using-the-database-browser)
24. [Using Resources in Your Game Code](#24-using-resources-in-your-game-code)
25. [Using the Save System](#25-using-the-save-system)
26. [Tips and Best Practices](#26-tips-and-best-practices)

---

## 1. Installation

1. Copy the `addons/forge_kit/` folder into your Godot project
2. Open your project in Godot 4.2+
3. Go to **Project > Project Settings > Plugins**
4. Find **ForgeKit** in the list and click the **Enable** checkbox
5. You should see the **ForgeKit** dock appear on the right side of the editor

---

## 2. Quick Setup (Recommended for Beginners)

The fastest way to get started. The Quick Setup tab generates a complete starter RPG dataset (45 resources) with one click.

1. After enabling the plugin, find the **ForgeKit** dock on the right side
2. The first tab is **Quick Setup** and it should already be selected
3. Read the summary of what will be created (45 resources total)
4. Click the **"Run Quick Setup"** button
5. Watch the log as resources are created
6. When it says "Setup Complete!", switch to the **Database** tab and click **Refresh Database** to see everything

**What gets created:**

| Category | Resources |
|----------|-----------|
| Stats | Strength, Dexterity, Intelligence, Wisdom, Vitality, Luck |
| Derived Stats | Physical Attack, Magic Attack, Evasion, Heal Power |
| Abilities | Slash, Power Strike, Fireball, Ice Shard, Heal, Group Heal, Shield Bash, Poison Sting |
| Passive Skills | Iron Body, Keen Eye, Arcane Mind, Last Stand, Lucky Star |
| Skill Trees | Warrior Skill Tree (6 nodes, 3 tiers with passives, ability unlocks, milestone) |
| Classes | Warrior (with skill tree), Mage, Rogue (with full stat growth and equipment types) |
| Items | Potion, Ether, Antidote, Iron Sword, Wooden Staff, Iron Dagger, Leather Armor, Iron Shield |
| Enemies | Slime, Goblin, Skeleton, Dragon (boss) |
| Loot Tables | Common Drops, Boss Drops |
| Encounters | Forest Encounters |
| Zones | Emerald Forest |
| Dialogues | Village Elder Introduction (with branching choices) |
| Quests | Slime Slayer (kill, collect, and talk objectives) |

All resources are linked together. Enemies reference loot tables, encounter tables reference enemies, zones reference encounter tables, and quests reference dialogue. Click any resource in the Database tab to open it in the Inspector and see how it's configured.

**After Quick Setup, you can:**
- Edit any resource by clicking it in the Database tab
- Add new resources using the Resources tab
- Create scenes using the Scenes tab
- Use the Scene Generator for custom scene layouts

---

## 3. Setup Tab (Genre Presets & Configuration)

The **Setup** tab (second tab) lets you configure your RPG's core systems before diving into individual resources. It's the recommended second step after Quick Setup, or your starting point if you want full control.

### Step-by-Step

1. Click the **Setup** tab in the ForgeKit dock
2. **Game Profile** - Enter your game's name and select a genre preset
3. When you select a genre, all fields auto-fill with recommended values
4. Customize any section to match your vision:
   - **Base Stats** - Check/uncheck stats, or type a custom name and click "Add"
   - **Derived Stats** - Shown from the genre preset (editable in Inspector after saving)
   - **Elements** - Check/uncheck elements, or add custom ones
   - **Equipment Slots** - Check/uncheck slots, or add custom ones (use snake_case)
   - **Economy** - Set currency name (e.g., "Gold", "Credits") and sell ratio
   - **Battle System** - Choose battle type, party size, max enemies, EXP distribution, flee toggle, and max level
5. Click **Save Settings** to generate your configuration

### What "Save Settings" Creates

- An **FKSettings** resource at `res://rpg_data/rpg_settings/game_settings.tres` storing all your choices
- **FKStat** resources for each selected base stat (only creates new ones, won't overwrite existing)
- **FKDerivedStat** resources for each derived stat from the genre preset

### Available Genre Presets

| Genre           | Battle Type      | Party | Stats | Elements | Max Level |
|-----------------|------------------|-------|-------|----------|-----------|
| Classic JRPG    | Turn-Based       |   4   |   6   |    8     | 99 |
| Action RPG      | Action Real-Time |   1   |   5   |    4     | 99 |
| Tactical RPG    | Tactical Grid    |   6   |   7   |    6     | 50 |
| Dungeon Crawler | Turn-Based       |   5   |   6   |    5     | 99 |
| Open World      | Action Real-Time |   3   |   6   |    5     | 60 |
| Autobattler     | Autobattle       |   6   |   5   |    6     | 30 |

**Tip:** Genre presets are just starting points. Every field can be changed after selection. You can even switch genres multiple times before saving.

---

## 4. Getting Started (Manual Setup)

If you prefer to build everything from scratch, the ForgeKit dock has five tabs:

- **Quick Setup** - One-click starter dataset (covered above)
- **Setup** - Genre presets and core game configuration (covered above)
- **Resources** - Create and browse RPG data resources
- **Scenes** - Generate pre-built scene templates
- **Database** - View all your RPG data in one place

**Recommended order for building your RPG manually:**

1. Define your **Stats** (the attributes your characters use)
2. Create **Abilities** (skills and spells)
3. Create **Passive Skills** (optional)
4. Build **Classes** (using the stats and abilities you defined)
5. Create **Items** (weapons, armor, consumables)
6. Create **Enemies** (using stats and abilities)
7. Set up **Loot Tables** (what enemies drop)
8. Set up **Encounter Tables** (what enemies appear where)
9. Create **Zones** (game areas that use encounter tables)
10. Write **Dialogues** (NPC conversations)
11. Design **Quests** (using all the above)
12. Generate **Scenes** (battle, overworld, menus)

---

## 5. Creating Stats

Stats are the foundation of your RPG. They define the attributes that characters and enemies use.

1. In the ForgeKit dock, click **New Stat**
2. Choose a save location (the default `res://rpg_data/rpg_stat/` is recommended)
3. Name the file (e.g., `strength.tres`)
4. In the Inspector, fill in:
   - **Id**: `strength` (used in code to reference this stat)
   - **Display Name**: `Strength`
   - **Description**: `Physical power. Affects melee damage.`
   - **Min Value**: `1`
   - **Max Value**: `999`
   - **Default Value**: `10`

**Common stats to create:**
- Strength, Dexterity, Intelligence, Wisdom, Vitality, Luck
- You can also create Derived Stats like Evasion, Critical Rate, Magic Defense

**For Derived Stats:**
1. Click **New DerivedStat**
2. Set the **Stat Weights** dictionary. For example, for Evasion:
   - Key: `dexterity`, Value: `0.5`
   - Key: `luck`, Value: `0.3`
3. This means `Evasion = Dexterity * 0.5 + Luck * 0.3 + flat_bonus`

---

## 6. Creating Classes

Classes define character archetypes like Warrior, Mage, or Rogue.

1. Click **New Class** in the dock
2. Fill in the basic info (id, display name, description)
3. Set **Base Stats** as a Dictionary mapping stat IDs to starting values:
   - Example: `{"strength": 15, "dexterity": 10, "intelligence": 5}`
4. Set **Stat Growth Per Level** to control how much each stat increases per level:
   - Example: `{"strength": 3, "dexterity": 2, "intelligence": 1}`
5. Set **Equippable Types** for what gear this class can use:
   - Example: `["sword", "shield", "heavy_armor"]`
6. Set **Abilities By Level** as a Dictionary mapping levels to ability paths:
   - Example: `{1: ["res://rpg_data/rpg_ability/slash.tres"], 5: ["res://rpg_data/rpg_ability/power_strike.tres"]}`
7. Configure the **EXP curve** (Linear, Quadratic, or Cubic)

---

## 7. Creating Items

Items cover everything: weapons, armor, potions, key items, and more.

1. Click **New Item** in the dock
2. Choose the **Item Type**: Weapon, Armor, Accessory, Consumable, Material, Key Item, or Currency
3. For **Equipment** (Weapon/Armor/Accessory):
   - Set **Equipment Slot**: `main_hand`, `off_hand`, `head`, `body`, `legs`, `feet`, `ring`, or `necklace`
   - Set **Stat Modifiers**: `{"strength": 5, "dexterity": 2}`
   - Set **Class Restrictions** if only certain classes can equip it
   - Set **Level Requirement**
4. For **Consumables**:
   - Set **Use Effects**: `{"heal_hp": 50}` or `{"cure_poison": true}`
   - Toggle **Usable In Battle** and **Usable In Field**
   - Set **Consumable** to `true` if it's used up
5. Set **economy values** (buy price, sell price, rarity)

---

## 8. Creating Abilities

Abilities are active skills used in combat.

1. Click **New Ability** in the dock
2. Set the **Ability Type**: Physical, Magical, Hybrid, Healing, Buff, Debuff, or Utility
3. Set **Target Type**: Single Enemy, All Enemies, Single Ally, All Allies, Self, etc.
4. Set **Element** if applicable (Fire, Ice, Lightning, etc.)
5. Configure **costs**: MP Cost, HP Cost, TP Cost, Cooldown
6. Set **damage/healing**: Base Power, Scaling Stat (e.g., `strength`), Scaling Multiplier
7. Add **Status Effects** if the ability inflicts conditions:
   - Example: `[{"status": "poison", "chance": 0.5, "duration": 3}]`
8. Set animation and sound if desired

---

## 9. Creating Passive Skills and Skill Trees

**Passive Skills** provide permanent or conditional bonuses:

1. Click **New PassiveSkill**
2. Set **Stat Bonuses**: `{"strength": 5}` for flat bonuses
3. Set **Stat Percent Bonuses**: `{"attack": 0.1}` for +10% attack
4. Set **Activation Condition**: Always, In Battle, HP Below 25%, etc.

**Skill Trees** organize abilities and passives into unlockable trees:

> **Tip:** For a much easier experience, use the **Visual Skill Tree Editor** (see [Section 16](#16-using-the-visual-skill-tree-editor)) to build skill trees with drag-and-drop instead of editing dictionaries manually.

1. Click **New SkillTree**
2. Add **nodes** to the `nodes` array. Each node is a Dictionary:
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
3. Set **Points Per Tier** to control progression gating
4. Connect nodes using the `prerequisites` array

---

## 10. Creating Enemies

1. Click **New Enemy** in the dock
2. Set basic info and **Battle Sprite**
3. Set **Base Stats**: `{"strength": 8, "dexterity": 5, "intelligence": 3}`
4. Set **Max HP**, **Max MP**, and **Level**
5. Add **Abilities** the enemy can use
6. Configure **AI Patterns** for smart ability selection:
   ```
   [
	 {"ability_index": 0, "weight": 50, "condition": "hp_above_50"},
	 {"ability_index": 1, "weight": 80, "condition": "hp_below_25"}
   ]
   ```
   This means: use ability 0 normally, but prefer ability 1 when low HP
7. Set **Weaknesses** and **Resistances**: `{"fire": 2.0}` means double fire damage
8. Set **EXP Reward**, **Gold Reward**, and assign a **Loot Table**
9. Set **Enemy Tier**: Normal, Elite, Mini Boss, Boss, or Raid Boss

---

## 11. Creating Loot Tables

Loot tables control what items enemies drop.

1. Click **New LootTable**
2. Add entries to the **entries** array:
   ```
   {
	 "item": <drag an FKItem resource here>,
	 "weight": 100,
	 "min_quantity": 1,
	 "max_quantity": 3,
	 "drop_chance": 0.5
   }
   ```
   - **weight**: Higher = more likely to be picked (relative to other entries)
   - **drop_chance**: Absolute chance (0-1) applied after weight selection
3. Set **Roll Count** for how many times to roll per drop event
4. Set **Guaranteed Drops** for the minimum items that always drop
5. Toggle **Allow Duplicates**

---

## 12. Creating Encounter Tables

Encounter tables define what enemies appear in a zone.

1. Click **New EncounterTable**
2. Add entries to the **entries** array:
   ```
   {
	 "enemies": [<FKEnemy resource>],
	 "weight": 100,
	 "min_count": 1,
	 "max_count": 3
   }
   ```
3. Set **Base Steps** for the average steps between encounters (e.g., 30)
4. Set **Step Variance** for randomization (0.5 = encounters happen between 15-45 steps)
5. Set **Max Enemies Per Battle**

---

## 13. Creating Zones

Zones represent game areas like towns, dungeons, and the overworld.

1. Click **New Zone**
2. Set **Zone Type**: Overworld, Town, Dungeon, Indoor, Battle Arena, Safe Zone
3. Assign an **Encounter Table** for random battles
4. Add **Connections** to other zones:
   ```
   {"zone_id": "forest_1", "direction": "north", "requirement": "has_key"}
   ```
5. Add **NPCs**:
   ```
   {"name": "Shopkeeper", "type": "shop", "position": Vector2(100, 200)}
   ```
6. Add **Points of Interest** (chests, switches)
7. Set **BGM** (background music) and weather/lighting

---

## 14. Creating Dialogues

Dialogues are branching conversation trees.

1. Click **New Dialogue**
2. Set **Speaker Name** and **Speaker Portrait**
3. Add nodes to the **nodes** array. Each node is one of these types:

**Text node** (shows text, advances to next):
```
{"id": "node_0", "type": "text", "speaker": "Elder", "text": "Welcome, hero!", "next": "node_1"}
```

**Choice node** (presents options to the player):
```
{
  "id": "node_1", "type": "choice", "text": "How can I help?",
  "choices": [
	{"text": "Tell me about the quest", "next": "node_2"},
	{"text": "Nevermind", "next": "node_end"}
  ]
}
```

**Condition node** (branches based on game state):
```
{"id": "node_3", "type": "condition", "condition": "has_item:old_key", "true_next": "node_4", "false_next": "node_5"}
```

**Action node** (triggers a game action):
```
{"id": "node_4", "type": "action", "action": "give_item:potion", "next": "node_5"}
```

**End node** (ends the conversation):
```
{"id": "node_end", "type": "end"}
```

---

## 15. Using the Visual Dialogue Editor

The Visual Dialogue Editor lets you build and edit dialogue trees using a drag-and-drop node graph. No manual dictionary editing needed.

### Opening the Editor

1. In the ForgeKit dock, go to the **Resources** tab
2. Scroll to **Visual Editors** at the bottom
3. Click **"Open Dialogue Editor..."**
4. Select an existing dialogue `.tres` file (e.g., `elder_intro.tres` from Quick Setup)
5. The editor opens in a large popup window with your dialogue tree displayed as connected nodes

### Node Types

The editor has 5 node types, each with a distinct color:

| Node | Color | Purpose | Ports |
|------|-------|---------|-------|
| **Text** | Blue | Shows dialogue text with speaker and emotion | 1 input, 1 output |
| **Choice** | Gold | Presents player choices, each with its own connection | 1 input, 1 output per choice |
| **Condition** | Purple | Branches based on a game condition | 1 input, True + False outputs |
| **Action** | Green | Triggers a game action (give item, set flag, etc.) | 1 input, 1 output |
| **End** | Red | Ends the conversation | 1 input only |

### Adding Nodes

- **Toolbar buttons**: Click **+ Text**, **+ Choice**, **+ Condition**, **+ Action**, or **+ End** to add a node at the center of the canvas
- **Right-click**: Right-click on empty space to open a context menu with all node types. The node appears at your click position.

### Connecting Nodes

1. Click and drag from an **output port** (right side of a node) to an **input port** (left side of another node)
2. A connection line appears linking the two nodes
3. Each output port connects to **one** target. Dragging a new connection replaces the old one.
4. To **disconnect**: Right-click drag from a connected port, or select the connection and press Delete

### Editing Node Content

All fields are editable directly inside each node:

- **Text nodes**: Edit the speaker name, dialogue text (multi-line), and emotion tag
- **Choice nodes**: Edit the prompt text and each choice's label. Click **"+ Add Choice"** to add more options, or **"x"** to remove one
- **Condition nodes**: Type the condition expression (e.g., `has_item:key`, `quest_complete:slime_slayer`)
- **Action nodes**: Type the action to perform (e.g., `give_item:potion`, `set_flag:met_elder`)

### Saving

1. Click the **Save** button in the toolbar
2. All node positions, text content, and connections are saved back into the dialogue resource
3. The resource file is updated on disk. You can verify by opening it in the Inspector.

### Auto Layout

- Click **Auto Layout** to automatically arrange all nodes in a left-to-right tree
- Useful for dialogues imported from the Inspector or when nodes get messy
- Node positions are saved, so the layout persists between sessions

### Tips

- Start with a Text node. Most dialogues begin with an NPC greeting.
- Make sure all paths lead to an End node (or loop back).
- Use Condition nodes for branching based on player progress.
- Use Action nodes to give rewards, set flags, or trigger events mid-conversation.
- Each choice in a Choice node has an optional condition field to show/hide that option based on game state.

---

## 16. Using the Visual Skill Tree Editor

The Visual Skill Tree Editor lets you build and edit skill trees using a drag-and-drop node graph. Much easier than editing dictionary arrays in the Inspector.

### Opening the Editor

1. In the ForgeKit dock, go to the **Resources** tab
2. Scroll to **Visual Editors** at the bottom
3. Click **"Open Skill Tree Editor..."**
4. Select an existing skill tree `.tres` file
5. The editor opens in a large popup window with your skill tree displayed as connected nodes

### Node Types

The editor has 3 node types, each with a distinct color:

| Node | Color | Purpose |
|------|-------|---------|
| **Passive Skill** | Teal | Represents an FKPassiveSkill unlock in the tree |
| **Ability Unlock** | Orange | Represents an FKAbility unlock in the tree |
| **Milestone** | Gold | A gate/checkpoint that must be unlocked to progress past a tier |

### Node Fields

Each node has the following editable fields:

- **Name** - Display name of the skill node
- **Skill/Ability** - Resource path to the FKPassiveSkill or FKAbility resource (Passive and Ability nodes only)
- **Cost** - Skill points required to unlock
- **Max Rank** - How many times this node can be ranked up
- **Tier** - Which tier/row this node belongs to (used for auto-layout and tier gating)
- **Description** - Description text for the node

### Connections (Prerequisites)

Connections represent **prerequisite relationships**:
- Drag from a node's **output port** (right side) to another node's **input port** (left side)
- This means "the source node must be unlocked before the target node"
- A node can have **multiple prerequisites** (multiple incoming connections)
- A node can be a prerequisite for **multiple other nodes** (multiple outgoing connections)

### Toolbar

- **Save** - Saves all nodes, connections, positions, and tree settings back to the resource
- **+ Passive / + Ability / + Milestone** - Add new nodes at the center of the canvas
- **Auto Layout** - Arranges nodes by tier (left-to-right columns)
- **Tiers** - Set the total number of tiers in the tree
- **Pts/Tier** - Minimum skill points spent in previous tiers to unlock the next tier

### Tips

- Use tiers for progression. Place early/basic skills at tier 0, intermediate at tier 1-2, and powerful skills at higher tiers.
- Use Milestone nodes to create clear progression checkpoints.
- Hit Auto Layout after adding many nodes to keep things organized.
- Right-click on empty space to add nodes at a specific position.

---

## 17. Using the Damage Formula Tester

The Damage Formula Tester lets you test and tune ability damage calculations in real-time. See how damage scales with stats, defense, and element modifiers.

### Opening the Tester

1. In the ForgeKit dock, go to the **Resources** tab
2. Scroll to **Visual Editors** at the bottom
3. Click **"Damage Formula Tester..."**
4. The tester opens as a popup with three columns and a results section

### Layout

The tester has three columns:

**Ability Settings (left column):**
- Base Power - The base damage value
- Scaling Stat - Which attacker stat scales the ability
- Scale Multiplier - How much the scaling stat contributes
- Variance - Random damage variance (0.1 = +/- 10%)
- Crit Bonus - Additional crit multiplier above the base 1.5x
- Hit Count - Number of hits per ability use

**Attacker Stats (middle column):**
- A SpinBox for each stat defined in your project (auto-loaded from `rpg_data/rpg_stat/`)
- Adjust these to simulate different character builds

**Defender Stats (right column):**
- Defense - The defender's defense value
- Element Modifier - 1.0 = neutral, 2.0 = double damage (weakness), 0.5 = half damage (resistance), 0.0 = immune

### The Damage Formula

The tester uses a standard RPG damage formula:

1. **Raw Power** = Base Power + (Stat Value x Scale Multiplier)
2. **After Defense** = Raw Power x (100 / (100 + Defense))
3. **After Element** = After Defense x Element Modifier
4. **Min Damage** = After Element x (1 - Variance)
5. **Max Damage** = After Element x (1 + Variance)
6. **Crit Damage** = Max Damage x (1.5 + Crit Bonus)

### Loading from Resources

- **Load from Ability** - Click to pick any FKAbility `.tres` file. Auto-fills base power, scaling stat, multiplier, variance, crit bonus, and hit count.
- **Load from Enemy** - Click to pick any FKEnemy `.tres` file. Auto-fills defense value and element modifiers from the enemy's stats.

### Tips

- Adjust attacker stats to see how different character builds affect damage.
- Test your abilities against low-defense and high-defense enemies to make sure the damage ranges feel right.
- Play with the scaling multiplier to find the right stat contribution.

---

## 18. Using Data Validation

The Data Validator scans all your ForgeKit resources and reports errors, warnings, and balance issues. Catch problems before they cause runtime bugs.

### Opening the Validator

1. In the ForgeKit dock, go to the **Database** tab
2. Click **"Validate All Resources"**
3. In the popup, click **"Run Validation"**
4. Review the color-coded results

### What Gets Checked

The validator runs 6 categories of checks:

**1. Missing Required Fields**
- Every resource must have a non-empty `id`
- Resources with empty `display_name` trigger a warning

**2. Duplicate IDs**
- Flags any two resources of the same type that share the same ID

**3. Broken Resource References**
- Checks all resource-typed fields: enemy loot tables, enemy abilities, class skill trees, class passive skills, zone encounter tables, quest dialogues, quest ability rewards, loot table items, encounter table enemies
- Flags null references and resources with no saved path

**4. Broken String ID References**
- Skill tree node prerequisites must reference existing node IDs
- Quest prerequisites must reference existing quest IDs
- Zone connections must reference existing zone IDs

**5. Empty Collections**
- Loot tables with no entries
- Encounter tables with no entries
- Skill trees with no nodes
- Dialogues with no nodes
- Classes with no base stats

**6. Balance Warnings**
- Enemies with 0 EXP or 0 gold reward
- Items with a buy price but 0 sell price, or sell price exceeding buy price
- Physical/Magical/Hybrid abilities with 0 base power
- Abilities with no cost (MP, HP, and TP all 0)

### Output

- **Red** = Error (likely to cause problems)
- **Yellow** = Warning (may be intentional but worth checking)
- **Cyan** = Section headers
- Click **"Copy Results"** to copy the full report as plain text to your clipboard

---

## 19. Using Import / Export JSON

The Import/Export tool lets you save all your ForgeKit resources as a JSON file and import them back. Useful for backups, sharing, and bulk editing.

### Opening the Tool

1. In the ForgeKit dock, go to the **Database** tab
2. Click **"Import / Export JSON"**

### Exporting

1. Select a resource type from the dropdown (or leave as "All Types" to export everything)
2. Click **"Export to JSON..."**
3. Choose where to save the `.json` file
4. All matching resources are serialized and saved

**What gets exported:**
- All `@export` properties from each resource
- Resource references are stored as file paths (e.g., `{"_resource_path": "res://rpg_data/rpg_item/potion.tres"}`)
- Vector2, Vector2i, and Color values are stored as readable dictionaries
- Each entry includes a `_type` field identifying the resource type

### Importing

1. Click **"Import from JSON..."**
2. Select a previously exported `.json` file
3. Resources are recreated as `.tres` files in the appropriate `rpg_data/` subdirectories
4. The log shows each imported resource and any errors

**Import behavior:**
- Resources are saved to `res://rpg_data/{type_snake_case}/{id}.tres`
- Existing files with the same name are overwritten
- Resource path references are resolved back to actual resource files (the referenced files must already exist)
- Directories are created automatically if they don't exist

### Use Cases

- **Backups** - Export all resources before making major changes
- **Sharing** - Send your game data to collaborators as a single JSON file
- **Bulk editing** - Export to JSON, edit in a text editor or spreadsheet tool, then import back
- **Migration** - Move resources between projects

---

## 20. Creating Quests

Quests tie all your RPG elements together.

1. Click **New Quest**
2. Set **Quest Type**: Main Story, Side Quest, Daily, Repeatable, Hidden, Tutorial
3. Set **Prerequisites** for quests that must be done first
4. Add **Objectives**:
   ```
   [
	 {"id": "obj_1", "type": "kill", "description": "Defeat 5 Slimes", "target": "slime", "count": 5},
	 {"id": "obj_2", "type": "collect", "description": "Gather 3 Herbs", "target": "herb", "count": 3},
	 {"id": "obj_3", "type": "talk", "description": "Return to Elder", "target": "elder", "count": 1}
   ]
   ```
5. Set **Rewards**: EXP, Gold, Items, Abilities unlocked
6. Link **Accept Dialogue**, **Progress Dialogue**, and **Complete Dialogue**
7. Set **Quest Chain** and **Chain Order** if this is part of a series

---

## 21. Creating Scenes

The Scenes tab provides 9 pre-built scene templates. Click any button to generate a scene:

1. Click the desired scene template button (e.g., "Create Battle Scene")
2. Choose where to save the `.tscn` file
3. The scene opens automatically in the editor
4. Customize the node tree, add your art and scripts

**What each template includes:**

- **Battle Scene**: Enemy/party areas, command buttons, status display, battle log
- **Overworld Scene**: Camera, TileMap placeholder, spawn points, NPC/interactable containers, HUD
- **Title Screen**: Title label, menu buttons (New Game, Continue, Options, Quit)
- **Dialogue Scene**: Dialogue panel, speaker name, text area, choice container, portrait
- **Shop Scene**: Shop/inventory split, buy/sell buttons, gold display
- **Inventory Screen**: Category tabs, item list, detail panel with use/equip/drop
- **Party Menu**: Menu sidebar, 4-member party display with portraits and stats
- **Save/Load Screen**: 10 save slots with save/load toggle

---

## 22. Using the Scene Generator

For custom scenes beyond the templates:

1. Click **Open Scene Generator...** in the Scenes tab
2. Enter a **Scene Name**
3. Choose a **Scene Type** from 13 options
4. Choose **2D or 3D** rendering
5. Toggle optional components (Camera, HUD, Music, Transitions)
6. Click **Generate Scene**
7. The scene is saved to `res://scenes/` and opens automatically

---

## 23. Using the Database Browser

The Database tab shows all RPG resources in your project:

1. Click the **Database** tab in the dock
2. Click **Refresh Database**
3. All resources are listed by category
4. Click any resource name to open it in the Inspector
5. Use this to quickly browse and edit your game data

The Database tab also includes two tools:
- **Validate All Resources** - Scan for errors, broken references, and balance issues (see [Section 18](#18-using-data-validation))
- **Import / Export JSON** - Export and import resources as JSON files (see [Section 19](#19-using-import--export-json))

---

## 24. Using Resources in Your Game Code

### Loading the Database

```gdscript
var db := FKDatabase.new()

# Load a specific resource
var warrior_class: FKClass = db.get_class("warrior")
var fire_spell: FKAbility = db.get_ability("fireball")
var slime: FKEnemy = db.get_enemy("slime")

# Load all resources of a type
var all_items: Array[Resource] = db.get_all_items()
var all_quests: Array[Resource] = db.get_all_quests()

# Get a database summary
var summary: Dictionary = db.get_summary()
# Returns: {"FKStat": 6, "FKClass": 4, "FKEnemy": 12, ...}
```

### Using Stats and Classes

```gdscript
# Get a class's stats at level 10
var warrior := db.get_class("warrior")
var stats: Dictionary = warrior.get_stats_at_level(10)
# stats = {"strength": 42, "dexterity": 28, ...}

# Calculate EXP needed for next level
var exp_needed: int = warrior.get_exp_for_level(11)
```

### Using Abilities

```gdscript
var fireball := db.get_ability("fireball")
var player_stats := {"intelligence": 25, "wisdom": 15}
var damage: float = fireball.calculate_power(player_stats)
```

### Using Derived Stats

```gdscript
var evasion_stat: FKDerivedStat = db.get_resource("FKDerivedStat", "evasion") as FKDerivedStat
var base_stats := {"dexterity": 20, "luck": 10}
var evasion: float = evasion_stat.calculate(base_stats)
```

### Rolling Loot Tables

```gdscript
var loot_table: FKLootTable = db.get_resource("FKLootTable", "slime_drops") as FKLootTable
var drops: Array[Dictionary] = loot_table.roll()
for drop in drops:
    var item: FKItem = drop["item"]
    var qty: int = drop["quantity"]
    print("Dropped: %s x%d" % [item.display_name, qty])
```

### Rolling Encounters

```gdscript
var encounter_table: FKEncounterTable = db.get_resource("FKEncounterTable", "forest_encounters") as FKEncounterTable
var steps_until_encounter: int = encounter_table.roll_steps()
var encounter: Dictionary = encounter_table.roll_encounter()
var enemies: Array = encounter["enemies"]
var count: int = encounter["count"]
```

### Enemy AI

```gdscript
var enemy := db.get_enemy("goblin")
var hp_percent := float(current_hp) / float(enemy.max_hp)
var chosen_ability: FKAbility = enemy.select_ability(hp_percent)
```

### Dialogues

```gdscript
var dialogue := db.get_dialogue("elder_intro")
var current_node: Dictionary = dialogue.get_start_node()

# Advance through dialogue
var next_node: Dictionary = dialogue.get_next_node(current_node["id"])

# Handle choices
if current_node["type"] == "choice":
    var choices: Array = current_node["choices"]
    # Present choices to player, get selection, then:
    var selected_next: String = choices[player_choice]["next"]
    current_node = dialogue.get_node_by_id(selected_next)
```

### Quest Progress

```gdscript
var quest := db.get_quest("slay_slimes")
var progress := {"obj_1": 3, "obj_2": 2, "obj_3": 0}  # player's current progress

if quest.is_complete(progress):
	print("Quest complete! Awarding %d EXP and %d Gold" % [quest.exp_reward, quest.gold_reward])
```

---

## 25. Using the Save System

```gdscript
# Save game
var save_data := {
	"player_name": "Hero",
	"level": 15,
	"playtime": 3600,
	"hp": 250,
	"mp": 80,
	"inventory": ["potion", "sword_1", "shield_1"],
	"quest_progress": {"slay_slimes": {"obj_1": 5}},
	"current_zone": "forest_1",
	"position": {"x": 100, "y": 200}
}
FKSaveSystem.save_game(1, save_data)  # Save to slot 1

# Load game
var loaded: Dictionary = FKSaveSystem.load_game(1)
if not loaded.is_empty():
	var player_name: String = loaded["player_name"]
	var level: int = loaded["level"]

# Check slots
var used: Array[int] = FKSaveSystem.get_used_slots()
var info: Dictionary = FKSaveSystem.get_slot_info(1)
# info = {"save_time": "2025-01-15T10:30:00", "player_name": "Hero", "level": 15, ...}

# Delete a save
FKSaveSystem.delete_slot(1)
```

---

## 26. Tips and Best Practices

1. **Use consistent IDs.** Use snake_case for all resource IDs (e.g., `fire_sword`, `heal_spell`, `forest_zone`). These IDs are how you reference resources in code and in other resources.

2. **Start small.** Create a few stats, one class, a couple enemies, and a handful of items first. Test your systems before scaling up.

3. **Use the default directories.** The toolkit organizes resources into `res://rpg_data/` subdirectories. Stick with this structure for the Database browser to work properly.

4. **Reference resources, not paths.** When linking resources (e.g., abilities in a class, loot tables on an enemy), drag the `.tres` file into the Inspector field rather than typing paths.

5. **Test loot tables.** Before deploying, create a test script that calls `loot_table.roll()` many times to verify drop rates feel right.

6. **Back up your data.** Since all data is `.tres` files, they work great with Git. Commit your `rpg_data/` folder regularly.

7. **Use the Database tab.** Hit **Refresh Database** frequently to get an overview of all your game data. It helps catch missing or orphaned resources.

8. **Scene templates are starting points.** The generated scenes give you a node structure. You still need to add your own art, scripts, and gameplay logic.

9. **Keep related resources linked.** Assign a loot table to every enemy, connect dialogues to quests, and link zones to encounter tables. This creates a complete, connected game database.

10. **Build incrementally.** Start with the title screen and one playable zone. Get the basic gameplay loop working, then expand.
