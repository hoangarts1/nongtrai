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
@onready var weather_hud: Label = $WeatherHud
@onready var weather_fx: Node3D = $GrayBoxWorld/WeatherFx
@onready var wallet_hud: Label = $WalletHud
@onready var shipping_bin_panel = $ShippingBinPanel
@onready var seed_shop_panel = $SeedShopPanel
@onready var npc_system: NpcSystem = $NpcSystem
var inventory
var farm_state: FarmGridState
var day_simulator: Object
var quest_state: Variant
var wallet: WalletState
var profile: Dictionary = {}
var _game_started: bool = false
var _real_seconds_since_save: float = 0.0
var _seconds_since_dirty_save: float = 0.0
var _save_dirty: bool = false
var weather_state: Object
var ui_coordinator: UiCoordinator
var _initial_wallet: Dictionary
var _spawn_position: Vector3

func _process(delta: float) -> void:
	if not _game_started:
		return
	_real_seconds_since_save += delta
	_seconds_since_dirty_save += delta
	if _real_seconds_since_save >= 60.0:
		_save_game_to_slot(1)
		_real_seconds_since_save = 0.0
		_save_dirty = false
	elif _save_dirty and _seconds_since_dirty_save >= 5.0:
		_save_game_to_slot(1)
		_save_dirty = false
		_seconds_since_dirty_save = 0.0

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_before_exit()
		get_tree().quit()

func _save_before_exit() -> void:
	if _game_started:
		npc_system.close_panels()
		_save_game_to_slot(1)

func _ready() -> void:
	Localization.load_translations()
	if is_instance_valid(debug_menu):
		debug_menu.configure(world.player)
	inventory = preload("res://scripts/domain/inventory_state.gd").new()
	farm_state = preload("res://scripts/domain/farm_grid_state.gd").new()
	day_simulator = preload("res://scripts/domain/day_simulator.gd").new()
	quest_state = preload("res://scripts/domain/tutorial_quest_state.gd").new()
	weather_state = preload("res://scripts/domain/weather_state.gd").new()
	weather_state.call("configure", preload("res://data/weather_profile.tres"), 0)
	wallet = preload("res://scripts/domain/economy/wallet_state.gd").new(100)
	_initial_wallet = wallet.serialize()
	_spawn_position = world.player.position
	wallet_hud.configure(wallet)
	weather_hud.configure(weather_state)
	weather_fx.configure(weather_state)
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
		var starter_seed: StringName = DataRegistry.get_starter_seed_for_season(GameClock.season)
		inventory.add_item(starter_seed, 10)
	farm_view.call("configure", farm_state)
	feedback.configure(inventory)
	shipping_bin_panel.configure(inventory, wallet, world.player, feedback)
	world.shipping_bin_interacted.connect(shipping_bin_panel.open)
	seed_shop_panel.configure(inventory, wallet, world.player, feedback)
	world.seed_shop_interacted.connect(seed_shop_panel.open)
	tool_controller.configure(world, farm_state, inventory, farm_view, world.player, inventory_panel, debug_menu, feedback, audio_service, hotbar_panel, shipping_bin_panel, seed_shop_panel)
	hotbar_panel.register_tool(&"hoe", tr("UI_TOOL_HOE"), func() -> void: tool_controller.select_tool(&"hoe"))
	hotbar_panel.register_tool(&"watering_can", tr("UI_TOOL_WATER"), func() -> void: tool_controller.select_tool(&"watering_can"))
	hotbar_panel.register_tool(&"seed", tr("UI_TOOL_SEED"), tool_controller.select_seed)
	hotbar_panel.register_tool(&"harvest", tr("UI_TOOL_HARVEST"), func() -> void: tool_controller.select_tool(&"harvest"))
	debug_menu.configure_inventory(inventory)
	debug_menu.configure_wallet(wallet)
	debug_menu.configure_farm(farm_state, farm_view)
	debug_menu.configure_save_load(_save_game, _load_game)
	debug_menu.configure_weather(weather_state)
	pause_menu.configure(_save_game, _load_game, _return_to_start_menu)
	start_menu.configure(_start_new_game, _continue_game, _quit_game)
	npc_system.configure(self, $DialoguePanel, $NpcJournal)
	start_menu.visible = true
	world.player.movement_enabled = not start_menu.visible
	_game_started = false
	farm_state.plot_changed.connect(_mark_save_dirty)
	inventory.inventory_changed.connect(_mark_save_dirty)
	wallet.coins_changed.connect(_mark_save_dirty)
	if not GameClock.day_started.is_connected(_on_day_started):
		GameClock.day_started.connect(_on_day_started)
	if not GameClock.season_changed.is_connected(_on_season_changed):
		GameClock.season_changed.connect(_on_season_changed)
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
	hud_button_bar.register_button(&"journal", tr("UI_NPC_JOURNAL"), npc_system.open_journal)
	hud_button_bar.register_button(&"pause", tr("UI_PAUSE_TITLE"), pause_menu.open)
	inventory_panel.inventory_toggled.connect(func(is_open: bool) -> void:
		hud_button_bar.set_button_active(&"inventory", is_open)
	)
	hud_button_bar.set_button_active(&"inventory", inventory_panel.visible)
	ui_coordinator = UiCoordinator.new()
	add_child(ui_coordinator)
	ui_coordinator.configure(self)
	var title_backdrop: TitleBackdrop = TitleBackdrop.new()
	title_backdrop.menu = start_menu
	add_child(title_backdrop)
	move_child(title_backdrop, 1)
	var presentation: WorldPresentation = WorldPresentation.new()
	add_child(presentation)
	presentation.configure(self)

func _on_day_started(_day_index: int) -> void:
	weather_state.call("advance_day", GameClock.day_index)
	farm_state.mark_out_of_season()
	if bool(weather_state.call("is_rainy")):
		farm_state.water_all_crops()
	day_simulator.call("simulate_day", farm_state)
	_save_game_to_slot(0)
	_show_toast(tr("UI_SAVED"))

func _on_season_changed(season: StringName) -> void:
	_show_toast(tr("UI_SEASON_CHANGED") % tr(String(DataRegistry.get_season(season).get("display_name_key"))))

func _save_game() -> void:
	_save_game_to_slot(1)
	_show_toast(tr("UI_SAVED"))

func _save_game_to_slot(slot: int) -> void:
	if npc_system.is_open():
		return
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
		"profile": profile,
		"weather": weather_state.call("serialize"),
		"wallet": wallet.serialize(),
		"social": npc_system.state.serialize()
	}
	if not SaveService.save_game(payload, slot):
		push_warning("Main: could not save slot %d" % slot)

func _load_game() -> void:
	_load_game_from_slot(1)

func _load_game_from_slot(slot: int) -> void:
	var payload: Dictionary = SaveService.load_game(slot)
	if payload.is_empty():
		return
	_load_payload(payload)

func _quit_game() -> void:
	_save_before_exit()
	get_tree().quit()

func _start_new_game(player_name: String, farm_name: String) -> void:
	_game_started = false
	GameClock.deserialize({})
	inventory.clear()
	farm_state.reset()
	quest_state.deserialize({})
	wallet.deserialize(_initial_wallet)
	var fresh_weather: WeatherState = WeatherState.new()
	fresh_weather.configure(preload("res://data/weather_profile.tres"), 0)
	weather_state.call("deserialize", fresh_weather.serialize())
	world.player.position = _spawn_position
	npc_system.restore({})
	profile = {"player_name": player_name, "farm_name": farm_name}
	_game_started = true
	world.player.movement_enabled = true
	start_menu.visible = false
	if inventory.get_slots().is_empty():
		var starter_seed: StringName = DataRegistry.get_starter_seed_for_season(GameClock.season)
		inventory.add_item(starter_seed, 10)
	_save_game_to_slot(1)
	if not Settings.is_tutorial_dismissed():
		tutorial_panel.open_help()

func _continue_game() -> void:
	var latest: Dictionary = SaveService.load_latest()
	if latest.is_empty():
		return
	_load_payload(latest)
	start_menu.visible = false
	world.player.movement_enabled = true

func _return_to_start_menu() -> void:
	if _game_started:
		_save_game_to_slot(1)
	pause_menu.close()
	start_menu.refresh_continue()
	start_menu.visible = true
	world.player.movement_enabled = false

func _load_payload(payload: Dictionary) -> void:
	GameClock.deserialize(payload.get("clock", {}))
	inventory.deserialize(payload.get("inventory", {}))
	farm_state.deserialize(payload.get("farm", {}))
	quest_state.deserialize(payload.get("quests", {}))
	weather_state.call("deserialize", payload.get("weather", {}))
	wallet.deserialize(payload.get("wallet", {}))
	var social_data: Variant = payload.get("social", {})
	npc_system.restore(social_data if social_data is Dictionary else {})
	wallet_hud.configure(wallet)
	weather_hud.configure(weather_state)
	profile = payload.get("profile", {})
	_game_started = true
	var player_data: Dictionary = payload.get("player", {})
	var position_data: Dictionary = player_data.get("position", {})
	if not position_data.is_empty():
		world.player.global_position = Vector3(
			float(position_data.get("x", world.player.global_position.x)),
			float(position_data.get("y", world.player.global_position.y)),
			float(position_data.get("z", world.player.global_position.z))
		)

func _mark_save_dirty(_value: Variant = null, _delta: Variant = null, _reason: Variant = null) -> void:
	if _game_started:
		_save_dirty = true
		_seconds_since_dirty_save = 0.0

func _show_toast(message: String) -> void:
	toast.text = message
	toast.visible = true
	var timer: SceneTreeTimer = get_tree().create_timer(1.5)
	timer.timeout.connect(func() -> void: toast.visible = false)
