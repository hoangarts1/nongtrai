extends GutTest
const CONFIG: LandExpansionConfig = preload("res://data/land_expansion_config.tres")
const FIRST: StringName = &"farm_east_1"
const SECOND: StringName = &"test_second"
var _config: LandExpansionConfig
var _state: LandOwnershipState
var _wallet: WalletState
var _service: LandExpansionService
var _watches: Array[Dictionary] = []
class RejectingState extends LandOwnershipState:
	var reject: bool = true
	func grant_next(parcel_id: StringName) -> bool:
		return false if reject else super.grant_next(parcel_id)

func before_each() -> void:
	_config = _copy_config()
	_state = LandOwnershipState.new()
	_state.configure(_config)
	_wallet = WalletState.new(2000)
	_service = LandExpansionService.new()
	_service.configure(_config,_state,_wallet)

func after_each() -> void:
	for watch: Dictionary in _watches:
		var wallet: WalletState = watch.wallet
		var callback: Callable = watch.callback
		wallet.coins_changed.disconnect(callback)
	_watches.clear()

func _watch(wallet: WalletState, callback: Callable) -> void:
	_watches.append({"wallet":wallet,"callback":callback})
	wallet.coins_changed.connect(callback)

func _copy_config() -> LandExpansionConfig:
	var cfg: LandExpansionConfig = CONFIG.duplicate() as LandExpansionConfig
	var parcels: Array[ExpansionParcelData] = []
	for parcel: ExpansionParcelData in CONFIG.parcels:
		parcels.append(parcel.duplicate() as ExpansionParcelData)
	cfg.parcels = parcels
	return cfg

func _snapshot() -> Dictionary:
	return {"land":_state.serialize(),"wallet":_wallet.serialize(),"clock":GameClock.serialize()}

func _add_second() -> void:
	var parcel: ExpansionParcelData = ExpansionParcelData.new()
	parcel.parcel_id = SECOND
	parcel.region = Rect2i(0,6,2,1)
	_config.parcels.append(parcel)

func test_shipped_data_integer_formula_rounding_and_overflow_fail_closed() -> void:
	assert_eq(DataValidator.validate_land_expansion_config(CONFIG),PackedStringArray())
	assert_eq(CONFIG.parcels[0].region,Rect2i(6,0,6,6))
	var prices: Array[int] = [500,1100,2400,5300,11700]
	for index: int in range(prices.size()):
		var quote: Dictionary = LandExpansionRules.quote_cost(_config,index+1)
		assert_true(quote.ok)
		assert_true(quote.price is int)
		assert_eq(quote.price,prices[index])
	assert_false(LandExpansionRules.quote_cost(_config,0).ok)
	assert_false(LandExpansionRules.quote_cost(_config,-1).ok)
	assert_false(LandExpansionRules.quote_cost(null,1).ok)
	assert_eq(LandExpansionRules.quote_cost(_config,LandExpansionRules.MAX_INTEGER).reason,&"cost_overflow")
	_config.base_cost = 525
	assert_eq(LandExpansionRules.quote_cost(_config,1).price,550,"Positive half-step rounds upward without floats")
	_config.base_cost = LandExpansionRules.MAX_INTEGER
	_config.rounding_step = 2
	assert_false(LandExpansionRules.quote_cost(_config,1).ok,"Rounding itself must not overflow")
	assert_eq(LandExpansionRules.quote_cost(_config,2).reason,&"cost_overflow")

func test_bad_regions_catalog_context_and_prices_fail_validation_and_unlock_nothing() -> void:
	assert_false(LandExpansionRules.validate(null).is_empty())
	var invalids: Array[LandExpansionConfig] = []
	for region: Rect2i in [Rect2i(0,0,1,1),Rect2i(6,0,0,6),Rect2i(6,0,-1,6),Rect2i(CONFIG.world.player_region.end,Vector2i(2,2)),Rect2i(9,9,2,2),Rect2i(99,0,1,1)]:
		var cfg: LandExpansionConfig = _copy_config()
		cfg.parcels[0].region = region
		invalids.append(cfg)
	for field: StringName in [&"base_cost",&"growth_numerator",&"growth_denominator",&"rounding_step"]:
		var cfg: LandExpansionConfig = _copy_config()
		cfg.set(field,0)
		invalids.append(cfg)
	for id: StringName in [&"",&"Bad Id",&"a-b",&"1_bad"]:
		var empty_id: LandExpansionConfig = _copy_config()
		empty_id.parcels[0].parcel_id = id
		invalids.append(empty_id)
	var duplicate: LandExpansionConfig = _copy_config()
	duplicate.parcels.append(duplicate.parcels[0])
	invalids.append(duplicate)
	var missing: LandExpansionConfig = _copy_config()
	missing.parcels.append(null)
	invalids.append(missing)
	var context: LandExpansionConfig = _copy_config()
	context.world = null
	invalids.append(context)
	var zero_quote: LandExpansionConfig = _copy_config()
	zero_quote.base_cost = 1
	invalids.append(zero_quote)
	for cfg: LandExpansionConfig in invalids:
		assert_false(DataValidator.validate_land_expansion_config(cfg).is_empty())
		_state.configure(cfg)
		_service.configure(cfg,_state,_wallet)
		var before: Dictionary = _snapshot()
		assert_false(_state.can_use_cell(Vector2i.ZERO))
		assert_false(_state.grant_next(FIRST))
		assert_false(_service.purchase(FIRST).ok)
		assert_eq(_snapshot(),before)

func test_preview_is_readonly_and_exactly_one_purchase_unlocks_only_configured_cells() -> void:
	var events: Array[StringName] = []
	_watch(_wallet,func(_coins: int, _delta: int, reason: StringName) -> void: events.append(reason))
	var before: Dictionary = _snapshot()
	assert_eq(_state.next_parcel_id(),FIRST)
	assert_eq(_service.can_purchase(FIRST).price,500)
	assert_eq(_snapshot(),before)
	assert_true(events.is_empty())
	for y: int in range(6):
		for x: int in range(6):
			assert_true(_state.can_use_cell(Vector2i(x,y)))
			assert_false(_state.can_use_cell(Vector2i(x+6,y)))
	var result: Dictionary = _service.purchase(FIRST)
	assert_eq(result,{"ok":true,"reason":&"purchased","parcel_id":FIRST,"price":500})
	assert_eq(_wallet.get_coins(),1500)
	assert_eq(events,[&"buy_land"])
	for y: int in range(6):
		for x: int in range(6,12):
			assert_true(_state.can_use_cell(Vector2i(x,y)))
	for cell: Vector2i in [Vector2i(-1,0),Vector2i(12,0),Vector2i(6,6),Vector2i(99,99)]:
		assert_false(_state.can_use_cell(cell))
	var ids: Array[StringName] = _state.get_owned_ids()
	ids.clear()
	assert_eq(_state.get_owned_ids(),[FIRST],"Ownership queries are detached")
	before = _snapshot()
	assert_eq(_service.purchase(FIRST).reason,&"already_owned")
	assert_eq(_snapshot(),before)

func test_order_missing_service_insufficient_and_changed_quotes_never_charge_stale_price() -> void:
	var empty: LandExpansionService = LandExpansionService.new()
	assert_eq(empty.purchase(FIRST).reason,&"invalid_service")
	_add_second()
	var before: Dictionary = _snapshot()
	for id: StringName in [&"unknown",SECOND,&""]:
		assert_false(_service.purchase(id).ok)
		assert_eq(_snapshot(),before)
	_wallet = WalletState.new(499)
	_service.configure(_config,_state,_wallet)
	before = _snapshot()
	assert_eq(_service.purchase(FIRST).reason,&"insufficient_coins")
	assert_eq(_snapshot(),before)
	_wallet = WalletState.new(2000)
	_service.configure(_config,_state,_wallet)
	assert_eq(_service.can_purchase(FIRST).price,500)
	_config.base_cost = 550
	assert_eq(_service.purchase(FIRST).price,550)
	assert_eq(_wallet.get_coins(),1450)
	assert_eq(_service.can_purchase(SECOND).price,1200)
	assert_true(_service.purchase(SECOND).ok)
	assert_eq(_wallet.get_coins(),250)
	assert_eq(_service.purchase(&"other").reason,&"no_available_parcel")

func test_grant_rejection_refunds_only_the_debit_and_retry_is_safe() -> void:
	var rejecting: RejectingState = RejectingState.new()
	rejecting.configure(_config)
	_state = rejecting
	_service.configure(_config,_state,_wallet)
	var before: Dictionary = _snapshot()
	var reasons: Array[StringName] = []
	_watch(_wallet,func(_coins: int, _delta: int, reason: StringName) -> void: reasons.append(reason))
	assert_eq(_service.purchase(FIRST).reason,&"grant_rejected")
	assert_eq(_snapshot(),before)
	assert_eq(reasons,[&"buy_land",&"buy_land_rollback"])
	rejecting.reject = false
	assert_true(_service.purchase(FIRST).ok)
	assert_eq(_wallet.get_coins(),1500)

func test_reentry_is_guarded_and_independent_callback_purchase_is_preserved() -> void:
	var observed: Array[StringName] = []
	_watch(_wallet,func(_coins: int, _delta: int, reason: StringName) -> void:
		if reason==&"buy_land":
			observed.append(StringName(_service.purchase(FIRST).reason))
			observed.append(StringName(_service.can_purchase(FIRST).reason))
	)
	assert_true(_service.purchase(FIRST).ok)
	assert_eq(observed,[&"purchase_busy",&"purchase_busy"])
	_state.configure(_config)
	_wallet = WalletState.new(2000)
	_service.configure(_config,_state,_wallet)
	var other: LandExpansionService = LandExpansionService.new()
	other.configure(_config,_state,_wallet)
	var once: Array[bool] = [false]
	var nested: Array[Dictionary] = []
	_watch(_wallet,func(_coins: int, _delta: int, reason: StringName) -> void:
		if reason==&"buy_land" and not once[0]:
			once[0] = true
			nested.append(other.purchase(FIRST))
	)
	assert_eq(_service.purchase(FIRST).reason,&"grant_rejected")
	assert_true(nested[0].ok)
	assert_eq(_state.get_owned_ids(),[FIRST],"Refund cannot erase a separate completed grant")
	assert_eq(_wallet.get_coins(),1500,"Exactly one successful purchase was charged")

func test_live_config_change_refunds_and_callback_reconfiguration_cannot_redirect_money() -> void:
	_watch(_wallet,func(_coins: int, _delta: int, reason: StringName) -> void:
		if reason==&"buy_land":
			_config.base_cost = 1000
	)
	assert_eq(_service.purchase(FIRST).reason,&"grant_rejected")
	assert_eq(_wallet.get_coins(),2000)
	assert_true(_state.get_owned_ids().is_empty())
	_wallet = WalletState.new(2000)
	_config.base_cost = 500
	_service.configure(_config,_state,_wallet)
	var next_state: LandOwnershipState = LandOwnershipState.new()
	next_state.configure(_config)
	var next_wallet: WalletState = WalletState.new(700)
	_watch(_wallet,func(_coins: int, _delta: int, reason: StringName) -> void:
		if reason==&"buy_land":
			_service.configure(_config,next_state,next_wallet)
	)
	assert_true(_service.purchase(FIRST).ok)
	assert_eq(_wallet.get_coins(),1500)
	assert_eq(_state.get_owned_ids(),[FIRST])
	assert_eq(next_wallet.get_coins(),700)
	assert_true(next_state.get_owned_ids().is_empty())
	assert_true(_service.can_purchase(FIRST).ok)

func test_json_roundtrip_and_corrupt_grants_restore_only_known_ordered_prefix() -> void:
	_add_second()
	assert_true(_service.purchase(FIRST).ok)
	var saved: Dictionary = _state.serialize()
	var json: Variant = JSON.parse_string(JSON.stringify(saved))
	var restored: LandOwnershipState = LandOwnershipState.new()
	restored.configure(_config)
	restored.deserialize(json as Dictionary)
	assert_eq(restored.serialize(),saved)
	assert_true(restored.can_use_cell(Vector2i(11,5)))
	assert_false(restored.can_use_cell(Vector2i(0,6)))
	for raw: Variant in [null,4,"farm_east_1",{"id":FIRST}]:
		restored.deserialize({"owned_parcels":raw})
		assert_true(restored.get_owned_ids().is_empty())
	restored.deserialize({"owned_parcels":[SECOND,FIRST,FIRST,"unknown",7,true]})
	assert_eq(restored.get_owned_ids(),[FIRST])
	assert_false(restored.can_use_cell(Vector2i(0,6)))
	restored.deserialize({"owned_parcels":[FIRST,SECOND]})
	assert_eq(restored.get_owned_ids(),[FIRST,SECOND])
	assert_true(restored.can_use_cell(Vector2i(1,6)))
	assert_false(restored.can_use_cell(Vector2i(2,6)))
	var unconfigured: LandOwnershipState = LandOwnershipState.new()
	unconfigured.deserialize({"owned_parcels":[FIRST]})
	assert_false(unconfigured.can_use_cell(Vector2i.ZERO))
	assert_eq(unconfigured.serialize(),{"owned_parcels":[]})
