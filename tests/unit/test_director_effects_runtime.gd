extends GutTest

const FIXTURE: Script = preload("res://tests/helpers/director_fixture.gd")
var f: RefCounted
var main: Node

func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
	main = f.main
	await f.settle(self)

func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_active_dust_actual_manual_water_insufficient_refill_and_current_canopy_rain_counters() -> void:
	await f.prepare_dust(self)
	await f.advance(self, 2, 100.0, 0.0)
	assert_eq(main.watering_runtime.get_charge_cost(), 2)
	var wallet: Dictionary = main.wallet.serialize()
	for cell: Vector2i in [Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]:
		assert_true(main.farm_state.till_cell(cell))
		assert_true(main.farm_state.plant_crop(cell, &"turnip"))
	f.use(&"watering_can", Vector2i(1, 1))
	assert_eq(main.watering_can.get_charges(), 18)
	assert_eq(f.current_counts().plot_watered, 1)
	main.watering_can.deserialize({"capacity": 20, "charges": 1})
	f.use(&"watering_can", Vector2i(2, 1))
	assert_eq(main.watering_can.get_charges(), 1)
	assert_false(main.farm_state.get_plot(Vector2i(2, 1)).watered)
	assert_eq(f.current_counts().plot_watered, 1)
	main.world.player.move_to_cell(Vector2i(7, 9))
	await f.key(self, KEY_E)
	assert_eq(main.watering_can.get_charges(), 20)
	assert_eq(f.current_counts().plot_watered, 1)
	var ecology: Dictionary = main.ecology_state.serialize()
	ecology.metrics.tree_cover = 30.0
	main.ecology_state.deserialize(ecology)
	f.use(&"watering_can", Vector2i(2, 1))
	assert_eq(main.watering_can.get_charges(), 19)
	assert_eq(main.watering_runtime.get_charge_cost(), 1)
	ecology.metrics.tree_cover = 0.0
	main.ecology_state.deserialize(ecology)
	main.weather_state.force_weather(&"rain")
	f.use(&"watering_can", Vector2i(3, 1))
	assert_eq(main.watering_can.get_charges(), 18)
	assert_eq(f.current_counts().plot_watered, 3)
	assert_eq(main.wallet.serialize(), wallet)

func test_extra_visit_uses_actual_market_hours_rain_night_routes_and_never_resets_stock() -> void:
	await f.prepare_bloom(self)
	assert_true(main.director_runtime.queue_force(&"merchant_visit"))
	await f.advance(self, 1, 100.0, 0.0)
	var override: Dictionary = main.director_npc_bridge.override()
	assert_eq(override, {"day_index": 8, "npc_id": "minh", "location_id": "minh_market"})
	var npc: NpcData = main.npc_system.state.get_npc(&"minh")
	var scheduler: NpcSchedule = main.npc_system.state.scheduler
	assert_eq(scheduler.destination(npc, 8, 1020, GameClock.season, false), npc.home_location)
	assert_eq(scheduler.destination(npc, 8, 1020, GameClock.season, false, override), &"minh_market")
	assert_eq(scheduler.destination(npc, 8, 1019, GameClock.season, false, override), npc.home_location)
	assert_eq(scheduler.destination(npc, 8, 1320, GameClock.season, false, override), npc.home_location)
	assert_eq(scheduler.destination(npc, 8, 1020, GameClock.season, true, override), npc.home_location)
	assert_eq(scheduler.destination(npc, 8, 1380, GameClock.season, false, override), npc.home_location)
	assert_eq(scheduler.destination(npc, 8, 1020, GameClock.season, false, {"day_index": true, "npc_id": "minh", "location_id": "minh_market"}), npc.home_location)
	GameClock.set_time(17, 0)
	var cells: Dictionary = main.npc_system.state.cells.duplicate(true)
	var stock: Dictionary = main.npc_system.state.merchant.serialize()
	var offer: MerchantOfferData = main.npc_system.state.merchant.get_offer(8, GameClock.season)
	for _index: int in range(10):
		main.director_npc_bridge.apply()
		assert_eq(main.npc_system.state.targets[&"minh"], &"minh_market")
		assert_eq(main.npc_system.state.cells, cells)
		assert_eq(main.npc_system.state.merchant.serialize(), stock)
		assert_eq(main.npc_system.state.merchant.get_offer(8, GameClock.season), offer)
	assert_false(main.npc_system.state.paths[&"minh"].is_empty())
	await f.advance(self, 1, 100.0, 0.0)
	assert_eq(main.director_npc_bridge.override(), {})
	assert_eq(main.npc_system.state.merchant.serialize(), stock)

func test_native_accent_reuses_fourteen_existing_roots_phase_opacity_and_reverses_after_two_days() -> void:
	assert_true(main.director_runtime.set_enabled(true))
	await f.advance(self, 6, 100.0, 100.0)
	main.ecology_effects_flow.refresh()
	var before: Array[Dictionary] = main.ecology_effects_flow.get_presentation_snapshot()
	assert_eq(before.size(), 14)
	assert_true(main.director_runtime.queue_force(&"butterfly_bloom"))
	await f.advance(self, 1, 100.0, 100.0)
	var current: Array[Dictionary] = main.ecology_effects_flow.get_presentation_snapshot()
	assert_eq(current, before, "Accent changes neither identity, phase, placement nor opacity")
	var color: Color = (LifeDirectorRuntime.PROFILE.get_event(&"butterfly_bloom").effects[0] as DirectorEffectData).accent_color
	for row: Dictionary in current:
		var critter: LifeEcologyCritter2D = instance_from_id(int(row.instance_id)) as LifeEcologyCritter2D
		assert_eq(critter.modulate, color if row.id == "butterflies" else Color.WHITE)
	if DisplayServer.get_name() != "headless":
		for locale: String in ["vi", "en"]:
			TranslationServer.set_locale(locale)
			for size: Vector2i in [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1920, 1080)]:
				f.viewport.size = size
				await f.settle(self)
				var owners: Dictionary = f.owners()
				f.viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
				await RenderingServer.frame_post_draw
				var image: Image = f.viewport.get_texture().get_image()
				assert_eq(image.get_size(), size)
				assert_eq(image.save_png("user://director_accent_%s_%dx%d.png" % [locale, size.x, size.y]), OK)
				assert_eq(f.owners(), owners)
	await f.advance(self, 2, 100.0, 100.0)
	assert_eq(main.ecology_effects_flow.get_presentation_snapshot(), before)
	for row: Dictionary in before:
		var critter: LifeEcologyCritter2D = instance_from_id(int(row.instance_id)) as LifeEcologyCritter2D
		assert_eq(critter.modulate, Color.WHITE)

func test_off_title_and_readonly_projection_clear_only_application_without_extra_world_or_save_fields() -> void:
	await f.prepare_dust(self)
	await f.advance(self, 2, 100.0, 0.0)
	var before: Dictionary = f.owners()
	var readout: Dictionary = main.director_runtime.get_projection(true)
	readout.water.event.effect.extra_charge = 99
	readout.event_ids.clear()
	assert_eq(f.owners(), before)
	assert_eq(main.director_runtime.get_projection(true).water.event.effect.extra_charge, 1)
	assert_true(main.director_runtime.set_enabled(false))
	assert_eq(main.watering_runtime.get_charge_cost(), 1)
	assert_eq(main.director_runtime.get_projection().visitor, {})
	assert_eq(main.director_runtime.get_projection().accent, [])
	assert_eq(main.director_state.serialize().history, before.director.history)
	assert_eq(main.watering_can.serialize(), before.water)
	assert_true(main._return_to_start_menu())
	assert_eq(main.ecology_effects_flow.get_presentation_snapshot(), [])
	assert_false(main.director_runtime.set_enabled(true))
	assert_false(main.director_runtime.queue_force(&"gentle_dust"))
	var saved: Dictionary = SaveService.load_game(1)
	assert_true(saved.has("director_activity") and saved.has("director"))
	assert_eq(saved.watering_can.size(), 2)
	assert_false(saved.has("director_projection"))
