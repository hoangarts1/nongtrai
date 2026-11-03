extends GutTest

const SIZES: Array[Vector2i] = [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]
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
	_viewport.size = SIZES[0]
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)

func after_each() -> void:
	await _settle()
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)
	SaveService.delete_save(0)
	SaveService.delete_save(1)

func _fixture(kind: String) -> void:
	_main.call("_start_new_game","Mai","Vườn")
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	GameClock.paused = true
	var quest: QuestData = DataRegistry.get_all_quests()[0] as QuestData
	var flags: Array[bool] = []
	for index: int in range(_main.quest_panel.STEP_KEYS.size()):
		flags.append(kind=="done" or index<2)
	_main.quest_state.deserialize({"completed":flags})
	if kind in ["active","ready","long"]:
		_main.npc_system.state.quests.accept_quest(quest.quest_id)
	if kind=="done":
		_main.npc_system.state.quests.deserialize({"completed":[String(quest.quest_id)]})
	if kind in ["active","ready"]:
		_main.inventory.add_item(quest.required_item_id,quest.required_item_quantity if kind=="ready" else 1)
	_main.npc_system.open_journal()
	await _settle()
	var controller: LifeQuestBookController = _main.npc_system.journal.book_controller
	if kind not in ["tutorial","empty"]:
		controller.select("delivery:"+String(quest.quest_id))
	if kind=="empty":
		controller.filter(&"completed")
	await _settle()
	if kind=="long":
		_main.npc_system.journal.book.detail.description.text = (tr(String(quest.description_key))+" ").repeat(15)
	await _settle()

func test_reference08_both_locales_three_sizes_real_task_states_and_fixed_actions() -> void:
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in SIZES:
			_viewport.size = dimensions
			for kind: String in ["tutorial","new","active","ready","done","empty","long"]:
				await _fixture(kind)
				var panel: NpcPanel = _main.npc_system.journal
				var book: LifeQuestBook = panel.book
				assert_true(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(panel.get_global_rect()),"Book fits %s/%s: %s" % [dimensions,kind,panel.get_global_rect()])
				for region: Control in [book.tabs,book.filters,book.list,book.detail,book.detail.pin_button,book.detail.map_button,book.hint]:
					assert_true(panel.get_global_rect().encloses(region.get_global_rect()),"Region fits: %s %s" % [region.name,region.get_global_rect()])
				assert_false(book.list.get_global_rect().intersects(book.detail.get_global_rect()))
				assert_true(book.detail.pin_button.disabled)
				assert_true(book.detail.map_button.disabled)
				assert_true(book.filters.buttons[3].disabled)
				assert_true(book.find_children("*","ProgressBar",true,false).is_empty(),"No fake XP/progress")
				assert_true(GameClock.paused)
				assert_false(_main.world.player.movement_enabled)
				if kind=="empty":
					assert_true(book.list.empty.visible)
				elif kind=="tutorial":
					assert_eq(book.detail.objectives.get_child_count(),_main.quest_panel.STEP_KEYS.size())
					assert_eq(book.detail.rewards.note.text,tr("BOOK_NO_REWARD"))
				else:
					var quest: QuestData = DataRegistry.get_all_quests()[0] as QuestData
					assert_eq(book.detail.rewards.coins.text,tr("UI_WALLET_COINS") % quest.reward_coins)
					assert_true(book.detail.portrait.visible)
					assert_eq(book.detail.portrait.avatar.outfit,_main.npc_system.actors[quest.giver_id].avatar.outfit)
				await _capture("%s_%s_%d" % [locale,kind,dimensions.x])

func test_native_list_and_detail_wheel_scroll_use_only_isolated_display_overflow() -> void:
	await _fixture("long")
	var book: LifeQuestBook = _main.npc_system.journal.book
	var social: Dictionary = _main.npc_system.state.serialize()
	var bag: Dictionary = _main.inventory.serialize()
	await _wheel(book.detail.scroll)
	assert_gt(book.detail.scroll.scroll_vertical,0,"Long task text scrolls with fixed action buttons")
	_main.npc_system.journal.book_controller.select("onboarding")
	await _settle()
	assert_eq(book.detail.scroll.scroll_vertical,0,"Selecting a different task starts its detail at the top")
	var snapshot: Dictionary = QuestBookSnapshot.capture(_main)
	var repeated: Array[Dictionary] = []
	for index: int in range(12):
		var row: Dictionary = snapshot.entries[index%snapshot.entries.size()].duplicate(true)
		row.key = String(row.key)+":display_%d" % index
		repeated.append(row)
	snapshot.entries = repeated
	QuestBookPresenter.render(book,snapshot,&"all","",_main)
	await _settle()
	await _wheel(book.list)
	assert_gt(book.list.scroll_vertical,0,"Repeated real display snapshots stress list overflow, no domain quests added")
	assert_eq(_main.npc_system.state.serialize(),social)
	assert_eq(_main.inventory.serialize(),bag)
	assert_eq(QuestBookSnapshot.capture(_main).entries.size(),DataRegistry.get_all_quests().size()+1)

func test_zero_reward_and_translation_keys_never_invent_a_payout() -> void:
	await _fixture("new")
	var book: LifeQuestBook = _main.npc_system.journal.book
	var snapshot: Dictionary = QuestBookSnapshot.capture(_main)
	var row: Dictionary = snapshot.entries[1].duplicate(true)
	row.coins = 0
	row.reward_item = &""
	row.reward_quantity = 0
	book.detail.display(row,_main)
	assert_false(book.detail.rewards.coins.visible)
	assert_false(book.detail.rewards.item.visible)
	assert_eq(book.detail.rewards.note.text,tr("BOOK_NO_REWARD"))
	var paths: Array[String] = ["res://localization/strings_vi.csv","res://localization/strings_en.csv"]
	var keys: PackedStringArray = ["BOOK_TUTORIAL","BOOK_TUTORIAL_DESC","BOOK_ALL","BOOK_ACTIVE","BOOK_COMPLETED","BOOK_DAILY","BOOK_STATUS_NEW","BOOK_STATUS_ACTIVE","BOOK_STATUS_COMPLETED","BOOK_COUNT","BOOK_EMPTY","BOOK_IN_BAG","BOOK_ITEM_PROGRESS","BOOK_ITEM_REWARD","BOOK_REWARD_TERMS","BOOK_NO_REWARD","BOOK_SELECT","BOOK_OBJECTIVES","BOOK_REWARDS","BOOK_PIN","BOOK_MAP","BOOK_UNKNOWN_GIVER","BOOK_GIVER","BOOK_VISIT","BOOK_KEYS"]
	assert_true(DataValidator.validate_translation_keys(paths,keys).is_empty())

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func _wheel(control: Control) -> void:
	var point: Vector2 = control.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	_viewport.push_input(motion,true)
	for index: int in range(10):
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_WHEEL_DOWN
		event.position = point
		event.global_position = point
		event.pressed = true
		_viewport.push_input(event,true)
		await get_tree().process_frame

func _capture(id: String) -> void:
	if DisplayServer.get_name()!="headless":
		await RenderingServer.frame_post_draw
		assert_eq(_viewport.get_texture().get_image().save_png("user://iso11_%s.png" % id),OK)
