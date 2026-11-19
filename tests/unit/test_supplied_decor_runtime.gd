extends GutTest

var _main: Node
var _viewport: SubViewport
var _clock: Dictionary
var _paused: bool

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152, 648)
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
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	SaveService.delete_save(1)

func test_nine_decor_appear_while_every_legacy_cell_texture_pivot_and_collider_stays() -> void:
	var before: Dictionary = _owners()
	var seen: PackedStringArray = []
	var legacy: Dictionary = {}
	for root: Node in _main.presentation.get_world_art_root().get_children():
		if not root is SuppliedSceneryView:
			continue
		var cell: Vector2i = root.get_meta("cell")
		var entry: Dictionary = WorldPresentation.SCENERY_CATALOG.get_entry(root.get_meta("asset_id"))
		assert_eq(root.global_position, _main.world.cell_to_global(cell))
		assert_eq(root.sprite.texture.resource_path, entry.path)
		assert_eq(root.sprite.position, -entry.pivot * entry.scale)
		assert_eq(root.sprite.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST)
		if entry.kind in [&"rock", &"grass_clump"]:
			var value: int = absi(cell.x*92837111+cell.y*689287499+314159)
			var offset: Vector2i = Vector2i(17, 3) if value%100 < 7 else Vector2i(5, 29)
			var size: String = ["small", "medium", "large"][absi((cell.x+41)*92837111+(cell.y+11)*689287499+314159)%3]
			var variant: int = absi((cell.x+offset.x)*92837111+(cell.y+offset.y)*689287499+314159)%3+1
			assert_eq(entry.id, StringName("%s_%s_%d" % [entry.kind, size, variant]))
			assert_eq(root.sprite.position, Vector2(-64, -128))
			assert_eq(root.has_node("WorldStaticCollision"), bool(entry.blocks))
			legacy[cell] = entry.id
		else:
			if not seen.has(String(entry.id)): seen.append(String(entry.id))
			assert_false(root.has_node("WorldStaticCollision"))
			assert_false(_main.presentation.call("_reserved_scenery_cell", cell))
			assert_false(_main.presentation.call("_decor_occupied", cell))
	var config: Dictionary = SceneryPlacementRules.compile(WorldPresentation.SCENERY_CATALOG)
	var region: Rect2i = _main.world.CONFIG.scenery_region
	var expected: Dictionary = {}
	for y: int in range(region.position.y, region.end.y):
		for x: int in range(region.position.x, region.end.x):
			var cell: Vector2i = Vector2i(x, y)
			var entry: Dictionary = SceneryPlacementRules.select(config, cell)
			if not entry.is_empty() and not _main.presentation.call("_reserved_scenery_cell", cell): expected[cell] = entry.id
	assert_eq(legacy, expected)
	seen.sort()
	assert_eq(seen, PackedStringArray(["flower_0", "flower_1", "flower_2", "flower_3", "pebble_0", "pebble_1", "tuft_0", "tuft_1", "tuft_2"]))
	assert_eq(_owners(), before)

func test_plot_changes_coalesce_view_reconciliation_without_duplicates_or_owner_mutation() -> void:
	var baseline: Dictionary = _layout()
	var cell: Vector2i = _small_roots()[0].get_meta("cell")
	assert_true(_main.farm_state.till_cell(cell))
	var changed: Dictionary = _owners()
	await _settle()
	for root: Node in _small_roots(): assert_ne(root.get_meta("cell"), cell)
	assert_eq(_owners(), changed)
	_main.farm_state.reset()
	await _settle()
	assert_eq(_layout(), baseline, "Clearing a transient plot restores the same derived art")
	var before: Dictionary = _owners()
	for repeat: int in range(4):
		_main.presentation.refresh_land(_main.land_ownership.get_owned_regions())
		await _settle()
		assert_eq(_layout(), baseline)
	assert_eq(_owners(), before)

func test_actual_land_purchase_load_and_new_game_never_leave_decor_on_owned_cells() -> void:
	_main.wallet.add_coins(900, &"test_scenery")
	_main.machine_shop_panel.open()
	await _settle()
	_main.land_runtime.open()
	await _settle()
	_main.land_runtime.purchase(&"farm_east_1")
	await _settle()
	assert_eq(_main.land_ownership.get_owned_regions().size(), 2)
	_assert_owned_clear()
	assert_true(_main.call("_save_game_to_slot", 1))
	var payload: Dictionary = SaveService.load_game(1)
	assert_eq(payload.meta.save_version, 16)
	var before: Dictionary = _owners()
	_main.call("_load_payload", payload)
	await _settle()
	_assert_owned_clear()
	assert_eq(_owners(), before)
	_main.call("_start_new_game", "Mai", "Garden")
	await _settle()
	assert_eq(_main.land_ownership.get_owned_regions().size(), 1)
	_assert_owned_clear()
	var layout: Dictionary = _layout()
	_main.presentation.refresh_land(_main.land_ownership.get_owned_regions())
	await _settle()
	assert_eq(_layout(), layout)

func test_view_accepts_all_catalogue_textures_but_never_creates_input_physics_or_process() -> void:
	for entry: Dictionary in WorldPresentation.SCENERY_CATALOG.entries:
		var view: SuppliedSceneryView = SuppliedSceneryView.new()
		add_child(view)
		assert_true(view.configure(entry))
		assert_eq(view.get_child_count(), 1)
		assert_true(view.sprite is Sprite2D)
		assert_false(view.is_processing())
		assert_eq(view.sprite.position, -entry.pivot * entry.scale)
		assert_false(view.configure({}))
		assert_null(view.sprite.texture)
		assert_false(view.visible)
		view.free()

func _assert_owned_clear() -> void:
	for root: Node in _main.presentation.get_world_art_root().get_children():
		if not root.has_meta("cell"): continue
		for region: Rect2i in _main.land_ownership.get_owned_regions(): assert_false(region.has_point(root.get_meta("cell")))

func _small_roots() -> Array[Node]:
	var roots: Array[Node] = []
	for root: Node in _main.presentation.get_world_art_root().get_children():
		if root.get_meta("scenery_kind", &"") in [&"flower", &"pebble", &"tuft"]: roots.append(root)
	return roots

func _layout() -> Dictionary:
	var result: Dictionary = {}
	for root: Node in _main.presentation.get_world_art_root().get_children():
		if root is SuppliedSceneryView:
			var key: Vector2i = root.get_meta("cell")
			assert_false(result.has(key))
			result[key] = root.get_meta("asset_id")
	return result

func _owners() -> Dictionary:
	return {"clock":GameClock.serialize(), "farm":_main.farm_state.serialize(), "bag":_main.inventory.serialize(), "wallet":_main.wallet.serialize(), "water":_main.watering_can.serialize(), "coop":_main.chicken_coop.serialize(), "weather":_main.weather_state.serialize(), "ledger":_main.day_end_flow.ledger.serialize(), "stock":_main.machine_inventory.serialize(), "placements":_main.machine_placements.serialize(), "jobs":_main.machine_operations.serialize(), "land":_main.land_ownership.serialize(), "social":_main.npc_system.state.serialize()}

func _settle() -> void:
	for frame: int in range(5): await get_tree().process_frame
