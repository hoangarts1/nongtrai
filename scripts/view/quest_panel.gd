## QuestPanel — displays the current farming onboarding checklist.
## API:
##   func configure(state: TutorialQuestState) -> void
class_name QuestPanel
extends PanelContainer

const STEP_KEYS: Array[StringName] = [
	&"UI_QUEST_TILL",
	&"UI_QUEST_PLANT",
	&"UI_QUEST_WATER",
	&"UI_QUEST_SLEEP",
	&"UI_QUEST_HARVEST"
]
var _state: Variant
var _list: VBoxContainer
var _help_suppressed: bool = false

func _ready() -> void:
	visible = true
	_build_ui()

func configure(state: Variant) -> void:
	_state = state
	_state.step_changed.connect(_on_step_changed)
	_state.all_completed.connect(_on_all_completed)
	_render()

func set_help_suppressed(suppressed: bool) -> void:
	_help_suppressed = suppressed
	_render()

func _build_ui() -> void:
	var margin: MarginContainer = MarginContainer.new()
	for side: StringName in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		margin.add_theme_constant_override(side, 10)
	add_child(margin)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 3)
	margin.add_child(_list)

func _render() -> void:
	if _list == null or _state == null:
		return
	for child: Node in _list.get_children():
		child.queue_free()
	for index: int in range(STEP_KEYS.size()):
		var label: Label = Label.new()
		var marker: String = "[x]" if _state.is_step_completed(index) else "[ ]"
		label.text = "%s %s" % [marker, tr(STEP_KEYS[index])]
		_list.add_child(label)
	visible = not _state.is_complete() and not _help_suppressed

func _on_step_changed(_step_index: int, _completed: bool) -> void:
	_render()

func _on_all_completed() -> void:
	visible = false
