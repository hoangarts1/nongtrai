extends GutTest
const PROFILE: DogVisualProfile = preload("res://data/art/characters/dog_visual_profile.tres")
func test_shipped_visual_data_and_detached_finite_geometry() -> void:
	assert_eq(PROFILE.validation_errors(), PackedStringArray())
	assert_eq(DataValidator.validate_dog_visual(PROFILE), PackedStringArray())
	var copy: DogVisualProfile = PROFILE.frozen_copy()
	copy.palette.wood_color = Color.MAGENTA
	copy.parts[0].points = PackedVector2Array([Vector2(NAN, 0),Vector2.ZERO,Vector2.ONE])
	assert_false(copy.validation_errors().is_empty())
	assert_eq(PROFILE.validation_errors(), PackedStringArray())
	assert_ne(copy.palette.wood_color, PROFILE.palette.wood_color)
func test_missing_invalid_and_nonfinite_profile_is_rejected() -> void:
	assert_false(DataValidator.validate_dog_visual(null).is_empty())
	for key: String in ["cycle_seconds", "stride", "bob", "tail_angle", "outline_width"]:
		var copy: DogVisualProfile = PROFILE.frozen_copy()
		copy.set(key, INF)
		assert_false(copy.validation_errors().is_empty())
	var copy: DogVisualProfile = PROFILE.frozen_copy()
	copy.parts[0].motion = "unknown"
	assert_false(copy.validation_errors().is_empty())
