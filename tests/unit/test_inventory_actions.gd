extends GutTest

func test_default_capacity_and_full_stack_boundaries() -> void:
	assert_true(DataValidator.validate_inventory_config(InventoryState.CONFIG).is_empty())
	assert_false(DataValidator.validate_inventory_config(InventoryConfig.new()).is_empty())
	var inventory: InventoryState = InventoryState.new()
	assert_eq(inventory.capacity,40)
	assert_eq(InventoryState.new(2).capacity,2)
	var item: ItemData = DataRegistry.get_item(&"turnip") as ItemData
	assert_eq(inventory.add_item(&"turnip",40*item.max_stack),40*item.max_stack)
	assert_false(inventory.can_add_item(&"turnip",1))
	assert_eq(inventory.add_item(&"turnip_seed",1),0)
	assert_eq(inventory.get_slots().size(),40)

func test_stable_sort_preserves_individual_stacks_and_reports_mapping() -> void:
	var inventory: InventoryState = InventoryState.new()
	inventory.deserialize({"slots":[{"item_id":"turnip","quantity":2},{"item_id":"turnip_seed","quantity":7},{"item_id":"turnip","quantity":3},{"item_id":"spring_carrot_seed","quantity":4}]})
	var before: Array[Dictionary] = inventory.get_slots()
	var order: Array[int] = InventoryActions.sort(inventory)
	assert_eq(order,[3,1,0,2])
	for index: int in range(order.size()):
		assert_eq(inventory.get_slots()[index],before[order[index]])
	assert_eq(InventoryActions.sort(inventory),[0,1,2,3],"Repeated sorting is stable")

func test_discard_guards_exact_stack_revision_quantity_and_emits_once() -> void:
	var inventory: InventoryState = InventoryState.new()
	inventory.deserialize({"slots":[{"item_id":"turnip","quantity":7},{"item_id":"turnip","quantity":3}]})
	var revision: int = inventory.revision
	watch_signals(inventory)
	for quantity: int in [-1,0,8]:
		assert_false(InventoryActions.discard(inventory,0,&"turnip",7,revision,quantity))
	assert_false(InventoryActions.discard(inventory,0,&"turnip_seed",7,revision,1))
	assert_false(InventoryActions.discard(inventory,0,&"turnip",6,revision,1))
	assert_true(InventoryActions.discard(inventory,0,&"turnip",7,revision,2))
	assert_eq(inventory.get_slots()[0]["quantity"],5)
	assert_eq(inventory.get_slots()[1]["quantity"],3)
	assert_false(InventoryActions.discard(inventory,0,&"turnip",7,revision,2),"Repeated stale confirmation is harmless")
	assert_signal_emit_count(inventory,"item_removed",1)
	assert_signal_emit_count(inventory,"inventory_changed",1)
	assert_true(InventoryActions.discard(inventory,0,&"turnip",5,inventory.revision,5))
	assert_eq(inventory.get_slots(),[{"item_id":&"turnip","quantity":3}])

func test_restore_preserves_valid_contents_beyond_declared_capacity_and_stack_limit() -> void:
	var inventory: InventoryState = InventoryState.new()
	inventory.deserialize({"capacity":1,"slots":[{"item_id":"turnip","quantity":100},{"item_id":"turnip_seed","quantity":6}]})
	assert_eq(inventory.capacity,2)
	assert_eq(inventory.get_quantity(&"turnip"),100)
	assert_true(inventory.can_add_item(&"turnip_seed",1),"Oversized legacy stack must not subtract another stack's room")
	assert_eq(inventory.add_item(&"turnip_seed",1),1)
	var snapshot: Dictionary = inventory.serialize()
	inventory.deserialize({"capacity":-8,"slots":"broken"})
	assert_eq(inventory.serialize(),snapshot)
	inventory.deserialize({"slots":[null,{"item_id":"unknown","quantity":1},{"item_id":"turnip","quantity":1.5},{"item_id":"turnip_seed","quantity":6}]})
	assert_eq(inventory.get_slots(),[{"item_id":&"turnip_seed","quantity":6}])

func test_all_old_migrations_and_v6_round_trip_preserve_contents() -> void:
	for version: int in range(1,6):
		var original: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v%d.json" % version))
		var migrated: Dictionary = SaveService._migrate(original,version)
		assert_eq(int(migrated["meta"]["save_version"]),16)
		assert_eq(migrated["inventory"]["slots"],original["inventory"]["slots"])
		assert_gte(int(migrated["inventory"]["capacity"]),40)
		if version==5:
			assert_eq(migrated["day_ledger"],original["day_ledger"])
			assert_eq(migrated["day_end"],original["day_end"])
	var larger: Dictionary = {"inventory":{"capacity":60,"slots":[]}}
	assert_eq(SaveService.migrate_5_to_6(larger)["inventory"]["capacity"],60)
	assert_eq(larger["inventory"]["capacity"],60)
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v6.json"))
	var restored: InventoryState = InventoryState.new()
	restored.deserialize(golden["inventory"])
	assert_eq(restored.capacity,40)
	assert_eq(JSON.parse_string(JSON.stringify(restored.serialize()))["slots"],golden["inventory"]["slots"])
