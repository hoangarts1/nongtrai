## MachineData — data definition for one processing machine.
## API:
##   func accepts_recipe(recipe_id: StringName) -> bool
class_name MachineData
extends Resource

@export var machine_id: StringName = &""
@export var display_name_key: StringName = &""
@export var sprite_dir: String = ""
@export_range(1, 99) var input_slots: int = 1
@export_range(1, 99) var output_slots: int = 1
@export var recipe_ids: PackedStringArray = PackedStringArray()
@export_range(0, 99) var unlock_house_level: int = 0
@export_range(0, 999999) var purchase_price: int = 0

func accepts_recipe(recipe_id: StringName) -> bool:
	return recipe_ids.has(String(recipe_id))
