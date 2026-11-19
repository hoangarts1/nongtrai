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

func test_vi_en_three_sizes_long_name_and_native_captures() -> void:
	f.viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	f.main.dog_state.try_set_name("Mây".repeat(8))
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for size: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]:
			f.viewport.size = size
			open_name()
			await f.settle(self)
			var panel: LifeDogNameSheet = f.main.dog_name_flow.panel
			assert_true(Rect2(Vector2.ZERO,Vector2(size)).encloses(panel.get_global_rect()))
			assert_true(panel.get_global_rect().encloses(panel.form.field.get_global_rect()))
			assert_eq(panel.form.field.text,"Mây".repeat(8))
			if DisplayServer.get_name()!="headless":
				await RenderingServer.frame_post_draw
				assert_eq(f.viewport.get_texture().get_image().save_png("user://dog_name_%s_%d.png" % [locale,size.x]),OK)
			f.main.dog_name_flow.back()
			await f.settle(self)
			if DisplayServer.get_name()!="headless":
				await RenderingServer.frame_post_draw
				assert_eq(f.viewport.get_texture().get_image().save_png("user://dog_card_%s_%d.png" % [locale,size.x]),OK)
			f.main.ui_coordinator.close_active()
