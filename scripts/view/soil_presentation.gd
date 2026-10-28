## SoilPresentation -- C2 data-owned grass, furrow and wet-soil presentation.
## API:
##   static func render(soil: MeshInstance3D, tilled: bool, watered: bool, cell: Vector2i) -> void
class_name SoilPresentation
extends RefCounted

const CATALOG: FarmingArtCatalog = preload("res://data/art/farming/chibi_farming_catalog.tres")

static func render(soil: MeshInstance3D, tilled: bool, watered: bool, cell: Vector2i) -> void:
	_clear(soil)
	soil.material_override = _material(_base_color(tilled, watered), 0.56 if tilled and watered else 0.90)
	if not tilled:
		return
	for index: int in range(3):
		var furrow: MeshInstance3D = _box(
			"SoilFurrow_%d" % index,
			Vector3(0.16, 0.040, 0.74),
			Vector3(-0.24 + 0.24 * float(index), 0.062, 0.0),
			CATALOG.furrow_color.lightened(0.08 if index % 2 == 0 else 0.0)
		)
		soil.add_child(furrow)
	if watered:
		var sheen: MeshInstance3D = _box("MoistureSheen", Vector3(0.54, 0.010, 0.59), Vector3(0.0, 0.090, 0.0), CATALOG.water_effect_color)
		sheen.material_override = _transparent_material(CATALOG.water_effect_color)
		sheen.rotation.y = deg_to_rad(float(posmod(cell.x * 29 + cell.y * 13, 20)) - 10.0)
		soil.add_child(sheen)

static func _clear(soil: MeshInstance3D) -> void:
	for child: Node in soil.get_children():
		child.free()

static func _base_color(tilled: bool, watered: bool) -> Color:
	if tilled and watered:
		return CATALOG.wet_soil_color
	if tilled:
		return CATALOG.tilled_color
	return CATALOG.grass_color

static func _box(part_name: String, size: Vector3, origin: Vector3, color: Color) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	var part: MeshInstance3D = MeshInstance3D.new()
	part.name = part_name
	part.mesh = mesh
	part.position = origin
	part.material_override = _material(color, 0.86)
	return part

static func _material(color: Color, roughness: float) -> Material:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.roughness = roughness
	return material

static func _transparent_material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(color, 0.30)
	material.roughness = 0.42
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material
