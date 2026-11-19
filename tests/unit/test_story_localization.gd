extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/story_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame
func test_all_story_keys_have_vi_en_and_report_missing_locale() -> void:
	var locales: Array[String] = ["res://localization/strings_vi.csv","res://localization/strings_en.csv"]
	var keys: PackedStringArray = LifeStorySnapshot.CONFIG.translation_keys()+LifeStoryPresenter.KEYS
	assert_true(DataValidator.validate_story_text(locales,keys).is_empty())
	assert_false(DataValidator.validate_story_text(locales,PackedStringArray(["STORY_MISSING_TEST_ONLY"])).is_empty())
func test_locale_refresh_is_readonly_and_never_calls_supported_progress_complete() -> void:
	f.main.story_state.observe(LifeStorySnapshot.CONFIG.supported_ids())
	var before: Dictionary = f.owners()
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes("user://saves/slot_1.json")
	var titles: PackedStringArray = []
	for locale: String in ["vi","en","vi"]:
		TranslationServer.set_locale(locale)
		var model: Dictionary = LifeStoryPresenter.describe(LifeStorySnapshot.capture(f.main))
		titles.append(model.title)
		assert_ne(model.title,"STORY_CHAPTER_1")
		assert_true(model.progress.contains("5/10"))
		assert_false(model.chapter_complete)
		for row: Dictionary in model.milestones: assert_eq(row.status,tr("STORY_PLANNED"))
	assert_ne(titles[0],titles[1])
	assert_eq(titles[0],titles[2])
	assert_eq(f.owners(),before)
	assert_eq(FileAccess.get_file_as_bytes("user://saves/slot_1.json"),bytes)
