extends GutTest

var _main: Node
var _viewport: SubViewport
var _clock: Dictionary
var _paused: bool
var _locale: String

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	SaveService.delete_save(0)
	SaveService.delete_save(1)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152,648)
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_start()

func after_each() -> void:
	await _settle()
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)
	SaveService.delete_save(0)
	SaveService.delete_save(1)

func _start() -> void:
	_main.call("_start_new_game","Mai","Vườn")
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	GameClock.paused = true

func test_native_list_filters_and_locale_read_actual_state_without_gameplay_mutation() -> void:
	var before: Dictionary = _domains()
	await _key(KEY_J)
	var panel: NpcPanel = _main.npc_system.journal
	var book: LifeQuestBook = panel.book
	assert_true(panel.visible)
	assert_eq(panel.tabs,book.tabs)
	assert_eq(book.list.rows.get_child_count(),QuestBookSnapshot.capture(_main).entries.size())
	assert_eq(book.detail.objectives.get_child_count(),_main.quest_panel.STEP_KEYS.size())
	assert_eq(book.detail.rewards.note.text,tr("BOOK_NO_REWARD"))
	assert_true(book.filters.buttons[3].disabled)
	await _click(book.list.rows.get_child(1))
	var quest: QuestData = _quest()
	assert_eq(book.detail.title.text,tr(String(quest.title_key)))
	assert_eq(book.detail.status.text,tr("BOOK_STATUS_NEW"))
	assert_eq(book.detail.rewards.coins.text,tr("UI_WALLET_COINS") % quest.reward_coins)
	assert_eq(book.detail.rewards.item.text,tr("BOOK_ITEM_REWARD") % [tr(String(DataRegistry.get_item(quest.reward_item_id).display_name_key)),quest.reward_item_quantity])
	var selected: String = panel.book_controller.selected_key
	for locale: String in ["en","vi"]:
		TranslationServer.set_locale(locale)
		await _settle()
		assert_eq(panel.book_controller.selected_key,selected)
	await _click(book.filters.buttons[2])
	assert_true(book.list.empty.visible)
	assert_eq(book.detail.title.text,tr("BOOK_SELECT"))
	await _click(book.filters.buttons[0])
	assert_false(book.list.empty.visible)
	await _key(KEY_ESCAPE)
	assert_eq(_domains(),before,"Looking/filtering/closing cannot accept, talk, pay or simulate")
	assert_true(GameClock.paused)

func test_native_gui_accept_tab_and_three_tab_navigation_restore_running_clock() -> void:
	GameClock.paused = false
	var bag: Dictionary = _main.inventory.serialize()
	var farm: Dictionary = _main.farm_state.serialize()
	await _key(KEY_J)
	var book: LifeQuestBook = _main.npc_system.journal.book
	book.filters.buttons[2].grab_focus()
	await _key(KEY_SPACE)
	assert_eq(_main.npc_system.journal.book_controller.active_filter,&"completed")
	assert_true(_main.npc_system.journal.visible)
	await _key(KEY_TAB)
	assert_false(_main.inventory_panel.visible,"Native focus does not open Bag")
	book.filters.buttons[0].grab_focus()
	await _key(KEY_ENTER)
	assert_eq(_main.npc_system.journal.book_controller.active_filter,&"all")
	await _key(KEY_E)
	assert_true(_main.inventory_panel.visible)
	await _key(KEY_E)
	assert_true(_main.character_flow.panel.visible)
	await _key(KEY_E)
	assert_true(_main.npc_system.journal.visible)
	await _click(book.tabs.close_button)
	assert_false(GameClock.paused)
	assert_true(_main.world.player.movement_enabled)
	assert_eq(_main.inventory.serialize(),bag)
	assert_eq(_main.farm_state.serialize(),farm)

func test_original_nearby_dialogue_accept_delivery_capacity_guard_and_once_only_reward() -> void:
	var system: NpcSystem = _main.npc_system
	var quest: QuestData = _quest()
	system.debug_visit()
	system.open_dialogue(quest.giver_id)
	await _settle()
	await _click(system.dialogue.column.get_node("AcceptQuest") as Button)
	assert_true(system.state.quests.is_quest_active(quest.quest_id))
	_main.inventory.deserialize({"capacity":1,"slots":[{"item_id":quest.required_item_id,"quantity":quest.required_item_quantity+1}]})
	system.close_panels()
	system.open_journal()
	await _settle()
	system.journal.book_controller.select("delivery:"+String(quest.quest_id))
	await _settle()
	assert_eq(system.journal.book.detail.status.text,tr("BOOK_STATUS_ACTIVE"))
	assert_false(system.state.quests.can_deliver(quest.quest_id,_main.inventory),"Reward cannot fit after removal")
	system.close_panels()
	system.open_dialogue(quest.giver_id)
	await _settle()
	assert_true((system.dialogue.column.get_node("DeliverQuest") as Button).disabled)
	var before: Dictionary = _domains()
	system.call("_deliver",quest.quest_id)
	assert_eq(_domains(),before,"Blocked transaction retains all owners")
	_main.inventory.deserialize({"capacity":40,"slots":[{"item_id":quest.required_item_id,"quantity":quest.required_item_quantity}]})
	system.close_panels()
	system.open_dialogue(quest.giver_id)
	await _settle()
	var coins: int = _main.wallet.get_coins()
	await _click(system.dialogue.column.get_node("DeliverQuest") as Button)
	assert_true(system.state.quests.is_quest_completed(quest.quest_id))
	assert_eq(_main.wallet.get_coins(),coins+quest.reward_coins)
	assert_eq(_main.inventory.get_quantity(quest.reward_item_id),quest.reward_item_quantity)
	assert_eq(_main.inventory.get_quantity(quest.required_item_id),0)
	before = _domains()
	system.call("_deliver",quest.quest_id)
	assert_eq(_domains(),before,"Repeated payout is rejected")
	system.close_panels()
	system.open_journal()
	await _settle()
	assert_eq(system.journal.book.detail.status.text,tr("BOOK_STATUS_COMPLETED"))
	var goal: LifeQuestObjective = system.journal.book.detail.objectives.get_child(0) as LifeQuestObjective
	assert_eq(goal.text.text,"✓ "+tr("BOOK_ITEM_PROGRESS") % [tr(String(DataRegistry.get_item(quest.required_item_id).display_name_key)),0,quest.required_item_quantity])

func test_live_owner_signals_refresh_selected_task_after_complete_state_changes() -> void:
	_main.npc_system.open_journal()
	await _settle()
	var controller: LifeQuestBookController = _main.npc_system.journal.book_controller
	controller.select("delivery:"+String(_quest().quest_id))
	await _settle()
	_main.npc_system.state.quests.accept_quest(_quest().quest_id)
	_main.inventory.add_item(_quest().required_item_id,1)
	await _settle()
	assert_eq(controller.selected_key,"delivery:"+String(_quest().quest_id))
	assert_eq(_main.npc_system.journal.book.detail.status.text,tr("BOOK_STATUS_ACTIVE"))
	var before: Dictionary = _domains()
	controller.filter(&"daily")
	controller.queue_render()
	await _settle()
	assert_eq(controller.active_filter,&"all")
	assert_eq(_domains(),before)

func test_old_saves_reset_transient_book_and_keep_review_and_title_guards() -> void:
	for version: int in range(1,9):
		_start()
		_main.npc_system.open_journal()
		_main.npc_system.journal.book_controller.filter(&"completed")
		var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v%d.json" % version))
		_main.call("_load_payload",raw)
		assert_false(_main.npc_system.journal.visible)
		assert_eq(_main.npc_system.journal.book_controller.active_filter,&"all")
		assert_eq(SaveService.CURRENT_VERSION,16)
		var before: Dictionary = _domains()
		_main.npc_system.open_journal()
		await _settle()
		if _main.day_end_flow.panel.visible:
			assert_false(_main.npc_system.journal.visible)
		assert_eq(_domains(),before)
	_start()
	assert_true(_main.call("_return_to_start_menu"))
	_main.npc_system.open_journal()
	assert_false(_main.npc_system.journal.visible)
	_start()
	GameClock.set_time(20,0)
	assert_true(_main.day_end_flow.request())
	_main.npc_system.journal.show_quest_book()
	assert_false(_main.npc_system.journal.visible)
	assert_true(_main.day_end_flow.cancel())
	GameClock.set_time(25,59)
	GameClock.advance_minutes(1)
	await _key(KEY_J)
	assert_true(_main.day_end_flow.panel.visible)
	assert_false(_main.npc_system.journal.visible)

func _quest() -> QuestData:
	return DataRegistry.get_all_quests()[0] as QuestData

func _domains() -> Dictionary:
	return {"clock":GameClock.serialize(),"social":_main.npc_system.state.serialize(),"bag":_main.inventory.serialize(),"wallet":_main.wallet.serialize(),"quest":_main.quest_state.serialize(),"farm":_main.farm_state.serialize(),"weather":_main.weather_state.serialize(),"ledger":_main.day_end_flow.ledger.serialize(),"review":_main.day_end_flow.state.serialize()}

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
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		event.pressed = pressed
		_viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()
