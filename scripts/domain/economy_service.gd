## EconomyService — checked integer currency and guarded bag/coin exchanges.
## API: credit/debit, can_credit, total, buy/sell, is_busy.
## WalletState/InventoryState remain the only persisted owners; no saved locks.
class_name EconomyService
extends RefCounted

const MAX_AMOUNT: int = 9007199254740991 # Exact external JSON integer integrity.
static var _active: Dictionary[int, RefCounted] = {}
static var _independent: Dictionary[int, bool] = {}

static func is_busy(wallet: WalletState) -> bool:
	return wallet!=null and _active.has(wallet.get_instance_id())

static func can_credit(wallet: WalletState, amount: int) -> bool:
	return wallet!=null and amount>=0 and amount<=MAX_AMOUNT and wallet.get_coins()>=0 and wallet.get_coins()<=MAX_AMOUNT-amount

@warning_ignore("integer_division")
static func total(unit_price: int, quantity: int) -> int:
	if unit_price<=0 or quantity<=0 or quantity>MAX_AMOUNT or unit_price>MAX_AMOUNT/quantity: return -1
	return unit_price*quantity

static func credit(wallet: WalletState, amount: int, reason: StringName, independent: bool = false) -> bool:
	if reason.is_empty() or not can_credit(wallet,amount) or not _can_enter(wallet,independent): return false
	var previous: RefCounted = _active.get(wallet.get_instance_id())
	var token: RefCounted = RefCounted.new()
	_active[wallet.get_instance_id()] = token
	_independent[wallet.get_instance_id()] = independent
	if amount>0:
		wallet.add_coins(amount,reason)
		Log.debug(&"EconomyService","credit %d reason=%s" % [amount,reason])
	_restore(wallet,previous)
	return true

static func debit(wallet: WalletState, amount: int, reason: StringName, independent: bool = false) -> bool:
	if wallet==null or reason.is_empty() or amount<0 or amount>MAX_AMOUNT or not _can_enter(wallet,independent) or not wallet.can_afford(amount): return false
	var previous: RefCounted = _active.get(wallet.get_instance_id())
	var token: RefCounted = RefCounted.new()
	_active[wallet.get_instance_id()] = token
	_independent[wallet.get_instance_id()] = independent
	var paid: bool = wallet.remove_coins(amount,reason)
	if paid: Log.debug(&"EconomyService","debit %d reason=%s" % [amount,reason])
	_restore(wallet,previous)
	return paid

static func buy(wallet: WalletState, inventory: InventoryState, id: StringName, quantity: int, unit_price: int, reason: StringName, refund_reason: StringName = &"refund") -> Dictionary:
	var price: int = total(unit_price,quantity)
	if wallet==null or inventory==null or id.is_empty() or reason.is_empty() or refund_reason.is_empty() or price<0: return _failure(&"invalid_trade")
	if is_busy(wallet) or InventoryService.is_busy(inventory): return _failure(&"trade_busy")
	if not wallet.can_afford(price): return _failure(&"insufficient_coins")
	if not inventory.can_add_item(id,quantity): return _failure(&"inventory_full")
	var token: RefCounted = _begin(wallet,inventory)
	if token==null: return _failure(&"trade_busy")
	var result: Dictionary = _failure(&"debit_rejected")
	if wallet.remove_coins(price,reason):
		Log.debug(&"EconomyService","debit %d reason=%s" % [price,reason])
		var added: int = InventoryService.add_reserved(inventory,token,id,quantity,reason)
		if added==quantity:
			result = {"ok":true,"reason":&"purchased","quantity":quantity,"total":price}
		elif added>=0 and added<quantity and (added==0 or InventoryService.remove_reserved(inventory,token,id,added,refund_reason)):
			# Undo only our transfer, preserving independent callback mutations.
			if can_credit(wallet,price):
				wallet.add_coins(price,refund_reason)
				Log.debug(&"EconomyService","credit %d reason=%s" % [price,refund_reason])
				result = _failure(&"transfer_rejected")
			else: result = _failure(&"settlement_failed")
		else:
			# Unknown transfer counts cannot justify a free refund or success notice.
			result = _failure(&"settlement_failed")
	_end(wallet,inventory,token)
	return result

static func sell(wallet: WalletState, inventory: InventoryState, id: StringName, quantity: int, unit_price: int, reason: StringName) -> Dictionary:
	var price: int = total(unit_price,quantity)
	if wallet==null or inventory==null or id.is_empty() or reason.is_empty() or price<0: return _failure(&"invalid_trade")
	if is_busy(wallet) or InventoryService.is_busy(inventory): return _failure(&"trade_busy")
	if not can_credit(wallet,price): return _failure(&"invalid_total")
	if not inventory.has_item(id,quantity): return _failure(&"missing_items")
	var token: RefCounted = _begin(wallet,inventory)
	if token==null: return _failure(&"trade_busy")
	var result: Dictionary = _failure(&"debit_rejected")
	if InventoryService.remove_reserved(inventory,token,id,quantity,reason):
		if can_credit(wallet,price):
			wallet.add_coins(price,reason)
			Log.debug(&"EconomyService","credit %d reason=%s" % [price,reason])
			result = {"ok":true,"reason":&"sold","quantity":quantity,"total":price}
		else:
			var restored: int = InventoryService.add_reserved(inventory,token,id,quantity,StringName(String(reason)+"_rollback"))
			result = _failure(&"credit_rejected" if restored==quantity else &"settlement_failed")
	_end(wallet,inventory,token)
	return result

static func _begin(wallet: WalletState, inventory: InventoryState) -> RefCounted:
	var token: RefCounted = RefCounted.new()
	if is_busy(wallet) or not InventoryService.begin_transfer(inventory,token): return null
	_active[wallet.get_instance_id()] = token
	_independent[wallet.get_instance_id()] = false
	return token

static func _end(wallet: WalletState, inventory: InventoryState, token: RefCounted) -> void:
	if _active.get(wallet.get_instance_id())==token:
		_active.erase(wallet.get_instance_id())
		_independent.erase(wallet.get_instance_id())
	InventoryService.finish_transfer(inventory,token)

static func _can_enter(wallet: WalletState, independent: bool) -> bool:
	return wallet!=null and (not is_busy(wallet) or (independent and _independent.get(wallet.get_instance_id(),false)))

static func _restore(wallet: WalletState, previous: RefCounted) -> void:
	if previous==null:
		_active.erase(wallet.get_instance_id())
		_independent.erase(wallet.get_instance_id())
	else:
		# A nested scope is permitted only when both primitive scopes opted in.
		_active[wallet.get_instance_id()] = previous
		_independent[wallet.get_instance_id()] = true

static func _failure(reason: StringName) -> Dictionary:
	return {"ok":false,"reason":reason,"quantity":0,"total":0}
