extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/story_fixture.gd")
var f: RefCounted

func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)

func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_seed_wallet_callback_blocks_save_reset_and_second_purchase() -> void:
	var main: Node = f.main
	var attempts: Array[bool] = []
	var observer: Callable = func(_coins: int, delta: int, _reason: StringName) -> void:
		if delta>=0: return
		attempts.append(main.call("_save_game_to_slot",98))
		attempts.append(main.call("_return_to_start_menu"))
		attempts.append(main.seed_shop_panel.try_buy_item(&"turnip_seed",1))
		attempts.append(InventoryService.clear(main.inventory,&"test_facade"))
		main.call("_start_new_game","Wrong","Wrong")
	main.wallet.coins_changed.connect(observer)
	var before: int = main.inventory.get_quantity(&"spring_carrot_seed")
	var coins: int = main.wallet.get_coins()
	var item: ItemData = DataRegistry.get_item(&"spring_carrot_seed") as ItemData
	assert_true(main.seed_shop_panel.try_buy_item(item.item_id,1))
	main.wallet.coins_changed.disconnect(observer)
	assert_eq(attempts,[false,false,false,false])
	assert_eq(main.inventory.get_quantity(item.item_id),before+1)
	assert_eq(main.wallet.get_coins(),coins-item.buy_price)
	assert_eq(main.profile.player_name,"Mai")
	assert_false(main.seed_shop_panel.is_busy())
	assert_false(main.call("_purchase_in_progress"))

func test_shipping_notice_blocks_second_sale_and_persistence_until_complete() -> void:
	var main: Node = f.main
	InventoryService.add(main.inventory,&"turnip",2,&"test_facade")
	main.shipping_bin_panel.open()
	main.shipping_bin_panel.call("_select_item",&"turnip")
	main.shipping_bin_panel.call("_set_max_quantity")
	var attempts: Array[bool] = []
	var observer: Callable = func(_id: StringName, _qty: int, _price: int) -> void:
		attempts.append(main.call("_save_game_to_slot",98))
		main.shipping_bin_panel.call("_confirm_sale")
		main.shipping_bin_panel.close()
		attempts.append(main.shipping_bin_panel.visible)
	main.shipping_bin_panel.item_sold.connect(observer)
	var coins: int = main.wallet.get_coins()
	var item: ItemData = DataRegistry.get_item(&"turnip") as ItemData
	main.shipping_bin_panel.call("_confirm_sale")
	main.shipping_bin_panel.item_sold.disconnect(observer)
	assert_eq(attempts,[false,true])
	assert_eq(main.inventory.get_quantity(&"turnip"),0)
	assert_eq(main.wallet.get_coins(),coins+2*item.sell_price)
	assert_true(main.story_state.serialize().completed_objectives.has("first_sale"))
	assert_false(main.shipping_bin_panel.is_busy())
	main.ui_coordinator.close_active()
	assert_true(main.call("_save_game_to_slot",98))
	var before: Dictionary = f.owners()
	assert_true(main.call("_load_game_from_slot",98))
	assert_eq(f.owners(),before)
	assert_eq(int(SaveService.load_game(98).meta.save_version),17)

func test_recipe_input_callback_cannot_start_a_second_free_job() -> void:
	var bag: InventoryState = InventoryState.new()
	InventoryService.add(bag,&"autumn_wheat",4,&"test_facade")
	var first: MachineState = MachineState.new()
	var second: MachineState = MachineState.new()
	var machine: MachineData = DataRegistry.get_machine(&"mill") as MachineData
	var recipe: RecipeData = DataRegistry.get_recipe(&"mill_wheat_flour") as RecipeData
	var attempts: Array[bool] = []
	var observer: Callable = func(_slots: Array[Dictionary]) -> void:
		attempts.append(second.start(machine,recipe,bag,1).ok)
	bag.inventory_changed.connect(observer)
	assert_true(first.start(machine,recipe,bag,1).ok)
	bag.inventory_changed.disconnect(observer)
	assert_eq(attempts,[false])
	assert_eq(bag.get_quantity(&"autumn_wheat"),2)
	assert_eq(second.status,MachineState.STATUS_IDLE)

func test_log_is_contextual_without_an_owner_or_sink() -> void:
	assert_eq(Log.format_message(&"warn",&"trade","rejected"),"[WARN][trade] rejected")
	assert_eq(Log.format_message(&"debug",&"Main","ready"),"[DEBUG][Main] ready")
