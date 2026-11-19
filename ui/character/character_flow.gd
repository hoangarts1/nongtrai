## LifeCharacterFlow — view-only opening/refresh; modal locks belong to UiCoordinator.
class_name LifeCharacterFlow
extends Node

var panel: LifeCharacterSheet
var _main: Node

func configure(main: Node) -> void:
	_main = main
	panel = preload("res://ui/character/character_sheet.tscn").instantiate() as LifeCharacterSheet
	panel.name = "CharacterScreen"
	main.add_child(panel)
	panel.tabs.close_requested.connect(close)
	panel.visibility_changed.connect(refresh)
	main.npc_system.state.changed.connect(refresh)
	main.dog_state.changed.connect(_dog_changed)
	panel.companion.rename_requested.connect(func() -> void: main.dog_name_flow.open())

func open() -> void:
	if not bool(_main.get("_game_started")) or _main.start_menu.visible or _main.tutorial_panel.visible or GameClock.is_sleeping():
		return
	if _main.day_end_flow.is_advancing() or _main.day_end_flow.panel.visible:
		return
	panel.show()
	if panel.visible:
		panel.tabs.buttons[1].call_deferred("grab_focus")

func close() -> void:
	panel.hide()

func refresh() -> void:
	if panel != null and panel.visible:
		CharacterPresenter.render(panel,CharacterSnapshot.capture(_main))

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and panel != null:
		refresh()

func _dog_changed(_cell: Vector2i, _name: String) -> void:
	refresh()
