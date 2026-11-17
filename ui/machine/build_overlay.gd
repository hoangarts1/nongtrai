## LifeMachineBuildOverlay — modal click plane; native child controls get priority.
class_name LifeMachineBuildOverlay
extends Control

signal pointed(point: Vector2)
signal confirmed()
signal cancelled()
signal rotated(direction: int)
var ghost: MachinePlacementPreview
var status: LifeMachineBuildStatus
var _layout_queued: bool = false

func _ready() -> void:
	hide()
	LifeTheme.bind(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(_queue_layout)

func ensure_built() -> void:
	if status!=null:
		return
	ghost = MachinePlacementPreview.new()
	add_child(ghost)
	status = preload("res://ui/machine/build_status.tscn").instantiate() as LifeMachineBuildStatus
	add_child(status)
	status.confirmed.connect(func() -> void: confirmed.emit())
	status.cancelled.connect(func() -> void: cancelled.emit())
	status.rotated.connect(func(direction: int) -> void: rotated.emit(direction))
	status.minimum_size_changed.connect(_queue_layout)
	_queue_layout()

func _queue_layout() -> void:
	if not _layout_queued:
		_layout_queued = true
		call_deferred("_layout")

func _layout() -> void:
	_layout_queued = false
	if status==null:
		return
	var width: float = minf(1000.0,size.x-48.0)
	status.size.x = width
	status.size.y = status.get_combined_minimum_size().y
	status.position = Vector2((size.x-width)*0.5,size.y-status.size.y-24.0)

func _gui_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event is InputEventMouseMotion:
		pointed.emit((event as InputEventMouseMotion).position)
	elif event is InputEventMouseButton and event.is_pressed():
		var mouse: InputEventMouseButton = event as InputEventMouseButton
		if mouse.button_index==MOUSE_BUTTON_RIGHT:
			cancelled.emit()
		elif mouse.button_index==MOUSE_BUTTON_LEFT:
			pointed.emit((event as InputEventMouseButton).position)
			confirmed.emit()
	elif event.is_action_pressed("use_tool"):
		confirmed.emit()
	else:
		return
	accept_event()
