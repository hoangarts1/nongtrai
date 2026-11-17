## LifeLandFooter ? actual wallet/result and native confirmation/cancel buttons.
class_name LifeLandFooter
extends VBoxContainer

signal confirmed()
signal cancelled()
var wallet: Label
var result_label: Label
var buy_button: Button
var cancel_button: Button

func _ready() -> void:
	wallet = LifePauseParts.label(self,&"",&"LifeInvTitle")
	result_label = LifePauseParts.label(self,&"")
	var row: HBoxContainer = HBoxContainer.new()
	row.theme_type_variation = &"LifeHudRow"
	add_child(row)
	cancel_button = LifePauseParts.button(row,&"UI_CLOSE")
	buy_button = LifePauseParts.button(row,&"LAND_BUY",&"LifePrimary")
	cancel_button.pressed.connect(func() -> void: cancelled.emit())
	buy_button.pressed.connect(func() -> void: confirmed.emit())

func display(model: Dictionary, result: Dictionary) -> void:
	wallet.text = tr("LAND_WALLET") % int(model.coins)
	buy_button.text = tr("LAND_BUY")
	buy_button.disabled = not bool(model.can_buy)
	buy_button.tooltip_text = LifeLandPresenter.reason(StringName(model.reason))
	cancel_button.text = tr("UI_CLOSE")
	result_label.visible = not result.is_empty()
	result_label.text = LifeLandPresenter.reason(StringName(result.get("reason",&""))) if not result.is_empty() else ""
