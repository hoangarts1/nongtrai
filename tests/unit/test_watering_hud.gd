extends GutTest

const SOURCES: WaterSourceConfig = preload("res://data/water_sources.tres")
var main: Node
var viewport: SubViewport
var clock: Dictionary
var paused: bool
var accumulator: float
var locale: String

func before_each() -> void:
	clock = GameClock.serialize()
	paused = GameClock.paused
	accumulator = float(GameClock.get("_real_seconds_accumulator"))
	locale = TranslationServer.get_locale()
	GameClock.deserialize({"day_index":0,"minute":720,"season":"spring","year":1})
	GameClock.paused = true
	viewport = SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.world_2d = World2D.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)
	main = preload("res://scenes/main/main.tscn").instantiate()
	viewport.add_child(main)
	main.set("_game_started",true)
	main.set_process(false)
	main.start_menu.hide()
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	main.hotbar_panel.toolbar.request(2)
	await _settle()

func after_each() -> void:
	viewport.free()
	GameClock.deserialize(clock)
	GameClock.set("_real_seconds_accumulator",accumulator)
	GameClock.paused = paused
	TranslationServer.set_locale(locale)

func test_native_e_refills_all_three_sources_and_full_can_has_no_side_effect() -> void:
	for source: WaterSourceData in SOURCES.sources:
		main.world.player.move_to_cell(source.access_waypoints.back())
		main.watering_can.deserialize({"capacity":20,"charges":0})
		main.watering_runtime.refresh()
		await _settle()
		assert_eq(main.world.interaction_prompt.message_label.text,tr("WATER_REFILL_HINT"))
		var before: Dictionary = _owners()
		_key(KEY_E)
		await _settle()
		assert_eq(main.watering_can.get_charges(),20)
		assert_eq(main.hotbar_panel.toolbar.water_meter.amount.text,tr("WATER_CAN_COUNT") % [20,20])
		assert_eq(_owners(),before,"Only the actual can changes on refill")
		assert_false(main.shipping_bin_panel.visible)
		assert_false(main.seed_shop_panel.visible)
		var revision: int = main.watering_can.get_refill_revision()
		_key(KEY_E)
		await _settle()
		assert_eq(main.watering_can.get_refill_revision(),revision)
		assert_eq(main.world.interaction_prompt.message_label.text,tr("WATER_CAN_FULL"))
		await _capture("source_"+String(source.source_id))

func test_native_menu_e_wrong_tool_and_ordinary_bin_interaction_keep_their_context() -> void:
	main.world.player.move_to_cell(Vector2i(7,9))
	main.watering_can.deserialize({"capacity":20,"charges":5})
	main.watering_runtime.refresh()
	main.hotbar_panel.toolbar.request(0)
	assert_false(main.watering_runtime.can_refill().ok)
	_key(KEY_E)
	await _settle()
	assert_true(main.shipping_bin_panel.visible,"Ordinary hoe context keeps the nearby bin interaction")
	main.ui_coordinator.close_active()
	main.hotbar_panel.toolbar.request(2)
	main.inventory_panel.toggle_inventory()
	await _settle()
	assert_true(main.inventory_panel.visible)
	assert_false(main.world.player.movement_enabled)
	_key(KEY_E)
	await _settle()
	assert_eq(main.watering_can.get_charges(),5,"Menu E cannot refill the can")
	assert_false(main.shipping_bin_panel.visible)
	assert_false(main.watering_runtime.refill().ok)
	main.ui_coordinator.close_active()
	main.world.player.move_to_cell(Vector2i(3,3))
	assert_false(main.watering_runtime.refill().ok)
	main.world.player.move_to_cell(SOURCES.sources[2].label_cell)
	assert_false(main.watering_runtime.refill().ok,"Water interior is not a dry bank")
	assert_eq(main.watering_can.get_charges(),5)

func test_live_count_locales_small_default_large_and_pause_zoom_are_read_only() -> void:
	main.world.player.move_to_cell(Vector2i(7,9))
	var meter: LifeHudWaterMeter = main.hotbar_panel.toolbar.water_meter
	var identity: int = meter.get_instance_id()
	for language: String in ["vi","en"]:
		TranslationServer.set_locale(language)
		for width: int in [800,1152,1600]:
			viewport.size = Vector2i(width,width*9/16)
			for water: int in [20,7,0]:
				main.watering_can.deserialize({"capacity":20,"charges":water})
				main.watering_runtime.refresh()
				await _settle()
				assert_eq(meter.get_instance_id(),identity)
				assert_eq(meter.amount.text,tr("WATER_CAN_COUNT") % [water,20])
				assert_true(main.hotbar_panel.toolbar.get_global_rect().encloses(meter.get_global_rect()))
				assert_true(Rect2(Vector2.ZERO,Vector2(viewport.size)).encloses(meter.get_global_rect()))
				assert_eq(main.hotbar_panel.toolbar.buttons.size(),8)
				assert_eq(main.hotbar_panel.toolbar.caption.text,tr("UI_TOOL_WATER"))
				var before: Dictionary = _owners()
				var can: Dictionary = main.watering_can.serialize()
				await _capture("%s_%d_%d" % [language,width,water])
				assert_eq(_owners(),before)
				assert_eq(main.watering_can.serialize(),can)
	var before: Dictionary = main.watering_can.serialize()
	for zoom: float in SOURCES.world.zoom_levels:
		main.world.camera.zoom = Vector2.ONE*zoom
		main.world.camera.force_update_scroll()
		await _settle()
		assert_eq(main.watering_can.serialize(),before)
		assert_eq(main.world.pick_cell(main.world.grid.cell_to_screen(Vector2i(8,9))),Vector2i(8,9))

func _key(key: Key) -> void:
	for pressed: bool in [true,false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = key
		event.physical_keycode = key
		event.pressed = pressed
		viewport.push_input(event,true)

func _owners() -> Dictionary:
	return {"clock":GameClock.serialize(),"bag":main.inventory.serialize(),"wallet":main.wallet.serialize(),"farm":main.farm_state.serialize(),"land":main.land_ownership.serialize(),"jobs":main.machine_operations.serialize(),"social":main.npc_system.state.serialize()}

func _capture(stem: String) -> void:
	if DisplayServer.get_name()!="headless":
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		assert_eq(viewport.get_texture().get_image().save_png("user://phase65h2b_%s.png" % stem),OK)

func _settle() -> void:
	for frame: int in range(90):
		await get_tree().process_frame
		if frame>0 and not main.ui_coordinator._layout_queued and not main.inventory_panel.controller._queued:
			return
	assert_true(false,"Water HUD layout failed to settle")
