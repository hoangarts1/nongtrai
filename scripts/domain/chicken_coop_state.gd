## ChickenCoopState — trusted standalone daily herd/feed/output owner, not player commands.
## API:
##   func configure(config: ChickenCoopConfig, start_day: int, hens: int) -> void
##   func feed(day_index: int, hens_to_feed: int) -> Dictionary
##   func feeding_quote(day_index: int, hens_to_feed: int) -> Dictionary
##   func begin_feeding(day_index: int, hens_to_feed: int) -> Dictionary
##   func finish_feeding(token: RefCounted, debited: bool) -> bool
##   func advance_day(completed_day: int) -> Dictionary
##   func take_eggs(expected_quantity: int) -> Dictionary
##   func collection_quote(expected_quantity: int) -> Dictionary
##   func begin_collection(expected_quantity: int) -> Dictionary
##   func finish_collection(token: RefCounted, remaining_quantity: int) -> bool
##   func is_busy() -> bool
##   func begin_shop(stock_hens: int = 0) -> Dictionary
##   func finish_shop(token: RefCounted, paid: bool) -> bool
##   func day_quote(completed_day: int) -> Dictionary
##   func begin_day(completed_day: int) -> Dictionary
##   func finish_day(token: RefCounted) -> bool
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
class_name ChickenCoopState
extends RefCounted

const MAX_JSON_INTEGER: int = ChickenCoopConfig.MAX_JSON_INTEGER
# Stable schema token; inventory registration/authorization belongs to the collection service.
const OUTPUT_ITEM_ID: StringName = &"egg"
var _config: ChickenCoopConfig
var _configured: bool = false
var _current_day: int = 0
var _hen_count: int = 0
var _fed_hens: int = 0
var _pending_eggs: int = 0
# Shared across facades, never serialized or treated as another output owner.
var _collection_token: RefCounted
var _reserved_eggs: int = 0
var _feeding_token: RefCounted
var _reserved_feed_hens: int = 0
var _shop_token: RefCounted
var _stock_hens: int = 0
var _day_token: RefCounted
var _day_eggs: int = 0

func configure(config: ChickenCoopConfig, start_day: int, hens: int) -> void:
	if is_busy():
		push_warning("ChickenCoopState: configure blocked during transaction; state retained")
		return
	_config = config
	_configured = false
	_current_day = 0
	_hen_count = 0
	_fed_hens = 0
	_pending_eggs = 0
	if config==null or not config.validation_errors().is_empty():
		push_warning("ChickenCoopState: invalid config; no herd initialized")
		return
	if start_day<0 or start_day>MAX_JSON_INTEGER or hens<0 or hens>config.hen_capacity:
		push_warning("ChickenCoopState: invalid initial day/herd; no herd initialized")
		return
	_current_day = start_day
	_hen_count = hens
	_configured = true

func feed(day_index: int, hens_to_feed: int) -> Dictionary:
	var quote: Dictionary = feeding_quote(day_index,hens_to_feed)
	if not bool(quote.ok):
		return quote
	# Trusted primitive only; real inventory commands use ChickenCoopFeedingService.
	_fed_hens += hens_to_feed
	return {"ok":true,"reason":&"fed","fed_hens":_fed_hens,"feed_units":int(quote.feed_units)}

func feeding_quote(day_index: int, hens_to_feed: int) -> Dictionary:
	if is_busy():
		return _failure(_busy_reason())
	if not _is_ready():
		return _failure(&"invalid_state")
	if day_index!=_current_day:
		return _failure(&"wrong_day")
	if hens_to_feed<=0 or hens_to_feed>_hen_count-_fed_hens:
		return _failure(&"invalid_feed")
	return {"ok":true,"reason":&"ready","day_index":day_index,"hens_to_feed":hens_to_feed,"item_id":_config.feed_item_id,"feed_units":hens_to_feed*_config.feed_per_hen}

func begin_feeding(day_index: int, hens_to_feed: int) -> Dictionary:
	var quote: Dictionary = feeding_quote(day_index,hens_to_feed)
	if not bool(quote.ok):
		return quote
	_feeding_token = RefCounted.new()
	_reserved_feed_hens = hens_to_feed
	quote["token"] = _feeding_token
	quote["reason"] = &"reserved"
	return quote

func finish_feeding(token: RefCounted, debited: bool) -> bool:
	if token==null or token!=_feeding_token or _reserved_feed_hens<=0 or _reserved_feed_hens>_hen_count-_fed_hens or _collection_token!=null:
		return false
	# Honor the captured whole debit, without re-reading mutable Resource terms.
	if debited:
		_fed_hens += _reserved_feed_hens
	_reserved_feed_hens = 0
	_feeding_token = null
	return true

func day_quote(completed_day: int) -> Dictionary:
	if is_busy() or not _is_ready() or completed_day!=_current_day:
		return _failure(&"wrong_day" if not is_busy() else _busy_reason())
	var produced: int = _fed_hens*_config.eggs_per_fed_hen
	return {"ok":_current_day<MAX_JSON_INTEGER and _pending_eggs<=MAX_JSON_INTEGER-produced,"reason":&"ready"}

func begin_day(completed_day: int) -> Dictionary:
	var quote: Dictionary = day_quote(completed_day)
	if not bool(quote.ok):
		return quote
	var reservation: Dictionary = begin_shop()
	if bool(reservation.ok):
		_day_token = reservation.token
		_day_eggs = _fed_hens*_config.eggs_per_fed_hen
	return reservation

func finish_day(token: RefCounted) -> bool:
	if token==null or token!=_day_token or token!=_shop_token:
		return false
	_pending_eggs += _day_eggs
	_fed_hens = 0
	_current_day += 1
	_day_eggs = 0
	_day_token = null
	return finish_shop(token,false)

func advance_day(completed_day: int) -> Dictionary:
	if is_busy():
		return _failure(_busy_reason())
	if not _is_ready():
		return _failure(&"invalid_state")
	if completed_day!=_current_day:
		return _failure(&"wrong_day")
	var produced: int = _fed_hens*_config.eggs_per_fed_hen
	if _current_day==MAX_JSON_INTEGER or _pending_eggs>MAX_JSON_INTEGER-produced:
		return _failure(&"numeric_overflow")
	_pending_eggs += produced
	_fed_hens = 0
	_current_day += 1
	return {"ok":true,"reason":&"advanced","produced":produced,"day_index":_current_day}

func take_eggs(expected_quantity: int) -> Dictionary:
	if is_busy():
		return _failure(_busy_reason())
	if not _is_ready():
		return _failure(&"invalid_state")
	if expected_quantity<=0 or expected_quantity!=_pending_eggs:
		return _failure(&"stale_quantity")
	# Raw primitive only; player transfers must use ChickenCoopCollectionService.
	_pending_eggs = 0
	return {"ok":true,"reason":&"collected","item_id":OUTPUT_ITEM_ID,"quantity":expected_quantity}

func is_busy() -> bool:
	return _collection_token!=null or _feeding_token!=null or _shop_token!=null

func collection_quote(expected_quantity: int) -> Dictionary:
	if is_busy():
		return _failure(_busy_reason())
	if not _is_ready():
		return _failure(&"invalid_state")
	if expected_quantity<=0 or expected_quantity!=_pending_eggs:
		return _failure(&"stale_quantity")
	return {"ok":true,"reason":&"ready","item_id":OUTPUT_ITEM_ID,"quantity":expected_quantity}

func begin_collection(expected_quantity: int) -> Dictionary:
	var quote: Dictionary = collection_quote(expected_quantity)
	if not bool(quote.ok):
		return quote
	_collection_token = RefCounted.new()
	_reserved_eggs = _pending_eggs
	_pending_eggs = 0
	quote["token"] = _collection_token
	quote["reason"] = &"reserved"
	return quote

func finish_collection(token: RefCounted, remaining_quantity: int) -> bool:
	if token==null or token!=_collection_token or remaining_quantity<0 or remaining_quantity>_reserved_eggs or _pending_eggs!=0:
		return false
	# Always settle the captured reservation, even if callbacks invalidated config.
	_pending_eggs = remaining_quantity
	_reserved_eggs = 0
	_collection_token = null
	return true

func begin_shop(stock_hens: int = 0) -> Dictionary:
	if is_busy():
		return _failure(_busy_reason())
	if not _is_ready() or stock_hens<0 or stock_hens>_config.hen_capacity or (stock_hens>0 and (_hen_count!=0 or _pending_eggs!=0)):
		return _failure(&"invalid_state")
	_shop_token = RefCounted.new()
	_stock_hens = stock_hens
	return {"ok":true,"reason":&"reserved","token":_shop_token}

func finish_shop(token: RefCounted, paid: bool) -> bool:
	if token==null or token!=_shop_token:
		return false
	if paid and _stock_hens>0:
		_hen_count = _stock_hens
	_stock_hens = 0
	_shop_token = null
	return true

func serialize() -> Dictionary:
	# Diagnostic while busy; runtime saves must wait for is_busy()==false.
	return {"current_day":_current_day,"hen_count":_hen_count,"fed_hens":_fed_hens,"pending_eggs":_pending_eggs}

func deserialize(data: Dictionary) -> void:
	if is_busy():
		push_warning("ChickenCoopState: restore blocked during transaction; state retained")
		return
	if not _configured or _config==null or not _config.validation_errors().is_empty():
		push_warning("ChickenCoopState: restore requires valid explicit configuration; state retained")
		return
	# Restore all fields together: clamping forged feed could create unwarranted output.
	var day: int = _json_integer(data.get("current_day"))
	var hens: int = _json_integer(data.get("hen_count"))
	var fed: int = _json_integer(data.get("fed_hens"))
	var eggs: int = _json_integer(data.get("pending_eggs"))
	if day<0 or hens<0 or fed<0 or eggs<0 or hens>_config.hen_capacity or fed>hens:
		push_warning("ChickenCoopState: malformed snapshot rejected atomically; state retained")
		return
	_current_day = day
	_hen_count = hens
	_fed_hens = fed
	_pending_eggs = eggs

func _is_ready() -> bool:
	return _configured and _config!=null and _config.validation_errors().is_empty() and _current_day>=0 and _current_day<=MAX_JSON_INTEGER and _hen_count>=0 and _hen_count<=_config.hen_capacity and _fed_hens>=0 and _fed_hens<=_hen_count and _pending_eggs>=0 and _pending_eggs<=MAX_JSON_INTEGER

func _busy_reason() -> StringName:
	return &"collection_busy" if _collection_token!=null else (&"feeding_busy" if _feeding_token!=null else &"purchase_busy")

func _failure(reason: StringName) -> Dictionary:
	return {"ok":false,"reason":reason}

static func _json_integer(value: Variant) -> int:
	if value is int:
		return int(value) if value>=0 and value<=MAX_JSON_INTEGER else -1
	if value is float and is_finite(value) and value>=0 and value<=MAX_JSON_INTEGER and value==floorf(value):
		return int(value)
	return -1
