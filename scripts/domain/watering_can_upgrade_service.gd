## WateringCanUpgradeService - first-tier wallet command; preserves remaining water.
## API:
##   func configure(config: WateringCanConfig, state: WateringCanState, wallet: WalletState) -> void
##   func can_purchase(expected_capacity: int) -> Dictionary
##   func purchase(expected_capacity: int) -> Dictionary
class_name WateringCanUpgradeService
extends RefCounted

var _config: WateringCanConfig
var _state: WateringCanState
var _wallet: WalletState
var _purchasing: bool = false

func configure(config: WateringCanConfig, state: WateringCanState, wallet: WalletState) -> void:
	_config = config
	_state = state
	_wallet = wallet

func can_purchase(expected_capacity: int) -> Dictionary:
	if _purchasing:
		return _failure(&"purchase_busy")
	if _state==null or _wallet==null or not _state.is_ready_for(_config):
		return _failure(&"invalid_service")
	var current: int = _state.get_capacity()
	if expected_capacity!=current:
		return _failure(&"stale_capacity")
	if current==_config.upgrade_capacity:
		return _failure(&"already_upgraded")
	if not _wallet.can_afford(_config.upgrade_price):
		return _failure(&"insufficient_coins")
	return {"ok":true,"reason":&"available","capacity":current,"target":_config.upgrade_capacity,"price":_config.upgrade_price}

func purchase(expected_capacity: int) -> Dictionary:
	var quote: Dictionary = can_purchase(expected_capacity)
	if not bool(quote.ok):
		return quote
	var config: WateringCanConfig = _config
	var state: WateringCanState = _state
	var wallet: WalletState = _wallet
	var target: int = int(quote.target)
	var price: int = int(quote.price)
	_purchasing = true
	if not EconomyService.debit(wallet,price,&"buy_watering_upgrade",true):
		_purchasing = false
		return _failure(&"insufficient_coins")
	var unchanged: bool = state.is_ready_for(config) and config.upgrade_capacity==target and config.upgrade_price==price
	if not unchanged or not state.try_upgrade(expected_capacity,target):
		EconomyService.credit(wallet,price,&"buy_watering_upgrade_rollback",true)
		_purchasing = false
		return _failure(&"grant_rejected")
	_purchasing = false
	return {"ok":true,"reason":&"upgraded","capacity":state.get_capacity(),"charges":state.get_charges(),"price":price}

func _failure(reason: StringName) -> Dictionary:
	return {"ok":false,"reason":reason}
