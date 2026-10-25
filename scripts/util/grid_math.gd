## GridMath — converts between logical XZ cells and world positions.
## API:
##   static func world_to_cell(position: Vector3) -> Vector2i
##   static func cell_to_world(cell: Vector2i) -> Vector3
##   static func footprint_cells(origin: Vector2i, size: Vector2i, rotation_steps: int) -> Array[Vector2i]
class_name GridMath
extends RefCounted

const CELL_SIZE: float = 1.0

static func world_to_cell(position: Vector3) -> Vector2i:
	return Vector2i(floori(position.x / CELL_SIZE), floori(position.z / CELL_SIZE))

static func cell_to_world(cell: Vector2i) -> Vector3:
	return Vector3((cell.x + 0.5) * CELL_SIZE, 0.0, (cell.y + 0.5) * CELL_SIZE)

static func footprint_cells(origin: Vector2i, size: Vector2i, rotation_steps: int) -> Array[Vector2i]:
	var normalized_steps: int = posmod(rotation_steps, 4)
	var cells: Array[Vector2i] = []
	for local_z: int in range(size.y):
		for local_x: int in range(size.x):
			var rotated: Vector2i = Vector2i(local_x, local_z)
			if normalized_steps == 1:
				rotated = Vector2i(size.y - 1 - local_z, local_x)
			elif normalized_steps == 2:
				rotated = Vector2i(size.x - 1 - local_x, size.y - 1 - local_z)
			elif normalized_steps == 3:
				rotated = Vector2i(local_z, size.x - 1 - local_x)
			cells.append(origin + rotated)
	return cells
