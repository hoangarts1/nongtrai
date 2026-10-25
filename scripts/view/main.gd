## Main — wires shared debug tooling to the active gray-box world.
extends Node3D

@onready var world: GrayBoxWorld = $GrayBoxWorld
@onready var debug_menu: DebugMenu = $DebugMenu
@onready var inventory_panel: InventoryPanel = $InventoryPanel
@onready var hud_button_bar = $HudButtonBar
@onready var hotbar_panel = $HotbarPanel
@onready var farm_view: Node3D = $GrayBoxWorld/FarmView
var inventory
var farm_state: FarmGridState

func _ready() -> void:
	Localization.load_translations()
	if is_instance_valid(debug_menu):
		debug_menu.configure(world.player)
	inventory = preload("res://scripts/domain/inventory_state.gd").new()
	farm_state = preload("res://scripts/domain/farm_grid_state.gd").new()
	inventory_panel.configure(inventory, world.player)
	hotbar_panel.configure(inventory)
	farm_view.call("configure", farm_state)
	debug_menu.configure_inventory(inventory)
	var _inventory_button: Button = hud_button_bar.register_button(
		&"inventory",
		tr("UI_INV_BUTTON"),
		inventory_panel.toggle_inventory,
		func() -> bool: return not GameClock.is_sleeping()
	)
	_inventory_button.tooltip_text = tr("UI_INV_BUTTON_TOOLTIP")
	inventory_panel.inventory_toggled.connect(func(is_open: bool) -> void:
		hud_button_bar.set_button_active(&"inventory", is_open)
	)
	hud_button_bar.set_button_active(&"inventory", inventory_panel.visible)
