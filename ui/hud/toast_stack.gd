## LifeHudToastStack — at most two timed view messages; no game state.
class_name LifeHudToastStack
extends VBoxContainer

func _ready() -> void:
	LifeTheme.bind(self,&"LifeHudColumn")
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func show_message(message: String, icon_id: StringName = &"journal") -> void:
	while get_child_count() >= 2:
		_remove(get_child(0))
	var card: LifeHudToastCard = preload("res://ui/hud/toast_card.tscn").instantiate() as LifeHudToastCard
	add_child(card)
	card.display(message,icon_id)
	var timer: Timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 3.0
	card.add_child(timer)
	timer.timeout.connect(_remove.bind(card),CONNECT_DEFERRED)
	timer.start()

func clear() -> void:
	for child: Node in get_children():
		_remove(child)

func _remove(card: Node) -> void:
	if is_instance_valid(card) and card.get_parent() == self:
		remove_child(card)
		card.free()
