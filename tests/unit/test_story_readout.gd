extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/story_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame
func test_empty_partial_and_all_supported_have_truthful_planned_boundaries() -> void:
	var first: Dictionary = LifeStorySnapshot.capture(f.main)
	assert_true(first.ok)
	assert_eq(first.done_count,0)
	assert_eq(first.total_count,10)
	assert_eq(first.supported_count,6)
	assert_true(first.pages[0].available)
	assert_false(first.pages[1].available)
	f.main.story_state.observe(PackedStringArray(["first_sowing"]))
	assert_eq(LifeStorySnapshot.capture(f.main).done_count,1)
	f.main.story_state.observe(LifeStorySnapshot.CONFIG.supported_ids())
	var full: Dictionary = LifeStorySnapshot.capture(f.main)
	assert_eq(full.done_count,6)
	assert_false(full.chapter_complete)
	for row: Dictionary in full.objectives:
		assert_ne(row.planned,row.done)
	for row: Dictionary in full.milestones:
		assert_true(row.planned)
		assert_false(row.done)
	for page: Dictionary in full.pages: assert_true(page.available)
func test_detached_reads_do_not_change_any_owner_or_save_bytes() -> void:
	var before: Dictionary = f.owners()
	var saved: PackedByteArray = FileAccess.get_file_as_bytes("user://saves/slot_1.json")
	var raw: Dictionary = LifeStorySnapshot.capture(f.main)
	var model: Dictionary = LifeStoryPresenter.describe(raw)
	model.objectives[0].done = true
	model.pages.clear()
	raw.objectives.clear()
	assert_eq(LifeStorySnapshot.capture(f.main).objectives.size(),10)
	assert_eq(f.owners(),before)
	assert_eq(FileAccess.get_file_as_bytes("user://saves/slot_1.json"),saved)
func test_legacy_uses_actual_owner_evidence_and_invalid_wire_has_no_readout() -> void:
	var payload: Dictionary = {"quests":{"completed":[false,true,false,false,true,true,false]}}
	var baseline: Dictionary = StorySaveContext.capture(LifeStorySnapshot.CONFIG,payload)
	assert_true(baseline.ok)
	assert_true(f.main.story_state.deserialize(baseline.baseline))
	assert_eq(LifeStorySnapshot.capture(f.main).done_count,3)
	assert_false(LifeStorySnapshot.from_wire({"completed_objectives":["repair_house"],"read_pages":[]}).ok)
	assert_false(LifeStorySnapshot.capture(null).ok)
	assert_false(LifeStoryPresenter.describe({}).ok)
