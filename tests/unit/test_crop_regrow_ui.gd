extends GutTest

var _clock: Dictionary
var _paused: bool
var _locale: String
var _viewport: SubViewport
var _main: Node

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	GameClock.deserialize({"day_index":28,"minute":360,"season":"summer","year":1})
	GameClock.paused = true
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152,648)
	_viewport.world_2d = World2D.new()
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_main.start_menu.hide()
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	_main.set("_game_started",true)
	_main.world.player.move_to_cell(Vector2i(0,1))
	_main.farm_state.reset()
	_main.inventory.clear()
	_main.weather_state.force_weather(&"sunny")

func after_each() -> void:
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)

func _plot(growth: int, target: int = 5, repeating: bool = false, dry: int = 0) -> void:
	_main.farm_state.deserialize({"plots":[{"cell_x":0,"cell_y":0,"tilled":true,"crop_id":"summer_tomato","growth_days":growth,"growth_target":target,"regrowing":repeating,"consecutive_dry_days":dry,"watered":false,"withered":false}]})

func _settle() -> void:
	for frame: int in range(8):
		await get_tree().process_frame
	await get_tree().create_timer(0.18).timeout

func _click(button: Button) -> void:
	var point: Vector2 = button.get_global_rect().get_center()
	for pressed: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		event.pressed = pressed
		_viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()

func test_native_harvest_full_bag_is_atomic_then_repeat_grants_once_and_updates_visual() -> void:
	_plot(5)
	_main.inventory.deserialize({"capacity":1,"slots":[{"item_id":"turnip","quantity":20}]})
	_main.crop_inspector.show_cell(Vector2i.ZERO)
	await _settle()
	var before: Dictionary = _main.farm_state.serialize()
	var bag: Dictionary = _main.inventory.serialize()
	var wallet: Dictionary = _main.wallet.serialize()
	var ledger: Dictionary = _main.day_end_flow.ledger.serialize()
	await _click(_main.crop_inspector.action_button)
	assert_eq(_main.farm_state.serialize(),before)
	assert_eq(_main.inventory.serialize(),bag)
	_main.inventory.clear()
	await _click(_main.crop_inspector.action_button)
	assert_eq(_main.inventory.get_quantity(&"summer_tomato"),2)
	assert_true(_main.farm_state.get_plot(Vector2i.ZERO)["regrowing"])
	assert_true(_main.crop_inspector.visible,"Repeat crop stays available for inspection")
	assert_eq(_main.crop_inspector.get_remaining_minutes(),2880)
	assert_eq(_main.crop_inspector.note_label.text,tr("UI_CROP_REGROW_NOTE"))
	assert_false(_main.farm_view.get_crop_view(Vector2i.ZERO).get_meta("mature"))
	for attempt: int in range(3):
		_main.tool_controller.perform_crop_action(Vector2i.ZERO,&"harvest")
	assert_eq(_main.inventory.get_quantity(&"summer_tomato"),2)
	for day: int in range(2):
		_main.farm_state.water_all_crops()
		_main.day_simulator.simulate_day(_main.farm_state)
	await _settle()
	assert_true(_main.farm_view.get_crop_view(Vector2i.ZERO).get_meta("mature"))
	await _click(_main.crop_inspector.action_button)
	assert_eq(_main.inventory.get_quantity(&"summer_tomato"),4)
	assert_eq(_main.inventory.get_quantity(&"summer_tomato_seed"),0)
	assert_eq(_main.wallet.serialize(),wallet)
	assert_eq(_main.day_end_flow.ledger.serialize(),ledger)

func test_physical_seed_sowing_consumes_once_and_later_picks_consume_no_seed() -> void:
	_main.farm_state.till_cell(Vector2i.ZERO)
	_main.inventory.add_item(&"summer_tomato_seed",3)
	_main.hotbar_panel.select_slot(0)
	_main.tool_controller.select_seed()
	await _settle()
	var point: Vector2 = _main.world.grid.cell_to_screen(Vector2i.ZERO)
	for pressed: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		event.pressed = pressed
		_viewport.push_input(event,true)
		await get_tree().process_frame
	assert_eq(_main.inventory.get_quantity(&"summer_tomato_seed"),2)
	for cycle: int in range(2):
		for day: int in range(5 if cycle==0 else 2):
			_main.farm_state.water_all_crops()
			_main.day_simulator.simulate_day(_main.farm_state)
		_main.tool_controller.perform_crop_action(Vector2i.ZERO,&"harvest")
		assert_eq(_main.inventory.get_quantity(&"summer_tomato_seed"),2)
	assert_eq(_main.inventory.get_quantity(&"summer_tomato"),4)

func test_loading_multiple_cycles_refreshes_every_crop_from_its_saved_target() -> void:
	_main.call("_load_payload",{
		"clock":{"day_index":28,"minute":360,"season":"summer","year":1},
		"weather":{"today":"sunny","forecast":["sunny","sunny","rain"]},
		"farm":{"plots":[
			{"cell_x":0,"cell_y":0,"tilled":true,"crop_id":"summer_tomato","growth_days":4,"growth_target":4,"regrowing":false},
			{"cell_x":1,"cell_y":0,"tilled":true,"crop_id":"summer_tomato","growth_days":1,"growth_target":2,"regrowing":true}
		]}})
	await _settle()
	assert_true(_main.farm_state.can_harvest(Vector2i.ZERO))
	assert_true(_main.farm_view.get_crop_view(Vector2i.ZERO).visible)
	assert_true(_main.farm_view.get_crop_view(Vector2i.ZERO).get_meta("mature"))
	assert_true(_main.farm_view.get_crop_view(Vector2i(1,0)).visible)
	assert_false(_main.farm_view.get_crop_view(Vector2i(1,0)).get_meta("mature"))
	_main.crop_inspector.show_cell(Vector2i(1,0))
	assert_eq(_main.crop_inspector.get_remaining_minutes(),1440)

func test_legacy_ready_and_repeat_inspector_match_real_targets_both_languages_three_sizes() -> void:
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for extent: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]:
			_viewport.size = extent
			for mode: String in ["legacy_ready","repeat","repeat_ready","dry_repeat"]:
				if mode=="legacy_ready":
					_plot(4,4)
				else:
					_plot(2 if mode=="repeat_ready" else 1,2,true,1 if mode=="dry_repeat" else 0)
				_main.crop_inspector.show_cell(Vector2i.ZERO)
				await _settle()
				var inspector: CropInspector = _main.crop_inspector
				var rect: Rect2 = inspector.get_global_rect()
				assert_true(Rect2(Vector2.ZERO,Vector2(extent)).encloses(rect))
				for control: Control in [inspector.countdown_label,inspector.note_label,inspector.action_button]:
					assert_true(rect.encloses(control.get_global_rect()))
				var ripe: bool = mode in ["legacy_ready","repeat_ready"]
				assert_eq(_main.farm_state.can_harvest(Vector2i.ZERO),ripe)
				assert_eq(bool(_main.farm_view.get_crop_view(Vector2i.ZERO).get_meta("mature")),ripe)
				assert_eq(inspector.get_remaining_minutes(),0 if ripe else 1440)
				if mode=="repeat":
					assert_eq(inspector.note_label.text,tr("UI_CROP_REGROW_NOTE"))
				elif mode=="dry_repeat":
					assert_eq(inspector.note_label.text,tr("UI_CROP_DRY_WARNING") % 1)
				if DisplayServer.get_name()!="headless":
					await RenderingServer.frame_post_draw
					assert_eq(_viewport.get_texture().get_image().save_png("user://iso6b1_%s_%s_%d.png" % [locale,mode,extent.x]),OK)
