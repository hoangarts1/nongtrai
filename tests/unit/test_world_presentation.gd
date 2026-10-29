extends GutTest

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

func _game() -> Node:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	add_child_autofree(main)
	main.set("_game_started", true)
	main.start_menu.hide()
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	return main

func test_world_art_separates_readable_places_without_changing_their_interaction_logic() -> void:
	var main: Node = _game()
	await _settle()
	var world: GrayBoxWorld = main.world as GrayBoxWorld
	var house: MeshInstance3D = world.get_node("House") as MeshInstance3D
	var shop: MeshInstance3D = world.get_node("SeedShop") as MeshInstance3D
	var shipping_bin: MeshInstance3D = world.get_node("ShippingBin") as MeshInstance3D
	var house_position: Vector3 = house.global_position
	var shop_position: Vector3 = shop.global_position
	var shipping_bin_position: Vector3 = shipping_bin.global_position
	assert_not_null(house.get_node_or_null("CottageRoof"))
	assert_not_null(house.get_node_or_null("Door"))
	assert_not_null(shop.get_node_or_null("MarketRoof"))
	assert_not_null(shop.get_node_or_null("MarketSign"))
	assert_not_null(shipping_bin.get_node_or_null("BinLid"))
	assert_eq(world.seed_shop_marker.global_position, Vector3(-2.0, 0.0, 7.5), "Market keeps the tested seed-shop marker")
	assert_eq(world.shipping_bin_marker.global_position, Vector3(5.2, 0.0, 10.0), "Bin and its interaction marker move together")
	assert_eq(shipping_bin.global_position.x, world.shipping_bin_marker.global_position.x)
	assert_gt(world.shipping_bin_marker.global_position.distance_to(world.bed_marker.global_position), 4.0, "The sale point is visibly separate from the player cottage")
	var minh_home: MeshInstance3D = main.npc_system.get_node("Home_minh") as MeshInstance3D
	var linh_home: MeshInstance3D = main.npc_system.get_node("Home_linh") as MeshInstance3D
	var minh_home_position: Vector3 = minh_home.global_position
	var linh_home_position: Vector3 = linh_home.global_position
	assert_not_null(minh_home.get_node_or_null("CottageRoof"))
	assert_not_null(linh_home.get_node_or_null("CottageRoof"))
	var presentation: WorldPresentation = main.get_node("WorldPresentation") as WorldPresentation
	assert_not_null(presentation)
	assert_eq(house.get_meta("c3_world_asset_id"), &"bld_player_cottage")
	assert_eq(shop.get_meta("c3_world_asset_id"), &"bld_seed_market")
	assert_eq(shipping_bin.get_meta("c3_world_asset_id"), &"bld_shipping_bin")
	assert_eq(minh_home.get_meta("c3_world_asset_id"), &"bld_npc_cottage")
	var world_art: Node3D = presentation.get_world_art_root()
	assert_not_null(world_art)
	assert_not_null(world_art.get_node_or_null("C3Trees/EnvRoundTree_0"))
	assert_not_null(world_art.get_node_or_null("C3Terrain/EnvCliffBorder_0"))
	assert_not_null(world_art.get_node_or_null("C3Landmarks/BldObservatory_0"))
	assert_not_null(world_art.get_node_or_null("C3VillageProps/PropFenceWood_0"))
	assert_not_null(world_art.get_node_or_null("C3VillageProps/PropWell_0"))
	GameClock.season = &"autumn"
	GameClock.season_changed.emit(&"autumn")
	await _settle()
	assert_eq(house.global_position, house_position, "Seasonal art must not move the player-home interaction anchor")
	assert_eq(shop.global_position, shop_position, "Seasonal art must not move the seed-shop interaction anchor")
	assert_eq(shipping_bin.global_position, shipping_bin_position, "Seasonal art must not move the shipping-bin interaction anchor")
	assert_eq(minh_home.global_position, minh_home_position, "Seasonal art must not move Minh's home marker")
	assert_eq(linh_home.global_position, linh_home_position, "Seasonal art must not move Linh's home marker")
	var season_fx: Node = presentation.get_season_fx()
	assert_not_null(season_fx)
	assert_true(season_fx.has_method(&"get_active_effect_count"))
	assert_gt(int(season_fx.call(&"get_active_effect_count")), 0)
	var farm_cells := Rect2i(Vector2i.ZERO, Vector2i(6, 6))
	for group: Node in world_art.get_children():
		for asset: Node in group.get_children():
			if asset is Node3D:
				assert_false(farm_cells.has_point(GridMath.world_to_cell((asset as Node3D).global_position)), "C3 decoration is outside tillable cells: %s" % asset.name)

func test_lighting_is_gentle_forward_plus_post_processing_with_soft_sun_shadows() -> void:
	var main: Node = _game()
	await _settle()
	var world: GrayBoxWorld = main.world as GrayBoxWorld
	var environment: Environment = world.world_environment.environment
	assert_eq(environment.tonemap_mode, Environment.TONE_MAPPER_FILMIC)
	assert_true(environment.adjustment_enabled)
	assert_true(environment.glow_enabled)
	assert_true(environment.fog_enabled)
	assert_gt(environment.glow_bloom, 0.0)
	assert_gt(environment.fog_density, 0.0)
	assert_gt(environment.fog_light_color.r, environment.fog_light_color.b, "Daylight mist is warm rather than blue-grey")
	assert_true(world.sun.shadow_enabled)
	assert_true(world.sun.directional_shadow_blend_splits)
	assert_gt(world.sun.light_angular_distance, 0.0)

func test_crop_visuals_progress_from_sprout_to_mature_and_clear_after_harvest() -> void:
	var main: Node = _game()
	var cell := Vector2i(0, 0)
	assert_true(main.farm_state.till_cell(cell))
	assert_true(main.farm_state.plant_crop(cell, &"spring_carrot"))
	await _settle()
	var crop: MeshInstance3D = main.farm_view.get_crop_view(cell)
	assert_true(crop.visible)
	assert_true(crop.mesh is BoxMesh, "C2 keeps a stable crop click bound under generated art")
	assert_eq(crop.get_meta("stage_id"), &"0")
	assert_not_null(crop.get_node_or_null("CropVisual/Leaf_0"), "New plants load a distinct generated sprout")
	for _day: int in range(3):
		assert_true(main.farm_state.water_cell(cell))
		main.day_simulator.simulate_day(main.farm_state)
	await _settle()
	assert_eq(crop.get_meta("stage_id"), &"3")
	assert_not_null(crop.get_node_or_null("CropVisual/RootBody"), "Mature roots receive a generated crop body")
	assert_not_null(crop.get_node_or_null("CropVisual/MatureSparkles"), "Mature roots receive a view-only sparkle")
	assert_true(main.farm_state.harvest_cell(cell).get("success", false))
	await _settle()
	assert_false(crop.visible)
	assert_null(crop.mesh)
	assert_eq(crop.get_child_count(), 0)

func test_tilled_soil_has_furrows_and_water_uses_a_subtle_moisture_sheen() -> void:
	var main: Node = _game()
	var cell: Vector2i = Vector2i(0, 0)
	assert_true(main.farm_state.till_cell(cell))
	assert_true(main.farm_state.plant_crop(cell, &"turnip"))
	await _settle()
	var soil: MeshInstance3D = main.farm_view.get_cell_view(cell)
	assert_not_null(soil.get_node_or_null("SoilFurrow_0"))
	assert_null(soil.get_node_or_null("MoistureSheen"))
	assert_true(main.farm_state.water_cell(cell))
	await _settle()
	assert_not_null(soil.get_node_or_null("MoistureSheen"))

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func _find_c3_asset(root: Node, asset_id: StringName) -> Node3D:
	if root is Node3D and StringName(root.get_meta("c3_world_asset_id", "")) == asset_id:
		return root as Node3D
	for child: Node in root.get_children():
		var found: Node3D = _find_c3_asset(child, asset_id)
		if found != null:
			return found
	return null
