@tool
class_name FKItem
extends Resource
## Defines an item in the RPG system (weapons, armor, consumables, key items, etc.).

## Unique identifier for this item.
@export var id: String = ""
## Display name shown to players.
@export var display_name: String = ""
## Description of this item.
@export_multiline var description: String = ""
## Icon for this item.
@export var icon: Texture2D

## --- Category ---
@export_enum("Weapon", "Armor", "Accessory", "Consumable", "Material", "Key Item", "Currency") var item_type: String = "Consumable"
## Sub-type for further categorization (e.g., "Sword", "Staff", "Potion").
@export var sub_type: String = ""

## --- Equipment Stats (for Weapon/Armor/Accessory) ---
## Stat modifiers when equipped. Maps stat ID -> bonus value.
@export var stat_modifiers: Dictionary = {}
## Equipment slot this occupies (e.g., "main_hand", "off_hand", "head", "body", "legs", "feet", "ring", "necklace").
@export var equipment_slot: String = ""
## Classes that can equip this item. Empty means all classes.
@export var class_restrictions: Array[String] = []
## Level requirement to equip.
@export var level_requirement: int = 0

## --- Consumable Properties ---
## Effect when used. Maps effect_type -> value (e.g., {"heal_hp": 50, "cure_poison": true}).
@export var use_effects: Dictionary = {}
## Can this item be used in battle?
@export var usable_in_battle: bool = false
## Can this item be used outside of battle?
@export var usable_in_field: bool = false
## Is this item consumed on use?
@export var consumable: bool = true
## Cooldown in turns (0 = no cooldown).
@export var cooldown_turns: int = 0

## --- Economy ---
## Buy price from shops.
@export var buy_price: int = 0
## Sell price to shops.
@export var sell_price: int = 0
## Maximum stack size (1 = not stackable).
@export var max_stack: int = 99
## Item rarity tier.
@export_enum("Common", "Uncommon", "Rare", "Epic", "Legendary", "Unique") var rarity: String = "Common"

## --- Flags ---
## Can this item be sold?
@export var sellable: bool = true
## Can this item be dropped/discarded?
@export var droppable: bool = true
## Can this item be traded to other players?
@export var tradeable: bool = true

func _to_string() -> String:
	return display_name if display_name else id
