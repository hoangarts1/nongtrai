extends GutTest

const FIXTURE: Script = preload("res://tests/helpers/director_fixture.gd")
var f: RefCounted
var main: Node

func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
	main = f.main
	await f.settle(self)

func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_native_two_locales_three_sizes_scroll_last_record_focus_and_fresh_captures() -> void:
	await f.prepare_dust(self)
	var flow: LifeDirectorDebugFlow = main.director_debug_flow
	assert_true(flow.open())
	var before: Dictionary = f.owners()
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1920, 1080)]:
			f.viewport.size = dimensions
			await f.settle(self)
			flow.refresh()
			await f.settle(self)
			var panel: LifeDirectorDebugSheet = flow.panel
			assert_true(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(panel.get_global_rect()))
			assert_true(panel.get_global_rect().encloses(panel.close_button.get_global_rect()))
			assert_true(panel.get_global_rect().encloses(panel.hint_label.get_global_rect()))
			assert_gt(panel.scroll.size.y, 100.0)
			assert_eq(panel.banner.caption.text, tr("DIR_DEBUG_TITLE"))
			panel.scroll.scroll_vertical = 0
			await f.settle(self)
			var wheel: InputEventMouseButton = InputEventMouseButton.new()
			wheel.position = panel.scroll.get_global_rect().get_center()
			wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
			wheel.pressed = true
			f.viewport.push_input(wheel, true)
			await f.settle(self)
			assert_gt(panel.scroll.scroll_vertical, 0)
			panel.scroll.ensure_control_visible(panel.trace_panel.body_label)
			await f.settle(self)
			assert_true(panel.scroll.get_global_rect().intersects(panel.trace_panel.body_label.get_global_rect()))
			panel.close_button.grab_focus()
			assert_eq(f.viewport.gui_get_focus_owner(), panel.close_button)
			if DisplayServer.get_name() != "headless":
				f.viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
				await RenderingServer.frame_post_draw
				var picture: Image = f.viewport.get_texture().get_image()
				assert_eq(picture.get_size(), dimensions)
				assert_eq(picture.save_png("user://director_debug_%s_%dx%d.png" % [locale, dimensions.x, dimensions.y]), OK)
			assert_eq(f.owners(), before)
