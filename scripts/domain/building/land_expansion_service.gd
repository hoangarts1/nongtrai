## LandExpansionService — stateless land purchase adapter; WalletState owns all coins.
## API:
##   func configure(config: LandExpansionConfig, state: LandOwnershipState, wallet: WalletState) -> void
##   func can_purchase(parcel_id: StringName) -> Dictionary
##   func purchase(parcel_id: StringName) -> Dictionary
class_name LandExpansionService
extends RefCounted

var _config: LandExpansionConfig
var _state: LandOwnershipState
var _wallet: WalletState
var _purchasing: bool = false

func configure(config: LandExpansionConfig, state: LandOwnershipState, wallet: WalletState) -> void:
	_config = config
	_state = state
	_wallet = wallet

func can_purchase(parcel_id: StringName) -> Dictionary:
	if _purchasing:
		return _failure(&"purchase_busy")
	if _state==null or _wallet==null or not _state.is_ready_for(_config):
		return _failure(&"invalid_service")
	if _state.get_owned_ids().has(parcel_id):
		return _failure(&"already_owned")
	var next: StringName = _state.next_parcel_id()
	if next.is_empty():
		return _failure(&"no_available_parcel")
	if parcel_id!=next:
		return _failure(&"not_next_parcel")
	var quote: Dictionary = LandExpansionRules.quote_cost(_config,_state.get_owned_ids().size()+1)
	if not bool(quote.ok):
		return quote
	if not _wallet.can_afford(int(quote.price)):
		return _failure(&"insufficient_coins")
	return {"ok":true,"reason":&"available","parcel_id":parcel_id,"price":int(quote.price)}

func purchase(parcel_id: StringName) -> Dictionary:
	var quote: Dictionary = can_purchase(parcel_id)
	if not bool(quote.ok):
		return quote
	var price: int = int(quote.price)
	var config: LandExpansionConfig = _config
	var state: LandOwnershipState = _state
	var wallet: WalletState = _wallet
	_purchasing = true
	if not wallet.remove_coins(price,&"buy_land"):
		_purchasing = false
		return _failure(&"insufficient_coins")
	# Wallet callbacks can change resources/order or complete an independent purchase.
	var current: Dictionary = LandExpansionRules.quote_cost(config,state.get_owned_ids().size()+1)
	var unchanged: bool = state.is_ready_for(config) and state.next_parcel_id()==parcel_id and bool(current.ok) and int(current.get("price",0))==price
	if not unchanged or not state.grant_next(parcel_id):
		wallet.add_coins(price,&"buy_land_rollback")
		_purchasing = false
		return _failure(&"grant_rejected")
	_purchasing = false
	return {"ok":true,"reason":&"purchased","parcel_id":parcel_id,"price":price}

func _failure(reason: StringName) -> Dictionary:
	return {"ok":false,"reason":reason}
