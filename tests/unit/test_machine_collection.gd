extends GutTest

const CELL: Vector2i = Vector2i(2,3)
var _inventory: InventoryState
var _owned: MachineInventory
var _placements: MachinePlacementState
var _service: MachineOperationService

class RejectingInventory extends InventoryState:
	var reject: bool = true
	func add_item(id: StringName, quantity: int) -> int:
		return 0 if reject else super.add_item(id,quantity)

func before_each() -> void:
	_inventory = InventoryState.new(4)
	_owned = MachineInventory.new()
	_owned.add_machine(&"stove")
	_placements = MachinePlacementState.new()
	_placements.configure(preload("res://data/land_parcels.tres"),_owned)
	assert_true(_placements.place(&"stove",CELL,0).ok)
	_service = MachineOperationService.new()
	_service.configure(_inventory,_placements)
	SaveService.delete_save(1)

func after_each() -> void:
	SaveService.delete_save(1)

func _ready_output() -> void:
	_inventory.add_item(&"carrot",2)
	assert_true(_service.start(CELL,&"stove_carrot_meal",1).ok)
	_service.advance_day()
	assert_true(_service.can_collect_output(CELL).ok)

func test_all_seven_existing_recipe_outputs_register_and_collect_exactly_their_terms() -> void:
	var shop: MachineShopData = preload("res://data/machine_shop.tres")
	var outputs: Array[StringName] = []
	for id: String in shop.machine_ids:
		var bag: InventoryState = InventoryState.new()
		var owned: MachineInventory = MachineInventory.new()
		owned.add_machine(StringName(id))
		var placements: MachinePlacementState = MachinePlacementState.new()
		placements.configure(preload("res://data/land_parcels.tres"),owned)
		assert_true(placements.place(StringName(id),CELL,0).ok)
		var service: MachineOperationService = MachineOperationService.new()
		service.configure(bag,placements)
		var machine: MachineData = DataRegistry.get_machine(StringName(id))
		for resource: Resource in DataRegistry.get_recipes_for_machine(StringName(id)):
			var recipe: RecipeData = resource as RecipeData
			for input: Dictionary in recipe.input_entries():
				bag.add_item(StringName(input.item_id),int(input.quantity))
			assert_true(service.start(CELL,recipe.recipe_id,maxi(machine.unlock_house_level,recipe.unlock_house_level)).ok)
			for day: int in range(recipe.duration_days):
				service.advance_day()
			var entry: Dictionary = recipe.output_entries()[0]
			var item: ItemData = DataRegistry.get_item(StringName(entry.item_id)) as ItemData
			assert_not_null(item)
			assert_eq(item.category,&"other")
			assert_eq(item.max_stack,99)
			assert_eq(item.buy_price,0)
			assert_eq(item.sell_price,0)
			assert_true(service.collect_output_to_inventory(CELL).ok)
			assert_eq(bag.get_quantity(item.item_id),int(entry.quantity))
			outputs.append(item.item_id)
	assert_eq(outputs.size(),7)
	var paths: Array[String] = ["res://localization/strings_vi.csv","res://localization/strings_en.csv"]
	var keys: PackedStringArray = ["ITEM_PROCESSED_DESCRIPTION"]
	for id: StringName in outputs:
		keys.append(String(DataRegistry.get_item(id).display_name_key))
	assert_true(DataValidator.validate_translation_keys(paths,keys).is_empty())

func test_success_and_duplicate_add_once_without_coins_or_replayed_buffer() -> void:
	_ready_output()
	var wallet: WalletState = WalletState.new(100)
	var funds: Dictionary = wallet.serialize()
	var result: Dictionary = _service.collect_output_to_inventory(CELL)
	assert_true(result.ok)
	assert_eq(result.item_id,&"temp_carrot_meal")
	assert_eq(int(result.quantity),1)
	assert_eq(_inventory.get_quantity(&"temp_carrot_meal"),1)
	assert_eq(_service.get_state(CELL).status,MachineState.STATUS_IDLE)
	var before: Dictionary = _inventory.serialize()
	assert_eq(_service.collect_output_to_inventory(CELL).reason,&"no_output")
	assert_eq(_inventory.serialize(),before)
	assert_true(_service.take_output(CELL).is_empty())
	assert_eq(wallet.serialize(),funds)

func test_full_bag_preserves_every_owner_then_succeeds_after_space_is_freed() -> void:
	_ready_output()
	_inventory.deserialize({"capacity":1,"slots":[{"item_id":"turnip","quantity":1}]})
	var bag: Dictionary = _inventory.serialize()
	var machine: Dictionary = _service.serialize()
	assert_eq(_service.can_collect_output(CELL).reason,&"inventory_full")
	assert_eq(_service.collect_output_to_inventory(CELL).reason,&"inventory_full")
	assert_eq(_inventory.serialize(),bag)
	assert_eq(_service.serialize(),machine)
	_inventory.remove_item(&"turnip",1)
	assert_true(_service.collect_output_to_inventory(CELL).ok)
	assert_eq(_inventory.get_quantity(&"temp_carrot_meal"),1)

func test_existing_stack_exact_capacity_is_used_without_a_second_slot() -> void:
	_ready_output()
	var item: ItemData = DataRegistry.get_item(&"temp_carrot_meal") as ItemData
	_inventory.deserialize({"capacity":1,"slots":[{"item_id":item.item_id,"quantity":item.max_stack-1}]})
	assert_true(_service.collect_output_to_inventory(CELL).ok)
	assert_eq(_inventory.get_slots().size(),1)
	assert_eq(_inventory.get_quantity(item.item_id),item.max_stack)

func test_unknown_item_and_corrupt_registered_terms_leave_buffer_and_bag_unchanged() -> void:
	_ready_output()
	var state: MachineState = _service.get_state(CELL)
	for id: StringName in [&"unregistered_output",&"temp_wheat_flour"]:
		state.output_item_id = id
		var before: Dictionary = state.serialize()
		var bag: Dictionary = _inventory.serialize()
		var result: Dictionary = _service.collect_output_to_inventory(CELL)
		assert_false(result.ok)
		assert_eq(result.reason,&"unknown_item" if id==&"unregistered_output" else &"invalid_state")
		assert_eq(state.serialize(),before)
		assert_eq(_inventory.serialize(),bag)
	state.output_item_id = &"temp_carrot_meal"
	state.output_quantity = 2
	assert_eq(_service.collect_output_to_inventory(CELL).reason,&"invalid_state")
	assert_eq(state.output_quantity,2)

func test_no_output_missing_placement_and_mismatched_machine_are_rejected() -> void:
	assert_eq(_service.collect_output_to_inventory(CELL).reason,&"no_output")
	_inventory.add_item(&"carrot",2)
	_service.start(CELL,&"stove_carrot_meal",1)
	assert_eq(_service.collect_output_to_inventory(CELL).reason,&"no_output")
	_service.advance_day()
	var state: MachineState = _service.get_state(CELL)
	state.machine_id = &"mill"
	assert_eq(_service.collect_output_to_inventory(CELL).reason,&"invalid_state")
	state.machine_id = &"stove"
	_placements.remove(CELL)
	var before: Dictionary = state.serialize()
	assert_eq(_service.collect_output_to_inventory(CELL).reason,&"no_machine")
	assert_eq(state.serialize(),before)

func test_inventory_signal_reentry_cannot_collect_restart_or_extract_again() -> void:
	_ready_output()
	var observed: Array[Dictionary] = []
	_inventory.item_added.connect(func(_id: StringName, _quantity: int) -> void:
		observed.append(_service.collect_output_to_inventory(CELL))
		observed.append(_service.start(CELL,&"stove_carrot_meal",1))
		observed.append(_service.take_output(CELL))
		_service.advance_day()
		assert_eq(_service.get_state(CELL).output_quantity,0)
		assert_eq(_inventory.get_quantity(&"temp_carrot_meal"),1)
	)
	assert_true(_service.collect_output_to_inventory(CELL).ok)
	assert_eq(observed.size(),3)
	assert_eq(observed[0].reason,&"collection_busy")
	assert_eq(observed[1].reason,&"collection_busy")
	assert_true(observed[2].is_empty())
	assert_eq(_inventory.get_quantity(&"temp_carrot_meal"),1)

func test_rejected_addition_restores_both_snapshots_and_releases_guard() -> void:
	_ready_output()
	var reject: RejectingInventory = RejectingInventory.new(4)
	_service.configure(reject,_placements)
	var machine: Dictionary = _service.serialize()
	var bag: Dictionary = reject.serialize()
	assert_eq(_service.collect_output_to_inventory(CELL).reason,&"transfer_failed")
	assert_eq(_service.serialize(),machine)
	assert_eq(reject.serialize(),bag)
	reject.reject = false
	assert_true(_service.collect_output_to_inventory(CELL).ok)
	assert_eq(reject.get_quantity(&"temp_carrot_meal"),1)

func test_save_load_buffer_and_collected_inventory_do_not_replay_payout() -> void:
	_ready_output()
	assert_true(SaveService.save_game({"inventory":_inventory.serialize(),"machine_operations":_service.serialize()},1))
	var payload: Dictionary = SaveService.load_game(1)
	_inventory.deserialize(payload.inventory)
	_service.deserialize(payload.machine_operations)
	assert_true(_service.collect_output_to_inventory(CELL).ok)
	assert_true(SaveService.save_game({"inventory":_inventory.serialize(),"machine_operations":_service.serialize()},1))
	payload = SaveService.load_game(1)
	_inventory.deserialize(payload.inventory)
	_service.deserialize(payload.machine_operations)
	assert_eq(_service.collect_output_to_inventory(CELL).reason,&"no_output")
	assert_eq(_inventory.get_quantity(&"temp_carrot_meal"),1)
	assert_eq(SaveService.CURRENT_VERSION,17)
