## LifeBagUpgradeFooter - native commands and actual wallet/result.
class_name LifeBagUpgradeFooter
extends VBoxContainer

signal confirmed()
signal backed()
var wallet: Label
var feedback: Label
var buy_button: Button
var back_button: Button

func _ready() -> void:
	wallet = LifePauseParts.label(self,&"",&"LifeInvTitle")
	feedback = LifePauseParts.label(self,&"")
	var row: HBoxContainer = HBoxContainer.new()
	row.theme_type_variation = &"LifeHudRow"
	add_child(row)
	back_button = LifePauseParts.button(row,&"BAG_UP_BACK")
	buy_button = LifePauseParts.button(row,&"BAG_UP_CONFIRM",&"LifePrimary")
	back_button.pressed.connect(func() -> void: backed.emit())
	buy_button.pressed.connect(func() -> void: confirmed.emit())

func display(model: Dictionary, result: Dictionary) -> void:
	wallet.text = tr("BAG_UP_WALLET") % int(model.coins)
	back_button.text = tr("BAG_UP_BACK")
	buy_button.text = tr("BAG_UP_CONFIRM")
	buy_button.disabled = not bool(model.can_buy)
	buy_button.tooltip_text = LifeBagUpgradePresenter.reason(StringName(model.reason))
	feedback.visible = not result.is_empty()
	feedback.text = LifeBagUpgradePresenter.reason(StringName(result.get("reason",&""))) if not result.is_empty() else ""
