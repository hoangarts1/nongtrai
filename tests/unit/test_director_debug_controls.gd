extends GutTest

const FIXTURE: Script = preload("res://tests/helpers/director_fixture.gd")
var f: RefCounted
var main: Node
var flow: LifeDirectorDebugFlow

func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
	main = f.main
	flow = main.director_debug_flow
	await f.settle(self)

func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_native_shop_entry_toggle_focus_escape_and_registered_action() -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEY_M
	event.physical_keycode = KEY_M
	event.ctrl_pressed = true
	event.pressed = true
	f.viewport.push_input(event, true)
	await f.settle(self)
	assert_true(main.machine_shop_panel.visible)
	var entry: Button = main.machine_shop_panel.screen.header.director_button
	assert_true(entry.visible and not entry.disabled)
	await f.mouse(self, entry.get_global_rect().get_center())
	assert_true(flow.panel.visible)
	assert_false(main.machine_shop_panel.visible)
	assert_true(GameClock.paused)
	assert_false(main.world.player.movement_enabled)
	assert_eq(f.viewport.gui_get_focus_owner(), flow.panel.close_button)
	await f.mouse(self, flow.panel.enabled_button.get_global_rect().get_center())
	assert_true(main.director_state.is_enabled())
	await f.key(self, KEY_TAB)
	assert_true(flow.panel.visible)
	assert_false(main.inventory_panel.visible)
	await f.key(self, KEY_ESCAPE)
	assert_false(flow.panel.visible)
	var found: bool = false
	for action: Dictionary in main.debug_menu._actions:
		if action.key == &"DIR_DEBUG_ENTRY":
			found = true
			action.callback.call()
	assert_true(found)
	assert_true(flow.panel.visible)

func test_force_is_queued_rechecked_and_reentry_or_disabled_rejected() -> void:
	await f.prepare_bloom(self)
	var ecology: Dictionary = main.ecology_state.serialize()
	ecology.metrics.tree_cover = 0.0
	main.ecology_state.deserialize(ecology)
	assert_true(flow.open())
	assert_true(flow.model.ready)
	var before: Dictionary = f.owners()
	assert_true(flow.queue_force(&"gentle_dust"))
	assert_eq(main.director_state.serialize().forced, "gentle_dust")
	assert_eq(main.director_state.serialize().pending, before.director.pending)
	assert_eq(main.watering_runtime.get_charge_cost(), 1)
	assert_true(flow.queue_force(&""))
	assert_eq(main.director_state.serialize().forced, "")
	var nested: Array[bool] = []
	var callback: Callable = func(_day: int) -> void: nested.append(flow.set_enabled(true))
	main.director_state.director_changed.connect(callback)
	assert_true(flow.set_enabled(false))
	main.director_state.director_changed.disconnect(callback)
	assert_eq(nested, [false])
	assert_false(flow.queue_force(&"gentle_dust"))
	assert_eq(main.director_state.serialize().history, before.director.history)
	assert_true(flow.panel.rows[0].force_button.disabled)

func test_effective_release_gate_title_load_new_and_modal_lifecycle() -> void:
	main.director_runtime.debug_preview_allowed = false
	assert_false(flow.open())
	assert_false(main.director_runtime.set_enabled(true))
	main.director_runtime.debug_preview_allowed = true
	assert_true(flow.open())
	assert_true(flow.set_enabled(true))
	assert_true(main._save_game_to_slot(98))
	var payload: Dictionary = SaveService.load_game(98)
	assert_true(main._load_payload(payload))
	assert_false(flow.panel.visible)
	assert_true(flow.open())
	main.inventory_panel.toggle_inventory()
	assert_false(flow.panel.visible)
	assert_true(main.inventory_panel.visible)
	assert_true(flow.open())
	main._start_new_game("Mai", "Garden")
	main.tutorial_panel.close_help()
	assert_false(flow.panel.visible)
	assert_false(main.director_state.is_enabled())
	assert_true(main._return_to_start_menu())
	assert_false(flow.open())
	assert_false(main.director_state.is_enabled())
