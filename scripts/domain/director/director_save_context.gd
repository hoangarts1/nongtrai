## DirectorSaveContext - pure current catalog/calendar/weather/ecology/land boundary.
## API: capture(profile,payload,crops)->Dictionary; valid(profile,context)->bool.
class_name DirectorSaveContext
extends RefCounted

const LAND: LandExpansionConfig = preload("res://data/land_expansion_config.tres")
const LEGACY: CropMigrationConfig = preload("res://data/crop_migration_v7.tres")
const SAMPLING: EcologySamplingConfig = preload("res://data/ecology_sampling_config.tres")
const FIELDS: PackedStringArray = ["ok", "reason", "day_index", "calendar", "calendar_aligned", "catalog_ids", "weather", "weather_available", "ecology", "available", "regions"]

static func capture(profile: DirectorProfile, payload: Variant, crops: Array[Resource]) -> Dictionary:
	if profile == null or not profile.validation_errors().is_empty() or not payload is Dictionary or not payload.get("clock", {}) is Dictionary:
		return _failure(&"invalid_context")
	var clock: Dictionary = payload.get("clock", {})
	var raw_day: Variant = clock.get("day_index", 0)
	if not DirectorActivityCodec.valid_integer(raw_day):
		return _failure(&"invalid_clock_day")
	var day: int = int(raw_day)
	var garden: Dictionary = EcologySaveContext.capture(payload, crops, LAND, LEGACY)
	if not garden.ok:
		return _failure(&"invalid_garden_context")
	var ecology: Dictionary = EcologySaveCodec.normalize(profile.ecology, SAMPLING, payload.get("ecology"), day, crops, garden)
	if not ecology.ok:
		return _failure(&"invalid_ecology_context")
	var calendar: Dictionary = DirectorSnapshot.calendar(profile, day)
	var aligned: bool = calendar.ok and clock.get("season") == calendar.season_id and DirectorActivityCodec.valid_integer(clock.get("year")) and int(clock.year) == int(calendar.year)
	var weather: Dictionary = WeatherSaveCodec.normalize(profile.weather, payload.get("weather", {}), day, true)
	var ids: Array[String] = []
	for crop: CropData in crops:
		ids.append(String(crop.crop_id))
	ids.sort()
	return {"ok": true, "reason": &"captured" if aligned else &"clock_calendar_unavailable", "day_index": day, "calendar": calendar.duplicate(true), "calendar_aligned": aligned, "catalog_ids": ids, "weather": weather.duplicate(true), "weather_available": not weather.is_empty(), "ecology": ecology.snapshot.duplicate(true), "available": ecology.sample.available.duplicate(true), "regions": garden.regions.duplicate()}

static func valid(profile: DirectorProfile, context: Variant) -> bool:
	if profile == null or not profile.validation_errors().is_empty() or not context is Dictionary or context.size() != FIELDS.size():
		return false
	for field: String in FIELDS:
		if not context.has(field):
			return false
	if context.ok != true or not context.ok is bool or not DirectorActivityCodec.valid_integer(context.day_index) or not context.calendar_aligned is bool or not context.weather_available is bool or (not context.reason is String and not context.reason is StringName):
		return false
	var day: int = int(context.day_index)
	if not DirectorSnapshot._same(context.calendar, DirectorSnapshot.calendar(profile, day)) or not context.ecology is Dictionary or not context.available is Dictionary or context.available.size() != profile.ecology.metrics.size():
		return false
	var ecology: Dictionary = EcologySnapshotCodec.decode(profile.ecology, context.ecology)
	if not ecology.ok or int(ecology.snapshot.day_index) != day:
		return false
	for metric: EcologyMetricData in profile.ecology.metrics:
		if not context.available.get(String(metric.metric_id)) is bool or (metric.metric_id == &"water_clarity" and context.available[String(metric.metric_id)]):
			return false
	if not context.weather is Dictionary or context.weather_available == context.weather.is_empty():
		return false
	if context.weather_available and not WeatherSnapshotCodec.decode_at_day(profile.weather, context.weather, day).ok:
		return false
	if not context.catalog_ids is Array or context.catalog_ids.is_empty() or not context.regions is Array or context.regions.is_empty() or context.regions[0] != LAND.initial_region:
		return false
	var seen: Dictionary = {}
	for id: Variant in context.catalog_ids:
		if not EcologyMetricData.valid_id(id) or seen.has(String(id)):
			return false
		seen[String(id)] = true
	var allowed: Array[Rect2i] = [LAND.initial_region]
	for parcel: ExpansionParcelData in LAND.parcels:
		allowed.append(parcel.region)
	var regions: Array[Rect2i] = []
	for region: Variant in context.regions:
		if not region is Rect2i or not allowed.has(region) or regions.has(region):
			return false
		regions.append(region)
	return true

static func _failure(reason: StringName) -> Dictionary:
	return {"ok": false, "reason": reason}
