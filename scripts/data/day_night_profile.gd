## DayNightProfile — data-driven keyframes for world lighting.
## API:
##   func sample(minute: int) -> Dictionary
extends Resource
class_name DayNightProfile

@export var keyframes: Array[Dictionary] = []

func sample(minute: int) -> Dictionary:
	if keyframes.is_empty():
		return {}
	var normalized_minute: int = posmod(minute, 1440)
	var previous: Dictionary = keyframes[0]
	var next_frame: Dictionary = keyframes[0]
	for frame: Dictionary in keyframes:
		var frame_minute: int = int(frame.get("minute", 0))
		if frame_minute <= normalized_minute:
			previous = frame
		if frame_minute > normalized_minute:
			next_frame = frame
			break
	if int(next_frame.get("minute", 0)) <= int(previous.get("minute", 0)):
		next_frame = keyframes[0]
	var previous_minute: int = int(previous.get("minute", 0))
	var next_minute: int = int(next_frame.get("minute", 0))
	if next_minute <= previous_minute:
		next_minute += 1440
	var sample_minute: int = normalized_minute
	if sample_minute < previous_minute:
		sample_minute += 1440
	var weight: float = clampf(
		float(sample_minute - previous_minute) / float(next_minute - previous_minute),
		0.0,
		1.0
	)
	return {
		"sun_color": (previous.get("sun_color", Color.WHITE) as Color).lerp(
			next_frame.get("sun_color", Color.WHITE) as Color, weight
		),
		"sun_energy": lerpf(
			float(previous.get("sun_energy", 0.0)),
			float(next_frame.get("sun_energy", 0.0)),
			weight
		),
		"sun_angle": lerpf(
			float(previous.get("sun_angle", -45.0)),
			float(next_frame.get("sun_angle", -45.0)),
			weight
		),
		"ambient_color": (previous.get("ambient_color", Color.WHITE) as Color).lerp(
			next_frame.get("ambient_color", Color.WHITE) as Color, weight
		),
		"ambient_energy": lerpf(
			float(previous.get("ambient_energy", 0.0)),
			float(next_frame.get("ambient_energy", 0.0)),
			weight
		),
		"sky_color": (previous.get("sky_color", Color.BLACK) as Color).lerp(
			next_frame.get("sky_color", Color.BLACK) as Color, weight
		),
		"moon_energy": lerpf(
			float(previous.get("moon_energy", 0.0)),
			float(next_frame.get("moon_energy", 0.0)),
			weight
		)
	}
