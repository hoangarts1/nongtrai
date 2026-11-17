## LifeMachineCatalog — scrollable stable-key rows, no transaction state.
class_name LifeMachineCatalog
extends ScrollContainer

signal selected(id: StringName)
var rows: VBoxContainer
var cards: Array[LifeMachineCard] = []

func _ready() -> void:
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	# Leave themed inset room for the existing focus/hover scale animation.
	# Rows flush with the ScrollContainer edge otherwise lose their border/text.
	var inset: MarginContainer = MarginContainer.new()
	inset.theme_type_variation = &"LifeGalleryMargin"
	inset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(inset)
	rows = LifeHudParts.column(inset)
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func display(models: Array[Dictionary], selected_id: StringName, operation_mode: bool) -> void:
	# Reuse rows: owner/locale updates must not destroy an emitting/focused Button.
	while cards.size()>models.size():
		var card: LifeMachineCard = cards.pop_back()
		rows.remove_child(card)
		card.queue_free()
	for index: int in range(models.size()):
		if index>=cards.size():
			var card: LifeMachineCard = preload("res://ui/machine/machine_card.tscn").instantiate() as LifeMachineCard
			rows.add_child(card)
			card.pressed.connect(_pressed.bind(card))
			cards.append(card)
		var model: Dictionary = models[index]
		cards[index].display(model,model.id==selected_id and (operation_mode or model.kind==&"machine"))

func _pressed(card: LifeMachineCard) -> void:
	selected.emit(StringName(card.get_meta(&"machine_action")))
