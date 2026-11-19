## LifeDogNameFlow - revision-checked native naming commands and explicit Back.
class_name LifeDogNameFlow
extends Node
var panel: LifeDogNameSheet
var busy: bool = false
var model: Dictionary = {}
var result: Dictionary = {}
var _main: Node
func configure(main: Node) -> void:
	_main = main
	panel = preload("res://ui/pet/dog_name_sheet.tscn").instantiate() as LifeDogNameSheet
	panel.name = "DogName"
	main.add_child(panel)
	panel.form.save.pressed.connect(save)
	panel.form.cancel.pressed.connect(back)
	panel.form.field.text_submitted.connect(func(_text: String) -> void: save())
	_refresh_caption()
func open() -> void:
	if busy or bool(_main.call("_purchase_in_progress")) or not bool(_main.get("_game_started")) or _main.start_menu.visible or GameClock.is_sleeping() or _main.day_end_flow.is_advancing() or _main.ui_coordinator.get_active_panel()!=_main.character_flow.panel: return
	model = LifeDogSnapshot.capture(_main)
	result = {}
	panel.form.field.text = model.name
	LifeDogPresenter.form(panel)
	panel.show()
	panel.form.field.call_deferred("grab_focus")
	panel.form.field.select_all()
func close() -> void:
	if busy: return
	panel.hide()
	model.clear()
	result.clear()
func back() -> void:
	if busy or not panel.visible or _main.ui_coordinator.get_active_panel()!=panel: return
	close()
	if bool(_main.get("_game_started")) and not _main.start_menu.visible and not GameClock.is_sleeping() and _main.ui_coordinator.get_active_panel()==null: _main.character_flow.open()
func save() -> void:
	if busy or bool(_main.call("_purchase_in_progress")) or not panel.visible or model.is_empty() or _main.ui_coordinator.get_active_panel()!=panel or not bool(_main.get("_game_started")) or GameClock.is_sleeping(): return
	busy = true
	result = _main.dog_state.try_set_name(panel.form.field.text, int(model.revision))
	busy = false
	if result.ok: back()
	else: LifeDogPresenter.form(panel,result)
func _refresh_caption() -> void:
	if _main != null: _main.dog_runtime.actor.set_unnamed_caption(tr("DOG_UNNAMED"))
func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and panel != null:
		LifeDogPresenter.form(panel,result)
		_refresh_caption()
