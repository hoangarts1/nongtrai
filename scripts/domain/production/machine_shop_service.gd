## MachineShopService — atomic domain purchase boundary for machine ownership.
## API:
##   func purchase(machine_id: StringName, house_level: int) -> Dictionary
class_name MachineShopService
extends RefCounted

var shop_data: MachineShopData
var inventory: MachineInventory
var wallet: WalletState

func configure(shop: MachineShopData, owned: MachineInventory, funds: WalletState) -> void:
	shop_data = shop
	inventory = owned
	wallet = funds

func purchase(machine_id: StringName, house_level: int) -> Dictionary:
	if shop_data == null or inventory == null or wallet == null:
		return _failure(&"invalid_service")
	if not shop_data.sells(machine_id):
		return _failure(&"machine_not_sold")
	var machine: MachineData = DataRegistry.get_machine(machine_id)
	if machine == null:
		return _failure(&"unknown_machine")
	if house_level < machine.unlock_house_level:
		return _failure(&"house_level_locked")
	if machine.purchase_price <= 0:
		return _failure(&"invalid_price")
	if not EconomyService.debit(wallet,machine.purchase_price, &"buy_machine",true):
		return _failure(&"insufficient_coins")
	if not inventory.add_machine(machine_id):
		EconomyService.credit(wallet,machine.purchase_price, &"buy_machine_rollback",true)
		return _failure(&"inventory_rejected")
	return {"ok": true, "reason": &"purchased", "machine_id": machine_id}

func _failure(reason: StringName) -> Dictionary:
	return {"ok": false, "reason": reason}
