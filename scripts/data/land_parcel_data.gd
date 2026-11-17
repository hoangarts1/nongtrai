## LandParcelData — data-owned locked logical cells for placement.
## API:
##   func is_locked(cell: Vector2i) -> bool
class_name LandParcelData
extends Resource

@export var locked_cells: Array[Vector2i] = []

func is_locked(cell: Vector2i) -> bool:
	return locked_cells.has(cell)
