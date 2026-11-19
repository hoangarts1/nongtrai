extends GutTest
const CONFIG: StoryConfig = preload("res://data/story/chapter1.tres")
func test_catalogue_uses_actual_sources_and_planned_repairs_never_claim_unlocks() -> void:
	assert_eq(CONFIG.objectives.size(),10)
	assert_eq(CONFIG.supported_ids().size(),5)
	assert_eq(CONFIG.milestones.size(),4)
	assert_eq(CONFIG.pages.size(),6)
	assert_eq(CONFIG.delivery.quest_id,&"turnip_delivery")
	assert_eq(CONFIG.land.parcels[0].parcel_id,&"farm_east_1")
	assert_true(DataValidator.validate_story_config(CONFIG,["res://localization/strings_vi.csv","res://localization/strings_en.csv"]).is_empty())
	for row: StoryObjectiveData in CONFIG.milestones: assert_true(row.planned)
func test_freeze_detaches_external_resources_arrays_and_nested_definitions() -> void:
	var copy: StoryConfig = CONFIG.frozen_copy()
	copy.delivery.reward_coins += 1
	copy.land.base_cost += 1
	copy.pages[0].body_key = &"OTHER"
	copy.objectives[0].requires.append("first_sale")
	copy.land.npc_world.npcs[0].schedule[0].weekdays.append(1)
	assert_ne(copy.delivery.reward_coins,CONFIG.delivery.reward_coins)
	assert_ne(copy.land.base_cost,CONFIG.land.base_cost)
	assert_ne(copy.pages[0].body_key,CONFIG.pages[0].body_key)
	assert_true(CONFIG.objectives[0].requires.is_empty())
	assert_eq(CONFIG.land.npc_world.npcs[0].schedule[0].weekdays.size(),2)
func test_duplicate_unknown_source_and_unimplemented_milestone_are_rejected() -> void:
	for kind: int in range(4):
		var copy: StoryConfig = CONFIG.frozen_copy()
		if kind==0: copy.objectives[1].objective_id = copy.objectives[0].objective_id
		elif kind==1: copy.objectives[0].source = &"repair_station"
		elif kind==2: copy.milestones[0].planned = false
		else: copy.objectives[3].source_id = &"missing_quest"
		assert_false(StoryCatalogValidator.validate(copy).is_empty())
func test_page_dependencies_and_objective_cycles_reject_without_source_mutation() -> void:
	var copy: StoryConfig = CONFIG.frozen_copy()
	copy.pages[0].requires_pages = PackedStringArray([String(copy.pages[0].page_id)])
	assert_false(StoryCatalogValidator.validate(copy).is_empty())
	copy = CONFIG.frozen_copy()
	copy.pages[0].objective_id = &"repair_house"
	assert_false(StoryCatalogValidator.validate(copy).is_empty())
	copy = CONFIG.frozen_copy()
	copy.objectives[0].requires = PackedStringArray(["first_harvest"])
	copy.objectives[1].requires = PackedStringArray(["first_sowing"])
	assert_false(StoryCatalogValidator.validate(copy).is_empty())
	copy = CONFIG.frozen_copy()
	copy.pages[0].requires_pages = PackedStringArray(["missing"])
	assert_false(StoryCatalogValidator.validate(copy).is_empty())
	assert_true(StoryCatalogValidator.validate(CONFIG).is_empty())
