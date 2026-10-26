## WalletState — manages player coins, atomic spend/earn, and serialization.
## API:
##   func get_coins() -> int
##   func add_coins(amount: int, reason: StringName = &"") -> void
##   func remove_coins(amount: int, reason: StringName = &"") -> bool
##   func has_coins(amount: int) -> bool
##   func can_afford(amount: int) -> bool
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
##   signal coins_changed(new_total: int, delta: int, reason: StringName)
class_name WalletState
extends RefCounted

signal coins_changed(new_total: int, delta: int, reason: StringName)

var _coins: int = 100

func _init(starting_coins: int = 100) -> void:
	_coins = maxi(0, starting_coins)

func get_coins() -> int:
	return _coins

func add_coins(amount: int, reason: StringName = &"") -> void:
	if amount <= 0:
		return
	_coins += amount
	coins_changed.emit(_coins, amount, reason)
	Events.coins_changed.emit(_coins, amount, reason)

func remove_coins(amount: int, reason: StringName = &"") -> bool:
	if amount < 0 or _coins < amount:
		return false
	_coins -= amount
	coins_changed.emit(_coins, -amount, reason)
	Events.coins_changed.emit(_coins, -amount, reason)
	return true

func has_coins(amount: int) -> bool:
	return amount >= 0 and _coins >= amount

func can_afford(amount: int) -> bool:
	return has_coins(amount)

func serialize() -> Dictionary:
	return {"coins": _coins}

func deserialize(data: Dictionary) -> void:
	_coins = maxi(0, int(data.get("coins", 0)))
	coins_changed.emit(_coins, 0, &"load")
	Events.coins_changed.emit(_coins, 0, &"load")
