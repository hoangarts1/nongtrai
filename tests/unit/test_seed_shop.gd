extends GutTest

const SeedShopPanelScript = preload("res://scripts/view/seed_shop_panel.gd")

func test_seed_shop_prompt_and_reach() -> void:
	var world_scene: PackedScene = preload("res://scenes/world/gray_box_world.tscn")
	var world: GrayBoxWorld = world_scene.instantiate()
	add_child_autofree(world)
	await get_tree().process_frame
	
	var marker: Marker3D = world.get_node("SeedShopMarker")
	assert_not_null(marker, "SeedShopMarker should exist in GrayBoxWorld")
	
	# Place player near seed shop
	world.player.global_position = marker.global_position + Vector3(0.5, 0, 0)
	world._update_interaction_prompt()
	assert_true(world.interaction_prompt.visible)
	assert_string_contains(world.interaction_prompt.get_node("Message").text, tr("UI_PROMPT_SHOP"))
	
	# Place player far away
	world.player.global_position = Vector3(20, 0, 20)
	world._update_interaction_prompt()
	assert_false(world.interaction_prompt.visible)

func test_seed_shop_season_filtering_and_dimming() -> void:
	GameClock.season = &"spring"
	var panel = SeedShopPanelScript.new()
	add_child_autofree(panel)
	var inventory: InventoryState = InventoryState.new(12)
	var wallet: WalletState = WalletState.new(500)
	var player: Player = Player.new()
	add_child_autofree(player)
	panel.configure(inventory, wallet, player)
	
	panel.open()
	assert_true(panel.is_open())
	
	# Check children of list_container
	var list: VBoxContainer = panel._list_container
	assert_gt(list.get_child_count(), 0)
	
	# In spring, spring_carrot_seed should be enabled and selectable
	# winter_cabbage_seed should be disabled and dimmed
	var found_carrot: bool = false
	var found_winter_cabbage: bool = false
	for child in list.get_children():
		if child is Button:
			for sub in child.get_children():
				if sub is HBoxContainer:
					for label in sub.get_children():
						if label is Label:
							if label.text.contains(tr("ITEM_SPRING_CARROT_SEED")):
								found_carrot = true
								assert_false(child.disabled, "Spring carrot seed should be enabled in Spring")
							elif label.text.contains(tr("ITEM_WINTER_CABBAGE_SEED")):
								found_winter_cabbage = true
								assert_true(child.disabled, "Winter cabbage seed should be disabled in Spring")
								assert_true(label.text.contains(tr("SEASON_WINTER")), "Winter cabbage should show winter note")
	assert_true(found_carrot, "Should find spring carrot seed button")
	assert_true(found_winter_cabbage, "Should find winter cabbage seed button")
	panel.close()

func test_seed_shop_atomic_purchasing() -> void:
	GameClock.season = &"spring"
	var panel = SeedShopPanelScript.new()
	add_child_autofree(panel)
	var inventory: InventoryState = InventoryState.new(2)
	var wallet: WalletState = WalletState.new(100)
	var player: Player = Player.new()
	add_child_autofree(player)
	panel.configure(inventory, wallet, player)
	
	watch_signals(panel)
	
	# 1. Purchase when afford: turnip_seed buy_price is 20 coins
	var carrot_data: Resource = DataRegistry.get_item(&"spring_carrot_seed")
	var price: int = int(carrot_data.get("buy_price")) # 15 coins
	
	var success: bool = panel.try_buy_item(&"spring_carrot_seed", 2)
	assert_true(success, "Should successfully buy 2 carrot seeds")
	assert_eq(wallet.get_coins(), 100 - (price * 2), "Wallet should be deducted")
	assert_eq(inventory.get_quantity(&"spring_carrot_seed"), 2, "Inventory should receive seeds")
	assert_signal_emitted(panel, "item_purchased")
	
	# 2. Cannot afford test
	var fail_expensive: bool = panel.try_buy_item(&"spring_carrot_seed", 999)
	assert_false(fail_expensive, "Should fail when cannot afford")
	assert_eq(wallet.get_coins(), 100 - (price * 2), "Wallet coins must not change on failure")
	
	# 3. Inventory full test: fill remaining slots
	# Currently 1 slot used by carrot seeds (stack is 99, so let's add 1 other item to fill second slot)
	inventory.add_item(&"turnip_seed", 1)
	assert_eq(inventory._slots.size(), 2, "Inventory should be at max capacity (2 slots)")
	
	# Now try buying a third item type that needs a new slot (e.g. spring_pea_seed)
	var coins_before: int = wallet.get_coins()
	var fail_full: bool = panel.try_buy_item(&"spring_pea_seed", 1)
	assert_false(fail_full, "Should fail purchase when inventory cannot fit new item")
	assert_eq(wallet.get_coins(), coins_before, "Wallet must NOT be deducted when inventory is full (atomic)")
	assert_false(inventory.has_item(&"spring_pea_seed", 1), "Item should not be added when inventory is full")
