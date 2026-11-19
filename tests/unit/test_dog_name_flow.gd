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

func test_invalid_unicode_cancel_commit_and_stale_quote() -> void:
	var flow: LifeDogNameFlow = f.main.dog_name_flow
	open_name()
	assert_true(flow.panel.visible)
	assert_eq(flow.panel.form.field.max_length,0)
	for value: String in ["", "a".repeat(25), "Milo" + String.chr(0x200b)]:
		flow.panel.form.field.text = value
		flow.save()
		assert_eq(f.main.dog_state.get_name(),"")
		assert_true(flow.panel.visible)
	flow.panel.form.field.text = "Mây"
	flow.back()
	assert_eq(f.main.dog_state.get_name(),"")
	assert_true(f.main.character_flow.panel.visible)
	flow.open()
	flow.panel.form.field.text = "Mây"
	flow.save()
	assert_eq(f.main.dog_state.get_name(),"Mây")
	assert_true(f.main.character_flow.panel.visible)
	flow.open()
	f.main.dog_state.try_set_name("Milo")
	flow.panel.form.field.text = "Old"
	flow.save()
	assert_eq(f.main.dog_state.get_name(),"Milo")
	assert_true(flow.panel.visible)
func test_native_mouse_enter_tab_escape_and_lifecycle_close() -> void:
	f.main.character_flow.open()
	await f.settle(self)
	await f.mouse(self,f.main.character_flow.panel.companion.rename.get_global_rect().get_center())
	await f.settle(self)
	var flow: LifeDogNameFlow = f.main.dog_name_flow
	assert_true(flow.panel.visible)
	assert_eq(f.viewport.gui_get_focus_owner(),flow.panel.form.field)
	flow.panel.form.field.clear()
	for entry: Array in [[KEY_M,0x4d],[KEY_A,0xe2],[KEY_Y,0x79]]:
		for pressed: bool in [true,false]:
			var event: InputEventKey = InputEventKey.new()
			event.keycode = entry[0]
			event.physical_keycode = entry[0]
			event.unicode = entry[1]
			event.pressed = pressed
			f.viewport.push_input(event,true)
			await get_tree().process_frame
	assert_eq(flow.panel.form.field.text,"M"+String.chr(0xe2)+"y")
	await f.key(self,KEY_ENTER)
	assert_eq(f.main.dog_state.get_name(),"Mây")
	flow.open()
	await f.settle(self)
	await f.key(self,KEY_TAB)
	assert_ne(f.viewport.gui_get_focus_owner(),flow.panel.form.field)
	await f.key(self,KEY_ESCAPE)
	assert_false(flow.panel.visible)
	assert_false(f.main.character_flow.panel.visible)
	open_name()
	f.main.call("_start_new_game","Mai","Garden")
	assert_false(flow.panel.visible)
	assert_false(f.main.character_flow.panel.visible)
