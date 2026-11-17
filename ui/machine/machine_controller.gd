## LifeMachineController — transient selection, deferred display and existing commands.
class_name LifeMachineController
extends Node

var panel: MachineShopPanel
var main: Node
var selected: StringName = &""
var recipe_id: StringName = &""
var operation_mode: bool = false
var cell: Vector2i = Vector2i.ZERO
var result: Dictionary = {}
var model: Dictionary = {}
var shop: MachineShopService
var _queued: bool = false
var _busy: bool = false

func configure(view: MachineShopPanel, owner: Node) -> void:
	panel = view
	main = owner
	shop = MachineShopService.new()
	shop.configure(preload("res://data/machine_shop.tres"),main.machine_inventory,main.wallet)
	panel.screen.selected.connect(select)
	panel.screen.requested.connect(request)
	main.inventory.inventory_changed.connect(_inventory_changed)
	main.wallet.coins_changed.connect(_coins_changed)

func open(operation: bool = false, target: Vector2i = Vector2i.ZERO) -> void:
	operation_mode = operation
	cell = target
	recipe_id = &""
	result = {}
	queue_refresh()

func reset() -> void:
	selected = &""
	recipe_id = &""
	operation_mode = false
	cell = Vector2i.ZERO
	result = {}
	model = {}

func select(key: StringName) -> void:
	if not panel.visible or _busy:
		return
	for row: Dictionary in model.get("rows",[]):
		if row.key!=key:
			continue
		if row.kind==&"placement":
			panel.open_machine(row.cell)
			return
		if row.kind==&"recipe":
			recipe_id = StringName(row.id)
		else:
			selected = StringName(row.id)
		result = {}
		queue_refresh()
		return

func request(action: StringName) -> void:
	if _busy or not panel.visible or GameClock.is_sleeping() or main.ui_coordinator.get_active_panel()!=panel:
		return
	if action==&"land" and not operation_mode:
		main.land_runtime.call_deferred("open")
		return
	if action==&"catalog":
		panel.open()
		return
	if (operation_mode and action not in [&"start",&"collect",&"return",&"move"]) or (not operation_mode and action not in [&"buy",&"place"]):
		return
	if model.is_empty() or not bool(model.get("valid",false)) or StringName(model.id)!=selected or bool(model.operation)!=operation_mode:
		return
	if operation_mode and (StringName(model.recipe.id)!=recipe_id or main.machine_placements.get_placement(cell).get("machine_id",&"")!=selected):
		result = {"ok":false,"reason":&"invalid_state"}
		queue_refresh()
		return
	if action==&"place":
		main.machine_placement_flow.call_deferred("begin",selected)
		return
	if action==&"move":
		var ready: Dictionary = main.machine_placement_request.can_begin_move(cell,main.world.player.get_cell())
		if bool(ready.ok):
			main.machine_placement_flow.call_deferred("begin_move",cell)
		else:
			result = ready
			queue_refresh()
		return
	_busy = true
	match action:
		&"buy":
			if not operation_mode:
				result = shop.purchase(selected,1)
		&"return":
			result = main.machine_placement_request.return_to_storage(cell,main.world.player.get_cell())
			if bool(result.ok):
				operation_mode = false
				recipe_id = &""
		&"start":
			if operation_mode:
				# A disabled Start must not create an empty low-level job on failure.
				var current: Dictionary = LifeMachineSnapshot.capture(main,selected,recipe_id,true,cell)
				var reason: StringName = StringName(current.recipe.reason)
				result = main.machine_operations.start(cell,recipe_id,1) if reason.is_empty() else {"ok":false,"reason":reason}
		&"collect":
			if operation_mode:
				result = main.machine_operations.collect_output_to_inventory(cell)
	if bool(result.get("ok",false)) and action in [&"return",&"start",&"collect"]:
		main.machine_presentation.refresh()
		main.call("_mark_save_dirty")
	_busy = false
	queue_refresh()

func queue_refresh() -> void:
	if not _queued:
		_queued = true
		call_deferred("_refresh")

func _refresh() -> void:
	_queued = false
	if not panel.visible:
		return
	var next: Dictionary = LifeMachineSnapshot.capture(main,selected,recipe_id,operation_mode,cell)
	if not bool(next.valid):
		panel.close()
		return
	var focus: Control = panel.get_viewport().gui_get_focus_owner()
	var action: String = String(focus.get_meta(&"machine_action","")) if focus!=null and panel.is_ancestor_of(focus) else ""
	selected = StringName(next.id)
	recipe_id = StringName(next.recipe.id)
	model = next
	panel.screen.display(model,result)
	if not action.is_empty():
		for node: Node in panel.find_children("*","Button",true,false):
			var button: Button = node as Button
			if String(button.get_meta(&"machine_action",""))==action and button.visible and not button.disabled:
				button.call_deferred("grab_focus")
				return
	panel.screen.close_button.call_deferred("grab_focus")

func _inventory_changed(_slots: Array[Dictionary]) -> void:
	if not _busy and not result.is_empty() and not bool(result.ok):
		result = {}
	queue_refresh()

func _coins_changed(_total: int, _delta: int, reason: StringName) -> void:
	if reason==&"load":
		panel.close()
		return
	if not _busy and not result.is_empty() and not bool(result.ok):
		result = {}
	queue_refresh()
