## LifeDirectorDebugSheet - small shared-theme components, transient native controls.
class_name LifeDirectorDebugSheet
extends LifeHudFrame

signal closed()
signal enabled_requested(value: bool)
signal force_requested(id: StringName)
var banner: LifeBanner
var close_button: Button
var enabled_button: CheckButton
var clear_button: Button
var coverage_label: Label
var metrics_label: Label
var notice_label: Label
var hint_label: Label
var scroll: ScrollContainer
var content: VBoxContainer
var rows: Array[LifeDirectorCandidateRow] = []
var trace_panel: LifeDirectorTracePanel

func _ready() -> void:
	super._ready()
	mouse_filter = Control.MOUSE_FILTER_STOP
	var column: VBoxContainer = LifePauseParts.paper(self)
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var heading: HBoxContainer = HBoxContainer.new()
	heading.theme_type_variation = &"LifeHudRow"
	column.add_child(heading)
	banner = preload("res://ui/components/banner.tscn").instantiate() as LifeBanner
	banner.tone = &"red"
	banner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(banner)
	close_button = LifePauseParts.button(heading, &"UI_CLOSE", &"LifeDanger")
	close_button.autowrap_mode = TextServer.AUTOWRAP_OFF
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	close_button.pressed.connect(func() -> void: closed.emit())
	var controls: HBoxContainer = HBoxContainer.new()
	controls.theme_type_variation = &"LifeHudRow"
	column.add_child(controls)
	enabled_button = CheckButton.new()
	enabled_button.theme_type_variation = &"LifeToggle"
	enabled_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.add_child(enabled_button)
	enabled_button.toggled.connect(func(value: bool) -> void: enabled_requested.emit(value))
	clear_button = LifePauseParts.button(controls, &"")
	clear_button.autowrap_mode = TextServer.AUTOWRAP_OFF
	clear_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	clear_button.pressed.connect(func() -> void: force_requested.emit(&""))
	coverage_label = LifePauseParts.label(column, &"")
	metrics_label = LifePauseParts.label(column, &"")
	notice_label = LifePauseParts.label(column, &"")
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	content = LifeHudParts.column(scroll)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	trace_panel = preload("res://ui/director_debug/trace_panel.tscn").instantiate() as LifeDirectorTracePanel
	content.add_child(trace_panel)
	hint_label = LifePauseParts.label(column, &"")

func ensure_rows(count: int) -> void:
	while rows.size() < count:
		var row: LifeDirectorCandidateRow = preload("res://ui/director_debug/candidate_row.tscn").instantiate() as LifeDirectorCandidateRow
		content.add_child(row)
		content.move_child(row, rows.size())
		row.forced.connect(func(id: StringName) -> void: force_requested.emit(id))
		rows.append(row)
	while rows.size() > count:
		var row: LifeDirectorCandidateRow = rows.pop_back()
		content.remove_child(row)
		row.queue_free()
