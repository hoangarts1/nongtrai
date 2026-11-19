extends GutTest
const CONFIG: StoryConfig = preload("res://data/story/chapter1.tres")
func test_all_mutation_and_restore_reentry_are_blocked_during_committed_publication() -> void:
	var state: StoryState = StoryState.new()
	state.configure(CONFIG)
	var attempts: Array[bool] = []
	var snapshots: Array[Dictionary] = []
	var callback: Callable = func() -> void:
		snapshots.append(state.serialize())
		attempts.append(state.observe(PackedStringArray(["first_harvest"])).ok)
		attempts.append(state.acknowledge_page(&"intro",state.get_revision()).ok)
		attempts.append(state.deserialize(StorySnapshotCodec.empty()))
		attempts.append(state.configure(CONFIG))
	state.changed.connect(callback)
	assert_true(state.observe(PackedStringArray(["first_sowing"])).ok)
	state.changed.disconnect(callback)
	assert_eq(attempts,[false,false,false,false])
	assert_eq(snapshots,[{"completed_objectives":["first_sowing"],"read_pages":[]}])
	assert_false(state.is_busy())
	assert_eq(state.serialize(),snapshots[0])
func test_restore_and_reset_invalidate_quotes_without_emitting_or_acknowledging() -> void:
	var state: StoryState = StoryState.new()
	state.configure(CONFIG)
	var calls: Array[int] = [0]
	state.changed.connect(func() -> void: calls[0] += 1)
	var quote: int = state.get_revision()
	assert_true(state.deserialize(state.serialize()))
	assert_false(state.acknowledge_page(&"intro",quote).ok)
	quote = state.get_revision()
	assert_true(state.configure(CONFIG))
	assert_false(state.acknowledge_page(&"intro",quote).ok)
	assert_eq(calls[0],0)
	assert_eq(state.serialize(),StorySnapshotCodec.empty())
