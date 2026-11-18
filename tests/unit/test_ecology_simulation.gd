extends GutTest

const SIM: Script = preload("res://tools/sim_ecology.gd")

func test_thousand_days_actual_farm_seasons_care_and_expansion_match_individual_steps() -> void:
	var clock: Dictionary = GameClock.serialize()
	var paused: bool = GameClock.paused
	var result: Dictionary = SIM.run_scenario(1000, 17)
	assert_true(result.ok, str(result.get("reason", "")))
	if not result.ok:
		return
	assert_eq(result.stats.compared_days, 1000)
	assert_eq(result.stats.duplicate_rejections, 1000)
	assert_eq(result.snapshot, result.reference)
	assert_eq(int(result.snapshot.day_index), 1000)
	assert_true(result.stats.expanded)
	assert_gt(int(result.stats.harvests), 0)
	assert_gt(int(result.stats.withered_observations), 0)
	assert_gte(int(result.stats.mature_tree_peak), 8)
	assert_gte(int(result.stats.species_peak), 8)
	assert_gt(int(result.stats.upward), 0)
	assert_gt(int(result.stats.downward), 0)
	assert_gt(int(result.stats.roundtrips), 0)
	assert_false(result.water_available)
	assert_false(result.snapshot.triggered.has("clear_water"))
	assert_eq(GameClock.serialize(), clock)
	assert_eq(GameClock.paused, paused)
	for row: Dictionary in result.crossings:
		assert_true(row.id in ["birds", "butterflies"])
		assert_true(row.active is bool)
		assert_true(int(row.day) > 0 and int(row.day) <= 1000)

func test_chunk_boundaries_and_repeated_seedless_runs_have_identical_results() -> void:
	var first: Dictionary = SIM.run_scenario(90, 1)
	var grouped: Dictionary = SIM.run_scenario(90, 23)
	assert_true(first.ok)
	assert_true(grouped.ok)
	first.erase("chunk_size")
	grouped.erase("chunk_size")
	assert_eq(first, grouped)

func test_invalid_verification_arguments_do_not_change_clock_or_pause() -> void:
	var before: Dictionary = GameClock.serialize()
	var paused: bool = GameClock.paused
	assert_false(SIM.run_scenario(0, 1).ok)
	assert_false(SIM.run_scenario(1, 0).ok)
	assert_eq(GameClock.serialize(), before)
	assert_eq(GameClock.paused, paused)
