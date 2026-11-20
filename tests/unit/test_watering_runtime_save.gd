extends GutTest

const SLOT: int = 96
var main: Node
var viewport: SubViewport
var clock: Dictionary
var paused: bool
var accumulator: float
var originals: Dictionary = {}

func before_each() -> void:
	clock = GameClock.serialize()
	paused = GameClock.paused
	accumulator = float(GameClock.get("_real_seconds_accumulator"))
	GameClock.deserialize({"day_index":0,"minute":720,"season":"spring","year":1})
	GameClock.paused = true
	for slot: int in [0,1,2,SLOT]:
		var path: String = "user://saves/slot_%d.json" % slot
		originals[path] = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
		SaveService.delete_save(slot)
	viewport = SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.world_2d = World2D.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)
	main = preload("res://scenes/main/main.tscn").instantiate()
	viewport.add_child(main)
	main.set("_game_started",true)
	_unblock()
	await get_tree().process_frame

func after_each() -> void:
	# Ownership rebuild detaches scenery and queues its deletion for the next frame.
	await get_tree().process_frame
	await get_tree().process_frame
	viewport.free()
	for path: String in originals:
		if originals[path]==null:
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		else:
			var file: FileAccess = FileAccess.open(path,FileAccess.WRITE)
			file.store_buffer(originals[path])
			file.close()
	originals.clear()
	GameClock.deserialize(clock)
	GameClock.set("_real_seconds_accumulator",accumulator)
	GameClock.paused = paused

func test_every_legacy_golden_gets_explicit_full_base_without_losing_prior_payload() -> void:
	for version: int in range(1,10):
		var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v%d.json" % version))
		var before: Dictionary = raw.duplicate(true)
		_write(raw)
		var loaded: Dictionary = SaveService.load_game(SLOT)
		assert_eq(int(loaded.meta.save_version),18)
		assert_eq(loaded.watering_can,{"capacity":20,"charges":20})
		assert_eq(raw,before)
		for key: String in ["clock","profile","wallet","machine_inventory","machine_placements","machine_operations","social","weather"]:
			if raw.has(key):
				var expected: Variant = raw[key]
				if key=="social":
					expected = raw[key].duplicate(true)
					expected["introduced"] = []
				if key=="weather" and not expected.is_empty():
					expected = raw[key].duplicate(true)
					expected["world_seed"] = int(expected["world_seed"])
					expected["day_index"] = int(raw["clock"]["day_index"])
				assert_eq(loaded[key],expected,"Legacy %d %s" % [version,key])
		assert_eq(loaded.inventory.slots,raw.inventory.slots)
		assert_eq(loaded.farm.plots.size(),raw.farm.plots.size())
		assert_true(main.call("_load_game_from_slot",SLOT))
		assert_eq(main.watering_can.serialize(),{"capacity":20,"charges":20})
		_unblock()
	var forged: Dictionary = {"meta":{"save_version":9},"watering_can":{"capacity":40,"charges":40},"wallet":{"coins":321}}
	var migrated: Dictionary = SaveService.migrate_9_to_10(forged)
	assert_eq(migrated.watering_can,{"capacity":20,"charges":20})
	assert_eq(forged.watering_can,{"capacity":40,"charges":40})
	assert_eq(migrated.wallet,{"coins":321})

func test_v10_partial_slot_continue_new_game_and_known_upgrade_keep_exact_water_and_rights() -> void:
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v10.json"))
	_write(golden)
	assert_true(main.call("_load_game_from_slot",SLOT))
	_unblock()
	assert_eq(main.watering_can.serialize(),{"capacity":20,"charges":13})
	assert_eq(main.land_ownership.get_owned_ids(),[&"farm_east_1"])
	var owners: Dictionary = {"inventory":main.inventory.serialize(),"farm":main.farm_state.serialize(),"wallet":main.wallet.serialize(),"machine_inventory":main.machine_inventory.serialize(),"machine_placements":main.machine_placements.serialize(),"machine_operations":main.machine_operations.serialize(),"land_ownership":main.land_ownership.serialize()}
	assert_true(main.call("_save_game_to_slot",SLOT))
	var saved: Dictionary = SaveService.load_game(SLOT)
	for key: String in owners:
		assert_eq(saved[key],JSON.parse_string(JSON.stringify(owners[key])),"Preserve canonical owner through JSON")
	for index: int in range(golden.farm.plots.size()):
		for key: String in golden.farm.plots[index]:
			assert_eq(saved.farm.plots[index][key],golden.farm.plots[index][key],"Every historical plot field survives")
	assert_eq(saved.inventory,golden.inventory)
	assert_eq(saved.wallet,golden.wallet)
	main.watering_can.deserialize({"capacity":40,"charges":4})
	main.watering_runtime.refresh()
	assert_true(main.call("_save_game_to_slot",2))
	assert_true(main.call("_return_to_start_menu"))
	assert_true(main.start_menu.visible)
	main.call("_continue_game")
	_unblock()
	assert_eq(main.watering_can.serialize(),{"capacity":40,"charges":4},"Continue never grants a refill")
	main.call("_start_new_game","Mai","Vườn")
	_unblock()
	assert_eq(main.watering_can.serialize(),{"capacity":20,"charges":20})
	assert_eq(main.land_ownership.get_owned_ids(),[],"Existing land reset still executes")
	assert_eq(SaveService.load_game(1).watering_can,{"capacity":20,"charges":20})
	assert_true(main.call("_load_game_from_slot",2))
	_unblock()
	assert_eq(main.watering_can.serialize(),{"capacity":40,"charges":4})
	assert_eq(main.land_ownership.get_owned_ids(),[&"farm_east_1"])
	assert_eq(main.hotbar_panel.toolbar.water_meter.amount.text,tr("WATER_CAN_COUNT") % [4,40])

func test_corrupt_current_data_stays_conservative_and_missing_legacy_payload_is_explicit() -> void:
	for bad: Variant in [null,"bad",{}, {"capacity":40}, {"capacity":999,"charges":999}, {"capacity":20,"charges":-1}, {"capacity":20,"charges":"20"}]:
		main.call("_load_payload",{"meta":{"save_version":10},"watering_can":bad})
		_unblock()
		assert_eq(main.watering_can.get_charges(),0,"Corrupt current state must never grant full water")
		assert_true(main.watering_can.get_capacity() in [20,40])
		_write({"meta":{"save_version":10},"watering_can":bad})
		var canonical: Dictionary = SaveService.load_game(SLOT).watering_can
		assert_eq(canonical.charges,0)
		assert_true(canonical.capacity in [20,40])
		assert_true(canonical.charges is int)
		assert_true(canonical.capacity is int)
	main.call("_load_payload",{"meta":{"save_version":10}})
	assert_eq(main.watering_can.get_charges(),0)
	main.call("_load_payload",{"meta":{"save_version":10},"watering_can":{"capacity":20,"charges":99}})
	assert_eq(main.watering_can.serialize(),{"capacity":20,"charges":20},"Excess valid charges clamp")
	main.call("_load_payload",{"wallet":{"coins":42}})
	assert_eq(main.watering_can.serialize(),{"capacity":20,"charges":20},"Unversioned direct legacy load has the explicit default")
	assert_eq(main.wallet.get_coins(),42)

func test_refill_dirty_autosave_failed_save_retry_rain_and_completed_morning_keep_water() -> void:
	main.watering_can.deserialize({"capacity":20,"charges":0})
	main.world.player.move_to_cell(Vector2i(7,9))
	main.tool_controller.select_tool(&"watering_can")
	main.set("_save_dirty",false)
	assert_true(main.watering_runtime.refill().ok)
	assert_true(bool(main.get("_save_dirty")),"Refill dirties save without a plot event")
	main.call("_process",5.1)
	assert_eq(SaveService.load_game(1).watering_can,{"capacity":20,"charges":20})
	main.watering_can.deserialize({"capacity":20,"charges":7})
	main.watering_runtime.refresh()
	assert_false(main.call("_save_game_to_slot",-1))
	assert_eq(main.watering_can.get_charges(),7)
	assert_true(main.call("_save_game_to_slot",SLOT))
	assert_eq(SaveService.load_game(SLOT).watering_can,{"capacity":20,"charges":7})
	assert_true(main.farm_state.till_cell(Vector2i.ZERO))
	assert_true(main.farm_state.plant_crop(Vector2i.ZERO,&"turnip"))
	main.farm_state.water_all_crops()
	assert_eq(main.watering_can.get_charges(),7)
	GameClock.set_time(20,0)
	assert_true(main.day_end_flow.request())
	main.day_end_flow.confirm()
	await get_tree().process_frame
	assert_eq(GameClock.day_index,1)
	assert_eq(main.watering_can.get_charges(),7,"Overnight never resets or consumes manual water")
	assert_eq(SaveService.load_game(0).watering_can,{"capacity":20,"charges":7})

func _write(data: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://saves"))
	var file: FileAccess = FileAccess.open("user://saves/slot_%d.json" % SLOT,FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func _unblock() -> void:
	main.start_menu.hide()
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	GameClock.paused = true
