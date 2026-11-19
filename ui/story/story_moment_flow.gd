## Optional page command adapter; UiCoordinator alone owns modal holds/input.
class_name LifeStoryMomentFlow
extends Node
var panel: LifeStoryMomentSheet
var busy: bool = false
var result: Dictionary = {}
var _main: Node
var _page: StringName
var _revision: int = -1
func configure(main: Node) -> void:
	_main = main
	panel = preload("res://ui/story/moment_sheet.tscn").instantiate() as LifeStoryMomentSheet
	panel.name = "StoryMoment"
	main.add_child(panel)
	panel.actions.confirm.pressed.connect(confirm)
	panel.actions.cancel.pressed.connect(back)
func open(page_id: StringName) -> bool:
	if busy or bool(_main.call("_purchase_in_progress")) or not bool(_main.get("_game_started")) or _main.start_menu.visible or GameClock.is_sleeping() or _main.day_end_flow.is_advancing() or _main.ui_coordinator.get_active_panel()!=_main.npc_system.journal or not _main.npc_system.journal.book_controller.story_controller.is_open(): return false
	var snapshot: Dictionary = LifeStorySnapshot.capture(_main)
	if not snapshot.ok or not _main.story_state.can_read_page(page_id): return false
	_page = page_id
	_revision = snapshot.revision
	result = {}
	_refresh()
	panel.body.scroll.scroll_vertical = 0
	panel.show()
	panel.actions.cancel.call_deferred("grab_focus")
	return true
func close() -> void:
	if busy: return
	panel.hide()
	_page = &""
	_revision = -1
	result.clear()
func back() -> void:
	if busy or not panel.visible or _main.ui_coordinator.get_active_panel()!=panel: return
	close()
	if bool(_main.get("_game_started")) and not _main.start_menu.visible and not GameClock.is_sleeping() and _main.ui_coordinator.get_active_panel()==null:
		_main.npc_system.open_journal()
		_main.npc_system.journal.book_controller.story_controller.open()
func confirm() -> void:
	if busy or bool(_main.call("_purchase_in_progress")) or not panel.visible or _page.is_empty() or panel.actions.confirm.disabled or _main.ui_coordinator.get_active_panel()!=panel: return
	busy = true
	result = _main.story_state.acknowledge_page(_page,_revision)
	busy = false
	if result.ok: back()
	else: _refresh()
func _refresh() -> void:
	if _page.is_empty(): return
	var model: Dictionary = LifeStoryPresenter.describe(LifeStorySnapshot.capture(_main))
	if not model.ok: return
	for page: Dictionary in model.pages:
		if page.id==String(_page):
			panel.display(page,not result.is_empty() and not bool(result.get("ok",false)))
			return
func _notification(what: int) -> void:
	if what==NOTIFICATION_TRANSLATION_CHANGED and panel!=null: _refresh()
