extends GutTest
const CONFIG: WateringCanConfig = preload("res://data/watering_can_config.tres")
const SLOT: int = 98
var locale: String

class RejectingState extends WateringCanState:
	func try_upgrade(_expected_capacity: int, _target_capacity: int) -> bool:
		return false

func before_each() -> void:
	locale = TranslationServer.get_locale()

func after_each() -> void:
	TranslationServer.set_locale(locale)
	SaveService.delete_save(SLOT)

func test_real_service_purchase_and_refund_have_correct_signed_totals() -> void:
	for rejected: bool in [false,true]:
		var state: WateringCanState = RejectingState.new() if rejected else WateringCanState.new()
		state.configure(CONFIG)
		state.deserialize({"capacity":20,"charges":7})
		var wallet: WalletState = WalletState.new(500)
		var ledger: DayLedgerState = DayLedgerState.new()
		var callback: Callable = func(_total: int, delta: int, reason: StringName) -> void: ledger.record(delta,reason)
		wallet.coins_changed.connect(callback)
		var service: WateringCanUpgradeService = WateringCanUpgradeService.new()
		service.configure(CONFIG,state,wallet)
		assert_eq(bool(service.purchase(20).ok),not rejected)
		assert_eq(wallet.get_coins(),500 if rejected else 300)
		assert_eq(ledger.totals(),{"income":0,"expense":0 if rejected else 200,"profit":0 if rejected else -200})
		assert_eq(ledger.rows().size(),2 if rejected else 1)
		assert_eq(ledger.rows()[0].reason,"buy_watering_upgrade")
		assert_eq(ledger.rows()[0].amount,-200)
		if rejected:
			assert_eq(ledger.rows()[1].reason,"buy_watering_upgrade_rollback")
			assert_eq(ledger.rows()[1].amount,200)
		wallet.coins_changed.disconnect(callback)

func test_refund_preserves_independent_wallet_income_and_real_save_v10_roundtrip() -> void:
	var state: RejectingState = RejectingState.new()
	state.configure(CONFIG)
	var wallet: WalletState = WalletState.new(500)
	var ledger: DayLedgerState = DayLedgerState.new()
	var callback: Callable = func(_total: int, delta: int, reason: StringName) -> void:
		ledger.record(delta,reason)
		if reason==&"buy_watering_upgrade":
			wallet.add_coins(11,&"sell_produce")
	wallet.coins_changed.connect(callback)
	var service: WateringCanUpgradeService = WateringCanUpgradeService.new()
	service.configure(CONFIG,state,wallet)
	assert_eq(service.purchase(20).reason,&"grant_rejected")
	assert_eq(wallet.get_coins(),511)
	assert_eq(ledger.totals(),{"income":11,"expense":0,"profit":11})
	var payload: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v10.json"))
	payload.day_ledger = ledger.serialize()
	payload.wallet = wallet.serialize()
	assert_true(SaveService.save_game(payload,SLOT))
	var restored: DayLedgerState = DayLedgerState.new()
	restored.deserialize(SaveService.load_game(SLOT).day_ledger)
	assert_eq(restored.serialize(),ledger.serialize())
	assert_eq(restored.totals(),ledger.totals())
	wallet.coins_changed.disconnect(callback)

func test_day_end_presenter_labels_real_purchase_and_refund_in_both_locales() -> void:
	for language: String in ["vi","en"]:
		TranslationServer.set_locale(language)
		assert_eq(LifeDayEndPresenter.REASON_KEYS["buy_watering_upgrade"],&"WATER_UP_LEDGER")
		assert_eq(LifeDayEndPresenter.REASON_KEYS["buy_watering_upgrade_rollback"],&"END_REFUND")
		assert_ne(tr("WATER_UP_LEDGER"),"WATER_UP_LEDGER")
		assert_ne(tr("END_REFUND"),"END_REFUND")
