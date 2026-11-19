extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/director_fixture.gd")
const CONFIG: DogConfig = preload("res://data/dog_config.tres")
const PROFILE: DogVisualProfile = preload("res://data/art/characters/dog_visual_profile.tres")
var f: RefCounted
var actor: DogActor2D
var state: DogState
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
	state = DogState.new()
	state.configure(CONFIG, CONFIG.world.debug_home_cell)
	state.try_set_name("Mây")
	actor = DogActor2D.new()
	f.main.world.objects.add_child(actor)
	assert_true(actor.configure(state, f.main.world.grid, CONFIG, PROFILE))
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame
func test_ground_interpolation_pause_and_readonly_owner() -> void:
	var before: Dictionary = state.serialize()
	var target: Vector2i = state.get_cell() + Vector2i.RIGHT
	assert_eq(actor.global_position, f.main.world.grid.cell_to_global(state.get_cell()))
	assert_true(actor.begin_step(target))
	var point: Vector2 = actor.global_position
	var phase: float = actor.avatar.get_phase()
	actor.advance(10.0, false)
	assert_eq(actor.global_position, point)
	assert_eq(actor.avatar.get_phase(), phase)
	actor.advance(0.1)
	assert_ne(actor.global_position, point)
	actor.advance(1.0)
	assert_eq(actor.global_position, f.main.world.grid.cell_to_global(target))
	assert_eq(state.serialize(), before)
	assert_eq(actor.caption.text, "Mây")
	assert_eq(actor.get_child_count(), 2)
	assert_eq(actor.get_class(), "Node2D")
	actor.reset_position()
	assert_eq(actor.global_position, point)
func test_native_render_matrix_locale_sizes_zoom_and_frozen_owners() -> void:
	var before: Dictionary = f.owners()
	var dog: Dictionary = state.serialize()
	f.viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for size: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]:
			f.viewport.size = size
			for zoom: float in [0.5,0.75,1.0,1.5,2.0]:
				var camera: Camera2D = f.main.world.get_viewport().get_camera_2d()
				camera.zoom = Vector2.ONE * zoom
				f.main.world.camera_rig.set_process(false)
				camera.global_position = actor.global_position
				camera.reset_smoothing()
				camera.force_update_scroll()
				actor.advance(0.05)
				await f.settle(self)
				assert_eq(actor.global_position, f.main.world.grid.cell_to_global(state.get_cell()))
				assert_eq(state.serialize(), dog)
			if DisplayServer.get_name() != "headless":
				await RenderingServer.frame_post_draw
				var picture: Image = f.viewport.get_texture().get_image()
				assert_false(picture.is_empty())
				assert_eq(picture.save_png("user://dog_actor_%s_%d.png" % [locale,size.x]), OK)
	assert_eq(f.owners(), before)
