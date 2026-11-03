## LifeHudRoot — non-interactive HUD shell; binding/layout live in separate classes.
class_name LifeHudRoot
extends Control

var right_column: VBoxContainer
var clock_card: LifeHudClockCard
var coins: LifeCoinLabel
var wallet_frame: LifeHudFrame
var toasts: LifeHudToastStack

func _ready() -> void:
	LifeTheme.bind(self)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_column = LifeHudParts.column(self)
	right_column.name = "RightColumn"
	clock_card = preload("res://ui/hud/clock_card.tscn").instantiate() as LifeHudClockCard
	right_column.add_child(clock_card)
	wallet_frame = LifeHudFrame.new()
	wallet_frame.name = "WalletFrame"
	right_column.add_child(wallet_frame)
	coins = preload("res://ui/components/coin_label.tscn").instantiate() as LifeCoinLabel
	wallet_frame.add_child(coins)
	coins.amount.theme_type_variation = &"LifeHudCoins"
	coins.get_node("Icon").hide()
	var coin_icon: TextureRect = LifeHudParts.texture(coins,UiIcons.get_icon(&"coin"),32)
	coins.move_child(coin_icon,0)
	coins.amount.clip_text = true
	coins.amount.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toasts = preload("res://ui/hud/toast_stack.tscn").instantiate() as LifeHudToastStack
	toasts.name = "ToastStack"
	toasts.z_index = 82
	add_child(toasts)
