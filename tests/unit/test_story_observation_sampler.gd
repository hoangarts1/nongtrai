extends GutTest
const CONFIG: StoryConfig = preload("res://data/story/chapter1.tres")
func test_only_real_stored_owner_flags_import_without_fabricated_history() -> void:
	var raw: Dictionary = {"quests":{"completed":[false,true,false,false,true,true,false]},"social":{"quests":{"completed":["turnip_delivery"]}},"land_ownership":{"owned_parcels":["farm_east_1"]}}
	var before: Dictionary = raw.duplicate(true)
	var result: Dictionary = StoryObservationSampler.legacy(CONFIG,raw)
	assert_true(result.ok)
	assert_eq(result.objective_ids,CONFIG.supported_ids())
	assert_eq(result.provenance,&"saved_owner_progress")
	assert_eq(raw,before)
	assert_false(result.has("day_index"))
func test_missing_malformed_boolean_coercions_and_bag_possession_are_not_evidence() -> void:
	for raw: Dictionary in [{}, {"quests":{"completed":[false,"true",false,false,1,1.0]}}, {"quests":[]}, {"inventory":{"turnip":999},"social":{"quests":{"active":["turnip_delivery"],"completed":[]}}}, {"story":{"completed_objectives":["m2_4_station","first_sale"]}}]:
		assert_eq(StoryObservationSampler.legacy(CONFIG,raw).objective_ids,PackedStringArray())
func test_ordered_actual_parcels_and_strict_completed_quest_ids_only() -> void:
	for raw: Variant in [[],["missing"],["farm_east_1","farm_east_1"],[true],"farm_east_1"]:
		assert_false(StoryObservationSampler.first_parcel(CONFIG,{"owned_parcels":raw}))
	assert_true(StoryObservationSampler.first_parcel(CONFIG,{"owned_parcels":["farm_east_1"]}))
	for raw: Variant in ["turnip_delivery",[true],["turnip_delivery","turnip_delivery"],["missing"]]:
		assert_eq(StoryObservationSampler.legacy(CONFIG,{"social":{"quests":{"completed":raw}}}).objective_ids,PackedStringArray())
func test_legacy_uses_referenced_data_without_mutation_or_unavailable_completions() -> void:
	var result: Dictionary = StoryObservationSampler.legacy(CONFIG,{"social":{"quests":{"completed":["turnip_delivery"]}}})
	assert_eq(result.objective_ids,PackedStringArray(["first_delivery"]))
	assert_false(StoryObservationSampler.legacy(null,{}).ok)
	for row: StoryObjectiveData in CONFIG.milestones: assert_true(row.planned)
