extends GutTest

const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")

static func golden(version: int = 13) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v%d.json" % version))

func test_all_thirteen_real_goldens_use_actual_catalog_land_ecology_and_saved_weather_without_mutation() -> void:
	var crops: Array[Resource] = DataRegistry.get_all_crops()
	for version: int in range(1, 14):
		var payload: Dictionary = golden(version)
		var before: Dictionary = payload.duplicate(true)
		var context: Dictionary = DirectorSaveContext.capture(PROFILE, payload, crops)
		assert_true(context.ok, str(version))
		assert_true(DirectorSaveContext.valid(PROFILE, context))
		assert_eq(context.day_index, int(payload.clock.day_index))
		assert_true(context.calendar_aligned)
		assert_eq(context.catalog_ids.size(), crops.size())
		assert_false(context.available.water_clarity)
		assert_eq(context.regions[0], DirectorSaveContext.LAND.initial_region)
		assert_eq(context.weather_available, version > 1)
		if version > 1:
			assert_eq(context.weather.today, payload.weather.today)
			assert_eq(context.weather.forecast, payload.weather.forecast)
			assert_eq(int(context.weather.world_seed), int(payload.weather.world_seed))
		assert_eq(payload, before)

func test_current_owned_parcel_and_calendar_mismatch_are_explicit_without_guessed_clock_or_water() -> void:
	var payload: Dictionary = golden()
	var id: String = String(DirectorSaveContext.LAND.parcels[0].parcel_id)
	payload.land_ownership = {"owned_parcels": [id]}
	payload.clock.season = "winter"
	var before: Dictionary = payload.duplicate(true)
	var context: Dictionary = DirectorSaveContext.capture(PROFILE, payload, DataRegistry.get_all_crops())
	assert_true(context.ok)
	assert_true(DirectorSaveContext.valid(PROFILE, context))
	assert_false(context.calendar_aligned)
	assert_eq(context.reason, &"clock_calendar_unavailable")
	assert_eq(context.regions.size(), 2)
	assert_eq(context.regions[1], DirectorSaveContext.LAND.parcels[0].region)
	assert_eq(context.day_index, 30)
	assert_false(context.available.water_clarity)
	assert_eq(payload, before)

func test_invalid_sources_catalog_and_forged_contexts_fail_without_partial_context_or_alias() -> void:
	var crops: Array[Resource] = DataRegistry.get_all_crops()
	for raw: Variant in [null, true, [], {"clock": []}, {"clock": {"day_index": true}}, {"clock": {"day_index": -1}}, {"clock": {"day_index": 0.25}}]:
		assert_false(DirectorSaveContext.capture(PROFILE, raw, crops).ok)
	assert_false(DirectorSaveContext.capture(PROFILE, golden(), []).ok)
	var payload: Dictionary = golden()
	payload.farm.plots[0].withered_days = []
	assert_false(DirectorSaveContext.capture(PROFILE, payload, crops).ok)
	payload = golden()
	var context: Dictionary = DirectorSaveContext.capture(PROFILE, payload, crops)
	for field: String in context:
		var missing: Dictionary = context.duplicate(true)
		missing.erase(field)
		assert_false(DirectorSaveContext.valid(PROFILE, missing), field)
	var before: Dictionary = payload.duplicate(true)
	context.ecology.metrics.tree_cover = 99.0
	context.catalog_ids.clear()
	context.regions.clear()
	assert_false(DirectorSaveContext.valid(PROFILE, context))
	assert_eq(payload, before)
	assert_true(DirectorSaveContext.valid(PROFILE, DirectorSaveContext.capture(PROFILE, payload, crops)))
