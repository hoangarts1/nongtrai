extends GutTest

func test_all_seven_tutorial_quest_steps() -> void:
	var quest_state: TutorialQuestState = TutorialQuestState.new()
	assert_false(quest_state.is_complete())
	assert_eq(quest_state._completed.size(), 7)
	
	# Step 0: Till
	Events.plot_tilled.emit(Vector2i(0, 0))
	assert_true(quest_state.is_step_completed(0))
	assert_false(quest_state.is_complete())
	
	# Step 1: Plant
	Events.crop_planted.emit(Vector2i(0, 0), &"turnip")
	assert_true(quest_state.is_step_completed(1))
	
	# Step 2: Water
	Events.plot_watered.emit(Vector2i(0, 0))
	assert_true(quest_state.is_step_completed(2))
	
	# Step 3: Sleep
	GameClock.sleep_finished.emit(1)
	assert_true(quest_state.is_step_completed(3))
	
	# Step 4: Harvest
	Events.crop_harvested.emit(Vector2i(0, 0), &"turnip", 1, 1)
	assert_true(quest_state.is_step_completed(4))
	
	# Step 5: Sell
	Events.item_sold.emit(&"turnip", 1, 25)
	assert_true(quest_state.is_step_completed(5), "Selling produce must complete step 5")
	assert_false(quest_state.is_complete())
	
	# Step 6: Buy seed
	watch_signals(quest_state)
	Events.item_purchased.emit(&"turnip_seed", 1, 20)
	assert_true(quest_state.is_step_completed(6), "Buying seeds must complete step 6")
	assert_true(quest_state.is_complete(), "All 7 steps completed must complete the quest")
	assert_signal_emitted(quest_state, "all_completed")

func test_tutorial_quest_backward_compatible_deserialization() -> void:
	var quest_state: TutorialQuestState = TutorialQuestState.new()
	# Old v1 save with only 5 completed steps
	var old_data: Dictionary = {"completed": [true, true, true, true, true]}
	quest_state.deserialize(old_data)
	assert_true(quest_state.is_step_completed(0))
	assert_true(quest_state.is_step_completed(4))
	assert_false(quest_state.is_step_completed(5))
	assert_false(quest_state.is_step_completed(6))
	assert_false(quest_state.is_complete())

func test_debug_menu_add_coins_and_add_all_seeds() -> void:
	var debug_menu: DebugMenu = DebugMenu.new()
	add_child_autofree(debug_menu)
	var wallet: WalletState = WalletState.new(100)
	var inventory: InventoryState = InventoryState.new(24)
	
	debug_menu.configure_inventory(inventory)
	debug_menu.configure_wallet(wallet)
	
	# Test adding all seeds
	debug_menu._add_all_seeds()
	var seed_items: Array[Resource] = DataRegistry.get_seed_items()
	assert_gt(seed_items.size(), 0)
	for seed: Resource in seed_items:
		assert_true(inventory.get_quantity(seed.get("item_id")) >= 5, "Should have added 5 seeds of %s" % seed.get("item_id"))
	
	# Test adding coins via registered action or direct call
	wallet.add_coins(500, &"debug_grant")
	assert_eq(wallet.get_coins(), 600)
