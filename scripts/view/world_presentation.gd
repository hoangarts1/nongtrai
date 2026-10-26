## WorldPresentation — handmade procedural scenery; no gameplay state or collision changes.
class_name WorldPresentation
extends Node3D

func configure(main: Node) -> void:
	var player: Player = main.world.player
	var visual: MeshInstance3D = player.get_node("Visual") as MeshInstance3D
	visual.hide()
	var avatar: ChibiAvatar = ChibiAvatar.new()
	player.add_child(avatar)
	avatar.configure(Color("a7bd88"))
	# Existing placeholders remain the authoritative anchors and keep their signals.
	var house: MeshInstance3D = main.world.get_node("House") as MeshInstance3D
	house.mesh = null
	_box(house, Vector3(3, 2.1, 2.5), Vector3(0, 0.05, 0), Color("f4e2b8"))
	var roof: PrismMesh = PrismMesh.new()
	roof.size = Vector3(3.6, 1.2, 3.1)
	_mesh(house, roof, Vector3(0, 1.65, 0), Color("c47f64"))
	_box(house, Vector3(0.72, 1.45, 0.1), Vector3(0.4, -0.22, 1.3), Color("91a986"))
	_box(house, Vector3(0.7, 0.65, 0.12), Vector3(-0.75, 0.25, 1.32), Color("add0ce"))
	_box(house, Vector3(0.11, 0.7, 0.14), Vector3(-0.75, 0.25, 1.34), Color("fff3ce"))
	var shop: MeshInstance3D = main.world.get_node("SeedShop") as MeshInstance3D
	shop.mesh = null
	_box(shop, Vector3(1.6, 0.7, 1), Vector3(0, -0.1, 0), Color("c39c6b"))
	for side: float in [-0.7, 0.7]:
		_box(shop, Vector3(0.1, 1.8, 0.1), Vector3(side, 0.45, -0.4), Color("a9845d"))
	for stripe: int in range(6):
		_box(shop, Vector3(0.3, 0.15, 1.5), Vector3(-0.75 + stripe * 0.3, 1.3, 0), Color("f1cba5") if stripe % 2 == 0 else Color("a7be90"))
	var bin: MeshInstance3D = main.world.get_node("ShippingBin") as MeshInstance3D
	bin.mesh = null
	_box(bin, Vector3(1.1, 0.7, 0.85), Vector3.ZERO, Color("b18c64"))
	_box(bin, Vector3(1.18, 0.12, 0.92), Vector3(0, 0.4, 0), Color("d4b78b"))
	_box(bin, Vector3(0.2, 0.25, 0.05), Vector3(0, 0.23, 0.47), Color("edcf7d"))
	for cell: Vector2i in [Vector2i(-8,-5), Vector2i(-6,-6), Vector2i(-8,1), Vector2i(8,-6), Vector2i(6,-8), Vector2i(-6,11), Vector2i(13,5)]:
		_tree(GridMath.cell_to_world(cell))

func _tree(origin: Vector3) -> void:
	var trunk: CylinderMesh = CylinderMesh.new()
	trunk.top_radius = 0.14
	trunk.bottom_radius = 0.22
	trunk.height = 1.6
	_mesh(self, trunk, origin + Vector3(0, 0.8, 0), Color("a88b66"))
	for offset: Vector3 in [Vector3(-0.4,1.8,0), Vector3(0.4,2,0.2), Vector3(0,2.4,-0.2)]:
		var crown: SphereMesh = SphereMesh.new()
		crown.radius = 0.9
		crown.height = 1.6
		crown.radial_segments = 12
		crown.rings = 6
		_mesh(self, crown, origin + offset, Color("99b979"))
	for offset: Vector3 in [Vector3(0.5,2,0.75), Vector3(-0.5,1.8,0.65), Vector3(0,2.7,0.45)]:
		var fruit: SphereMesh = SphereMesh.new()
		fruit.radius = 0.15
		fruit.height = 0.3
		_mesh(self, fruit, origin + offset, Color("e9b083"))

func _box(parent: Node3D, dimensions: Vector3, origin: Vector3, color: Color) -> void:
	var box: BoxMesh = BoxMesh.new()
	box.size = dimensions
	_mesh(parent, box, origin, color)

func _mesh(parent: Node3D, mesh: Mesh, origin: Vector3, color: Color) -> void:
	var part: MeshInstance3D = MeshInstance3D.new()
	part.mesh = mesh
	part.position = origin
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	part.material_override = material
	parent.add_child(part)
