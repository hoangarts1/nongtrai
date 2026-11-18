## AmbientAudioContext — pure cosmetic selection from actual world context.
## API: static select(profile,cell,minute,rainy)->Dictionary{zone,ambience,music}.
class_name AmbientAudioContext
extends RefCounted

static func select(profile: AmbientAudioProfile, cell: Vector2i, minute: int, rainy: bool) -> Dictionary:
	if profile == null or not profile.validation_errors().is_empty():
		return {}
	var zone: StringName = &"farm"
	for row: Dictionary in profile.zones:
		if (row.region as Rect2i).has_point(cell):
			zone = StringName(row.zone)
			break
	var time: int = posmod(minute, 1440)
	var night: bool = time < profile.day_start or time >= profile.night_start
	var ambience: StringName = StringName(profile.day_by_zone[String(zone)])
	if rainy:
		ambience = profile.rain_track
	elif night:
		ambience = profile.night_track
	var music: StringName = &""
	if not night:
		music = profile.morning_music if time < profile.afternoon_start else profile.afternoon_music
	return {"zone": zone, "ambience": ambience, "music": music}
