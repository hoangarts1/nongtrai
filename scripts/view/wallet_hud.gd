## WalletHud — displays player's coin balance on the HUD.
## API:
##   func configure(wallet: WalletState) -> void
class_name WalletHud
extends Label

var _wallet: WalletState = null

func configure(wallet: WalletState) -> void:
	_wallet = wallet
	if _wallet != null:
		if not _wallet.coins_changed.is_connected(_on_coins_changed):
			_wallet.coins_changed.connect(_on_coins_changed)
		_render(_wallet.get_coins())

func _on_coins_changed(total: int, _delta: int, _reason: StringName) -> void:
	_render(total)

func _render(coins: int) -> void:
	text = tr("UI_WALLET_COINS") % coins
