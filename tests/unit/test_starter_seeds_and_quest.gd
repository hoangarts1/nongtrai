extends GutTest

func test_all_seasons_have_valid_plantable_starter_seed() -> void:
	for season_id: StringName in [&"spring", &"summer", &"autumn", &"winter"]:
		var seed_id: StringName = DataRegistry.get_starter_seed_for_season(season_id)
		assert_ne(seed_id, &"", "Starter seed for season %s should not be empty" % season_id)
		var crop_data: Resource = DataRegistry.get_crop_for_seed(seed_id)
		assert_not_null(crop_data, "Starter seed %s should have valid crop" % seed_id)
		var seasons: PackedStringArray = crop_data.get("seasons")
		assert_true(
			seasons.is_empty() or seasons.has(String(season_id)),
			"Starter seed %s crop %s must be plantable in season %s" % [seed_id, crop_data.get("crop_id"), season_id]
		)

func test_new_game_starter_seed_plants_successfully_and_completes_quest() -> void:
	var starting_season: StringName = GameClock.season
	var starter_seed: StringName = DataRegistry.get_starter_seed_for_season(starting_season)
	assert_ne(starter_seed, &"")
	
	var inventory: InventoryState = InventoryState.new()
	var farm_state: FarmGridState = FarmGridState.new()
	var quest_state: TutorialQuestState = TutorialQuestState.new()
	
	# Grant starter seeds
	var added: int = inventory.add_item(starter_seed, 10)
	assert_eq(added, 10)
	assert_true(inventory.has_item(starter_seed, 1))
	
	# Till cell
	var target_cell: Vector2i = Vector2i(1, 1)
	assert_true(farm_state.till_cell(target_cell), "Should till empty cell")
	assert_true(quest_state.is_step_completed(0), "Till quest should complete")
	
	# Plant starter seed
	var crop_data: Resource = DataRegistry.get_crop_for_seed(starter_seed)
	assert_not_null(crop_data)
	var crop_id: StringName = crop_data.get("crop_id")
	
	assert_false(quest_state.is_step_completed(1), "Plant quest should not be completed yet")
	var plant_ok: bool = farm_state.plant_crop(target_cell, crop_id)
	assert_true(plant_ok, "Planting starter seed in starting season must succeed")
	
	# Consume item as ToolActionController does
	inventory.remove_item(starter_seed, 1)
	assert_eq(inventory.get_quantity(starter_seed), 9)
	
	# Quest check
	assert_true(quest_state.is_step_completed(1), "Plant quest (Gieo hat) must complete without softlock")
	
	var plot: Dictionary = farm_state.get_plot(target_cell)
	assert_eq(plot.get("crop_id"), crop_id)
