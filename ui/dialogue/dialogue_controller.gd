## LifeDialogueController — validates GUI context, routes once, never owns transactions.
## API: configure(main,system,panel), displayed(snapshot), request(id)->bool,
## is_busy()->bool, queue_render(_slots:Array[Dictionary]=[])->void.
class_name LifeDialogueController
extends RefCounted

var _main: Node
var _system: NpcSystem
var _panel: NpcPanel
var _shown: Dictionary = {}
var _busy: bool = false
var _queued: bool = false
var _epoch: int = 0

func configure(main: Node, system: NpcSystem, panel: NpcPanel) -> void:
	_main = main
	_system = system
	_panel = panel
	panel.dialogue_screen.requested.connect(request)
	panel.visibility_changed.connect(_visibility_changed)
	main.inventory.inventory_changed.connect(queue_render)

func displayed(snapshot: Dictionary) -> void:
	_shown = {"npc_id": snapshot.get("npc_id"), "dialogue_id": snapshot.get("dialogue_id"), "quest_id": snapshot.get("quest_id")}

func is_busy() -> bool:
	return _busy

func request(id: StringName) -> bool:
	if _busy or not is_instance_valid(_system) or not _system.is_dialogue_context_valid():
		return false
	var fresh: Dictionary = _system.get_dialogue_snapshot()
	for key: String in ["npc_id", "dialogue_id", "quest_id"]:
		if fresh.get(key) != _shown.get(key):
			_system.refresh_dialogue()
			return false
	var enabled: bool = false
	for action: Dictionary in fresh.get("actions", []):
		if action.id == id and bool(action.get("enabled", false)):
			enabled = true
	if not enabled:
		_system.refresh_dialogue()
		return false
	_busy = true
	_system.execute_dialogue_action(id, StringName(fresh.get("quest_id", &"")))
	_busy = false
	if is_instance_valid(_system) and _system.is_dialogue_context_valid():
		_system.refresh_dialogue()
	return true

func queue_render(_slots: Array[Dictionary] = []) -> void:
	if _busy or _queued or not is_instance_valid(_panel) or not _panel.visible:
		return
	_queued = true
	_refresh.call_deferred(_epoch)

func _refresh(token: int) -> void:
	if token != _epoch:
		return
	_queued = false
	if not is_instance_valid(_panel) or not _panel.visible or not is_instance_valid(_system):
		return
	if _system.is_dialogue_context_valid():
		_system.refresh_dialogue()
	else:
		_system.close_panels()

func _visibility_changed() -> void:
	if not _panel.visible:
		_epoch += 1
		_queued = false
		_shown.clear()
