extends GutTest

var _clock: Dictionary
var _paused: bool
var _viewport: SubViewport
var _main: Node

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152, 648)
	_viewport.world_2d = World2D.new()
	_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_main.call("_start_new_game", "Mai", "Garden")
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	GameClock.paused = true

func after_each() -> void:
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	SaveService.delete_save(1)

func test_native_world_accepts_only_exact_control_m_and_preserves_all_owners() -> void:
	await _settle()
	var before: Dictionary = _owners()
	await _rejected_matrix(null)
	await _key(true)
	assert_true(_main.machine_shop_panel.visible)
	assert_eq(_main.ui_coordinator.get_active_panel(), _main.machine_shop_panel)
	assert_false(_main.world.player.movement_enabled)
	assert_true(GameClock.paused)
	assert_eq(_owners(), before)
	_main.machine_shop_panel.close()
	await _settle()
	assert_true(_main.world.player.movement_enabled)

func test_native_modal_replacement_uses_the_same_policy_for_bag_pause_character_and_npc() -> void:
	await _settle()
	var panels: Array[Control] = [_main.inventory_panel, _main.pause_menu, _main.character_flow.panel, _main.npc_system.journal, _main.npc_system.dialogue]
	for panel: Control in panels:
		if panel == _main.inventory_panel:
			_main.inventory_panel.toggle_inventory()
		elif panel == _main.pause_menu:
			_main.pause_menu.open()
		elif panel == _main.character_flow.panel:
			_main.character_flow.open()
		elif panel == _main.npc_system.journal:
			_main.npc_system.open_journal()
		else:
			_main.npc_system.dialogue.show_content(tr("NPC_MINH_NAME"), tr("UI_NPC_TALK_HINT"))
			_main.npc_system.dialogue.show()
		await _settle()
		assert_eq(_main.ui_coordinator.get_active_panel(), panel)
		var before: Dictionary = _owners()
		await _rejected_matrix(panel)
		await _key(true)
		assert_true(_main.machine_shop_panel.visible)
		assert_false(panel.visible)
		assert_eq(_main.ui_coordinator.get_active_panel(), _main.machine_shop_panel)
		assert_eq(_owners(), before)
		_main.machine_shop_panel.close()
		await _settle()

func test_title_and_day_end_review_never_open_the_machine_shortcut() -> void:
	await _settle()
	_main.start_menu.show()
	await _settle()
	await _key(true)
	assert_true(_main.start_menu.visible)
	assert_false(_main.machine_shop_panel.visible)
	_main.start_menu.hide()
	await _settle()
	GameClock.set_time(20, 0)
	assert_true(_main.day_end_flow.request())
	await _settle()
	var before: Dictionary = _owners()
	await _key(true)
	await _key(true, true)
	assert_true(_main.day_end_flow.panel.visible)
	assert_true(GameClock.is_day_end_held())
	assert_false(_main.machine_shop_panel.visible)
	assert_eq(_owners(), before)
	assert_true(_main.day_end_flow.cancel())

func test_sleep_and_transaction_busy_block_shortcut_in_world_and_modal() -> void:
	await _settle()
	_main.watering_runtime.busy = true
	var before: Dictionary = _owners()
	await _key(true)
	assert_false(_main.machine_shop_panel.visible)
	assert_eq(_owners(), before)
	_main.watering_runtime.busy = false
	_main.inventory_panel.toggle_inventory()
	await _settle()
	_main.watering_runtime.busy = true
	await _key(true)
	assert_true(_main.inventory_panel.visible)
	assert_false(_main.machine_shop_panel.visible)
	_main.watering_runtime.busy = false
	_main.ui_coordinator.close_active()
	GameClock.set_time(20, 0)
	assert_true(GameClock.try_sleep())
	GameClock.paused = true
	before = _owners()
	await _key(true)
	assert_true(GameClock.is_sleeping())
	assert_false(_main.machine_shop_panel.visible)
	assert_eq(_owners(), before)

func _rejected_matrix(active: Control) -> void:
	var before: Dictionary = _owners()
	for modifiers: Vector3i in [Vector3i.ZERO, Vector3i(1, 0, 0), Vector3i(0, 1, 0), Vector3i(0, 0, 1)]:
		await _key(modifiers != Vector3i.ZERO, modifiers.x == 1, modifiers.y == 1, modifiers.z == 1)
		assert_false(_main.machine_shop_panel.visible)
		assert_eq(_main.ui_coordinator.get_active_panel(), active)
		assert_eq(_owners(), before)

func _key(control: bool, shift: bool = false, alt: bool = false, meta: bool = false) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = KEY_M
		event.physical_keycode = KEY_M
		event.ctrl_pressed = control
		event.shift_pressed = shift
		event.alt_pressed = alt
		event.meta_pressed = meta
		event.pressed = pressed
		_viewport.push_input(event, true)
		await get_tree().process_frame
	await _settle()

func _owners() -> Dictionary:
	return {"clock": GameClock.serialize(), "farm": _main.farm_state.serialize(), "wallet": _main.wallet.serialize(), "bag": _main.inventory.serialize(), "water": _main.watering_can.serialize(), "coop": _main.chicken_coop.serialize(), "weather": _main.weather_state.serialize(), "ledger": _main.day_end_flow.ledger.serialize(), "machines": _main.machine_operations.serialize(), "stock": _main.machine_inventory.serialize(), "placements": _main.machine_placements.serialize()}

func _settle() -> void:
	for frame: int in range(4):
		await get_tree().process_frame
