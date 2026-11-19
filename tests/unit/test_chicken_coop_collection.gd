extends GutTest
const CONFIG: ChickenCoopConfig = preload("res://data/chicken_coop_config.tres")
const SLOT: int = 99
var egg: ItemData
var locale: String

class CountingInventory extends InventoryState:
	var calls: int = 0
	func add_item(item_id: StringName, quantity: int) -> int:
		calls += 1
		return super.add_item(item_id,quantity)

func before_each() -> void:
	egg = DataRegistry.get_item(&"egg") as ItemData
	locale = TranslationServer.get_locale()

func after_each() -> void:
	var items: Dictionary = DataRegistry.get("_items")
	items[&"egg"] = egg
	TranslationServer.set_locale(locale)
	SaveService.delete_save(SLOT)

func _state(quantity: int = 4) -> ChickenCoopState:
	var state: ChickenCoopState = ChickenCoopState.new()
	state.configure(CONFIG,3,4)
	state.deserialize({"current_day":3,"hen_count":4,"fed_hens":2,"pending_eggs":quantity})
	return state

func _service(state: ChickenCoopState, inventory: InventoryState) -> ChickenCoopCollectionService:
	var service: ChickenCoopCollectionService = ChickenCoopCollectionService.new()
	service.configure(state,inventory)
	return service

func test_registered_data_translations_existing_icon_fallback_and_schema_terms() -> void:
	assert_not_null(egg)
	assert_eq(egg.item_id,&"egg")
	assert_eq(egg.category,&"produce")
	assert_eq([egg.max_stack,egg.buy_price,egg.sell_price],[99,0,30])
	assert_eq(egg.icon_path,"")
	assert_not_null(UiIcons.for_item(&"egg"),"Existing generic icon handles new item")
	for language: String in ["vi","en"]:
		TranslationServer.set_locale(language)
		assert_ne(tr(String(egg.display_name_key)),String(egg.display_name_key))
		assert_ne(tr(String(egg.description_key)),String(egg.description_key))

func test_readonly_quote_and_one_actual_whole_transfer_preserve_other_items_and_daily_feed() -> void:
	var state: ChickenCoopState = _state()
	var inventory: InventoryState = InventoryState.new(3)
	inventory.add_item(&"turnip",2)
	var service: ChickenCoopCollectionService = _service(state,inventory)
	var before: Dictionary = {"state":state.serialize(),"bag":inventory.serialize()}
	assert_eq(service.can_collect(4),{"ok":true,"reason":&"ready","item_id":&"egg","quantity":4})
	assert_eq({"state":state.serialize(),"bag":inventory.serialize()},before)
	assert_eq(service.collect(4),{"ok":true,"reason":&"collected","item_id":&"egg","quantity":4,"remaining":0})
	assert_eq(inventory.get_quantity(&"egg"),4)
	assert_eq(inventory.get_quantity(&"turnip"),2)
	assert_eq(state.serialize(),{"current_day":3,"hen_count":4,"fed_hens":2,"pending_eggs":0})
	assert_false(state.is_busy())
	assert_eq(service.collect(4).reason,&"stale_quantity")
	assert_eq(inventory.get_quantity(&"egg"),4)
	assert_eq(state.advance_day(3).produced,2,"Collection does not reset today's feed")

func test_full_bag_and_insufficient_partial_stack_room_never_reserve_or_call_add() -> void:
	for initial: Array in [[&"turnip",20],[&"egg",96],[&"egg",99]]:
		var state: ChickenCoopState = _state()
		var inventory: CountingInventory = CountingInventory.new(1)
		inventory.add_item(initial[0],int(initial[1]))
		inventory.calls = 0
		var service: ChickenCoopCollectionService = _service(state,inventory)
		var before: Dictionary = {"state":state.serialize(),"bag":inventory.serialize()}
		assert_eq(service.can_collect(4).reason,&"inventory_full")
		assert_eq(service.collect(4).reason,&"inventory_full")
		assert_eq({"state":state.serialize(),"bag":inventory.serialize()},before)
		assert_eq(inventory.calls,0,"Whole capacity preflight blocks before insertion")
		assert_false(state.is_busy())

func test_existing_stack_and_multiple_new_stacks_use_real_limits_without_loss() -> void:
	var state: ChickenCoopState = _state(104)
	var inventory: InventoryState = InventoryState.new(3)
	inventory.add_item(&"turnip",2)
	inventory.add_item(&"egg",94)
	var service: ChickenCoopCollectionService = _service(state,inventory)
	assert_true(service.collect(104).ok)
	assert_eq(inventory.get_slots(),[{"item_id":&"turnip","quantity":2},{"item_id":&"egg","quantity":99},{"item_id":&"egg","quantity":99}])
	assert_eq(inventory.get_quantity(&"egg"),198)
	assert_eq(state.serialize().pending_eggs,0)

func test_stale_empty_unconfigured_unknown_registry_and_invalid_item_fail_without_changes() -> void:
	var state: ChickenCoopState = _state()
	var inventory: InventoryState = InventoryState.new()
	var service: ChickenCoopCollectionService = _service(state,inventory)
	assert_eq(ChickenCoopCollectionService.new().collect(4).reason,&"invalid_state")
	for empty: ChickenCoopState in [null,ChickenCoopState.new()]:
		assert_eq(_service(empty,inventory).collect(4).reason,&"invalid_state")
	assert_eq(_service(state,null).collect(4).reason,&"invalid_state")
	var before: Dictionary = {"state":state.serialize(),"bag":inventory.serialize()}
	for amount: int in [-1,0,1,3,5,ChickenCoopConfig.MAX_JSON_INTEGER]:
		assert_eq(service.collect(amount).reason,&"stale_quantity")
		assert_eq({"state":state.serialize(),"bag":inventory.serialize()},before)
	var items: Dictionary = DataRegistry.get("_items")
	items.erase(&"egg")
	assert_eq(service.can_collect(4).reason,&"unknown_item")
	assert_eq(service.collect(4).reason,&"unknown_item")
	assert_eq({"state":state.serialize(),"bag":inventory.serialize()},before)
	items[&"egg"] = ItemData.new()
	assert_eq(service.collect(4).reason,&"unknown_item")
	items[&"egg"] = egg
	assert_true(service.collect(4).ok)
	assert_false(service.collect(0).ok)

func test_real_v10_save_roundtrip_keeps_collected_egg_stacks_without_animal_save_field() -> void:
	var state: ChickenCoopState = _state(104)
	var inventory: InventoryState = InventoryState.new(4)
	inventory.add_item(&"turnip",2)
	assert_true(_service(state,inventory).collect(104).ok)
	var payload: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v10.json"))
	payload.inventory = inventory.serialize()
	var wallet: Dictionary = payload.wallet.duplicate(true)
	var farm: Dictionary = payload.farm.duplicate(true)
	assert_true(SaveService.save_game(payload,SLOT))
	var loaded: Dictionary = SaveService.load_game(SLOT)
	assert_eq(int(loaded.meta.save_version),15)
	assert_false(bool(loaded.chicken_coop.owned))
	assert_eq(loaded.wallet,wallet)
	assert_eq(loaded.farm,farm)
	var restored: InventoryState = InventoryState.new()
	restored.deserialize(loaded.inventory)
	assert_eq(restored.get_slots(),inventory.get_slots())
	assert_eq(restored.get_quantity(&"egg"),104)
	assert_eq(restored.get_quantity(&"turnip"),2)
	assert_eq(restored.capacity,inventory.capacity,"Current v10 retains explicit bag capacity")
