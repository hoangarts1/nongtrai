extends GutTest

const CATALOG_PATH: String = "res://data/art/farming/chibi_farming_catalog.tres"
const PALETTE_PATH: String = "res://data/art/palette/chibi_valley.tres"
const VALIDATOR: Script = preload("res://scripts/core/data_validator.gd")
const MESH_AUDIT: Script = preload("res://tools/art/chibi/chibi_mesh_audit.gd")
const CROP_PRESENTATION: Script = preload("res://scripts/view/crop_presentation.gd")

const CROP_IDS: Array[String] = ["turnip", "spring_carrot", "spring_pea", "summer_tomato", "summer_corn", "autumn_wheat", "autumn_pumpkin", "winter_radish", "winter_cabbage"]
const ITEM_PATHS: Array[String] = [
	"res://data/items/turnip_seed.tres", "res://data/items/turnip.tres",
	"res://data/items/spring_carrot_seed.tres", "res://data/items/spring_carrot.tres",
	"res://data/items/spring_pea_seed.tres", "res://data/items/spring_pea.tres",
	"res://data/items/summer_tomato_seed.tres", "res://data/items/summer_tomato.tres",
	"res://data/items/summer_corn_seed.tres", "res://data/items/summer_corn.tres",
	"res://data/items/autumn_wheat_seed.tres", "res://data/items/autumn_wheat.tres",
	"res://data/items/autumn_pumpkin_seed.tres", "res://data/items/autumn_pumpkin.tres",
	"res://data/items/winter_radish_seed.tres", "res://data/items/winter_radish.tres",
	"res://data/items/winter_cabbage_seed.tres", "res://data/items/winter_cabbage.tres"
]

var _clock: Dictionary
var _paused: bool

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	GameClock.deserialize({"day_index": 0, "minute": 720, "season": "spring", "year": 1})
	GameClock.paused = false

func after_each() -> void:
	GameClock.deserialize(_clock)
	GameClock.paused = _paused

func test_catalog_and_all_generated_crop_stages_are_valid() -> void:
	var catalog: FarmingArtCatalog = load(CATALOG_PATH) as FarmingArtCatalog
	var palette: Resource = load(PALETTE_PATH) as Resource
	assert_not_null(catalog)
	assert_not_null(palette)
	assert_eq(catalog.validate().size(), 0)
	assert_eq(VALIDATOR.validate_farming_art_catalog_path(CATALOG_PATH).size(), 0)
	assert_eq(catalog.crop_ids.size(), 9)
	for crop_id: String in CROP_IDS:
		for stage: int in range(4):
			_assert_model(catalog.get_crop_scene_path(StringName(crop_id), StringName(str(stage))), int(palette.get_triangle_budget(&"crop")))
		_assert_model(catalog.get_crop_scene_path(StringName(crop_id), &"withered"), int(palette.get_triangle_budget(&"crop")))

func test_all_item_visual_assets_are_128px_stickers_and_ui_prefers_them() -> void:
	var items: Array[Resource] = []
	for item_path: String in ITEM_PATHS:
		var item: Resource = load(item_path) as Resource
		assert_not_null(item)
		items.append(item)
		var model_path: String = String(item.get("model_path"))
		var icon_path: String = String(item.get("icon_path"))
		_assert_model(model_path, 1500)
		assert_true(FileAccess.file_exists(icon_path), "Generated icon exists: %s" % icon_path)
		var icon: Image = Image.load_from_file(ProjectSettings.globalize_path(icon_path))
		assert_not_null(icon)
		assert_eq(icon.get_size(), Vector2i(128, 128))
		assert_lte(icon.get_pixel(0, 0).a, 0.04, "Sticker keeps transparent corners")
		assert_gt(_opaque_pixels(icon), 0)
		var texture: Texture2D = UiIcons.for_item(item.get("item_id"))
		assert_not_null(texture)
		assert_eq(texture.resource_path, icon_path, "Inventory item uses its generated sticker before SVG fallback")
	assert_eq(VALIDATOR.validate_item_visual_assets(items).size(), 0)

func test_tool_models_and_generated_crop_stage_runtime_keep_click_contract() -> void:
	var catalog: FarmingArtCatalog = load(CATALOG_PATH) as FarmingArtCatalog
	var palette: Resource = load(PALETTE_PATH) as Resource
	for tool_id: String in catalog.tool_ids:
		_assert_model(catalog.get_tool_scene_path(StringName(tool_id)), int(palette.get_triangle_budget(&"prop")))
		var tool_icon_path: String = catalog.get_tool_icon_path(StringName(tool_id))
		assert_true(FileAccess.file_exists(tool_icon_path))
		var tool_icon: Image = Image.load_from_file(ProjectSettings.globalize_path(tool_icon_path))
		assert_eq(tool_icon.get_size(), Vector2i(128, 128))
		assert_not_null(UiIcons.get_icon(StringName(tool_id)))
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	var cell: Vector2i = Vector2i(0, 0)
	assert_true(main.farm_state.till_cell(cell))
	assert_true(main.farm_state.plant_crop(cell, &"turnip"))
	await get_tree().process_frame
	var crop: Sprite2D = main.farm_view.get_crop_view(cell)
	assert_not_null(crop.texture)
	assert_eq(crop.get_meta("stage_id"), &"0")
	var sprout_image: Image = crop.texture.get_image()
	assert_gt(_opaque_pixels(sprout_image), 0)
	for _day: int in range(2):
		assert_true(main.farm_state.water_cell(cell))
		main.farm_state.advance_day()
	await get_tree().process_frame
	assert_eq(crop.get_meta("stage_id"), &"3")
	assert_gt(_opaque_pixels(crop.texture.get_image()), _opaque_pixels(sprout_image), "Mature 2D stage has a larger visible silhouette")
	var point: Vector2 = crop.get_global_transform_with_canvas() * Vector2(0,-40)
	assert_eq(main.farm_view.pick_crop(point, main.world.camera), cell, "C2 art keeps the mature crop selectable")

func test_farm_effects_follow_only_successful_tool_results() -> void:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	var cell: Vector2i = Vector2i(1, 1)
	var effects: FarmEffects = main.world.get_node("WorldCanvas/FarmEffects") as FarmEffects
	assert_not_null(effects)
	main.inventory.clear()
	main.tool_controller.select_seed()
	main.tool_controller.set("_hovered_cell", cell)
	main.tool_controller.call("_use_selected_tool")
	assert_eq(effects.get_child_count(), 0, "Rejected seed action has no C2 visual side effect")
	assert_true(main.farm_state.till_cell(cell))
	assert_eq(main.inventory.add_item(&"turnip_seed", 1), 1)
	main.tool_controller.call("_use_selected_tool")
	assert_gt(effects.get_child_count(), 0, "Successful existing seed action emits only a transient view effect")
	await get_tree().create_timer(0.70).timeout
	assert_eq(effects.get_child_count(), 0, "C2 effect cleans itself and leaves no persistent state")

func _assert_model(path: String, budget: int) -> void:
	assert_true(ResourceLoader.exists(path), "Generated model exists: %s" % path)
	var scene: PackedScene = load(path) as PackedScene
	assert_not_null(scene)
	var model: Node3D = scene.instantiate() as Node3D
	assert_not_null(model)
	add_child_autofree(model)
	assert_eq(MESH_AUDIT.validate_model(model, budget).size(), 0, "Generated model audit: %s" % path)
	assert_gt(MESH_AUDIT.triangle_count(model), 0)

func _opaque_pixels(image: Image) -> int:
	var total: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.04:
				total += 1
	return total
