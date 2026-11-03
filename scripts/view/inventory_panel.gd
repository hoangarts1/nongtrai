## InventoryPanel — compatible modal adapter for the modular inventory screen.
class_name InventoryPanel
extends PanelContainer

signal inventory_toggled(is_open: bool)
signal slot_selected(slot_index: int)
var screen: LifeInventoryScreen
var controller: LifeInventoryController
var _inventory: InventoryState
var _player: Player

func _ready() -> void:
	hide()
	LifeTheme.bind(self,&"LifeHudClearPanel")
	var inset: MarginContainer = MarginContainer.new()
	inset.theme_type_variation = &"LifeInvOuterMargin"
	add_child(inset)
	screen = preload("res://ui/inventory/inventory_screen.tscn").instantiate() as LifeInventoryScreen
	inset.add_child(screen)
	screen.tabs.close_requested.connect(close_inventory)
	controller = LifeInventoryController.new()
	add_child(controller)

func configure(inventory: InventoryState, player: Player) -> void:
	_inventory = inventory
	_player = player
	controller.configure(self,inventory)

func attach_main(main: Node) -> void:
	controller.attach_main(main)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_inventory") and not event.is_echo() and _inventory!=null:
		toggle_inventory()
		get_viewport().set_input_as_handled()

func toggle_inventory() -> bool:
	if _inventory==null or GameClock.is_sleeping():
		return false
	visible = not visible
	_player.movement_enabled = not visible
	controller.cancel_discard()
	controller.queue_render()
	inventory_toggled.emit(visible)
	return true

func close_inventory() -> void:
	if visible:
		toggle_inventory()

func _select_slot(index: int) -> void:
	if _inventory==null or index<0 or index>=_inventory.get_slots().size():
		return
	slot_selected.emit(index)
	close_inventory()

func _notification(what: int) -> void:
	if what==NOTIFICATION_TRANSLATION_CHANGED and controller!=null:
		controller.cancel_discard()
		controller.queue_render()
