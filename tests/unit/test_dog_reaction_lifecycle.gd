extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/dog_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_real_harvest_receipt_once_and_no_extra_reward() -> void:
	f.use(&"hoe",Vector2i.ZERO)
	f.use(&"seed",Vector2i.ZERO)
	var raw: Dictionary = f.main.farm_state.serialize()
	for row: Dictionary in raw.plots: row.growth_days = int(row.growth_target)
	f.main.farm_state.deserialize(raw)
	assert_true(f.main.farm_state.can_harvest(Vector2i.ZERO))
	f.play()
	var r: LifeDogRuntime = f.main.dog_runtime
	var count: int = r.reactions.reactions
	var coins: int = f.main.wallet.get_coins()
	f.use(&"harvest",Vector2i.ZERO)
	assert_eq(r.reactions.reactions,count+1)
	assert_true(r.actor.avatar.is_happy())
	assert_eq(f.main.wallet.get_coins(),coins)
	f.use(&"harvest",Vector2i.ZERO)
	assert_eq(r.reactions.reactions,count+1)
	var dog: Dictionary = f.main.dog_state.serialize()
	GameClock.paused = true
	var phase: float = r.actor.avatar.get_phase()
	f.ticks(30)
	assert_eq(r.actor.avatar.get_phase(),phase)
	assert_eq(f.main.dog_state.serialize(),dog)
func test_save_load_title_clear_reactions_and_reuse_visual_nodes() -> void:
	var r: LifeDogRuntime = f.main.dog_runtime
	var actor: DogActor2D = r.actor
	f.play()
	var weather: Dictionary = f.main.weather_state.serialize()
	weather.today = "rain"
	weather.forecast = ["rain","rain","rain"]
	f.main.weather_state.deserialize(weather)
	f.ticks(1)
	assert_true(actor.avatar.is_happy())
	assert_true(f.main.call("_save_game_to_slot",98))
	assert_true(f.main.call("_load_game_from_slot",98))
	assert_false(actor.avatar.is_happy())
	var count: int = r.reactions.reactions
	f.play()
	f.ticks(2)
	assert_eq(r.reactions.reactions,count)
	assert_true(f.main.call("_return_to_start_menu"))
	assert_false(actor.avatar.is_happy())
	assert_eq(r.actor,actor)
	assert_eq(actor.get_child_count(),2)
	assert_eq(f.actors().size(),1)
