extends GutTest
const CONFIG: ChickenCoopConfig = preload("res://data/chicken_coop_config.tres")

class RejectingInventory extends InventoryState:
	func add_item(item_id: StringName, quantity: int) -> int:
		if item_id==&"egg":
			super.add_item(&"turnip",1)
			return 0
		return super.add_item(item_id,quantity)

class PartialInventory extends InventoryState:
	func add_item(item_id: StringName, quantity: int) -> int:
		return super.add_item(item_id,mini(quantity,2) if item_id==&"egg" else quantity)

func _state(config: ChickenCoopConfig = CONFIG) -> ChickenCoopState:
	var state: ChickenCoopState = ChickenCoopState.new()
	state.configure(config,3,4)
	state.deserialize({"current_day":3,"hen_count":4,"fed_hens":2,"pending_eggs":4})
	return state

func _service(state: ChickenCoopState, inventory: InventoryState) -> ChickenCoopCollectionService:
	var service: ChickenCoopCollectionService = ChickenCoopCollectionService.new()
	service.configure(state,inventory)
	return service

func test_first_inventory_notification_sees_reserved_source_and_blocks_all_facades_and_raw_commands() -> void:
	var state: ChickenCoopState = _state()
	var inventory: InventoryState = InventoryState.new()
	var service: ChickenCoopCollectionService = _service(state,inventory)
	var other: ChickenCoopCollectionService = _service(state,inventory)
	var replies: Array[StringName] = []
	var observed: Array[int] = []
	var callback: Callable = func(_slots: Array[Dictionary]) -> void:
		observed.append(inventory.get_quantity(&"egg"))
		observed.append(int(state.serialize().pending_eggs))
		assert_true(state.is_busy())
		replies.append(service.can_collect(4).reason)
		replies.append(service.collect(4).reason)
		replies.append(other.collect(4).reason)
		replies.append(state.take_eggs(4).reason)
		replies.append(state.feed(3,1).reason)
		replies.append(state.advance_day(3).reason)
		replies.append(state.begin_collection(4).reason)
		state.configure(CONFIG,0,0)
		state.deserialize({"current_day":0,"hen_count":0,"fed_hens":0,"pending_eggs":99})
		assert_eq(state.serialize(),{"current_day":3,"hen_count":4,"fed_hens":2,"pending_eggs":0})
		assert_eq(state.serialize().size(),4,"No token/lock in wire data; busy snapshot is diagnostic only")
	inventory.inventory_changed.connect(callback)
	assert_true(service.collect(4).ok)
	inventory.inventory_changed.disconnect(callback)
	assert_eq(observed,[4,0],"Bag grant precedes first callback; source already reserved")
	assert_eq(replies,[&"collection_busy",&"collection_busy",&"collection_busy",&"collection_busy",&"collection_busy",&"collection_busy",&"collection_busy"])
	assert_false(state.is_busy())
	assert_eq(inventory.get_quantity(&"egg"),4)

func test_legitimate_independent_callback_gift_and_consumption_are_not_rolled_back() -> void:
	var state: ChickenCoopState = _state()
	var inventory: InventoryState = InventoryState.new()
	inventory.add_item(&"carrot",2)
	var service: ChickenCoopCollectionService = _service(state,inventory)
	var callback: Callable = func(item_id: StringName, quantity: int) -> void:
		if item_id==&"egg":
			assert_eq(quantity,4)
			inventory.add_item(&"turnip",3)
			assert_true(inventory.remove_item(&"egg",1))
	inventory.item_added.connect(callback)
	assert_eq(service.collect(4).quantity,4)
	inventory.item_added.disconnect(callback)
	assert_eq(inventory.get_quantity(&"egg"),3)
	assert_eq(inventory.get_quantity(&"turnip"),3)
	assert_eq(inventory.get_quantity(&"carrot"),2)
	assert_eq(state.serialize().pending_eggs,0)
	assert_eq(inventory.get_quantity(&"egg")+1,4,"Independent consumer received one of the four grants")

func test_reconfigured_facade_cannot_redirect_in_progress_transfer_or_unlock_another_owner() -> void:
	var state: ChickenCoopState = _state()
	var inventory: InventoryState = InventoryState.new()
	var other_state: ChickenCoopState = _state()
	var other_inventory: InventoryState = InventoryState.new()
	var service: ChickenCoopCollectionService = _service(state,inventory)
	var callback: Callable = func(_id: StringName, _quantity: int) -> void: service.configure(other_state,other_inventory)
	inventory.item_added.connect(callback)
	assert_true(service.collect(4).ok)
	inventory.item_added.disconnect(callback)
	assert_eq(inventory.get_quantity(&"egg"),4)
	assert_eq(state.serialize().pending_eggs,0)
	assert_false(state.is_busy())
	assert_eq(other_state.serialize().pending_eggs,4)
	assert_eq(other_inventory.get_quantity(&"egg"),0)
	assert_true(service.can_collect(4).ok,"Future command uses newly configured owner")

func test_reservation_identity_and_remaining_bounds_cannot_release_another_transfer() -> void:
	var state: ChickenCoopState = _state()
	var other: ChickenCoopState = _state()
	var reserved: Dictionary = state.begin_collection(4)
	var other_reserved: Dictionary = other.begin_collection(4)
	assert_true(reserved.ok)
	assert_false(state.finish_collection(null,0))
	assert_false(state.finish_collection(other_reserved.token as RefCounted,0))
	for remaining: int in [-1,5,9223372036854775807]:
		assert_false(state.finish_collection(reserved.token as RefCounted,remaining))
		assert_true(state.is_busy())
	assert_true(state.finish_collection(reserved.token as RefCounted,2))
	assert_eq(state.serialize().pending_eggs,2)
	assert_false(state.finish_collection(reserved.token as RefCounted,0))
	assert_eq(state.serialize().pending_eggs,2)
	assert_true(other.is_busy())
	assert_true(other.finish_collection(other_reserved.token as RefCounted,4))

func test_zero_rejected_grant_restores_all_output_without_erasing_independent_gift() -> void:
	var state: ChickenCoopState = _state()
	var before: Dictionary = state.serialize()
	var inventory: RejectingInventory = RejectingInventory.new()
	inventory.add_item(&"carrot",2)
	var result: Dictionary = _service(state,inventory).collect(4)
	assert_false(result.ok)
	assert_eq(result.reason,&"transfer_rejected")
	assert_eq(result.quantity,0)
	assert_eq(result.remaining,4)
	assert_eq(state.serialize(),before)
	assert_false(state.is_busy())
	assert_eq(inventory.get_quantity(&"egg"),0)
	assert_eq(inventory.get_quantity(&"turnip"),1)
	assert_eq(inventory.get_quantity(&"carrot"),2)
	var actual: InventoryState = InventoryState.new()
	assert_true(_service(state,actual).collect(4).ok)
	assert_eq(actual.get_quantity(&"egg"),4)

func test_partial_fault_retains_only_untransferred_eggs_and_retry_never_duplicates() -> void:
	var state: ChickenCoopState = _state()
	var inventory: PartialInventory = PartialInventory.new()
	var service: ChickenCoopCollectionService = _service(state,inventory)
	var result: Dictionary = service.collect(4)
	assert_false(result.ok)
	assert_eq(result.reason,&"partial_transfer")
	assert_eq(result.quantity,2)
	assert_eq(result.remaining,2)
	assert_eq(inventory.get_quantity(&"egg")+int(state.serialize().pending_eggs),4)
	assert_false(state.is_busy())
	assert_eq(service.collect(4).reason,&"stale_quantity")
	assert_true(service.collect(2).ok)
	assert_eq(inventory.get_quantity(&"egg"),4)
	assert_eq(state.serialize().pending_eggs,0)
	assert_false(service.collect(2).ok)

func test_invalidated_resource_during_callback_still_settles_original_success_or_rejection() -> void:
	for rejected: bool in [false,true]:
		var config: ChickenCoopConfig = CONFIG.duplicate() as ChickenCoopConfig
		var state: ChickenCoopState = _state(config)
		var inventory: InventoryState = RejectingInventory.new() if rejected else InventoryState.new()
		var callback: Callable = func(_id: StringName, _quantity: int) -> void: config.hen_capacity = 0
		inventory.item_added.connect(callback)
		var result: Dictionary = _service(state,inventory).collect(4)
		inventory.item_added.disconnect(callback)
		assert_eq(bool(result.ok),not rejected)
		assert_false(state.is_busy())
		assert_eq(state.serialize().pending_eggs,4 if rejected else 0)
		assert_eq(inventory.get_quantity(&"egg"),0 if rejected else 4)
		assert_eq(state.advance_day(3).reason,&"invalid_state")
		config.hen_capacity = 4
		assert_eq(state.advance_day(3).produced,2)
