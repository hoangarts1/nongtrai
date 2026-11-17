## RecipeData — data definition for one machine transformation.
## API:
##   func has_machine(machine_id: StringName) -> bool
##   func input_entries() -> Array[Dictionary]
##   func output_entries() -> Array[Dictionary]
class_name RecipeData
extends Resource

@export var recipe_id: StringName = &""
@export var inputs: Array[Dictionary] = []
@export var outputs: Array[Dictionary] = []
@export_range(1, 999) var duration_days: int = 1
@export var machine_ids: PackedStringArray = PackedStringArray()
@export_range(0, 99) var unlock_house_level: int = 0

func has_machine(machine_id: StringName) -> bool:
	return machine_ids.has(String(machine_id))

func input_entries() -> Array[Dictionary]:
	return inputs.duplicate(true)

func output_entries() -> Array[Dictionary]:
	return outputs.duplicate(true)
