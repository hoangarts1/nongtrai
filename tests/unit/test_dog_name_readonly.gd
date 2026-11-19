extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/dog_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame
func open_name() -> void:
	f.main.character_flow.open()
	f.main.dog_name_flow.open()

func test_refresh_locale_and_open_cancel_do_not_save_tick_or_consume_rng() -> void:
	var before: Dictionary = f.owners()
	var dog: Dictionary = f.main.dog_state.serialize()
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes("user://saves/slot_1.json")
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for _i: int in range(20):
			open_name()
			f.main.character_flow.refresh()
			LifeDogSnapshot.capture(f.main)
			f.main.dog_name_flow.back()
		assert_eq(f.main.dog_runtime.actor.caption.text,tr("DOG_UNNAMED"))
	assert_eq(f.owners(),before)
	assert_eq(f.main.dog_state.serialize(),dog)
	assert_eq(FileAccess.get_file_as_bytes("user://saves/slot_1.json"),bytes)
