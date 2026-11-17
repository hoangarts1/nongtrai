## DayLedgerState — signed daily cash journal; never changes a wallet.
## API:
##   func reset(day: int, history_complete: bool = true) -> void
##   func record(amount: int, reason: StringName) -> void
##   func annotate_trade(reason: StringName, item_id: StringName, quantity: int, total: int) -> void
##   func totals() -> Dictionary
##   func rows() -> Array[Dictionary]
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
class_name DayLedgerState
extends RefCounted

# A corruption/resource bound, not a gameplay earning or transaction limit.
const MAX_SAVED_ENTRIES: int = 4096
const MAX_JSON_INTEGER: int = 9007199254740991
const REFUNDS: Array[StringName] = [&"refund",&"minh_rollback",&"buy_land_rollback",&"buy_bag_upgrade_rollback",&"buy_watering_upgrade_rollback",&"buy_chicken_coop_rollback",&"buy_chicken_feed_rollback"]
var day_index: int = 0
var complete: bool = true
var _entries: Array[Dictionary] = []
var _absolute_total: int = 0

func reset(day: int, history_complete: bool = true) -> void:
	day_index = maxi(0,day)
	complete = history_complete
	_entries.clear()
	_absolute_total = 0

func record(amount: int, reason: StringName) -> void:
	if amount == 0 or reason == &"load":
		return
	if _entries.size() >= MAX_SAVED_ENTRIES or amount < -MAX_JSON_INTEGER or amount > MAX_JSON_INTEGER or _absolute_total > MAX_JSON_INTEGER-absi(amount):
		complete = false
		return
	_absolute_total += absi(amount)
	_entries.append({"amount":amount,"reason":String(reason),"item_id":"","quantity":0})

func annotate_trade(reason: StringName, item_id: StringName, quantity: int, total: int) -> void:
	if _entries.is_empty() or quantity <= 0 or total <= 0:
		return
	var entry: Dictionary = _entries.back()
	# Refunded/partial operations have a later refund entry; do not invent quantities.
	if entry["reason"] == String(reason) and absi(int(entry["amount"])) == total:
		entry["item_id"] = String(item_id)
		entry["quantity"] = quantity

func totals() -> Dictionary:
	var income: int = 0
	var expense: int = 0
	for entry: Dictionary in _entries:
		var amount: int = int(entry["amount"])
		if amount < 0 or StringName(entry["reason"]) in REFUNDS:
			expense -= amount
		else:
			income += amount
	return {"income":income,"expense":expense,"profit":income-expense}

func rows() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var indices: Dictionary = {}
	for entry: Dictionary in _entries:
		var key: String = "%s|%s|%s" % [entry["reason"],entry["item_id"],int(entry["amount"])<0]
		if not indices.has(key):
			indices[key] = result.size()
			result.append(entry.duplicate(true))
		else:
			var existing: Dictionary = result[int(indices[key])]
			existing["amount"] = int(existing["amount"])+int(entry["amount"])
			existing["quantity"] = int(existing["quantity"])+int(entry["quantity"])
	return result

func serialize() -> Dictionary:
	return {"day_index":day_index,"complete":complete,"entries":_entries.duplicate(true)}

func deserialize(data: Dictionary) -> void:
	reset(maxi(0,number(data.get("day_index",0))),data.get("complete",false) is bool and data.get("complete",false))
	var raw: Variant = data.get("entries",[])
	if not raw is Array:
		complete = false
		return
	if raw.size() > MAX_SAVED_ENTRIES:
		complete = false
	for value: Variant in raw.slice(0,MAX_SAVED_ENTRIES):
		if not value is Dictionary:
			complete = false
			continue
		var amount: int = number(value.get("amount",0))
		var reason: Variant = value.get("reason","")
		if amount == 0 or not reason is String or reason.length() > 128:
			complete = false
			continue
		var previous_size: int = _entries.size()
		record(amount,StringName(reason))
		if _entries.size() == previous_size:
			continue
		var id: Variant = value.get("item_id","")
		if id is String and id.length() <= 128:
			_entries.back()["item_id"] = id
			_entries.back()["quantity"] = maxi(0,number(value.get("quantity",0)))

static func number(value: Variant, fallback: int = 0) -> int:
	if not value is int and not value is float:
		return fallback
	if not is_finite(float(value)) or absf(float(value)) > MAX_JSON_INTEGER:
		return fallback
	return int(value)
