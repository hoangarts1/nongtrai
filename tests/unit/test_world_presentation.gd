extends GutTest

var _clock: Dictionary
var _paused: bool
func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	GameClock.deserialize({"day_index":0,"minute":720,"season":"spring","year":1})
	GameClock.paused = true
func after_each() -> void:
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
func _game() -> Node:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	add_child_autofree(main)
	main.set("_game_started",true)
	main.start_menu.hide()
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	return main

func test_world_art_separates_readable_places_without_changing_their_interaction_logic() -> void:
	var main: Node = _game()
	await _settle()
	var world: GrayBoxWorld = main.world
	var anchors: Array[Node2D] = []
	var positions: Array[Vector2] = []
	for anchor_name: String in ["House","SeedShop","ShippingBin"]:
		var anchor: Node2D = world.objects.get_node(anchor_name)
		assert_not_null(anchor.get_node_or_null("Placeholder"))
		anchors.append(anchor)
		positions.append(anchor.global_position)
	assert_eq(anchors[1].global_position, world.seed_shop_marker.global_position)
	assert_eq(anchors[2].global_position, world.shipping_bin_marker.global_position)
	assert_gt(world.shipping_bin_marker.global_position.distance_to(world.bed_marker.global_position),100.0)
	assert_eq(world.grid.global_to_cell(world.bed_marker.global_position),Vector2i(11,10))
	assert_eq(world.grid.global_to_cell(world.shipping_bin_marker.global_position),Vector2i(5,10))
	assert_eq(world.grid.global_to_cell(world.seed_shop_marker.global_position),Vector2i(-2,7))
	for npc_id: StringName in [&"minh",&"linh"]:
		var home: Node2D = main.npc_system.homes[npc_id]
		assert_eq(home.global_position,world.cell_to_global(main.npc_system.state.scheduler.location_cell(main.npc_system.state.get_npc(npc_id).home_location)))
	GameClock.season = &"autumn"
	GameClock.season_changed.emit(&"autumn")
	await _settle()
	for index: int in range(anchors.size()):
		assert_eq(anchors[index].global_position,positions[index],"Seasonal presentation cannot move an anchor")
	var farm_cells: Rect2i = Rect2i(0,0,6,6)
	assert_true(main.presentation.get_world_art_root().y_sort_enabled)
	for child: Node in main.presentation.get_world_art_root().get_children():
		if child is PlaceholderWorld2D and child.has_meta("cell"):
			assert_false(farm_cells.has_point(child.get_meta("cell")),"Passive scenery stays outside farm")
	assert_gt(main.presentation.get_season_fx().get_active_effect_count(),0)

func test_lighting_is_gentle_forward_plus_post_processing_with_soft_sun_shadows() -> void:
	# 3D postprocessing is intentionally replaced by world-only CanvasModulate.
	var main: Node = _game()
	GameClock.set_time(12,0)
	var daylight: Color = main.world.world_tint.color
	assert_gt(daylight.get_luminance(),0.8)
	assert_false(main.world.house_light.visible)
	GameClock.set_time(22,0)
	assert_lt(main.world.world_tint.color.get_luminance(),daylight.get_luminance())
	assert_true(main.world.house_light.visible)
	assert_eq(main.layer,1,"The HUD stays outside world modulation/camera transforms")

func test_crop_visuals_progress_from_sprout_to_mature_and_clear_after_harvest() -> void:
	var main: Node = _game()
	var cell: Vector2i = Vector2i.ZERO
	assert_true(main.farm_state.till_cell(cell))
	assert_true(main.farm_state.plant_crop(cell,&"spring_carrot"))
	var crop: Sprite2D = main.farm_view.get_crop_view(cell)
	assert_true(crop.visible)
	assert_eq(crop.get_meta("stage_id"),&"0")
	var sprout: PackedByteArray = crop.texture.get_image().get_data()
	for _day: int in range(3):
		assert_true(main.farm_state.water_cell(cell))
		main.day_simulator.simulate_day(main.farm_state)
	assert_eq(crop.get_meta("stage_id"),&"3")
	assert_true(bool(crop.get_meta("mature")))
	assert_ne(crop.texture.get_image().get_data(),sprout)
	assert_true(main.farm_state.harvest_cell(cell).get("success",false))
	assert_false(crop.visible)
	assert_null(crop.texture)
	assert_eq(crop.get_child_count(),0)

func test_tilled_soil_has_furrows_and_water_uses_a_subtle_moisture_sheen() -> void:
	var main: Node = _game()
	var cell: Vector2i = Vector2i.ZERO
	assert_true(main.farm_state.till_cell(cell))
	assert_true(main.farm_state.plant_crop(cell,&"turnip"))
	var soil: Polygon2D = main.farm_view.get_cell_view(cell)
	assert_not_null(soil.get_node_or_null("SoilFurrow_0"))
	assert_null(soil.get_node_or_null("MoistureSheen"))
	assert_eq(main.world.farmland.get_cell_atlas_coords(cell),Vector2i(1,0))
	assert_true(main.farm_state.water_cell(cell))
	assert_not_null(soil.get_node_or_null("MoistureSheen"))
	assert_eq(main.world.farmland.get_cell_atlas_coords(cell),Vector2i(2,0))

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
