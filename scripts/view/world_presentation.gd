## WorldPresentation — handmade scenery and lighting that preserves gameplay anchors.
## API:
##   func configure(main: Node) -> void
class_name WorldPresentation
extends Node3D

const WORLD_ART_FACTORY: Script = preload("res://scripts/view/world_art_factory.gd")
const CHARACTER_CATALOG_PATH: String = "res://data/art/characters/chibi_character_catalog.tres"

var _player_avatar: ChibiAvatar
var _player_profile: Dictionary = {}

func configure(main: Node) -> void:
	name = "WorldPresentation"
	var world: GrayBoxWorld = main.world as GrayBoxWorld
	var player: Player = world.player
	var visual: MeshInstance3D = player.get_node("Visual") as MeshInstance3D
	visual.hide()
	_player_avatar = ChibiAvatar.new()
	_player_avatar.name = "ChibiAvatar"
	player.add_child(_player_avatar)
	_player_profile = _default_player_profile()
	if _player_profile.is_empty():
		_player_avatar.configure(Color("a7bd88"))
	else:
		_player_avatar.configure_profile(_player_profile)
	WORLD_ART_FACTORY.build_cottage(world.get_node("House") as MeshInstance3D, Vector3(3.0, 2.1, 2.5), Color("f4e2b8"), Color("c47f64"))
	WORLD_ART_FACTORY.build_market(world.get_node("SeedShop") as MeshInstance3D)
	WORLD_ART_FACTORY.decorate_shipping_bin(world.get_node("ShippingBin") as MeshInstance3D)
	WORLD_ART_FACTORY.add_decorative_cottage(self, "VillageCottageMeadow", Vector3(-8.0, 0.82, 7.6), Vector3(1.8, 1.6, 1.6), Color("d9e6bd"), Color("77915e"))
	WORLD_ART_FACTORY.add_decorative_cottage(self, "VillageCottageHill", Vector3(8.7, 0.82, -5.4), Vector3(1.7, 1.6, 1.5), Color("d9c5a0"), Color("a86e5d"))
	WORLD_ART_FACTORY.add_ground_dressing(self)
	_tune_lighting(world)
	for cell: Vector2i in [Vector2i(-8, -5), Vector2i(-6, -6), Vector2i(-8, 1), Vector2i(8, -6), Vector2i(6, -8), Vector2i(-6, 11), Vector2i(10, 5)]:
		_tree(GridMath.cell_to_world(cell))
	WORLD_ART_FACTORY.add_rock_cluster(self, "RockClusterMoss", Vector3(-9.1, 0.0, 5.4), Color("7c8179"))
	WORLD_ART_FACTORY.add_rock_cluster(self, "RockClusterNorth", Vector3(-6.6, 0.0, 10.2), Color("7d8381"))
	WORLD_ART_FACTORY.add_rock_cluster(self, "RockClusterEast", Vector3(9.6, 0.0, 6.8), Color("7d8589"))
	WORLD_ART_FACTORY.add_rock_cluster(self, "RockClusterSouth", Vector3(7.6, 0.0, -7.6), Color("847e75"))

func configure_player_appearance(customization: Dictionary) -> void:
	if _player_avatar == null:
		return
	if _player_profile.is_empty():
		_player_profile = _default_player_profile()
	if _player_profile.is_empty():
		return
	_player_avatar.configure_profile(_player_profile, customization)

func get_player_avatar() -> ChibiAvatar:
	return _player_avatar

func _default_player_profile() -> Dictionary:
	var catalog: Resource = load(CHARACTER_CATALOG_PATH) as Resource
	if catalog == null or not catalog.has_method(&"get_default_player_appearance"):
		return {}
	return _appearance_dictionary(catalog.call(&"get_default_player_appearance"))

func _appearance_dictionary(appearance: Variant) -> Dictionary:
	if appearance is Dictionary:
		return (appearance as Dictionary).duplicate(true)
	if appearance is Resource and (appearance as Resource).has_method(&"to_builder_dictionary"):
		var profile: Variant = (appearance as Resource).call(&"to_builder_dictionary")
		if profile is Dictionary:
			return (profile as Dictionary).duplicate(true)
	return {}

func _tune_lighting(world: GrayBoxWorld) -> void:
	var environment: Environment = world.world_environment.environment
	if environment != null:
		environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
		environment.tonemap_exposure = 1.0
		environment.tonemap_white = 4.4
		environment.adjustment_enabled = true
		environment.adjustment_saturation = 1.05
		environment.adjustment_contrast = 1.02
		environment.glow_enabled = true
		environment.glow_bloom = 0.055
		environment.glow_hdr_scale = 1.0
		environment.fog_enabled = true
		environment.fog_density = 0.003
		environment.fog_light_color = Color("f4ddb4")
		environment.fog_light_energy = 0.45
		environment.fog_sun_scatter = 0.24
		environment.fog_sky_affect = 0.10
	world.sun.directional_shadow_max_distance = 46.0
	world.sun.directional_shadow_fade_start = 0.78
	world.sun.directional_shadow_blend_splits = true
	world.sun.light_angular_distance = 0.82

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
