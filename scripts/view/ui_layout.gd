## UiLayout — readable runtime theme and viewport-based HUD/modal rectangles.
class_name UiLayout
extends RefCounted

static func apply(main: Node) -> void:
	var theme: Theme = preload("res://scenes/main/ui_theme.tres").duplicate()
	theme.default_font_size = 18
	theme.set_stylebox("panel", "PanelContainer", _surface())
	for kind: String in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style: StyleBoxFlat = _surface()
		style.bg_color = Color(0.15, 0.22, 0.19) if kind in ["hover", "pressed", "focus"] else Color(0.09, 0.13, 0.12)
		style.content_margin_left = 14.0
		style.content_margin_right = 14.0
		style.content_margin_top = 8.0
		style.content_margin_bottom = 8.0
		theme.set_stylebox(kind, "Button", style)
	for child: Node in main.get_children():
		if child is Control:
			(child as Control).theme = theme
			_style_children(child)
	main.hotbar_panel.refresh_readability()
	main.tutorial_panel.get_node("MarginContainer/VBoxContainer/Instructions").custom_minimum_size.x = 560.0
	reflow(main)

static func _surface() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.065, 0.06, 0.98)
	style.border_color = Color(0.5, 0.65, 0.45)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	return style

static func _style_children(node: Node) -> void:
	if node is Label:
		var label: Label = node as Label
		if label.has_theme_font_size_override("font_size"):
			label.add_theme_font_size_override("font_size", 18 if label.name == &"ToolLabel" else maxi(24, label.get_theme_font_size("font_size")))
	if node is Button:
		var button: Button = node as Button
		button.custom_minimum_size.y = maxf(40.0, button.custom_minimum_size.y)
	if node is PanelContainer:
		(node as PanelContainer).add_theme_stylebox_override("panel", _surface())
	for child: Node in node.get_children():
		_style_children(child)

static func reflow(main: Node) -> void:
	var viewport: Vector2 = main.get_viewport().get_visible_rect().size
	var modal_size: Vector2 = Vector2(minf(680.0, viewport.x - 64.0), minf(560.0, viewport.y - 48.0))
	for panel: Control in [main.inventory_panel, main.tutorial_panel, main.debug_menu, main.pause_menu, main.start_menu, main.seed_shop_panel, main.shipping_bin_panel, main.npc_system.dialogue, main.npc_system.journal]:
		_rect(panel, (viewport - modal_size) * 0.5, modal_size)
	_rect(main.get_node("ClockHud"), Vector2(20, 16), Vector2(480, 36))
	_rect(main.weather_hud, Vector2(20, 56), Vector2(480, 30))
	_rect(main.wallet_hud, Vector2(20, 90), Vector2(300, 28))
	_rect(main.quest_panel, Vector2(viewport.x - 370.0, 16), Vector2(350, 242))
	var bar_width: float = minf(1000.0, viewport.x - 300.0)
	_rect(main.hotbar_panel, Vector2(16, viewport.y - 238.0), Vector2(bar_width, 222))
	_rect(main.hud_button_bar, Vector2(viewport.x - 264.0, viewport.y - 92.0), Vector2(248, 76))
	var prompt: Control = main.world.interaction_prompt
	_rect(prompt, Vector2((viewport.x - 480.0) * 0.5, viewport.y - 298.0), Vector2(480, 52))
	prompt.get_node("Message").add_theme_font_size_override("font_size", 20)
	_rect(main.toast, Vector2(20, 128), Vector2(460, 32))
	_rect(main.feedback, Vector2((viewport.x - 660.0) * 0.5, 126), Vector2(660, 44))
	main.feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

static func _rect(control: Control, origin: Vector2, dimensions: Vector2) -> void:
	control.set_anchors_preset(Control.PRESET_TOP_LEFT)
	control.position = origin
	control.size = dimensions
