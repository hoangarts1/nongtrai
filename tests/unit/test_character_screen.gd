extends GutTest

var _main: Node
var _viewport: SubViewport
var _clock: Dictionary
var _paused: bool
var _locale: String
var _tutorial_dismissed: bool

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	_tutorial_dismissed = Settings.is_tutorial_dismissed()
	Settings.set_tutorial_dismissed(false)
	SaveService.delete_save(0)
	SaveService.delete_save(1)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152,648)
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_start("Mai","Vườn")

func after_each() -> void:
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)
	Settings.set_tutorial_dismissed(_tutorial_dismissed)
	SaveService.delete_save(0)
	SaveService.delete_save(1)

func _start(player: String, farm: String) -> void:
	_main.call("_start_new_game",player,farm)
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	GameClock.paused = true

func test_native_three_tab_order_wrap_and_close_preserve_all_owners() -> void:
	var before: Dictionary = _domains()
	_main.inventory_panel.toggle_inventory()
	await _settle()
	await _key(KEY_E)
	assert_eq(_main.ui_coordinator.get_active_panel(),_main.character_flow.panel)
	assert_false(_main.inventory_panel.visible)
	assert_false(_main.npc_system.journal.visible)
	assert_false(_main.world.player.movement_enabled)
	await _key(KEY_E)
	assert_true(_main.npc_system.journal.visible)
	await _key(KEY_E)
	assert_true(_main.inventory_panel.visible)
	await _key(KEY_Q)
	assert_true(_main.npc_system.journal.visible)
	await _key(KEY_Q)
	assert_true(_main.character_flow.panel.visible)
	await _click(_main.character_flow.panel.tabs.buttons[0])
	assert_true(_main.inventory_panel.visible)
	await _click(_main.inventory_panel.screen.tabs.buttons[1])
	assert_true(_main.character_flow.panel.visible)
	await _click(_main.character_flow.panel.tabs.close_button)
	assert_eq(_main.ui_coordinator.get_active_panel(),null)
	assert_true(GameClock.paused,"Original hold survives tab switching")
	assert_eq(_domains(),before,"Tabs/close cannot talk, transact, simulate or reroll")

func test_actual_friendship_owner_changes_refresh_without_remote_talk_or_rewards() -> void:
	var social: NpcSocialState = _main.npc_system.state
	var npc: NpcData = social.content.npcs[0] as NpcData
	assert_not_null(social.talk(npc.npc_id,GameClock.day_index,GameClock.season))
	var before: Dictionary = _domains()
	_main.character_flow.open()
	await _settle()
	var card: LifeCharacterRelationship = _main.character_flow.panel.relationships.cards.get_child(0) as LifeCharacterRelationship
	assert_eq(card.points.text,tr("CHAR_FRIENDSHIP") % [int(social.friendship[npc.npc_id]),npc.friendship_max])
	for locale: String in ["en","vi","en"]:
		TranslationServer.set_locale(locale)
		_main.character_flow.refresh()
	await _key(KEY_F)
	await _key(KEY_Z)
	await _key(KEY_TAB)
	assert_true(_main.character_flow.panel.visible)
	assert_false(_main.inventory_panel.visible)
	assert_eq(_domains(),before)
	var saved: Dictionary = social.serialize()
	saved.friendship[String(npc.npc_id)] = npc.friendship_max
	social.deserialize(saved)
	await _settle()
	card = _main.character_flow.panel.relationships.cards.get_child(0) as LifeCharacterRelationship
	assert_eq(card.hearts.filled,5)
	assert_eq(card.points.text,tr("CHAR_FRIENDSHIP") % [npc.friendship_max,npc.friendship_max])
	before = _domains()
	await _key(KEY_ESCAPE)
	assert_eq(_domains(),before)
	assert_true(GameClock.paused)

func test_native_accept_and_escape_restore_running_clock_without_world_action() -> void:
	GameClock.paused = false
	var farm: Dictionary = _main.farm_state.serialize()
	var bag: Dictionary = _main.inventory.serialize()
	_main.character_flow.open()
	await _settle()
	assert_true(GameClock.paused)
	_main.character_flow.panel.tabs.buttons[1].grab_focus()
	await _key(KEY_SPACE)
	assert_true(_main.character_flow.panel.visible,"Native accept on current tab stays in Character")
	_main.character_flow.panel.tabs.close_button.grab_focus()
	await _key(KEY_ENTER)
	assert_false(_main.character_flow.panel.visible)
	assert_false(GameClock.paused)
	assert_true(_main.world.player.movement_enabled)
	assert_eq(_main.farm_state.serialize(),farm)
	assert_eq(_main.inventory.serialize(),bag)
	_main.character_flow.open()
	await _key(KEY_ESCAPE)
	assert_false(_main.character_flow.panel.visible)
	assert_false(GameClock.paused)

func test_start_tutorial_sleep_and_day_end_guards_prevent_character_bypass() -> void:
	assert_true(_main.call("_return_to_start_menu"))
	_main.character_flow.open()
	assert_false(_main.character_flow.panel.visible)
	_main.call("_start_new_game","Mai","Vườn")
	_main.character_flow.open()
	assert_false(_main.character_flow.panel.visible,"Tutorial is not bypassed")
	_main.tutorial_panel.close_help()
	GameClock.paused = false
	GameClock.set_time(20,0)
	assert_true(GameClock.try_sleep())
	_main.character_flow.open()
	assert_false(_main.character_flow.panel.visible)
	GameClock.advance_minutes(GameClock.SLEEP_END_MINUTE-GameClock.minute)
	await _settle()
	assert_true(_main.morning_flow.panel.visible)
	_main.morning_flow.dismiss()
	GameClock.set_time(20,0)
	assert_true(_main.day_end_flow.request())
	_main.character_flow.open()
	assert_false(_main.character_flow.panel.visible)
	_main.character_flow.panel.show()
	assert_false(_main.character_flow.panel.visible,"Modal owner rejects programmatic overlap")
	assert_true(_main.day_end_flow.cancel())
	GameClock.set_time(25,59)
	GameClock.advance_minutes(1)
	assert_true(_main.day_end_flow.panel.visible)
	for code: Key in [KEY_Q,KEY_E,KEY_B]:
		await _key(code)
		assert_false(_main.character_flow.panel.visible)
		assert_true(_main.day_end_flow.panel.visible)
	assert_false(_main.day_end_flow.cancel())

func test_old_saves_and_new_game_refresh_real_profile_without_saved_ui_state() -> void:
	for version: int in range(1,9):
		_start("Mai","Vườn")
		_main.character_flow.open()
		var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v%d.json" % version))
		_main.call("_load_payload",raw)
		assert_false(_main.character_flow.panel.visible)
		assert_eq(SaveService.CURRENT_VERSION,15)
		var snapshot: Dictionary = CharacterSnapshot.capture(_main)
		assert_eq(snapshot.appearance,LifeCharacterPortrait.CATALOG.normalize_player_customization(_main.profile.appearance))
		var before: Dictionary = _domains()
		_main.character_flow.open()
		if _main.day_end_flow.panel.visible:
			assert_false(_main.character_flow.panel.visible)
		else:
			assert_true(_main.character_flow.panel.visible)
			assert_eq(_main.character_flow.panel.identity.player_name.text,String(snapshot.player_name) if not String(snapshot.player_name).is_empty() else tr("UI_DEFAULT_PLAYER"))
			_main.character_flow.close()
		assert_eq(_domains(),before)
	_start("Nông dân mới","Vườn mới")
	_main.character_flow.open()
	assert_eq(_main.character_flow.panel.identity.player_name.text,"Nông dân mới")
	assert_eq(_main.character_flow.panel.identity.farm_name.text,"Vườn mới")
	_main.call("_return_to_start_menu")
	assert_false(_main.character_flow.panel.visible)

func _domains() -> Dictionary:
	return {"clock":GameClock.serialize(),"profile":_main.profile.duplicate(true),"social":_main.npc_system.state.serialize(),"farm":_main.farm_state.serialize(),"weather":_main.weather_state.serialize(),"bag":_main.inventory.serialize(),"wallet":_main.wallet.serialize(),"quest":_main.quest_state.serialize(),"ledger":_main.day_end_flow.ledger.serialize(),"review":_main.day_end_flow.state.serialize()}

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func _key(code: Key) -> void:
	for pressed: bool in [true,false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		_viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()

func _click(control: Control) -> void:
	var point: Vector2 = control.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	_viewport.push_input(motion,true)
	for pressed: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = point
		event.global_position = point
		event.pressed = pressed
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		_viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()
