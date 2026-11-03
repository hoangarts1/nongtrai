## LifeInventoryGrid — eight columns, original indices retained through filtering.
class_name LifeInventoryGrid
extends ScrollContainer

signal slot_requested(index: int)
var grid: GridContainer
var buttons: Array[LifeInventorySlot] = []
var visible_indices: Array[int] = []

func _ready() -> void:
	LifeTheme.bind(self)
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid = GridContainer.new()
	grid.columns = InventoryState.CONFIG.columns
	grid.theme_type_variation = &"LifeInvGrid"
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(grid)

func display(slots: Array[Dictionary], capacity: int, category: StringName, selected: int) -> void:
	for child: Node in grid.get_children():
		grid.remove_child(child)
		child.free()
	buttons.clear()
	visible_indices.clear()
	for index: int in range(slots.size()):
		var item: ItemData = DataRegistry.get_item(slots[index]["item_id"]) as ItemData
		if category.is_empty() or item.category==category:
			visible_indices.append(index)
	for position: int in range(capacity):
		var index: int = visible_indices[position] if position < visible_indices.size() else -1
		var button: LifeInventorySlot = preload("res://ui/inventory/inventory_slot.tscn").instantiate() as LifeInventorySlot
		button.name = "InventorySlot_%d" % position
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(button)
		var texture: Texture2D
		var count: int = 0
		var title: String = tr("UI_HOTBAR_EMPTY")
		if index >= 0:
			var item: ItemData = DataRegistry.get_item(slots[index]["item_id"]) as ItemData
			texture = LifeInventoryIcon.for_item(item.item_id)
			count = int(slots[index]["quantity"])
			title = tr(String(item.display_name_key))
		button.display(index,texture,count,title,index>=0 and index==selected)
		button.pressed.connect(func() -> void: slot_requested.emit(index))
		buttons.append(button)
