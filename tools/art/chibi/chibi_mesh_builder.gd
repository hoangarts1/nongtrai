## ChibiMeshBuilder — primitive calibration models for the reusable chibi pipeline.
## API:
##   static func build_character(palette: ArtPalette) -> Node3D
##   static func build_prop(palette: ArtPalette) -> Node3D
##   static func build_crop(palette: ArtPalette) -> Node3D
##   static func build_building(palette: ArtPalette) -> Node3D
##   static func build_tree(palette: ArtPalette) -> Node3D
class_name ChibiMeshBuilder
extends RefCounted

const MATERIAL_FACTORY: Script = preload("res://scripts/view/chibi_material_factory.gd")

static func build_character(palette: Resource) -> Node3D:
	var root: Node3D = _root("ChibiCharacterCalibration", &"character")
	_sphere(root, "Body", Vector3(0.0, 0.37, 0.0), Vector3(0.34, 0.34, 0.25), palette.get_color(&"ui_accent"), 10, 5, &"toon", true)
	_sphere(root, "Head", Vector3(0.0, 0.70, 0.0), Vector3(0.52, 0.44, 0.42), Color("f5caaa"), 10, 5, &"toon", true)
	_sphere(root, "Hair", Vector3(0.0, 0.91, -0.02), Vector3(0.56, 0.18, 0.44), Color("745542"), 10, 5, &"toon", true)
	for side: float in [-1.0, 1.0]:
		_sphere(root, "Eye_%s" % _side_name(side), Vector3(side * 0.16, 0.71, 0.37), Vector3(0.045, 0.075, 0.025), palette.get_color(&"outline"), 8, 4)
		_sphere(root, "Cheek_%s" % _side_name(side), Vector3(side * 0.27, 0.62, 0.37), Vector3(0.075, 0.035, 0.018), Color("efa3a2"), 8, 4)
		_sphere(root, "Arm_%s" % _side_name(side), Vector3(side * 0.35, 0.40, 0.0), Vector3(0.11, 0.24, 0.12), Color("f5caaa"), 10, 5, &"toon", true)
		_cylinder(root, "Leg_%s" % _side_name(side), Vector3(side * 0.13, 0.12, 0.0), 0.095, 0.24, Color("705544"), 10, 4, &"toon", true)
	return root

static func build_prop(palette: Resource) -> Node3D:
	var root: Node3D = _root("ChibiPropCalibration", &"prop")
	_box(root, "Crate", Vector3(0.0, 0.25, 0.0), Vector3(0.72, 0.50, 0.56), palette.get_color(&"wood"), &"toon", true)
	_cylinder(root, "Handle", Vector3(0.0, 0.58, 0.0), 0.09, 0.20, palette.get_color(&"outline"), 10, 3, &"toon", true)
	_sphere(root, "Accent", Vector3(0.0, 0.54, 0.28), Vector3(0.15, 0.15, 0.07), palette.get_color(&"ui_accent"), 8, 4, &"toon", true)
	return root

static func build_crop(palette: Resource) -> Node3D:
	var root: Node3D = _root("ChibiCropCalibration", &"crop")
	_sphere(root, "CropBulb", Vector3(0.0, 0.20, 0.0), Vector3(0.30, 0.35, 0.30), palette.get_color(&"ui_accent"), 8, 3, &"toon", true)
	for offset: Vector3 in [Vector3(-0.15, 0.55, 0.0), Vector3(0.15, 0.57, 0.02), Vector3(0.0, 0.64, -0.08)]:
		_sphere(root, "Leaf_%d" % root.get_child_count(), offset, Vector3(0.16, 0.33, 0.08), palette.get_color(&"foliage"), 8, 3, &"foliage")
	return root

static func build_building(palette: Resource) -> Node3D:
	var root: Node3D = _root("ChibiBuildingCalibration", &"building")
	_sphere(root, "Walls", Vector3(0.0, 0.64, 0.0), Vector3(1.55, 1.28, 1.25), Color("f0d8af"), 12, 6, &"toon", true)
	_sphere(root, "Roof", Vector3(0.0, 1.39, 0.0), Vector3(1.80, 0.35, 1.50), palette.get_color(&"roof"), 12, 4, &"toon", true)
	_box(root, "Door", Vector3(0.0, 0.36, 0.64), Vector3(0.32, 0.60, 0.04), palette.get_color(&"wood"), &"toon", true)
	for side: float in [-1.0, 1.0]:
		_sphere(root, "Window_%s" % _side_name(side), Vector3(side * 0.46, 0.76, 0.65), Vector3(0.16, 0.16, 0.03), palette.get_color(&"water"), 8, 4, &"toon")
	return root

static func build_tree(palette: Resource) -> Node3D:
	var root: Node3D = _root("ChibiTreeCalibration", &"tree")
	_cylinder(root, "Trunk", Vector3(0.0, 0.58, 0.0), 0.13, 1.16, palette.get_color(&"wood"), 10, 4, &"toon", true)
	for offset: Vector3 in [Vector3(-0.30, 1.38, 0.0), Vector3(0.30, 1.52, 0.08), Vector3(0.0, 1.83, -0.10)]:
		_sphere(root, "Crown_%d" % root.get_child_count(), offset, Vector3(0.58, 0.56, 0.50), palette.get_color(&"foliage"), 10, 4, &"foliage")
	return root

static func _root(model_name: String, art_kind: StringName) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = model_name
	root.set_meta("art_kind", art_kind)
	return root

static func _side_name(side: float) -> String:
	return "left" if side < 0.0 else "right"

static func _sphere(parent: Node3D, part_name: String, origin: Vector3, dimensions: Vector3, color: Color, radial_segments: int = 10, rings: int = 5, shader_id: StringName = &"toon", add_outline: bool = false) -> MeshInstance3D:
	var mesh: ArrayMesh = _rounded_mesh(radial_segments, rings)
	return _mesh(parent, part_name, mesh, origin, dimensions, color, shader_id, add_outline)

static func _cylinder(parent: Node3D, part_name: String, origin: Vector3, radius: float, height: float, color: Color, radial_segments: int, _rings: int, shader_id: StringName = &"toon", add_outline: bool = false) -> MeshInstance3D:
	var mesh: ArrayMesh = _cylinder_mesh(radial_segments)
	return _mesh(parent, part_name, mesh, origin, Vector3(radius * 2.0, height, radius * 2.0), color, shader_id, add_outline)

static func _box(parent: Node3D, part_name: String, origin: Vector3, size: Vector3, color: Color, shader_id: StringName = &"toon", add_outline: bool = false) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	return _mesh(parent, part_name, mesh, origin, Vector3.ONE, color, shader_id, add_outline)

static func _mesh(parent: Node3D, part_name: String, mesh: Mesh, origin: Vector3, scale_factor: Vector3, color: Color, shader_id: StringName, add_outline: bool) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = part_name
	instance.mesh = mesh
	instance.position = origin
	instance.scale = scale_factor
	var material: ShaderMaterial = MATERIAL_FACTORY.create_material(shader_id, &"wood")
	if material.shader != null:
		if shader_id == &"water":
			material.set_shader_parameter(&"water_color", color)
		else:
			material.set_shader_parameter(&"base_color", color)
		if add_outline:
			var outline: ShaderMaterial = MATERIAL_FACTORY.create_material(&"outline", &"outline")
			if outline.shader != null:
				material.next_pass = outline
		instance.material_override = material
	else:
		var fallback: StandardMaterial3D = StandardMaterial3D.new()
		fallback.albedo_color = color
		fallback.roughness = 0.88
		instance.material_override = fallback
	parent.add_child(instance)
	return instance

static func _rounded_mesh(radial_segments: int, vertical_segments: int) -> ArrayMesh:
	var radial: int = maxi(radial_segments, 3)
	var vertical: int = maxi(vertical_segments, 3)
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var top: Vector3 = Vector3(0.0, 0.5, 0.0)
	var bottom: Vector3 = Vector3(0.0, -0.5, 0.0)
	for segment: int in range(radial):
		var next_segment: int = (segment + 1) % radial
		var current_top: Vector3 = _sphere_ring_point(1, segment, radial, vertical)
		var next_top: Vector3 = _sphere_ring_point(1, next_segment, radial, vertical)
		_add_triangle(surface, top, Vector2(0.5, 0.0), next_top, _sphere_uv(1, next_segment, radial, vertical), current_top, _sphere_uv(1, segment, radial, vertical))
	for ring: int in range(1, vertical - 1):
		for segment: int in range(radial):
			var next_segment: int = (segment + 1) % radial
			var upper_current: Vector3 = _sphere_ring_point(ring, segment, radial, vertical)
			var upper_next: Vector3 = _sphere_ring_point(ring, next_segment, radial, vertical)
			var lower_current: Vector3 = _sphere_ring_point(ring + 1, segment, radial, vertical)
			var lower_next: Vector3 = _sphere_ring_point(ring + 1, next_segment, radial, vertical)
			_add_triangle(surface, upper_current, _sphere_uv(ring, segment, radial, vertical), lower_next, _sphere_uv(ring + 1, next_segment, radial, vertical), lower_current, _sphere_uv(ring + 1, segment, radial, vertical))
			_add_triangle(surface, upper_current, _sphere_uv(ring, segment, radial, vertical), upper_next, _sphere_uv(ring, next_segment, radial, vertical), lower_next, _sphere_uv(ring + 1, next_segment, radial, vertical))
	for segment: int in range(radial):
		var next_segment: int = (segment + 1) % radial
		var current_bottom: Vector3 = _sphere_ring_point(vertical - 1, segment, radial, vertical)
		var next_bottom: Vector3 = _sphere_ring_point(vertical - 1, next_segment, radial, vertical)
		_add_triangle(surface, current_bottom, _sphere_uv(vertical - 1, segment, radial, vertical), next_bottom, _sphere_uv(vertical - 1, next_segment, radial, vertical), bottom, Vector2(0.5, 1.0))
	surface.generate_normals()
	return surface.commit() as ArrayMesh

static func _sphere_ring_point(ring: int, segment: int, radial: int, vertical: int) -> Vector3:
	var theta: float = PI * float(ring) / float(vertical)
	var phi: float = TAU * float(segment) / float(radial)
	return Vector3(sin(theta) * cos(phi) * 0.5, cos(theta) * 0.5, sin(theta) * sin(phi) * 0.5)

static func _sphere_uv(ring: int, segment: int, radial: int, vertical: int) -> Vector2:
	return Vector2(float(segment) / float(radial), float(ring) / float(vertical))

static func _cylinder_mesh(radial_segments: int) -> ArrayMesh:
	var radial: int = maxi(radial_segments, 3)
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var top_center: Vector3 = Vector3(0.0, 0.5, 0.0)
	var bottom_center: Vector3 = Vector3(0.0, -0.5, 0.0)
	for segment: int in range(radial):
		var next_segment: int = (segment + 1) % radial
		var top_current: Vector3 = _cylinder_point(0.5, segment, radial)
		var top_next: Vector3 = _cylinder_point(0.5, next_segment, radial)
		var bottom_current: Vector3 = _cylinder_point(-0.5, segment, radial)
		var bottom_next: Vector3 = _cylinder_point(-0.5, next_segment, radial)
		var uv_current: float = float(segment) / float(radial)
		var uv_next: float = float(next_segment) / float(radial)
		_add_triangle(surface, top_current, Vector2(uv_current, 0.0), bottom_next, Vector2(uv_next, 1.0), bottom_current, Vector2(uv_current, 1.0))
		_add_triangle(surface, top_current, Vector2(uv_current, 0.0), top_next, Vector2(uv_next, 0.0), bottom_next, Vector2(uv_next, 1.0))
		_add_triangle(surface, top_center, Vector2(0.5, 0.5), top_next, Vector2(0.5 + top_next.x, 0.5 + top_next.z), top_current, Vector2(0.5 + top_current.x, 0.5 + top_current.z))
		_add_triangle(surface, bottom_center, Vector2(0.5, 0.5), bottom_current, Vector2(0.5 + bottom_current.x, 0.5 + bottom_current.z), bottom_next, Vector2(0.5 + bottom_next.x, 0.5 + bottom_next.z))
	surface.generate_normals()
	return surface.commit() as ArrayMesh

static func _cylinder_point(height: float, segment: int, radial: int) -> Vector3:
	var phi: float = TAU * float(segment) / float(radial)
	return Vector3(cos(phi) * 0.5, height, sin(phi) * 0.5)

static func _add_triangle(surface: SurfaceTool, first: Vector3, first_uv: Vector2, second: Vector3, second_uv: Vector2, third: Vector3, third_uv: Vector2) -> void:
	surface.set_uv(first_uv)
	surface.add_vertex(first)
	surface.set_uv(third_uv)
	surface.add_vertex(third)
	surface.set_uv(second_uv)
	surface.add_vertex(second)
