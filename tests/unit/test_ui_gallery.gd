extends GutTest

const UI_GALLERY_SCRIPT: GDScript = preload("res://ui/ui_gallery.gd")
var _locale: String
var _paused: bool

func before_each() -> void:
	_locale = TranslationServer.get_locale()
	_paused = GameClock.paused
	GameClock.paused = true

func after_each() -> void:
	TranslationServer.set_locale(_locale)
	GameClock.paused = _paused

func test_gallery_contains_every_section_and_no_gameplay_world() -> void:
	var gallery: Variant = preload("res://ui/ui_gallery.tscn").instantiate()
	add_child_autofree(gallery)
	await get_tree().process_frame
	for id: String in ["buttons","slots","tokens","inputs","badges","fonts","icons","frame","tabs"]:
		assert_true(gallery.get_sections().has(id),"Gallery section exists: %s" % id)
	assert_eq(gallery.get_sections().size(),9)
	assert_null(gallery.find_child("GrayBoxWorld",true,false))
	assert_same(gallery.theme,LifeTheme.get_theme())
	assert_eq(_style_overrides(gallery),0)

func test_gallery_fits_three_sizes_in_both_locales_and_captures_all_scroll_regions() -> void:
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]:
			var viewport: SubViewport = SubViewport.new()
			viewport.size = dimensions
			viewport.world_2d = World2D.new()
			viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			add_child(viewport)
			var gallery: Variant = preload("res://ui/ui_gallery.tscn").instantiate()
			viewport.add_child(gallery)
			for frame: int in range(5):
				await get_tree().process_frame
			var scroll: ScrollContainer = gallery.get_node("Margin/Scroll") as ScrollContainer
			assert_true(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(scroll.get_global_rect()))
			assert_lte(scroll.get_h_scroll_bar().max_value,scroll.size.x+2,"Gallery has no horizontal overflow")
			for id: String in gallery.get_sections():
				var panel: Control = gallery.get_sections()[id]
				assert_gte(panel.get_global_rect().position.x,0.0)
				assert_lte(panel.get_global_rect().end.x,float(dimensions.x))
				for child: Node in panel.find_children("*","Button",true,false):
					var button: Button = child as Button
					assert_lte(button.get_global_rect().end.x,panel.get_global_rect().end.x,"Button fits its card: %s" % button.name)
			if DisplayServer.get_name() != "headless":
				for mode: String in ["top","middle","bottom"]:
					scroll.scroll_vertical = 0 if mode=="top" else int(scroll.get_v_scroll_bar().max_value*(0.5 if mode=="middle" else 1))
					await get_tree().process_frame
					await RenderingServer.frame_post_draw
					var image: Image = viewport.get_texture().get_image()
					assert_eq(image.save_png("user://ui_gallery_%s_%d_%s.png" % [locale,dimensions.x,mode]),OK)
			viewport.free()
			await get_tree().process_frame

func _style_overrides(root: Node) -> int:
	var count: int = 0
	if root is Control and (root as Control).has_theme_stylebox_override("panel"):
		count += 1
	for child: Node in root.get_children():
		count += _style_overrides(child)
	return count
