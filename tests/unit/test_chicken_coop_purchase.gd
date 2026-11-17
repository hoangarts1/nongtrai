extends GutTest
const CONFIG: ChickenCoopSiteConfig = preload("res://data/chicken_coop_site.tres")
var holding: ChickenCoopHoldingState
var bag: InventoryState
var wallet: WalletState
var shop: ChickenCoopShopService
var occupied: Array[Vector2i] = []

func before_each() -> void:
	holding = ChickenCoopHoldingState.new()
	holding.configure(CONFIG.coop_config,0)
	bag = InventoryState.new(2)
	wallet = WalletState.new(1000)
	shop = ChickenCoopShopService.new()
	shop.configure(CONFIG,holding,bag,wallet)
	occupied.clear()

func cells() -> Array[Vector2i]:
	return occupied

func test_data_geometry_bundle_and_once_only_purchase() -> void:
	assert_eq(CONFIG.validation_errors(),PackedStringArray())
	assert_eq(CONFIG.purchase_price,700)
	assert_eq(CONFIG.initial_hens,4)
	assert_true(CONFIG.reserved_cells().has(CONFIG.entrance))
	var before: Dictionary = holding.serialize()
	assert_true(shop.quote(&"buy_coop",4,cells()).ok)
	assert_eq(holding.serialize(),before)
	assert_true(shop.purchase(&"buy_coop",4,cells).ok)
	assert_true(holding.is_owned())
	assert_eq(int(holding.coop.serialize().hen_count),4)
	assert_eq(wallet.get_coins(),300)
	assert_false(shop.purchase(&"buy_coop",4,cells).ok)
	assert_eq(wallet.get_coins(),300)

func test_unaffordable_occupied_invalid_and_unowned_feed_preserve_all() -> void:
	wallet.deserialize({"coins":699})
	for action: StringName in [&"buy_coop",&"buy_feed",&"unknown"]:
		var before: Dictionary = {"coop":holding.serialize(),"bag":bag.serialize(),"coins":wallet.serialize()}
		assert_false(shop.purchase(action,4,cells).ok)
		assert_eq({"coop":holding.serialize(),"bag":bag.serialize(),"coins":wallet.serialize()},before)
	wallet.add_coins(100)
	occupied.append(CONFIG.footprint.position)
	assert_eq(shop.purchase(&"buy_coop",4,cells).reason,&"occupied")
	assert_false(holding.is_owned())

func test_food_whole_price_stock_capacity_and_quantities() -> void:
	shop.purchase(&"buy_coop",4,cells)
	assert_true(shop.purchase(&"buy_feed",4,cells).ok)
	assert_eq(bag.get_quantity(&"chicken_feed"),4)
	assert_eq(wallet.get_coins(),220)
	for quantity: int in [0,-1,100]:
		assert_false(shop.purchase(&"buy_feed",quantity,cells).ok)
	bag.deserialize({"capacity":1,"slots":[{"item_id":"egg","quantity":99}]})
	var before: Dictionary = {"bag":bag.serialize(),"wallet":wallet.serialize()}
	assert_eq(shop.purchase(&"buy_feed",1,cells).reason,&"inventory_full")
	assert_eq({"bag":bag.serialize(),"wallet":wallet.serialize()},before)

func test_captured_owners_and_occupancy_refund_preserve_independent_gifts() -> void:
	wallet.coins_changed.connect(func(_total: int,delta: int,reason: StringName) -> void:
		if delta<0 and reason==&"buy_chicken_coop":
			occupied.append(CONFIG.footprint.position)
			wallet.add_coins(17,&"gift")
			bag.add_item(&"egg",2)
			assert_false(shop.purchase(&"buy_coop",4,cells).ok)
			assert_false(holding.coop.advance_day(0).ok)
			assert_false(holding.coop.feed(0,1).ok)
	)
	assert_false(shop.purchase(&"buy_coop",4,cells).ok)
	assert_eq(wallet.get_coins(),1017)
	assert_eq(bag.get_quantity(&"egg"),2)
	assert_false(holding.is_owned())
	assert_false(holding.coop.is_busy())

func test_food_refund_when_callback_fills_bag_and_ledger_net() -> void:
	shop.purchase(&"buy_coop",4,cells)
	bag.deserialize({"capacity":1,"slots":[]})
	var ledger: DayLedgerState = DayLedgerState.new()
	ledger.reset(0)
	wallet.coins_changed.connect(func(_t: int,delta: int,reason: StringName) -> void:
		ledger.record(delta,reason)
		if reason==&"buy_chicken_feed":
			bag.add_item(&"egg",99)
	)
	assert_false(shop.purchase(&"buy_feed",4,cells).ok)
	assert_eq(wallet.get_coins(),300)
	assert_eq(bag.get_quantity(&"chicken_feed"),0)
	assert_eq(bag.get_quantity(&"egg"),99)
	assert_eq(ledger.totals(),{"income":0,"expense":0,"profit":0})
	assert_false(holding.coop.is_busy())

func test_source_token_and_json_roundtrip_keep_same_inner_owner() -> void:
	assert_false(holding.begin_purchase(0).ok)
	var owner: ChickenCoopState = holding.coop
	var reserved: Dictionary = holding.begin_purchase(4)
	assert_false(holding.finish_purchase(RefCounted.new(),true))
	holding.configure(CONFIG.coop_config,8)
	holding.deserialize({})
	assert_true(holding.coop.is_busy())
	assert_true(holding.finish_purchase(reserved.token,true))
	assert_false(holding.finish_purchase(reserved.token,true))
	assert_true(holding.coop==owner)
	var copy: ChickenCoopHoldingState = ChickenCoopHoldingState.new()
	copy.configure(CONFIG.coop_config,0)
	copy.deserialize(JSON.parse_string(JSON.stringify(holding.serialize())))
	assert_eq(copy.serialize(),holding.serialize())

func test_reconfigured_facade_settles_captured_owners_only() -> void:
	var other: ChickenCoopHoldingState = ChickenCoopHoldingState.new()
	other.configure(CONFIG.coop_config,0)
	var other_bag: InventoryState = InventoryState.new()
	var other_wallet: WalletState = WalletState.new(2000)
	wallet.coins_changed.connect(func(_t: int,delta: int,_reason: StringName) -> void:
		if delta<0:
			shop.configure(CONFIG,other,other_bag,other_wallet)
	)
	assert_true(shop.purchase(&"buy_coop",4,cells).ok)
	assert_true(holding.is_owned())
	assert_false(other.is_owned())
	assert_eq(wallet.get_coins(),300)
	assert_eq(other_wallet.get_coins(),2000)
	assert_false(holding.coop.is_busy())

func test_changed_price_or_geometry_refunds_and_never_grants_moved_site() -> void:
	for field: String in ["purchase_price","footprint"]:
		var config: ChickenCoopSiteConfig = CONFIG.duplicate() as ChickenCoopSiteConfig
		var local: ChickenCoopShopService = ChickenCoopShopService.new()
		local.configure(config,holding,bag,wallet)
		var listener: Callable = func(_t: int,delta: int,_reason: StringName) -> void:
			if delta<0:
				if field=="purchase_price":
					config.purchase_price += 1
				else:
					config.footprint = Rect2i(13,16,2,2)
		wallet.coins_changed.connect(listener)
		assert_false(local.purchase(&"buy_coop",4,cells).ok)
		assert_false(holding.is_owned())
		assert_eq(wallet.get_coins(),1000)
		assert_false(holding.coop.is_busy())
		wallet.coins_changed.disconnect(listener)
