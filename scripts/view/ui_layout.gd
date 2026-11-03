## UiLayout — readable runtime theme and viewport-based HUD/modal rectangles.
class_name UiLayout
extends RefCounted

static func apply(main: Node) -> void:
	var shared: Theme = LifeTheme.get_theme()
	for child: Node in main.get_children():
		if child is Control:
			(child as Control).theme = shared
			_style_children(child)
	main.hotbar_panel.refresh_readability()
	main.start_menu.apply_chibi_style()
	var status: Panel = main.get_node_or_null("StatusCard") as Panel
	if status == null:
		status = Panel.new()
		status.name = "StatusCard"
		status.mouse_filter = Control.MOUSE_FILTER_IGNORE
		status.z_index = -1
		main.add_child(status)
	LifeTheme.bind(status,&"LifeStatus")
	var prompt: PanelContainer = main.world.interaction_prompt
	prompt.remove_theme_stylebox_override("panel")
	LifeTheme.bind(prompt,&"LifeCompactPanel")
	main.tutorial_panel.get_node("MarginContainer/VBoxContainer/Instructions").custom_minimum_size.x = 560.0
	reflow(main)

static func _style_children(node: Node) -> void:
	if node is HotbarPanel or node is HudButtonBar or node is QuestPanel or node is LifeHudRoot or node is LifeDayEndSheet or node is InventoryPanel or (node is NpcPanel and node.tabs!=null):
		return
	if node is Label:
		var label: Label = node as Label
		if label.has_theme_font_size_override("font_size"):
			var old_size: int = label.get_theme_font_size("font_size")
			label.theme_type_variation = LifeTheme.text_variation(18 if label.name == &"ToolLabel" else maxi(24,old_size))
			label.remove_theme_font_size_override("font_size")
		if label.has_theme_color_override("font_color"):
			label.remove_theme_color_override("font_color")
	if node is Button:
		var button: Button = node as Button
		button.custom_minimum_size.y = maxf(40.0,button.custom_minimum_size.y)
	if node is PanelContainer:
		var panel: PanelContainer = node as PanelContainer
		panel.remove_theme_stylebox_override("panel")
		panel.theme_type_variation = &"LifeCompactPanel"
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
	var summary_size: Vector2 = Vector2(minf(1200,viewport.x-64),minf(760,viewport.y-48))
	_rect(main.day_end_flow.panel,(viewport-summary_size)*0.5,summary_size)
	_rect(main.inventory_panel,(viewport-summary_size)*0.5,summary_size)
	_rect(main.npc_system.journal,(viewport-summary_size)*0.5,summary_size)
	LifeHudRegions.apply(main)
	var message: Label = main.world.interaction_prompt.get_node("Message") as Label
	message.remove_theme_font_size_override("font_size")
	message.theme_type_variation = &"LifeText20"

static func _rect(control: Control, origin: Vector2, dimensions: Vector2) -> void:
	control.set_anchors_preset(Control.PRESET_TOP_LEFT)
	control.position = origin
	control.size = dimensions
