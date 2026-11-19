extends GutTest
const CONFIG: DogConfig = preload("res://data/dog_config.tres")
func test_exact_native_json_and_fallback_preserve_good_name_and_other_components() -> void:
	var raw: Dictionary = {"name":"Mây","cell_x":-12,"cell_y":-10}
	var decoded: Dictionary = DogSaveCodec.normalize(CONFIG,JSON.parse_string(JSON.stringify(raw)),CONFIG.world.spawn_cell)
	assert_true(decoded.ok)
	assert_false(decoded.used_fallback)
	assert_eq(decoded.snapshot,raw)
	for bad: Variant in [null,[],{"name":"Mây","cell_x":999,"cell_y":999},{"name":"Mây","cell_x":true,"cell_y":0}]:
		var result: Dictionary = DogSaveCodec.normalize(CONFIG,bad,CONFIG.world.spawn_cell)
		assert_true(result.ok)
		assert_true(result.used_fallback)
		assert_true(DogSnapshotCodec.decode(CONFIG,result.snapshot).ok)
		if bad is Dictionary: assert_eq(result.snapshot.name,"Mây")
func test_lifecycle_repairs_real_obstacle_preserves_name_and_restore_is_silent() -> void:
	var state: DogState = DogState.new()
	state.configure(CONFIG,Vector2i(-10,-10))
	var nav: DogNavigation = DogNavigation.new()
	nav.configure(CONFIG)
	var lifecycle: DogLifecycle = DogLifecycle.new()
	assert_true(lifecycle.configure(CONFIG,state))
	var changes: Array[int] = []
	var callback: Callable = func(_cell: Vector2i,_name: String) -> void: changes.append(1)
	state.changed.connect(callback)
	var prepared: Dictionary = lifecycle.prepare({"name":"Mây","cell_x":0,"cell_y":0},Vector2i.ZERO,nav)
	assert_true(prepared.ok)
	assert_true(lifecycle.restore(prepared))
	assert_eq(state.get_name(),"Mây")
	assert_true(nav.is_walkable(state.get_cell()))
	assert_eq(changes,[])
	state.changed.disconnect(callback)
