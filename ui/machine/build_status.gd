## LifeMachineBuildStatus — fixed native commands and real placement feedback.
class_name LifeMachineBuildStatus
extends PanelContainer

signal confirmed()
signal cancelled()
signal rotated(direction: int)
var title: Label
var info: Label
var reason: Label
var hints: Label
var confirm_button: Button
var cancel_button: Button
var clockwise: Button
var counterclockwise: Button

func _ready() -> void:
	LifeTheme.bind(self,&"LifeHudWood")
	mouse_filter = Control.MOUSE_FILTER_STOP
	var column: VBoxContainer = LifePauseParts.paper(self)
	title = LifeMachinePresenter.label(column,&"LifeInvTitle")
	info = LifeMachinePresenter.label(column)
	reason = LifeMachinePresenter.label(column)
	hints = LifeMachinePresenter.label(column,&"LifeSecondaryText")
	var row: HBoxContainer = HBoxContainer.new()
	row.theme_type_variation = &"LifeHudRow"
	column.add_child(row)
	counterclockwise = LifeMachinePresenter.button(row,&"PLC_LEFT","build:left")
	clockwise = LifeMachinePresenter.button(row,&"PLC_RIGHT","build:right")
	cancel_button = LifeMachinePresenter.button(row,&"PLC_CANCEL","build:cancel")
	confirm_button = LifeMachinePresenter.button(row,&"PLC_CONFIRM","build:confirm",&"LifePrimary")
	counterclockwise.pressed.connect(func() -> void: rotated.emit(-1))
	clockwise.pressed.connect(func() -> void: rotated.emit(1))
	cancel_button.pressed.connect(func() -> void: cancelled.emit())
	confirm_button.pressed.connect(func() -> void: confirmed.emit())

func display(id: StringName, cell: Vector2i, rotation: int, has_cell: bool, preview: Dictionary, region: Rect2i) -> void:
	var machine: MachineData = DataRegistry.get_machine(id)
	title.text = tr("PLC_TITLE") % tr(String(machine.display_name_key)) if machine!=null else ""
	info.text = tr("PLC_CELL") % [str(cell),rotation,region.size.x,region.size.y]
	reason.text = tr("PLC_PICK") if not has_cell else (tr("PLC_VALID") if bool(preview.ok) else LifeMachinePresenter.reason(StringName(preview.reason)))
	hints.text = tr("PLC_HINTS")
	counterclockwise.text = tr("PLC_LEFT")
	clockwise.text = tr("PLC_RIGHT")
	cancel_button.text = tr("PLC_CANCEL")
	confirm_button.text = tr("PLC_CONFIRM")
	confirm_button.disabled = not has_cell or not bool(preview.get("ok",false))

func display_move(id: StringName, source_cell: Vector2i, cell: Vector2i, rotation: int, has_cell: bool, preview: Dictionary, region: Rect2i) -> void:
	display(id,cell,rotation,has_cell,preview,region)
	var machine: MachineData = DataRegistry.get_machine(id)
	title.text = tr("PLC_MOVE_TITLE") % tr(String(machine.display_name_key)) if machine!=null else ""
	info.text = tr("PLC_MOVE_CELL") % [str(source_cell),str(cell),rotation]
	if not has_cell or bool(preview.ok):
		reason.text = tr("PLC_MOVE_VALID") if has_cell else tr("PLC_MOVE_PICK")
	hints.text = tr("PLC_MOVE_HINTS")
	confirm_button.text = tr("PLC_MOVE_CONFIRM")
	cancel_button.text = tr("PLC_MOVE_CANCEL")
