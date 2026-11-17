## WeatherSaveCodec — pure envelope normalization, no RNG or unrelated progress changes.
## API:
##   static func normalize(profile: WeatherProfile, raw: Variant, day: int, legacy: bool = false) -> Dictionary
##   static func pack(profile: WeatherProfile, raw: Variant, day: int) -> Dictionary
class_name WeatherSaveCodec
extends RefCounted

static func normalize(profile: WeatherProfile, raw: Variant, day: int, legacy: bool = false) -> Dictionary:
	if raw is Dictionary and raw.is_empty():
		return {}
	if day<0 or day>WeatherSnapshotCodec.MAX_JSON_INTEGER:
		push_warning("WeatherSaveCodec: invalid clock day")
		return {}
	var candidate: Variant = raw
	if legacy and raw is Dictionary and not raw.has("day_index"):
		candidate = raw.duplicate(true)
		candidate["day_index"] = day
	var decoded: Dictionary = WeatherSnapshotCodec.decode_at_day(profile,candidate,day)
	if not bool(decoded.ok):
		push_warning("WeatherSaveCodec: invalid weather component; empty for explicit runtime fallback")
		return {}
	return decoded.snapshot

static func pack(profile: WeatherProfile, raw: Variant, day: int) -> Dictionary:
	return normalize(profile,raw,day,true)
