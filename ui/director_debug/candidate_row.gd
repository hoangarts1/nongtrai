## LifeDirectorCandidateRow - translated current eligibility and one deferred intent.
class_name LifeDirectorCandidateRow
extends PanelContainer

signal forced(id: StringName)
var name_label: Label
var details_label: Label
var score_label: Label
var force_button: Button
var _id: StringName

func _ready() -> void:
	LifeTheme.bind(self, &"LifeCompactPanel")
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var row: HBoxContainer = HBoxContainer.new()
	row.theme_type_variation = &"LifeHudRow"
	add_child(row)
	var column: VBoxContainer = LifeHudParts.column(row)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label = LifePauseParts.label(column, &"", &"LifeText20")
	details_label = LifePauseParts.label(column, &"")
	score_label = LifePauseParts.label(column, &"")
	force_button = LifePauseParts.button(row, &"", &"LifeSecondary")
	force_button.autowrap_mode = TextServer.AUTOWRAP_OFF
	force_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	force_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	force_button.disabled = true
	force_button.pressed.connect(func() -> void: forced.emit(_id))

func display(view: Dictionary) -> void:
	_id = StringName(view.id)
	name_label.text = view.title
	details_label.text = view.reason
	score_label.text = view.score
	tooltip_text = view.hint
	force_button.text = view.force_label
	force_button.tooltip_text = view.force_hint
	force_button.disabled = not bool(view.can_force)
	force_button.set_meta(&"director_event", _id)
