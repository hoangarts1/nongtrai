extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/chicken_coop_fixture.gd")
var f: RefCounted
var main: Node

func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
	main = f.main

func after_each() -> void:
	await get_tree().process_frame
	f.cleanup()

func test_native_e_space_escape_and_bag_use_existing_pause_owner() -> void:
	main.wallet.deserialize({"coins":1000})
	main.world.player.move_to_cell(main.chicken_coop_runtime.CONFIG.entrance)
	GameClock.paused = false
	main.ui_coordinator._sync()
	await f.key(self,KEY_E)
	var panel: LifeChickenCoopScreen = main.chicken_coop_flow.panel
	assert_true(panel.visible)
	assert_true(GameClock.paused)
	assert_false(main.world.player.movement_enabled)
	panel.controls.buy.grab_focus()
	await f.key(self,KEY_SPACE)
	assert_true(main.chicken_coop.is_owned())
	assert_eq(main.wallet.get_coins(),300)
	await f.key(self,KEY_TAB)
	assert_not_null(f.viewport.gui_get_focus_owner())
	await f.key(self,KEY_ESCAPE)
	assert_false(panel.visible)
	assert_false(GameClock.paused)
	assert_true(main.world.player.movement_enabled)
	GameClock.paused = true
	await f.key(self,KEY_E)
	panel.controls.back.pressed.emit()
	assert_true(main.inventory_panel.visible)
	await f.key(self,KEY_ESCAPE)
	assert_true(GameClock.paused)

func test_vi_en_three_sizes_four_states_fit_and_render_without_owner_changes() -> void:
	for language: String in ["vi","en"]:
		TranslationServer.set_locale(language)
		for dimensions: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1600,900)]:
			f.viewport.size = dimensions
			for state: String in ["unaffordable","available","fed","eggs_full"]:
				main.chicken_coop_flow.close()
				main.chicken_coop_runtime.reset()
				main.inventory.deserialize({"capacity":40,"slots":[]})
				f.open(100 if state=="unaffordable" else 2000)
				if state=="fed" or state=="eggs_full":
					main.chicken_coop_flow.command(&"buy_coop",4)
					main.chicken_coop_flow.command(&"buy_feed",4)
					main.chicken_coop_flow.command(&"feed",4)
					if state=="eggs_full":
						main.chicken_coop_flow.close()
						GameClock.sleep_to_morning()
						main.morning_flow.dismiss()
						main.chicken_coop_flow.open()
						main.inventory.deserialize({"capacity":1,"slots":[{"item_id":"egg","quantity":99}]})
						main.chicken_coop_flow.command(&"collect",4)
				main.chicken_coop_flow.refresh()
				await f.settle(self)
				var panel: LifeChickenCoopScreen = main.chicken_coop_flow.panel
				assert_true(panel.visible)
				assert_eq(panel.banner.caption.text,tr("COOP_TITLE"))
				for node: Node in panel.find_children("*","Control",true,false):
					var control: Control = node as Control
					if control.is_visible_in_tree():
						assert_true(panel.get_global_rect().grow(1).encloses(control.get_global_rect()),state+" "+String(control.name))
				assert_true(Rect2(Vector2.ZERO,Vector2(dimensions)).grow(1).encloses(panel.get_global_rect()),"%s %s actual=%s min=%s" % [language,state,panel.get_global_rect(),panel.get_combined_minimum_size()])
				await _capture("%s_%d_%s" % [language,dimensions.x,state])

func test_world_unowned_owned_vi_en_keep_progress_and_clear_access_scenery() -> void:
	for language: String in ["vi","en"]:
		TranslationServer.set_locale(language)
		for owned: bool in [false,true]:
			main.chicken_coop_flow.close()
			main.chicken_coop_runtime.reset()
			f.open(2000)
			if owned:
				main.chicken_coop_flow.command(&"buy_coop",4)
			main.chicken_coop_flow.close()
			main.world.camera_rig.set_target(main.world.player)
			main.world.camera.global_position = main.world.cell_to_global(main.chicken_coop_runtime.CONFIG.entrance)
			await f.settle(self)
			var reserved: Dictionary = main.chicken_coop_runtime.CONFIG.reserved_cells()
			for child: Node in main.presentation.get_world_art_root().get_children():
				assert_false(reserved.has(child.get_meta("cell",Vector2i(-99,-99))))
			await _capture("%s_world_%s" % [language,"owned" if owned else "unowned"])

func _capture(stem: String) -> void:
	var before: Dictionary = f.owners()
	if DisplayServer.get_name()!="headless":
		f.viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		assert_eq(f.viewport.get_texture().get_image().save_png("user://phase66d_%s.png" % stem),OK)
	assert_eq(f.owners(),before,"Rendering cannot change owner state")
