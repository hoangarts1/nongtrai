extends GutTest
const CONFIG: WateringCanConfig = preload("res://data/watering_can_config.tres")
var _watches: Array[Dictionary] = []

class RejectingState extends WateringCanState:
	var reject: bool = true
	func try_upgrade(expected_capacity: int, target_capacity: int) -> bool:
		return false if reject else super.try_upgrade(expected_capacity,target_capacity)

func after_each() -> void:
	_clear_watches()

func _clear_watches() -> void:
	for entry: Dictionary in _watches:
		var wallet: WalletState = entry.wallet
		wallet.coins_changed.disconnect(entry.callback)
	_watches.clear()

func _watch(wallet: WalletState, callback: Callable) -> void:
	wallet.coins_changed.connect(callback)
	_watches.append({"wallet":wallet,"callback":callback})

func _state(charges: int = 7, config: WateringCanConfig = CONFIG) -> WateringCanState:
	var state: WateringCanState = WateringCanState.new()
	state.configure(config)
	state.deserialize({"capacity":config.base_capacity,"charges":charges})
	return state

func _service(state: WateringCanState, wallet: WalletState, config: WateringCanConfig = CONFIG) -> WateringCanUpgradeService:
	var service: WateringCanUpgradeService = WateringCanUpgradeService.new()
	service.configure(config,state,wallet)
	return service

func test_readonly_quote_one_actual200_payment_preserves_empty_partial_or_full_water() -> void:
	for remaining: int in [0,7,20]:
		var state: WateringCanState = _state(remaining)
		var wallet: WalletState = WalletState.new(500)
		var service: WateringCanUpgradeService = _service(state,wallet)
		var before: Dictionary = state.serialize()
		var quote: Dictionary = service.can_purchase(20)
		assert_true(quote.ok)
		assert_eq(quote.price,200)
		assert_eq(quote.target,40)
		assert_eq(state.serialize(),before)
		assert_eq(wallet.get_coins(),500)
		assert_true(service.purchase(20).ok)
		assert_eq(state.serialize(),{"capacity":40,"charges":remaining})
		assert_eq(wallet.get_coins(),300)
		assert_false(service.purchase(20).ok)
		assert_eq(service.purchase(40).reason,&"already_upgraded")
		assert_eq(wallet.get_coins(),300)

func test_invalid_service_config_identity_stale_and_insufficient_funds_never_pay() -> void:
	assert_eq(WateringCanUpgradeService.new().purchase(20).reason,&"invalid_service")
	var state: WateringCanState = _state()
	var wallet: WalletState = WalletState.new(199)
	var service: WateringCanUpgradeService = _service(state,wallet)
	assert_eq(service.purchase(20).reason,&"insufficient_coins")
	wallet.add_coins(1,&"test")
	assert_eq(service.purchase(19).reason,&"stale_capacity")
	assert_eq(wallet.get_coins(),200)
	assert_eq(state.serialize(),{"capacity":20,"charges":7})
	var separate_config: WateringCanConfig = CONFIG.duplicate() as WateringCanConfig
	service.configure(separate_config,state,wallet)
	assert_eq(service.purchase(20).reason,&"invalid_service")
	separate_config.upgrade_price = -1
	state.configure(separate_config)
	assert_eq(service.purchase(20).reason,&"invalid_service")
	assert_eq(wallet.get_coins(),200)

func test_rejected_grant_refunds_exact_debit_and_retry_emits_correct_reasons() -> void:
	var state: RejectingState = RejectingState.new()
	state.configure(CONFIG)
	state.deserialize({"capacity":20,"charges":7})
	var wallet: WalletState = WalletState.new(500)
	var service: WateringCanUpgradeService = _service(state,wallet)
	var reasons: Array[StringName] = []
	_watch(wallet,func(_total: int, _delta: int, reason: StringName) -> void: reasons.append(reason))
	assert_eq(service.purchase(20).reason,&"grant_rejected")
	assert_eq(wallet.get_coins(),500)
	assert_eq(state.serialize(),{"capacity":20,"charges":7})
	assert_eq(reasons,[&"buy_watering_upgrade",&"buy_watering_upgrade_rollback"])
	state.reject = false
	assert_true(service.purchase(20).ok)
	assert_eq(wallet.get_coins(),300)
	assert_eq(state.serialize(),{"capacity":40,"charges":7})
	assert_eq(reasons.back(),&"buy_watering_upgrade")

func test_same_service_reentry_and_independent_facade_purchase_preserve_one_success() -> void:
	var state: WateringCanState = _state()
	var wallet: WalletState = WalletState.new(1000)
	var service: WateringCanUpgradeService = _service(state,wallet)
	var replies: Array[StringName] = []
	_watch(wallet,func(_total: int, _delta: int, reason: StringName) -> void:
		if reason==&"buy_watering_upgrade":
			replies.append(service.purchase(20).reason)
			replies.append(service.can_purchase(20).reason)
	)
	assert_true(service.purchase(20).ok)
	assert_eq(replies,[&"purchase_busy",&"purchase_busy"])
	assert_eq(wallet.get_coins(),800)
	_clear_watches()
	state.deserialize({"capacity":20,"charges":7})
	var other: WateringCanUpgradeService = _service(state,wallet)
	var once: Array[bool] = [false]
	_watch(wallet,func(_total: int, _delta: int, reason: StringName) -> void:
		if reason==&"buy_watering_upgrade" and not once[0]:
			once[0] = true
			other.purchase(20)
	)
	assert_eq(service.purchase(20).reason,&"grant_rejected")
	assert_eq(wallet.get_coins(),600,"Only the outer debit is refunded, independent success stays")
	assert_eq(state.serialize(),{"capacity":40,"charges":7})

func test_changed_price_preserves_independent_watering_and_context_reconfiguration_cannot_redirect_money() -> void:
	var config: WateringCanConfig = CONFIG.duplicate() as WateringCanConfig
	var state: WateringCanState = _state(7,config)
	var wallet: WalletState = WalletState.new(500)
	var service: WateringCanUpgradeService = _service(state,wallet,config)
	var season: StringName = GameClock.season
	GameClock.season = &"spring"
	var farm: FarmGridState = FarmGridState.new()
	assert_true(farm.till_cell(Vector2i.ZERO))
	assert_true(farm.plant_crop(Vector2i.ZERO,&"turnip"))
	GameClock.season = season
	var watering: WateringService = WateringService.new()
	watering.configure(config,state,farm)
	_watch(wallet,func(_total: int, _delta: int, reason: StringName) -> void:
		if reason==&"buy_watering_upgrade":
			watering.water(Vector2i.ZERO)
			config.upgrade_price += 1
	)
	assert_eq(service.purchase(20).reason,&"grant_rejected")
	assert_eq(wallet.get_coins(),500)
	assert_eq(state.serialize(),{"capacity":20,"charges":6})
	assert_true(farm.get_plot(Vector2i.ZERO).watered)
	_clear_watches()
	config.upgrade_price = 200
	var separate_state: WateringCanState = _state()
	var separate_wallet: WalletState = WalletState.new(70)
	_watch(wallet,func(_total: int, _delta: int, reason: StringName) -> void:
		if reason==&"buy_watering_upgrade":
			state.refill()
			service.configure(CONFIG,separate_state,separate_wallet)
	)
	assert_true(service.purchase(20).ok)
	assert_eq(state.serialize(),{"capacity":40,"charges":20},"Independent refill retained, upgrade adds no water")
	assert_eq(wallet.get_coins(),300)
	assert_eq(separate_state.serialize(),{"capacity":20,"charges":7})
	assert_eq(separate_wallet.get_coins(),70)
