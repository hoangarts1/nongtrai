## LifeHudToastStack — at most two timed view messages; no game state.
class_name LifeHudToastStack
extends VBoxContainer

var _locale: String = ""
var _dismissed: PackedInt64Array = PackedInt64Array()

func _ready() -> void:
	LifeTheme.bind(self,&"LifeHudColumn")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_locale = TranslationServer.get_locale()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		var next_locale: String = TranslationServer.get_locale()
		if not _locale.is_empty() and next_locale!=_locale:
			# Translation notifications traverse the tree; hide now, free afterward.
			for card: Node in get_children():
				(card as Control).hide()
				_dismissed.append(card.get_instance_id())
			_flush_dismissed.call_deferred()
		_locale = next_locale

func show_message(message: String, icon_id: StringName = &"journal") -> void:
	_flush_dismissed()
	while get_child_count() >= 2:
		_remove(get_child(0))
	var card: LifeHudToastCard = preload("res://ui/hud/toast_card.tscn").instantiate() as LifeHudToastCard
	add_child(card)
	card.display(message,icon_id)
	var timer: Timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 3.0
	card.add_child(timer)
	timer.timeout.connect(_remove_id.bind(card.get_instance_id()),CONNECT_DEFERRED)
	timer.start()

func clear() -> void:
	_dismissed.clear()
	for child: Node in get_children():
		_remove(child)

func _flush_dismissed() -> void:
	var ids: PackedInt64Array = _dismissed
	_dismissed = PackedInt64Array()
	for id: int in ids:
		_remove_id(id)

func _remove_id(id: int) -> void:
	_remove(instance_from_id(id) as Node)

func _remove(card: Node) -> void:
	if is_instance_valid(card) and card.get_parent() == self:
		remove_child(card)
		card.free()
