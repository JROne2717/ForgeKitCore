@tool
class_name FKSkillTree
extends Resource
## Defines a skill tree with nodes that can be unlocked with skill points.

## Unique identifier.
@export var id: String = ""
## Display name.
@export var display_name: String = ""
## Description of this skill tree.
@export_multiline var description: String = ""
## Icon for this tree.
@export var icon: Texture2D

## --- Skill Nodes ---
## Array of skill tree nodes. Each node is a dictionary:
## {
##   "id": "node_1",
##   "name": "Power Strike I",
##   "description": "Increases physical damage by 5%",
##   "type": "passive" or "ability",
##   "resource": FKPassiveSkill or FKAbility,
##   "cost": 1,  # skill points needed
##   "max_rank": 3,
##   "prerequisites": ["other_node_id"],
##   "position": Vector2(0, 0),  # position in the tree UI
##   "tier": 1  # tree tier/row
## }
@export var nodes: Array[Dictionary] = []

## --- Structure ---
## Number of tiers/rows in the tree.
@export var tier_count: int = 5
## Minimum points spent in previous tier to unlock next tier.
@export var points_per_tier: int = 5
## Total skill points available (or -1 for level-based).
@export var max_points: int = -1

## --- Custom ---
## Store any additional data your project needs. ForgeKit will not touch this.
@export var custom_data: Dictionary = {}

## Get all nodes in a specific tier.
func get_nodes_in_tier(tier: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for node in nodes:
		if node.get("tier", 0) == tier:
			result.append(node)
	return result

## Check if a node can be unlocked given current state.
func can_unlock_node(node_id: String, unlocked_nodes: Dictionary, available_points: int) -> bool:
	for node in nodes:
		if node.get("id", "") == node_id:
			# Check cost
			var current_rank: int = unlocked_nodes.get(node_id, 0)
			if current_rank >= node.get("max_rank", 1):
				return false
			if available_points < node.get("cost", 1):
				return false
			# Check prerequisites
			for prereq in node.get("prerequisites", []):
				if not unlocked_nodes.has(prereq) or unlocked_nodes[prereq] <= 0:
					return false
			# Check tier requirement
			var tier: int = node.get("tier", 0)
			if tier > 0:
				var points_in_lower := _count_points_in_tiers_below(tier, unlocked_nodes)
				if points_in_lower < points_per_tier * tier:
					return false
			return true
	return false

func _count_points_in_tiers_below(tier: int, unlocked_nodes: Dictionary) -> int:
	var total := 0
	for node in nodes:
		if node.get("tier", 0) < tier:
			var nid: String = node.get("id", "")
			total += unlocked_nodes.get(nid, 0) * node.get("cost", 1)
	return total

func _to_string() -> String:
	return display_name if display_name else id
