extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/story_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_actual_five_goals_notebook_confirmation_review_autosave_and_continue() -> void:
	f.play()
	var cell: Vector2i = Vector2i(1,1)
	f.use(&"hoe",cell)
	f.use(&"seed",cell)
	for _day: int in range(f.main.farm_state.get_growth_target(cell)):
		f.play()
		f.use(&"watering_can",cell)
		GameClock.sleep_to_morning()
		f.main.morning_flow.reset()
	f.play()
	f.use(&"harvest",cell)
	f.main.shipping_bin_panel.call("_select_item",&"turnip")
	f.main.shipping_bin_panel.call("_set_max_quantity")
	f.main.shipping_bin_panel.call("_confirm_sale")
	# Explicit inventory/wallet setup for a real existing transaction, not history.
	f.main.inventory.add_item(&"turnip",3)
	assert_true(f.main.npc_system.state.quests.accept_quest(&"turnip_delivery"))
	assert_true(f.main.npc_system.state.quests.confirm_delivery(&"turnip_delivery",f.main.inventory,f.main.wallet))
	f.main.wallet.add_coins(5000,&"test_story_journey")
	f.main.machine_shop_panel.open()
	f.main.land_runtime.open()
	await f.settle(self)
	await f.mouse(self,f.main.land_runtime.panel.footer.buy_button.get_global_rect().get_center())
	f.main.ui_coordinator.close_active()
	# This fixture ticks the companion manually. Refresh the newly owned farm
	# obstacle just as the live runtime's sparse context poll does before saving.
	f.main.dog_runtime.refresh_context()
	assert_true(f.main.dog_runtime.navigation.is_walkable(f.main.dog_state.get_cell()))
	assert_eq(f.main.story_state.serialize().completed_objectives,Array(LifeStorySnapshot.CONFIG.supported_ids()))
	assert_false(f.main.story_state.is_complete())
	await f.key(self,KEY_J)
	var journal: NpcPanel = f.main.npc_system.journal
	await f.mouse(self,journal.book.story_button.get_global_rect().get_center())
	assert_not_null(journal.book.story_sheet)
	await f.mouse(self,journal.book.story_sheet.page_links[0].get_global_rect().get_center())
	var flow: LifeStoryMomentFlow = f.main.story_moment_flow
	assert_true(flow.panel.visible)
	await f.mouse(self,flow.panel.actions.cancel.get_global_rect().get_center())
	assert_eq(f.main.story_state.serialize().read_pages,[])
	assert_true(flow.open(&"intro"))
	await f.settle(self)
	await f.mouse(self,flow.panel.actions.confirm.get_global_rect().get_center())
	assert_eq(f.main.story_state.serialize().read_pages,["intro"])
	f.main.ui_coordinator.close_active()
	f.main.dog_state.try_set_name("M"+String.chr(0xe2)+"y")
	var dog: Dictionary = f.main.dog_state.serialize()
	var story: Dictionary = f.main.story_state.serialize()
	GameClock.set_time(21,0)
	assert_true(f.main.day_end_flow.request())
	var day: int = GameClock.day_index
	await f.settle(self)
	await f.mouse(self,f.main.day_end_flow.panel.continue_button.get_global_rect().get_center())
	assert_eq(GameClock.day_index,day+1)
	assert_eq(SaveService.load_game(0).story,story)
	assert_eq(SaveService.load_game(0).dog,dog)
	f.main.morning_flow.dismiss()
	f.main.ui_coordinator.close_active()
	assert_true(f.main.call("_save_game_to_slot",98))
	var owners: Dictionary = f.owners()
	assert_true(f.main.call("_load_game_from_slot",98))
	assert_eq(f.owners(),owners)
	assert_true(f.main.call("_return_to_start_menu"))
	await f.settle(self)
	await f.mouse(self,f.main.start_menu.screen.actions.continue_button.get_global_rect().get_center())
	assert_eq(f.owners(),owners)
	assert_eq(f.actors().size(),1)
	assert_false(flow.panel.visible)
	assert_false(f.main.director_state.serialize().enabled)
	assert_eq(f.main.npc_system.content.npcs.size(),2)
func test_fresh_both_locales_three_sizes_and_native_new_game_clear_only_new_story() -> void:
	f.main.story_state.observe(LifeStorySnapshot.CONFIG.supported_ids())
	f.main.story_state.acknowledge_page(&"intro")
	var before: Dictionary = f.owners()
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]:
			f.viewport.size = dimensions
			f.main.npc_system.open_journal()
			await f.settle(self)
			f.main.npc_system.journal.book_controller.story_controller.open()
			await f.settle(self)
			var sheet: LifeStoryNotebook = f.main.npc_system.journal.book.story_sheet
			assert_true(sheet.header.progress.text.contains("5/10"))
			if DisplayServer.get_name()!="headless":
				f.viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
				await RenderingServer.frame_post_draw
				assert_eq(f.viewport.get_texture().get_image().save_png("user://story_journey_%s_%d.png" % [locale,dimensions.x]),OK)
			f.main.ui_coordinator.close_active()
	assert_eq(f.owners(),before)
	assert_true(f.main.call("_return_to_start_menu"))
	await f.settle(self)
	await f.mouse(self,f.main.start_menu.screen.actions.new_game_button.get_global_rect().get_center())
	f.main.start_menu.screen.profile.player_name.text = "Mai"
	f.main.start_menu.screen.profile.farm_name.text = "Garden"
	await f.settle(self)
	await f.mouse(self,f.main.start_menu.screen.profile.confirm_button.get_global_rect().get_center())
	assert_eq(f.main.story_state.serialize(),StorySnapshotCodec.empty())
	assert_eq(f.actors().size(),1)
	assert_false(f.main.story_moment_flow.panel.visible)
