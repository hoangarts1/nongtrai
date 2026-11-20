extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/neighbor_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_both_neighbors_locales_three_sizes_use_actual_portraits_text_and_native_close() -> void:
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]:
			f.viewport.size = dimensions
			for id: StringName in [&"an",&"bac_lam"]:
				await f.converse(self,id)
				await f.settle(self)
				var screen: LifeDialogueScreen = f.main.npc_system.dialogue.dialogue_screen
				assert_true(screen.visible)
				var npc: NpcData = f.main.npc_system.state.get_npc(id)
				assert_eq(screen.speaker.name_label.text,tr(String(npc.display_name_key)))
				assert_eq(screen.body.text.text,tr("DIALOGUE_AN_INTRO" if id==&"an" else "DIALOGUE_LAM_INTRO"))
				assert_true(screen.get_global_rect().encloses(screen.close_button.get_global_rect()))
				assert_true(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(screen.get_global_rect()))
				assert_eq(f.main.npc_system.workplaces[id].label.text,tr(String(npc.workplace_title_key)))
				if DisplayServer.get_name()!="headless":
					f.viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
					await RenderingServer.frame_post_draw
					assert_eq(f.viewport.get_texture().get_image().save_png("user://neighbor_%s_%s_%d.png" % [id,locale,dimensions.x]),OK)
				await f.mouse(self,screen.close_button.get_global_rect().get_center())
				assert_false(f.main.npc_system.dialogue.visible)
				assert_false(screen.is_visible_in_tree())
	assert_eq(f.main.npc_system.state.get_introduced_ids(),PackedStringArray(["an","bac_lam"]))
	assert_true(f.main.story_state.serialize().completed_objectives.has("meet_neighbors"))

func test_live_locale_and_keyboard_escape_keep_real_history_without_reopening_or_repeating_intro() -> void:
	await f.converse(self,&"bac_lam")
	var before: Dictionary = f.owners()
	var text: String = f.main.npc_system.dialogue.dialogue_screen.body.text.text
	TranslationServer.set_locale("en" if TranslationServer.get_locale().begins_with("vi") else "vi")
	await f.settle(self)
	assert_ne(f.main.npc_system.dialogue.dialogue_screen.body.text.text,text)
	assert_eq(f.owners(),before)
	await f.key(self,KEY_ESCAPE)
	assert_false(f.main.npc_system.dialogue.visible)
	assert_eq(f.owners(),before)
