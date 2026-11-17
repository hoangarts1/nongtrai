extends GutTest
const CONFIG: BagUpgradeConfig = preload("res://data/bag_upgrade_config.tres")

class RejectInventory extends InventoryState:
	func try_expand_capacity(_expected: int, _target: int) -> bool:
		return false

func _service(inventory: InventoryState, wallet: WalletState, config: BagUpgradeConfig = CONFIG) -> InventoryUpgradeService:
	var service: InventoryUpgradeService = InventoryUpgradeService.new()
	service.configure(config,inventory,wallet)
	return service

func test_shipped_and_invalid_config_integrity_boundaries() -> void:
	assert_true(DataValidator.validate_bag_upgrade_config(CONFIG).is_empty())
	assert_eq(InventoryState.MAX_SAVED_SLOTS,4096)
	assert_eq(CONFIG.MAX_CAPACITY,InventoryState.MAX_SAVED_SLOTS)
	assert_eq(CONFIG.base.default_capacity,40)
	assert_eq(CONFIG.additional_slots,12)
	assert_eq(CONFIG.purchase_price,300)
	assert_false(InventoryUpgradeService.validate_config(null).is_empty())
	for field: String in ["additional_slots","purchase_price"]:
		for value: int in [0,-1]:
			var invalid: BagUpgradeConfig = CONFIG.duplicate() as BagUpgradeConfig
			invalid.set(field,value)
			assert_false(InventoryUpgradeService.validate_config(invalid).is_empty())
	var invalid: BagUpgradeConfig = CONFIG.duplicate() as BagUpgradeConfig
	invalid.additional_slots = 9223372036854775807
	assert_false(InventoryUpgradeService.validate_config(invalid).is_empty())
	invalid.base = CONFIG.base.duplicate() as InventoryConfig
	invalid.base.default_capacity = -9223372036854775807
	assert_false(InventoryUpgradeService.validate_config(invalid).is_empty())
	invalid.base = null
	assert_false(InventoryUpgradeService.validate_config(invalid).is_empty())
	assert_false(InventoryUpgradeService.new().purchase(40).ok)

func test_full_bag_expands_once_preserves_stacks_and_uses_new_slots() -> void:
	var inventory: InventoryState = InventoryState.new()
	var wallet: WalletState = WalletState.new(1000)
	var service: InventoryUpgradeService = _service(inventory,wallet)
	var maximum: int = (DataRegistry.get_item(&"turnip") as ItemData).max_stack
	assert_eq(inventory.add_item(&"turnip",40*maximum),40*maximum)
	assert_false(inventory.can_add_item(&"turnip_seed",1))
	var before: Array[Dictionary] = inventory.get_slots()
	var revision: int = inventory.revision
	var quote: Dictionary = service.can_purchase(40)
	assert_true(quote.ok)
	assert_eq(quote.target,52)
	assert_eq(inventory.get_slots(),before)
	assert_eq(inventory.revision,revision)
	assert_eq(wallet.get_coins(),1000)
	watch_signals(inventory)
	assert_true(service.purchase(40).ok)
	assert_eq(inventory.capacity,52)
	assert_eq(wallet.get_coins(),700)
	assert_eq(inventory.get_slots(),before)
	assert_eq(inventory.revision,revision+1)
	assert_signal_emit_count(inventory,&"inventory_changed",1)
	assert_false(service.purchase(40).ok)
	assert_eq(service.purchase(52).reason,&"already_upgraded")
	assert_eq(wallet.get_coins(),700)
	var seed_maximum: int = (DataRegistry.get_item(&"turnip_seed") as ItemData).max_stack
	assert_eq(inventory.add_item(&"turnip_seed",12*seed_maximum),12*seed_maximum)
	assert_eq(inventory.get_slots().size(),52)
	assert_false(inventory.can_add_item(&"turnip_seed",1))
	inventory.clear()
	assert_eq(inventory.capacity,52,"Ordinary clear retains an upgrade")
	var loaded: InventoryState = InventoryState.new()
	loaded.deserialize(JSON.parse_string(JSON.stringify(inventory.serialize())))
	assert_eq(loaded.capacity,52)

func test_insufficient_stale_invalid_and_larger_legacy_bags_never_pay_or_shrink() -> void:
	var inventory: InventoryState = InventoryState.new()
	var wallet: WalletState = WalletState.new(299)
	var service: InventoryUpgradeService = _service(inventory,wallet)
	assert_eq(service.purchase(40).reason,&"insufficient_coins")
	wallet.add_coins(1,&"test")
	assert_eq(service.purchase(39).reason,&"stale_capacity")
	for target: int in [-1,0,40,4097,9223372036854775807]:
		assert_false(inventory.try_expand_capacity(40,target))
	assert_false(inventory.try_expand_capacity(39,52))
	assert_eq(inventory.capacity,40)
	assert_eq(wallet.get_coins(),300)
	inventory.deserialize({"capacity":60,"slots":[{"item_id":"turnip","quantity":2}]})
	var before: Dictionary = inventory.serialize()
	assert_eq(service.purchase(60).reason,&"already_upgraded")
	assert_eq(inventory.serialize(),before)
	assert_eq(wallet.get_coins(),300)
	inventory.deserialize({"capacity":45,"slots":[]})
	assert_eq(service.can_purchase(45).target,52)
	assert_true(service.purchase(45).ok)
	assert_eq(inventory.capacity,52)

func test_rejected_expansion_and_changed_quote_refund_only_their_debit() -> void:
	var inventory: RejectInventory = RejectInventory.new()
	var wallet: WalletState = WalletState.new(1000)
	var ledger: DayLedgerState = DayLedgerState.new()
	var journal: Callable = func(_total: int, delta: int, reason: StringName) -> void: ledger.record(delta,reason)
	wallet.coins_changed.connect(journal)
	assert_eq(_service(inventory,wallet).purchase(40).reason,&"grant_rejected")
	wallet.coins_changed.disconnect(journal)
	assert_eq(wallet.get_coins(),1000)
	assert_eq(inventory.capacity,40)
	assert_eq(ledger.totals(),{"income":0,"expense":0,"profit":0})
	var config: BagUpgradeConfig = CONFIG.duplicate() as BagUpgradeConfig
	var normal: InventoryState = InventoryState.new()
	var callback: Callable = func(_total: int, _delta: int, reason: StringName) -> void:
		if reason==&"buy_bag_upgrade":
			config.purchase_price += 1
			normal.add_item(&"turnip",2)
	wallet.coins_changed.connect(callback)
	assert_eq(_service(normal,wallet,config).purchase(40).reason,&"grant_rejected")
	wallet.coins_changed.disconnect(callback)
	assert_eq(wallet.get_coins(),1000)
	assert_eq(normal.capacity,40)
	assert_eq(normal.get_quantity(&"turnip"),2,"Independent item callbacks are not overwritten by refund")

func test_reentry_independent_purchase_and_callback_context_reconfiguration() -> void:
	var inventory: InventoryState = InventoryState.new()
	var wallet: WalletState = WalletState.new(1000)
	var service: InventoryUpgradeService = _service(inventory,wallet)
	var replies: Array[StringName] = []
	var callback: Callable = func(_total: int, _delta: int, reason: StringName) -> void:
		if reason==&"buy_bag_upgrade":
			replies.append(service.purchase(40).reason)
			inventory.add_item(&"turnip",1)
	wallet.coins_changed.connect(callback)
	assert_true(service.purchase(40).ok)
	wallet.coins_changed.disconnect(callback)
	assert_eq(replies,[&"purchase_busy"])
	assert_eq(wallet.get_coins(),700)
	assert_eq(inventory.get_quantity(&"turnip"),1)
	inventory.deserialize({"capacity":40,"slots":[]})
	wallet.deserialize({"coins":1000})
	var other: InventoryUpgradeService = _service(inventory,wallet)
	var once: Array[bool] = [false]
	callback = func(_total: int, _delta: int, reason: StringName) -> void:
		if reason==&"buy_bag_upgrade" and not once[0]:
			once[0] = true
			other.purchase(40)
	wallet.coins_changed.connect(callback)
	assert_eq(service.purchase(40).reason,&"grant_rejected")
	wallet.coins_changed.disconnect(callback)
	assert_eq(inventory.capacity,52)
	assert_eq(wallet.get_coins(),700,"One independent success remains; outer debit alone is refunded")
	inventory.deserialize({"capacity":40,"slots":[]})
	var separate: InventoryState = InventoryState.new()
	var separate_wallet: WalletState = WalletState.new(70)
	callback = func(_total: int, _delta: int, reason: StringName) -> void:
		if reason==&"buy_bag_upgrade":
			service.configure(CONFIG,separate,separate_wallet)
	wallet.coins_changed.connect(callback)
	assert_true(service.purchase(40).ok)
	wallet.coins_changed.disconnect(callback)
	assert_eq(inventory.capacity,52)
	assert_eq(wallet.get_coins(),400)
	assert_eq(separate.capacity,40)
	assert_eq(separate_wallet.get_coins(),70)
