extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/chicken_coop_fixture.gd")
const PROFILE: WeatherProfile = preload("res://data/weather_profile.tres")
var f: RefCounted
var main: Node

func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
	main = f.main

func after_each() -> void:
	await get_tree().process_frame
	f.cleanup()

func test_all_twelve_real_goldens_migrate_preserving_existing_prerolls_and_other_values() -> void:
	for version: int in range(1,SaveService.CURRENT_VERSION+1):
		var raw: Dictionary = _golden(version)
		var original: Dictionary = raw.duplicate(true)
		_write(raw)
		var loaded: Dictionary = SaveService.load_game(98)
		assert_eq(int(loaded.meta.save_version),17)
		assert_eq(loaded.clock,raw.clock)
		assert_eq(loaded.get("wallet",{}),raw.get("wallet",loaded.get("wallet",{})))
		assert_eq(loaded.inventory.slots,raw.inventory.slots)
		if version==1:
			assert_eq(loaded.weather,{})
		else:
			var expected: Dictionary = WeatherSnapshotCodec.decode(PROFILE,raw.weather).snapshot
			expected.day_index = int(raw.clock.day_index)
			assert_eq(loaded.weather,expected)
		assert_eq(raw,original,"No migration mutates its input fixture")
		main.call("_load_payload",loaded)
		assert_eq(main.weather_state.get_day_index(),GameClock.day_index)
		if version>1:
			assert_eq(main.weather_state.serialize(),loaded.weather)
		assert_false(main.morning_flow.panel.visible,"Load never simulates or opens a morning")

func test_actual_main_save_reload_and_continue_keep_weather_and_other_owners() -> void:
	f.open(2000)
	main.chicken_coop_flow.command(&"buy_coop",4)
	main.chicken_coop_flow.command(&"buy_feed",8)
	main.chicken_coop_flow.command(&"feed",2)
	main.chicken_coop_flow.close()
	main.watering_can.deserialize({"capacity":40,"charges":7})
	var raw: Dictionary = {"world_seed":-42,"today":"storm","forecast":["cloudy","storm","rain"],"day_index":0}
	main.weather_state.deserialize(raw)
	var owners: Dictionary = f.owners()
	var ledger: Dictionary = main.day_end_flow.ledger.serialize()
	assert_true(main.call("_save_game_to_slot",98))
	assert_eq(SaveService.load_game(98).weather,raw)
	for index: int in range(3):
		assert_true(main.call("_load_game_from_slot",98))
		assert_eq(main.weather_state.serialize(),raw)
		assert_eq(f.owners(),owners)
		assert_eq(main.day_end_flow.ledger.serialize(),ledger)
	assert_true(main.call("_return_to_start_menu"))
	main.call("_continue_game")
	assert_eq(main.weather_state.serialize(),raw)
	assert_eq(f.owners(),owners)
	assert_false(main.start_menu.visible)

func test_saved_first_three_choices_are_consumed_unchanged_across_three_reloads() -> void:
	main.call("_load_payload",SaveService._migrate(_golden(11),11))
	var saved: Dictionary = main.weather_state.serialize()
	for offset: int in range(1,5):
		var expected: StringName = StringName(saved.forecast[offset-1]) if offset<=3 else WeatherRoller.roll_day(PROFILE,int(saved.world_seed),int(saved.day_index)+4)
		GameClock.sleep_to_morning()
		main.morning_flow.dismiss()
		assert_eq(main.weather_state.today,expected)
		assert_eq(main.weather_state.get_day_index(),30+offset)
		assert_eq(main.weather_state.forecast.back(),WeatherRoller.roll_day(PROFILE,0,33+offset))
		var before: Dictionary = main.weather_state.serialize()
		assert_true(main.call("_save_game_to_slot",98))
		assert_true(main.call("_load_game_from_slot",98))
		assert_eq(main.weather_state.serialize(),before)

func test_corrupt_or_missing_components_have_correct_day_fallback_without_progress_loss() -> void:
	var raw: Dictionary = _golden(12)
	for key: String in raw.watering_can:
		raw.watering_can[key] = int(raw.watering_can[key])
	for key: String in raw.chicken_coop.coop:
		raw.chicken_coop.coop[key] = int(raw.chicken_coop.coop[key])
	for value: Variant in [null,[],{},"rain",{"world_seed":0,"today":"rain","forecast":["sunny","sunny","sunny"],"day_index":29}]:
		raw.weather = value
		_write(raw)
		var loaded: Dictionary = SaveService.load_game(98)
		assert_eq(loaded.weather,{})
		assert_eq(loaded.inventory,raw.inventory)
		assert_eq(loaded.wallet,raw.wallet)
		assert_eq(loaded.watering_can,raw.watering_can)
		assert_eq(loaded.chicken_coop,raw.chicken_coop)
		main.call("_load_payload",loaded)
		assert_eq(main.weather_state.serialize(),WeatherRoller.initial_snapshot(PROFILE,0,30))
		assert_eq(main.wallet.serialize(),{"coins":int(raw.wallet.coins)})
		assert_eq(main.watering_can.serialize(),raw.watering_can)
		assert_eq(main.chicken_coop.serialize(),raw.chicken_coop)

func test_current_requires_day_but_trusted_pack_and_legacy_migration_bind_clock() -> void:
	var raw: Dictionary = _golden(12)
	raw.weather.erase("day_index")
	_write(raw)
	assert_eq(SaveService.load_game(98).weather,{})
	assert_true(SaveService.save_game(raw,98))
	var expected: Dictionary = raw.weather.duplicate(true)
	expected.world_seed = int(expected.world_seed)
	expected.day_index = 30
	assert_eq(SaveService.load_game(98).weather,expected)
	raw.meta.save_version = 11
	_write(raw)
	assert_eq(SaveService.load_game(98).weather,expected)
	raw.meta.save_version = SaveService.CURRENT_VERSION+1
	_write(raw)
	assert_eq(SaveService.load_game(98),{})

func test_new_game_reuses_owner_resets_day_and_uses_declared_initial_sequence() -> void:
	var owner: Object = main.weather_state
	main.call("_load_payload",_golden(12))
	main.call("_start_new_game","An","New")
	assert_eq(main.weather_state,owner)
	assert_eq(GameClock.day_index,0)
	assert_eq(main.weather_state.serialize(),WeatherRoller.initial_snapshot(PROFILE,0,0))
	assert_eq(SaveService.load_game(1).weather,main.weather_state.serialize())
	assert_false(main.morning_flow.panel.visible)

func _golden(version: int) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v%d.json" % version))

func _write(raw: Dictionary) -> void:
	var file: FileAccess = FileAccess.open("user://saves/slot_98.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(raw))
	file.close()
