## WeatherSnapshotCodec — validates existing wire data without rolling or owning weather.
## API:
##   static func decode_at_day(profile: WeatherProfile, raw: Variant, expected_day: int = -1) -> Dictionary
##   static func decode(profile: WeatherProfile, raw: Variant) -> Dictionary
class_name WeatherSnapshotCodec
extends RefCounted
const MAX_JSON_INTEGER: int = 9007199254740991

static func decode(profile: WeatherProfile, raw: Variant) -> Dictionary:
	if profile==null:
		return _failure(PackedStringArray(["weather snapshot requires a valid profile"]))
	var errors: PackedStringArray = profile.validation_errors()
	if not errors.is_empty():
		return _failure(errors)
	if not raw is Dictionary:
		return _failure(PackedStringArray(["weather snapshot must be a Dictionary"]))
	var seed: Variant = raw.get("world_seed")
	if not _valid_seed(seed):
		errors.append("weather world_seed must be a signed exact JSON integer")
	var today: Variant = raw.get("today")
	if not _known_id(profile,today):
		errors.append("weather today must be a known string id")
	var saved: Variant = raw.get("forecast")
	var decoded: Array[String] = []
	if not saved is Array and not saved is PackedStringArray:
		errors.append("weather forecast must be an Array or PackedStringArray")
	elif saved.size()!=profile.forecast_days:
		errors.append("weather forecast length must match profile horizon")
	else:
		for value: Variant in saved:
			if not _known_id(profile,value):
				errors.append("weather forecast contains an unknown/non-string id")
			else:
				decoded.append(String(value))
	if not errors.is_empty():
		return _failure(errors)
	return {"ok":true,"snapshot":{"world_seed":int(seed),"today":String(today),"forecast":decoded}}

static func _valid_seed(value: Variant) -> bool:
	if value is int:
		return value>=-MAX_JSON_INTEGER and value<=MAX_JSON_INTEGER
	if value is float:
		return is_finite(value) and value>=-MAX_JSON_INTEGER and value<=MAX_JSON_INTEGER and value==floorf(value)
	return false

static func _known_id(profile: WeatherProfile, value: Variant) -> bool:
	return (value is String or value is StringName) and not profile.get_entry(StringName(value)).is_empty()

static func _failure(errors: PackedStringArray) -> Dictionary:
	return {"ok":false,"errors":errors}

static func decode_at_day(profile: WeatherProfile, raw: Variant, expected_day: int = -1) -> Dictionary:
	var decoded: Dictionary = decode(profile,raw)
	if not bool(decoded.ok):
		return decoded
	var day: Variant = raw.get("day_index")
	if not _valid_seed(day) or day<0 or day>MAX_JSON_INTEGER-profile.forecast_days:
		return _failure(PackedStringArray(["weather day_index must be a nonnegative exact integer with forecast headroom"]))
	if expected_day < -1 or (expected_day>=0 and int(day)!=expected_day):
		return _failure(PackedStringArray(["weather day_index does not match expected clock day"]))
	decoded.snapshot["day_index"] = int(day)
	return decoded
