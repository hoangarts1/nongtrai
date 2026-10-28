## ItemData — data-only definition of an inventory item.
class_name ItemData
extends Resource

@export var item_id: StringName
@export var display_name_key: StringName = &""
@export_range(1, 999) var max_stack: int = 99
@export var buy_price: int = 0
@export var sell_price: int = 0
@export var color: Color = Color.WHITE
## Visual-only generated C2 asset references. These never enter inventory/save state.
@export_file("*.tscn") var model_path: String = ""
@export_file("*.png") var icon_path: String = ""
