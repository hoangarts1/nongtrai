## ChibiUiMotion — view-only focus, button motion and cursor coordination.
## API:
##   func configure(main: Node) -> void
##   func refresh() -> void
##   func get_cursor() -> ChibiCursor
class_name ChibiUiMotion
extends Node

var _main: Node
var _cursor: ChibiCursor
var _panels: Array[Control] = []
var _control_tweens: Dictionary = {}
var _panel_tweens: Dictionary = {}
var _hovered_controls: Dictionary = {}

func configure(main: Node) -> void:
	_main = main
	name = "ChibiUiMotion"
	_cursor = ChibiCursor.new()
	add_child(_cursor)
	get_tree().node_added.connect(_on_node_added)
	_bind_panels()
	refresh()
	for panel: Control in _panels:
		if panel.visible:
			_play_open_bounce(panel)

func _exit_tree() -> void:
	var tree: SceneTree = get_tree()
	if tree != null and tree.node_added.is_connected(_on_node_added):
		tree.node_added.disconnect(_on_node_added)

func refresh() -> void:
	if _main != null:
		_bind_descendants(_main)

func get_cursor() -> ChibiCursor:
	return _cursor

func _bind_panels() -> void:
	if _main == null:
		return
	for candidate: Variant in [
		_main.inventory_panel,
		_main.tutorial_panel,
		_main.debug_menu,
		_main.pause_menu,
		_main.start_menu,
		_main.seed_shop_panel,
		_main.shipping_bin_panel,
		_main.npc_system.dialogue,
		_main.npc_system.journal
	]:
		if candidate is Control:
			var panel: Control = candidate as Control
			_panels.append(panel)
			if not panel.visibility_changed.is_connected(_on_panel_visibility_changed.bind(panel)):
				panel.visibility_changed.connect(_on_panel_visibility_changed.bind(panel))

func _on_node_added(node: Node) -> void:
	if _main == null or not _main.is_ancestor_of(node):
		return
	if node is Control:
		_bind_control(node as Control)

func _bind_descendants(root: Node) -> void:
	if root is Control:
		_bind_control(root as Control)
	for child: Node in root.get_children():
		_bind_descendants(child)

func _bind_control(control: Control) -> void:
	if control is ChibiCursor or control.has_meta(&"chibi_ui_motion_bound"):
		return
	control.set_meta(&"chibi_ui_motion_bound", true)
	control.set_meta(&"chibi_ui_base_scale", control.scale)
	control.resized.connect(_center_pivot.bind(control))
	_center_pivot(control)
	if control.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		control.mouse_entered.connect(_on_control_mouse_entered.bind(control))
		control.mouse_exited.connect(_on_control_mouse_exited.bind(control))
	if control is BaseButton:
		var button: BaseButton = control as BaseButton
		button.focus_mode = Control.FOCUS_ALL
		button.button_down.connect(_on_button_down.bind(button))
		button.button_up.connect(_on_button_up.bind(button))
		if button is Button:
			var text_button: Button = button as Button
			if text_button.name.begins_with("Tool_"):
				var tool_id: StringName = StringName(text_button.name.trim_prefix("Tool_"))
				text_button.pressed.connect(_on_tool_button_pressed.bind(tool_id))
	elif control is LineEdit or control is OptionButton:
		control.focus_mode = Control.FOCUS_ALL
	if control.focus_mode != Control.FOCUS_NONE:
		control.focus_entered.connect(_on_control_focus_entered.bind(control))
		control.focus_exited.connect(_on_control_focus_exited.bind(control))

func _center_pivot(control: Control) -> void:
	if is_instance_valid(control):
		control.pivot_offset = control.size * 0.5

func _on_control_mouse_entered(control: Control) -> void:
	_hovered_controls[control.get_instance_id()] = true
	if _cursor != null:
		_cursor.set_ui_hovered(true)
	if control is BaseButton:
		_tween_button(control as BaseButton, 1.035, 0.12)

func _on_control_mouse_exited(control: Control) -> void:
	_hovered_controls.erase(control.get_instance_id())
	if _cursor != null:
		_cursor.set_ui_hovered(not _hovered_controls.is_empty())
	if control is BaseButton:
		_tween_button(control as BaseButton, 1.0, 0.12)

func _on_control_focus_entered(control: Control) -> void:
	if control is BaseButton:
		_tween_button(control as BaseButton, 1.02, 0.1)

func _on_control_focus_exited(control: Control) -> void:
	if control is BaseButton and not _hovered_controls.has(control.get_instance_id()):
		_tween_button(control as BaseButton, 1.0, 0.1)

func _on_button_down(button: BaseButton) -> void:
	if button.disabled:
		return
	if _cursor != null:
		_cursor.set_pressed(true)
	_tween_button(button, 0.94, 0.07)

func _on_button_up(button: BaseButton) -> void:
	if _cursor != null:
		_cursor.set_pressed(false)
	if button.disabled:
		return
	_tween_button(button, 1.035 if _hovered_controls.has(button.get_instance_id()) else 1.0, 0.13)

func _on_tool_button_pressed(tool_id: StringName) -> void:
	if _cursor != null:
		_cursor.set_tool_mode(tool_id)

func _tween_button(button: BaseButton, multiplier: float, duration: float) -> void:
	if not is_instance_valid(button):
		return
	var control: Control = button as Control
	var key: int = control.get_instance_id()
	var old_tween: Tween = _control_tweens.get(key) as Tween
	if old_tween != null and old_tween.is_valid():
		old_tween.kill()
	var base_value: Variant = control.get_meta(&"chibi_ui_base_scale", Vector2.ONE)
	var base_scale: Vector2 = base_value if base_value is Vector2 else Vector2.ONE
	_center_pivot(control)
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(control, "scale", base_scale * multiplier, duration)
	_control_tweens[key] = tween

func _on_panel_visibility_changed(panel: Control) -> void:
	if panel.visible:
		_play_open_bounce(panel)
		call_deferred("_focus_panel", panel)

func _play_open_bounce(panel: Control) -> void:
	if not is_instance_valid(panel):
		return
	var key: int = panel.get_instance_id()
	var old_tween: Tween = _panel_tweens.get(key) as Tween
	if old_tween != null and old_tween.is_valid():
		old_tween.kill()
	_center_pivot(panel)
	panel.scale = Vector2(0.97, 0.97)
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.16)
	_panel_tweens[key] = tween

func _focus_panel(panel: Control) -> void:
	if not is_instance_valid(panel) or not panel.visible or panel == _main.start_menu:
		return
	var target: Control = _find_first_focusable(panel)
	if target != null:
		target.grab_focus()

func _find_first_focusable(root: Node) -> Control:
	for child: Node in root.get_children():
		if child is BaseButton:
			var button: BaseButton = child as BaseButton
			if button.visible and not button.disabled:
				return button as Control
		elif child is LineEdit:
			var line_edit: LineEdit = child as LineEdit
			if line_edit.visible and line_edit.editable:
				return line_edit
		var nested: Control = _find_first_focusable(child)
		if nested != null:
			return nested
	return null
