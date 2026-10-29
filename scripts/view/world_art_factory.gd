class_name WorldArtFactory
extends RefCounted

const CATALOG_PATH: String = "res://data/art/world/chibi_world_catalog.tres"
const PALETTE_PATH: String = "res://data/art/palette/chibi_valley.tres"

static var _scene_cache: Dictionary = {}

static func replace_anchor_visual(anchor: MeshInstance3D, asset_id: StringName, season: StringName = &"spring") -> bool:
	if anchor == null:
		return false
	var visual: Node3D = create_asset(asset_id, season)
	if visual == null:
		return false
	_clear_anchor_art(anchor)
	anchor.mesh = null
	anchor.material_override = null
	for child: Node in visual.get_children():
		visual.remove_child(child)
		if child is Node3D:
			var part: Node3D = child as Node3D
			part.owner = null
			part.position.y -= anchor.position.y
			part.set_meta("c3_world_part", true)
			anchor.add_child(part)
	visual.free()
	anchor.set_meta("c3_world_asset_id", asset_id)
	return true

static func create_asset(asset_id: StringName, season: StringName = &"spring") -> Node3D:
	var scene: PackedScene = _load_asset_scene(asset_id)
	if scene == null:
		return _fallback_asset(asset_id, season)
	var asset: Node3D = scene.instantiate() as Node3D
	if asset == null:
		return _fallback_asset(asset_id, season)
	asset.name = String(asset_id).to_pascal_case()
	asset.set_meta("c3_world_asset_id", asset_id)
	apply_season(asset, season)
	return asset

static func apply_season(root: Node, season: StringName) -> void:
	if root == null:
		return
	_apply_season_recursive(root, season)

static func build_cottage(anchor: MeshInstance3D, _size: Vector3, _wall_color: Color, _roof_color: Color) -> void:
	if not replace_anchor_visual(anchor, &"bld_npc_cottage"):
		_add_legacy_box(anchor, "CottageWalls", Color("e3d4ad"), Vector3(2.2, 1.8, 2.0))

static func build_market(anchor: MeshInstance3D) -> void:
	if not replace_anchor_visual(anchor, &"bld_seed_market"):
		_add_legacy_box(anchor, "MarketFallback", Color("bd8e5d"), Vector3(2.0, 1.0, 1.2))

static func decorate_shipping_bin(anchor: MeshInstance3D) -> void:
	if not replace_anchor_visual(anchor, &"bld_shipping_bin"):
		_add_legacy_box(anchor, "BinFallback", Color("a97750"), Vector3(1.2, 0.8, 0.9))

static func add_decorative_cottage(parent: Node3D, cottage_name: String, origin: Vector3, _size: Vector3, _wall_color: Color, _roof_color: Color) -> MeshInstance3D:
	var anchor: MeshInstance3D = MeshInstance3D.new()
	anchor.name = cottage_name
	anchor.position = origin
	parent.add_child(anchor)
	build_cottage(anchor, Vector3.ZERO, Color.WHITE, Color.WHITE)
	return anchor

static func add_ground_dressing(parent: Node3D) -> Node3D:
	var dressing: Node3D = Node3D.new()
	dressing.name = "GroundDressing"
	parent.add_child(dressing)
	for index: int in range(3):
		var stone: Node3D = create_asset(&"prop_path_stone")
		stone.name = "PathStone_%d" % index
		stone.position = Vector3(6.15 + float(index) * 0.92, 0.0, 9.92)
		dressing.add_child(stone)
	return dressing

static func add_rock_cluster(parent: Node3D, cluster_name: String, origin: Vector3, _stone_color: Color) -> Node3D:
	var cluster: Node3D = create_asset(&"prop_rock_cluster")
	cluster.name = cluster_name
	cluster.position = origin
	parent.add_child(cluster)
	return cluster

static func _load_asset_scene(asset_id: StringName) -> PackedScene:
	var catalog: Resource = load(CATALOG_PATH) as Resource
	if catalog == null or not catalog.has_method(&"get_model_path"):
		return null
	var path: String = String(catalog.call(&"get_model_path", asset_id))
	if path.is_empty():
		return null
	if not _scene_cache.has(path):
		_scene_cache[path] = load(path) as PackedScene
	return _scene_cache[path] as PackedScene

static func _palette_color(role: StringName, season: StringName) -> Color:
	var palette: Resource = load(PALETTE_PATH) as Resource
	if palette != null and palette.has_method(&"get_color"):
		var result: Variant = palette.call(&"get_color", role, season)
		if result is Color:
			return result as Color
	return Color.WHITE

static func _clear_anchor_art(anchor: MeshInstance3D) -> void:
	for child: Node in anchor.get_children():
		if child is MeshInstance3D or bool(child.get_meta("c3_world_part", false)):
			child.free()

static func _fallback_asset(asset_id: StringName, season: StringName) -> Node3D:
	var fallback: Node3D = Node3D.new()
	fallback.name = "%sFallback" % String(asset_id).to_pascal_case()
	var part: MeshInstance3D = MeshInstance3D.new()
	part.name = "FallbackMesh"
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 8
	mesh.rings = 4
	part.mesh = mesh
	part.position = Vector3(0.0, 0.5, 0.0)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = _palette_color(&"ui_accent", season)
	material.roughness = 0.88
	part.material_override = material
	fallback.add_child(part)
	return fallback

static func _add_legacy_box(anchor: MeshInstance3D, node_name: String, color: Color, size: Vector3) -> void:
	_clear_anchor_art(anchor)
	anchor.mesh = null
	var part: MeshInstance3D = MeshInstance3D.new()
	part.name = node_name
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	part.mesh = mesh
	part.position = Vector3(0.0, size.y * 0.5 - anchor.position.y, 0.0)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.86
	part.material_override = material
	anchor.add_child(part)

static func _apply_season_recursive(node: Node, season: StringName) -> void:
	if node is MeshInstance3D:
		var mesh: MeshInstance3D = node as MeshInstance3D
		var role: StringName = StringName(mesh.get_meta("art_role", ""))
		if not role.is_empty():
			_apply_season_material(mesh, role, season)
	for child: Node in node.get_children():
		_apply_season_recursive(child, season)

static func _apply_season_material(mesh: MeshInstance3D, role: StringName, season: StringName) -> void:
	var current: Material = mesh.material_override
	if current is ShaderMaterial:
		var source: ShaderMaterial = current as ShaderMaterial
		var shader_path: String = source.shader.resource_path if source.shader != null else ""
		var base_color: Color = _palette_color(role, season)
		if shader_path.ends_with("chibi_toon.gdshader"):
			_apply_readable_toon_material(mesh, base_color)
			return
		var runtime_material: ShaderMaterial = source.duplicate(false) as ShaderMaterial
		runtime_material.next_pass = null
		if shader_path.ends_with("chibi_water.gdshader"):
			runtime_material.set_shader_parameter(&"water_color", base_color)
			runtime_material.set_shader_parameter(&"foam_color", _palette_color(&"sunlight", season))
		else:
			runtime_material.set_shader_parameter(&"base_color", base_color)
			if shader_path.ends_with("chibi_foliage.gdshader"):
				runtime_material.set_shader_parameter(&"wind_color", _palette_color(&"sunlight", season))
		mesh.material_override = runtime_material
		return
	if bool(mesh.get_meta("c3_runtime_toon_material", false)):
		_apply_readable_toon_material(mesh, _palette_color(role, season))
		return
	var fallback: StandardMaterial3D = StandardMaterial3D.new()
	fallback.albedo_color = _palette_color(role, season)
	fallback.roughness = 0.86
	fallback.metallic = 0.05 if role == &"water" else 0.0
	mesh.material_override = fallback

static func _apply_readable_toon_material(mesh: MeshInstance3D, base_color: Color) -> void:
	# C0 keeps its toon/outline source material for isolated art review. The
	# existing DayNightProfile world lighting makes that custom light pass render
	# almost black, so C3 uses a local readable material only in runtime world
	# instances. The metadata retains that choice across later season changes.
	var readable: StandardMaterial3D = StandardMaterial3D.new()
	readable.albedo_color = base_color
	readable.roughness = 0.84
	readable.metallic = 0.0
	readable.emission_enabled = true
	readable.emission = base_color.darkened(0.64)
	readable.emission_energy_multiplier = 0.08
	mesh.material_override = readable
	mesh.set_meta("c3_runtime_toon_material", true)
