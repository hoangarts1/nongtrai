extends GutTest
const CONFIG: ChickenCoopConfig = preload("res://data/chicken_coop_config.tres")
const SLOT: int = 100
var food: ItemData
var locale: String

func before_each() -> void:
	food = DataRegistry.get_item(&"chicken_feed") as ItemData
	locale = TranslationServer.get_locale()

func after_each() -> void:
	var items: Dictionary = DataRegistry.get("_items")
	items[&"chicken_feed"] = food
	TranslationServer.set_locale(locale)
	SaveService.delete_save(SLOT)

func _state(config: ChickenCoopConfig = CONFIG) -> ChickenCoopState:
	var state: ChickenCoopState = ChickenCoopState.new()
	state.configure(config,3,4)
	return state

func _service(state: ChickenCoopState, inventory: InventoryState) -> ChickenCoopFeedingService:
	var service: ChickenCoopFeedingService = ChickenCoopFeedingService.new()
	service.configure(state,inventory)
	return service

func test_registered_food_config_terms_locales_fallback_and_old_prices() -> void:
	assert_not_null(food)
	assert_eq(food.item_id,&"chicken_feed")
	assert_eq(food.category,&"material")
	assert_eq([food.max_stack,food.buy_price,food.sell_price],[99,20,0])
	assert_eq(CONFIG.feed_item_id,&"chicken_feed")
	assert_eq([CONFIG.hen_capacity,CONFIG.feed_per_hen,CONFIG.eggs_per_fed_hen],[4,1,1])
	assert_true(CONFIG.validation_errors().is_empty())
	assert_eq(int(DataRegistry.get_item(&"egg").sell_price),30)
	assert_eq(int(DataRegistry.get_item(&"autumn_wheat").sell_price),42)
	assert_not_null(UiIcons.for_item(&"chicken_feed"))
	for language: String in ["vi","en"]:
		TranslationServer.set_locale(language)
		assert_ne(tr(String(food.display_name_key)),String(food.display_name_key))
		assert_ne(tr(String(food.description_key)),String(food.description_key))
	var invalid: ChickenCoopConfig = CONFIG.duplicate() as ChickenCoopConfig
	invalid.feed_item_id = &""
	assert_false(invalid.validation_errors().is_empty())

func test_readonly_quote_real_partial_feeding_then_day_eggs_and_existing_collection() -> void:
	var state: ChickenCoopState = _state()
	var inventory: InventoryState = InventoryState.new(4)
	inventory.add_item(&"chicken_feed",4)
	inventory.add_item(&"turnip",2)
	var service: ChickenCoopFeedingService = _service(state,inventory)
	var before: Dictionary = {"state":state.serialize(),"bag":inventory.serialize()}
	var quote: Dictionary = service.can_feed(3,2)
	assert_true(quote.ok)
	assert_eq(quote.item_id,&"chicken_feed")
	assert_eq(quote.feed_units,2)
	assert_eq({"state":state.serialize(),"bag":inventory.serialize()},before)
	assert_eq(service.feed(3,2),{"ok":true,"reason":&"fed","item_id":&"chicken_feed","feed_units":2,"hens_fed":2,"fed_hens":2})
	assert_eq(inventory.get_quantity(&"chicken_feed"),2)
	assert_eq(state.serialize(),{"current_day":3,"hen_count":4,"fed_hens":2,"pending_eggs":0})
	assert_eq(inventory.get_quantity(&"egg"),0,"No immediate egg grant")
	assert_eq(state.advance_day(3).produced,2)
	assert_eq(service.feed(4,2).feed_units,2)
	assert_eq(inventory.get_quantity(&"chicken_feed"),0)
	var collection: ChickenCoopCollectionService = ChickenCoopCollectionService.new()
	collection.configure(state,inventory)
	assert_true(collection.collect(2).ok)
	assert_eq(inventory.get_quantity(&"egg"),2)
	assert_eq(inventory.get_quantity(&"turnip"),2)
	assert_eq(state.advance_day(4).produced,2)
	assert_eq(state.serialize().hen_count,4)
	assert_false(state.is_busy())

func test_exact_whole_debit_across_stacks_and_data_owned_cost_units() -> void:
	var state: ChickenCoopState = _state()
	var inventory: InventoryState = InventoryState.new(4)
	inventory.add_item(&"turnip",2)
	inventory.add_item(&"chicken_feed",100)
	assert_eq(_service(state,inventory).feed(3,4).feed_units,4)
	assert_eq(inventory.get_slots(),[{"item_id":&"turnip","quantity":2},{"item_id":&"chicken_feed","quantity":96}])
	var config: ChickenCoopConfig = CONFIG.duplicate() as ChickenCoopConfig
	config.feed_per_hen = 2
	state = _state(config)
	assert_eq(_service(state,inventory).feed(3,2).feed_units,4)
	assert_eq(inventory.get_quantity(&"chicken_feed"),92)
	assert_eq(state.serialize().fed_hens,2)

func test_missing_wrong_unknown_food_or_invalid_owners_do_not_mutate() -> void:
	var state: ChickenCoopState = _state()
	var inventory: InventoryState = InventoryState.new()
	inventory.add_item(&"autumn_wheat",10)
	var service: ChickenCoopFeedingService = _service(state,inventory)
	var before: Dictionary = {"state":state.serialize(),"bag":inventory.serialize()}
	assert_eq(service.can_feed(3,1).reason,&"missing_feed")
	assert_eq(service.feed(3,1).reason,&"missing_feed")
	assert_eq({"state":state.serialize(),"bag":inventory.serialize()},before)
	assert_eq(ChickenCoopFeedingService.new().feed(3,1).reason,&"invalid_state")
	assert_eq(_service(null,inventory).feed(3,1).reason,&"invalid_state")
	assert_eq(_service(state,null).feed(3,1).reason,&"invalid_state")
	assert_eq(_service(ChickenCoopState.new(),inventory).feed(3,1).reason,&"invalid_state")
	inventory.add_item(&"chicken_feed",4)
	before = {"state":state.serialize(),"bag":inventory.serialize()}
	var items: Dictionary = DataRegistry.get("_items")
	items.erase(&"chicken_feed")
	assert_eq(service.feed(3,1).reason,&"unknown_feed")
	assert_eq({"state":state.serialize(),"bag":inventory.serialize()},before)
	items[&"chicken_feed"] = ItemData.new()
	assert_eq(service.feed(3,1).reason,&"unknown_feed")
	items[&"chicken_feed"] = food
	var config: ChickenCoopConfig = CONFIG.duplicate() as ChickenCoopConfig
	config.feed_item_id = &"unknown_feed"
	assert_eq(_service(_state(config),inventory).feed(3,1).reason,&"unknown_feed")
	assert_eq(inventory.serialize(),before.bag)

func test_invalid_day_counts_missing_quantity_and_duplicate_overfeed_never_debit() -> void:
	var state: ChickenCoopState = _state()
	var inventory: InventoryState = InventoryState.new()
	inventory.add_item(&"chicken_feed",6)
	var service: ChickenCoopFeedingService = _service(state,inventory)
	var before: Dictionary = {"state":state.serialize(),"bag":inventory.serialize()}
	for day: int in [-1,2,4,ChickenCoopConfig.MAX_JSON_INTEGER]:
		assert_eq(service.feed(day,1).reason,&"wrong_day")
		assert_eq({"state":state.serialize(),"bag":inventory.serialize()},before)
	for hens: int in [-1,0,5,9223372036854775807]:
		assert_eq(service.feed(3,hens).reason,&"invalid_feed")
		assert_eq({"state":state.serialize(),"bag":inventory.serialize()},before)
	inventory.remove_item(&"chicken_feed",3)
	before = {"state":state.serialize(),"bag":inventory.serialize()}
	assert_eq(service.feed(3,4).reason,&"missing_feed")
	assert_eq({"state":state.serialize(),"bag":inventory.serialize()},before)
	assert_true(service.feed(3,3).ok)
	inventory.add_item(&"chicken_feed",3)
	assert_true(service.feed(3,1).ok)
	before = {"state":state.serialize(),"bag":inventory.serialize()}
	assert_eq(service.feed(3,1).reason,&"invalid_feed")
	assert_eq({"state":state.serialize(),"bag":inventory.serialize()},before)

func test_json_partial_feed_and_v10_remaining_food_roundtrip_without_animal_field() -> void:
	var state: ChickenCoopState = _state()
	var inventory: InventoryState = InventoryState.new(4)
	inventory.add_item(&"chicken_feed",6)
	inventory.add_item(&"turnip",2)
	assert_true(_service(state,inventory).feed(3,2).ok)
	var snapshot: Dictionary = state.serialize()
	assert_eq(snapshot.size(),4)
	var restored_state: ChickenCoopState = _state()
	restored_state.deserialize(JSON.parse_string(JSON.stringify(snapshot)))
	assert_eq(restored_state.serialize(),snapshot)
	var payload: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v10.json"))
	payload.inventory = inventory.serialize()
	assert_true(SaveService.save_game(payload,SLOT))
	var loaded: Dictionary = SaveService.load_game(SLOT)
	assert_eq(int(loaded.meta.save_version),18)
	assert_false(bool(loaded.chicken_coop.owned))
	var restored: InventoryState = InventoryState.new()
	restored.deserialize(loaded.inventory)
	assert_eq(restored.serialize(),inventory.serialize())
	assert_eq(restored.get_quantity(&"chicken_feed"),4)
	assert_eq(restored.get_quantity(&"turnip"),2)
	assert_eq(restored_state.advance_day(3).produced,2)
