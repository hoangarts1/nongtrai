## MachinePlacementFlow — transient modal placement; UiCoordinator owns clock/Player.
class_name MachinePlacementFlow
extends Node

const CONFIG: MachineBuildConfig = preload("res://data/machine_build_config.tres")
var panel: LifeMachineBuildOverlay
var main: Node
var machine_id: StringName = &""
var cell: Vector2i
var rotation: int = 0
var has_cell: bool = false
var preview: Dictionary = {}
var result: Dictionary = {}
var source: Dictionary = {}
var active: bool:
	get: return panel!=null and panel.visible

func configure(owner: Node) -> void:
	main = owner
	panel = preload("res://ui/machine/build_overlay.tscn").instantiate() as LifeMachineBuildOverlay
	main.add_child(panel)
	panel.pointed.connect(point)
	panel.confirmed.connect(confirm)
	panel.cancelled.connect(cancel)
	panel.rotated.connect(rotate)
	panel.visibility_changed.connect(_visibility_changed)
	set_process(false)

func begin(id: StringName) -> void:
	if not _may_begin():
		return
	if main.ui_coordinator.get_active_panel()!=main.machine_shop_panel or main.machine_inventory.get_quantity(id)<=0 or DataRegistry.get_machine(id)==null:
		return
	machine_id = id
	source = {}
	_show_preview(MachinePlacementState.VALID_ROTATIONS[0])

func begin_move(cell: Vector2i) -> void:
	if not _may_begin() or main.ui_coordinator.get_active_panel()!=main.machine_shop_panel:
		return
	var controller: LifeMachineController = main.machine_shop_panel.controller
	if not controller.operation_mode or controller.cell!=cell:
		return
	var ready: Dictionary = main.machine_placement_request.can_begin_move(cell,main.world.player.get_cell())
	if not bool(ready.ok):
		controller.result = ready
		controller.queue_refresh()
		return
	if StringName(ready.source.machine_id)!=controller.selected:
		return
	source = ready.source
	machine_id = StringName(source.machine_id)
	_show_preview(int(source.rotation))

func _may_begin() -> bool:
	return not active and OS.is_debug_build() and bool(main.get("_game_started")) and not GameClock.is_sleeping()

func _show_preview(initial_rotation: int) -> void:
	panel.ensure_built()
	rotation = initial_rotation
	has_cell = false
	result = {}
	panel.show()
	if not active:
		return
	main.tool_controller.set_placement_active(true)
	set_process(true)
	_refresh()
	panel.call_deferred("grab_focus")

func cancel() -> void:
	result = {}
	if panel!=null:
		panel.hide()
	_clear()

func _clear() -> void:
	set_process(false)
	machine_id = &""
	source = {}
	has_cell = false
	preview = {}
	if panel!=null and panel.ghost!=null:
		panel.ghost.hide()
	if main!=null:
		main.tool_controller.set_placement_active(false)

func _visibility_changed() -> void:
	if not panel.visible:
		_clear()

func _process(_delta: float) -> void:
	if GameClock.is_sleeping() or not bool(main.get("_game_started")):
		cancel()
	elif panel.get_viewport().gui_get_hovered_control()==panel:
		point(panel.get_viewport().get_mouse_position())
	else:
		_refresh()

func point(screen_position: Vector2) -> void:
	if not active:
		return
	var picked: Variant = main.world.pick_cell(screen_position)
	if (picked is Vector2i and (not has_cell or picked!=cell)) or (not picked is Vector2i and has_cell):
		result = {}
	has_cell = picked is Vector2i
	if has_cell:
		cell = picked as Vector2i
	_refresh()

func rotate(direction: int) -> void:
	if not active:
		return
	var choices: Array[int] = MachinePlacementState.VALID_ROTATIONS
	result = {}
	rotation = choices[posmod(choices.find(rotation)+direction,choices.size())]
	_refresh()

func handle_shortcut(event: InputEvent) -> bool:
	if not active or event.is_echo():
		return false
	if event.is_action_pressed("rotate_cw"):
		rotate(1)
	elif event.is_action_pressed("rotate_ccw"):
		rotate(-1)
	else:
		return false
	return true

func confirm() -> void:
	if not active or not has_cell or GameClock.is_sleeping() or main.ui_coordinator.get_active_panel()!=panel:
		return
	result = main.machine_placement_request.place(machine_id,cell,rotation,main.world.player.get_cell()) if source.is_empty() else main.machine_placement_request.move(source,cell,rotation,main.world.player.get_cell())
	if not bool(result.ok):
		_refresh()
		return
	var message: String = LifeMachinePresenter.result_text(result)
	panel.hide()
	main.machine_presentation.refresh()
	main.call("_mark_save_dirty")
	main.feedback.show_message(message)

func _refresh() -> void:
	if not active:
		return
	var validated: Dictionary = {"ok":false,"reason":&"invalid_state"}
	if has_cell:
		validated = main.machine_placement_request.preview(machine_id,cell,rotation,main.world.player.get_cell()) if source.is_empty() else main.machine_placement_request.preview_move(source,cell,rotation,main.world.player.get_cell())
	if validated!=preview:
		result = {}
	preview = validated
	if source.is_empty():
		panel.status.display(machine_id,cell,rotation,has_cell,preview,CONFIG.allowed_region)
	else:
		panel.status.display_move(machine_id,source.cell,cell,rotation,has_cell,preview,CONFIG.allowed_region)
	if source.is_empty():
		panel.status.info.text = tr("LAND_PLACEMENT") % [str(cell),rotation,LifeLandSnapshot.owned_cells(main.land_ownership)]
	if has_cell and preview.get("reason")==&"land_locked":
		panel.status.reason.text = tr("LAND_LOCKED")
	if not result.is_empty() and not bool(result.ok):
		panel.status.reason.text = tr("LAND_LOCKED") if result.reason==&"land_locked" else LifeMachinePresenter.reason(StringName(result.reason))
	if has_cell:
		panel.ghost.display(main.world,cell,machine_id,rotation,bool(preview.ok))
	else:
		panel.ghost.hide()
