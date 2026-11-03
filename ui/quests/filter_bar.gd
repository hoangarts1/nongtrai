## LifeQuestFilters — transient view filters; daily quests do not exist.
class_name LifeQuestFilters
extends GridContainer

signal filter_requested(id: StringName)
const IDS: Array[StringName] = [&"all",&"active",&"completed",&"daily"]
const KEYS: Array[StringName] = [&"BOOK_ALL",&"BOOK_ACTIVE",&"BOOK_COMPLETED",&"BOOK_DAILY"]
var buttons: Array[Button] = []

func _ready() -> void:
	columns = 2
	theme_type_variation = &"LifeInvGrid"
	for index: int in range(IDS.size()):
		var button: Button = Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.y = 38
		button.disabled = IDS[index]==&"daily"
		button.pressed.connect(func() -> void: filter_requested.emit(IDS[index]))
		add_child(button)
		buttons.append(button)

func display(active: StringName, counts: Dictionary) -> void:
	for index: int in range(buttons.size()):
		var button: Button = buttons[index]
		button.text = tr(String(KEYS[index]))
		if not button.disabled:
			button.text += " · %d" % int(counts.get(IDS[index],0))
		button.tooltip_text = tr("INV_UNAVAILABLE") if button.disabled else button.text
		button.theme_type_variation = &"LifeInvFilterActive" if IDS[index]==active else &"LifeInvFilter"
