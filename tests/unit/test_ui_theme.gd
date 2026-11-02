extends GutTest

func test_theme_has_exact_kit_tokens_shared_frames_and_all_button_states() -> void:
	var theme: Theme = LifeTheme.get_theme()
	assert_not_null(theme)
	for token: StringName in LifeThemeFactory.COLORS:
		assert_eq(theme.get_color(token,&"LifeTokens"),LifeThemeFactory.COLORS[token])
	assert_eq(theme.get_constant(&"frame_margin",&"LifeTokens"),28)
	var wood: StyleBoxFlat = theme.get_stylebox(&"panel",&"LifeWood") as StyleBoxFlat
	assert_eq(wood.content_margin_left,28.0)
	assert_eq(wood.content_margin_top,28.0)
	for type: StringName in [&"LifePrimary",&"LifeSecondary",&"LifeDanger",&"LifeAccent"]:
		for state: StringName in [&"normal",&"hover",&"pressed",&"disabled",&"focus"]:
			var style: StyleBoxFlat = theme.get_stylebox(state,type) as StyleBoxFlat
			assert_not_null(style)
			assert_eq(style.border_width_left,3)
			assert_eq(style.border_width_bottom,3)
		assert_ne(theme.get_stylebox(&"normal",type),theme.get_stylebox(&"hover",type))
		assert_ne(theme.get_stylebox(&"normal",type),theme.get_stylebox(&"pressed",type))

func test_selected_fonts_and_fallback_render_vietnamese_and_keep_licenses() -> void:
	var theme: Theme = LifeTheme.get_theme()
	var fonts: Array[Font] = [theme.default_font,theme.get_font(&"font",&"LifeTitle"),theme.get_font(&"font",&"LifeSecondaryText")]
	var sample: String = "Thung Lũng Sống ẩn ệ ữ ợ ỡ ằ ẫ ắ ặ ể ữ ự"
	for font: Font in fonts:
		assert_true(font is FontVariation)
		var variation: FontVariation = font as FontVariation
		assert_eq(variation.fallbacks.size(),1)
		assert_true((variation.fallbacks[0] as FontFile).resource_path.ends_with("OpenSans-Regular.ttf"))
		for index: int in range(sample.length()):
			assert_true(variation.base_font.has_char(sample.unicode_at(index)),"Primary font includes glyph %s" % sample[index])
		assert_gt(font.get_string_size(sample,HORIZONTAL_ALIGNMENT_LEFT,-1,18).x,0.0)
	for folder: String in ["Baloo_2","Nunito","Noto_Serif"]:
		var license_text: String = FileAccess.get_file_as_string("res://assets/fonts/%s/OFL.txt" % folder)
		assert_true(license_text.contains("SIL Open Font License"))
		assert_true(license_text.contains("Copyright"))
	var weight: int = TextServerManager.get_primary_interface().name_to_tag("wght")
	assert_eq(int((theme.default_font as FontVariation).variation_opentype[weight]),600)
	assert_eq(int((fonts[1] as FontVariation).variation_opentype[weight]),800)

func test_existing_ui_roots_share_one_theme_without_panel_style_overrides() -> void:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	var theme: Theme = LifeTheme.get_theme()
	assert_eq(ProjectSettings.get_setting("gui/theme/custom"),LifeTheme.PATH)
	for control: Control in [main.start_menu,main.hotbar_panel,main.inventory_panel,main.pause_menu,main.npc_system.dialogue,main.world.interaction_prompt,main.crop_inspector]:
		assert_same(control.theme,theme)
		assert_false(control.has_theme_stylebox_override("panel"),"Shared Theme owns panel skin: %s" % control.name)
	assert_same(main.npc_system.actors[&"minh"].name_label.theme,theme)
	assert_same((main.world.objects.get_node("House/Placeholder") as PlaceholderWorld2D).label.theme,theme)
