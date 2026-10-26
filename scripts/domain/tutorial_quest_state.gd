## TutorialQuestState — tracks the five farming onboarding milestones.
## API:
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
##   signal step_changed(step_index: int, completed: bool)
class_name TutorialQuestState
extends RefCounted

signal step_changed(step_index: int, completed: bool)
signal all_completed()

const STEP_COUNT: int = 7
var _completed: Array[bool] = [false, false, false, false, false, false, false]

func _init() -> void:
	Events.plot_tilled.connect(_on_plot_tilled)
	Events.crop_planted.connect(_on_crop_planted)
	Events.plot_watered.connect(_on_plot_watered)
	Events.crop_harvested.connect(_on_crop_harvested)
	GameClock.sleep_finished.connect(_on_sleep_finished)
	Events.item_sold.connect(_on_item_sold)
	Events.item_purchased.connect(_on_item_purchased)

func is_step_completed(step_index: int) -> bool:
	return step_index >= 0 and step_index < STEP_COUNT and _completed[step_index]

func is_complete() -> bool:
	for completed: bool in _completed:
		if not completed:
			return false
	return true

func serialize() -> Dictionary:
	var steps: Array[bool] = []
	steps.append_array(_completed)
	return {"completed": steps}

func deserialize(data: Dictionary) -> void:
	var values: Array = data.get("completed", [])
	for index: int in range(STEP_COUNT):
		_completed[index] = index < values.size() and bool(values[index])
		step_changed.emit(index, _completed[index])

func _complete_step(step_index: int) -> void:
	if step_index < 0 or step_index >= STEP_COUNT or _completed[step_index]:
		return
	_completed[step_index] = true
	step_changed.emit(step_index, true)
	if is_complete():
		all_completed.emit()

func _on_plot_tilled(_cell: Vector2i) -> void:
	_complete_step(0)

func _on_crop_planted(_cell: Vector2i, _crop_id: StringName) -> void:
	_complete_step(1)

func _on_plot_watered(_cell: Vector2i) -> void:
	_complete_step(2)

func _on_sleep_finished(_day_index: int) -> void:
	_complete_step(3)

func _on_crop_harvested(_cell: Vector2i, _crop_id: StringName, _quantity: int, _quality: int) -> void:
	_complete_step(4)

func _on_item_sold(_item_id: StringName, _quantity: int, _total_price: int) -> void:
	_complete_step(5)

func _on_item_purchased(_item_id: StringName, _quantity: int, _total_price: int) -> void:
	_complete_step(6)
