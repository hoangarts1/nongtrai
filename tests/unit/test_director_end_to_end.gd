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

func _capture(tag: String) -> void:
	var owners: Dictionary = f.owners()
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for size: Vector2i in [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1920, 1080)]:
			f.viewport.size = size
			await f.settle(self)
			if DisplayServer.get_name() != "headless":
				f.viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
				await RenderingServer.frame_post_draw
				var picture: Image = f.viewport.get_texture().get_image()
				assert_eq(picture.get_size(), size)
				assert_eq(picture.save_png("user://director_e2e_%s_%s_%dx%d.png" % [tag, locale, size.x, size.y]), OK)
	assert_eq(f.owners(), owners)

func test_native_enable_request_review_autosave_morning_j_load_continue_active_water_refill_and_expiry() -> void:
	assert_true(main.director_debug_flow.open())
	await f.settle(self)
	await f.mouse(self, main.director_debug_flow.panel.enabled_button.get_global_rect().get_center())
	assert_true(main.director_state.is_enabled())
	await f.key(self, KEY_ESCAPE)
	f.use(&"hoe", Vector2i(1, 1))
	assert_eq(f.current_counts().plot_tilled, 1)
	await f.advance(self, 7, 100.0, 100.0)
	var ecology: Dictionary = main.ecology_state.serialize()
	ecology.metrics.tree_cover = 0.0
	main.ecology_state.deserialize(ecology)
	var weather: Dictionary = main.weather_state.serialize()
	weather.today = "sunny"
	weather.forecast = ["sunny", "sunny", "sunny"]
	main.weather_state.deserialize(weather)
	assert_true(main.director_debug_flow.open())
	await f.settle(self)
	var button: Button = main.director_debug_flow.panel.rows[0].force_button
	assert_false(button.disabled)
	main.director_debug_flow.panel.scroll.ensure_control_visible(button)
	await f.settle(self)
	await f.mouse(self, button.get_global_rect().get_center())
	assert_eq(main.director_state.serialize().forced, "gentle_dust")
	await _capture("queued")
	await f.key(self, KEY_ESCAPE)
	GameClock.set_time(20, 0)
	assert_true(main.day_end_flow.request())
	await f.settle(self)
	await f.mouse(self, main.day_end_flow.panel.continue_button.get_global_rect().get_center())
	main.day_end_flow.confirm()
	assert_eq(GameClock.day_index, 8)
	assert_eq(main.director_state.serialize().pending.size(), 1)
	assert_eq(int(main.director_state.serialize().pending[0].start_day), 10)
	assert_eq(SaveService.load_game(0).director, main.director_state.serialize())
	await f.settle(self)
	assert_true(main.morning_flow.panel.visible)
	assert_true(main.morning_flow.panel.director.summary.text.contains(tr("DIR_DUST_TITLE")))
	await _capture("morning")
	await f.key(self, KEY_ESCAPE)
	await f.key(self, KEY_J)
	var journal: NpcPanel = main.npc_system.journal
	await f.mouse(self, journal.book.ecology_button.get_global_rect().get_center())
	assert_true(journal.book.ecology_sheet.director_history.records.text.contains(tr("DIR_DUST_TITLE")))
	await _capture("journal")
	await f.key(self, KEY_ESCAPE)
	var before: Dictionary = f.owners()
	assert_true(main._save_game_to_slot(98))
	assert_true(main._load_game_from_slot(98))
	assert_eq(f.owners(), before)
	assert_false(main.morning_flow.panel.visible)
	assert_true(main._save_game_to_slot(1))
	assert_true(main._return_to_start_menu())
	main._continue_game()
	assert_eq(f.owners(), before)
	await f.advance(self, 2, 100.0, 0.0)
	assert_eq(main.watering_runtime.get_charge_cost(), 2)
	assert_true(main.farm_state.plant_crop(Vector2i(1, 1), &"turnip"))
	var charges: int = main.watering_can.get_charges()
	f.use(&"watering_can", Vector2i(1, 1))
	assert_eq(main.watering_can.get_charges(), charges - 2)
	main.world.player.move_to_cell(Vector2i(7, 9))
	await f.key(self, KEY_E)
	assert_eq(main.watering_can.get_charges(), main.watering_can.get_capacity())
	await f.advance(self, 1, 100.0, 0.0)
	assert_eq(main.watering_runtime.get_charge_cost(), 1)
	assert_lte(main.ecology_effects_flow.get_presentation_snapshot().size(), 14)

func test_actual_extra_merchant_receipt_is_finite_and_accent_expiry_never_adds_critter_roots() -> void:
	await f.prepare_bloom(self)
	var roots: Array[Dictionary] = main.ecology_effects_flow.get_presentation_snapshot()
	assert_eq(roots.size(), 14)
	assert_true(main.director_runtime.queue_force(&"merchant_visit"))
	await f.advance(self, 1, 100.0, 100.0)
	GameClock.set_time(17, 0)
	var override: Dictionary = main.director_npc_bridge.override()
	assert_eq(override.npc_id, "minh")
	var market: Vector2i = main.npc_system.state.scheduler.location_cell(&"minh_market")
	main.npc_system.state.cells[&"minh"] = market
	main.npc_system.actors[&"minh"].reset_position()
	main.world.player.move_to_cell(market + Vector2i(0, 1))
	var offer: MerchantOfferData = main.npc_system.state.merchant.get_offer(GameClock.day_index, GameClock.season)
	assert_not_null(offer)
	main.wallet.add_coins(10000, &"test_director_trade")
	if offer.kind == "request": main.inventory.add_item(offer.item_id, offer.quantity)
	var before: Dictionary = f.current_counts()
	main.npc_system._trade()
	var after: Dictionary = f.current_counts()
	var key: String = "item_purchased" if offer.kind == "discount" else "item_sold"
	assert_eq(int(after[key]) - int(before[key]), offer.quantity)
	main.npc_system._trade()
	assert_eq(f.current_counts(), after)
	await f.advance(self, 2, 100.0, 100.0)
	assert_eq(main.director_npc_bridge.override(), {})
	assert_lte(main.ecology_effects_flow.get_presentation_snapshot().size(), 14)
	for row: Dictionary in roots:
		var critter: LifeEcologyCritter2D = instance_from_id(int(row.instance_id)) as LifeEcologyCritter2D
		assert_true(is_instance_valid(critter))
		if is_instance_valid(critter): assert_eq(critter.modulate, Color.WHITE)
