extends GutTest

const CATALOG_PATH: String = "res://data/art/world/chibi_world_catalog.tres"
const PALETTE_PATH: String = "res://data/art/palette/chibi_valley.tres"
const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const VALIDATOR: Script = preload("res://scripts/core/data_validator.gd")
const AUDIT: Script = preload("res://tools/art/chibi/chibi_mesh_audit.gd")

var _clock: Dictionary
var _paused: bool

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	GameClock.deserialize({"day_index": 0, "minute": 720, "season": "spring", "year": 1})
	GameClock.paused = true

func after_each() -> void:
	GameClock.deserialize(_clock)
	GameClock.paused = _paused

func test_c3_catalog_generated_models_and_passive_placements_are_safe() -> void:
	var catalog: Resource = load(CATALOG_PATH) as Resource
	var palette: Resource = load(PALETTE_PATH) as Resource
	assert_not_null(catalog)
	assert_not_null(palette)
	assert_true(catalog.has_method(&"validate"))
	assert_eq((catalog.call(&"validate") as PackedStringArray).size(), 0)
	assert_eq(VALIDATOR.validate_world_art_catalog_path(CATALOG_PATH).size(), 0)
	var asset_ids: PackedStringArray = catalog.get("asset_ids") as PackedStringArray
	assert_eq(asset_ids.size(), 21)
	var farm_cells: Rect2i = Rect2i(Vector2i.ZERO, Vector2i(6, 6))
	var protected_positions: Array[Vector3] = [Vector3(11.0, 0.0, 10.0), Vector3(-2.0, 0.0, 7.5), Vector3(5.2, 0.0, 10.0)]
	for asset_name: String in asset_ids:
		var asset_id: StringName = StringName(asset_name)
		var path: String = String(catalog.call(&"get_model_path", asset_id))
		assert_true(ResourceLoader.exists(path), "Generated C3 model exists: %s" % path)
		var scene: PackedScene = load(path) as PackedScene
		assert_not_null(scene)
		var model: Node3D = scene.instantiate() as Node3D
		assert_not_null(model)
		var kind: StringName = catalog.call(&"get_asset_kind", asset_id) as StringName
		var budget_kind: StringName = &"building" if kind == &"building" else (&"tree" if kind == &"tree" else &"prop")
		assert_eq(AUDIT.validate_model(model, int(palette.call(&"get_triangle_budget", budget_kind))).size(), 0, "C3 mesh audit: %s" % path)
		assert_gt(AUDIT.triangle_count(model), 0)
		model.free()
		var placements: Array[Vector3] = catalog.call(&"get_placements", asset_id) as Array[Vector3]
		for location: Vector3 in placements:
			assert_false(farm_cells.has_point(GridMath.world_to_cell(location)), "C3 placement is outside FarmView: %s" % asset_id)
			for protected_position: Vector3 in protected_positions:
				assert_gt(Vector2(location.x, location.z).distance_to(Vector2(protected_position.x, protected_position.z)), 2.5, "C3 decoration clears an interaction reach: %s" % asset_id)

func test_c3_season_fx_observes_existing_clock_and_weather_within_cap() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	await _settle()
	var presentation: WorldPresentation = main.get_node("WorldPresentation") as WorldPresentation
	var fx: Node = presentation.get_season_fx()
	var catalog: Resource = load(CATALOG_PATH) as Resource
	var cap: int = int(catalog.get("ambient_effect_cap"))
	assert_not_null(fx)
	for season: StringName in [&"spring", &"summer", &"autumn", &"winter"]:
		GameClock.season = season
		GameClock.season_changed.emit(season)
		await _settle()
		assert_true(String(fx.call(&"get_current_mode")).begins_with(String(season)))
		assert_lte(int(fx.call(&"get_active_effect_count")), cap)
	GameClock.season = &"summer"
	GameClock.season_changed.emit(&"summer")
	GameClock.set_time(12, 0)
	main.weather_state.call("force_weather", &"sunny")
	await _settle()
	assert_not_null(fx.get_node_or_null("SeasonalEffects/EnvButterflyAmbient"))
	GameClock.set_time(20, 0)
	await _settle()
	assert_not_null(fx.get_node_or_null("SeasonalEffects/EnvFireflyAmbient"))
	main.weather_state.call("force_weather", &"rain")
	await _settle()
	assert_not_null(fx.get_node_or_null("SeasonalEffects/RainRipples"))
	assert_lte(int(fx.call(&"get_active_effect_count")), cap)
	var tree_crown: MeshInstance3D = presentation.get_world_art_root().get_node("C3Trees/EnvRoundTree_0/TreeCrown0") as MeshInstance3D
	var material: ShaderMaterial = tree_crown.material_override as ShaderMaterial
	var palette: Resource = load(PALETTE_PATH) as Resource
	assert_not_null(material)
	assert_not_null(material.shader)
	assert_true(material.shader.resource_path.ends_with("chibi_foliage.gdshader"))
	assert_eq(material.get_shader_parameter(&"base_color"), palette.call(&"get_color", &"foliage", &"summer"))
	var cottage_wall: MeshInstance3D = main.world.get_node("House/CottageWalls") as MeshInstance3D
	var cottage_material: StandardMaterial3D = cottage_wall.material_override as StandardMaterial3D
	assert_not_null(cottage_material)
	assert_eq(cottage_material.albedo_color, palette.call(&"get_color", &"wood", &"summer"))
	assert_true(cottage_material.emission_enabled, "C3 uses a local readable override for the existing DayNightProfile world lighting")

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
