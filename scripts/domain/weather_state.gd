## WeatherState — single serializable weather/day owner with captured daily reservations.
## API:
##   configure(profile:Resource,seed:int=0,start_day:int=0)->void
##   advance_day(day_index:int)->void; force_weather(weather_id:StringName)->void
##   get_day_index()->int; is_busy()->bool; day_quote(target_day:int)->Dictionary
##   begin_day(target_day:int)->Dictionary; finish_day(token:RefCounted)->bool; abort_day(token:RefCounted)->bool
##   serialize()->Dictionary; deserialize(data:Dictionary)->void
##   restore_for_day(raw:Variant,day:int,default_seed:int=0)->Dictionary
##   is_rainy()->bool; is_stormy()->bool; get_entry()->Dictionary
##   signal weather_changed(weather_id: StringName); signal forecast_updated(forecast: Array[StringName])
class_name WeatherState
extends RefCounted
signal weather_changed(weather_id: StringName)
signal forecast_updated(forecast: Array[StringName])
var world_seed: int = 0
var today: StringName = &"sunny"
var forecast: Array[StringName] = []
var _profile: WeatherProfile
var _day: int = 0
var _day_token: RefCounted
var _reserved: Dictionary = {}
var _notifying: bool = false

func configure(profile: Resource, seed: int = 0, start_day: int = 0) -> void:
	if is_busy():
		push_warning("WeatherState: configure blocked while busy")
		return
	var config: WeatherProfile = profile as WeatherProfile
	var initial: Dictionary = WeatherRoller.initial_snapshot(config,seed,start_day)
	if initial.is_empty():
		push_warning("WeatherState: invalid configuration; prior state retained")
		return
	_profile = config
	_apply(initial,false)

func get_day_index() -> int:
	return _day

func is_busy() -> bool:
	return _day_token!=null or _notifying

func day_quote(target_day: int) -> Dictionary:
	if is_busy():
		return _failure(&"weather_busy")
	if not bool(WeatherSnapshotCodec.decode_at_day(_profile,serialize()).ok):
		return _failure(&"invalid_weather")
	if target_day!=_day+1:
		return _failure(&"wrong_day")
	if target_day>WeatherSnapshotCodec.MAX_JSON_INTEGER-_profile.forecast_days:
		return _failure(&"numeric_overflow")
	return {"ok":true,"reason":&"ready","day_index":target_day}

func begin_day(target_day: int) -> Dictionary:
	var quote: Dictionary = day_quote(target_day)
	if not bool(quote.ok):
		return quote
	var next: StringName = WeatherRoller.roll_day(_profile,world_seed,target_day+_profile.forecast_days)
	if next==&"":
		return _failure(&"invalid_weather")
	var future: Array[String] = []
	for index: int in range(1,forecast.size()):
		future.append(String(forecast[index]))
	future.append(String(next))
	_reserved = {"world_seed":world_seed,"today":String(forecast[0]),"forecast":future,"day_index":target_day}
	_day_token = RefCounted.new()
	return {"ok":true,"reason":&"reserved","token":_day_token}

func finish_day(token: RefCounted) -> bool:
	if token==null or token!=_day_token:
		return false
	var captured: Dictionary = _reserved
	_reserved = {}
	_day_token = null
	_apply(captured,true)
	return true

func abort_day(token: RefCounted) -> bool:
	if token==null or token!=_day_token:
		return false
	_reserved = {}
	_day_token = null
	return true

func advance_day(day_index: int) -> void:
	var reserved: Dictionary = begin_day(day_index)
	if bool(reserved.ok):
		finish_day(reserved.token)

func force_weather(weather_id: StringName) -> void:
	if is_busy() or _profile==null or not _profile.validation_errors().is_empty() or _profile.get_entry(weather_id).is_empty():
		return
	today = weather_id
	_publish(false)

func is_rainy() -> bool:
	return bool(get_entry().get("rain",false))

func is_stormy() -> bool:
	return bool(get_entry().get("storm",false))

func get_entry() -> Dictionary:
	return _profile.get_entry(today) if _profile!=null and _profile.validation_errors().is_empty() else {}

func serialize() -> Dictionary:
	var saved: Array[String] = []
	for value: StringName in forecast:
		saved.append(String(value))
	return {"world_seed":world_seed,"today":String(today),"forecast":saved,"day_index":_day}

func deserialize(data: Dictionary) -> void:
	if is_busy():
		push_warning("WeatherState: restore blocked while busy")
		return
	var candidate: Dictionary = data.duplicate(true)
	if not candidate.has("day_index"):
		candidate["day_index"] = _day
	var decoded: Dictionary = WeatherSnapshotCodec.decode_at_day(_profile,candidate)
	if not bool(decoded.ok):
		push_warning("WeatherState: invalid snapshot; prior state retained")
		return
	_apply(decoded.snapshot,true)

func restore_for_day(raw: Variant, day: int, default_seed: int = 0) -> Dictionary:
	if is_busy():
		return _failure(&"weather_busy")
	if day<0 or day>WeatherSnapshotCodec.MAX_JSON_INTEGER:
		return _failure(&"invalid_weather")
	var candidate: Variant = raw
	if raw is Dictionary and not raw.has("day_index"):
		candidate = raw.duplicate(true)
		candidate["day_index"] = day
	var decoded: Dictionary = WeatherSnapshotCodec.decode_at_day(_profile,candidate,day)
	if bool(decoded.ok):
		_apply(decoded.snapshot,true)
		return {"ok":true,"reason":&"restored"}
	var fallback: Dictionary = WeatherRoller.initial_snapshot(_profile,default_seed,day)
	if fallback.is_empty():
		return _failure(&"invalid_weather")
	if not (raw is Dictionary and raw.is_empty()):
		push_warning("WeatherState: corrupt load weather; explicit correct-day baseline")
	_apply(fallback,true)
	return {"ok":true,"reason":&"initialized","used_fallback":true}

func _apply(snapshot: Dictionary, notify: bool) -> void:
	world_seed = int(snapshot.world_seed)
	today = StringName(snapshot.today)
	forecast.clear()
	for value: String in snapshot.forecast:
		forecast.append(StringName(value))
	_day = int(snapshot.day_index)
	if notify:
		_publish(true)

func _publish(with_forecast: bool) -> void:
	_notifying = true
	weather_changed.emit(today)
	if with_forecast:
		forecast_updated.emit(forecast.duplicate())
	Events.weather_changed.emit(today)
	if with_forecast:
		Events.forecast_updated.emit(forecast.duplicate())
	_notifying = false

func _failure(reason: StringName) -> Dictionary:
	return {"ok":false,"reason":reason}
