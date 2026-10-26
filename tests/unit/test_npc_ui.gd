extends GutTest

const SLOT: int = 95
var _clock: Dictionary = {}
var _paused: bool = false

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused

func after_each() -> void:
	SaveService.delete_save(SLOT)
	GameClock.deserialize(_clock)
	GameClock.paused = _paused

func _main() -> Node:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	add_child_autofree(main)
	main.set("_game_started", true)
	main.start_menu.hide()
	main.tutorial_panel.hide()
	main.world.player.movement_enabled = true
	return main

func test_playable_delivery_flow_and_save_load_keep_social_progress() -> void:
	var main: Node = _main()
	var system: NpcSystem = main.npc_system
	system.debug_visit()
	await get_tree().process_frame
	system.open_dialogue(&"minh")
	assert_true(system.dialogue.visible)
	assert_true(GameClock.paused)
	assert_false(main.world.player.movement_enabled)
	var before: Dictionary = main.inventory.serialize()
	system.dialogue.column.get_node("AcceptQuest").pressed.emit()
	assert_true(system.state.quests.is_quest_active(&"turnip_delivery"))
	assert_eq(main.inventory.serialize(), before)
	assert_true((system.dialogue.column.get_node("DeliverQuest") as Button).disabled)
	system.close_panels()
	system.debug_delivery_items()
	system.open_dialogue(&"minh")
	assert_false((system.dialogue.column.get_node("DeliverQuest") as Button).disabled)
	var coins: int = main.wallet.get_coins()
	system.dialogue.column.get_node("DeliverQuest").pressed.emit()
	assert_true(system.state.quests.is_quest_completed(&"turnip_delivery"))
	assert_eq(main.inventory.get_quantity(&"turnip"), 0)
	assert_eq(main.wallet.get_coins(), coins + 60)
	assert_true(main.get("_save_dirty"), "Wallet and social changes schedule autosave")
	main.call("_save_game_to_slot", SLOT)
	assert_true(SaveService.load_game(SLOT).is_empty(), "Dialogue is not a safe save point")
	system.close_panels()
	var social: Dictionary = system.state.serialize()
	main.call("_save_game_to_slot", SLOT)
	var payload: Dictionary = SaveService.load_game(SLOT)
	assert_eq(payload["social"]["quests"]["completed"], ["turnip_delivery"])
	system.restore({})
	main.call("_load_payload", payload)
	var restored_social: Dictionary = system.state.serialize()
	for field: String in social:
		assert_eq(restored_social[field], social[field], "%s: %s / %s" % [field, restored_social[field], social[field]])
	await get_tree().process_frame

func test_journal_and_dialogue_layout_at_three_sizes_in_both_locales() -> void:
	var old_locale: String = TranslationServer.get_locale()
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for viewport_size: Vector2i in [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1920, 1080)]:
			get_tree().root.size = viewport_size
			get_viewport().size = viewport_size
			var main: Node = _main()
			var system: NpcSystem = main.npc_system
			system.open_journal()
			await get_tree().process_frame
			await get_tree().process_frame
			_check_panel(system.journal, viewport_size, main.hotbar_panel)
			await _capture("journal", locale, viewport_size)
			var inventory_before: Dictionary = main.inventory.serialize()
			var event: InputEventAction = InputEventAction.new()
			event.action = &"pause"
			event.pressed = true
			system._input(event)
			assert_false(system.is_open())
			assert_false(main.pause_menu.visible)
			assert_eq(main.inventory.serialize(), inventory_before)
			system.debug_visit()
			await get_tree().process_frame
			system.state.quests.accept_quest(&"turnip_delivery")
			system.open_dialogue(&"minh")
			await get_tree().process_frame
			await get_tree().process_frame
			_check_panel(system.dialogue, viewport_size, main.hotbar_panel)
			await _capture("dialogue", locale, viewport_size)
			for child: Node in system.dialogue.column.get_children():
				if child is Button:
					assert_lte((child as Button).size.x, system.dialogue.size.x - 24.0)
			system.close_panels()
			main.free()
	TranslationServer.set_locale(old_locale)

func _check_panel(panel: NpcPanel, viewport_size: Vector2i, hotbar: Control) -> void:
	assert_true(panel.visible, "Panel must actually open")
	assert_true(Rect2(Vector2.ZERO, Vector2(viewport_size)).encloses(panel.get_global_rect()), "Panel inside viewport")
	assert_false(hotbar.visible, "Modal hides hotbar instead of competing for screen space")
	assert_true(panel.get_global_rect().encloses(panel.close_button.get_global_rect()), "Close button is reachable")
	assert_true(panel.get_global_rect().encloses(panel.title_label.get_global_rect()), "Title inside panel")

func _capture(mode: String, locale: String, viewport_size: Vector2i) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var screenshot: Image = get_viewport().get_texture().get_image()
	var path: String = "user://npc_%s_%s_%dx%d.png" % [mode, locale, viewport_size.x, viewport_size.y]
	assert_eq(screenshot.save_png(path), OK, "Save rendered UI evidence")

func test_rain_and_night_send_actors_home_and_block_talk() -> void:
	var main: Node = _main()
	var system: NpcSystem = main.npc_system
	system.debug_visit()
	await get_tree().process_frame
	main.weather_state.force_weather(&"rain")
	assert_eq(system.state.targets[&"minh"], &"minh_home")
	while not system.state.paths[&"minh"].is_empty():
		system.state.advance_step(&"minh")
	await get_tree().process_frame
	assert_true(system.state.is_indoors(&"minh"))
	system.open_dialogue(&"minh")
	assert_false(system.is_open())
	main.weather_state.force_weather(&"sunny")
	GameClock.set_time(20, 0)
	assert_eq(system.state.targets[&"minh"], &"minh_home")

func test_real_input_dispatch_opens_npc_before_world_and_consumes_modal_shortcuts() -> void:
	var main: Node = _main()
	var system: NpcSystem = main.npc_system
	system.debug_visit()
	await get_tree().process_frame
	_push_action(&"interact")
	assert_true(system.dialogue.visible, "E reaches nearby NPC")
	assert_false(main.seed_shop_panel.visible)
	assert_false(main.shipping_bin_panel.visible)
	_push_action(&"open_inventory")
	assert_true(main.inventory_panel.visible, "Inventory shortcut switches to inventory")
	assert_false(system.dialogue.visible, "Switching closes dialogue")
	assert_false(main.hud_button_bar.visible, "HUD cannot open another modal")
	_push_action(&"pause")
	assert_false(system.is_open())
	assert_false(main.pause_menu.visible, "Esc closes dialogue before pause")
	assert_true(main.hud_button_bar.visible)
	_push_action(&"open_journal")
	assert_true(system.journal.visible, "J opens journal")
	_push_action(&"open_journal")
	assert_false(system.is_open(), "J closes journal")
	await get_tree().process_frame

func _push_action(action: StringName) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = action
	event.pressed = true
	get_viewport().push_input(event)
