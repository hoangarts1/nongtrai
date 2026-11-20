extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/clearing_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func _focus(cell: Vector2i) -> void:
	f.play()
	f.main.world.player.move_to_cell(cell+Vector2i.DOWN)
	f.main.world.camera_rig.set_target(f.main.world.player)
	await f.settle(self)
	await f.key(self,KEY_2)
	assert_eq(f.main.tool_controller.get_selected_tool(),&"shovel")

func _point(cell: Vector2i) -> Vector2:
	var art: SuppliedSceneryView = f.debris(cell) as SuppliedSceneryView
	var sprite: Sprite2D = art.sprite
	return sprite.get_global_transform_with_canvas()*(sprite.get_rect().position+sprite.get_rect().size*Vector2(0.5,0.8))

func _capture(name: String) -> void:
	if DisplayServer.get_name()=="headless": return
	f.viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	assert_eq(f.viewport.get_texture().get_image().save_png("user://"+name+".png"),OK)

func test_native_shovel_key_sprite_click_release_and_repeat_are_once_only_after_camera_zoom() -> void:
	var cell: Vector2i = Vector2i(3,-4)
	await _focus(cell)
	await f.key(self,KEY_2)
	assert_eq(f.main.tool_controller.get_selected_tool(),&"shovel")
	await f.key(self,KEY_EQUAL)
	var point: Vector2 = _point(cell)
	assert_eq(f.main.presentation.pick_scenery(point),cell)
	var before: Dictionary = f.core_owners()
	await f.mouse(self,point)
	assert_null(f.debris(cell))
	assert_eq(f.main.clearing_state.get_count(),1)
	await f.mouse(self,point)
	assert_eq(f.main.clearing_state.get_count(),1)
	assert_eq(f.core_owners(),before)

func test_native_modal_and_cancelled_pointer_do_not_clear_under_the_overlay() -> void:
	var cell: Vector2i = f.TARGETS[0]
	await _focus(cell)
	var point: Vector2 = _point(cell)
	var before: Dictionary = f.owners()
	await f.key(self,KEY_ESCAPE)
	assert_true(f.main.pause_menu.visible)
	await f.mouse(self,point)
	assert_eq(f.owners(),before)
	await f.key(self,KEY_ESCAPE)
	assert_false(f.main.pause_menu.visible)
	# Native release without a pressed stroke is not a clear command.
	var release: InputEventMouseButton = InputEventMouseButton.new()
	release.position = point
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	f.viewport.push_input(release,true)
	await f.settle(self)
	assert_eq(f.owners(),before)
	assert_not_null(f.debris(cell))

func test_fresh_both_locales_three_sizes_before_after_captures_and_unrelated_owners() -> void:
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]:
			assert_true(f.main.clearing_runtime.reset())
			f.viewport.size = dimensions
			var cell: Vector2i = f.TARGETS[0]
			await _focus(cell)
			var before: Dictionary = f.core_owners()
			assert_not_null(f.debris(cell))
			assert_ne(tr("CLEARING_UNAVAILABLE"),"CLEARING_UNAVAILABLE")
			await _capture("clearing_%s_%d_before" % [locale,dimensions.x])
			await f.mouse(self,_point(cell))
			assert_null(f.debris(cell))
			assert_eq(f.main.clearing_state.get_count(),1)
			assert_eq(f.core_owners(),before)
			await _capture("clearing_%s_%d_after" % [locale,dimensions.x])
