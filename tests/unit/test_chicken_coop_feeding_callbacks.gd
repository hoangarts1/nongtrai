extends GutTest
const CONFIG: ChickenCoopConfig = preload("res://data/chicken_coop_config.tres")

class RejectingInventory extends InventoryState:
	func remove_item(item_id: StringName, quantity: int) -> bool:
		if item_id==&"chicken_feed":
			add_item(&"turnip",1)
			return false
		return super.remove_item(item_id,quantity)

func _state(config: ChickenCoopConfig = CONFIG) -> ChickenCoopState:
	var state: ChickenCoopState = ChickenCoopState.new()
	state.configure(config,3,4)
	state.deserialize({"current_day":3,"hen_count":4,"fed_hens":0,"pending_eggs":4})
	return state

func _bag() -> InventoryState:
	var inventory: InventoryState = InventoryState.new()
	inventory.add_item(&"chicken_feed",6)
	return inventory

func _feeding(state: ChickenCoopState, inventory: InventoryState) -> ChickenCoopFeedingService:
	var service: ChickenCoopFeedingService = ChickenCoopFeedingService.new()
	service.configure(state,inventory)
	return service

func _collection(state: ChickenCoopState, inventory: InventoryState) -> ChickenCoopCollectionService:
	var service: ChickenCoopCollectionService = ChickenCoopCollectionService.new()
	service.configure(state,inventory)
	return service

func test_earliest_debit_callback_blocks_both_facades_collection_and_raw_state_changes() -> void:
	var state: ChickenCoopState = _state()
	var inventory: InventoryState = _bag()
	var service: ChickenCoopFeedingService = _feeding(state,inventory)
	var other: ChickenCoopFeedingService = _feeding(state,inventory)
	var collection: ChickenCoopCollectionService = _collection(state,inventory)
	var reasons: Array[StringName] = []
	var observations: Array[int] = []
	var callback: Callable = func(_slots: Array[Dictionary]) -> void:
		observations.append(inventory.get_quantity(&"chicken_feed"))
		observations.append(int(state.serialize().fed_hens))
		assert_true(state.is_busy())
		reasons.append(service.can_feed(3,1).reason)
		reasons.append(service.feed(3,1).reason)
		reasons.append(other.feed(3,1).reason)
		reasons.append(collection.collect(4).reason)
		reasons.append(state.feed(3,1).reason)
		reasons.append(state.advance_day(3).reason)
		reasons.append(state.take_eggs(4).reason)
		reasons.append(state.begin_feeding(3,1).reason)
		state.configure(CONFIG,0,0)
		state.deserialize({"current_day":0,"hen_count":0,"fed_hens":0,"pending_eggs":0})
		assert_eq(state.serialize(),{"current_day":3,"hen_count":4,"fed_hens":0,"pending_eggs":4})
	inventory.inventory_changed.connect(callback)
	assert_true(service.feed(3,2).ok)
	inventory.inventory_changed.disconnect(callback)
	assert_eq(observations,[4,0],"Whole debit precedes notifications; fed hens commit afterward")
	assert_eq(reasons,[&"feeding_busy",&"feeding_busy",&"feeding_busy",&"feeding_busy",&"feeding_busy",&"feeding_busy",&"feeding_busy",&"feeding_busy"])
	assert_false(state.is_busy())
	assert_eq(state.serialize().fed_hens,2)

func test_existing_collection_blocks_feeding_in_the_other_direction() -> void:
	var state: ChickenCoopState = _state()
	var inventory: InventoryState = _bag()
	var service: ChickenCoopFeedingService = _feeding(state,inventory)
	var reasons: Array[StringName] = []
	var callback: Callable = func(item_id: StringName, _quantity: int) -> void:
		if item_id==&"egg":
			reasons.append(service.can_feed(3,2).reason)
			reasons.append(service.feed(3,2).reason)
			reasons.append(state.begin_feeding(3,2).reason)
	inventory.item_added.connect(callback)
	assert_true(_collection(state,inventory).collect(4).ok)
	inventory.item_added.disconnect(callback)
	assert_eq(reasons,[&"collection_busy",&"collection_busy",&"collection_busy"])
	assert_eq(inventory.get_quantity(&"chicken_feed"),6)
	assert_eq(state.serialize().fed_hens,0)
	assert_true(service.feed(3,2).ok)
	assert_eq(inventory.get_quantity(&"chicken_feed"),4)

func test_rejected_debit_grants_no_hens_unlocks_and_retains_independent_gift() -> void:
	var state: ChickenCoopState = _state()
	var before: Dictionary = state.serialize()
	var inventory: RejectingInventory = RejectingInventory.new()
	inventory.add_item(&"chicken_feed",6)
	var result: Dictionary = _feeding(state,inventory).feed(3,2)
	assert_false(result.ok)
	assert_eq(result.reason,&"debit_rejected")
	assert_eq(result.feed_units,0)
	assert_eq(result.hens_fed,0)
	assert_eq(state.serialize(),before)
	assert_false(state.is_busy())
	assert_eq(inventory.get_quantity(&"chicken_feed"),6)
	assert_eq(inventory.get_quantity(&"turnip"),1)
	assert_true(_feeding(state,_bag()).feed(3,2).ok)
	assert_eq(state.serialize().fed_hens,2)

func test_independent_gift_and_secondary_consumption_are_not_snapshot_rolled_back() -> void:
	var state: ChickenCoopState = _state()
	var inventory: InventoryState = _bag()
	inventory.add_item(&"carrot",2)
	var once: Array[bool] = [false]
	var callback: Callable = func(item_id: StringName, _quantity: int) -> void:
		if item_id==&"chicken_feed" and not once[0]:
			once[0] = true
			inventory.add_item(&"turnip",3)
			inventory.remove_item(&"carrot",1)
			inventory.remove_item(&"chicken_feed",1)
	inventory.item_removed.connect(callback)
	assert_eq(_feeding(state,inventory).feed(3,2).feed_units,2)
	inventory.item_removed.disconnect(callback)
	assert_eq(inventory.get_quantity(&"chicken_feed"),3)
	assert_eq(inventory.get_quantity(&"carrot"),1)
	assert_eq(inventory.get_quantity(&"turnip"),3)
	assert_eq(state.serialize().fed_hens,2,"Independent food use does not feed extra hens")
	assert_eq(state.serialize().pending_eggs,4)

func test_token_identity_abort_reuse_and_cross_operation_settlement_are_safe() -> void:
	var state: ChickenCoopState = _state()
	var other: ChickenCoopState = _state()
	var reserved: Dictionary = state.begin_feeding(3,2)
	var other_reserved: Dictionary = other.begin_feeding(3,2)
	assert_true(reserved.ok)
	assert_false(state.finish_feeding(null,true))
	assert_false(state.finish_feeding(other_reserved.token as RefCounted,true))
	assert_false(state.finish_collection(reserved.token as RefCounted,0))
	assert_eq(state.collection_quote(4).reason,&"feeding_busy")
	assert_true(state.finish_feeding(reserved.token as RefCounted,false))
	assert_eq(state.serialize().fed_hens,0)
	assert_false(state.finish_feeding(reserved.token as RefCounted,true))
	assert_true(other.finish_feeding(other_reserved.token as RefCounted,true))
	assert_eq(other.serialize().fed_hens,2)
	var collection: Dictionary = state.begin_collection(4)
	assert_false(state.finish_feeding(collection.token as RefCounted,true))
	assert_true(state.is_busy())
	assert_true(state.finish_collection(collection.token as RefCounted,4))
	assert_eq(state.serialize().size(),4)

func test_reconfigured_facade_keeps_original_debit_and_hen_owners() -> void:
	var state: ChickenCoopState = _state()
	var inventory: InventoryState = _bag()
	var other_state: ChickenCoopState = _state()
	var other_inventory: InventoryState = _bag()
	var service: ChickenCoopFeedingService = _feeding(state,inventory)
	var callback: Callable = func(_id: StringName, _quantity: int) -> void: service.configure(other_state,other_inventory)
	inventory.item_removed.connect(callback)
	assert_true(service.feed(3,2).ok)
	inventory.item_removed.disconnect(callback)
	assert_eq(inventory.get_quantity(&"chicken_feed"),4)
	assert_eq(state.serialize().fed_hens,2)
	assert_false(state.is_busy())
	assert_eq(other_inventory.get_quantity(&"chicken_feed"),6)
	assert_eq(other_state.serialize().fed_hens,0)
	assert_true(service.can_feed(3,1).ok)

func test_changed_or_invalid_config_settles_captured_food_terms_and_paid_hens() -> void:
	for rejected: bool in [false,true]:
		var config: ChickenCoopConfig = CONFIG.duplicate() as ChickenCoopConfig
		var state: ChickenCoopState = _state(config)
		var inventory: InventoryState = RejectingInventory.new() if rejected else InventoryState.new()
		inventory.add_item(&"chicken_feed",6)
		inventory.add_item(&"autumn_wheat",8)
		var callback: Callable = func(_slots: Array[Dictionary]) -> void:
			config.feed_item_id = &"autumn_wheat"
			config.feed_per_hen = 3
			config.hen_capacity = 0
		inventory.inventory_changed.connect(callback)
		var result: Dictionary = _feeding(state,inventory).feed(3,2)
		inventory.inventory_changed.disconnect(callback)
		assert_eq(bool(result.ok),not rejected)
		assert_eq(result.item_id,&"chicken_feed")
		assert_eq(result.feed_units,0 if rejected else 2)
		assert_eq(inventory.get_quantity(&"chicken_feed"),6 if rejected else 4)
		assert_eq(inventory.get_quantity(&"autumn_wheat"),8)
		assert_eq(state.serialize().fed_hens,0 if rejected else 2)
		assert_false(state.is_busy())
		assert_eq(state.advance_day(3).reason,&"invalid_state")
		config.feed_item_id = &"chicken_feed"
		config.feed_per_hen = 1
		config.hen_capacity = 4
		assert_eq(state.advance_day(3).produced,0 if rejected else 2)
