## MachineShopData — data-owned list of machines sold by the future shop.
## API:
##   func sells(machine_id: StringName) -> bool
class_name MachineShopData
extends Resource

@export var machine_ids: PackedStringArray = PackedStringArray()

func sells(machine_id: StringName) -> bool:
	return machine_ids.has(String(machine_id))
