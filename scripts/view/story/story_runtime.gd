## LifeStoryRuntime - stable owner lifecycle and proven command adapters; no simulation.
class_name LifeStoryRuntime
extends Node
const CONFIG: StoryConfig = preload("res://data/story/chapter1.tres")
const INTRODUCED_VERSION: int = 16
var lifecycle: StoryLifecycle = StoryLifecycle.new()
var _main: Node
var _observer: LifeStoryObserverFlow
var _quests: QuestManager
var _land: LandRuntime
func configure(main: Node) -> bool:
	if _main!=null: return _main==main
	_main = main
	if not main.story_state.configure(CONFIG) or not lifecycle.configure(CONFIG,main.story_state): return false
	# The original composition creates a plain collector. Replace it once, while idle,
	# before any game starts, retaining its base API/name and rebinding cached consumers.
	var old: LifeDirectorActivityCollector = main.director_activity_collector
	if old==null or old.busy: return false
	_observer = LifeStoryObserverFlow.new()
	_observer.name = old.name
	old.get_parent().remove_child(old)
	main.director_activity_collector = _observer
	main.add_child(_observer)
	_observer.configure(main)
	main.tool_controller.configure_director(_observer)
	main.seed_shop_panel.configure_director(_observer)
	main.shipping_bin_panel.configure_director(_observer)
	old.free()
	_observer.command_committed.connect(_command)
	_land = main.land_runtime
	_land.purchased.connect(_parcel)
	main.clearing_runtime.cleared.connect(_scenery)
	_bind_quests()
	return true
func is_busy() -> bool:
	return lifecycle.is_busy() or (is_instance_valid(_observer) and _observer.is_dispatching())
func prepare(payload: Dictionary) -> Dictionary:
	var metadata: Dictionary = StoryObservationSampler.section(payload.get("meta"))
	var version: Variant = metadata.get("save_version")
	var legacy: bool = (version is int or version is float) and is_finite(float(version)) and float(version)<INTRODUCED_VERSION
	return lifecycle.prepare(payload,legacy)
func restore(candidate: Dictionary) -> bool:
	if not lifecycle.restore(candidate): return false
	_bind_quests()
	return _observer.reset_receipt()
func reset() -> bool:
	if not lifecycle.reset(): return false
	_bind_quests()
	return _observer.reset_receipt()
func suspend() -> void:
	_observer.reset_receipt()
func _bind_quests() -> void:
	var current: QuestManager = _main.npc_system.state.quests
	if current==_quests: return
	if _quests!=null and _quests.quest_completed.is_connected(_delivery): _quests.quest_completed.disconnect(_delivery)
	_quests = current
	_quests.quest_completed.connect(_delivery)
func _active() -> bool:
	return _main!=null and bool(_main.get("_game_started")) and not _main.start_menu.visible and not _main.ecology_runtime.busy and not _main.director_runtime.busy and not GameClock.is_sleeping()
func _record(result: Dictionary) -> void:
	if result.get("ok",false): _main.story_state.observe(result.objective_ids)
func _command(day: int, source: StringName, counts: Dictionary) -> void:
	if _active() and day==GameClock.day_index and _observer.is_dispatching() and _observer.busy:
		_record(StoryReceiptRules.from_command(CONFIG,source,counts,true))
func _delivery(id: StringName, _coins: int, _item: StringName, _quantity: int) -> void:
	if _active() and _quests==_main.npc_system.state.quests:
		_record(StoryReceiptRules.delivery(CONFIG,id,_quests.serialize(),_quests.is_busy()))
func _parcel(id: StringName) -> void:
	if _active(): _record(StoryReceiptRules.parcel(CONFIG,id,_main.land_ownership.serialize(),_land.busy and bool(_land.result.get("ok",false))))

func _scenery(cell: Vector2i, id: StringName, count: int) -> void:
	if _active() and _main.clearing_runtime.is_committed(cell,id,count):
		_record(StoryReceiptRules.clearing(CONFIG,_main.clearing_state.serialize(),true))
func _exit_tree() -> void:
	if is_instance_valid(_observer) and _observer.command_committed.is_connected(_command): _observer.command_committed.disconnect(_command)
	if _quests!=null and _quests.quest_completed.is_connected(_delivery): _quests.quest_completed.disconnect(_delivery)
	if is_instance_valid(_land) and _land.purchased.is_connected(_parcel): _land.purchased.disconnect(_parcel)
	if is_instance_valid(_main) and is_instance_valid(_main.clearing_runtime) and _main.clearing_runtime.cleared.is_connected(_scenery): _main.clearing_runtime.cleared.disconnect(_scenery)
