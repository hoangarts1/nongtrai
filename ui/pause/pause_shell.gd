## LifePauseShell — two-panel reference-14 composition and fixed footer.
class_name LifePauseShell
extends VBoxContainer

var actions: LifePauseActions
var settings: LifeSettingsPanel
var close_button: Button
var hints: Label

func _ready() -> void:
	LifeTheme.bind(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var header_margin: MarginContainer = MarginContainer.new()
	for side: String in ["left","right","top","bottom"]:
		header_margin.add_theme_constant_override("margin_"+side,6)
	add_child(header_margin)
	var header: HBoxContainer = HBoxContainer.new()
	header_margin.add_child(header)
	var spacer: Control = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(spacer)
	close_button = LifePauseParts.button(header,&"UI_CLOSE",&"LifeDanger")
	close_button.size_flags_horizontal = Control.SIZE_FILL
	var columns: HBoxContainer = HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(columns)
	actions = preload("res://ui/pause/pause_actions.tscn").instantiate() as LifePauseActions
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.size_flags_stretch_ratio = 0.3
	columns.add_child(actions)
	settings = preload("res://ui/pause/settings_panel.tscn").instantiate() as LifeSettingsPanel
	settings.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings.size_flags_stretch_ratio = 0.7
	columns.add_child(settings)
	var footer: PanelContainer = PanelContainer.new()
	footer.theme_type_variation = &"LifeKeyHint"
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(footer)
	hints = LifePauseParts.label(footer,&"PAUSE_NAV_HINT",&"LifeText16")
	hints.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and hints != null:
		close_button.text = tr("UI_CLOSE")
		hints.text = tr("PAUSE_NAV_HINT")
