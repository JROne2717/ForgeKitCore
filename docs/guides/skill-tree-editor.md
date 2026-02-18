# Visual Skill Tree Editor

The skill tree editor provides a node-graph interface for building and editing FKSkillTree resources. It is significantly easier than editing the `nodes` Dictionary array in the Inspector.

## Opening the Editor

1. Open the ForgeKit dock and go to the Resources tab.
2. Scroll to "Visual Editors" at the bottom.
3. Click "Open Skill Tree Editor..."
4. Select an existing FKSkillTree `.tres` file, or create a new one by navigating to `rpg_data/rpg_skill_tree/`, typing a filename, and clicking Save.

The editor opens in a popup window with your skill tree displayed as connected nodes on a canvas.

## Node Types

The editor supports three node types, each with a distinct color:

| Node | Color | Purpose |
|------|-------|---------|
| Passive Skill | Teal | Represents an FKPassiveSkill unlock |
| Ability Unlock | Orange | Represents an FKAbility unlock |
| Milestone | Gold | A gate/checkpoint that must be unlocked to progress past a tier |

## Adding Nodes

- **Toolbar buttons**: Click "+ Passive", "+ Ability", or "+ Milestone" to add a node at the center of the canvas.
- **Right-click**: Right-click on empty space to open a context menu with all node types. The node appears at the click position.

## Editing Nodes

Each node has the following fields, editable directly inside the node:

- **Name** - Display name of the skill node.
- **Skill/Ability** - Resource path to the FKPassiveSkill or FKAbility resource (not available on Milestone nodes).
- **Cost** - Skill points required to unlock.
- **Max Rank** - How many times this node can be ranked up.
- **Tier** - Which tier/row this node belongs to. Used for auto-layout and tier gating.
- **Description** - Tooltip or description text.

## Connections (Prerequisites)

Connections define prerequisite relationships between nodes.

1. Drag from a node's output port (right side) to another node's input port (left side).
2. This means the source node must be unlocked before the target node becomes available.
3. A node can have multiple prerequisites (multiple incoming connections).
4. A node can be a prerequisite for multiple other nodes (multiple outgoing connections).

To disconnect: right-click drag from a connected port, or select the connection and press Delete.

## Tree Settings

The toolbar includes two tree-level settings:

- **Tiers** - Total number of tiers in the tree.
- **Pts/Tier** - Minimum skill points that must be spent in previous tiers before the next tier unlocks.

These map to the `tier_count` and `points_per_tier` properties on the FKSkillTree resource.

## Auto Layout

Click "Auto Layout" to arrange all nodes by tier in left-to-right columns. This is useful after adding many nodes or when the layout gets cluttered. Node positions are saved, so the layout persists between sessions.

## Saving

Click "Save" in the toolbar. All node positions, text content, connections, and tree settings are written back to the FKSkillTree resource on disk.

You can verify the saved data by opening the `.tres` file in the Inspector. The `nodes` array contains one Dictionary per node with all the data from the visual editor.

## Assigning the Skill Tree to a Class

After saving, assign the skill tree to an FKClass resource:

1. Open the class resource in the Inspector.
2. Drag the skill tree `.tres` file into the `skill_tree` field.

At runtime, the class references the skill tree, and you can use `FKSkillTree.can_unlock_node(node_id, unlocked_nodes, available_points)` to check if a player can unlock a specific node.

## Tips

- Place basic skills at tier 0, intermediate at tiers 1-2, and powerful skills at higher tiers.
- Use Milestone nodes to create clear progression checkpoints that players must unlock before reaching the next tier.
- The `cost` field on each node is separate from the tier gating. A player needs both enough unspent points for the node cost and enough total points spent in previous tiers to access the tier.
- Hit Auto Layout after reorganizing to keep things readable.

## Common Issues

**Connections go to the wrong port.** GraphEdit uses port indices (the nth enabled port), not slot indices. If you are debugging connection data in the raw `.tres` file, count only enabled ports. The visual editor handles this correctly during normal use.

**Node positions not persisting.** The editor uses `position_offset` on GraphNode. If you are touching graph data programmatically, do not use `offset` or `position`. See [Troubleshooting](../troubleshooting.md).
