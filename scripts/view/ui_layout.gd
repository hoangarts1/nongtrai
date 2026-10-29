## UiLayout — readable runtime theme and viewport-based HUD/modal rectangles.
class_name UiLayout
extends RefCounted

const PALETTE: Resource = preload("res://data/art/palette/chibi_valley.tres")

static func apply(main: Node) -> void:
	var theme: Theme = preload("res://scenes/main/ui_theme.tres").duplicate()
	var outline: Color = _palette_color(&"outline", Color("4b3c47"))
	var shadow: Color = _palette_color(&"shadow", Color("82749a"))
	var cream: Color = _palette_color(&"sunlight", Color("fff3cf"))
	var accent: Color = _palette_color(&"ui_accent", Color("f3a58e"))
	theme.default_font_size = 18
	theme.default_font = preload("res://assets/fonts/Open_Sans/OpenSans-Regular.ttf")
	for type: String in ["Label", "Button", "CheckButton", "LineEdit", "OptionButton"]:
		theme.set_color("font_color", type, Color(outline, 0.92))
		theme.set_color("font_hover_color", type, outline)
		theme.set_color("font_pressed_color", type, outline)
		theme.set_color("font_disabled_color", type, Color(shadow, 0.72))
		theme.set_color("font_focus_color", type, outline)
	theme.set_color("font_placeholder_color", "LineEdit", Color(shadow, 0.82))
	theme.set_color("font_color", "TooltipLabel", outline)
	theme.set_font_size("font_size", "TooltipLabel", 16)
	theme.set_stylebox("normal", "LineEdit", _field_surface(outline, shadow, cream, accent))
	theme.set_stylebox("focus", "LineEdit", _field_surface(outline, shadow, cream, accent))
	theme.set_stylebox("read_only", "LineEdit", _field_surface(outline, shadow, cream, accent))
	theme.set_stylebox("normal", "OptionButton", _button_surface(&"normal", outline, shadow, cream, accent))
	theme.set_stylebox("hover", "OptionButton", _button_surface(&"hover", outline, shadow, cream, accent))
	theme.set_stylebox("pressed", "OptionButton", _button_surface(&"pressed", outline, shadow, cream, accent))
	theme.set_stylebox("focus", "OptionButton", _button_surface(&"focus", outline, shadow, cream, accent))
	theme.set_stylebox("disabled", "OptionButton", _button_surface(&"disabled", outline, shadow, cream, accent))
	theme.set_stylebox("panel", "PanelContainer", _surface(outline, shadow, cream))
	theme.set_stylebox("panel", "TooltipPanel", _tooltip_surface(outline, shadow, cream, accent))
	for kind: String in ["normal", "hover", "pressed", "focus", "disabled"]:
		theme.set_stylebox(kind, "Button", _button_surface(StringName(kind), outline, shadow, cream, accent))
		theme.set_stylebox(kind, "CheckButton", _button_surface(StringName(kind), outline, shadow, cream, accent))
	for child: Node in main.get_children():
		if child is Control:
			(child as Control).theme = theme
			_style_children(child)
	main.hotbar_panel.refresh_readability()
	main.start_menu.apply_chibi_style()
	for id: StringName in [&"inventory", &"help", &"journal", &"pause"]:
		var button: Button = main.hud_button_bar.get_button(id)
		if button != null:
			UiIcons.decorate(button, &"backpack" if id == &"inventory" else id, true)
			button.custom_minimum_size = Vector2(42, 42)
			button.add_theme_constant_override("icon_max_width", 24)
	var status: Panel = main.get_node_or_null("StatusCard") as Panel
	if status == null:
		status = Panel.new()
		status.name = "StatusCard"
		status.mouse_filter = Control.MOUSE_FILTER_IGNORE
		status.z_index = -1
		main.add_child(status)
	status.add_theme_stylebox_override("panel", _surface(outline, shadow, cream))
	main.tutorial_panel.get_node("MarginContainer/VBoxContainer/Instructions").custom_minimum_size.x = 560.0
	reflow(main)

static func _surface(outline: Color, shadow: Color, cream: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(cream, 0.96)
	style.border_color = Color(outline, 0.52)
	style.set_border_width_all(2)
	style.set_corner_radius_all(22)
	style.shadow_color = Color(shadow, 0.26)
	style.shadow_size = 7
	style.shadow_offset = Vector2(0, 4)
	return style

static func _button_surface(kind: StringName, outline: Color, shadow: Color, cream: Color, accent: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = _surface(outline, shadow, cream)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	match kind:
		&"hover", &"focus":
			style.bg_color = cream.lerp(accent, 0.16)
			style.border_color = Color(accent, 0.94)
			style.shadow_size = 9
		&"pressed":
			style.bg_color = cream.lerp(accent, 0.3)
			style.border_color = outline
			style.shadow_size = 3
			style.shadow_offset = Vector2(0, 2)
		&"disabled":
			style.bg_color = Color(shadow, 0.14)
			style.border_color = Color(shadow, 0.38)
			style.shadow_size = 0
		_:
			pass
	return style

static func _field_surface(outline: Color, shadow: Color, cream: Color, accent: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = _surface(outline, shadow, cream)
	style.border_color = Color(accent, 0.72)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 7.0
	style.content_margin_bottom = 7.0
	return style

static func _tooltip_surface(outline: Color, shadow: Color, cream: Color, accent: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = _surface(outline, shadow, cream.lerp(accent, 0.08))
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 7.0
	style.content_margin_bottom = 7.0
	style.shadow_size = 10
	return style

static func _palette_color(role: StringName, fallback: Color) -> Color:
	if PALETTE == null:
		return fallback
	var value: Variant = PALETTE.call("get_color", role)
	return value if value is Color else fallback

static func _style_children(node: Node) -> void:
	if node is Label:
		var label: Label = node as Label
		if label.has_theme_font_size_override("font_size"):
			label.add_theme_font_size_override("font_size", 18 if label.name == &"ToolLabel" else maxi(24, label.get_theme_font_size("font_size")))
		if label.has_theme_color_override("font_color"):
			label.remove_theme_color_override("font_color")
	if node is Button:
		var button: Button = node as Button
		button.custom_minimum_size.y = maxf(40.0, button.custom_minimum_size.y)
	if node is PanelContainer:
		var outline: Color = _palette_color(&"outline", Color("4b3c47"))
		var shadow: Color = _palette_color(&"shadow", Color("82749a"))
		var cream: Color = _palette_color(&"sunlight", Color("fff3cf"))
		(node as PanelContainer).add_theme_stylebox_override("panel", _surface(outline, shadow, cream))
	if node is CropInspector:
		return
	for child: Node in node.get_children():
		_style_children(child)

static func reflow(main: Node) -> void:
	var viewport: Vector2 = main.get_viewport().get_visible_rect().size
	var modal_size: Vector2 = Vector2(minf(680.0, viewport.x - 64.0), minf(560.0, viewport.y - 48.0))
	for panel: Control in [main.inventory_panel, main.tutorial_panel, main.debug_menu, main.pause_menu, main.start_menu, main.seed_shop_panel, main.shipping_bin_panel, main.npc_system.dialogue, main.npc_system.journal]:
		_rect(panel, (viewport - modal_size) * 0.5, modal_size)
	var start_size: Vector2 = Vector2(minf(452.0, viewport.x - 64.0), modal_size.y)
	_rect(main.start_menu, Vector2(maxf(32.0, viewport.x * 0.055), (viewport.y - start_size.y) * 0.5), start_size)
	var status: Control = main.get_node_or_null("StatusCard") as Control
	if status != null:
		_rect(status, Vector2(12, 8), Vector2(484, 116))
	_rect(main.get_node("ClockHud"), Vector2(20, 16), Vector2(480, 36))
	_rect(main.weather_hud, Vector2(20, 56), Vector2(480, 30))
	_rect(main.wallet_hud, Vector2(20, 90), Vector2(300, 28))
	_rect(main.quest_panel, Vector2(viewport.x - 370.0, 16), Vector2(350, 242))
	_rect(main.hotbar_panel, Vector2(16, viewport.y - 76.0), Vector2(220, 60))
	_rect(main.hud_button_bar, Vector2(viewport.x - 232.0, viewport.y - 76.0), Vector2(216, 60))
	if main.crop_inspector != null:
		_rect(main.crop_inspector, Vector2(16, viewport.y - 350.0), Vector2(360, 262))
	var prompt: Control = main.world.interaction_prompt
	_rect(prompt, Vector2((viewport.x - 440.0) * 0.5, viewport.y - 76.0), Vector2(440, 52))
	prompt.get_node("Message").add_theme_font_size_override("font_size", 20)
	_rect(main.toast, Vector2(20, 128), Vector2(460, 32))
	_rect(main.feedback, Vector2((viewport.x - 660.0) * 0.5, 126), Vector2(660, 44))
	main.feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

static func _rect(control: Control, origin: Vector2, dimensions: Vector2) -> void:
	control.set_anchors_preset(Control.PRESET_TOP_LEFT)
	control.position = origin
	control.size = dimensions
