extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/story_fixture.gd")
var f: RefCounted
var flow: LifeStoryMomentFlow
var journal: NpcPanel
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
	flow = f.main.story_moment_flow
	journal = f.main.npc_system.journal
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame
func notebook() -> void:
	f.main.npc_system.open_journal()
	await f.settle(self)
	journal.book_controller.story_controller.open()
	await f.settle(self)
func letter() -> void:
	await notebook()
	await f.mouse(self,journal.book.story_sheet.page_links[0].get_global_rect().get_center())
	await f.settle(self)

func test_vi_en_three_sizes_long_letter_scroll_focus_and_fresh_captures() -> void:
	var captures: int = 0
	var core: Dictionary = f.core_owners()
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]:
			f.viewport.size = dimensions
			await letter()
			for length: String in ["normal","long"]:
				if length=="long": flow.panel.body.body.text = (tr("STORY_PAGE_INTRO_BODY")+" ").repeat(12)
				await f.settle(self)
				assert_true(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(flow.panel.get_global_rect()),str(dimensions))
				for control: Control in [flow.panel.body.title,flow.panel.body.scroll,flow.panel.actions.confirm,flow.panel.actions.cancel]:
					assert_true(flow.panel.get_global_rect().encloses(control.get_global_rect()),str(control.name))
				assert_eq(flow.panel.actions.confirm.text,tr("STORY_CONFIRM"))
				assert_true(flow.panel.is_ancestor_of(f.viewport.gui_get_focus_owner()))
				if length=="long":
					flow.panel.body.scroll.scroll_vertical = int(flow.panel.body.scroll.get_v_scroll_bar().max_value)
					await f.settle(self)
					assert_gt(flow.panel.body.scroll.scroll_vertical,0)
				if DisplayServer.get_name()!="headless":
					f.viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
					await RenderingServer.frame_post_draw
					assert_eq(f.viewport.get_texture().get_image().save_png("user://story_letter_%s_%d_%s.png" % [locale,dimensions.x,length]),OK)
					captures += 1
			flow.back()
			await f.settle(self)
			assert_eq(f.main.story_state.serialize().read_pages,[])
	if DisplayServer.get_name()!="headless": assert_eq(captures,12)
	assert_eq(f.core_owners(),core)
func test_locale_switch_updates_open_letter_without_changing_quote_or_read_flags() -> void:
	await letter()
	var revision: int = f.main.story_state.get_revision()
	for locale: String in ["vi","en","vi"]:
		TranslationServer.set_locale(locale)
		await f.settle(self)
		assert_eq(flow.panel.body.title.text,tr("STORY_PAGE_INTRO"))
		assert_eq(flow.panel.body.body.text,tr("STORY_PAGE_INTRO_BODY"))
		assert_eq(f.main.story_state.get_revision(),revision)
		assert_eq(f.main.story_state.serialize().read_pages,[])
	flow.back()
