## WorldPresentation — handmade scenery and lighting that preserves gameplay anchors.
## API:
##   func configure(main: Node) -> void
class_name WorldPresentation
extends Node3D

const WORLD_ART_FACTORY: Script = preload("res://scripts/view/world_art_factory.gd")

func configure(main: Node) -> void:
	name = "WorldPresentation"
	var world: GrayBoxWorld = main.world as GrayBoxWorld
	var player: Player = world.player
	var visual: MeshInstance3D = player.get_node("Visual") as MeshInstance3D
	visual.hide()
	var avatar: ChibiAvatar = ChibiAvatar.new()
	player.add_child(avatar)
	avatar.configure(Color("a7bd88"))
	WORLD_ART_FACTORY.build_cottage(world.get_node("House") as MeshInstance3D, Vector3(3.0, 2.1, 2.5), Color("f4e2b8"), Color("c47f64"))
	WORLD_ART_FACTORY.build_market(world.get_node("SeedShop") as MeshInstance3D)
	WORLD_ART_FACTORY.decorate_shipping_bin(world.get_node("ShippingBin") as MeshInstance3D)
	_tune_lighting(world)
	for cell: Vector2i in [Vector2i(-8, -5), Vector2i(-6, -6), Vector2i(-8, 1), Vector2i(8, -6), Vector2i(6, -8), Vector2i(-6, 11), Vector2i(10, 5)]:
		_tree(GridMath.cell_to_world(cell))
	WORLD_ART_FACTORY.add_rock_cluster(self, "RockClusterMoss", Vector3(-9.1, 0.0, 5.4), Color("7c8179"))
	WORLD_ART_FACTORY.add_rock_cluster(self, "RockClusterNorth", Vector3(-6.6, 0.0, 10.2), Color("7d8381"))
	WORLD_ART_FACTORY.add_rock_cluster(self, "RockClusterEast", Vector3(9.6, 0.0, 6.8), Color("7d8589"))
	WORLD_ART_FACTORY.add_rock_cluster(self, "RockClusterSouth", Vector3(7.6, 0.0, -7.6), Color("847e75"))

func _tune_lighting(world: GrayBoxWorld) -> void:
	var environment: Environment = world.world_environment.environment
	if environment != null:
		environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
		environment.tonemap_exposure = 1.04
		environment.tonemap_white = 5.0
		environment.adjustment_enabled = true
		environment.adjustment_saturation = 1.08
		environment.adjustment_contrast = 1.04
		environment.glow_enabled = true
		environment.glow_bloom = 0.08
		environment.glow_hdr_scale = 1.0
		environment.fog_enabled = true
		environment.fog_density = 0.004
		environment.fog_light_color = Color("b9d4d9")
		environment.fog_light_energy = 0.55
		environment.fog_sun_scatter = 0.18
		environment.fog_sky_affect = 0.14
	world.sun.directional_shadow_max_distance = 42.0
	world.sun.directional_shadow_fade_start = 0.88
	world.sun.directional_shadow_blend_splits = true
	world.sun.light_angular_distance = 0.65

func _tree(origin: Vector3) -> void:
	var trunk: CylinderMesh = CylinderMesh.new()
	trunk.top_radius = 0.14
	trunk.bottom_radius = 0.22
	trunk.height = 1.6
	_mesh(self, "TreeTrunk", trunk, origin + Vector3(0, 0.8, 0), Color("a88b66"))
	for offset: Vector3 in [Vector3(-0.4, 1.8, 0), Vector3(0.4, 2.0, 0.2), Vector3(0, 2.4, -0.2)]:
		var crown: SphereMesh = SphereMesh.new()
		crown.radius = 0.9
		crown.height = 1.6
		crown.radial_segments = 12
		crown.rings = 6
		_mesh(self, "TreeCrown", crown, origin + offset, Color("99b979"))
	for offset: Vector3 in [Vector3(0.5, 2.0, 0.75), Vector3(-0.5, 1.8, 0.65), Vector3(0, 2.7, 0.45)]:
		var fruit: SphereMesh = SphereMesh.new()
		fruit.radius = 0.15
		fruit.height = 0.3
		_mesh(self, "TreeFruit", fruit, origin + offset, Color("e9b083"))

func _mesh(parent: Node3D, mesh_name: String, mesh: Mesh, origin: Vector3, color: Color) -> void:
	var part: MeshInstance3D = MeshInstance3D.new()
	part.name = mesh_name
	part.mesh = mesh
	part.position = origin
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	part.material_override = material
	parent.add_child(part)
