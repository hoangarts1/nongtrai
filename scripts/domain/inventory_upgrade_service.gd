## InventoryUpgradeService - stateless first-tier command; actual owners keep state.
## API:
##   static func validate_config(config: BagUpgradeConfig) -> PackedStringArray
##   func configure(config: BagUpgradeConfig, inventory: InventoryState, wallet: WalletState) -> void
##   func can_purchase(expected_capacity: int) -> Dictionary
##   func purchase(expected_capacity: int) -> Dictionary
class_name InventoryUpgradeService
extends RefCounted

var _config: BagUpgradeConfig
var _inventory: InventoryState
var _wallet: WalletState
var _purchasing: bool = false

static func validate_config(config: BagUpgradeConfig) -> PackedStringArray:
	return config.validation_errors() if config!=null else PackedStringArray(["bag upgrade requires a config"])

func configure(config: BagUpgradeConfig, inventory: InventoryState, wallet: WalletState) -> void:
	_config = config
	_inventory = inventory
	_wallet = wallet

func can_purchase(expected_capacity: int) -> Dictionary:
	if _purchasing:
		return _failure(&"purchase_busy")
	if _inventory==null or _wallet==null or not validate_config(_config).is_empty():
		return _failure(&"invalid_service")
	var current: int = _inventory.capacity
	var target: int = _config.base.default_capacity+_config.additional_slots
	var result: Dictionary = {"ok":false,"reason":&"available","capacity":current,"target":target,"price":_config.purchase_price}
	if expected_capacity!=current:
		result.reason = &"stale_capacity"
	elif current<=0 or current>InventoryState.MAX_SAVED_SLOTS or current<_inventory.get_slots().size():
		result.reason = &"invalid_service"
	elif current>=target:
		result.reason = &"already_upgraded"
	elif not _wallet.can_afford(_config.purchase_price):
		result.reason = &"insufficient_coins"
	else:
		result.ok = true
	return result

func purchase(expected_capacity: int) -> Dictionary:
	var quote: Dictionary = can_purchase(expected_capacity)
	if not bool(quote.ok):
		return quote
	var config: BagUpgradeConfig = _config
	var inventory: InventoryState = _inventory
	var wallet: WalletState = _wallet
	var target: int = int(quote.target)
	var price: int = int(quote.price)
	_purchasing = true
	if not EconomyService.debit(wallet,price,&"buy_bag_upgrade",true):
		_purchasing = false
		return _failure(&"insufficient_coins")
	# Callbacks may legitimately change items/config/capacity; never overwrite them.
	var unchanged: bool = validate_config(config).is_empty() and config.purchase_price==price and config.base.default_capacity+config.additional_slots==target
	if not unchanged or not inventory.try_expand_capacity(expected_capacity,target):
		EconomyService.credit(wallet,price,&"buy_bag_upgrade_rollback",true)
		_purchasing = false
		return _failure(&"grant_rejected")
	_purchasing = false
	return {"ok":true,"reason":&"upgraded","capacity":inventory.capacity,"target":target,"price":price}

func _failure(reason: StringName) -> Dictionary:
	return {"ok":false,"reason":reason}
