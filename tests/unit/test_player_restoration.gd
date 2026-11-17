extends GutTest

var _main: Node
var _viewport: SubViewport
var _clock: Dictionary
var _paused: bool

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	SaveService.delete_save(0)
	SaveService.delete_save(1)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152,648)
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_main.call("_start_new_game","Mai","Vườn Máy")
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	GameClock.paused = true

func after_each() -> void:
	Input.action_release("move_right")
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	SaveService.delete_save(0)
	SaveService.delete_save(1)

func test_player_motion_appearance_character_tab_and_modal_gate_are_restored() -> void:
	assert_true(_main.world.player is CharacterBody2D)
	assert_eq(_main.world.camera,_main.world.player.camera)
	assert_eq(String(_main.profile.player_name),"Mai")
	assert_not_null(_main.presentation.get_player_avatar())
	_main.world.player.move_to_cell(Vector2i(3,3))
	var before: Vector2 = _main.world.player.global_position
	Input.action_press("move_right")
	for index: int in range(4):
		await get_tree().physics_frame
	Input.action_release("move_right")
	assert_gt(_main.world.player.global_position.x,before.x)
	_main.character_flow.open()
	await _settle()
	assert_true(_main.character_flow.panel.visible)
	assert_false(_main.world.player.movement_enabled)
	before = _main.world.player.global_position
	Input.action_press("move_right")
	for index: int in range(3):
		await get_tree().physics_frame
	Input.action_release("move_right")
	assert_eq(_main.world.player.global_position,before)
	_main.character_flow.close()
	await _settle()
	assert_true(_main.world.player.movement_enabled)
	if DisplayServer.get_name()!="headless":
		await RenderingServer.frame_post_draw
		assert_eq(_viewport.get_texture().get_image().save_png("user://restored_player.png"),OK)

func test_player_save_cell_coexists_with_machine_purchase_placement_and_processing() -> void:
	var machine: MachineData = DataRegistry.get_machine(&"stove")
	assert_not_null(machine)
	_main.wallet.add_coins(machine.purchase_price,&"test_restoration")
	var shop: MachineShopService = _main.machine_shop_panel.get("_shop") as MachineShopService
	assert_true(shop.purchase(machine.machine_id,machine.unlock_house_level).ok)
	var cell: Vector2i = Vector2i(2,3)
	assert_true(_main.machine_build.place(machine.machine_id,cell,0).ok)
	_main.inventory.add_item(&"carrot",2)
	assert_true(_main.machine_operations.start(cell,&"stove_carrot_meal",1).ok)
	_main.world.player.move_to_cell(Vector2i(4,3))
	assert_true(_main.call("_save_game_to_slot",1))
	var payload: Dictionary = SaveService.load_game(1)
	assert_false(payload.player.is_empty())
	assert_false(payload.machine_placements.is_empty())
	assert_false(payload.machine_operations.is_empty())
	_main.world.player.move_to_cell(Vector2i.ZERO)
	_main.machine_placements.deserialize({})
	_main.machine_operations.deserialize({})
	_main.call("_load_payload",payload)
	assert_eq(_main.world.player.get_cell(),Vector2i(4,3))
	assert_eq(_main.machine_placements.get_placement(cell).machine_id,machine.machine_id)
	assert_not_null(_main.machine_operations.get_state(cell))
	_main.machine_operations.advance_day()
	var output: Dictionary = _main.machine_operations.take_output(cell)
	assert_eq(output.get("item_id"),&"temp_carrot_meal")
	assert_not_null(DataRegistry.get_tool(&"shovel"))
	var perennial_found: bool = false
	for resource: Resource in DataRegistry.get_all_crops():
		if (resource as CropData).perennial:
			perennial_found = true
	assert_true(perennial_found,"New perennial crop data survives Player restoration")

func test_machine_shop_shortcut_and_overlay_keep_player_locked() -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEY_M
	event.physical_keycode = KEY_M
	event.pressed = true
	_viewport.push_input(event,true)
	await _settle()
	assert_false(_main.machine_shop_panel.visible,"Plain M does not open the machine shop")
	event.ctrl_pressed = true
	_viewport.push_input(event,true)
	await _settle()
	assert_true(_main.machine_shop_panel.visible)
	assert_eq(_main.ui_coordinator.get_active_panel(),_main.machine_shop_panel)
	assert_false(_main.world.player.movement_enabled)
	_main.machine_shop_panel.close()
	await _settle()
	assert_true(_main.world.player.movement_enabled)

func test_new_machine_marker_and_seed_shop_remain_reachable_with_player() -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	_main.world.player.move_to_cell(_main.world.machine_shop_marker.get_meta("cell"))
	_main.world.call("_unhandled_input",event)
	await _settle()
	assert_true(_main.machine_shop_panel.visible,"Machine marker wins when it is closer")
	assert_false(_main.seed_shop_panel.visible)
	_main.machine_shop_panel.close()
	await _settle()
	_main.world.player.move_to_cell(_main.world.seed_shop_marker.get_meta("cell"))
	_main.world.call("_unhandled_input",event)
	await _settle()
	assert_true(_main.seed_shop_panel.visible,"Original seed shop still opens at its own marker")
	assert_false(_main.machine_shop_panel.visible)

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
