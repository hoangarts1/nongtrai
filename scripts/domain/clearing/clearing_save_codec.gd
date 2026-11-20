## ClearingSaveCodec - strict bounded canonical cell/asset rows, no node trees/history.
## API: empty()->Dictionary; decode(context,raw)->Dictionary;
## normalize(config,raw,legacy=false)->Dictionary.
class_name ClearingSaveCodec
extends RefCounted
const INTRODUCED_VERSION: int = 17
const INT32_MIN: int = -2147483648
const INT32_MAX: int = 2147483647

static func empty() -> Dictionary:
	return {"cleared":[]}

static func normalize(config: ClearingConfig, raw: Variant, legacy: bool = false) -> Dictionary:
	var context: Dictionary = ClearingRules.compile(config)
	if context.is_empty(): return {"ok":false,"reason":&"invalid_clearing_config"}
	if not legacy:
		var result: Dictionary = decode(context,raw)
		if result.ok: return {"ok":true,"snapshot":result.snapshot,"fallback":false,"reason":&"preserved_clearing"}
	return {"ok":true,"snapshot":empty(),"fallback":true,"reason":&"legacy_clearing" if legacy else &"clearing_fallback"}

static func decode(context: Dictionary, raw: Variant) -> Dictionary:
	if not context.get("entries") is Dictionary or not raw is Dictionary or raw.size()!=1 or not raw.has("cleared") or not raw.cleared is Array or raw.cleared.size()>context.entries.size(): return _failure()
	var seen: Dictionary = {}
	var rows: Array[Dictionary] = []
	for value: Variant in raw.cleared:
		if not value is Dictionary or value.size()!=3 or not _integer(value.get("x")) or not _integer(value.get("y")) or typeof(value.get("asset_id"))!=TYPE_STRING: return _failure()
		for key: Variant in value:
			if typeof(key)!=TYPE_STRING: return _failure()
		var cell: Vector2i = Vector2i(int(value.x),int(value.y))
		if seen.has(cell) or not context.entries.has(cell) or context.entries[cell]!=StringName(value.asset_id): return _failure()
		seen[cell] = true
		rows.append({"x":cell.x,"y":cell.y,"asset_id":String(value.asset_id)})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.y<b.y or (a.y==b.y and a.x<b.x))
	return {"ok":true,"snapshot":{"cleared":rows}}

static func _integer(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value)==floorf(float(value)) and value>=INT32_MIN and value<=INT32_MAX

static func _failure() -> Dictionary:
	return {"ok":false,"reason":&"invalid_clearing_snapshot"}
