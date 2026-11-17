## LifeMachineFooter — fixed wallet/result/native commands, no state ownership.
class_name LifeMachineFooter
extends VBoxContainer

signal requested(action: StringName)
var result: Label
var wallet: Label
var buttons: Dictionary = {}

func _ready() -> void:
	result = LifeMachinePresenter.label(self,&"LifeText18")
	result.custom_minimum_size.y = 48
	var row: HBoxContainer = HBoxContainer.new()
	row.theme_type_variation = &"LifeHudRow"
	add_child(row)
	var coin_plate: PanelContainer = PanelContainer.new()
	coin_plate.theme_type_variation = &"LifeHudCaption"
	coin_plate.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(coin_plate)
	wallet = LifeMachinePresenter.label(coin_plate,&"LifeHudCoins")
	for action: StringName in [&"catalog",&"buy",&"place",&"start",&"collect",&"move",&"return"]:
		var button: Button = LifeMachinePresenter.button(row,&"",String(action),&"LifePrimary" if action in [&"buy",&"start",&"collect"] else &"LifeSecondary")
		button.custom_minimum_size.x = 148
		button.pressed.connect(func() -> void: requested.emit(action))
		buttons[action] = button

func display(model: Dictionary, feedback: Dictionary) -> void:
	result.text = LifeMachinePresenter.result_text(feedback)
	wallet.text = tr("UI_WALLET_COINS") % int(model.coins)
	var operation: bool = bool(model.operation)
	for action: StringName in buttons:
		var button: Button = buttons[action]
		button.visible = operation if action in [&"catalog",&"start",&"collect",&"move",&"return"] else not operation
	buttons[&"catalog"].text = tr("MUI_BACK")
	buttons[&"buy"].text = tr("UI_BUY")
	buttons[&"place"].text = tr("PLC_PLACE")
	buttons[&"start"].text = tr("UI_MACHINE_START")
	buttons[&"collect"].text = tr("UI_MACHINE_COLLECT")
	buttons[&"return"].text = tr("PLC_RETURN")
	buttons[&"move"].text = tr("PLC_MOVE")
	_set_reason(&"buy",StringName(model.buy_reason))
	_set_reason(&"place",&"machine_not_owned" if int(model.owned)<=0 else &"")
	_set_reason(&"start",StringName(model.recipe.reason))
	var returned: Dictionary = model.get("return",{})
	_set_reason(&"return",StringName(returned.get("reason",&"no_machine")) if not bool(returned.get("ok",false)) else &"")
	var moved: Dictionary = model.get("move",{})
	_set_reason(&"move",StringName(moved.get("reason",&"no_machine")) if not bool(moved.get("ok",false)) else &"")
	buttons[&"move"].set_meta(&"machine_action","move:%s" % model.cell)
	var collect: Dictionary = model.collect
	_set_reason(&"collect",StringName(collect.get("reason",&"no_output")) if not bool(collect.get("ok",false)) else &"")
	buttons[&"start"].set_meta(&"machine_action","start:%s:%s" % [model.cell,model.recipe.id])
	buttons[&"collect"].set_meta(&"machine_action","collect:%s" % model.cell)

func _set_reason(action: StringName, reason: StringName) -> void:
	var button: Button = buttons[action]
	button.disabled = not reason.is_empty()
	button.tooltip_text = LifeMachinePresenter.reason(reason) if button.disabled else button.text
