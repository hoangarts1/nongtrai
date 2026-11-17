extends GutTest

var _wallet: WalletState
var _inventory: MachineInventory
var _service: MachineShopService

func before_each() -> void:
	_wallet = WalletState.new(2000)
	_inventory = MachineInventory.new()
	_service = MachineShopService.new()
	_service.configure(load("res://data/machine_shop.tres") as MachineShopData, _inventory, _wallet)

func test_purchase_charges_wallet_and_adds_one_machine() -> void:
	var result: Dictionary = _service.purchase(&"stove", 1)
	assert_true(result["ok"])
	assert_eq(_wallet.get_coins(), 1750)
	assert_eq(_inventory.get_quantity(&"stove"), 1)

func test_insufficient_coins_does_not_add_machine() -> void:
	_wallet = WalletState.new(100)
	_service.configure(load("res://data/machine_shop.tres") as MachineShopData, _inventory, _wallet)
	var result: Dictionary = _service.purchase(&"stove", 1)
	assert_false(result["ok"])
	assert_eq(result["reason"], &"insufficient_coins")
	assert_eq(_wallet.get_coins(), 100)
	assert_eq(_inventory.get_quantity(&"stove"), 0)

func test_house_level_lock_does_not_charge() -> void:
	var result: Dictionary = _service.purchase(&"roaster", 2)
	assert_false(result["ok"])
	assert_eq(result["reason"], &"house_level_locked")
	assert_eq(_wallet.get_coins(), 2000)

func test_multiple_purchases_accumulate_without_capacity_limit() -> void:
	assert_true(_service.purchase(&"mill", 1)["ok"])
	assert_true(_service.purchase(&"mill", 1)["ok"])
	assert_eq(_inventory.get_quantity(&"mill"), 2)
	assert_eq(_wallet.get_coins(), 1300)

func test_machine_inventory_save_round_trip() -> void:
	_inventory.add_machine(&"stove", 2)
	_inventory.add_machine(&"roaster", 1)
	var restored: MachineInventory = MachineInventory.new()
	restored.deserialize(_inventory.serialize())
	assert_eq(restored.get_quantity(&"stove"), 2)
	assert_eq(restored.get_quantity(&"roaster"), 1)

func test_save_service_preserves_machine_inventory_for_old_payload_shape() -> void:
	SaveService.delete_save(0)
	_inventory.add_machine(&"stove", 2)
	var saved: bool = SaveService.save_game({
		"wallet": _wallet.serialize(),
		"machine_inventory": _inventory.serialize()
	}, 0)
	assert_true(saved)
	var loaded: Dictionary = SaveService.load_game(0)
	assert_eq(loaded["machine_inventory"]["machines"][0]["machine_id"], "stove")
	assert_eq(loaded["machine_inventory"]["machines"][0]["quantity"], 2)
	SaveService.delete_save(0)

func test_unknown_or_unsold_machine_is_rejected() -> void:
	var result: Dictionary = _service.purchase(&"unknown_machine", 3)
	assert_false(result["ok"])
	assert_eq(result["reason"], &"machine_not_sold")
	assert_eq(_wallet.get_coins(), 2000)

func test_native_collect_feedback_capacity_locales_and_bag_without_extra_day() -> void:
	var clock: Dictionary = GameClock.serialize()
	var paused: bool = GameClock.paused
	var locale_before: String = TranslationServer.get_locale()
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(1152,648)
	# Native layout/input run normally; draw the world only for requested captures.
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	viewport.add_child(main)
	main.call("_start_new_game","Mai","Vườn Máy")
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	GameClock.paused = true
	var panel: MachineShopPanel = main.machine_shop_panel as MachineShopPanel
	var bag: InventoryState = main.inventory
	bag.clear()
	bag.capacity = 1
	var cell: Vector2i = Vector2i(2,3)
	main.machine_inventory.add_machine(&"stove")
	assert_true(main.machine_build.place(&"stove",cell,0).ok)
	var wallet: Dictionary = main.wallet.serialize()
	var day: int = GameClock.day_index
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for size: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]:
			viewport.size = size
			bag.clear()
			assert_eq(bag.add_item(&"carrot",2),2)
			assert_true(main.machine_operations.start(cell,&"stove_carrot_meal",1).ok)
			main.machine_operations.advance_day()
			assert_eq(bag.add_item(&"turnip",1),1)
			panel.open_machine(cell)
			await _settle_ui()
			assert_false(main.world.player.movement_enabled)
			assert_true(_collect_button(panel).disabled)
			assert_eq(_collect_button(panel).tooltip_text,tr("UI_MACHINE_COLLECT_FULL"))
			var before: Dictionary = main.machine_operations.serialize()
			panel.call("_collect",cell)
			await _settle_ui()
			assert_eq((panel.get("_status") as Label).text,tr("UI_MACHINE_COLLECT_FULL"))
			assert_eq(main.machine_operations.serialize(),before)
			assert_eq(bag.get_quantity(&"temp_carrot_meal"),0)
			await _capture(viewport,panel,"%s_%d_full" % [locale,size.x])
			assert_true(bag.remove_item(&"turnip",1))
			await _settle_ui()
			assert_false(_collect_button(panel).disabled)
			assert_eq((panel.get("_status") as Label).text,"")
			_collect_button(panel).grab_focus()
			await _capture(viewport,panel,"%s_%d_ready" % [locale,size.x])
			await _click_collect(viewport,_collect_button(panel))
			assert_eq(bag.get_quantity(&"temp_carrot_meal"),1)
			assert_eq(main.machine_operations.get_state(cell).output_quantity,0)
			assert_true(_collect_button(panel).disabled)
			assert_eq((panel.get("_status") as Label).text,tr("UI_MACHINE_COLLECT_SUCCESS") % [1,tr("ITEM_TEMP_CARROT_MEAL")])
			assert_eq(viewport.gui_get_focus_owner(),panel.get("_close_button"))
			assert_eq(panel.get("_machine_cell"),cell)
			assert_true(panel.get("_machine_mode"))
			await _capture(viewport,panel,"%s_%d_collected" % [locale,size.x])
			panel.call("_collect",cell)
			await _settle_ui()
			assert_eq(bag.get_quantity(&"temp_carrot_meal"),1)
			assert_eq((panel.get("_status") as Label).text,tr("UI_MACHINE_COLLECT_NO_OUTPUT"))
			panel.close()
			await _settle_ui()
			assert_true(main.world.player.movement_enabled)
	main.inventory_panel.toggle_inventory()
	await _settle_ui()
	assert_eq(main.inventory_panel.screen.detail.name_label.text,tr("ITEM_TEMP_CARROT_MEAL"))
	await _capture(viewport,main.inventory_panel,"en_bag")
	assert_eq(main.wallet.serialize(),wallet)
	assert_eq(GameClock.day_index,day,"Collection and view refresh never simulate another day")
	viewport.free()
	TranslationServer.set_locale(locale_before)
	GameClock.deserialize(clock)
	GameClock.paused = paused

func _collect_button(panel: MachineShopPanel) -> Button:
	for node: Node in panel.find_children("*","Button",true,false):
		if String(node.get_meta(&"machine_action","")).begins_with("collect:"):
			return node as Button
	return null

func _settle_ui() -> void:
	for index: int in range(2):
		await get_tree().process_frame

func _click_collect(viewport: SubViewport, button: Button) -> void:
	var point: Vector2 = button.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	viewport.push_input(motion,true)
	for pressed: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = point
		event.global_position = point
		event.pressed = pressed
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle_ui()

func _capture(viewport: SubViewport, panel: Control, suffix: String) -> void:
	var bounds: Rect2 = Rect2(Vector2.ZERO,Vector2(viewport.size)).grow(1.0)
	assert_true(bounds.encloses(panel.get_global_rect()),"Machine/bag panel stays in viewport: "+suffix)
	if panel is MachineShopPanel and (panel as MachineShopPanel)._machine_mode:
		var details: LifeMachineDetails = (panel as MachineShopPanel).screen.details
		if details.output.visible:
			assert_true(details.get_global_rect().encloses(details.output.get_global_rect()),"Actual buffered output stays above the fold: "+suffix)
	for node: Node in panel.find_children("*","Control",true,false):
		var control: Control = node as Control
		if control.is_visible_in_tree() and (control is Button or control is Label):
			assert_true(bounds.encloses(control.get_global_rect()),"Caption/action stays visible: "+suffix)
	if DisplayServer.get_name()!="headless":
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		assert_eq(viewport.get_texture().get_image().save_png("user://phase65b_%s.png" % suffix),OK)
