## Main — wires shared debug tooling to the active gray-box world.
extends Node3D

@onready var world: GrayBoxWorld = $GrayBoxWorld
@onready var debug_menu: DebugMenu = $DebugMenu
@onready var inventory_panel: InventoryPanel = $InventoryPanel
@onready var hud_button_bar = $HudButtonBar
@onready var hotbar_panel = $HotbarPanel
@onready var farm_view: Node3D = $GrayBoxWorld/FarmView
@onready var tool_controller: Node = $ToolActionController
var inventory
var farm_state: FarmGridState
var day_simulator: Object

func _ready() -> void:
	Localization.load_translations()
	if is_instance_valid(debug_menu):
		debug_menu.configure(world.player)
	inventory = preload("res://scripts/domain/inventory_state.gd").new()
	farm_state = preload("res://scripts/domain/farm_grid_state.gd").new()
	day_simulator = preload("res://scripts/domain/day_simulator.gd").new()
	inventory_panel.configure(inventory, world.player)
	hotbar_panel.configure(inventory)
	farm_view.call("configure", farm_state)
	tool_controller.configure(world, farm_state, inventory, farm_view, world.player, inventory_panel, debug_menu)
	hotbar_panel.register_tool(&"hoe", tr("UI_TOOL_HOE"), func() -> void: tool_controller.select_tool(&"hoe"))
	hotbar_panel.register_tool(&"watering_can", tr("UI_TOOL_WATER"), func() -> void: tool_controller.select_tool(&"watering_can"))
	hotbar_panel.register_tool(&"seed", tr("UI_TOOL_SEED"), tool_controller.select_seed)
	hotbar_panel.register_tool(&"harvest", tr("UI_TOOL_HARVEST"), func() -> void: tool_controller.select_tool(&"harvest"))
	debug_menu.configure_inventory(inventory)
	debug_menu.configure_farm(farm_state, farm_view)
	debug_menu.configure_save_load(_save_game, _load_game)
	if not GameClock.day_started.is_connected(_on_day_started):
		GameClock.day_started.connect(_on_day_started)
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

func _on_day_started(_day_index: int) -> void:
	day_simulator.call("simulate_day", farm_state)

func _save_game() -> void:
	var payload: Dictionary = {
		"clock": GameClock.serialize(),
		"player": {
			"position": {
				"x": world.player.global_position.x,
				"y": world.player.global_position.y,
				"z": world.player.global_position.z
			}
		},
		"inventory": inventory.serialize(),
		"farm": farm_state.serialize()
	}
	SaveService.save_game(payload)

func _load_game() -> void:
	var payload: Dictionary = SaveService.load_game()
	if payload.is_empty():
		return
	GameClock.deserialize(payload.get("clock", {}))
	inventory.deserialize(payload.get("inventory", {}))
	farm_state.deserialize(payload.get("farm", {}))
	var player_data: Dictionary = payload.get("player", {})
	var position_data: Dictionary = player_data.get("position", {})
	if not position_data.is_empty():
		world.player.global_position = Vector3(
			float(position_data.get("x", world.player.global_position.x)),
			float(position_data.get("y", world.player.global_position.y)),
			float(position_data.get("z", world.player.global_position.z))
		)
