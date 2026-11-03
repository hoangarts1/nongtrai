## LifeInventoryController — transient selection and requests to the inventory owner.
class_name LifeInventoryController
extends Node

var panel: InventoryPanel
var inventory: InventoryState
var selected: int = -1
var category: StringName = &""
var _main: Node
var _queued: bool = false
var _pending: Dictionary = {}

func configure(owner_panel: InventoryPanel, state: InventoryState) -> void:
	panel = owner_panel
	inventory = state
	inventory.inventory_changed.connect(_changed)
	panel.screen.items.slot_requested.connect(select)
	panel.screen.filters.filter_requested.connect(filter)
	panel.screen.detail.quick_selected.connect(quick_select)
	panel.screen.detail.discard_requested.connect(request_discard)
	panel.screen.discard.confirmed.connect(confirm_discard)
	panel.screen.discard.cancelled.connect(cancel_discard)
	panel.screen.footer.sort_requested.connect(sort_items)
	panel.screen.tabs.tab_requested.connect(show_tab)
	queue_render()

func attach_main(main: Node) -> void:
	_main = main
	main.npc_system.journal.enable_quest_book(main)
	main.npc_system.journal.tabs.tab_requested.connect(show_tab)
	main.character_flow.panel.tabs.tab_requested.connect(show_tab)

func queue_render() -> void:
	if not _queued:
		_queued = true
		call_deferred("_render")

func _changed(_slots: Array[Dictionary]) -> void:
	cancel_discard()
	queue_render()

func _render() -> void:
	_queued = false
	if inventory == null:
		return
	var slots: Array[Dictionary] = inventory.get_slots()
	if selected < 0 or selected >= slots.size() or not _matches(slots[selected]):
		selected = -1
		for index: int in range(slots.size()):
			if _matches(slots[index]):
				selected = index
				break
	panel.screen.filters.set_active(category)
	panel.screen.items.display(slots,inventory.capacity,category,selected)
	panel.screen.detail.display(slots[selected] if selected>=0 else {})
	panel.screen.footer.display(slots.size(),inventory.capacity,selected<0 and not category.is_empty())

func _matches(slot: Dictionary) -> bool:
	return category.is_empty() or (DataRegistry.get_item(slot["item_id"]) as ItemData).category==category

func select(index: int) -> void:
	if index>=0 and index<inventory.get_slots().size():
		selected = index
		cancel_discard()
		queue_render()

func filter(value: StringName) -> void:
	if value not in LifeInventoryFilters.CATEGORIES:
		return
	category = value
	cancel_discard()
	queue_render()

func _can_act() -> bool:
	return panel.visible and not GameClock.is_sleeping() and (_main==null or _main.ui_coordinator.get_active_panel()==panel)

func quick_select() -> void:
	if _can_act() and _pending.is_empty():
		panel._select_slot(selected)

func sort_items() -> void:
	if not _can_act() or not _pending.is_empty():
		return
	var old_hotbar: int = _main.hotbar_panel.selected_index() if _main!=null else -1
	var old_tool: StringName = _main.hotbar_panel.active_tool() if _main!=null else &""
	var order: Array[int] = InventoryActions.sort(inventory)
	selected = order.find(selected)
	if _main!=null:
		_main.hotbar_panel.remap_selection(order,old_hotbar,old_tool)
	queue_render()

func request_discard() -> void:
	if not _can_act():
		return
	var slots: Array[Dictionary] = inventory.get_slots()
	if selected<0 or selected>=slots.size():
		return
	var slot: Dictionary = slots[selected]
	_pending = {"index":selected,"item_id":slot["item_id"],"quantity":slot["quantity"],"revision":inventory.revision}
	panel.screen.detail.hide()
	var item: ItemData = DataRegistry.get_item(slot["item_id"]) as ItemData
	panel.screen.discard.display(tr(String(item.display_name_key)),int(slot["quantity"]))

func confirm_discard(quantity: int) -> void:
	if not _can_act() or _pending.is_empty():
		return
	var request: Dictionary = _pending.duplicate()
	var old_hotbar: int = _main.hotbar_panel.selected_index() if _main!=null else -1
	var old_size: int = inventory.get_slots().size()
	var old_tool: StringName = _main.hotbar_panel.active_tool() if _main!=null else &""
	var success: bool = InventoryActions.discard(inventory,int(request["index"]),request["item_id"],int(request["quantity"]),int(request["revision"]),quantity)
	if success and quantity==int(request["quantity"]) and _main!=null:
		var order: Array[int] = []
		for index: int in range(old_size):
			if index!=int(request["index"]):
				order.append(index)
		_main.hotbar_panel.remap_selection(order,old_hotbar,old_tool)
	cancel_discard()
	queue_render()

func cancel_discard() -> void:
	_pending.clear()
	panel.screen.discard.hide()
	panel.screen.detail.show()

func show_tab(index: int) -> void:
	if _main==null:
		return
	var panels: Array[Control] = [panel,_main.character_flow.panel,_main.npc_system.journal]
	var active: Control = _main.ui_coordinator.get_active_panel()
	if index<0 or index>=panels.size() or active not in panels:
		return
	if active==panels[index]:
		return
	_main.ui_coordinator.close_active()
	if index==0:
		panel.toggle_inventory()
	elif index==1:
		_main.character_flow.open()
	else:
		_main.npc_system.open_journal()

func handle_input(event: InputEvent) -> bool:
	if _main==null or event.is_echo():
		return false
	var panels: Array[Control] = [panel,_main.character_flow.panel,_main.npc_system.journal]
	var active: int = panels.find(_main.ui_coordinator.get_active_panel())
	if active<0:
		return false
	if event.is_action_pressed("inventory_tab_prev") or event.is_action_pressed("inventory_tab_next"):
		show_tab(posmod(active+(-1 if event.is_action_pressed("inventory_tab_prev") else 1),panels.size()))
		return true
	if panel.visible:
		if event.is_action_pressed("cancel") or event.is_action_pressed("pause"):
			if not _pending.is_empty():
				cancel_discard()
				return true
		if event.is_action_pressed("inventory_quick_select"):
			quick_select()
			return true
		if event.is_action_pressed("inventory_sort"):
			sort_items()
			return true
	return false
