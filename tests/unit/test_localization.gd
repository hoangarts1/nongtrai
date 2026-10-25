extends GutTest

const VALIDATOR_SCRIPT: Script = preload("res://scripts/core/data_validator.gd")

func test_default_locale_is_vietnamese() -> void:
	TranslationServer.set_locale("en")
	Localization.apply_default_locale()
	assert_eq(TranslationServer.get_locale(), "vi")
	assert_eq(tr("UI_INVENTORY_TITLE"), "KHO ĐỒ")

func test_every_english_key_has_non_empty_vietnamese_value() -> void:
	var errors: PackedStringArray = VALIDATOR_SCRIPT.validate_vietnamese_values(
		"res://localization/strings_en.csv",
		"res://localization/strings_vi.csv"
	)
	assert_true(errors.is_empty(), str(errors))

func test_data_names_are_translation_keys_and_render_in_vietnamese() -> void:
	var seed_data: Resource = DataRegistry.get_item(&"turnip_seed")
	var crop_data: Resource = DataRegistry.get_crop(&"turnip")
	assert_eq(String(seed_data.get("display_name_key")), "ITEM_TURNIP_SEED")
	assert_eq(tr(String(seed_data.get("display_name_key"))), "Hạt củ cải")
	assert_eq(String(crop_data.get("display_name_key")), "CROP_TURNIP")
	assert_eq(tr(String(crop_data.get("display_name_key"))), "Củ cải")
