# Building a Dialogue Tree

Walk through creating a branching dialogue with the visual editor.

## Prerequisites

- ForgeKit installed and active
- Quick Setup completed (or at least the `rpg_data/rpg_dialogue/` directory exists)

## Step 1: Open the Dialogue Editor

1. Open the ForgeKit dock.
2. Go to the Resources tab.
3. Click "Open Dialogue Editor..."
4. A file dialog appears. You can pick an existing FKDialogue `.tres` file to edit, or create a new one.
5. To create new: navigate to `rpg_data/rpg_dialogue/`, type a filename like `blacksmith_intro.tres`, and click Save.

The visual graph editor opens.

## Step 2: Create the Opening Text Node

The editor starts with an empty graph. Right-click on the canvas and select "Add Text Node."

A text node appears. Fill in:
- **Speaker**: "Blacksmith"
- **Text**: "Need something repaired? Or are you here to browse?"

This is the first thing the player sees when they talk to this NPC.

## Step 3: Add a Choice Node

Right-click the canvas again and add a Choice Node. This gives the player options.

Add two choices:
- "I would like to browse your wares."
- "Can you repair my equipment?"

Position the choice node to the right of the text node. Drag a connection from the text node's output port to the choice node's input port.

A screenshot would be useful here to show the port connection visually.

## Step 4: Add Response Branches

Create two more text nodes, one for each choice:

**Browse response:**
- Speaker: "Blacksmith"
- Text: "Take a look. Everything on the wall is for sale."

**Repair response:**
- Speaker: "Blacksmith"
- Text: "Hand it over. This will cost you 50 gold."

Connect each choice output to its corresponding response node. The choice node has one output port per choice, in order from top to bottom.

## Step 5: Add a Condition Branch

Say you want the repair option to check if the player has enough gold. Add a Condition Node between the choice and the repair response.

Set the condition to: `has_gold:50`

The condition node has two outputs: true and false. Connect true to the repair text. For false, create another text node:
- Speaker: "Blacksmith"
- Text: "You do not have enough gold for that."

## Step 6: Add End Nodes

Every branch needs to terminate. Add End Nodes at the end of each conversation path and connect the final text nodes to them.

Your graph should look roughly like:

```
[Text: greeting] --> [Choice: browse/repair]
                          |            |
                     [Text: browse] [Condition: has_gold:50]
                          |            |           |
                       [End]    [Text: repair]  [Text: no gold]
                                     |              |
                                   [End]          [End]
```

## Step 7: Save

Click the Save button in the editor toolbar. The dialogue data is written back to the `.tres` file.

Close the editor when done. You can reopen it anytime from the Resources tab.

## What Gets Saved

The visual editor writes to the FKDialogue resource's `nodes` property - an `Array[Dictionary]`. Each dictionary represents one node in the graph with its type, text, connections, and position.

You can inspect the raw data by opening the `.tres` file in the Inspector. The `nodes` array is fully editable there too, though the visual editor is obviously easier for anything with branching.

## Expected Result

After saving, `rpg_data/rpg_dialogue/blacksmith_intro.tres` contains a complete dialogue tree. At runtime, you would load this with FKDatabase and walk through it using `get_start_node()`, `get_node_by_id()`, and `get_next_node()` on the FKDialogue resource.

The Advanced layer (when released) will include a dialogue player node that handles this automatically. With Core only, you write the playback code yourself.

## Common Mistakes

**Forgetting to connect an End node.** If a branch has no End node, the dialogue runner will not know when the conversation is over. Every path must terminate.

**Port indices vs slot indices.** When the editor connects nodes internally, it uses port indices (the nth enabled port), not slot indices. If you are debugging connection issues in the raw data, keep this in mind. See the [Troubleshooting](../troubleshooting.md) page.

**Condition string format.** Conditions use a simple `key:value` format. The Core layer stores these as strings but does not evaluate them - that is up to your runtime code or the Advanced dialogue player. Make sure your runtime can parse whatever format you put in there.

**Node positions not saving.** The editor uses `position_offset` on GraphNodes. If you are touching the graph programmatically, do not use `offset` or `position` - they are different properties and will not affect the visual editor's layout.
