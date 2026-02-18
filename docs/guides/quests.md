# Setting Up a Quest Chain

Walk through creating a multi-part quest with objectives, prerequisites, and rewards.

## Prerequisites

- ForgeKit installed and active
- Quick Setup completed (or relevant `rpg_data/` directories exist)
- At least one FKEnemy, FKItem, and FKDialogue resource already created (Quick Setup provides these)

## Step 1: Plan the Chain

We will build a two-part quest:
1. "Rat Problem" - Kill 5 rats in the cellar. Reward: 50 gold, a health potion.
2. "The Rat King" - Defeat the Rat King boss. Requires completing "Rat Problem" first. Reward: 200 gold, a unique sword.

## Step 2: Create the First Quest

1. Open the ForgeKit dock, go to the Resources tab.
2. Under Quests, click "Create New."
3. A file dialog opens. Save as `rpg_data/rpg_quest/rat_problem.tres`.
4. The new resource opens in the Inspector.

Fill in the basics:
- **id**: `rat_problem`
- **display_name**: `Rat Problem`
- **summary**: `Clear the rats out of the tavern cellar.`
- **quest_type**: `Side Quest`

## Step 3: Add Objectives

Expand the `objectives` array and add one entry:

```
{
    "id": "kill_rats",
    "type": "kill",
    "description": "Defeat 5 rats in the cellar",
    "target": "rat",
    "count": 5,
    "optional": false,
    "hidden": false,
    "zone": "tavern_cellar"
}
```

The `target` value should match the `id` of your FKEnemy resource for rats. The `zone` is optional but useful if you want to restrict where the objective can be completed.

You can add multiple objectives to the array. For this quest, one is enough.

## Step 4: Set Rewards

- **exp_reward**: `100`
- **gold_reward**: `50`
- **item_rewards**: Add one entry - `{"item": <drag your health potion FKItem here>, "quantity": 2}`

For item_rewards, the `item` field expects an FKItem resource reference. You can drag it from the FileSystem dock into the Inspector field, or use the resource picker.

## Step 5: Attach Dialogue

If you have an FKDialogue for the quest giver, assign it:
- **accept_dialogue**: The conversation where the NPC offers the quest.
- **complete_dialogue**: The conversation when the player turns in the quest.
- **progress_dialogue**: What the NPC says if you talk to them mid-quest.

These are optional. If you are not using the dialogue system for quests, leave them empty.

## Step 6: Create the Second Quest

Create another resource: `rpg_data/rpg_quest/rat_king.tres`.

- **id**: `rat_king`
- **display_name**: `The Rat King`
- **summary**: `A giant rat rules the cellar depths. End its reign.`
- **quest_type**: `Side Quest`
- **quest_chain**: `rat_extermination` (any string - links quests in the same chain)
- **chain_order**: `1` (comes after the first quest, which has chain_order 0)
- **prerequisite_quests**: `["rat_problem"]`

The prerequisite array uses quest IDs. At runtime, your quest system checks if `rat_problem` is marked complete before making `rat_king` available.

Add an objective:

```
{
    "id": "kill_rat_king",
    "type": "kill",
    "description": "Defeat the Rat King",
    "target": "rat_king",
    "count": 1,
    "optional": false,
    "hidden": false,
    "zone": "tavern_cellar_depths"
}
```

Set rewards:
- **exp_reward**: `500`
- **gold_reward**: `200`
- **item_rewards**: `[{"item": <your unique sword resource>, "quantity": 1}]`

## Step 7: Add an Optional Objective

Want to reward thorough players? Add a second objective to the Rat King quest:

```
{
    "id": "find_cellar_key",
    "type": "collect",
    "description": "Find the old cellar key",
    "target": "cellar_key",
    "count": 1,
    "optional": true,
    "hidden": true,
    "zone": ""
}
```

Set `optional: true` so it is not required for completion, and `hidden: true` so it does not appear in the quest log until discovered.

Add bonus rewards:
- **bonus_exp**: `100`
- **bonus_gold**: `50`

These only trigger if the player completes the optional objective. The `is_fully_complete()` method on FKQuest checks both required and optional objectives.

## Expected Result

You now have two linked quests:
- `rat_problem.tres` - standalone, no prerequisites
- `rat_king.tres` - requires `rat_problem` completed, part of the `rat_extermination` chain

At runtime, use `FKQuest.is_complete(progress)` to check if the required objectives are done, where `progress` is a Dictionary mapping objective IDs to current counts.

```gdscript
var quest = FKDatabase.get_resource("FKQuest", "rat_problem")
var progress = {"kill_rats": 5}  # tracked by your game
if quest.is_complete(progress):
    # award rewards, mark quest done
    pass
```

## Common Mistakes

**Mismatched IDs.** The `target` in objectives must match the `id` field on the actual FKEnemy or FKItem resource. If your enemy's id is `giant_rat` but your objective says `rat_king`, nothing will connect.

**Forgetting chain_order.** If you set `quest_chain` on both quests but do not set `chain_order`, the system has no way to know which comes first. The first quest in a chain should be 0, the second 1, and so on.

**prerequisite_quests uses IDs, not display names.** A common mistake is putting "Rat Problem" instead of "rat_problem" in the prerequisites array.

**Array[Dictionary] serialization.** If you are creating quest objectives in code rather than the Inspector, remember the Godot serialization gotcha: build typed `Array[Dictionary]` using `.append()`, assign it after the resource is created, then re-save. See [Troubleshooting](../troubleshooting.md) for details.

**item_rewards resource references.** The `item` field in each reward entry should be an actual FKItem resource, not a string path. If you are building these in code, use `load("res://rpg_data/rpg_item/health_potion.tres")`.
