extends GutTest

const CONFIG: EcologySamplingConfig = preload("res://data/ecology_sampling_config.tres")
var _crops: Array[Resource] = []
var _regions: Array[Rect2i] = []
var _current: Dictionary = {}

func before_each() -> void:
	_crops = DataRegistry.get_all_crops()
	_regions = [Rect2i(0, 0, 64, 2)]
	_current = {"tree_cover": 17.0, "water_clarity": 42.5, "biodiversity": 31.0}

func _row(id: String, x: int = 0, growth: int = 0, target: int = 3, repeating: bool = false, withered: bool = false) -> Dictionary:
	return {"cell_x": x, "cell_y": 0, "tilled": true, "crop_id": id, "growth_days": growth, "growth_target": target, "regrowing": repeating, "watered": false, "consecutive_dry_days": 0, "withered": withered, "withered_days": 1 if withered else 0}

func _sample(rows: Array) -> Dictionary:
	return EcologySampler.sample(CONFIG, {"plots": rows}, _crops, _regions, _current)

func _reject(raw: Variant) -> void:
	var result: Dictionary = EcologySampler.sample(CONFIG, raw, _crops, _regions, _current)
	assert_false(result.ok, str(raw))
	assert_false(result.has("targets"))
	assert_false(result.has("counts"))
	assert_false(String(result.get("reason", "")).is_empty())

func test_empty_and_untilled_plots_have_zero_counts_and_unmeasured_water() -> void:
	var empty: Dictionary = _row("", 0, 0, 0)
	empty.tilled = false
	for rows: Array in [[], [empty]]:
		var result: Dictionary = _sample(rows)
		assert_true(result.ok)
		assert_eq(result.counts, {"mature_fruit_trees": 0, "healthy_plants": 0, "species": 0})
		assert_eq(result.targets, {"tree_cover": 0.0, "water_clarity": 42.5, "biodiversity": 0.0})
		assert_eq(result.available, {"tree_cover": true, "water_clarity": false, "biodiversity": true})

func test_frozen_maturity_boundary_and_repeat_trees_stay_mature() -> void:
	var rows: Array = [_row("orange", 0, 6, 7), _row("apple", 1, 7, 7), _row("banana", 2, 0, 2, true)]
	var result: Dictionary = _sample(rows)
	assert_true(result.ok)
	assert_eq(result.counts, {"mature_fruit_trees": 2, "healthy_plants": 3, "species": 3})
	assert_eq(result.targets.tree_cover, 25.0)
	assert_eq(result.targets.biodiversity, 37.5)
	rows[0].growth_days = 7
	assert_eq(_sample(rows).counts.mature_fruit_trees, 3)

func test_coffee_pepper_and_immature_crops_count_species_only() -> void:
	var result: Dictionary = _sample([_row("coffee", 0, 20, 10), _row("pepper", 1, 0, 4, true), _row("carrot", 2)])
	assert_true(result.ok)
	assert_eq(result.counts, {"mature_fruit_trees": 0, "healthy_plants": 3, "species": 3})
	assert_eq(result.targets.tree_cover, 0.0)

func test_withered_plants_do_not_contribute_even_when_mature_or_repeating() -> void:
	var result: Dictionary = _sample([_row("orange", 0, 10, 10, false, true), _row("banana", 1, 0, 2, true, true), _row("carrot", 2, 3, 3, false, true)])
	assert_true(result.ok)
	assert_eq(result.counts.healthy_plants, 0)
	assert_eq(result.counts.species, 0)
	assert_eq(result.counts.mature_fruit_trees, 0)

func test_six_legacy_aliases_collapse_species_without_changing_ids() -> void:
	var rows: Array = []
	for source: String in CONFIG.species_aliases:
		rows.append(_row(source, rows.size()))
		rows.append(_row(CONFIG.species_aliases[source], rows.size()))
	rows.append(_row("turnip", rows.size()))
	rows.append(_row("spring_pea", rows.size()))
	rows.append(_row("autumn_wheat", rows.size()))
	var before: Array = rows.duplicate(true)
	var result: Dictionary = _sample(rows)
	assert_true(result.ok)
	assert_eq(result.counts.species, 9)
	assert_eq(result.counts.healthy_plants, 15)
	assert_eq(result.targets.biodiversity, 100.0)
	assert_eq(rows, before)

func test_owned_only_overlapping_regions_count_once_and_empty_ownership_is_valid() -> void:
	_regions = [Rect2i(-1, 0, 2, 1), Rect2i(0, 0, 2, 1)]
	var rows: Array = [_row("orange", -1, 10), _row("apple", 0, 10), _row("banana", 1, 10), _row("carrot", 2)]
	var result: Dictionary = _sample(rows)
	assert_eq(result.counts.mature_fruit_trees, 3)
	assert_eq(result.counts.healthy_plants, 3)
	assert_eq(result.counts.species, 3)
	_regions.clear()
	assert_eq(_sample(rows).counts.healthy_plants, 0)
	assert_eq(rows.size(), 4, "Unowned data remains intact")

func test_resource_goals_control_normalization_and_cap_at_one_hundred() -> void:
	var config: EcologySamplingConfig = CONFIG.duplicate(true) as EcologySamplingConfig
	config.mature_tree_goal = 2
	config.species_goal = 4
	var rows: Array = []
	for x: int in range(12):
		rows.append(_row("orange", x, 9))
	var result: Dictionary = EcologySampler.sample(config, {"plots": rows}, _crops, _regions, _current)
	assert_true(result.ok)
	assert_eq(result.counts.mature_fruit_trees, 12)
	assert_eq(result.targets.tree_cover, 100.0)
	assert_eq(result.targets.biodiversity, 25.0)

func test_malformed_rows_types_counters_and_unknown_unowned_crop_fail_atomically() -> void:
	for raw: Variant in [null, [], {}, {"plots": {}}, {"plots": [null]}]:
		_reject(raw)
	var valid: Dictionary = _row("orange", 0, 9)
	for field: String in valid:
		var row: Dictionary = valid.duplicate(true)
		row.erase(field)
		_reject({"plots": [valid, row]})
	for field: String in ["cell_x", "cell_y", "growth_days", "growth_target", "consecutive_dry_days", "withered_days"]:
		for bad: Variant in [true, "1", 0.5, NAN, INF, 2147483648]:
			var row: Dictionary = valid.duplicate(true)
			row[field] = bad
			_reject({"plots": [row]})
	for field: String in ["growth_days", "growth_target", "consecutive_dry_days", "withered_days"]:
		var row: Dictionary = valid.duplicate(true)
		row[field] = -1
		_reject({"plots": [row]})
	for field: String in ["tilled", "regrowing", "watered", "withered"]:
		var row: Dictionary = valid.duplicate(true)
		row[field] = 1
		_reject({"plots": [row]})
	_reject({"plots": [valid, _row("unknown", 10000)]})
	var nonstring: Dictionary = valid.duplicate(true)
	nonstring.crop_id = 1
	_reject({"plots": [nonstring]})
	_reject({"plots": [_row("carrot", 1, 0, 3, true)]})
	_reject({"plots": [_row("orange", 1, 0, 0)]})
	_reject({"plots": [_row("", 1, 1, 0)]})

func test_duplicate_cells_and_invalid_regions_fail_even_with_valid_other_rows() -> void:
	var row: Dictionary = _row("orange", 0, 9)
	_reject({"plots": [row, row.duplicate(true)]})
	for region: Rect2i in [Rect2i(0, 0, 0, 1), Rect2i(0, 0, -1, 1), Rect2i(2147483647, 0, 1, 1), Rect2i(0, 2147483647, 1, 1)]:
		_regions = [region]
		_reject({"plots": [row]})

func test_json_integer_cells_negative_limits_and_stringname_ids_are_supported() -> void:
	_regions = [Rect2i(-2147483648, -1, 2, 2)]
	var row: Dictionary = _row("orange", -2147483648, 7, 7)
	row.cell_x = -2147483648.0
	row.cell_y = 0.0
	row.growth_days = 7.0
	row.crop_id = &"orange"
	assert_eq(_sample([row]).counts.mature_fruit_trees, 1)
	row.cell_x = -2147483649.0
	_reject({"plots": [row]})

func test_invalid_current_metrics_and_config_never_invent_water_fallback() -> void:
	for metrics: Dictionary in [{}, {"tree_cover": 0, "water_clarity": NAN, "biodiversity": 0}, {"tree_cover": 0, "water_clarity": true, "biodiversity": 0}, {"tree_cover": 0, "water_clarity": 101, "biodiversity": 0}, {"tree_cover": 0, "water_clarity": 0, "biodiversity": 0, "extra": 0}]:
		_current = metrics
		_reject({"plots": []})
	_current = {"tree_cover": 0, "water_clarity": 0, "biodiversity": 0}
	assert_eq(_sample([]).targets.water_clarity, 0.0)
	assert_false(_sample([]).available.water_clarity)
	var result: Dictionary = EcologySampler.sample(null, {"plots": []}, _crops, _regions, _current)
	assert_false(result.ok)
	var invalid: EcologySamplingConfig = CONFIG.duplicate(true) as EcologySamplingConfig
	invalid.species_goal = 0
	result = EcologySampler.sample(invalid, {"plots": []}, _crops, _regions, _current)
	assert_false(result.ok)
	assert_false(result.has("targets"))

func test_inputs_and_outputs_are_detached_and_sampling_is_repeatable() -> void:
	var rows: Array = [_row("orange", 0, 8)]
	var input_before: Array = rows.duplicate(true)
	var regions_before: Array[Rect2i] = _regions.duplicate()
	var metrics_before: Dictionary = _current.duplicate(true)
	var result: Dictionary = _sample(rows)
	var expected: Dictionary = result.duplicate(true)
	result.targets.water_clarity = 99.0
	result.counts.species = 999
	result.available.water_clarity = true
	assert_eq(_sample(rows), expected)
	assert_eq(rows, input_before)
	assert_eq(_regions, regions_before)
	assert_eq(_current, metrics_before)
	assert_eq(CONFIG.mature_tree_goal, 8)
	assert_eq((DataRegistry.get_crop(&"orange") as CropData).crop_id, &"orange")
