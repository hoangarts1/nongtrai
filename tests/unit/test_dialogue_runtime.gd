extends GutTest

var _main: Node
var _viewport: SubViewport
var _clock: Dictionary
var _paused: bool
var _locale: String
var _files: Dictionary = {}

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	for slot: int in [0, 1]:
		for index: int in range(4):
			var path: String = "user://saves/slot_%d.json%s" % [slot, "" if index == 0 else ".bak%d" % index]
			_files[path] = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152, 648)
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_main.set("_game_started", true)
	_main.set_process(false)
	_main.start_menu.hide()
	_main.tutorial_panel.hide()
	_main.ui_coordinator.close_active()
	GameClock.paused = false

func after_each() -> void:
	await _settle()
	_viewport.free()
	for path: String in _files:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		var bytes: Variant = _files[path]
		if bytes is PackedByteArray:
			var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
			file.store_buffer(bytes)
			file.close()
	_files.clear()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func _key(code: Key) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		_viewport.push_input(event, true)
		await get_tree().process_frame
	await _settle()

func _click(button: Control) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = button.get_global_rect().get_center()
		event.global_position = event.position
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		event.pressed = pressed
		_viewport.push_input(event, true)
		await get_tree().process_frame
	await _settle()

func _visit(id: StringName = &"minh") -> void:
	var system: NpcSystem = _main.npc_system
	system.close_panels()
	if id == &"minh":
		system.debug_visit()
	else:
		_main.weather_state.call("force_weather", &"sunny")
		GameClock.day_index = 0
		var entry: NpcScheduleEntry = system.state.get_npc(id).schedule[0] as NpcScheduleEntry
		GameClock.set_time(entry.start_minute / 60, posmod(entry.start_minute, 60))
		system.call("_refresh_schedule")
		while not system.state.paths.get(id, []).is_empty():
			system.state.advance_step(id)
		(system.actors[id] as NpcActor).reset_position()
		_main.world.player.move_to_cell(system.state.cells[id] + Vector2i(0, -1))

func _owners() -> Dictionary:
	return {"social": _main.npc_system.state.serialize(), "items": _main.inventory.serialize(), "coins": _main.wallet.serialize(), "farm": _main.farm_state.serialize()}

func test_native_e_mouse_accept_space_deliver_once_and_escape_preserve_book_and_real_rewards() -> void:
	_visit()
	await _settle()
	await _key(KEY_E)
	var panel: NpcPanel = _main.npc_system.dialogue
	assert_true(panel.visible)
	assert_eq(panel.column, panel.dialogue_screen.choices)
	assert_eq(_main.ui_coordinator.get_active_panel(), panel)
	await _click(panel.column.get_node("AcceptQuest") as Button)
	var quest: QuestData = _main.npc_system.state.quests.get_quest(&"turnip_delivery")
	assert_true(_main.npc_system.state.quests.is_quest_active(quest.quest_id))
	assert_true((panel.column.get_node("DeliverQuest") as Button).disabled)
	assert_eq(_main.inventory.add_item(quest.required_item_id, quest.required_item_quantity), quest.required_item_quantity)
	await _settle()
	var button: Button = panel.column.get_node("DeliverQuest") as Button
	assert_false(button.disabled, "Live inventory signal refreshes the disabled action")
	var old_callback: Callable = button.pressed.get_connections()[0].callable
	var coins: int = _main.wallet.get_coins()
	var reward_items: int = _main.inventory.get_quantity(quest.reward_item_id)
	var entries: int = _main.day_end_flow.ledger.serialize().entries.size()
	button.grab_focus()
	await _key(KEY_SPACE)
	old_callback.call()
	assert_true(_main.npc_system.state.quests.is_quest_completed(quest.quest_id))
	assert_eq(_main.wallet.get_coins(), coins + quest.reward_coins)
	assert_eq(_main.inventory.get_quantity(quest.reward_item_id), reward_items + quest.reward_item_quantity)
	assert_eq(_main.inventory.get_quantity(quest.required_item_id), 0)
	assert_eq(_main.day_end_flow.ledger.serialize().entries.size(), entries + 1)
	assert_eq(_main.day_end_flow.ledger.serialize().entries.back().amount, quest.reward_coins)
	await _key(KEY_TAB)
	await _key(KEY_ESCAPE)
	assert_false(panel.visible)
	assert_false(_main.pause_menu.visible)
	assert_eq(_main.hud_presenter.root.toasts.z_index, 82)
	_visit()
	await _key(KEY_E)
	panel.close_button.grab_focus()
	await _key(KEY_ENTER)
	assert_false(panel.visible)
	_main.npc_system.open_journal()
	assert_true(_main.npc_system.journal.book != null)
	assert_true(_main.npc_system.journal.visible)

func test_trade_reentry_double_request_and_close_shortcut_callbacks_cannot_duplicate_a_transaction() -> void:
	_visit()
	_main.npc_system.open_dialogue(&"minh")
	await _settle()
	var offer: MerchantOfferData = _main.npc_system.state.merchant.get_offer(GameClock.day_index, GameClock.season)
	var total: int = offer.quantity * offer.unit_price
	_main.wallet.add_coins(total, &"test_fund")
	if offer.kind != "discount":
		assert_eq(_main.inventory.add_item(offer.item_id, offer.quantity), offer.quantity)
	var before_coins: int = _main.wallet.get_coins()
	var before_items: int = _main.inventory.get_quantity(offer.item_id)
	var entries: int = _main.day_end_flow.ledger.serialize().entries.size()
	var attempts: Array[bool] = []
	_main.wallet.coins_changed.connect(func(_total: int, _delta: int, _reason: StringName) -> void:
		attempts.append(_main.npc_system.request_dialogue_action(&"ConfirmOffer"))
		_main.npc_system.close_panels()
		var event: InputEventAction = InputEventAction.new()
		event.action = &"open_inventory"
		event.pressed = true
		_main.ui_coordinator.call("_input", event))
	var button: Button = _main.npc_system.dialogue.column.get_node("ConfirmOffer") as Button
	var callback: Callable = button.pressed.get_connections()[0].callable
	callback.call()
	callback.call()
	assert_eq(attempts, [false])
	assert_true(_main.npc_system.dialogue.visible)
	assert_false(_main.inventory_panel.visible)
	assert_true(_main.npc_system.state.merchant.is_consumed(GameClock.day_index))
	assert_eq(_main.wallet.get_coins(), before_coins + (-total if offer.kind == "discount" else total))
	assert_eq(_main.inventory.get_quantity(offer.item_id), before_items + (offer.quantity if offer.kind == "discount" else -offer.quantity))
	assert_true((_main.npc_system.dialogue.column.get_node("ConfirmOffer") as Button).disabled)
	assert_eq(_main.day_end_flow.ledger.serialize().entries.size(), entries + 1)
	assert_eq(_main.day_end_flow.ledger.serialize().entries.back().amount, -total if offer.kind == "discount" else total)

func test_stale_hidden_wrong_npc_load_newgame_and_legacy_content_do_not_execute_old_actions() -> void:
	_visit()
	_main.npc_system.open_dialogue(&"minh")
	var old: Callable = (_main.npc_system.dialogue.column.get_node("AcceptQuest") as Button).pressed.get_connections()[0].callable
	_main.npc_system.close_panels()
	var before: Dictionary = _owners()
	old.call()
	assert_eq(_owners(), before)
	assert_true(_main.call("_save_game"))
	_visit(&"linh")
	_main.npc_system.open_dialogue(&"linh")
	assert_true(_main.npc_system.dialogue.visible)
	before = _owners()
	old.call()
	assert_false(_main.npc_system.request_dialogue_action(&"AcceptQuest"))
	assert_eq(_owners(), before)
	assert_true(_main.call("_load_game"))
	assert_false(_main.npc_system.dialogue.visible)
	before = _owners()
	old.call()
	assert_eq(_owners(), before)
	_main.call("_start_new_game", "Mai", "Vườn mới")
	before = _owners()
	old.call()
	assert_eq(_owners(), before)
	var legacy: NpcPanel = NpcPanel.new()
	_main.add_child(legacy)
	var calls: Array[bool] = []
	legacy.show_content("Legacy", "Body", [{"id": "LegacyAction", "text": "Action", "callback": func() -> void: calls.append(true)}])
	(legacy.column.get_node("LegacyAction") as Button).pressed.emit()
	assert_eq(calls, [true])
	legacy.free()

func test_actual_dialogue_matrix_locales_sizes_states_keeps_aliases_bounds_and_readonly_refresh() -> void:
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1920, 1080)]:
			_viewport.size = dimensions
			for kind: String in ["intro", "blocked", "ready", "done", "linh"]:
				_visit(&"linh" if kind == "linh" else &"minh")
				_main.npc_system.state.quests.deserialize({})
				_main.inventory.clear()
				var quest: QuestData = _main.npc_system.state.quests.get_quest(&"turnip_delivery")
				if kind in ["blocked", "ready", "done"]:
					assert_true(_main.npc_system.state.quests.accept_quest(quest.quest_id))
				if kind in ["ready", "done"]:
					assert_eq(_main.inventory.add_item(quest.required_item_id, quest.required_item_quantity), quest.required_item_quantity)
				if kind == "done":
					assert_true(_main.npc_system.state.quests.confirm_delivery(quest.quest_id, _main.inventory, _main.wallet))
				_main.npc_system.open_dialogue(&"linh" if kind == "linh" else &"minh")
				await _settle()
				var panel: NpcPanel = _main.npc_system.dialogue
				assert_true(panel.visible)
				var bounds: Rect2 = panel.get_global_rect()
				assert_true(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(bounds))
				for control: Control in [panel.title_label, panel.close_button, panel.dialogue_screen.speaker, panel.dialogue_screen.body, panel.dialogue_screen.choices]:
					assert_true(bounds.encloses(control.get_global_rect()), "%s/%s/%s %s: %s within %s" % [locale, dimensions, kind, control.name, control.get_global_rect(), bounds])
				assert_eq(panel.column, panel.dialogue_screen.choices)
				assert_false(_main.hotbar_panel.visible)
				assert_lt(_main.hud_presenter.root.toasts.z_index, panel.z_index)
				assert_true(GameClock.paused)
				var before: Dictionary = _owners()
				_main.npc_system.refresh_dialogue()
				assert_eq(_owners(), before)
				if DisplayServer.get_name() != "headless":
					await RenderingServer.frame_post_draw
					assert_eq(_viewport.get_texture().get_image().save_png("user://dialogue_runtime_%s_%s_%d.png" % [locale, kind, dimensions.x]), OK)
				_main.npc_system.close_panels()
