## UiCoordinator — one modal at a time and a single UI input/visibility lock.
## API:
##   func configure(main: Node) -> void
##   func close_active() -> void
##   func get_active_panel() -> Control
class_name UiCoordinator
extends Node

var _main: Node
var _panels: Array[Control] = []
var _active: Control
var _switching: bool = false
var _base_pause: bool = false
var _backdrop: ColorRect
var _layout_queued: bool = false

func configure(main: Node) -> void:
	_main = main
	_panels.assign([main.inventory_panel, main.tutorial_panel, main.debug_menu, main.pause_menu, main.start_menu, main.seed_shop_panel, main.shipping_bin_panel, main.npc_system.dialogue, main.npc_system.journal])
	_panels.append(main.day_end_flow.panel)
	_panels.append(main.morning_flow.panel)
	_panels.append(main.character_flow.panel)
	# Read-only HUD decoration must not intercept the wide modal header beneath it.
	_ignore_pointer(main.hud_presenter.root.right_column)
	_backdrop = ColorRect.new()
	_backdrop.name = "ModalBackdrop"
	_backdrop.color = Color(0.015, 0.025, 0.025, 0.66)
	_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_backdrop.z_index = 80
	main.add_child(_backdrop)
	# GUI picking follows sibling order, independently from rendering z_index.
	main.move_child(_backdrop, 0)
	_backdrop.hide()
	for panel: Control in _panels:
		panel.z_index = 81
		panel.visibility_changed.connect(_visibility_changed.bind(panel))
		panel.minimum_size_changed.connect(_queue_layout)
	main.quest_panel.minimum_size_changed.connect(_queue_layout)
	main.hotbar_panel.minimum_size_changed.connect(_queue_layout)
	main.toast.z_index = 82
	main.feedback.z_index = 82
	UiLayout.apply(main)
	main.get_viewport().size_changed.connect(_resize)
	# Start screen takes precedence over automatic first-run help.
	if main.start_menu.visible:
		_visibility_changed(main.start_menu)
	elif main.tutorial_panel.visible:
		_visibility_changed(main.tutorial_panel)

func get_active_panel() -> Control:
	return _active

func _ignore_pointer(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child: Node in node.get_children():
		_ignore_pointer(child)

func _resize() -> void:
	_layout_queued = false
	UiLayout.reflow(_main)

func _queue_layout() -> void:
	if not _layout_queued:
		_layout_queued = true
		call_deferred("_resize")

func _visibility_changed(panel: Control) -> void:
	if _switching:
		return
	_switching = true
	if _active == _main.day_end_flow.panel and panel != _active and panel.visible:
		_close(panel)
		_switching = false
		_sync()
		return
	if panel.visible:
		if _active == null:
			_base_pause = GameClock.paused
		elif _active == _main.debug_menu:
			_base_pause = GameClock.paused
		for other: Control in _panels:
			if other != panel and other.visible:
				_close(other)
		_active = panel
		if panel != _main.debug_menu:
			GameClock.paused = true
		else:
			GameClock.paused = _base_pause
	else:
		if _active == panel:
			if panel == _main.debug_menu:
				_base_pause = GameClock.paused
			_active = null
			GameClock.paused = _base_pause
	_switching = false
	_sync()
	call_deferred("_resize")

func _close(panel: Control) -> void:
	if panel == _main.day_end_flow.panel:
		_main.day_end_flow.cancel()
	elif panel == _main.morning_flow.panel:
		_main.morning_flow.dismiss()
	elif panel == _main.character_flow.panel:
		_main.character_flow.close()
	elif panel == _main.inventory_panel:
		_main.inventory_panel.close_inventory()
	elif panel == _main.tutorial_panel:
		_main.tutorial_panel.close_help()
	elif panel == _main.pause_menu:
		_main.pause_menu.close()
	elif panel == _main.seed_shop_panel or panel == _main.shipping_bin_panel:
		panel.call("close")
	elif panel == _main.npc_system.dialogue or panel == _main.npc_system.journal:
		_main.npc_system.close_panels()
	else:
		panel.hide()

func close_active() -> void:
	if _active != null and _active != _main.start_menu:
		_close(_active)
		_sync()

func _process(_delta: float) -> void:
	if _main != null:
		_sync()

func _sync() -> void:
	var modal: bool = _active != null and _active.visible
	_backdrop.visible = modal
	_backdrop.color.a = 0.0 if _main.start_menu.visible else 0.5
	_main.hotbar_panel.visible = not modal
	_main.hud_button_bar.visible = not modal
	_main.quest_panel.visible = not modal and not _main.quest_state.is_complete()
	_main.get_node("StatusCard").hide()
	_main.hud_presenter.sync(modal,_main.start_menu.visible)
	_main.world.player.movement_enabled = not modal and bool(_main.get("_game_started")) and not GameClock.is_sleeping()
	if modal:
		_main.world.interaction_prompt.hide()
		_main.crop_inspector.hide()
		if _active in [_main.seed_shop_panel, _main.shipping_bin_panel, _main.npc_system.dialogue]:
			var viewport: Vector2 = _main.get_viewport().get_visible_rect().size
			_main.feedback.position = Vector2(20, viewport.y - 36.0)
			_main.feedback.size = Vector2(viewport.x - 40.0, 32)
		else:
			_main.feedback.hide()
		if _active != _main.debug_menu:
			GameClock.paused = true
	if GameClock.is_sleeping():
		_main.crop_inspector.hide()
	if _main.crop_inspector.visible:
		_main.world.interaction_prompt.hide()

func _input(event: InputEvent) -> void:
	if _active == null or event.is_echo():
		return
	# Let GUI buttons/scrollbars receive mouse events before gameplay filtering.
	if event is InputEventMouse:
		return
	if _active == _main.day_end_flow.panel:
		if event.is_action_pressed("pause") or event.is_action_pressed("cancel"):
			_main.day_end_flow.cancel()
			get_viewport().set_input_as_handled()
			return
		for action: StringName in [&"open_inventory",&"open_help",&"open_journal",&"toggle_debug_menu",&"interact",&"use_tool"]:
			if event.is_action_pressed(action):
				get_viewport().set_input_as_handled()
		return
	if _main.inventory_panel.controller.handle_input(event):
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause") or event.is_action_pressed("cancel"):
		if _active == _main.start_menu:
			_main.start_menu.handle_back()
		else:
			close_active()
		get_viewport().set_input_as_handled()
		return
	if _active == _main.start_menu:
		for action: StringName in [&"ui_focus_next",&"ui_focus_prev",&"ui_accept",&"ui_left",&"ui_right",&"ui_up",&"ui_down"]:
			if event.is_action_pressed(action):
				return
		if not get_viewport().gui_get_focus_owner() is LineEdit:
			for action: StringName in [&"open_inventory", &"open_help", &"open_journal", &"toggle_debug_menu", &"interact", &"use_tool"]:
				if event.is_action_pressed(action):
					get_viewport().set_input_as_handled()
		return
	var target: StringName = &""
	if _active == _main.pause_menu or _active == _main.morning_flow.panel or _active == _main.character_flow.panel:
		# Tab/Space also bind world actions; native GUI focus/activation wins here.
		for action: StringName in [&"ui_focus_next",&"ui_focus_prev",&"ui_accept",&"ui_left",&"ui_right",&"ui_up",&"ui_down"]:
			if event.is_action_pressed(action):
				return
	if event.is_action_pressed("open_inventory"):
		target = &"inventory"
	elif event.is_action_pressed("open_help"):
		target = &"help"
	elif event.is_action_pressed("toggle_debug_menu"):
		target = &"debug"
	elif event.is_action_pressed("open_journal"):
		target = &"journal"
	if not target.is_empty():
		var old: Control = _active
		close_active()
		if target == &"inventory" and old != _main.inventory_panel:
			_main.inventory_panel.toggle_inventory()
		elif target == &"help" and old != _main.tutorial_panel:
			_main.tutorial_panel.open_help()
		elif target == &"debug" and old != _main.debug_menu:
			_main.debug_menu.show()
		elif target == &"journal" and old != _main.npc_system.journal:
			_main.npc_system.open_journal()
		_sync()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact") or event.is_action_pressed("use_tool"):
		if event.is_action_pressed("interact") and _active in [_main.seed_shop_panel, _main.shipping_bin_panel]:
			close_active()
		get_viewport().set_input_as_handled()
