extends GutTest

func test_validator_rejects_bad_npc_references_offers_and_translation_keys() -> void:
	var content: NpcWorldData = preload("res://data/npcs/phase8_world.tres").duplicate(true)
	var items: Array[Resource] = [preload("res://data/items/spring_carrot_seed.tres"), preload("res://data/items/summer_tomato_seed.tres"), preload("res://data/items/autumn_wheat_seed.tres"), preload("res://data/items/winter_radish_seed.tres"), preload("res://data/items/turnip.tres")]
	var quests: Array[Resource] = [preload("res://data/quests/quest_turnip_delivery.tres")]
	var locales: Array[String] = ["res://localization/strings_vi.csv", "res://localization/strings_en.csv"]
	assert_true(DataValidator.validate_npc_world(content, items, quests, locales).is_empty())
	(content.npcs[0] as NpcData).home_location = &"missing_home"
	(content.offers[0] as MerchantOfferData).unit_price = -1
	(content.dialogues[0] as DialogueData).text_key = &"MISSING_DIALOGUE_KEY"
	var errors: PackedStringArray = DataValidator.validate_npc_world(content, items, quests, locales)
	assert_gte(errors.size(), 3, "Missing homes, invalid price and missing translation all rejected")
