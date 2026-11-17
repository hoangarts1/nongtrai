## ChickenCoopHoldingState — purchased flag and stable daily coop owner.
## API: configure(config,day), is_owned(), begin_purchase(hens), finish_purchase(token,paid), serialize(), deserialize(data).
class_name ChickenCoopHoldingState
extends RefCounted
var coop: ChickenCoopState = ChickenCoopState.new()
var _owned: bool = false
var _config: ChickenCoopConfig
var _purchase_token: RefCounted

func configure(config: ChickenCoopConfig, day: int) -> void:
	if coop.is_busy():
		return
	_config = config
	_owned = false
	coop.configure(config,day,0)

func is_owned() -> bool:
	return _owned

func begin_purchase(hens: int) -> Dictionary:
	if hens<=0 or _config==null:
		return {"ok":false,"reason":&"invalid_quantity"}
	if _owned:
		return {"ok":false,"reason":&"already_owned"}
	var result: Dictionary = coop.begin_shop(hens)
	if bool(result.ok):
		_purchase_token = result.token
	return result

func finish_purchase(token: RefCounted, paid: bool) -> bool:
	if token==null or token!=_purchase_token or not coop.finish_shop(token,paid):
		return false
	_owned = paid
	_purchase_token = null
	return true

func serialize() -> Dictionary:
	return {"owned":_owned,"coop":coop.serialize()}

func deserialize(data: Dictionary) -> void:
	if coop.is_busy():
		return
	var day: int = int(coop.serialize().current_day)
	var normalized: Dictionary = ChickenCoopSaveCodec.normalize(data,day,_config)
	_owned = bool(normalized.owned)
	coop.deserialize(normalized.coop)
