## NpcPanel — scrollable dialogue/journal surface, no gameplay state.
class_name NpcPanel
extends PanelContainer

signal close_requested()
var column: VBoxContainer
var title_label: Label
var close_button: Button

func _ready() -> void:
	visible = false
	theme = preload("res://scenes/main/ui_theme.tres")
	var background: StyleBoxFlat = StyleBoxFlat.new()
	background.bg_color = Color(0.055, 0.075, 0.065, 0.98)
	background.border_color = Color(0.6, 0.72, 0.49, 1.0)
	background.set_border_width_all(2)
	background.set_corner_radius_all(8)
	add_theme_stylebox_override("panel", background)
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	offset_left = -260.0
	offset_right = 260.0
	offset_top = -150.0
	offset_bottom = 150.0
	mouse_filter = Control.MOUSE_FILTER_STOP
	var margin: MarginContainer = MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	add_child(margin)
	var outer: VBoxContainer = VBoxContainer.new()
	margin.add_child(outer)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 18)
	outer.add_child(title_label)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	column = VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 8)
	scroll.add_child(column)
	close_button = Button.new()
	close_button.text = tr("UI_NPC_CLOSE")
	close_button.pressed.connect(func() -> void: close_requested.emit())
	outer.add_child(close_button)

func show_content(title: String, body: String, actions: Array[Dictionary] = []) -> void:
	title_label.text = title
	for child: Node in column.get_children():
		column.remove_child(child)
		child.queue_free()
	var text: Label = Label.new()
	text.text = body
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(text)
	for action: Dictionary in actions:
		var button: Button = Button.new()
		button.name = String(action.get("id", "Action"))
		button.text = String(action["text"])
		button.disabled = not bool(action.get("enabled", true))
		button.pressed.connect(action["callback"] as Callable)
		column.add_child(button)
	visible = true
	close_button.grab_focus()
