## CropPresentation — view-only handmade crop meshes for FarmView.
## API:
##   static func render(crop: MeshInstance3D, crop_id: StringName, growth_ratio: float, crop_color: Color, withered: bool, watered: bool, cell: Vector2i) -> void
##   static func clear(crop: MeshInstance3D) -> void
class_name CropPresentation
extends RefCounted

const SOIL_TOP: float = 0.10
const LEAF_GREEN := Color("5f9b45")
const DARK_GREEN := Color("397437")
const DRY_BROWN := Color("725b42")

static func clear(crop: MeshInstance3D) -> void:
	for child: Node in crop.get_children():
		if child is MeshInstance3D:
			child.free()
	crop.mesh = null
	crop.material_override = null
	crop.rotation = Vector3.ZERO
	crop.scale = Vector3.ONE

static func render(
	crop: MeshInstance3D,
	crop_id: StringName,
	growth_ratio: float,
	crop_color: Color,
	withered: bool,
	watered: bool,
	cell: Vector2i
) -> void:
	clear(crop)
	var growth: float = clampf(growth_ratio, 0.0, 1.0)
	var phase: float = deg_to_rad(float(posmod(cell.x * 17 + cell.y * 31, 360)))
	if withered:
		_render_withered(crop, phase)
		return
	if growth < 0.42:
		_render_sprout(crop, growth, phase, watered)
		return
	match crop_id:
		&"spring_carrot", &"turnip", &"winter_radish":
			_render_root_vegetable(crop, growth, crop_color, phase, watered)
		&"summer_tomato":
			_render_tomato(crop, growth, crop_color, phase, watered)
		&"summer_corn":
			_render_corn(crop, growth, crop_color, phase, watered)
		&"autumn_wheat":
			_render_wheat(crop, growth, crop_color, phase, watered)
		&"autumn_pumpkin":
			_render_pumpkin(crop, growth, crop_color, phase, watered)
		&"winter_cabbage":
			_render_cabbage(crop, growth, crop_color, phase, watered)
		&"spring_pea":
			_render_pea(crop, growth, crop_color, phase, watered)
		_:
			_render_root_vegetable(crop, growth, crop_color, phase, watered)

static func _render_sprout(crop: MeshInstance3D, growth: float, phase: float, watered: bool) -> void:
	var height: float = lerpf(0.22, 0.38, growth / 0.42)
	_stem(crop, height, LEAF_GREEN)
	for index: int in range(2):
		var angle: float = phase + PI * float(index)
		_leaf(crop, "SproutLeaf_%d" % index, Vector3(cos(angle) * 0.10, height * 0.36, sin(angle) * 0.10), angle, Vector3(0.16, 0.045, 0.30), LEAF_GREEN.lightened(0.08))
	_add_dew(crop, height, watered)

static func _render_root_vegetable(crop: MeshInstance3D, growth: float, crop_color: Color, phase: float, watered: bool) -> void:
	var height: float = lerpf(0.42, 0.72, growth)
	_stem(crop, height, DARK_GREEN)
	var bulb_size: float = lerpf(0.20, 0.36, growth)
	_sphere(crop, "Bulb", Vector3(0.0, -height * 0.34, 0.0), Vector3(bulb_size, bulb_size * 0.8, bulb_size), crop_color)
	_leaf_rosette(crop, height * 0.42, 4, lerpf(0.22, 0.38, growth), LEAF_GREEN, phase)
	_add_dew(crop, height, watered)

static func _render_tomato(crop: MeshInstance3D, growth: float, crop_color: Color, phase: float, watered: bool) -> void:
	var height: float = lerpf(0.48, 0.92, growth)
	_stem(crop, height, DARK_GREEN)
	_leaf_rosette(crop, height * 0.18, 4, 0.25, LEAF_GREEN, phase)
	_leaf_rosette(crop, height * 0.42, 5, 0.29, LEAF_GREEN.lightened(0.05), phase + 0.35)
	if growth > 0.70:
		for index: int in range(3):
			var angle: float = phase + TAU * float(index) / 3.0
			_sphere(crop, "Tomato_%d" % index, Vector3(cos(angle) * 0.19, height * 0.22 + sin(float(index)) * 0.05, sin(angle) * 0.19), Vector3(0.18, 0.16, 0.18), crop_color)
	_add_dew(crop, height, watered)

static func _render_corn(crop: MeshInstance3D, growth: float, crop_color: Color, phase: float, watered: bool) -> void:
	var height: float = lerpf(0.55, 1.18, growth)
	_stem(crop, height, Color("658c3a"))
	for index: int in range(4):
		var angle: float = phase + TAU * float(index) / 4.0
		_leaf(crop, "CornLeaf_%d" % index, Vector3(cos(angle) * 0.12, -height * 0.08 + float(index) * height * 0.18, sin(angle) * 0.12), angle, Vector3(0.16, 0.035, 0.52), LEAF_GREEN)
	if growth > 0.72:
		_sphere(crop, "CornEar", Vector3(0.12, height * 0.16, 0.10), Vector3(0.13, 0.30, 0.13), crop_color)
	_add_dew(crop, height, watered)

static func _render_wheat(crop: MeshInstance3D, growth: float, crop_color: Color, phase: float, watered: bool) -> void:
	var height: float = lerpf(0.46, 0.92, growth)
	_stem(crop, height, Color("91a945"))
	for index: int in range(4):
		var angle: float = phase + TAU * float(index) / 4.0
		var blade_height: float = height * (0.72 + float(index) * 0.05)
		_cylinder(crop, "WheatBlade_%d" % index, Vector3(cos(angle) * 0.11, -height * 0.08, sin(angle) * 0.11), 0.028, 0.045, blade_height, Color("8eaa48"))
	if growth > 0.62:
		_sphere(crop, "WheatHead", Vector3(0.0, height * 0.48, 0.0), Vector3(0.12, 0.34, 0.12), crop_color)
	_add_dew(crop, height, watered)

static func _render_pumpkin(crop: MeshInstance3D, growth: float, crop_color: Color, phase: float, watered: bool) -> void:
	var height: float = lerpf(0.28, 0.48, growth)
	_stem(crop, height, DARK_GREEN)
	for index: int in range(5):
		var angle: float = phase + TAU * float(index) / 5.0
		_leaf(crop, "PumpkinLeaf_%d" % index, Vector3(cos(angle) * 0.22, -height * 0.26, sin(angle) * 0.22), angle, Vector3(0.30, 0.055, 0.38), LEAF_GREEN)
	if growth > 0.70:
		_sphere(crop, "Pumpkin", Vector3(0.07, -height * 0.30, -0.08), Vector3(0.32, 0.24, 0.32), crop_color)
	_add_dew(crop, height, watered)

static func _render_cabbage(crop: MeshInstance3D, growth: float, crop_color: Color, phase: float, watered: bool) -> void:
	var height: float = lerpf(0.30, 0.48, growth)
	_stem(crop, height, DARK_GREEN)
	for index: int in range(7):
		var angle: float = phase + TAU * float(index) / 7.0
		_leaf(crop, "CabbageLeaf_%d" % index, Vector3(cos(angle) * 0.15, -height * 0.28, sin(angle) * 0.15), angle, Vector3(0.30, 0.07, 0.34), crop_color.lightened(0.06))
	_sphere(crop, "CabbageHeart", Vector3(0.0, -height * 0.12, 0.0), Vector3(0.27, 0.20, 0.27), crop_color)
	_add_dew(crop, height, watered)

static func _render_pea(crop: MeshInstance3D, growth: float, crop_color: Color, phase: float, watered: bool) -> void:
	var height: float = lerpf(0.45, 0.86, growth)
	_stem(crop, height, DARK_GREEN)
	for index: int in range(4):
		var angle: float = phase + TAU * float(index) / 4.0
		_leaf(crop, "PeaLeaf_%d" % index, Vector3(cos(angle) * 0.13, -height * 0.08 + float(index) * height * 0.18, sin(angle) * 0.13), angle, Vector3(0.14, 0.035, 0.25), LEAF_GREEN)
	if growth > 0.68:
		for index: int in range(2):
			_sphere(crop, "PeaPod_%d" % index, Vector3(-0.13 + float(index) * 0.26, height * 0.15, 0.10), Vector3(0.09, 0.22, 0.09), crop_color)
	_add_dew(crop, height, watered)

static func _render_withered(crop: MeshInstance3D, phase: float) -> void:
	_stem(crop, 0.50, DRY_BROWN)
	for index: int in range(3):
		var angle: float = phase + TAU * float(index) / 3.0
		_leaf(crop, "DryLeaf_%d" % index, Vector3(cos(angle) * 0.10, 0.04, sin(angle) * 0.10), angle, Vector3(0.10, 0.025, 0.28), DRY_BROWN)

static func _stem(crop: MeshInstance3D, height: float, color: Color) -> void:
	var stem: CylinderMesh = CylinderMesh.new()
	stem.top_radius = 0.055
	stem.bottom_radius = 0.082
	stem.height = height
	stem.radial_segments = 8
	crop.mesh = stem
	crop.position.y = SOIL_TOP + height * 0.5
	crop.material_override = _material(color)

static func _leaf_rosette(parent: MeshInstance3D, height: float, count: int, radius: float, color: Color, phase: float) -> void:
	for index: int in range(count):
		var angle: float = phase + TAU * float(index) / float(count)
		_leaf(parent, "Leaf_%d" % index, Vector3(cos(angle) * radius * 0.45, height, sin(angle) * radius * 0.45), angle, Vector3(radius * 0.85, 0.05, radius * 1.2), color)

static func _add_dew(parent: MeshInstance3D, height: float, watered: bool) -> void:
	if not watered:
		return
	for index: int in range(2):
		var offset: float = -0.08 if index == 0 else 0.08
		_sphere(parent, "Dew_%d" % index, Vector3(offset, height * 0.36, 0.04), Vector3(0.045, 0.065, 0.045), Color("bfe8f2"))

static func _leaf(parent: MeshInstance3D, name: String, origin: Vector3, yaw: float, dimensions: Vector3, color: Color) -> void:
	var leaf: SphereMesh = SphereMesh.new()
	leaf.radius = 0.5
	leaf.height = 1.0
	leaf.radial_segments = 8
	leaf.rings = 4
	var part: MeshInstance3D = _part(parent, name, leaf, origin, color)
	part.scale = dimensions
	part.rotation.y = yaw
	part.rotation.z = 0.24

static func _sphere(parent: MeshInstance3D, name: String, origin: Vector3, dimensions: Vector3, color: Color) -> void:
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	sphere.radial_segments = 10
	sphere.rings = 6
	var part: MeshInstance3D = _part(parent, name, sphere, origin, color)
	part.scale = dimensions

static func _cylinder(parent: MeshInstance3D, name: String, origin: Vector3, top_radius: float, bottom_radius: float, height: float, color: Color) -> void:
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = top_radius
	cylinder.bottom_radius = bottom_radius
	cylinder.height = height
	cylinder.radial_segments = 8
	_part(parent, name, cylinder, origin, color)

static func _part(parent: MeshInstance3D, name: String, mesh: Mesh, origin: Vector3, color: Color) -> MeshInstance3D:
	var part: MeshInstance3D = MeshInstance3D.new()
	part.name = name
	part.mesh = mesh
	part.position = origin
	part.material_override = _material(color)
	parent.add_child(part)
	return part

static func _material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	return material
