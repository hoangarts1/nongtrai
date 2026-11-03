extends GutTest

class CountingSimulator extends RefCounted:
	var calls: int = 0
	func simulate_day(farm: FarmGridState) -> void:
		calls += 1
		DaySimulator.new().simulate_day(farm)

var _clock: Dictionary
var _paused: bool
var _locale: String
var _viewport: SubViewport
var _main: Node
var _saved_slots: Dictionary = {}

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	for slot: int in [0,1]:
		var path: String = "user://saves/slot_%d.json" % slot
		_saved_slots[slot] = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
	GameClock.deserialize({})
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
	_main.day_end_flow.reset()
	_main.farm_state.reset()
	_main.world.player.move_to_cell(Vector2i(0,1))

func after_each() -> void:
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)
	for slot: int in _saved_slots:
		if _saved_slots[slot] == null:
			SaveService.delete_save(slot)
		else:
			var file: FileAccess = FileAccess.open("user://saves/slot_%d.json" % slot,FileAccess.WRITE)
			file.store_buffer(_saved_slots[slot])
			file.close()
	_saved_slots.clear()

func _weather(today: StringName, tomorrow: StringName) -> void:
	_main.weather_state.deserialize({"world_seed":0,"today":today,"forecast":[tomorrow,&"sunny",&"sunny"]})

func _plant(dry_days: int = 0, growth: int = 0) -> void:
	_main.farm_state.deserialize({"plots":[{"cell_x":0,"cell_y":0,"tilled":true,"crop_id":"turnip","growth_days":growth,"watered":false,"withered":false,"consecutive_dry_days":dry_days}]})

func _settle() -> void:
	for frame: int in range(8):
		await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout

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

func test_tomorrows_rain_cannot_rescue_second_dry_day_but_waters_survivors() -> void:
	_weather(&"sunny",&"rain")
	_plant(1)
	var spy: CountingSimulator = CountingSimulator.new()
	_main.day_simulator = spy
	GameClock.set_time(20,0)
	assert_true(_main.day_end_flow.request())
	_main.day_end_flow.confirm()
	assert_eq(spy.calls,1)
	assert_true(_main.weather_state.is_rainy())
	assert_true(_main.farm_state.get_plot(Vector2i.ZERO)["withered"])
	assert_false(_main.farm_state.get_plot(Vector2i.ZERO)["watered"])
	assert_false(_main.farm_state.can_harvest(Vector2i.ZERO))
	assert_false(_main.day_end_flow.panel.visible)
	assert_false(GameClock.is_day_end_held())
	var saved: Dictionary = SaveService.load_latest()
	assert_eq(int(saved["farm"]["plots"][0]["consecutive_dry_days"]),2)
	assert_true(saved["farm"]["plots"][0]["withered"])
	_main.day_end_flow.confirm()
	assert_eq(spy.calls,1)
	_main.farm_state.reset()
	_plant()
	_weather(&"sunny",&"rain")
	GameClock.sleep_to_morning()
	var plot: Dictionary = _main.farm_state.get_plot(Vector2i.ZERO)
	assert_false(plot["withered"])
	assert_true(plot["watered"],"New morning's rain cares for surviving plants")
	assert_eq(int(plot["growth_days"]),0,"Tomorrow's rain adds no growth to yesterday")
	assert_eq(int(plot["consecutive_dry_days"]),0)

func test_finished_rain_grows_new_plants_before_dry_morning_and_next_day_counts_once() -> void:
	_weather(&"rain",&"sunny")
	_plant(1)
	GameClock.sleep_to_morning()
	var plot: Dictionary = _main.farm_state.get_plot(Vector2i.ZERO)
	assert_eq(int(plot["growth_days"]),1)
	assert_eq(int(plot["consecutive_dry_days"]),0)
	assert_false(plot["watered"],"Yesterday's rain cannot persist into a sunny morning")
	assert_false(plot["withered"])
	GameClock.sleep_to_morning()
	plot = _main.farm_state.get_plot(Vector2i.ZERO)
	assert_eq(int(plot["growth_days"]),1)
	assert_eq(int(plot["consecutive_dry_days"]),1)
	assert_false(plot["withered"])

func test_forced_cutoff_and_season_transition_do_not_replay_care_or_revive_crop() -> void:
	_weather(&"sunny",&"sunny")
	_plant(1)
	var spy: CountingSimulator = CountingSimulator.new()
	_main.day_simulator = spy
	GameClock.set_time(25,59)
	GameClock.advance_minutes(1)
	assert_eq(spy.calls,0,"Summary does not apply care before confirmation")
	assert_false(_main.day_end_flow.cancel())
	_main.day_end_flow.confirm()
	_main.day_end_flow.confirm()
	assert_eq(spy.calls,1)
	assert_true(_main.farm_state.get_plot(Vector2i.ZERO)["withered"])
	_weather(&"sunny",&"rain")
	GameClock.deserialize({"day_index":83,"minute":1200,"season":"autumn","year":1})
	_plant(0,1)
	_main.farm_state.water_cell(Vector2i.ZERO)
	GameClock.sleep_to_morning()
	assert_eq(GameClock.season,&"winter")
	assert_true(_main.farm_state.get_plot(Vector2i.ZERO)["withered"])
	assert_eq(int(_main.farm_state.get_plot(Vector2i.ZERO)["growth_days"]),2,"Finished in-season day is accounted before winter")
	assert_false(_main.farm_state.can_harvest(Vector2i.ZERO))

func test_real_inspector_water_button_resets_warning_without_inventory_or_money_change() -> void:
	_weather(&"sunny",&"sunny")
	_plant(1)
	_main.crop_inspector.show_cell(Vector2i.ZERO)
	await _settle()
	assert_eq(_main.crop_inspector.note_label.text,tr("UI_CROP_DRY_WARNING") % 1)
	var inventory: Dictionary = _main.inventory.serialize()
	var wallet: Dictionary = _main.wallet.serialize()
	var ledger: Dictionary = _main.day_end_flow.ledger.serialize()
	await _click(_main.crop_inspector.action_button)
	assert_true(_main.farm_state.get_plot(Vector2i.ZERO)["watered"])
	assert_eq(int(_main.farm_state.get_plot(Vector2i.ZERO)["consecutive_dry_days"]),0)
	assert_eq(_main.crop_inspector.note_label.text,tr("UI_CROP_ESTIMATE_NOTE"))
	assert_eq(_main.inventory.serialize(),inventory)
	assert_eq(_main.wallet.serialize(),wallet)
	assert_eq(_main.day_end_flow.ledger.serialize(),ledger)
	_main.inventory_panel.toggle_inventory()
	assert_false(_main.crop_inspector.visible)
	assert_false(_main.world.player.movement_enabled)

func test_warning_and_withered_inspector_fit_both_languages_three_sizes() -> void:
	_weather(&"sunny",&"sunny")
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for extent: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]:
			_viewport.size = extent
			for mode: String in ["warning","ripe_warning","withered"]:
				_plant(1,4 if mode=="ripe_warning" else 0)
				if mode=="withered":
					_main.day_simulator.simulate_day(_main.farm_state)
				_main.crop_inspector.show_cell(Vector2i.ZERO)
				await _settle()
				var inspector: CropInspector = _main.crop_inspector
				var rect: Rect2 = inspector.get_global_rect()
				assert_true(inspector.visible)
				assert_true(Rect2(Vector2.ZERO,Vector2(extent)).encloses(rect))
				for control: Control in [inspector.title_label,inspector.countdown_label,inspector.water_label,inspector.note_label,inspector.action_button]:
					assert_true(rect.encloses(control.get_global_rect()),"Inspector child fits %s %s %s %s" % [locale,extent,mode,control.name])
				if mode=="withered":
					assert_true(inspector.action_button.disabled)
					assert_eq(inspector.countdown_label.text,tr("CROP_STATUS_WITHERED"))
					assert_eq(inspector.estimate_label.text,tr("UI_CROP_WITHERED_NOTE"))
					assert_eq(inspector.water_label.text,"","Terminal crop does not ask for ineffective watering")
				else:
					assert_eq(inspector.note_label.text,tr("UI_CROP_DRY_WARNING") % 1)
				if DisplayServer.get_name()!="headless":
					await RenderingServer.frame_post_draw
					assert_eq(_viewport.get_texture().get_image().save_png("user://iso6a_%s_%s_%d.png" % [locale,mode,extent.x]),OK)
