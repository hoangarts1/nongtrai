extends GutTest

var _state: NpcSocialState
var _inventory: InventoryState
var _viewport: SubViewport
var _host: Node
var _screen: LifeDialogueScreen
var _clock: Dictionary
var _paused: bool
var _locale: String

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	_state = NpcSocialState.new()
	_state.configure(preload("res://data/npcs/phase8_world.tres"))
	_inventory = InventoryState.new()

func after_each() -> void:
	if is_instance_valid(_viewport):
		_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)

func _snapshot(id: StringName = &"minh") -> Dictionary:
	return LifeDialogueSnapshot.build(_state, _inventory, id, 1, &"spring")

func _owners() -> Dictionary:
	return {"social": _state.serialize(), "inventory": _inventory.serialize()}

func _view() -> void:
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152, 648)
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)
	_host = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_host)
	_host.set("_game_started", true)
	_host.set_process(false)
	_host.start_menu.hide()
	_host.tutorial_panel.hide()
	_host.ui_coordinator.close_active()
	_host.hud_presenter.root.hide()
	GameClock.paused = true
	_screen = preload("res://ui/dialogue/dialogue_screen.tscn").instantiate() as LifeDialogueScreen
	_host.add_child(_screen)
	_screen.position = Vector2(24, 24)
	_screen.size = Vector2(_viewport.size) - Vector2(48, 48)
	_screen.z_index = 10

func _action(snapshot: Dictionary, id: StringName) -> Dictionary:
	for action: Dictionary in snapshot.actions:
		if action.id == id:
			return action
	return {}

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

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

func test_snapshots_match_registered_dialogue_portrait_identity_and_exact_friendship_without_mutation() -> void:
	_state.friendship[&"linh"] = 37
	var before: Dictionary = _owners()
	for id: StringName in [&"minh", &"linh"]:
		var snapshot: Dictionary = _snapshot(id)
		var npc: NpcData = _state.get_npc(id)
		var line: DialogueData = _state.get_dialogue(id, &"spring")
		assert_eq(snapshot.name, tr(String(npc.display_name_key)))
		assert_eq(snapshot.body, tr(String(line.text_key)))
		assert_eq(snapshot.friendship, int(_state.friendship[id]))
		assert_eq(snapshot.friendship_max, npc.friendship_max)
		assert_eq(snapshot.npc_id, id)
		assert_eq(snapshot.color, npc.color)
		for action: Dictionary in snapshot.actions:
			assert_false(action.has("callback"))
		assert_eq(_owners(), before)
		(snapshot.actions as Array).clear()
		assert_eq(_owners(), before)
	assert_true(_snapshot(&"missing").is_empty())
	assert_true(LifeDialogueSnapshot.build(null, _inventory, &"minh", 1, &"spring").is_empty())

func test_registered_quest_requirements_rewards_and_offer_enabled_states_are_real() -> void:
	var quest: QuestData = _state.quests.get_quest(&"turnip_delivery")
	assert_true(_action(_snapshot(), &"AcceptQuest").enabled)
	assert_true(_state.quests.accept_quest(quest.quest_id))
	var blocked: Dictionary = _snapshot()
	assert_false(_action(blocked, &"DeliverQuest").enabled)
	assert_true(blocked.details.contains(str(quest.required_item_quantity)))
	assert_true(blocked.details.contains(str(quest.reward_coins)))
	assert_eq(_inventory.add_item(quest.required_item_id, quest.required_item_quantity), quest.required_item_quantity)
	var before: Dictionary = _owners()
	assert_true(_action(_snapshot(), &"DeliverQuest").enabled)
	assert_eq(_owners(), before)
	var merchant: Dictionary = _state.merchant.serialize()
	merchant["consumed_days"] = [1]
	_state.merchant.deserialize(merchant)
	assert_false(_action(_snapshot(), &"ConfirmOffer").enabled)
	var wallet: WalletState = WalletState.new()
	assert_true(_state.quests.confirm_delivery(quest.quest_id, _inventory, wallet))
	assert_true(_action(_snapshot(), &"AcceptQuest").is_empty())
	assert_true(_action(_snapshot(), &"DeliverQuest").is_empty())
	assert_eq(_snapshot().body, tr(String(_state.get_dialogue(&"minh", &"spring").text_key)))

func test_native_choices_emit_only_requests_and_reject_disabled_hidden_or_stale_buttons() -> void:
	_view()
	var requests: Array[StringName] = []
	var closed: Array[bool] = []
	_screen.requested.connect(func(id: StringName) -> void: requests.append(id))
	_screen.closed.connect(func() -> void: closed.append(true))
	_screen.display(_snapshot())
	await _settle()
	var before: Dictionary = _owners()
	var old: Button = _screen.choices.get_node("AcceptQuest") as Button
	await _click(old)
	assert_eq(requests, [&"AcceptQuest"])
	assert_eq(_owners(), before, "The component must not accept the quest")
	var close_id: int = _screen.close_button.get_instance_id()
	_screen.display(_snapshot(&"linh"))
	old.pressed.emit()
	assert_eq(requests.size(), 1, "Old revision cannot request anything")
	assert_eq(_screen.close_button.get_instance_id(), close_id)
	assert_true(_state.quests.accept_quest(&"turnip_delivery"))
	_screen.display(_snapshot())
	var disabled: Button = _screen.choices.get_node("DeliverQuest") as Button
	assert_true(disabled.disabled)
	disabled.pressed.emit()
	assert_eq(requests.size(), 1)
	_screen.hide()
	(_screen.choices.get_node("ConfirmOffer") as Button).pressed.emit()
	assert_eq(requests.size(), 1)
	_screen.show()
	await _settle()
	await _click(_screen.close_button)
	assert_eq(closed.size(), 1)
	_screen.size = Vector2(800, 420)
	_screen.display(_snapshot())
	await _settle()
	for control: Control in [_screen.speaker, _screen.body, _screen.choices, _screen.close_button]:
		assert_true(_screen.get_global_rect().encloses(control.get_global_rect()), "Reduced-space controls stay reachable")

func test_mockup12_component_matrix_scroll_focus_and_portraits_both_locales_three_sizes() -> void:
	_view()
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1920, 1080)]:
			_viewport.size = dimensions
			_screen.size = Vector2(dimensions) - Vector2(48, 48)
			for kind: String in ["intro", "blocked", "ready", "completed", "linh", "long"]:
				_state = NpcSocialState.new()
				_state.configure(preload("res://data/npcs/phase8_world.tres"))
				_inventory = InventoryState.new()
				var quest: QuestData = _state.quests.get_quest(&"turnip_delivery")
				if kind in ["blocked", "ready", "completed", "long"]:
					assert_true(_state.quests.accept_quest(quest.quest_id))
				if kind in ["ready", "completed"]:
					assert_eq(_inventory.add_item(quest.required_item_id, quest.required_item_quantity), quest.required_item_quantity)
				if kind == "completed":
					assert_true(_state.quests.confirm_delivery(quest.quest_id, _inventory, WalletState.new()))
				_state.friendship[&"linh"] = 37
				var snapshot: Dictionary = _snapshot(&"linh" if kind == "linh" else &"minh")
				if kind == "long":
					snapshot.body = String(snapshot.body).repeat(15)
				var before: Dictionary = _owners()
				_screen.display(snapshot)
				await _settle()
				var bounds: Rect2 = _screen.get_global_rect()
				assert_true(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(bounds))
				for control: Control in [_screen.speaker, _screen.body, _screen.choices, _screen.close_button, _screen.speaker.name_label]:
					assert_true(bounds.encloses(control.get_global_rect()), "%s %s %s bounds=%s child=%s min=%s" % [locale, kind, control.get_class(), bounds, control.get_global_rect(), control.get_combined_minimum_size()])
				assert_true(_screen.body.get_global_rect().encloses(_screen.body.scroll.get_global_rect()))
				assert_true(_screen.speaker.portrait.avatar != null)
				assert_eq(_screen.body.text.text, snapshot.body)
				assert_true(_screen.body.friendship.text.contains(str(snapshot.friendship_max)))
				assert_eq(_owners(), before)
				if kind == "long":
					assert_gt(_screen.body.scroll.get_v_scroll_bar().max_value, _screen.body.scroll.get_v_scroll_bar().page)
				_screen.close_button.grab_focus()
				assert_true(_screen.close_button.has_focus())
				if DisplayServer.get_name() != "headless":
					await RenderingServer.frame_post_draw
					assert_eq(_viewport.get_texture().get_image().save_png("user://dialogue_component_%s_%s_%d.png" % [locale, kind, dimensions.x]), OK)
