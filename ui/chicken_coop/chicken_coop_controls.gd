## LifeChickenCoopControls — transient quantities and typed command intent only.
class_name LifeChickenCoopControls
extends VBoxContainer
signal commanded(action: StringName, quantity: int)
signal backed()
var buy: Button
var buy_feed: Button
var feed: Button
var collect: Button
var back: Button
var food_label: Label
var hens_label: Label
var food_quantity: SpinBox
var hen_quantity: SpinBox
var feedback: Label
var _model: Dictionary = {}

func _ready() -> void:
	theme_type_variation = &"LifeInvColumn"
	buy = LifePauseParts.button(self,&"COOP_BUY",&"LifePrimary")
	buy.pressed.connect(func() -> void: commanded.emit(&"buy_coop",int(_model.initial_hens)))
	var food_row: HBoxContainer = HBoxContainer.new()
	add_child(food_row)
	food_label = LifePauseParts.label(food_row,&"COOP_FOOD_QUANTITY")
	food_label.custom_minimum_size.x = 205
	food_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	food_quantity = _spinner(food_row)
	buy_feed = LifePauseParts.button(food_row,&"COOP_BUY_FEED",&"LifePrimary")
	buy_feed.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buy_feed.pressed.connect(func() -> void: commanded.emit(&"buy_feed",int(food_quantity.value)))
	var hen_row: HBoxContainer = HBoxContainer.new()
	add_child(hen_row)
	hens_label = LifePauseParts.label(hen_row,&"COOP_HENS_QUANTITY")
	hens_label.custom_minimum_size.x = 205
	hens_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	hen_quantity = _spinner(hen_row)
	feed = LifePauseParts.button(hen_row,&"COOP_FEED",&"LifePrimary")
	feed.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	feed.pressed.connect(func() -> void: commanded.emit(&"feed",int(hen_quantity.value)))
	collect = LifePauseParts.button(hen_row,&"COOP_COLLECT",&"LifePrimary")
	collect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	collect.pressed.connect(func() -> void: commanded.emit(&"collect",int(_model.eggs)))
	feedback = LifePauseParts.label(self,&"",&"LifeSecondaryText")
	back = LifePauseParts.button(self,&"COOP_BAG",&"LifeSecondary")
	back.pressed.connect(func() -> void: backed.emit())
	food_quantity.value_changed.connect(func(_v: float) -> void: _availability())
	hen_quantity.value_changed.connect(func(_v: float) -> void: _availability())

func _spinner(parent: Node) -> SpinBox:
	var spin: SpinBox = SpinBox.new()
	spin.min_value = 1
	spin.max_value = 1
	spin.step = 1
	spin.allow_greater = false
	spin.allow_lesser = false
	spin.custom_minimum_size.x = 110
	parent.add_child(spin)
	return spin

func display(model: Dictionary, result: Dictionary) -> void:
	_model = model
	buy.visible = not bool(model.owned)
	buy.text = tr("COOP_BUY") % int(model.price)
	buy.disabled = not bool(model.buy.ok)
	food_label.text = tr("COOP_FOOD_QUANTITY")
	hens_label.text = tr("COOP_HENS_QUANTITY")
	food_quantity.max_value = maxi(1,int(model.stack_limit))
	hen_quantity.max_value = maxi(1,int(model.hens)-int(model.fed))
	collect.text = tr("COOP_COLLECT") % int(model.eggs)
	collect.disabled = not bool(model.collect.ok)
	feed.text = tr("COOP_FEED")
	back.text = tr("COOP_BAG")
	_availability()
	feedback.text = LifeChickenCoopPresenter.reason(StringName(result.get("reason",&"ready")))
	if result.is_empty() and not bool(model.owned):
		feedback.text = LifeChickenCoopPresenter.reason(StringName(model.buy.reason))

func _availability() -> void:
	if _model.is_empty():
		return
	var quantity: int = int(food_quantity.value)
	buy_feed.text = tr("COOP_BUY_FEED") % (quantity*int(_model.feed_price))
	buy_feed.disabled = not bool(_model.owned) or quantity*int(_model.feed_price)>int(_model.coins) or quantity>int(_model.food_room)
	feed.disabled = not bool(_model.owned) or int(_model.hens)<=int(_model.fed) or int(hen_quantity.value)*int(_model.feed_units)>int(_model.food)
