extends GutTest

var _main: Node
var _viewport: SubViewport
var _clock: Dictionary
var _paused: bool
var _locale: String

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152,648)
	_viewport.world_2d = World2D.new()
	_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_main.call("_start_new_game", "Mai", "Garden")
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	GameClock.paused = true
	await _settle()

func after_each() -> void:
	_viewport.free()
	TranslationServer.set_locale(_locale)
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	SaveService.delete_save(1)

func test_supplied_objects_keep_exact_legacy_tree_roots_cells_and_grounded_shared_view() -> void:
	var before: Dictionary = _owners()
	var expected: Array[Vector2i] = []
	for point: Vector3 in WorldPresentation.CATALOG.call("get_placements", &"env_round_tree"):
		var cell: Vector2i = GridMath.world_to_cell(point)
		if _main.presentation.call("_owned_cell", cell) or WaterSourceRules.reserved_cells(preload("res://data/water_sources.tres")).has(cell) or WorldPresentation.COOP_SITE.reserved_cells().has(cell): continue
		expected.append(cell)
	var actual: Array[Vector2i] = []
	var ids: Dictionary = {}
	for tree: Node2D in _trees():
		var cell: Vector2i = tree.get_meta("cell")
		actual.append(cell)
		assert_eq(tree.name, StringName("Tree_%d" % (actual.size()-1)))
		assert_eq(tree.global_position, _main.world.grid.cell_to_global(cell))
		assert_eq(tree.z_index, 0)
		var visual: SuppliedSceneryView = tree.get_node("Visual") as SuppliedSceneryView
		var entry: Dictionary = WorldPresentation.SCENERY_CATALOG.get_entry(tree.get_meta("asset_id"))
		assert_eq(entry.kind, &"object")
		assert_eq(visual.position, Vector2.ZERO)
		assert_eq(visual.sprite.position, -entry.pivot)
		assert_eq(visual.sprite.texture.resource_path, entry.path)
		assert_eq(visual.sprite.scale, Vector2.ONE)
		assert_false(tree.has_meta("scenery_kind"), "Tree wrappers preserve the scattered-scenery API boundary")
		assert_eq(tree.find_children("*", "PhysicsBody2D", true, false).size(), 0)
		ids[entry.id] = true
	assert_eq(actual, expected)
	assert_true(ids.has(&"bush"))
	assert_true(ids.has(&"tree_fruit"))
	assert_eq(_owners(), before)
	for key: String in ["House", "SeedShop", "ShippingBin"]:
		assert_true(_main.world.objects.get_node(key+"/Placeholder") is PlaceholderWorld2D)
	var config: Dictionary = _main.presentation.get("_scenery_config")
	var count: int = _trees().size()
	_main.presentation.set("_scenery_config", {})
	_main.presentation.call("_build_trees")
	assert_eq(_trees().size(), count, "An invalid compiled catalogue cannot partially construct trees")
	_main.presentation.set("_scenery_config", config)
	assert_null(SuppliedSceneryView.create_tall({}, Vector2i.ZERO, 0))

func test_legacy_plot_and_current_npc_path_hide_only_art_then_restore_same_root() -> void:
	var tree: Node2D
	for candidate: Node2D in _trees():
		if candidate.visible:
			tree = candidate
			break
	assert_not_null(tree)
	var count: int = _trees().size()
	var cell: Vector2i = tree.get_meta("cell")
	var instance: int = tree.get_instance_id()
	assert_true(_main.farm_state.till_cell(cell))
	var before: Dictionary = _owners()
	await _settle()
	assert_false(tree.visible)
	assert_eq(_trees().size(), count)
	assert_eq(_owners(), before)
	_main.farm_state.reset()
	await _settle()
	assert_true(tree.visible)
	var paths: Dictionary = _main.npc_system.state.paths.duplicate(true)
	var npc_id: StringName = _main.npc_system.state.cells.keys()[0]
	_main.npc_system.state.paths[npc_id] = [cell]
	_main.presentation.refresh_land(_main.land_ownership.get_owned_regions())
	await _settle()
	assert_false(tree.visible)
	_main.npc_system.state.paths = paths
	_main.presentation.refresh_land(_main.land_ownership.get_owned_regions())
	await _settle()
	assert_true(tree.visible)
	assert_eq(tree.get_instance_id(), instance)

func test_locale_season_save_load_and_refresh_preserve_objects_without_touching_progress() -> void:
	var original: Dictionary = _layout()
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for season: StringName in [&"spring", &"autumn", &"winter"]:
			GameClock.season = season
			GameClock.season_changed.emit(season)
			var before: Dictionary = _owners()
			_main.presentation.refresh_land(_main.land_ownership.get_owned_regions())
			await _settle()
			assert_eq(_layout(), original)
			assert_eq(_owners(), before)
	assert_true(_main.call("_save_game_to_slot", 1))
	var payload: Dictionary = SaveService.load_game(1)
	assert_eq(payload.meta.save_version, 15)
	var before: Dictionary = _owners()
	_main.call("_load_payload", payload)
	await _settle()
	assert_eq(_layout(), original)
	assert_eq(_owners(), before)
	_main.call("_start_new_game", "Mai", "Garden")
	await _settle()
	assert_eq(_layout(), original)

func _trees() -> Array[Node2D]:
	var result: Array[Node2D] = []
	for node: Node in _main.presentation.get_world_art_root().get_children():
		if node.get_meta("passive_tree", false): result.append(node as Node2D)
	return result

func _layout() -> Dictionary:
	var result: Dictionary = {}
	for tree: Node2D in _trees():
		var visual: SuppliedSceneryView = tree.get_node("Visual") as SuppliedSceneryView
		result[tree.get_meta("cell")] = {"id":tree.get_meta("asset_id"), "position":tree.global_position, "offset":visual.sprite.position, "color":visual.sprite.modulate}
	return result

func _owners() -> Dictionary:
	return {"clock":GameClock.serialize(), "farm":_main.farm_state.serialize(), "bag":_main.inventory.serialize(), "wallet":_main.wallet.serialize(), "water":_main.watering_can.serialize(), "coop":_main.chicken_coop.serialize(), "weather":_main.weather_state.serialize(), "ledger":_main.day_end_flow.ledger.serialize(), "stock":_main.machine_inventory.serialize(), "placements":_main.machine_placements.serialize(), "jobs":_main.machine_operations.serialize(), "land":_main.land_ownership.serialize(), "social":_main.npc_system.state.serialize()}

func _settle() -> void:
	for frame: int in range(5): await get_tree().process_frame
