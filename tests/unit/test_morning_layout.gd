extends GutTest

const SIZES: Array[Vector2i] = [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]
var _viewport: SubViewport
var _main: Node
var _clock: Dictionary
var _paused: bool
var _locale: String

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	SaveService.delete_save(0)
	SaveService.delete_save(1)
	_viewport = SubViewport.new()
	_viewport.size = SIZES[0]
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)

func after_each() -> void:
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)
	SaveService.delete_save(0)
	SaveService.delete_save(1)

func _game() -> void:
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_main.call("_start_new_game","Mai","Vườn")
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	GameClock.paused = true

func _show_fixture(kind: String) -> void:
	_main.morning_flow.dismiss()
	_main.farm_state.reset()
	var weather: Dictionary = _main.weather_state.serialize()
	weather.today = "rain" if kind == "rain" else "sunny"
	weather.forecast = ["sunny","cloudy","rain"]
	_main.weather_state.deserialize(weather)
	if kind == "mixed" or kind == "rain":
		GameClock.deserialize({"day_index":28,"season":"summer","year":1,"minute":360})
		var tomato: int = int(DataRegistry.get_crop(&"summer_tomato").regrow_days)
		var turnip: int = int(DataRegistry.get_crop(&"turnip").growth_days)
		_main.farm_state.deserialize({"plots":[
			{"cell_x":0,"cell_y":0,"tilled":true,"crop_id":"summer_tomato","growth_days":tomato,"growth_target":tomato,"regrowing":true,"watered":kind=="rain"},
			{"cell_x":1,"cell_y":0,"tilled":true,"crop_id":"summer_tomato","growth_days":0,"growth_target":tomato,"regrowing":true,"watered":kind=="rain"},
			{"cell_x":2,"cell_y":0,"tilled":true,"crop_id":"turnip","growth_days":turnip,"growth_target":turnip,"withered":true},
			{"cell_x":3,"cell_y":0,"tilled":true,"crop_id":""}
		]})
	if kind == "complete":
		var completed: Array[bool] = []
		completed.resize(_main.quest_panel.STEP_KEYS.size())
		completed.fill(true)
		_main.quest_state.deserialize({"completed":completed})
	MorningPresenter.render(_main.morning_flow.panel,MorningSnapshot.capture(_main))
	_main.morning_flow.panel.show()

func test_reference05_both_locales_three_sizes_real_states_and_prices() -> void:
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in SIZES:
			_viewport.size = dimensions
			_game()
			for kind: String in ["empty","mixed","rain","complete"]:
				_show_fixture(kind)
				await _settle()
				var sheet: LifeMorningSheet = _main.morning_flow.panel
				var bounds: Rect2 = Rect2(Vector2.ZERO,Vector2(dimensions))
				assert_true(bounds.encloses(sheet.get_global_rect()),"Bulletin fits "+kind)
				for control: Control in [sheet.begin_button,sheet.tasks,sheet.weather,sheet.garden,sheet.market]:
					assert_true(sheet.get_global_rect().encloses(control.get_global_rect()),"Fixed region fits: %s / %s in %s" % [control.name,control.get_global_rect(),sheet.get_global_rect()])
				assert_false(sheet.weather.get_global_rect().intersects(sheet.market.get_global_rect()))
				assert_eq(sheet.weather.forecast_row.get_child_count(),_main.weather_state.forecast.size())
				assert_eq(sheet.market.rows_box.get_child_count(),MorningSnapshot.capture(_main).prices.size())
				var rows: Array[Dictionary] = MorningSnapshot.capture(_main).prices
				for index: int in range(rows.size()):
					var row: LifeMorningPriceRow = sheet.market.rows_box.get_child(index) as LifeMorningPriceRow
					assert_eq(row.amount.text,tr("UI_WALLET_COINS") % int(rows[index].price))
					assert_eq(row.title.text,tr(String(rows[index].name_key)))
				assert_true(GameClock.paused)
				assert_false(_main.world.player.movement_enabled)
				assert_false(_main.hotbar_panel.visible)
				if kind == "rain":
					assert_eq(MorningSnapshot.capture(_main).water,0)
					assert_eq(sheet.weather.tip.text,tr("NEWS_RAIN_TIP"))
				if kind == "complete":
					assert_eq(sheet.garden.hints.text,tr("NEWS_QUEST_DONE"))
				await _capture("%s_%s_%d" % [locale,kind,dimensions.x])
			_main.free()

func test_physical_scroll_and_native_keyboard_dismiss_do_not_use_world_tools() -> void:
	_game()
	_show_fixture("mixed")
	await _settle()
	var sheet: LifeMorningSheet = _main.morning_flow.panel
	var bag: Dictionary = _main.inventory.serialize()
	var farm: Dictionary = _main.farm_state.serialize()
	var weather: Dictionary = _main.weather_state.serialize()
	var day: int = GameClock.day_index
	var point: Vector2 = sheet.market.scroll.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	_viewport.push_input(motion,true)
	for index: int in range(8):
		var wheel: InputEventMouseButton = InputEventMouseButton.new()
		wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
		wheel.pressed = true
		wheel.position = point
		wheel.global_position = point
		_viewport.push_input(wheel,true)
		await get_tree().process_frame
	assert_gt(sheet.market.scroll.scroll_vertical,0,"Real wheel events scroll prices")
	sheet.begin_button.grab_focus()
	await _key(KEY_TAB)
	assert_true(sheet.visible)
	assert_false(_main.inventory_panel.visible,"Tab stays in GUI rather than opening Bag")
	sheet.begin_button.grab_focus()
	await _key(KEY_SPACE)
	assert_false(sheet.visible)
	assert_eq(_main.inventory.serialize(),bag)
	assert_eq(_main.farm_state.serialize(),farm)
	assert_eq(_main.weather_state.serialize(),weather)
	assert_eq(GameClock.day_index,day)
	assert_true(_main.world.player.movement_enabled)

func test_unknown_forecast_and_translations_do_not_fabricate_predictions() -> void:
	_game()
	var empty_forecast: Array[StringName] = []
	_main.weather_state.set("forecast",empty_forecast)
	var snapshot: Dictionary = MorningSnapshot.capture(_main)
	MorningPresenter.render(_main.morning_flow.panel,snapshot)
	assert_eq(_main.morning_flow.panel.weather.forecast_row.get_child_count(),0)
	assert_eq(_main.morning_flow.panel.weather.forecast_title.text,tr("END_FORECAST_UNKNOWN"))
	var paths: Array[String] = ["res://localization/strings_vi.csv","res://localization/strings_en.csv"]
	var keys: PackedStringArray = ["NEWS_TITLE","NEWS_DATE","NEWS_WEATHER","NEWS_FORECAST","NEWS_RAIN_TIP","NEWS_DRY_TIP","NEWS_TODAY","NEWS_QUEST_PROGRESS","NEWS_QUEST_DONE","NEWS_GARDEN_STATUS","NEWS_EVENTS_UNAVAILABLE","NEWS_PRICES","NEWS_PRICE_NOTE","NEWS_TASKS","NEWS_READY","NEWS_WATER","NEWS_EMPTY","NEWS_BEGIN"]
	assert_true(DataValidator.validate_translation_keys(paths,keys).is_empty())

func _key(code: Key) -> void:
	for pressed: bool in [true,false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		_viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func _capture(id: String) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		assert_eq(_viewport.get_texture().get_image().save_png("user://iso9_%s.png" % id),OK)
