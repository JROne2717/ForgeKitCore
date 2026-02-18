@tool
class_name FKLootTable
extends Resource
## Defines a loot/drop table with weighted random item drops.

## Unique identifier.
@export var id: String = ""
## Display name.
@export var display_name: String = ""

## --- Loot Entries ---
## Array of loot entries. Each entry is a dictionary:
## {
##   "item": FKItem resource,
##   "weight": 100,        # relative weight (higher = more common)
##   "min_quantity": 1,
##   "max_quantity": 1,
##   "drop_chance": 1.0    # absolute chance (0-1), applied AFTER weight selection
## }
@export var entries: Array[Dictionary] = []

## --- Roll Settings ---
## Number of times to roll on this table per drop event.
@export var roll_count: int = 1
## Can the same item be selected multiple times in one drop event?
@export var allow_duplicates: bool = true
## Guaranteed minimum number of items dropped (picks top weighted).
@export var guaranteed_drops: int = 0

## --- Custom ---
## Store any additional data your project needs. ForgeKit will not touch this.
@export var custom_data: Dictionary = {}

## Roll the loot table and return an array of {"item": FKItem, "quantity": int}.
func roll() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	if entries.is_empty():
		return results

	# Handle guaranteed drops first
	var sorted_entries: Array = entries.duplicate()
	sorted_entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.get("weight", 0) > b.get("weight", 0))
	var guaranteed_items: Array[String] = []

	for i in range(mini(guaranteed_drops, sorted_entries.size())):
		var entry: Dictionary = sorted_entries[i]
		var item = entry.get("item")
		if item:
			var qty := randi_range(entry.get("min_quantity", 1), entry.get("max_quantity", 1))
			results.append({"item": item, "quantity": qty})
			if item.has_method("get") or item is Resource:
				guaranteed_items.append(str(item))

	# Roll for additional items
	for _roll in range(roll_count):
		var selected := _weighted_select()
		if selected.is_empty():
			continue
		# Check drop chance
		if randf() > selected.get("drop_chance", 1.0):
			continue
		# Check duplicates
		if not allow_duplicates:
			var item_str := str(selected.get("item"))
			var already_exists := false
			for result in results:
				if str(result.get("item")) == item_str:
					already_exists = true
					break
			if already_exists:
				continue

		var item = selected.get("item")
		if item:
			var qty := randi_range(selected.get("min_quantity", 1), selected.get("max_quantity", 1))
			results.append({"item": item, "quantity": qty})

	return results

func _weighted_select() -> Dictionary:
	var total_weight := 0.0
	for entry in entries:
		total_weight += entry.get("weight", 1.0)
	if total_weight <= 0:
		return {}
	var roll := randf() * total_weight
	var cumulative := 0.0
	for entry in entries:
		cumulative += entry.get("weight", 1.0)
		if roll <= cumulative:
			return entry
	return entries.back() if not entries.is_empty() else {}

func _to_string() -> String:
	return display_name if display_name else id
