extends GutTest
const CONFIG: DogConfig = preload("res://data/dog_config.tres")

func test_vietnamese_unicode_trim_exact_boundary_and_no_silent_truncation() -> void:
	for name: String in [" Sóc ", "Milo", "Mây Nhỏ", "a".repeat(CONFIG.name_max_length), "a" + String.chr(0x0301)]:
		var parsed: Dictionary = DogNameRules.normalize(CONFIG, name)
		assert_true(parsed.ok)
		assert_eq(parsed.name, name.strip_edges())
	assert_false(DogNameRules.normalize(CONFIG, "a".repeat(CONFIG.name_max_length + 1)).ok)
	assert_false(DogNameRules.normalize(CONFIG, "   ").ok)
	assert_true(DogNameRules.normalize(CONFIG, "", true).ok)

func test_controls_lines_format_and_wrong_types_are_explicitly_rejected() -> void:
	for value: Variant in [null, true, 2, [], {}, "\nMilo", "Milo\t", "Mi\rlo"]:
		assert_false(DogNameRules.normalize(CONFIG, value).ok)
	# Pinned native JSON converts NUL to U+FFFD before this layer. The independent
	# nul-probe log records that decoder diagnostic; reject its normalized input.
	var decoded_nul_name: String = "Mi" + String.chr(0xfffd) + "lo"
	assert_false(DogNameRules.normalize(CONFIG, decoded_nul_name).ok)
	for point: int in [31, 127, 159, 0x200b, 0x2028, 0x202e, 0x2066, 0xfeff]:
		assert_false(DogNameRules.normalize(CONFIG, "Mi" + String.chr(point) + "lo").ok)
	assert_false(DogNameRules.normalize(null, "Milo").ok)
