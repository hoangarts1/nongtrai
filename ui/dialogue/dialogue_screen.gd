## LifeDialogueScreen — mockup12 composition, independent of transaction owners.
class_name LifeDialogueScreen
extends Control

signal requested(id: StringName)
signal closed()
var speaker: LifeDialogueSpeaker
var body: LifeDialogueBody
var choices: LifeDialogueChoices
var close_button: Button

func _ready() -> void:
	LifeTheme.bind(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	speaker = preload("res://ui/dialogue/dialogue_speaker.tscn").instantiate() as LifeDialogueSpeaker
	body = preload("res://ui/dialogue/dialogue_body.tscn").instantiate() as LifeDialogueBody
	choices = preload("res://ui/dialogue/dialogue_choices.tscn").instantiate() as LifeDialogueChoices
	add_child(speaker)
	add_child(body)
	add_child(choices)
	close_button = choices.close_button
	choices.requested.connect(func(id: StringName) -> void: requested.emit(id))
	choices.closed.connect(func() -> void: closed.emit())
	resized.connect(_layout)
	body.minimum_size_changed.connect(_layout, CONNECT_DEFERRED)
	choices.minimum_size_changed.connect(_layout, CONNECT_DEFERRED)
	_layout()

func display(snapshot: Dictionary) -> void:
	speaker.display(snapshot)
	body.display(snapshot)
	var actions: Array[Dictionary] = []
	for value: Variant in snapshot.get("actions", []):
		if value is Dictionary:
			actions.append(value.duplicate(true))
	choices.display(actions)
	_layout()

func _layout() -> void:
	var body_height: float = maxf(clampf(size.y * 0.35, 180.0, 280.0), body.get_combined_minimum_size().y)
	var upper: float = maxf(0.0, size.y - body_height - 16.0)
	speaker.position = Vector2(16.0, 0.0)
	speaker.size = Vector2(size.x * 0.34, upper)
	body.position = Vector2(0.0, upper + 16.0)
	body.size = Vector2(size.x, body_height)
	choices.position = Vector2(size.x * 0.43, maxf(0.0, upper - choices.get_combined_minimum_size().y) * 0.5)
	choices.size = Vector2(size.x * 0.55, choices.get_combined_minimum_size().y)
