extends GutTest

class RejectingBag:
	extends InventoryState
	func add_item(_id: StringName, _quantity: int) -> int: return 0

class PartialBag:
	extends InventoryState
	func add_item(id: StringName, quantity: int) -> int: return super.add_item(id,mini(1,quantity))

func test_exact_integer_totals_reject_overflow_negative_and_zero_prices() -> void:
	assert_eq(EconomyService.total(1,EconomyService.MAX_AMOUNT),EconomyService.MAX_AMOUNT)
	assert_eq(EconomyService.total(EconomyService.MAX_AMOUNT,1),EconomyService.MAX_AMOUNT)
	for terms: Array in [[0,1],[1,0],[-1,2],[1,-1],[EconomyService.MAX_AMOUNT,2],[2,EconomyService.MAX_AMOUNT]]:
		assert_eq(EconomyService.total(terms[0],terms[1]),-1)

func test_credit_debit_require_reasons_and_prevent_negative_or_unsafe_wallet() -> void:
	var wallet: WalletState = WalletState.new(100)
	assert_false(EconomyService.debit(wallet,1,&""))
	assert_false(EconomyService.credit(wallet,1,&""))
	assert_false(EconomyService.debit(wallet,-1,&"test"))
	assert_false(EconomyService.credit(wallet,-1,&"test"))
	assert_false(EconomyService.debit(wallet,101,&"test"))
	assert_true(EconomyService.debit(wallet,40,&"test_debit"))
	assert_true(EconomyService.credit(wallet,20,&"test_credit"))
	assert_eq(wallet.serialize(),{"coins":80})
	wallet = WalletState.new(EconomyService.MAX_AMOUNT)
	assert_false(EconomyService.credit(wallet,1,&"test_overflow"))
	assert_eq(wallet.get_coins(),EconomyService.MAX_AMOUNT)
	assert_false(EconomyService.is_busy(wallet))

func test_currency_notification_cannot_reenter_through_another_service_call() -> void:
	var wallet: WalletState = WalletState.new(100)
	var attempts: Array[bool] = []
	var observer: Callable = func(_coins: int, _delta: int, _reason: StringName) -> void:
		attempts.append(EconomyService.is_busy(wallet))
		attempts.append(EconomyService.credit(wallet,100,&"reentry"))
		attempts.append(EconomyService.debit(wallet,1,&"reentry"))
	wallet.coins_changed.connect(observer)
	assert_true(EconomyService.debit(wallet,20,&"first"))
	wallet.coins_changed.disconnect(observer)
	assert_eq(attempts,[true,false,false])
	assert_eq(wallet.get_coins(),80)
	assert_false(EconomyService.is_busy(wallet))

func test_real_trade_prices_and_bag_coin_conservation() -> void:
	var wallet: WalletState = WalletState.new(500)
	var bag: InventoryState = InventoryState.new(2)
	var item: ItemData = DataRegistry.get_item(&"turnip_seed") as ItemData
	var bought: Dictionary = EconomyService.buy(wallet,bag,item.item_id,2,item.buy_price,&"buy_seed")
	assert_true(bought.ok)
	assert_eq(bag.get_quantity(item.item_id),2)
	assert_eq(wallet.get_coins(),500-item.buy_price*2)
	assert_true(EconomyService.sell(wallet,bag,item.item_id,1,item.sell_price,&"sell_produce").ok)
	assert_eq(bag.get_quantity(item.item_id),1)
	assert_eq(wallet.get_coins(),500-item.buy_price*2+item.sell_price)
	assert_false(InventoryService.is_busy(bag))
	assert_false(EconomyService.is_busy(wallet))

func test_full_shortage_and_unsafe_sales_leave_both_owners_unchanged() -> void:
	var wallet: WalletState = WalletState.new(100)
	var bag: InventoryState = InventoryState.new(1)
	bag.add_item(&"turnip",99)
	var before: Dictionary = bag.serialize()
	assert_false(EconomyService.buy(wallet,bag,&"turnip_seed",1,10,&"buy_seed").ok)
	assert_false(EconomyService.sell(wallet,bag,&"turnip",100,10,&"sell_produce").ok)
	assert_false(EconomyService.sell(wallet,bag,&"turnip",1,0,&"sell_produce").ok)
	wallet = WalletState.new(EconomyService.MAX_AMOUNT)
	assert_false(EconomyService.sell(wallet,bag,&"turnip",1,10,&"sell_produce").ok)
	assert_eq(bag.serialize(),before)
	assert_eq(wallet.get_coins(),EconomyService.MAX_AMOUNT)

func test_rejected_and_partial_adds_undo_only_our_items_and_refund_full_price() -> void:
	for bag: InventoryState in [RejectingBag.new(),PartialBag.new()]:
		var wallet: WalletState = WalletState.new(100)
		var before: Dictionary = bag.serialize()
		assert_false(EconomyService.buy(wallet,bag,&"turnip_seed",2,10,&"buy_seed").ok)
		assert_eq(wallet.get_coins(),100)
		assert_eq(bag.serialize(),before)
		assert_false(InventoryService.is_busy(bag))
		assert_false(EconomyService.is_busy(wallet))

func test_trade_holds_both_owners_for_cross_service_callbacks() -> void:
	var wallet: WalletState = WalletState.new(100)
	var bag: InventoryState = InventoryState.new()
	var attempts: Array[bool] = []
	var observer: Callable = func(_coins: int, _delta: int, _reason: StringName) -> void:
		attempts.append(EconomyService.buy(wallet,bag,&"turnip_seed",1,1,&"reentry").ok)
		attempts.append(InventoryService.clear(bag,&"test_reentry"))
		attempts.append(InventoryService.remove(bag,&"turnip_seed",1,&"test_reentry"))
	wallet.coins_changed.connect(observer)
	assert_true(EconomyService.buy(wallet,bag,&"turnip_seed",2,10,&"buy_seed").ok)
	wallet.coins_changed.disconnect(observer)
	assert_eq(attempts,[false,false,false])
	assert_eq(bag.get_quantity(&"turnip_seed"),2)
	assert_eq(wallet.get_coins(),80)

func test_legacy_independent_primitives_nest_but_cannot_bypass_a_paired_trade() -> void:
	var wallet: WalletState = WalletState.new(1000)
	var once: Array[bool] = [false]
	var attempts: Array[bool] = []
	var observer: Callable = func(_coins: int, _delta: int, _reason: StringName) -> void:
		if once[0]: return
		once[0] = true
		attempts.append(EconomyService.debit(wallet,300,&"independent",true))
	wallet.coins_changed.connect(observer)
	assert_true(EconomyService.debit(wallet,300,&"legacy_outer",true))
	wallet.coins_changed.disconnect(observer)
	assert_eq(attempts,[true])
	assert_eq(wallet.get_coins(),400)
	assert_false(EconomyService.is_busy(wallet))
	once[0] = false
	attempts.clear()
	var bag: InventoryState = InventoryState.new()
	wallet.coins_changed.connect(observer)
	assert_true(EconomyService.buy(wallet,bag,&"turnip_seed",1,10,&"buy_seed").ok)
	wallet.coins_changed.disconnect(observer)
	assert_eq(attempts,[false])
	assert_eq(wallet.get_coins(),390)
	assert_eq(bag.get_quantity(&"turnip_seed"),1)
