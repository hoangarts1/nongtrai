extends GutTest

const SHIPPED: EcologySamplingConfig = preload("res://data/ecology_sampling_config.tres")
var _config: EcologySamplingConfig
var _crops: Array[Resource] = []

func before_each() -> void:
	_config = SHIPPED.duplicate(true) as EcologySamplingConfig
	_config.species_aliases = SHIPPED.species_aliases.duplicate(true)
	_crops = DataRegistry.get_all_crops()

func test_shipped_goals_catalog_and_validator_facade() -> void:
	assert_eq(_config.mature_tree_goal, 8)
	assert_eq(_config.species_goal, 8)
	assert_eq(_config.fruit_tree_ids, PackedStringArray(["orange", "apple", "banana"]))
	assert_eq(_config.species_aliases.size(), 6)
	assert_eq(_crops.size(), 25)
	assert_eq(_config.validation_errors(_crops), PackedStringArray())
	assert_eq(DataValidator.validate_ecology_sampling(_config, _crops), PackedStringArray())
	assert_false(DataValidator.validate_ecology_sampling(null, _crops).is_empty())

func test_nonpositive_or_overflowing_goal_rejects() -> void:
	for value: int in [0, -1, 2147483648]:
		_config.mature_tree_goal = value
		assert_false(_config.validation_errors(_crops).is_empty(), str(value))
		_config.mature_tree_goal = 8
		_config.species_goal = value
		assert_false(_config.validation_errors(_crops).is_empty(), str(value))
		_config.species_goal = 8

func test_missing_wrong_duplicate_and_invalid_crop_catalog_rejects() -> void:
	assert_false(_config.validation_errors([]).is_empty())
	for resource: Resource in [null, Resource.new(), _crops[0]]:
		var invalid: Array[Resource] = _crops.duplicate()
		invalid.append(resource)
		assert_false(_config.validation_errors(invalid).is_empty())
	var bad: CropData = _crops[0].duplicate(true) as CropData
	var invalid: Array[Resource] = _crops.duplicate()
	invalid[0] = bad
	for id: StringName in [&"", &"Bad-id"]:
		bad.crop_id = id
		assert_false(_config.validation_errors(invalid).is_empty())
	bad.crop_id = (_crops[0] as CropData).crop_id
	bad.growth_days = 0
	assert_false(_config.validation_errors(invalid).is_empty())
	bad.growth_days = 1
	bad.regrow_days = -1
	assert_false(_config.validation_errors(invalid).is_empty())

func test_tree_ids_require_known_unique_perennial_repeat_crops() -> void:
	for ids: PackedStringArray in [PackedStringArray(), PackedStringArray(["unknown"]), PackedStringArray(["orange", "orange"]), PackedStringArray(["carrot"])]:
		_config.fruit_tree_ids = ids
		assert_false(_config.validation_errors(_crops).is_empty())
	_config.fruit_tree_ids = PackedStringArray(["orange"])
	var invalid: Array[Resource] = _crops.duplicate()
	for index: int in range(invalid.size()):
		var crop: CropData = invalid[index] as CropData
		if crop.crop_id == &"orange":
			var copy: CropData = crop.duplicate(true) as CropData
			invalid[index] = copy
			copy.perennial = false
			assert_false(_config.validation_errors(invalid).is_empty())
			copy.perennial = true
			copy.regrow_days = 0
			assert_false(_config.validation_errors(invalid).is_empty())

func test_alias_shape_unknown_identity_chain_cycle_reject_without_mutation() -> void:
	for aliases: Dictionary in [{1: "carrot"}, {"carrot": []}, {"unknown": "carrot"}, {"carrot": "unknown"}, {"carrot": "carrot"}, {"spring_carrot": "carrot", "carrot": "radish"}, {"carrot": "radish", "radish": "carrot"}]:
		_config.species_aliases = aliases.duplicate(true)
		assert_false(_config.validation_errors(_crops).is_empty(), str(aliases))
		assert_eq(_config.species_aliases, aliases)
	_config.species_aliases = {&"spring_carrot": &"carrot"}
	assert_true(_config.validation_errors(_crops).is_empty())
	assert_eq(SHIPPED.species_aliases.size(), 6, "Shipped shared Resource stays unchanged")
