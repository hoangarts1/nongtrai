extends GutTest

const CONFIG: EcologyJournalConfig = preload("res://data/ecology_journal_config.tres")
const PROFILE: EcologyProfile = preload("res://data/ecology_profile.tres")
const LOCALES: Array[String] = ["res://localization/strings_vi.csv", "res://localization/strings_en.csv"]

func _copy() -> EcologyJournalConfig:
	var config: EcologyJournalConfig = CONFIG.duplicate(true) as EcologyJournalConfig
	config.texts = CONFIG.texts.duplicate(true)
	config.rows = CONFIG.rows.duplicate(true)
	return config

func test_shipped_definitions_bind_actual_metrics_thresholds_and_both_locales() -> void:
	assert_eq(CONFIG.rows.size(), 3)
	assert_eq(CONFIG.validation_errors(PROFILE), PackedStringArray())
	assert_eq(DataValidator.validate_ecology_journal(CONFIG, PROFILE, LOCALES), PackedStringArray())
	assert_false(DataValidator.validate_ecology_journal(null, PROFILE, LOCALES).is_empty())
	var keys: PackedStringArray = CONFIG.get_translation_keys()
	assert_true(keys.has("ECO_WATER_NOTE"))
	keys.clear()
	assert_false(CONFIG.get_translation_keys().is_empty())

func test_missing_wrong_text_keys_and_wrong_profile_are_rejected() -> void:
	for value: Variant in [null, false, 1, "bad_key", ""]:
		var config: EcologyJournalConfig = _copy()
		config.texts.title = value
		assert_false(config.validation_errors(PROFILE).is_empty(), str(value))
	var config: EcologyJournalConfig = _copy()
	config.texts.erase("title")
	assert_false(config.validation_errors(PROFILE).is_empty())
	assert_false(CONFIG.validation_errors(null).is_empty())

func test_unknown_duplicate_wrong_threshold_and_count_definitions_reject() -> void:
	for field: String in ["id", "label_key", "hint_key", "threshold_id", "threshold_key", "count_key", "count_text_key"]:
		var config: EcologyJournalConfig = _copy()
		config.rows[0][field] = "unknown"
		assert_false(config.validation_errors(PROFILE).is_empty(), field)
	var duplicate: EcologyJournalConfig = _copy()
	duplicate.rows[1] = duplicate.rows[0].duplicate(true)
	assert_false(duplicate.validation_errors(PROFILE).is_empty())
	var missing: EcologyJournalConfig = _copy()
	missing.rows.pop_back()
	assert_false(missing.validation_errors(PROFILE).is_empty())

func test_valid_key_shape_without_actual_translation_fails_validator() -> void:
	var config: EcologyJournalConfig = _copy()
	config.texts.title = "ECO_MISSING_KEY"
	assert_true(config.validation_errors(PROFILE).is_empty())
	var errors: PackedStringArray = DataValidator.validate_ecology_journal(config, PROFILE, LOCALES)
	assert_false(errors.is_empty())
	assert_true(" ".join(errors).contains("ECO_MISSING_KEY"))
	assert_eq(CONFIG.texts.title, "ECO_TITLE")
