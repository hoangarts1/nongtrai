## Transient notebook view mode; no story commands or saved selection.
class_name LifeStoryNotebookController
extends Node
var _main: Node
var _panel: NpcPanel
var _queued: bool = false
func configure(panel: NpcPanel, main: Node) -> void:
	_panel = panel
	_main = main
	panel.book.story_button.pressed.connect(open)
	panel.visibility_changed.connect(_visibility_changed)
	main.story_state.changed.connect(queue_render)
	_sync_label()
func is_open() -> bool:
	return is_instance_valid(_panel) and is_instance_valid(_panel.book.story_sheet)
func open() -> void:
	if is_open() or not _panel.is_visible_in_tree() or not bool(_main.get("_game_started")) or _main.ui_coordinator.get_active_panel()!=_panel or bool(_main.call("_purchase_in_progress")): return
	_panel.book_controller.ecology_controller.close()
	var book: LifeQuestBook = _panel.book
	book.story_sheet = preload("res://ui/story/notebook.tscn").instantiate() as LifeStoryNotebook
	book.paper.add_child(book.story_sheet)
	book.story_sheet.page_requested.connect(_main.story_moment_flow.open)
	book.story_sheet.back_requested.connect(_back)
	book.body.hide()
	book.story_button.disabled = true
	queue_render()
	call_deferred("_focus_back")
func close() -> void:
	if not is_instance_valid(_panel) or _panel.book==null: return
	var book: LifeQuestBook = _panel.book
	if is_instance_valid(book.story_sheet):
		var sheet: LifeStoryNotebook = book.story_sheet
		book.story_sheet = null
		sheet.get_parent().remove_child(sheet)
		sheet.queue_free()
	book.story_button.disabled = false
	if not _panel.book_controller.ecology_controller.is_open(): book.body.show()
func reset() -> void:
	close()
func _back() -> void:
	close()
	if _panel.is_visible_in_tree(): _panel.book.story_button.call_deferred("grab_focus")
func queue_render() -> void:
	if is_open() and not _queued:
		_queued = true
		call_deferred("_render")
func _render() -> void:
	_queued = false
	if is_open() and _panel.is_visible_in_tree():
		_panel.book.story_sheet.display(LifeStoryPresenter.describe(LifeStorySnapshot.capture(_main)))
func _focus_back() -> void:
	if is_open() and _panel.is_visible_in_tree(): _panel.book.story_sheet.back_button.grab_focus()
func _sync_label() -> void:
	if is_instance_valid(_panel): _panel.book.story_button.text = tr("STORY_ENTRY")
func _visibility_changed() -> void:
	if not _panel.visible: call_deferred("_reset_if_hidden")
func _reset_if_hidden() -> void:
	if is_instance_valid(_panel) and not _panel.is_visible_in_tree(): close()
func _notification(what: int) -> void:
	if what==NOTIFICATION_TRANSLATION_CHANGED:
		_sync_label()
		queue_render()
