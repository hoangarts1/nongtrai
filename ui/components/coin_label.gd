## LifeCoinLabel — localized integer coin formatting, with no wallet mutation.
class_name LifeCoinLabel
extends HBoxContainer

var coins: int = 0
var amount: Label

func _ready() -> void:
	LifeTheme.bind(self)
	var icon: LifeIconPlaceholder = LifeIconPlaceholder.new()
	icon.name = "Icon"
	icon.text_key = &"UI_KIT_COIN"
	icon.tone = &"coin"
	add_child(icon)
	amount = Label.new()
	amount.name = "Amount"
	amount.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(amount)
	_refresh()

func set_coins(value: int) -> void:
	coins = value
	_refresh()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_refresh()

func _refresh() -> void:
	if amount != null:
		var text_value: String = str(absi(coins))
		var index: int = text_value.length()-3
		while index > 0:
			text_value = text_value.insert(index,"." if TranslationServer.get_locale().begins_with("vi") else ",")
			index -= 3
		amount.text = tr("UI_KIT_COINS") % (("-" if coins < 0 else "")+text_value)
