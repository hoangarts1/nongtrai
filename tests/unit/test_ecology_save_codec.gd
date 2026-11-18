extends GutTest

const PROFILE: EcologyProfile = preload("res://data/ecology_profile.tres")
const CONFIG: EcologySamplingConfig = preload("res://data/ecology_sampling_config.tres")
const LAND: LandExpansionConfig = preload("res://data/land_expansion_config.tres")
const LEGACY: CropMigrationConfig = preload("res://data/crop_migration_v7.tres")
var _crops: Array[Resource] = []

func before_each() -> void:
	_crops = DataRegistry.get_all_crops()

func _golden(version: int) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v%d.json" % version))

func _context(payload: Variant) -> Dictionary:
	return EcologySaveContext.capture(payload, _crops, LAND, LEGACY)

func _normalize(raw: Variant, context: Dictionary, day: int = 30) -> Dictionary:
	return EcologySaveCodec.normalize(PROFILE, CONFIG, raw, day, _crops, context)

func test_all_twelve_goldens_match_actual_farm_land_restore_and_leave_source_exact() -> void:
	for version: int in range(1, 13):
		var original: Dictionary = _golden(version)
		var before: Dictionary = original.duplicate(true)
		var context: Dictionary = _context(original)
		assert_true(context.ok, str(version))
		var farm: FarmGridState = FarmGridState.new()
		farm.deserialize(original.farm)
		var land: LandOwnershipState = LandOwnershipState.new()
		land.configure(LAND)
		land.deserialize(original.get("land_ownership", {}))
		assert_eq(context.farm, farm.serialize(), str(version))
		assert_eq(context.regions, land.get_owned_regions(), str(version))
		var result: Dictionary = _normalize(null, context, int(original.clock.day_index))
		assert_true(result.ok, str(version))
		assert_eq(result.snapshot.day_index, int(original.clock.day_index))
		assert_eq(result.snapshot.triggered, [])
		assert_false(result.sample.available.water_clarity)
		assert_eq(original, before)

func test_valid_clock_aligned_values_and_history_preserve_full_precision() -> void:
	var raw: Dictionary = {"day_index": 30, "metrics": {"tree_cover": 29.999999999999996, "water_clarity": 50.0, "biodiversity": 24.999999999999996}, "triggered": ["birds"]}
	var context: Dictionary = _context(_golden(12))
	var result: Dictionary = _normalize(JSON.parse_string(JSON.stringify(raw, "", true, true)), context)
	assert_true(result.ok)
	assert_eq(result.reason, &"restored")
	assert_eq(result.snapshot, raw)
	assert_true(result.snapshot.metrics.tree_cover < 30.0)
	assert_true(result.snapshot.metrics.biodiversity < 25.0)
	assert_false(result.sample.available.water_clarity)
	assert_eq(result.sample.targets.water_clarity, 50.0)
	var state: EcologyState = EcologyState.new()
	assert_true(state.configure(PROFILE))
	watch_signals(state)
	assert_true(state.deserialize(result.snapshot))
	assert_false(state.is_threshold_active(&"birds"))
	assert_false(state.is_threshold_active(&"butterflies"))
	assert_signal_not_emitted(state, "ecology_changed")
	assert_signal_not_emitted(state, "threshold_crossed")

func test_corrupt_component_fallback_is_explicit_current_day_without_history_replay() -> void:
	var context: Dictionary = _context(_golden(12))
	for raw: Variant in [null, {}, 5, [], {"day_index": 29, "metrics": {"tree_cover": 100, "water_clarity": 100, "biodiversity": 100}, "triggered": []}, {"day_index": 30, "metrics": {"tree_cover": 0, "water_clarity": 0, "biodiversity": 0}, "triggered": ["unknown"]}]:
		var result: Dictionary = _normalize(raw, context)
		assert_true(result.ok, str(raw))
		assert_ne(result.reason, &"restored")
		assert_eq(result.snapshot.day_index, 30)
		assert_eq(result.snapshot.triggered, [])
		assert_eq(result.snapshot.metrics.water_clarity, PROFILE.get_metric(&"water_clarity").initial_value)
		assert_false(result.sample.available.water_clarity)
		assert_eq(result.snapshot.metrics.biodiversity, result.sample.targets.biodiversity)

func test_invalid_context_profile_day_and_casts_fail_without_partial_snapshot() -> void:
	for input: Variant in [null, [], {"farm": []}, {"farm": {"plots": "bad"}}, {"farm": {"plots": [{"withered_days": []}]}}, {"farm": {"plots": [{"withered_days": INF}]}}]:
		var context: Dictionary = _context(input)
		assert_false(context.ok)
		var result: Dictionary = _normalize({}, context)
		assert_false(result.ok)
		assert_false(result.has("snapshot"))
	for context: Dictionary in [{}, {"ok": "true", "regions": []}, {"ok": true, "regions": [5], "farm": {"plots": []}}, {"ok": true, "regions": [], "farm": {"plots": "bad"}}]:
		var result: Dictionary = _normalize({}, context)
		assert_false(result.ok)
		assert_false(result.has("snapshot"))
	assert_false(_normalize({}, _context({}), -1).ok)
	assert_false(EcologySaveCodec.normalize(null, CONFIG, {}, 0, _crops, _context({})).ok)

func test_catalog_land_and_migration_errors_are_rejected_before_decode() -> void:
	assert_false(EcologySaveContext.capture({}, [], LAND, LEGACY).ok)
	assert_false(EcologySaveContext.capture({}, _crops, null, LEGACY).ok)
	assert_false(EcologySaveContext.capture({}, _crops, LAND, null).ok)
	for value: Variant in [0, -1, true, "3", [], INF, 0.5, 2147483648]:
		var legacy: CropMigrationConfig = LEGACY.duplicate(true) as CropMigrationConfig
		legacy.previous_growth_days = {&"turnip": value}
		assert_false(EcologySaveContext.capture({}, _crops, LAND, legacy).ok, str(value))

func test_canonical_context_and_component_results_do_not_alias_source() -> void:
	var payload: Dictionary = _golden(12)
	var before: Dictionary = payload.duplicate(true)
	var context: Dictionary = _context(payload)
	var result: Dictionary = _normalize({}, context)
	assert_true(result.ok)
	context.farm.plots.clear()
	context.regions.clear()
	result.snapshot.metrics.biodiversity = 999
	result.sample.available.water_clarity = true
	assert_eq(payload, before)
	var fresh: Dictionary = _normalize({}, _context(payload))
	assert_true(fresh.ok)
	assert_true(fresh.snapshot.metrics.biodiversity <= 100.0)
	assert_false(fresh.sample.available.water_clarity)
	assert_eq(int(_golden(12).meta.save_version), 12, "Historical golden retains its own version")
	assert_eq(int(_golden(SaveService.CURRENT_VERSION).meta.save_version), SaveService.CURRENT_VERSION, "Current schema has its own matching golden")
