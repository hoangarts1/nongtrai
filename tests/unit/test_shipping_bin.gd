extends GutTest

func test_shipping_bin_prompt_and_reach() -> void:
	var world_scene: PackedScene = preload("res://scenes/world/gray_box_world.tscn")
	var world: GrayBoxWorld = world_scene.instantiate()
	add_child_autofree(world)
	await get_tree().process_frame
	
	var marker: Marker2D = world.get_node("WorldCanvas/ShippingBinMarker")
	assert_not_null(marker, "ShippingBinMarker should exist in GrayBoxWorld")
	
	# Place player near shipping bin
	world.player.global_position = marker.global_position + Vector2(4, 0)
	world._update_interaction_prompt()
	assert_true(world.interaction_prompt.visible)
	assert_string_contains(world.interaction_prompt.get_node("Message").text, tr("UI_PROMPT_SELL"))
	
	# Place player far from shipping bin and house
	world.player.move_to_cell(Vector2i(-9, -9))
	world._update_interaction_prompt()
	assert_false(world.interaction_prompt.visible)

func test_shipping_bin_panel_selling_flow() -> void:
	var inventory: InventoryState = InventoryState.new()
	var wallet: WalletState = WalletState.new(50)
	var player: Player = Player.new()
	add_child_autofree(player)
	
	inventory.add_item(&"turnip", 5)
	assert_eq(inventory.get_quantity(&"turnip"), 5)
	
	var panel: ShippingBinPanel = ShippingBinPanel.new()
	add_child_autofree(panel)
	panel.configure(inventory, wallet, player)
	
	watch_signals(panel)
	panel.open()
	assert_true(panel.is_open())
	assert_false(player.movement_enabled, "Player movement should be locked when panel is open")
	
	# Test selling 3 turnips at 25 coins each = 75 coins
	panel._select_item(&"turnip")
	panel._change_quantity(2) # 1 + 2 = 3
	assert_eq(panel._selected_quantity, 3)
	
	panel._confirm_sale()
	assert_eq(inventory.get_quantity(&"turnip"), 2, "Should have 2 turnips left in inventory")
	assert_eq(wallet.get_coins(), 125, "Wallet should have 50 + 75 = 125 coins")
	assert_signal_emitted(panel, "item_sold")
	
	panel.close()
	assert_false(panel.is_open())
	assert_true(player.movement_enabled, "Player movement should be restored after closing panel")
