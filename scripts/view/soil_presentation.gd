## SoilPresentation — view-only tilled ridges and moisture accents for FarmView cells.
## API:
##   static func render(soil: MeshInstance3D, tilled: bool, watered: bool, cell: Vector2i) -> void
class_name SoilPresentation
extends RefCounted

const GRASS_COLOR := Color("477d3f")
const TILLED_COLOR := Color("7d512f")
const WET_SOIL_COLOR := Color("553920")

static func render(soil: MeshInstance3D, tilled: bool, watered: bool, cell: Vector2i) -> void:
	_clear(soil)
	soil.material_override = _material(_base_color(tilled, watered), 0.58 if watered and tilled else 0.92)
	if not tilled:
		return
	for index: int in range(3):
		var furrow: MeshInstance3D = _box(
			"SoilFurrow_%d" % index,
			Vector3(0.15, 0.035, 0.72),
			Vector3(-0.24 + 0.24 * float(index), 0.058, 0.0),
			TILLED_COLOR.lightened(0.11 if index % 2 == 0 else 0.03)
		)
		soil.add_child(furrow)
	if watered:
		var sheen: MeshInstance3D = _box("MoistureSheen", Vector3(0.50, 0.008, 0.56), Vector3(0.0, 0.087, 0.0), Color("98c8b5"))
		sheen.material_override = _transparent_material(Color("83b9aa"))
		sheen.rotation.y = deg_to_rad(float(posmod(cell.x * 29 + cell.y * 13, 20)) - 10.0)
		soil.add_child(sheen)

static func _clear(soil: MeshInstance3D) -> void:
	for child: Node in soil.get_children():
		if child is MeshInstance3D:
			child.free()

static func _base_color(tilled: bool, watered: bool) -> Color:
	if watered and tilled:
		return WET_SOIL_COLOR
	if tilled:
		return TILLED_COLOR
	return GRASS_COLOR

static func _box(name: String, size: Vector3, origin: Vector3, color: Color) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	var part: MeshInstance3D = MeshInstance3D.new()
	part.name = name
	part.mesh = mesh
	part.position = origin
	part.material_override = _material(color, 0.88)
	return part

static func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material

static func _transparent_material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = _material(color, 0.42)
	material.albedo_color.a = 0.34
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material
