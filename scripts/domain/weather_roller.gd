## WeatherRoller — pure per-absolute-day tagged weighted draws.
## API:
##   static func roll_day(profile: WeatherProfile, seed: int, day: int) -> StringName
##   static func initial_snapshot(profile: WeatherProfile, seed: int, day: int) -> Dictionary
class_name WeatherRoller
extends RefCounted

static func roll_day(profile: WeatherProfile, seed: int, day: int) -> StringName:
	if profile==null or not profile.validation_errors().is_empty() or seed < -WeatherSnapshotCodec.MAX_JSON_INTEGER or seed>WeatherSnapshotCodec.MAX_JSON_INTEGER or day<0 or day>WeatherSnapshotCodec.MAX_JSON_INTEGER:
		return &""
	var total: int = 0
	for entry: Dictionary in profile.entries:
		total += int(entry.probability)
	var rng: RandomNumberGenerator = DetRandom.make_rng(seed,day,DetRandom.TAG_WEATHER)
	var draw: int = rng.randi_range(0,total-1)
	for entry: Dictionary in profile.entries:
		draw -= int(entry.probability)
		if draw<0:
			return StringName(entry.id)
	return &""

static func initial_snapshot(profile: WeatherProfile, seed: int, day: int) -> Dictionary:
	if profile==null or not profile.validation_errors().is_empty() or seed < -WeatherSnapshotCodec.MAX_JSON_INTEGER or seed>WeatherSnapshotCodec.MAX_JSON_INTEGER or day<0 or day>WeatherSnapshotCodec.MAX_JSON_INTEGER-profile.forecast_days:
		return {}
	var forecast: Array[String] = []
	for offset: int in range(1,profile.forecast_days+1):
		forecast.append(String(roll_day(profile,seed,day+offset)))
	return {"world_seed":seed,"today":String(profile.initial_weather_id),"forecast":forecast,"day_index":day}
