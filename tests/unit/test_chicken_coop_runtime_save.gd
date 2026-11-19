extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/chicken_coop_fixture.gd")
var f: RefCounted
var main: Node

func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
	main = f.main

func after_each() -> void:
	await get_tree().process_frame
	f.cleanup()

func test_v11_actual_owner_feed_pending_and_water_roundtrip_without_day_replay() -> void:
	f.open(2000)
	main.chicken_coop_flow.command(&"buy_coop",4)
	main.chicken_coop_flow.command(&"buy_feed",8)
	main.chicken_coop_flow.command(&"feed",2)
	main.chicken_coop_flow.close()
	GameClock.sleep_to_morning()
	main.morning_flow.dismiss()
	f.open(1140)
	main.chicken_coop_flow.command(&"feed",1)
	main.watering_can.deserialize({"capacity":40,"charges":7})
	var expected: Dictionary = f.owners()
	assert_true(main.call("_save_game_to_slot",98))
	var payload: Dictionary = SaveService.load_game(98)
	assert_eq(int(payload.meta.save_version),14)
	main.chicken_coop_runtime.reset()
	main.call("_load_payload",payload)
	assert_eq(main.chicken_coop.serialize(),expected.coop)
	assert_eq(main.inventory.serialize(),expected.bag)
	assert_eq(main.wallet.serialize(),expected.wallet)
	assert_eq(main.watering_can.serialize(),expected.water)
	assert_eq(GameClock.serialize(),expected.clock)
	assert_not_null(main.chicken_coop_runtime.site.body)
	assert_eq(int(main.chicken_coop.coop.serialize().pending_eggs),2)
	assert_eq(int(main.chicken_coop.coop.serialize().fed_hens),1)

func test_every_legacy_golden_migrates_unowned_preserving_other_fields() -> void:
	for version: int in range(1,11):
		var path: String = "res://tests/golden_saves/save_v%d.json" % version
		var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		var saved: Dictionary = raw.duplicate(true)
		raw.chicken_coop = {"owned":true,"coop":{"current_day":0,"hen_count":4,"fed_hens":4,"pending_eggs":999}}
		var file: FileAccess = FileAccess.open("user://saves/slot_98.json",FileAccess.WRITE)
		file.store_string(JSON.stringify(raw))
		file.close()
		var payload: Dictionary = SaveService.load_game(98)
		assert_eq(int(payload.meta.save_version),14)
		assert_false(bool(payload.chicken_coop.owned))
		assert_eq(int(payload.chicken_coop.coop.hen_count),0)
		assert_eq(int(payload.chicken_coop.coop.pending_eggs),0)
		assert_eq(payload.get("wallet",{}),saved.get("wallet",payload.get("wallet",{})))
		assert_eq(payload.get("clock",{}),saved.get("clock",{}))

func test_v10_water_uses_introduction_threshold_not_current_save_version() -> void:
	for charges: int in [0,7,40]:
		main.watering_runtime.restore({"meta":{"save_version":10},"watering_can":{"capacity":40,"charges":charges}})
		assert_eq(main.watering_can.serialize(),{"capacity":40,"charges":charges})
	main.watering_runtime.restore({"meta":{"save_version":9},"watering_can":{"capacity":40,"charges":7}})
	assert_eq(main.watering_can.serialize(),{"capacity":20,"charges":20})

func test_corrupt_component_falls_back_without_changing_other_progress_and_future_rejected() -> void:
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v11.json"))
	var valid: Dictionary = raw.chicken_coop.duplicate(true)
	for field: String in ["current_day","hen_count","fed_hens","pending_eggs"]:
		valid.coop[field] = int(valid.coop[field])
	for bad: Variant in [null,[],{}, {"owned":true,"coop":{"current_day":0,"hen_count":999,"fed_hens":4,"pending_eggs":8}}, {"owned":false,"coop":{"current_day":0,"hen_count":0,"fed_hens":0,"pending_eggs":3}}]:
		raw.chicken_coop = bad
		_write(raw)
		var loaded: Dictionary = SaveService.load_game(98)
		assert_false(bool(loaded.chicken_coop.owned))
		assert_eq(loaded.wallet,raw.wallet)
		assert_eq(loaded.inventory,raw.inventory)
	raw.chicken_coop = valid
	_write(raw)
	assert_eq(SaveService.load_game(98).chicken_coop,valid)
	raw.meta.save_version = SaveService.CURRENT_VERSION+1
	_write(raw)
	assert_eq(SaveService.load_game(98),{})

func _write(raw: Dictionary) -> void:
	var file: FileAccess = FileAccess.open("user://saves/slot_98.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(raw))
	file.close()
