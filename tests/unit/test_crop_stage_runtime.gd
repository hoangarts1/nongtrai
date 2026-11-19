extends GutTest

const REPEATING: Array[StringName] = [&"coffee", &"pepper", &"orange", &"apple", &"banana", &"tomato", &"summer_tomato"]
var _clock: Dictionary
var _paused: bool
var _locale: String
var _viewport: SubViewport
var _main: Node

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152, 648)
	_viewport.world_2d = World2D.new()
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_main.call("_start_new_game", "Mai", "Garden")
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	_main.world.player.move_to_cell(Vector2i(0, 1))
	_main.farm_state.reset()
	_main.inventory.clear()
	GameClock.paused = true

func after_each() -> void:
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)
	SaveService.delete_save(17)

func test_all_seven_real_cycles_keep_the_tree_and_json_restores_stage_three_without_early_yield() -> void:
	await _settle()
	for id: StringName in REPEATING:
		_main.farm_state.reset()
		_main.inventory.clear()
		var data: CropData = DataRegistry.get_crop(id) as CropData
		GameClock.season = StringName(data.seasons[0])
		assert_true(_main.farm_state.till_cell(Vector2i.ZERO))
		assert_true(_main.farm_state.plant_crop(Vector2i.ZERO, id))
		_grow(data.growth_days)
		assert_true(_main.farm_state.can_harvest(Vector2i.ZERO))
		var stable: Dictionary = _other_owners()
		_main.tool_controller.perform_crop_action(Vector2i.ZERO, &"harvest")
		assert_eq(_main.inventory.get_quantity(data.product_item), data.yield_qty)
		assert_true(_main.farm_state.get_plot(Vector2i.ZERO).regrowing)
		assert_eq(_sprite().get_meta("visual_stage"), 3)
		assert_false(_sprite().get_meta("mature"))
		var saved: Dictionary = _wire(_main.farm_state.serialize())
		_main.farm_state.reset()
		_main.farm_state.deserialize(saved)
		_main.farm_view.configure(_main.farm_state)
		assert_eq(_wire(_main.farm_state.serialize()), saved)
		assert_eq(_sprite().get_meta("visual_stage"), 3)
		for day: int in range(data.regrow_days):
			assert_false(_main.farm_state.can_harvest(Vector2i.ZERO))
			_main.tool_controller.perform_crop_action(Vector2i.ZERO, &"harvest")
			assert_eq(_main.inventory.get_quantity(data.product_item), data.yield_qty)
			_grow(1)
			assert_eq(_sprite().get_meta("visual_stage"), 4 if day + 1 == data.regrow_days else 3)
		assert_true(_main.farm_state.can_harvest(Vector2i.ZERO))
		assert_true(_sprite().get_meta("mature"))
		var point: Vector2 = _sprite().get_global_transform_with_canvas() * _sprite().get_rect().get_center()
		assert_eq(_main.farm_view.pick_crop(point, _main.world.camera), Vector2i.ZERO)
		assert_eq(_other_owners(), stable, "Visual/cycle queries do not change other owners")

func test_full_bag_keeps_ripe_tree_then_one_pick_returns_to_stage_three() -> void:
	await _settle()
	_plant_coffee()
	var data: CropData = DataRegistry.get_crop(&"coffee") as CropData
	_grow(data.growth_days)
	_main.inventory.deserialize({"capacity": 1, "slots": [{"item_id": "turnip", "quantity": 20}]})
	var farm: Dictionary = _main.farm_state.serialize()
	var bag: Dictionary = _main.inventory.serialize()
	_main.tool_controller.perform_crop_action(Vector2i.ZERO, &"harvest")
	assert_eq(_main.farm_state.serialize(), farm)
	assert_eq(_main.inventory.serialize(), bag)
	assert_eq(_sprite().get_meta("visual_stage"), 4)
	assert_true(_sprite().get_meta("mature"))
	_main.inventory.clear()
	_main.tool_controller.perform_crop_action(Vector2i.ZERO, &"harvest")
	_main.tool_controller.perform_crop_action(Vector2i.ZERO, &"harvest")
	assert_eq(_main.inventory.get_quantity(data.product_item), data.yield_qty)
	assert_eq(_sprite().get_meta("visual_stage"), 3)
	assert_false(_sprite().get_meta("mature"))

func test_save_twelve_restores_mid_repeat_and_every_existing_owner_without_advancing() -> void:
	await _settle()
	_plant_coffee()
	var data: CropData = DataRegistry.get_crop(&"coffee") as CropData
	_grow(data.growth_days)
	_main.tool_controller.perform_crop_action(Vector2i.ZERO, &"harvest")
	_grow(1)
	var farm: Dictionary = _wire(_main.farm_state.serialize())
	var bag: Dictionary = _wire(_main.inventory.serialize())
	var others: Dictionary = _wire(_other_owners())
	assert_true(_main.call("_save_game_to_slot", 17))
	var payload: Dictionary = SaveService.load_game(17)
	assert_eq(int(payload.meta.save_version), 16)
	_main.farm_state.reset()
	_main.inventory.clear()
	_main.call("_load_payload", payload)
	await _settle()
	assert_eq(_wire(_main.farm_state.serialize()), farm)
	assert_eq(_wire(_main.inventory.serialize()), bag)
	assert_eq(_wire(_other_owners()), others)
	assert_eq(_sprite().get_meta("visual_stage"), 3)
	assert_eq(_main.farm_state.get_growth_remaining(Vector2i.ZERO), data.regrow_days - 1)
	assert_false(_sprite().get_meta("mature"))

func test_normal_repeat_and_wilted_art_capture_both_locales_three_sizes_without_mutation() -> void:
	await _settle()
	var plots: Array[Dictionary] = []
	for index: int in range(5):
		var id: StringName = REPEATING[index]
		var data: CropData = DataRegistry.get_crop(id) as CropData
		plots.append({"cell_x": index, "cell_y": 0, "tilled": true, "crop_id": String(id), "growth_days": 0, "growth_target": data.regrow_days, "regrowing": true, "withered": index == 2, "withered_days": 1 if index == 2 else 0})
	_main.farm_state.deserialize({"plots": plots})
	_main.farm_view.configure(_main.farm_state)
	var before: Dictionary = _wire({"farm": _main.farm_state.serialize(), "bag": _main.inventory.serialize(), "others": _other_owners()})
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1920, 1080)]:
			_viewport.size = dimensions
			await _settle()
			for index: int in range(5):
				var sprite: Sprite2D = _main.farm_view.get_crop_view(Vector2i(index, 0))
				assert_eq(sprite.get_meta("visual_stage"), 3)
				assert_false(sprite.get_meta("mature"))
				assert_eq(sprite.get_meta("withered"), index == 2)
			if DisplayServer.get_name() != "headless":
				await RenderingServer.frame_post_draw
				assert_eq(_viewport.get_texture().get_image().save_png("user://audit_f1_%s_%d.png" % [locale, dimensions.x]), OK)
	assert_eq(_wire({"farm": _main.farm_state.serialize(), "bag": _main.inventory.serialize(), "others": _other_owners()}), before)

func _plant_coffee() -> void:
	assert_true(_main.farm_state.till_cell(Vector2i.ZERO))
	assert_true(_main.farm_state.plant_crop(Vector2i.ZERO, &"coffee"))

func _grow(days: int) -> void:
	for day: int in range(days):
		_main.farm_state.water_all_crops()
		_main.day_simulator.simulate_day(_main.farm_state)

func _sprite() -> Sprite2D:
	return _main.farm_view.get_crop_view(Vector2i.ZERO)

func _other_owners() -> Dictionary:
	return {"clock": GameClock.serialize(), "wallet": _main.wallet.serialize(), "water": _main.watering_can.serialize(), "weather": _main.weather_state.serialize(), "coop": _main.chicken_coop.serialize(), "ledger": _main.day_end_flow.ledger.serialize(), "land": _main.land_ownership.serialize(), "machines": _main.machine_operations.serialize()}

func _wire(value: Dictionary) -> Dictionary:
	return JSON.parse_string(JSON.stringify(value)) as Dictionary

func _settle() -> void:
	for frame: int in range(6):
		await get_tree().process_frame
