## LifeEcologyController — transient journal pane and deferred actual-owner refresh.
class_name LifeEcologyController
extends Node

var _panel: NpcPanel
var _main: Node
var _open: bool = false
var _queued: bool = false

func configure(panel: NpcPanel, main: Node) -> void:
	_panel = panel
	_main = main
	_panel.book.ecology_button.pressed.connect(open)
	_panel.visibility_changed.connect(_visibility_changed)
	main.ecology_state.ecology_changed.connect(_metrics_changed)
	main.farm_state.plot_changed.connect(_plot_changed)
	main.wallet.coins_changed.connect(_money_changed)
	_sync_label()

func open() -> void:
	if _open or not _panel.is_visible_in_tree() or not bool(_main.get("_game_started")) or _main.ui_coordinator.get_active_panel() != _panel or bool(_main.call("_purchase_in_progress")):
		return
	var book: LifeQuestBook = _panel.book
	book.ecology_sheet = preload("res://ui/ecology/ecology_sheet.tscn").instantiate() as LifeEcologySheet
	book.paper.add_child(book.ecology_sheet)
	book.ecology_sheet.back_requested.connect(close)
	book.body.hide()
	book.ecology_button.disabled = true
	_open = true
	queue_render()
	call_deferred("_focus_back")

func close() -> void:
	_open = false
	if not is_instance_valid(_panel) or _panel.book == null:
		return
	var book: LifeQuestBook = _panel.book
	if is_instance_valid(book.ecology_sheet):
		var sheet: LifeEcologySheet = book.ecology_sheet
		book.ecology_sheet = null
		sheet.get_parent().remove_child(sheet)
		sheet.queue_free()
	book.body.show()
	book.ecology_button.disabled = false
	if _panel.is_visible_in_tree():
		call_deferred("_focus_entry")

func reset() -> void:
	close()

func is_open() -> bool:
	return _open

func queue_render() -> void:
	if _open and not _queued:
		_queued = true
		call_deferred("_render")

func _render() -> void:
	_queued = false
	if _open and is_instance_valid(_panel) and _panel.is_visible_in_tree() and is_instance_valid(_panel.book.ecology_sheet):
		_panel.book.ecology_sheet.display(EcologyPresenter.describe(EcologySnapshot.capture(_main)))

func _focus_back() -> void:
	if _open and is_instance_valid(_panel) and _panel.is_visible_in_tree() and is_instance_valid(_panel.book.ecology_sheet):
		_panel.book.ecology_sheet.back_button.grab_focus()

func _focus_entry() -> void:
	if not _open and is_instance_valid(_panel) and _panel.is_visible_in_tree():
		_panel.book.ecology_button.grab_focus()

func _sync_label() -> void:
	if is_instance_valid(_panel) and _panel.book != null:
		_panel.book.ecology_button.text = EcologyPresenter.text(EcologyPresenter.CONFIG, "entry")

func _visibility_changed() -> void:
	if not _panel.visible:
		call_deferred("_reset_if_hidden")

func _reset_if_hidden() -> void:
	if is_instance_valid(_panel) and not _panel.is_visible_in_tree():
		reset()

func _metrics_changed(_metrics: Dictionary) -> void:
	queue_render()

func _plot_changed(_cell: Vector2i) -> void:
	queue_render()

func _money_changed(_total: int, _delta: int, _reason: StringName) -> void:
	queue_render()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_sync_label()
		queue_render()
