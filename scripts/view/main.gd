## Main — wires shared debug tooling to the active gray-box world.
extends Node3D

@onready var world: GrayBoxWorld = $GrayBoxWorld
@onready var debug_menu: DebugMenu = $DebugMenu
@onready var inventory_panel: InventoryPanel = $InventoryPanel
@onready var hud_button_bar = $HudButtonBar
@onready var hotbar_panel = $HotbarPanel
@onready var farm_view: Node3D = $GrayBoxWorld/FarmView
@onready var tool_controller: Node = $ToolActionController
@onready var tutorial_panel: Node = $TutorialPanel
@onready var quest_panel: Node = $QuestPanel
@onready var pause_menu: PanelContainer = $PauseMenu
@onready var start_menu: PanelContainer = $StartMenu
@onready var toast: Label = $Toast
@onready var feedback: Label = $FeedbackPopup
@onready var audio_service: Node = $AudioService
var inventory
var farm_state: FarmGridState
var day_simulator: Object
var quest_state: Variant
var profile: Dictionary = {}

func _ready() -> void:
	Localization.load_translations()
	if is_instance_valid(debug_menu):
		debug_menu.configure(world.player)
	inventory = preload("res://scripts/domain/inventory_state.gd").new()
	farm_state = preload("res://scripts/domain/farm_grid_state.gd").new()
	day_simulator = preload("res://scripts/domain/day_simulator.gd").new()
	quest_state = preload("res://scripts/domain/tutorial_quest_state.gd").new()
	inventory_panel.configure(inventory, world.player)
	tutorial_panel.call("configure", world.player)
	tutorial_panel.call(
		"configure_modal",
		Callable(inventory_panel, &"close_inventory"),
		Callable(quest_panel, &"set_help_suppressed")
	)
	quest_panel.call("configure", quest_state)
	hotbar_panel.configure(inventory)
	if get_tree().current_scene == self and SaveService.load_game().is_empty():
		inventory.add_item(&"turnip_seed", 10)
	farm_view.call("configure", farm_state)
	feedback.configure(inventory)
	tool_controller.configure(world, farm_state, inventory, farm_view, world.player, inventory_panel, debug_menu, feedback, audio_service)
	hotbar_panel.register_tool(&"hoe", tr("UI_TOOL_HOE"), func() -> void: tool_controller.select_tool(&"hoe"))
	hotbar_panel.register_tool(&"watering_can", tr("UI_TOOL_WATER"), func() -> void: tool_controller.select_tool(&"watering_can"))
	hotbar_panel.register_tool(&"seed", tr("UI_TOOL_SEED"), tool_controller.select_seed)
	hotbar_panel.register_tool(&"harvest", tr("UI_TOOL_HARVEST"), func() -> void: tool_controller.select_tool(&"harvest"))
	debug_menu.configure_inventory(inventory)
	debug_menu.configure_farm(farm_state, farm_view)
	debug_menu.configure_save_load(_save_game, _load_game)
	pause_menu.configure(_save_game, _load_game, _return_to_start_menu)
	start_menu.configure(_start_new_game, _continue_game, func() -> void: get_tree().quit())
	start_menu.visible = not SaveService.has_save()
	world.player.movement_enabled = not start_menu.visible
	if not GameClock.day_started.is_connected(_on_day_started):
		GameClock.day_started.connect(_on_day_started)
	var _inventory_button: Button = hud_button_bar.register_button(
		&"inventory",
		tr("UI_INV_BUTTON"),
		inventory_panel.toggle_inventory,
		func() -> bool: return not GameClock.is_sleeping() and not bool(tutorial_panel.call("is_help_open"))
	)
	_inventory_button.tooltip_text = tr("UI_INV_BUTTON_TOOLTIP")
	var help_button: Button = hud_button_bar.register_button(
		&"help",
		tr("UI_HELP_BUTTON"),
		Callable(tutorial_panel, &"open_help"),
		func() -> bool: return not GameClock.is_sleeping()
	)
	help_button.tooltip_text = tr("UI_HELP_BUTTON_TOOLTIP")
	inventory_panel.inventory_toggled.connect(func(is_open: bool) -> void:
		hud_button_bar.set_button_active(&"inventory", is_open)
	)
	hud_button_bar.set_button_active(&"inventory", inventory_panel.visible)

func _on_day_started(_day_index: int) -> void:
	day_simulator.call("simulate_day", farm_state)
	_save_game_to_slot(0)
	_show_toast(tr("UI_SAVED"))

func _save_game() -> void:
	_save_game_to_slot(1)
	_show_toast(tr("UI_SAVED"))

func _save_game_to_slot(slot: int) -> void:
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
		"farm": farm_state.serialize(),
		"quests": quest_state.serialize(),
		"profile": profile
	}
	SaveService.save_game(payload, slot)

func _load_game() -> void:
	_load_game_from_slot(1)

func _load_game_from_slot(slot: int) -> void:
	var payload: Dictionary = SaveService.load_game(slot)
	if payload.is_empty():
		return
	GameClock.deserialize(payload.get("clock", {}))
	inventory.deserialize(payload.get("inventory", {}))
	farm_state.deserialize(payload.get("farm", {}))
	quest_state.deserialize(payload.get("quests", {}))
	profile = payload.get("profile", {})
	var player_data: Dictionary = payload.get("player", {})
	var position_data: Dictionary = player_data.get("position", {})
	if not position_data.is_empty():
		world.player.global_position = Vector3(
			float(position_data.get("x", world.player.global_position.x)),
			float(position_data.get("y", world.player.global_position.y)),
			float(position_data.get("z", world.player.global_position.z))
		)

func _start_new_game(player_name: String, farm_name: String) -> void:
	profile = {"player_name": player_name, "farm_name": farm_name}
	world.player.movement_enabled = true
	start_menu.visible = false
	_save_game_to_slot(1)

func _continue_game() -> void:
	_load_game_from_slot(1)
	start_menu.visible = false
	world.player.movement_enabled = true

func _return_to_start_menu() -> void:
	pause_menu.close()
	start_menu.visible = true
	world.player.movement_enabled = false

func _show_toast(message: String) -> void:
	toast.text = message
	toast.visible = true
	var timer: SceneTreeTimer = get_tree().create_timer(1.5)
	timer.timeout.connect(func() -> void: toast.visible = false)
