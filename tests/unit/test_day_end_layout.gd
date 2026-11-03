extends GutTest

var _clock: Dictionary
var _paused: bool
var _locale: String

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	GameClock.paused = true

func after_each() -> void:
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)

func test_summary_fits_reference_regions_both_languages_three_sizes_and_states() -> void:
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for extent: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]:
			GameClock.deserialize({})
			GameClock.paused = true
			var viewport: SubViewport = SubViewport.new()
			viewport.size = extent
			viewport.world_2d = World2D.new()
			viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			add_child(viewport)
			var main: Node = preload("res://scenes/main/main.tscn").instantiate()
			viewport.add_child(main)
			main.start_menu.hide()
			main.tutorial_panel.close_help()
			main.ui_coordinator.close_active()
			main.set("_game_started",true)
			main.day_end_flow.reset()
			main.wallet.add_coins(350,&"gift")
			assert_true(main.seed_shop_panel.try_buy_item(&"turnip_seed",4))
			main.inventory.add_item(&"turnip",3)
			main.shipping_bin_panel.call("_select_item",&"turnip")
			main.shipping_bin_panel.call("_set_max_quantity")
			main.shipping_bin_panel.call("_confirm_sale")
			main.farm_state.till_cell(Vector2i(0,0))
			main.farm_state.plant_crop(Vector2i(0,0),&"turnip")
			GameClock.set_time(20,0)
			var flow: LifeDayEndFlow = main.day_end_flow
			assert_true(flow.request())
			for mode: String in ["manual","partial","forced"]:
				if mode=="partial":
					flow.ledger.complete = false
				elif mode=="forced":
					flow.cancel()
					var weather_data: Dictionary = main.weather_state.serialize()
					weather_data["forecast"] = ["rain","sunny","cloudy"]
					main.weather_state.deserialize(weather_data)
					GameClock.set_time(25,59)
					GameClock.advance_minutes(1)
				flow.call("_refresh")
				for frame: int in range(10):
					await get_tree().process_frame
				var sheet: LifeDayEndSheet = flow.panel
				assert_true(Rect2(Vector2.ZERO,Vector2(extent)).encloses(sheet.get_global_rect()),"Sheet fits %s %s %s: %s min %s" % [locale,extent,mode,sheet.get_global_rect(),sheet.get_combined_minimum_size()])
				for control: Control in [sheet.title,sheet.ledger_view,sheet.tomorrow,sheet.warning,sheet.continue_button,sheet.stay_button]:
					if control.is_visible_in_tree():
						assert_true(sheet.get_global_rect().encloses(control.get_global_rect()),"Child fits: %s %s %s rect=%s" % [control.get_class(),locale,extent,control.get_global_rect()])
				assert_false(sheet.ledger_view.get_global_rect().intersects(sheet.tomorrow.get_global_rect()))
				assert_true(sheet.warning.visible,"Actual unwatered crop is reported")
				assert_eq(sheet.tomorrow.symbol.weather_id,StringName(main.weather_state.forecast[0]))
				assert_lte(sheet.ledger_view.scroll.get_h_scroll_bar().max_value,sheet.ledger_view.scroll.size.x+1)
				if DisplayServer.get_name() != "headless":
					await RenderingServer.frame_post_draw
					var image: Image = viewport.get_texture().get_image()
					assert_eq(image.save_png("user://iso4_%s_%s_%d.png" % [locale,mode,extent.x]),OK)
			viewport.free()
			await get_tree().process_frame
