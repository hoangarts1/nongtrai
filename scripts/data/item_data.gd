## ItemData — data-only definition of an inventory item.
class_name ItemData
extends Resource

@export var item_id: StringName
@export var display_name: String = ""
@export_range(1, 999) var max_stack: int = 99
