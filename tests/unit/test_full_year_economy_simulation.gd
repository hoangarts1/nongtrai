extends GutTest

const SeedShopPanelScript = preload("res://scripts/view/seed_shop_panel.gd")
const ShippingBinPanelScript = preload("res://scripts/view/shipping_bin_panel.gd")

func test_one_full_year_four_seasons_farming_and_economy_simulation() -> void:
	# Reset clock to year 1, spring, day 0
	GameClock.day_index = 0
	GameClock.season = &"spring"
	GameClock.year = 1
	GameClock.minute = GameClock.MORNING_MINUTE
	
	var inventory: InventoryState = InventoryState.new(12)
	var wallet: WalletState = WalletState.new(100) # Starts with 100 coins
	var farm_state: FarmGridState = FarmGridState.new()
	var player: Player = Player.new()
	add_child_autofree(player)
	
	var shop = SeedShopPanelScript.new()
	add_child_autofree(shop)
	shop.configure(inventory, wallet, player)
	
	var bin = ShippingBinPanelScript.new()
	add_child_autofree(bin)
	bin.configure(inventory, wallet, player)
	
	var seasons_crops: Array[Dictionary] = [
		{
			"season": &"spring",
			"seed_id": &"spring_carrot_seed",
			"crop_id": &"spring_carrot",
			"product_id": &"spring_carrot",
			"growth_days": 3
		},
		{
			"season": &"summer",
			"seed_id": &"summer_tomato_seed",
			"crop_id": &"summer_tomato",
			"product_id": &"summer_tomato",
			"growth_days": 4
		},
		{
			"season": &"autumn",
			"seed_id": &"autumn_wheat_seed",
			"crop_id": &"autumn_wheat",
			"product_id": &"autumn_wheat",
			"growth_days": 3
		},
		{
			"season": &"winter",
			"seed_id": &"winter_radish_seed",
			"crop_id": &"winter_radish",
			"product_id": &"winter_radish",
			"growth_days": 3
		}
	]
	
	var simulator: DaySimulator = DaySimulator.new()
	
	for s_info: Dictionary in seasons_crops:
		var season_name: StringName = s_info["season"]
		assert_eq(GameClock.season, season_name, "Current season should be %s" % season_name)
		
		var starting_coins: int = wallet.get_coins()
		assert_gt(starting_coins, 0, "Coins must be positive before buying seeds")
		
		# 1. Buy seeds via shop
		var seed_id: StringName = s_info["seed_id"]
		var qty_to_buy: int = 4
		var buy_ok: bool = shop.try_buy_item(seed_id, qty_to_buy)
		assert_true(buy_ok, "Must successfully buy seeds in season %s" % season_name)
		assert_eq(inventory.get_quantity(seed_id), qty_to_buy)
		assert_true(wallet.get_coins() >= 0, "Wallet coins must not be negative")
		
		# 2. Plant seeds
		var planted_cells: Array[Vector2i] = [
			Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)
		]
		for cell: Vector2i in planted_cells:
			assert_true(farm_state.till_cell(cell), "Till cell %s" % cell)
			assert_true(farm_state.plant_crop(cell, s_info["crop_id"]), "Plant in %s" % cell)
			inventory.remove_item(seed_id, 1)
		assert_eq(inventory.get_quantity(seed_id), 0, "All bought seeds planted")
		
		# 3. Water and advance days until ripe
		var growth_days: int = int(s_info["growth_days"])
		for day: int in range(growth_days):
			for cell: Vector2i in planted_cells:
				farm_state.water_cell(cell)
			simulator.simulate_day(farm_state)
			GameClock.sleep_to_morning()
		
		# 4. Harvest crops
		var product_id: StringName = s_info["product_id"]
		for cell: Vector2i in planted_cells:
			assert_true(farm_state.can_harvest(cell), "Cell %s should be ready to harvest" % cell)
			var payload: Dictionary = farm_state.harvest_cell(cell)
			assert_true(payload.get("success", false), "Harvest success")
			assert_eq(payload.get("product_item"), product_id)
			inventory.add_item(payload.get("product_item"), payload.get("quantity"))
		
		assert_eq(inventory.get_quantity(product_id), qty_to_buy, "Harvested produce items into inventory")
		
		# 5. Sell produce via shipping bin
		bin.open()
		bin._select_item(product_id)
		bin._set_max_quantity()
		assert_eq(bin._selected_quantity, qty_to_buy)
		bin._confirm_sale()
		bin.close()
		
		assert_eq(inventory.get_quantity(product_id), 0, "Produce sold from inventory")
		assert_gt(wallet.get_coins(), starting_coins, "Selling crop must yield profit over starting coins in season %s" % season_name)
		assert_true(wallet.get_coins() >= 0, "Coins must never be negative")
		
		# 6. Advance remaining days of this 28-day season until next season starts
		var days_passed: int = growth_days
		var days_to_advance: int = 28 - days_passed
		for d: int in range(days_to_advance):
			simulator.simulate_day(farm_state)
			GameClock.sleep_to_morning()
	
	# After 4 seasons (112 days total):
	assert_eq(GameClock.day_index, 112, "Full year of 112 days completed")
	assert_eq(GameClock.year, 2, "Game is now in Year 2")
	assert_eq(GameClock.season, &"spring", "Cycled back to Spring")
	assert_gt(wallet.get_coins(), 100, "Player must have made a cumulative profit over the full year")
	assert_true(wallet.get_coins() >= 0, "Final balance is strictly non-negative")
