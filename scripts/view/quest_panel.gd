## QuestPanel — existing tutorial completion adapter to a pinned paper card.
class_name QuestPanel
extends PanelContainer

const STEP_KEYS: Array[StringName] = [
	&"UI_QUEST_TILL",&"UI_QUEST_PLANT",&"UI_QUEST_WATER",&"UI_QUEST_SLEEP",
	&"UI_QUEST_HARVEST",&"UI_QUEST_SELL",&"UI_QUEST_BUY_SEED"
]
var _state: Variant
var _help_suppressed: bool = false
var card: LifeHudQuestCard

func _ready() -> void:
	LifeTheme.bind(self,&"LifeHudClearPanel")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	card = preload("res://ui/hud/quest_card.tscn").instantiate() as LifeHudQuestCard
	add_child(card)

func configure(state: Variant) -> void:
	_state = state
	_state.step_changed.connect(_on_step_changed)
	_state.all_completed.connect(_on_all_completed)
	_render()

func set_help_suppressed(suppressed: bool) -> void:
	_help_suppressed = suppressed
	_render()

func _render() -> void:
	if card == null or _state == null:
		return
	var completed: Array[bool] = []
	for index: int in range(STEP_KEYS.size()):
		completed.append(_state.is_step_completed(index))
	card.display(STEP_KEYS,completed)
	visible = not _state.is_complete() and not _help_suppressed

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_render()

func _on_step_changed(_step_index: int, _completed: bool) -> void:
	_render()

func _on_all_completed() -> void:
	visible = false
