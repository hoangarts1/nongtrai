## MachineShopPanel — compatible modal adapter for modular machine presentation.
class_name MachineShopPanel
extends PanelContainer

var screen: LifeMachineScreen
var controller: LifeMachineController
# Retained inspection adapters used by the existing integration contract.
var _shop: MachineShopService:
	get: return controller.shop
var _operation: MachineOperationService
var _status: Label:
	get: return screen.footer.result
var _close_button: Button:
	get: return screen.close_button
var _machine_cell: Vector2i:
	get: return controller.cell
var _machine_mode: bool:
	get: return controller.operation_mode

func _ready() -> void:
	hide()
	LifeTheme.bind(self,&"LifeHudClearPanel")
	screen = preload("res://ui/machine/machine_screen.tscn").instantiate() as LifeMachineScreen
	add_child(screen)
	screen.closed.connect(close)
	controller = LifeMachineController.new()
	add_child(controller)

func configure(main: Node) -> void:
	_operation = main.machine_operations
	controller.configure(self,main)

func open() -> void:
	if GameClock.is_sleeping():
		return
	controller.open()
	show()

func open_machine(cell: Vector2i) -> void:
	if GameClock.is_sleeping():
		return
	controller.open(true,cell)
	show()

func close() -> void:
	hide()
	if controller!=null:
		controller.reset()

func _collect(cell: Vector2i) -> void:
	if cell==controller.cell:
		controller.request(&"collect")

func _notification(what: int) -> void:
	if what==NOTIFICATION_TRANSLATION_CHANGED and controller!=null:
		controller.queue_refresh()
