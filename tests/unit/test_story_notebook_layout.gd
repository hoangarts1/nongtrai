extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/story_fixture.gd")
var f: RefCounted
var panel: NpcPanel
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
	panel = f.main.npc_system.journal
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame
func open_book() -> LifeStoryNotebook:
	f.main.npc_system.open_journal()
	await f.settle(self)
	await f.mouse(self,panel.book.story_button.get_global_rect().get_center())
	return panel.book.story_sheet

func test_three_sizes_both_locales_long_text_scroll_and_fresh_native_captures() -> void:
	var captures: int = 0
	var sheet: LifeStoryNotebook = await open_book()
	assert_not_null(sheet)
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]:
			f.viewport.size = dimensions
			for state: String in ["initial","long"]:
				if state=="long": f.main.story_state.observe(LifeStorySnapshot.CONFIG.supported_ids())
				else: f.main.story_state.deserialize(StorySnapshotCodec.empty())
				panel.book_controller.story_controller.queue_render()
				await f.settle(self)
				if state=="long":
					for row: LifeStoryMilestoneRow in sheet.milestones.rows: row.description.text = (row.description.text+" ").repeat(8)
					await f.settle(self)
				assert_true(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(panel.get_global_rect()),str(dimensions))
				for control: Control in [panel.book.tabs,panel.book.story_button,panel.book.ecology_button,sheet.header,sheet.objectives.scroll,sheet.milestones.scroll,sheet.back_button]:
					assert_true(panel.get_global_rect().encloses(control.get_global_rect()),str(control.name))
				assert_eq(sheet.objectives.rows.size(),10)
				assert_eq(sheet.milestones.rows.size(),4)
				for position: String in ["top","bottom"]:
					for scroller: ScrollContainer in [sheet.objectives.scroll,sheet.milestones.scroll]:
						scroller.scroll_vertical = 0 if position=="top" else int(scroller.get_v_scroll_bar().max_value)
					await f.settle(self)
					if position=="bottom": assert_gt(sheet.objectives.scroll.scroll_vertical,0)
					if DisplayServer.get_name()!="headless":
						f.viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
						await RenderingServer.frame_post_draw
						assert_eq(f.viewport.get_texture().get_image().save_png("user://story_notebook_%s_%d_%s_%s.png" % [locale,dimensions.x,state,position]),OK)
						captures += 1
	if DisplayServer.get_name()!="headless": assert_eq(captures,24)
func test_native_tab_focus_wheel_and_back_stay_inside_active_journal() -> void:
	var sheet: LifeStoryNotebook = await open_book()
	sheet.objectives.scroll.grab_focus()
	await f.key(self,KEY_TAB)
	assert_not_null(f.viewport.gui_get_focus_owner())
	assert_true(panel.is_ancestor_of(f.viewport.gui_get_focus_owner()))
	var point: Vector2 = sheet.objectives.scroll.get_global_rect().get_center()
	for _i: int in range(3):
		for pressed: bool in [true,false]:
			var event: InputEventMouseButton = InputEventMouseButton.new()
			event.position = point
			event.button_index = MOUSE_BUTTON_WHEEL_DOWN
			event.pressed = pressed
			f.viewport.push_input(event,true)
	await f.settle(self)
	assert_gt(sheet.objectives.scroll.scroll_vertical,0)
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = sheet.back_button.get_global_rect().get_center()
	motion.global_position = motion.position
	f.viewport.push_input(motion,true)
	await f.settle(self)
	await f.mouse(self,sheet.back_button.get_global_rect().get_center())
	assert_null(panel.book.story_sheet)
	assert_eq(f.main.ui_coordinator.get_active_panel(),panel)
