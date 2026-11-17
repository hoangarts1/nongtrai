extends GutTest
var main: Node
var viewport: SubViewport
var clock: Dictionary
var paused: bool
var locale: String

func before_each() -> void:
	clock = GameClock.serialize()
	paused = GameClock.paused
	locale = TranslationServer.get_locale()
	viewport = SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.world_2d = World2D.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)

func _create_world() -> void:
	if is_instance_valid(main):
		main.free()
	main = preload("res://scenes/main/main.tscn").instantiate()
	viewport.add_child(main)
	main.call("_start_new_game","Mai","Garden")
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	GameClock.paused = true
	for cell: Vector2i in [Vector2i(1,2),Vector2i(2,2),Vector2i(3,2)]:
		main.farm_state.till_cell(cell)
		main.farm_state.plant_crop(cell,&"turnip")
	for day: int in range(2):
		main.farm_state.water_all_crops()
		main.farm_state.advance_day()
	main.machine_inventory.add_machine(&"stove",1)
	main.machine_build.place(&"stove",Vector2i(2,3),0)
	main.inventory.add_item(&"carrot",2)
	main.machine_operations.start(Vector2i(2,3),&"stove_carrot_meal",1)
	main.machine_presentation.refresh()

func after_each() -> void:
	viewport.free()
	GameClock.deserialize(clock)
	GameClock.paused = paused
	TranslationServer.set_locale(locale)
	SaveService.delete_save(1)

func test_draft_asset_contracts_and_real_vi_en_world_ui_appearance_matrix() -> void:
	assert_true(DataValidator.validate_isometric_2d_assets().is_empty())
	assert_eq(DataValidator.validate_isometric_2d_assets("user://d72_missing_assets").size(),5)
	var path: String = "user://d72_wrong_assets/buildings/cottage_2x.png"
	assert_eq(DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir())),OK)
	var wrong: Image = Image.create(8,8,false,Image.FORMAT_RGBA8)
	wrong.fill(Color.TRANSPARENT)
	assert_eq(wrong.save_png(path),OK)
	var errors: PackedStringArray = DataValidator.validate_isometric_2d_assets("user://d72_wrong_assets")
	assert_true(" ".join(errors).contains("size mismatch"))
	for language: String in ["vi","en"]:
		TranslationServer.set_locale(language)
		# World anchors and transient feedback are localized when created, not retranslated.
		_create_world()
		var anchor: Vector2 = main.world.objects.get_node("House").global_position
		for dimensions: Vector2i in [Vector2i(1152,648),Vector2i(1600,900)]:
			viewport.size = dimensions
			main.ui_coordinator.close_active()
			GameClock.set_time(11,0)
			main.weather_state.call("force_weather",&"sunny")
			for index: int in [0,1,4]:
				main.world.camera_rig.set("_zoom_index",index)
				main.world.camera_rig.reset_pan()
				main.world.camera_rig.call("_process",0.0)
				await _capture("%s_%d_zoom%d" % [language,dimensions.x,index])
				assert_eq(main.world.objects.get_node("House").global_position,anchor)
			main.world.camera_rig.set("_zoom_index",1)
			main.world.camera_rig.call("_process",0.0)
			main.inventory_panel.toggle_inventory()
			await _capture("%s_%d_bag" % [language,dimensions.x])
			main.inventory_panel.close_inventory()
		GameClock.set_time(22,0)
		main.weather_state.call("force_weather",&"rain")
		await _capture("%s_night_rain" % language)
		main.start_menu.show()
		main.start_menu.call("_show_new_game_fields")
		await _settle()
		var form: LifeTitleProfileForm = main.start_menu.screen.profile
		assert_eq(form.hair_style.item_count,6)
		assert_eq(form.skin_tone.item_count,6)
		assert_eq(form.hair_color.item_count,6)
		assert_eq(form.outfit_color.item_count,6)
		var before: Dictionary = _owners()
		for index: int in range(6):
			form.hair_style.buttons[index].pressed.emit()
			assert_eq(form.preview.avatar.get_hair_style(),StringName(form.get_selection().hair_style))
		form.skin_tone.buttons[4].pressed.emit()
		form.hair_color.buttons[3].pressed.emit()
		form.outfit_color.buttons[2].pressed.emit()
		var resolved: Dictionary = LifeProfileChoices.CATALOG.call("resolve_player",form.get_selection())
		assert_eq(form.preview.avatar.skin,resolved.skin_color)
		assert_eq(form.preview.avatar.hair,resolved.hair_color)
		assert_eq(form.preview.avatar.outfit,resolved.outfit_color)
		assert_eq(_owners(),before,"Appearance preview keeps actual game owners unchanged")
		await _capture("%s_profile" % language)
		main.start_menu.hide()

func _owners() -> Dictionary:
	return {"farm":main.farm_state.serialize(),"inventory":main.inventory.serialize(),"wallet":main.wallet.serialize(),"jobs":main.machine_operations.serialize(),"land":main.land_ownership.serialize(),"profile":main.profile.duplicate(true),"weather":main.weather_state.serialize(),"clock":GameClock.serialize()}

func _settle() -> void:
	var previous: Array[Rect2] = []
	var stable: int = 0
	for frame: int in range(90):
		await get_tree().process_frame
		var rects: Array[Rect2] = [main.inventory_panel.get_global_rect(),main.start_menu.get_global_rect(),main.hotbar_panel.get_global_rect()]
		var pending: bool = main.ui_coordinator._layout_queued or main.inventory_panel.controller._queued
		stable = stable+1 if not pending and rects==previous else 0
		previous = rects
		if stable>=2:
			return
	assert_true(false,"D72 visual layout did not settle within90 frames")

func _capture(stem: String) -> void:
	if main.inventory_panel.visible or main.start_menu.visible:
		await _settle()
	else:
		# World zoom is applied synchronously; wait for actual queued UI work only.
		for frame: int in range(90):
			await get_tree().process_frame
			if not main.ui_coordinator._layout_queued and not main.inventory_panel.controller._queued:
				break
		assert_false(main.ui_coordinator._layout_queued or main.inventory_panel.controller._queued,"D72 world capture has pending layout")
	var bounds: Rect2 = Rect2(Vector2.ZERO,Vector2(viewport.size)).grow(1)
	if main.inventory_panel.visible:
		assert_true(bounds.encloses(main.inventory_panel.get_global_rect()),stem+" bag bounds")
	if main.start_menu.visible:
		assert_true(bounds.encloses(main.start_menu.get_global_rect()),stem+" profile bounds")
	var before: Dictionary = _owners()
	if DisplayServer.get_name()!="headless":
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		assert_eq(viewport.get_texture().get_image().save_png("user://d72_c1_%s.png" % stem),OK)
	assert_eq(_owners(),before,stem+" drawing cannot advance gameplay")
