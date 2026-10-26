## WorldArtFactory — shared view-only meshes for homes, market props and scenery.
## API:
##   static func build_cottage(anchor: MeshInstance3D, size: Vector3, wall_color: Color, roof_color: Color) -> void
##   static func build_market(anchor: MeshInstance3D) -> void
##   static func add_decorative_cottage(parent: Node3D, cottage_name: String, origin: Vector3, size: Vector3, wall_color: Color, roof_color: Color) -> MeshInstance3D
##   static func add_ground_dressing(parent: Node3D) -> Node3D
##   static func add_rock_cluster(parent: Node3D, cluster_name: String, origin: Vector3, stone_color: Color) -> Node3D
class_name WorldArtFactory
extends RefCounted

static func build_cottage(anchor: MeshInstance3D, size: Vector3, wall_color: Color, roof_color: Color) -> void:
	_clear_mesh_children(anchor)
	var walls: BoxMesh = BoxMesh.new()
	walls.size = size
	anchor.mesh = walls
	anchor.material_override = _material(wall_color, 0.92)
	var roof: PrismMesh = PrismMesh.new()
	roof.size = Vector3(size.x + 0.42, size.y * 0.56, size.z + 0.42)
	_mesh(anchor, "CottageRoof", roof, Vector3(0.0, size.y * 0.76, 0.0), roof_color)
	_box(anchor, "Door", Vector3(size.x * 0.23, size.y * 0.46, 0.07), Vector3(0.0, -size.y * 0.27, size.z * 0.51), Color("7d593f"))
	for side: float in [-1.0, 1.0]:
		_box(anchor, "Window_%s" % ("Left" if side < 0.0 else "Right"), Vector3(size.x * 0.20, size.y * 0.24, 0.06), Vector3(side * size.x * 0.28, size.y * 0.10, size.z * 0.51), Color("f5d994"))
		_box(anchor, "WindowFrame_%s" % ("Left" if side < 0.0 else "Right"), Vector3(0.035, size.y * 0.30, 0.075), Vector3(side * size.x * 0.28, size.y * 0.10, size.z * 0.53), Color("9c704d"))
	_box(anchor, "Chimney", Vector3(size.x * 0.14, size.y * 0.34, size.z * 0.14), Vector3(-size.x * 0.26, size.y * 0.84, -size.z * 0.16), Color("9a725d"))
	_box(anchor, "Porch", Vector3(size.x * 0.50, 0.10, size.z * 0.20), Vector3(0.0, -size.y * 0.52, size.z * 0.56), Color("c79b6d"))
	for side: float in [-1.0, 1.0]:
		_flower_box(anchor, "FlowerBox_%s" % ("Left" if side < 0.0 else "Right"), Vector3(side * size.x * 0.39, -size.y * 0.30, size.z * 0.57))

static func build_market(anchor: MeshInstance3D) -> void:
	_clear_mesh_children(anchor)
	var counter: BoxMesh = BoxMesh.new()
	counter.size = Vector3(2.0, 0.78, 1.25)
	anchor.mesh = counter
	anchor.material_override = _material(Color("b68d5c"), 0.9)
	for side: float in [-1.0, 1.0]:
		_box(anchor, "MarketPost_%s" % ("Left" if side < 0.0 else "Right"), Vector3(0.12, 2.05, 0.12), Vector3(side * 0.84, 0.65, -0.42), Color("805d40"))
	var roof: PrismMesh = PrismMesh.new()
	roof.size = Vector3(2.35, 0.78, 1.70)
	_mesh(anchor, "MarketRoof", roof, Vector3(0.0, 1.64, -0.08), Color("d97865"))
	for stripe: int in range(6):
		var color: Color = Color("fff1c8") if stripe % 2 == 0 else Color("8db77b")
		_box(anchor, "AwningStripe_%d" % stripe, Vector3(0.32, 0.10, 1.36), Vector3(-0.80 + float(stripe) * 0.32, 1.18, 0.16), color)
	for index: int in range(3):
		_box(anchor, "SeedCrate_%d" % index, Vector3(0.38, 0.24, 0.34), Vector3(-0.48 + float(index) * 0.48, 0.50, 0.42), Color("d1a46c"))
		_sphere(anchor, "SeedBag_%d" % index, Vector3(-0.48 + float(index) * 0.48, 0.68, 0.42), Vector3(0.20, 0.16, 0.16), [Color("e6a24a"), Color("83b971"), Color("d88062")][index])
	_box(anchor, "MarketSign", Vector3(0.82, 0.30, 0.05), Vector3(0.0, 1.22, 0.82), Color("f6d47b"))

static func decorate_shipping_bin(anchor: MeshInstance3D) -> void:
	_clear_mesh_children(anchor)
	var bin: BoxMesh = BoxMesh.new()
	bin.size = Vector3(1.25, 0.76, 0.95)
	anchor.mesh = bin
	anchor.material_override = _material(Color("ae8055"), 0.94)
	_box(anchor, "BinLid", Vector3(1.34, 0.13, 1.02), Vector3(0.0, 0.43, 0.0), Color("d8b788"))
	_box(anchor, "BinHandle", Vector3(0.28, 0.20, 0.05), Vector3(0.0, 0.30, 0.52), Color("efd37b"))

static func add_decorative_cottage(
	parent: Node3D,
	cottage_name: String,
	origin: Vector3,
	size: Vector3,
	wall_color: Color,
	roof_color: Color
) -> MeshInstance3D:
	var cottage: MeshInstance3D = MeshInstance3D.new()
	cottage.name = cottage_name
	cottage.position = origin
	parent.add_child(cottage)
	build_cottage(cottage, size, wall_color, roof_color)
	return cottage

static func add_ground_dressing(parent: Node3D) -> Node3D:
	var dressing: Node3D = Node3D.new()
	dressing.name = "GroundDressing"
	parent.add_child(dressing)
	var path_points: Array[Vector3] = [
		Vector3(5.35, 0.025, 9.92), Vector3(6.28, 0.025, 10.03), Vector3(7.18, 0.025, 10.12),
		Vector3(8.12, 0.025, 10.12), Vector3(9.04, 0.025, 10.06)
	]
	for index: int in range(path_points.size()):
		var stone: MeshInstance3D = _box(dressing, "PathStone_%d" % index, Vector3(0.62, 0.035, 0.38), path_points[index], Color("c9ae80"))
		stone.rotation.y = 0.20 if index % 2 == 0 else -0.18
	var grass_points: Array[Vector3] = [
		Vector3(-9.1, 0.02, -4.0), Vector3(-7.9, 0.02, 3.2), Vector3(-5.7, 0.02, 5.0),
		Vector3(-3.6, 0.02, 8.7), Vector3(7.8, 0.02, 7.5), Vector3(9.9, 0.02, 3.8),
		Vector3(8.0, 0.02, -4.6), Vector3(3.8, 0.02, -7.0), Vector3(-2.5, 0.02, -7.8)
	]
	for index: int in range(grass_points.size()):
		_add_grass_tuft(dressing, "GrassTuft_%d" % index, grass_points[index], 0.75 + float(index % 3) * 0.12)
	return dressing

static func add_rock_cluster(parent: Node3D, cluster_name: String, origin: Vector3, stone_color: Color) -> Node3D:
	var cluster: Node3D = Node3D.new()
	cluster.name = cluster_name
	cluster.position = origin
	parent.add_child(cluster)
	for index: int in range(4):
		var angle: float = TAU * float(index) / 4.0 + 0.25
		var radius: float = 0.36 + float(index) * 0.07
		var rock: SphereMesh = SphereMesh.new()
		rock.radius = 0.5
		rock.height = 1.0
		rock.radial_segments = 7
		rock.rings = 4
		var part: MeshInstance3D = _mesh(cluster, "Stone_%d" % index, rock, Vector3(cos(angle) * 0.32, radius * 0.45, sin(angle) * 0.28), stone_color.darkened(float(index) * 0.06))
		part.scale = Vector3(radius * 1.55, radius, radius * 1.20)
		part.rotation = Vector3(0.15 * float(index), angle, -0.13 * float(index))
	if cluster_name.ends_with("Moss"):
		_sphere(cluster, "Moss", Vector3(-0.06, 0.26, 0.04), Vector3(0.30, 0.09, 0.26), Color("709a54"))
	return cluster

static func _flower_box(parent: Node3D, name: String, origin: Vector3) -> void:
	_box(parent, name, Vector3(0.30, 0.12, 0.14), origin, Color("b87f57"))
	for index: int in range(2):
		_sphere(parent, "%s_Bloom_%d" % [name, index], origin + Vector3(-0.08 + 0.16 * float(index), 0.12, 0.0), Vector3(0.08, 0.10, 0.08), Color("ef9e9e") if index == 0 else Color("f4d788"))

static func _add_grass_tuft(parent: Node3D, name: String, origin: Vector3, scale_factor: float) -> void:
	var tuft: Node3D = Node3D.new()
	tuft.name = name
	tuft.position = origin
	parent.add_child(tuft)
	for index: int in range(3):
		var blade: MeshInstance3D = _box(tuft, "Blade_%d" % index, Vector3(0.045, 0.36 * scale_factor, 0.10), Vector3(0.11 * float(index - 1), 0.18 * scale_factor, 0.0), Color("5d8f43").lightened(float(index) * 0.04))
		blade.rotation.z = -0.18 + float(index) * 0.18

static func _clear_mesh_children(anchor: MeshInstance3D) -> void:
	for child: Node in anchor.get_children():
		if child is MeshInstance3D:
			child.free()

static func _box(parent: Node3D, name: String, size: Vector3, origin: Vector3, color: Color) -> MeshInstance3D:
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	return _mesh(parent, name, box, origin, color)

static func _sphere(parent: Node3D, name: String, origin: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	sphere.radial_segments = 10
	sphere.rings = 6
	var part: MeshInstance3D = _mesh(parent, name, sphere, origin, color)
	part.scale = size
	return part

static func _mesh(parent: Node3D, name: String, mesh: Mesh, origin: Vector3, color: Color) -> MeshInstance3D:
	var part: MeshInstance3D = MeshInstance3D.new()
	part.name = name
	part.mesh = mesh
	part.position = origin
	part.material_override = _material(color, 0.86)
	parent.add_child(part)
	return part

static func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material
