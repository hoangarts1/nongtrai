## ChibiMeshAudit — deterministic geometry safety and triangle-budget checks.
## API:
##   static func triangle_count(root: Node) -> int
##   static func combined_bounds(root: Node) -> AABB
##   static func has_degenerate_triangles(root: Node) -> bool
##   static func validate_model(root: Node3D, triangle_budget: int) -> PackedStringArray
class_name ChibiMeshAudit
extends RefCounted

static func triangle_count(root: Node) -> int:
	var triangles: int = 0
	for mesh_instance: MeshInstance3D in collect_meshes(root):
		if mesh_instance.mesh != null:
			triangles += int(mesh_instance.mesh.get_faces().size() / 3)
	return triangles

static func collect_meshes(root: Node) -> Array[MeshInstance3D]:
	var meshes: Array[MeshInstance3D] = []
	_collect_meshes(root, meshes)
	return meshes

static func combined_bounds(root: Node) -> AABB:
	var has_bounds: bool = false
	var combined: AABB = AABB()
	for mesh_instance: MeshInstance3D in collect_meshes(root):
		if mesh_instance.mesh == null:
			continue
		var bounds: AABB = _transform_bounds(mesh_instance.mesh.get_aabb(), _transform_relative_to_root(mesh_instance, root))
		if not has_bounds:
			combined = bounds
			has_bounds = true
		else:
			combined = _merge_bounds(combined, bounds)
	return combined

static func has_degenerate_triangles(root: Node) -> bool:
	for mesh_instance: MeshInstance3D in collect_meshes(root):
		if mesh_instance.mesh == null:
			continue
		var faces: PackedVector3Array = mesh_instance.mesh.get_faces()
		for index: int in range(0, faces.size(), 3):
			if index + 2 >= faces.size():
				return true
			var edge_a: Vector3 = faces[index + 1] - faces[index]
			var edge_b: Vector3 = faces[index + 2] - faces[index]
			if edge_a.cross(edge_b).length_squared() <= 0.00000001:
				return true
	return false

static func validate_model(root: Node3D, triangle_budget: int) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if root == null:
		errors.append("model root is null")
		return errors
	if triangle_budget <= 0:
		errors.append("triangle budget must be positive")
		return errors
	var meshes: Array[MeshInstance3D] = collect_meshes(root)
	if meshes.is_empty():
		errors.append("model has no mesh instances")
		return errors
	var triangles: int = triangle_count(root)
	if triangles <= 0:
		errors.append("model has no triangles")
	if triangles > triangle_budget:
		errors.append("model triangle budget exceeded: %d > %d" % [triangles, triangle_budget])
	if has_degenerate_triangles(root):
		errors.append("model has degenerate triangles")
	for mesh_instance: MeshInstance3D in meshes:
		if mesh_instance.mesh == null:
			errors.append("mesh instance has no mesh: %s" % mesh_instance.name)
			continue
		var bounds: AABB = mesh_instance.get_aabb()
		if not _is_valid_aabb(bounds):
			errors.append("mesh has invalid bounds: %s" % mesh_instance.name)
		if not _is_valid_vector(mesh_instance.position) or not _is_valid_vector(mesh_instance.scale):
			errors.append("mesh has invalid transform: %s" % mesh_instance.name)
	var combined: AABB = combined_bounds(root)
	if not _is_valid_aabb(combined):
		errors.append("model has invalid combined bounds")
	elif combined.position.y < -0.001:
		errors.append("model extends below ground pivot")
	return errors

static func _collect_meshes(root: Node, output: Array[MeshInstance3D]) -> void:
	if root is MeshInstance3D:
		output.append(root as MeshInstance3D)
	for child: Node in root.get_children():
		_collect_meshes(child, output)

static func _is_valid_aabb(bounds: AABB) -> bool:
	return _is_valid_vector(bounds.position) and _is_valid_vector(bounds.size) and bounds.size.length_squared() > 0.000001

static func _is_valid_vector(value: Vector3) -> bool:
	return _is_valid_float(value.x) and _is_valid_float(value.y) and _is_valid_float(value.z)

static func _is_valid_float(value: float) -> bool:
	return value == value and absf(value) < 1000000.0

static func _merge_bounds(first: AABB, second: AABB) -> AABB:
	var first_end: Vector3 = first.end
	var second_end: Vector3 = second.end
	var minimum: Vector3 = Vector3(
		minf(first.position.x, second.position.x),
		minf(first.position.y, second.position.y),
		minf(first.position.z, second.position.z)
	)
	var maximum: Vector3 = Vector3(
		maxf(first_end.x, second_end.x),
		maxf(first_end.y, second_end.y),
		maxf(first_end.z, second_end.z)
	)
	return AABB(minimum, maximum - minimum)

static func _transform_bounds(bounds: AABB, transform: Transform3D) -> AABB:
	var start: Vector3 = bounds.position
	var end: Vector3 = bounds.end
	var corners: Array[Vector3] = [
		Vector3(start.x, start.y, start.z),
		Vector3(end.x, start.y, start.z),
		Vector3(start.x, end.y, start.z),
		Vector3(end.x, end.y, start.z),
		Vector3(start.x, start.y, end.z),
		Vector3(end.x, start.y, end.z),
		Vector3(start.x, end.y, end.z),
		Vector3(end.x, end.y, end.z)
	]
	var minimum: Vector3 = transform * corners[0]
	var maximum: Vector3 = minimum
	for corner: Vector3 in corners:
		var transformed: Vector3 = transform * corner
		minimum = Vector3(minf(minimum.x, transformed.x), minf(minimum.y, transformed.y), minf(minimum.z, transformed.z))
		maximum = Vector3(maxf(maximum.x, transformed.x), maxf(maximum.y, transformed.y), maxf(maximum.z, transformed.z))
	return AABB(minimum, maximum - minimum)

static func _transform_relative_to_root(node: Node3D, root: Node3D) -> Transform3D:
	var accumulated: Transform3D = Transform3D.IDENTITY
	var current: Node3D = node
	while current != null and current != root:
		accumulated = current.transform * accumulated
		current = current.get_parent() as Node3D
	return accumulated
