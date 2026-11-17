extends GutTest

class RejectingFarm extends FarmGridState:
	func water_cell(_cell: Vector2i) -> bool:
		return false

var main: Node
var viewport: SubViewport
var clock: Dictionary
var paused: bool
var accumulator: float

func before_each() -> void:
	clock = GameClock.serialize()
	paused = GameClock.paused
	accumulator = float(GameClock.get("_real_seconds_accumulator"))
	GameClock.deserialize({"day_index":0,"minute":720,"season":"spring","year":1})
	GameClock.paused = true
	viewport = SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.world_2d = World2D.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)
	main = preload("res://scenes/main/main.tscn").instantiate()
	viewport.add_child(main)
	main.set("_game_started",true)
	main.start_menu.hide()
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	main.world.player.move_to_cell(Vector2i(2,2))
	await _settle()

func after_each() -> void:
	viewport.free()
	GameClock.deserialize(clock)
	GameClock.set("_real_seconds_accumulator",accumulator)
	GameClock.paused = paused

func test_native_mouse_drag_space_and_inspector_share_one_charge_owner() -> void:
	for cell: Vector2i in [Vector2i(2,2),Vector2i(3,2),Vector2i(3,3),Vector2i(2,3),Vector2i(2,4)]:
		_plant(cell)
	await _click(main.hotbar_panel.toolbar.buttons[2].get_global_rect().get_center())
	assert_eq(main.tool_controller.get_selected_tool(),&"water")
	await _click(main.world.grid.cell_to_screen(Vector2i(2,2)))
	assert_eq(main.watering_can.get_charges(),19)
	await _click(main.world.grid.cell_to_screen(Vector2i(2,2)))
	assert_eq(main.watering_can.get_charges(),19,"Already watered never consumes twice")
	await _drag([Vector2i(3,2),Vector2i(3,3),Vector2i(3,2),Vector2i(3,3)])
	assert_eq(main.watering_can.get_charges(),17)
	_motion(main.world.grid.cell_to_screen(Vector2i(2,3)))
	await _settle()
	_action(&"use_tool",true)
	_action(&"use_tool",false)
	await _settle()
	assert_eq(main.watering_can.get_charges(),16)
	await _click(main.hotbar_panel.toolbar.buttons[0].get_global_rect().get_center())
	main.crop_inspector.show_cell(Vector2i(2,4))
	await _settle()
	await _click(main.crop_inspector.action_button.get_global_rect().get_center())
	assert_eq(main.watering_can.get_charges(),15,"Native Inspector button uses the same can")
	for cell: Vector2i in [Vector2i(2,2),Vector2i(3,2),Vector2i(3,3),Vector2i(2,3),Vector2i(2,4)]:
		assert_true(bool(main.farm_state.get_plot(cell).watered))
	assert_eq(main.hotbar_panel.toolbar.water_meter.amount.text,tr("WATER_CAN_COUNT") % [15,20])

func test_twentieth_water_succeeds_and_next_crop_waits_for_refill_without_free_failures() -> void:
	for index: int in range(21):
		@warning_ignore("integer_division")
		var cell: Vector2i = Vector2i(index%6,index/6)
		_plant(cell)
		main.world.player.move_to_cell(cell)
		var result: Dictionary = main.watering_runtime.water(cell)
		assert_eq(bool(result.ok),index<20)
		assert_eq(main.watering_can.get_charges(),maxi(0,19-index))
		assert_eq(bool(main.farm_state.get_plot(cell).watered),index<20)
	var before: Dictionary = main.farm_state.serialize()
	assert_false(main.watering_runtime.water(Vector2i(2,3)).ok)
	assert_eq(main.farm_state.serialize(),before)
	main.world.player.move_to_cell(Vector2i(7,9))
	main.tool_controller.select_tool(&"watering_can")
	assert_true(main.watering_runtime.refill().ok)
	assert_eq(main.watering_can.get_charges(),20)
	main.world.player.move_to_cell(Vector2i(2,3))
	assert_true(main.watering_runtime.water(Vector2i(2,3)).ok)
	assert_eq(main.watering_can.get_charges(),19)

func test_wrong_reach_locked_and_rejected_crops_do_not_change_water_or_farm() -> void:
	_plant(Vector2i(5,5))
	var before: Dictionary = main.farm_state.serialize()
	assert_false(main.watering_runtime.water(Vector2i(5,5)).ok)
	assert_false(main.watering_runtime.water(Vector2i(1,1)).ok,"Empty soil")
	main.world.player.move_to_cell(Vector2i(5,5))
	main.pause_menu.open()
	assert_false(main.watering_runtime.water(Vector2i(5,5)).ok)
	main.pause_menu.close()
	assert_eq(main.watering_can.get_charges(),20)
	assert_eq(main.farm_state.serialize(),before)
	var damaged: Dictionary = before.duplicate(true)
	damaged.plots[0]["withered"] = true
	main.farm_state.deserialize(damaged)
	before = main.farm_state.serialize()
	assert_true(main.watering_runtime.water(Vector2i(5,5)).ok,"Keep actual domain wither recovery")
	assert_false(bool(main.farm_state.get_plot(Vector2i(5,5)).withered))
	assert_eq(main.watering_can.get_charges(),19)
	var rejected: RejectingFarm = RejectingFarm.new()
	rejected.deserialize(damaged)
	var command: WateringService = main.watering_runtime.get("_water") as WateringService
	command.configure(preload("res://data/watering_can_config.tres"),main.watering_can,rejected)
	before = main.farm_state.serialize()
	assert_false(main.watering_runtime.water(Vector2i(5,5)).ok)
	assert_eq(main.watering_can.get_charges(),19,"Rejected farm water refunds its own reservation")
	assert_eq(main.farm_state.serialize(),before)

func test_farm_callback_cannot_save_load_reset_title_or_reenter_pending_water() -> void:
	_plant(Vector2i(2,2))
	var results: Array[bool] = []
	var callback: Callable = func(_cell: Vector2i) -> void:
		results.append(bool(main.call("_save_game_to_slot",95)))
		results.append(bool(main.call("_load_game_from_slot",95)))
		results.append(bool(main.call("_return_to_start_menu")))
		results.append(bool(main.watering_runtime.water(Vector2i(2,2)).ok))
		results.append(bool(main.watering_runtime.refill().ok))
		main.call("_start_new_game","blocked","blocked")
		main.call("_load_payload",{"meta":{"save_version":10},"watering_can":{"capacity":20,"charges":20}})
	main.farm_state.plot_changed.connect(callback)
	assert_true(main.watering_runtime.water(Vector2i(2,2)).ok)
	main.farm_state.plot_changed.disconnect(callback)
	assert_eq(results,[false,false,false,false,false])
	assert_eq(main.profile,{})
	assert_false(main.start_menu.visible)
	assert_false(main.watering_runtime.busy)
	assert_eq(main.watering_can.get_charges(),19)
	assert_true(bool(main.farm_state.get_plot(Vector2i(2,2)).watered))
	assert_true(bool(main.get("_save_dirty")))

func _plant(cell: Vector2i) -> void:
	assert_true(main.farm_state.till_cell(cell))
	assert_true(main.farm_state.plant_crop(cell,&"turnip"))

func _action(action: StringName, pressed: bool) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = action
	event.pressed = pressed
	viewport.push_input(event,true)

func _motion(point: Vector2, mask: int = 0) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = point
	event.button_mask = mask
	viewport.push_input(event,true)

func _button(point: Vector2, pressed: bool) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	event.pressed = pressed
	viewport.push_input(event,true)

func _click(point: Vector2) -> void:
	_motion(point)
	_button(point,true)
	await get_tree().process_frame
	_button(point,false)
	await _settle()

func _drag(cells: Array[Vector2i]) -> void:
	_button(main.world.grid.cell_to_screen(cells[0]),true)
	await get_tree().process_frame
	for cell: Vector2i in cells:
		_motion(main.world.grid.cell_to_screen(cell),MOUSE_BUTTON_MASK_LEFT)
		await get_tree().process_frame
	_button(main.world.grid.cell_to_screen(cells.back()),false)
	await _settle()

func _settle() -> void:
	for frame: int in range(90):
		await get_tree().process_frame
		if not main.ui_coordinator._layout_queued and not main.inventory_panel.controller._queued:
			return
	assert_true(false,"Watering layout failed to settle")
