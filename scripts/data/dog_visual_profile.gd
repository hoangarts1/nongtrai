## DogVisualProfile - provisional polygon geometry and cosmetic motion DATA.
class_name DogVisualProfile
extends Resource
@export var palette: ArtPalette
@export var parts: Array[Dictionary] = []
@export var cycle_seconds: float = 0.65
@export var stride: float = 2.0
@export var bob: float = 1.2
@export var tail_angle: float = 0.25
@export var outline_width: float = 1.5
@export var name_offset: Vector2 = Vector2(-70, -70)
@export var name_size: Vector2 = Vector2(140, 24)

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if palette == null or not palette.validate().is_empty():
		errors.append("dog visual palette is required")
	for number: float in [cycle_seconds, stride, bob, tail_angle, outline_width, name_size.x, name_size.y]:
		if not is_finite(number) or number <= 0.0:
			errors.append("dog visual motion/size must be finite positive")
	if not name_offset.is_finite() or parts.is_empty():
		errors.append("dog visual geometry is required")
	for part: Dictionary in parts:
		if part.size() != 5 or not part.get("points") is PackedVector2Array or not part.get("pivot") is Vector2 or not part.get("phase") is float or not part.get("role") is String or not part.get("motion") is String:
			errors.append("invalid dog visual part")
			continue
		if part.points.size() < 3 or not part.pivot.is_finite() or not is_finite(part.phase) or not ["static", "ground", "leg", "tail"].has(part.motion) or not ["cream", "brown", "outline", "shadow"].has(part.role):
			errors.append("invalid dog visual role or shape")
		for point: Vector2 in part.points:
			if not point.is_finite():
				errors.append("nonfinite dog visual point")
	return errors

func frozen_copy() -> DogVisualProfile:
	var copy: DogVisualProfile = duplicate(false) as DogVisualProfile
	copy.palette = palette.duplicate(true) as ArtPalette if palette != null else null
	copy.parts = parts.duplicate(true)
	return copy

func color(role: String) -> Color:
	match role:
		"cream": return palette.sunlight_color
		"brown": return palette.wood_color
		"shadow": return Color(palette.shadow_tint, 0.35)
	return palette.outline_color
