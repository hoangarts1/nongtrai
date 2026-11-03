## LifeQuestBookController — transient selection/filter; deferred read-only refresh.
class_name LifeQuestBookController
extends Node

var selected_key: String = ""
var active_filter: StringName = &"all"
var _panel: NpcPanel
var _main: Node
var _queued: bool = false

func configure(owner_panel: NpcPanel, main: Node) -> void:
	_panel = owner_panel
	_main = main
	_panel.book.filters.filter_requested.connect(filter)
	_panel.book.list.selected.connect(select)
	_panel.visibility_changed.connect(queue_render)
	main.npc_system.state.changed.connect(queue_render)
	main.inventory.inventory_changed.connect(_inventory_changed)
	main.quest_state.step_changed.connect(_step_changed)

func reset() -> void:
	selected_key = ""
	active_filter = &"all"
	_panel.book.detail.scroll.scroll_vertical = 0
	_panel.book.list.scroll_vertical = 0
	queue_render()

func select(key: String) -> void:
	if key!=selected_key:
		_panel.book.detail.scroll.scroll_vertical = 0
	selected_key = key
	queue_render()

func filter(id: StringName) -> void:
	if id not in [&"all",&"active",&"completed"]:
		return
	active_filter = id
	_panel.book.list.scroll_vertical = 0
	queue_render()

func queue_render() -> void:
	if not _queued:
		_queued = true
		call_deferred("_render")

func _render() -> void:
	_queued = false
	if _panel.visible:
		var previous: String = selected_key
		selected_key = QuestBookPresenter.render(_panel.book,QuestBookSnapshot.capture(_main),active_filter,selected_key,_main)
		if previous!=selected_key:
			_panel.book.detail.scroll.scroll_vertical = 0

func _inventory_changed(_slots: Array[Dictionary]) -> void:
	queue_render()

func _step_changed(_index: int, _complete: bool) -> void:
	queue_render()

func _notification(what: int) -> void:
	if what==NOTIFICATION_TRANSLATION_CHANGED and _panel!=null:
		queue_render()
