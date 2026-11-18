## AmbientAudioProfile — validated replaceable cosmetic audio data, no world state.
## API: validation_errors()->PackedStringArray; get_track(id:StringName)->Dictionary.
class_name AmbientAudioProfile
extends Resource

@export var mix_rate: int = 22050
@export var fade_seconds: float = 0.8
@export var day_start: int = 360
@export var afternoon_start: int = 720
@export var night_start: int = 1200
@export var tracks: Array[Dictionary] = []
@export var zones: Array[Dictionary] = []
@export var day_by_zone: Dictionary = {}
@export var night_track: StringName
@export var rain_track: StringName
@export var morning_music: StringName
@export var afternoon_music: StringName

func get_track(id: StringName) -> Dictionary:
	for row: Dictionary in tracks:
		if row.get("id") == id:
			return row.duplicate(true)
	return {}

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if mix_rate < 8000 or mix_rate > 48000:
		errors.append("audio mix rate must be 8000..48000")
	if not is_finite(fade_seconds) or fade_seconds <= 0.0 or fade_seconds > 10.0:
		errors.append("audio fade must be finite and within (0,10]")
	if day_start < 0 or day_start >= afternoon_start or afternoon_start >= night_start or night_start >= 1440:
		errors.append("audio time bands must be ordered within a day")
	if tracks.is_empty() or tracks.size() > 64:
		errors.append("audio tracks must be nonempty and bounded")
	var ids: Dictionary = {}
	var pattern: RegEx = RegEx.new()
	pattern.compile("^[a-z][a-z0-9_]*$")
	for row: Dictionary in tracks:
		var id: Variant = row.get("id")
		if not _id(id) or pattern.search(String(id)) == null:
			errors.append("audio track id must be snake_case")
			continue
		var key: StringName = StringName(id)
		if ids.has(key):
			errors.append("duplicate audio track id")
		ids[key] = row.get("bus")
		if not row.get("path") is String or row.path != "res://assets/audio/%s.wav" % id:
			errors.append("audio path must match its canonical id")
		if not _id(row.get("bus")) or StringName(row.bus) not in [&"Music", &"Ambience"]:
			errors.append("audio track bus must be Music or Ambience")
		if not _number(row.get("gain")) or float(row.gain) < 0.0 or float(row.gain) > 1.0:
			errors.append("audio track gain must be finite 0..1")
		if not _number(row.get("seconds")) or float(row.seconds) < 2.0 or float(row.seconds) > 60.0:
			errors.append("audio duration must be finite 2..60 seconds")
	for zone: String in ["farm", "forest", "village", "water"]:
		var id: Variant = day_by_zone.get(zone)
		if not _id(id) or ids.get(StringName(id)) != &"Ambience":
			errors.append("day zone must reference an ambience track")
	for id: StringName in [night_track, rain_track]:
		if ids.get(id) != &"Ambience":
			errors.append("night/rain must reference ambience tracks")
	for id: StringName in [morning_music, afternoon_music]:
		if ids.get(id) != &"Music":
			errors.append("music time band must reference a music track")
	for row: Dictionary in zones:
		var region: Variant = row.get("region")
		if not _id(row.get("zone")) or not day_by_zone.has(String(row.zone)):
			errors.append("audio zone is unknown")
		if not region is Rect2i or region.size.x <= 0 or region.size.y <= 0:
			errors.append("audio zone must have a positive cell rectangle")
	return errors

static func _number(value: Variant) -> bool:
	return (value is float or value is int) and is_finite(float(value))

static func _id(value: Variant) -> bool:
	return (value is String or value is StringName) and not String(value).is_empty()
