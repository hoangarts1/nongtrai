## CropPresentation -- C2 generated crop-stage presentation beneath FarmView roots.
## API:
##   static func render(crop: MeshInstance3D, crop_id: StringName, growth_ratio: float, crop_color: Color, withered: bool, watered: bool, cell: Vector2i) -> void
##   static func clear(crop: MeshInstance3D) -> void
class_name CropPresentation
extends RefCounted

const CATALOG: FarmingArtCatalog = preload("res://data/art/farming/chibi_farming_catalog.tres")
const ROOT_SURFACE_OFFSET: float = -0.16
const CLICK_WIDTH: float = 0.34
const CLICK_HEIGHT: float = 2.00

static var _scene_cache: Dictionary = {}

static func clear(crop: MeshInstance3D) -> void:
	for child: Node in crop.get_children():
		child.free()
	crop.mesh = null
	crop.material_override = null
	crop.rotation = Vector3.ZERO
	crop.scale = Vector3.ONE
	crop.set_meta("mature", false)
	crop.set_meta("withered", false)

static func render(
	crop: MeshInstance3D,
	crop_id: StringName,
	growth_ratio: float,
	_crop_color: Color,
	withered: bool,
	watered: bool,
	cell: Vector2i
) -> void:
	clear(crop)
	var stage_id: StringName = &"withered" if withered else StringName(str(_stage_from_growth(growth_ratio)))
	_set_click_bounds(crop)
	var scene: PackedScene = _load_stage_scene(crop_id, stage_id)
	if scene != null:
		var visual: Node3D = scene.instantiate() as Node3D
		if visual != null:
			visual.name = "CropVisual"
			visual.position = Vector3(0.0, ROOT_SURFACE_OFFSET, 0.0)
			visual.rotation.y = deg_to_rad(float(posmod(cell.x * 17 + cell.y * 31, 360)))
			_apply_runtime_readability(visual)
			crop.add_child(visual)
	else:
		_add_fallback_visual(crop, crop_id, withered)
	if watered and not withered:
		_add_dew(crop)
	crop.set_meta("stage_id", stage_id)
	crop.set_meta("mature", stage_id == &"3")
	crop.set_meta("withered", withered)

static func get_stage_id(growth_ratio: float, withered: bool = false) -> StringName:
	return &"withered" if withered else StringName(str(_stage_from_growth(growth_ratio)))

static func _stage_from_growth(growth_ratio: float) -> int:
	var ratio: float = clampf(growth_ratio, 0.0, 1.0)
	if ratio >= 0.999:
		return 3
	return clampi(floori(ratio * 3.0), 0, 2)

static func _set_click_bounds(crop: MeshInstance3D) -> void:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(CLICK_WIDTH, CLICK_HEIGHT, CLICK_WIDTH)
	crop.mesh = mesh
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 1.0, 1.0, 0.0)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	crop.material_override = material
	crop.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

static func _load_stage_scene(crop_id: StringName, stage_id: StringName) -> PackedScene:
	var path: String = CATALOG.get_crop_scene_path(crop_id, stage_id)
	if path.is_empty():
		return null
	if not _scene_cache.has(path):
		_scene_cache[path] = load(path) as PackedScene
	return _scene_cache[path] as PackedScene

static func _add_dew(crop: MeshInstance3D) -> void:
	var dew_root: Node3D = Node3D.new()
	dew_root.name = "WateredDew"
	crop.add_child(dew_root)
	for index: int in range(2):
		var dew: MeshInstance3D = MeshInstance3D.new()
		dew.name = "Dew_%d" % index
		var mesh: SphereMesh = SphereMesh.new()
		mesh.radius = 0.5
		mesh.height = 1.0
		mesh.radial_segments = 6
		mesh.rings = 3
		dew.mesh = mesh
		dew.scale = Vector3(0.060, 0.078, 0.060)
		dew.position = Vector3(-0.10 + float(index) * 0.20, 0.34 + float(index) * 0.06, 0.08)
		var readable_material: StandardMaterial3D = StandardMaterial3D.new()
		readable_material.albedo_color = CATALOG.dew_color
		readable_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		readable_material.roughness = 0.42
		dew.material_override = readable_material
		dew_root.add_child(dew)

static func _add_fallback_visual(crop: MeshInstance3D, crop_id: StringName, withered: bool) -> void:
	var visual: Node3D = Node3D.new()
	visual.name = "CropVisualFallback"
	visual.position = Vector3(0.0, ROOT_SURFACE_OFFSET + 0.24, 0.0)
	var body: MeshInstance3D = MeshInstance3D.new()
	body.name = "Fallback_%s" % String(crop_id)
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 8
	mesh.rings = 4
	body.mesh = mesh
	body.scale = Vector3(0.34, 0.48, 0.34)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color("8b704e") if withered else CATALOG.sparkle_color
	material.roughness = 0.85
	body.material_override = material
	visual.add_child(body)
	crop.add_child(visual)

static func _apply_runtime_readability(root: Node) -> void:
	for child: Node in root.get_children():
		if child is MeshInstance3D:
			var mesh: MeshInstance3D = child as MeshInstance3D
			var source: ShaderMaterial = mesh.material_override as ShaderMaterial
			if source != null:
				var color_value: Variant = source.get_shader_parameter(&"base_color")
				if color_value is Color:
					var material: StandardMaterial3D = StandardMaterial3D.new()
					material.albedo_color = (color_value as Color).lightened(0.04)
					material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
					material.roughness = 0.82
					mesh.material_override = material
		_apply_runtime_readability(child)
