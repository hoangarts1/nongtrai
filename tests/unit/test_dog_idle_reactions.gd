extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/dog_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_idle_paths_stay_near_player_and_follow_interrupts_without_extra_nodes() -> void:
	var r: LifeDogRuntime = f.main.dog_runtime
	var player: Vector2i = Vector2i(-10,-10)
	f.main.world.player.move_to_cell(player)
	f.main.dog_state.try_set_cell(player+Vector2i.RIGHT)
	r.actor.reset_position()
	f.play()
	var owners: Dictionary = f.owners()
	var before: Vector2i = f.main.dog_state.get_cell()
	f.ticks(50)
	assert_lte(DogFollowRules.distance(f.main.dog_state.get_cell(),player),r.CONFIG.idle_radius)
	assert_ne(f.main.dog_state.get_cell(),before)
	assert_true(r.navigation.is_walkable(f.main.dog_state.get_cell()))
	f.main.world.player.move_to_cell(Vector2i(-15,-15))
	for _i: int in range(150):
		f.ticks(1)
		if DogFollowRules.distance(f.main.dog_state.get_cell(),f.main.world.player.get_cell())<=r.CONFIG.follow_stop_distance: break
	assert_lte(DogFollowRules.distance(f.main.dog_state.get_cell(),f.main.world.player.get_cell()),r.CONFIG.follow_stop_distance)
	assert_eq(f.actors().size(),1)
	assert_eq(f.owners(),owners)

func test_native_reaction_poses_render_without_owner_or_node_growth() -> void:
	var r: LifeDogRuntime = f.main.dog_runtime
	var weather: Dictionary = f.main.weather_state.serialize()
	weather.today = "rain"
	weather.forecast = ["rain","rain","rain"]
	f.main.weather_state.deserialize(weather)
	f.play()
	r.advance(0.1)
	assert_true(r.actor.avatar.is_happy())
	var dog: Dictionary = f.main.dog_state.serialize()
	var bag: Dictionary = f.main.inventory.serialize()
	var wallet: Dictionary = f.main.wallet.serialize()
	f.main.world.camera_rig.set_process(false)
	var camera: Camera2D = f.main.world.player.camera
	camera.global_position = r.actor.global_position
	camera.zoom = Vector2.ONE * 2.0
	camera.reset_smoothing()
	camera.force_update_scroll()
	f.viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var index: int = 0
	for delta: float in [0.1,0.2,1.0]:
		GameClock.paused = false
		r.advance(delta)
		GameClock.paused = true
		await f.settle(self)
		if DisplayServer.get_name()!="headless":
			await RenderingServer.frame_post_draw
			assert_eq(f.viewport.get_texture().get_image().save_png("user://dog_reaction_%d.png" % index),OK)
		index += 1
		assert_eq(f.main.dog_state.serialize(),dog)
		assert_eq(f.actors().size(),1)
	assert_false(r.actor.avatar.is_happy())
	assert_eq(f.main.inventory.serialize(),bag)
	assert_eq(f.main.wallet.serialize(),wallet)
func test_rain_cosmetic_once_and_producer_spoof_does_not_count_as_harvest() -> void:
	f.play()
	var r: LifeDogRuntime = f.main.dog_runtime
	var weather: Dictionary = f.main.weather_state.serialize()
	weather.today = "rain"
	weather.forecast = ["rain","rain","rain"]
	f.main.weather_state.deserialize(weather)
	r.advance(0.1)
	assert_true(r.actor.avatar.is_happy())
	var count: int = r.reactions.reactions
	var owners: Dictionary = f.owners()
	Events.crop_harvested.emit(Vector2i.ZERO,&"spring_turnip",1,1)
	f.ticks(30)
	assert_eq(r.reactions.reactions,count)
	assert_false(r.actor.avatar.is_happy())
	assert_eq(f.owners(),owners)
