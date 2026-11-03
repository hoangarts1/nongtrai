extends GutTest

const SIZES: Array[Vector2i] = [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]
var _clock: Dictionary
var _paused: bool
var _locale: String
var _preference_locale: String
var _viewport: SubViewport
var _main: Node

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	_preference_locale = Settings.get_locale()
	GameClock.paused = true
	SaveService.delete_save(0)
	SaveService.delete_save(1)

func after_each() -> void:
	if is_instance_valid(_viewport):
		_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	Settings.set_locale(_preference_locale)
	TranslationServer.set_locale(_locale)
	SaveService.delete_save(0)
	SaveService.delete_save(1)

func _avatar_view() -> SubViewport:
	var result: SubViewport = SubViewport.new()
	result.size = Vector2i(128,96)
	result.transparent_bg = true
	result.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(result)
	return result

func _avatar(view: SubViewport) -> PlaceholderAvatar2D:
	var result: PlaceholderAvatar2D = PlaceholderAvatar2D.new()
	result.position = Vector2(64,72)
	view.add_child(result)
	return result

func _pixels(view: SubViewport) -> PackedByteArray:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	return view.get_texture().get_image().get_data()

func test_six_native_hair_silhouettes_are_distinct_and_npc_arc_restores() -> void:
	var view: SubViewport = _avatar_view()
	var avatar: PlaceholderAvatar2D = _avatar(view)
	var legacy: Dictionary = {"skin_color":avatar.skin,"hair_color":avatar.hair,"outfit_color":avatar.outfit}
	avatar.configure_profile(legacy,{})
	var original: PackedByteArray = await _pixels(view)
	var images: Array[PackedByteArray] = []
	var options: Dictionary = LifeProfileChoices.CATALOG.call("get_player_customization")
	for style: String in options.hair_styles:
		avatar.configure_profile({},{"hair_style":style})
		assert_eq(avatar.get_hair_style(),StringName(style))
		var pixels: PackedByteArray = await _pixels(view)
		assert_false(pixels == original,"Player hair differs from the legacy NPC arc: "+style)
		for previous: PackedByteArray in images:
			assert_false(pixels == previous,"Distinct native-scale silhouette: "+style)
		images.append(pixels)
	assert_eq(images.size(),6)
	avatar.configure_profile(legacy,{})
	assert_eq(avatar.get_hair_style(),&"")
	assert_true((await _pixels(view)) == original,"NPC/no-player customization retains exact prior rendering")
	view.free()

func test_preview_and_game_configuration_render_identical_pixels_for_all_choices() -> void:
	var preview_view: SubViewport = _avatar_view()
	var game_view: SubViewport = _avatar_view()
	var preview: PlaceholderAvatar2D = _avatar(preview_view)
	var game: PlaceholderAvatar2D = _avatar(game_view)
	var base: Resource = LifeProfileChoices.CATALOG.call("get_default_player_appearance")
	var profile: Dictionary = base.call("to_builder_dictionary")
	var options: Dictionary = LifeProfileChoices.CATALOG.call("get_player_customization")
	for index: int in range(6):
		var selection: Dictionary = {"hair_style":options.hair_styles[index],"skin_index":index,"hair_color_index":index,"outfit_color_index":index}
		preview.configure_profile({},selection)
		game.configure_profile(profile,selection)
		assert_eq(preview.get_hair_style(),game.get_hair_style())
		assert_eq(preview.skin,game.skin)
		assert_eq(preview.hair,game.hair)
		assert_eq(preview.outfit,game.outfit)
		var preview_bytes: PackedByteArray = await _pixels(preview_view)
		var game_bytes: PackedByteArray = await _pixels(game_view)
		assert_true(preview_bytes == game_bytes,"Same shared renderer at native scale: "+String(options.hair_styles[index]))
	preview_view.free()
	game_view.free()

func test_creation_layout_captures_all_choices_and_long_names_in_both_locales() -> void:
	_viewport = SubViewport.new()
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)
	for locale: String in ["vi","en"]:
		Settings.set_locale(locale)
		for dimensions: Vector2i in SIZES:
			_viewport.size = dimensions
			_main = preload("res://scenes/main/main.tscn").instantiate()
			_viewport.add_child(_main)
			_main.start_menu.call("_show_new_game_fields")
			var form: LifeTitleProfileForm = _main.start_menu.screen.profile
			form.player_name.text = "Mai"
			form.farm_name.text = "Mùa An Lành"
			for index: int in range(6):
				for row: LifeProfileChoiceRow in [form.hair_style,form.skin_tone,form.hair_color,form.outfit_color]:
					row.select(index)
				form.presenter.refresh()
				await _settle()
				_check_layout(form,dimensions)
				assert_eq(form.preview.player_caption.text,"Mai")
				assert_eq(form.preview.avatar.get_hair_style(),StringName(form.get_selection().hair_style))
				await _capture("%s_choice%d_%d" % [locale,index,dimensions.x])
			form.player_name.text = "Nông dân ẩn ệ ữ ợ ỡ ằ ẫ — A very long gardener name"
			form.farm_name.text = "Trang trại Mùa An Lành — A very long peaceful farm name"
			form.presenter.refresh()
			await _settle()
			_check_layout(form,dimensions)
			assert_eq(form.player_name.text,form.preview.player_caption.tooltip_text,"Display truncation never edits the draft")
			await _capture("%s_long_%d" % [locale,dimensions.x])
			_main.free()

func _check_layout(form: LifeTitleProfileForm, dimensions: Vector2i) -> void:
	var bounds: Rect2 = Rect2(Vector2.ZERO,Vector2(dimensions))
	var modal: Rect2 = _main.start_menu.get_global_rect()
	assert_true(bounds.encloses(modal))
	for control: Control in [form.confirm_button,form.back_button,form.preview,form.preview.previous_button,form.preview.next_button,form.preview.player_caption,form.preview.farm_caption]:
		assert_true(modal.encloses(control.get_global_rect()),"Visible fixed region fits: %s %s / %s" % [control.name,control.get_global_rect(),modal])
	assert_false(form.preview.get_global_rect().intersects(form.confirm_button.get_global_rect()))
	assert_true(form.player_name.is_visible_in_tree())
	assert_eq(_main.ui_coordinator.get_active_panel(),_main.start_menu)
	assert_true(GameClock.paused)
	assert_false(_main.world.player.movement_enabled)
	assert_false(bool(_main.get("_game_started")))

func _capture(id: String) -> void:
	await RenderingServer.frame_post_draw
	assert_eq(_viewport.get_texture().get_image().save_png("user://iso8b_%s.png" % id),OK)

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
