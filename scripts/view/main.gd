## Main — wires shared debug tooling to the active gray-box world.
extends CanvasLayer

@onready var world: GrayBoxWorld = $GrayBoxWorld
@onready var debug_menu: DebugMenu = $DebugMenu
@onready var inventory_panel: InventoryPanel = $InventoryPanel
@onready var hud_button_bar: HudButtonBar = $HudButtonBar
@onready var hotbar_panel: HotbarPanel = $HotbarPanel
@onready var farm_view: FarmView = $GrayBoxWorld/WorldCanvas/FarmView
@onready var tool_controller: Node = $ToolActionController
@onready var tutorial_panel: Node = $TutorialPanel
@onready var quest_panel: Node = $QuestPanel
@onready var pause_menu: PanelContainer = $PauseMenu
@onready var start_menu: StartMenu = $StartMenu
@onready var toast: Label = $Toast
@onready var feedback: Label = $FeedbackPopup
@onready var audio_service: Node = $AudioService
@onready var weather_hud: Label = $WeatherHud
@onready var weather_fx: Node2D = $GrayBoxWorld/WorldCanvas/WeatherFx
@onready var wallet_hud: Label = $WalletHud
@onready var shipping_bin_panel: ShippingBinPanel = $ShippingBinPanel
@onready var seed_shop_panel: SeedShopPanel = $SeedShopPanel
@onready var npc_system: NpcSystem = $NpcSystem
const CHARACTER_CATALOG: Resource = preload("res://data/art/characters/chibi_character_catalog.tres")
var inventory: InventoryState
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
var chibi_ui_motion: ChibiUiMotion
var _initial_wallet: Dictionary
var _spawn_position: Vector2
var crop_inspector: CropInspector
var presentation: WorldPresentation
var _pending_appearance: Dictionary = {}

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
	farm_view.setup(world)
	farm_view.configure(farm_state)
	feedback.configure(inventory)
	shipping_bin_panel.configure(inventory, wallet, world.player, feedback)
	world.shipping_bin_interacted.connect(shipping_bin_panel.open)
	seed_shop_panel.configure(inventory, wallet, world.player, feedback)
	world.seed_shop_interacted.connect(seed_shop_panel.open)
	tool_controller.configure(world, farm_state, inventory, farm_view, world.player, inventory_panel, debug_menu, feedback, audio_service, hotbar_panel, shipping_bin_panel, seed_shop_panel)
	crop_inspector = CropInspector.new()
	add_child(crop_inspector)
	crop_inspector.configure(farm_state)
	tool_controller.configure_crop_inspector(crop_inspector)
	inventory_panel.slot_selected.connect(hotbar_panel.select_slot)
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
	if not start_menu.appearance_selected.is_connected(_on_appearance_selected):
		start_menu.appearance_selected.connect(_on_appearance_selected)
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
	chibi_ui_motion = ChibiUiMotion.new()
	add_child(chibi_ui_motion)
	chibi_ui_motion.configure(self)
	presentation = WorldPresentation.new()
	add_child(presentation)
	presentation.configure(self)
	_apply_player_appearance()
	if OS.get_cmdline_user_args().has("--capture-chibi-characters"):
		call_deferred("_capture_chibi_characters")
	elif OS.get_cmdline_user_args().has("--capture-chibi-farming"):
		call_deferred("_capture_chibi_farming")
	elif OS.get_cmdline_user_args().has("--capture-chibi-world"):
		call_deferred("_capture_chibi_world")
	elif OS.get_cmdline_user_args().has("--capture-chibi-ui"):
		call_deferred("_capture_chibi_ui")

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
		"player": {"position": _legacy_player_position()},
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
	_pending_appearance = _normalize_player_appearance(_pending_appearance)
	profile = {"player_name": player_name, "farm_name": farm_name, "appearance": _pending_appearance.duplicate(true)}
	_apply_player_appearance()
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
	var loaded_profile: Variant = payload.get("profile", {})
	profile = loaded_profile.duplicate(true) if loaded_profile is Dictionary else {}
	var saved_appearance: Variant = profile.get("appearance", {})
	_pending_appearance = _normalize_player_appearance(saved_appearance if saved_appearance is Dictionary else {})
	profile["appearance"] = _pending_appearance.duplicate(true)
	_apply_player_appearance()
	_game_started = true
	var raw_player: Variant = payload.get("player", {})
	var player_data: Dictionary = raw_player if raw_player is Dictionary else {}
	var raw_position: Variant = player_data.get("position", {})
	var position_data: Dictionary = raw_position if raw_position is Dictionary else {}
	if not position_data.is_empty():
		# v4 stores legacy XZ coordinates. Resolve a logical cell, never load pixels.
		var legacy: Vector3 = GridMath.cell_to_world(world.CONFIG.spawn_cell)
		var saved_x: Variant = position_data.get("x", legacy.x)
		var saved_z: Variant = position_data.get("z", legacy.z)
		if (saved_x is int or saved_x is float) and is_finite(float(saved_x)):
			legacy.x = float(saved_x)
		if (saved_z is int or saved_z is float) and is_finite(float(saved_z)):
			legacy.z = float(saved_z)
		var cell: Vector2i = GridMath.world_to_cell(legacy)
		cell = cell.clamp(world.CONFIG.player_region.position, world.CONFIG.player_region.end - Vector2i.ONE)
		world.player.move_to_cell(cell)

func _mark_save_dirty(_value: Variant = null, _delta: Variant = null, _reason: Variant = null) -> void:
	if _game_started:
		_save_dirty = true
		_seconds_since_dirty_save = 0.0

func _on_appearance_selected(selection: Dictionary) -> void:
	_pending_appearance = _normalize_player_appearance(selection)

func _apply_player_appearance() -> void:
	if presentation == null:
		return
	var selection: Variant = profile.get("appearance", _pending_appearance)
	var normalized: Dictionary = _normalize_player_appearance(selection if selection is Dictionary else {})
	_pending_appearance = normalized
	presentation.configure_player_appearance(normalized)

func _normalize_player_appearance(selection: Dictionary) -> Dictionary:
	var normalized: Variant = CHARACTER_CATALOG.call("normalize_player_customization", selection)
	return normalized if normalized is Dictionary else {}

func _show_toast(message: String) -> void:
	toast.text = message
	toast.visible = true
	var timer: SceneTreeTimer = get_tree().create_timer(1.5)
	timer.timeout.connect(func() -> void: toast.visible = false)

func _legacy_player_position() -> Dictionary:
	# Keep the existing v4 wire schema; view pixels never enter a save.
	var legacy: Vector3 = GridMath.cell_to_world(world.get_player_cell())
	return {"x": legacy.x, "y": legacy.y, "z": legacy.z}

func _prepare_capture() -> void:
	_game_started = false
	start_menu.hide()
	tutorial_panel.hide()
	npc_system.close_panels()
	GameClock.set_time(11, 0)
	weather_state.call("force_weather", &"sunny")
	GameClock.paused = true
	world.player.movement_enabled = false
	world.interaction_prompt.hide()

func _capture_chibi_characters() -> void:
	_prepare_capture()
	await _capture_frame("res://screenshots/chibi-characters", "chibi_characters_main_scene.png")
	get_tree().quit()

func _capture_chibi_farming() -> void:
	_prepare_capture()
	farm_state.reset()
	var crop_ids: PackedStringArray = PackedStringArray(["turnip", "spring_carrot", "spring_pea", "summer_tomato", "summer_corn", "autumn_wheat", "autumn_pumpkin", "winter_radish", "winter_cabbage"])
	for index: int in range(crop_ids.size()):
		var cell: Vector2i = Vector2i((index % 3) * 2, (index / 3) * 2)
		farm_state.till_cell(cell)
		farm_state.plant_crop(cell, StringName(crop_ids[index]))
	for _day: int in range(4):
		farm_state.water_all_crops()
		farm_state.advance_day()
	await _capture_frame("res://screenshots/chibi-farming", "chibi_farming_main_scene.png")
	get_tree().quit()

func _capture_chibi_world() -> void:
	_prepare_capture()
	await _capture_frame("res://screenshots/chibi-world", "chibi_world_main_scene.png")
	get_tree().quit()

func _capture_chibi_ui() -> void:
	_prepare_capture()
	start_menu.show()
	await _capture_frame("res://screenshots/chibi-ui", "chibi_ui_title.png")
	start_menu.hide()
	await _capture_frame("res://screenshots/chibi-ui", "chibi_ui_hud.png")
	get_tree().quit()

func _capture_frame(directory: String, file_name: String) -> void:
	if DisplayServer.get_name() == "headless":
		printerr("[2d_capture] a graphics renderer is required")
		get_tree().quit(1)
		return
	for _frame: int in range(20):
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory)) != OK:
		printerr("[2d_capture] cannot create capture directory")
		get_tree().quit(1)
		return
	var screenshot: Image = get_viewport().get_texture().get_image()
	if screenshot == null or screenshot.is_empty() or screenshot.save_png("%s/%s" % [directory, file_name]) != OK:
		printerr("[2d_capture] could not save capture")
		get_tree().quit(1)
		return
	print("[2d_capture] wrote %s/%s" % [directory, file_name])

func _save_chibi_ui_capture(file_name: String) -> bool:
	var directory: String = "res://screenshots/chibi-ui"
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory)) != OK:
		return false
	var screenshot: Image = get_viewport().get_texture().get_image()
	return screenshot != null and not screenshot.is_empty() and screenshot.save_png("%s/%s" % [directory,file_name]) == OK
