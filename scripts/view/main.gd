## Main — wires shared debug tooling to the active gray-box world.
## API: get_load_feedback() -> Dictionary returns detached feedback for the latest load request.
extends CanvasLayer

const CHARACTER_CATALOG: Resource = preload("res://data/art/characters/chibi_character_catalog.tres")

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
var machine_shop_panel: Control
@onready var npc_system: NpcSystem = $NpcSystem
var inventory: InventoryState
var machine_inventory: MachineInventory
var machine_placements: MachinePlacementState
var machine_build: MachineBuildService
var machine_placement_request: MachinePlacementRequest
var machine_placement_flow: MachinePlacementFlow
var machine_operations: Object
var machine_presentation: Node
var machine_interaction: Node
var land_ownership: LandOwnershipState
var land_expansion: LandExpansionService
var land_runtime: LandRuntime
var bag_upgrade: InventoryUpgradeService
var bag_upgrade_flow: BagUpgradeFlow
var watering_can: WateringCanState
var watering_upgrade_config: WateringCanConfig = preload("res://data/watering_can_config.tres")
var watering_upgrade: WateringCanUpgradeService
var watering_upgrade_flow: WateringUpgradeFlow
var watering_runtime: WateringRuntime
var chicken_coop: ChickenCoopHoldingState = ChickenCoopHoldingState.new()
var chicken_coop_runtime: ChickenCoopRuntime
var chicken_coop_flow: ChickenCoopFlow
var farm_state: FarmGridState
var story_state: StoryState = StoryState.new()
var story_runtime: LifeStoryRuntime
var dog_state: DogState = DogState.new()
var dog_name_flow: LifeDogNameFlow
var dog_runtime: LifeDogRuntime
var ecology_state: EcologyState = EcologyState.new()
var ecology_runtime: LifeEcologyRuntime
var ecology_effects_flow: LifeEcologyEffectsFlow
var director_activity: DirectorActivityState = DirectorActivityState.new()
var director_state: DirectorState = DirectorState.new()
var director_debug_flow: LifeDirectorDebugFlow
var director_runtime: LifeDirectorRuntime
var director_daily_flow: LifeDirectorDailyFlow
var director_activity_collector: LifeDirectorActivityCollector
var director_effects_flow: LifeDirectorEffectsFlow
var director_npc_bridge: LifeDirectorNpcBridge
var director_water_bridge: LifeDirectorWaterBridge
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
var hud_presenter: LifeHudPresenter
var day_end_flow: LifeDayEndFlow
var morning_flow: LifeMorningFlow
var character_flow: LifeCharacterFlow
var ambient_audio_flow: LifeAmbientAudioFlow
var chibi_ui_motion: ChibiUiMotion
var _initial_wallet: Dictionary
var _spawn_position: Vector2
var crop_inspector: CropInspector
var presentation: WorldPresentation
var _pending_appearance: Dictionary = {}
var _load_feedback: Dictionary = {}

func _process(delta: float) -> void:
	if not _game_started or GameClock.is_sleeping() or (day_end_flow != null and day_end_flow.is_advancing()):
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
		if _purchase_in_progress():
			return
		_save_before_exit()
		get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if MachineShopShortcut.matches(event, OS.is_debug_build()) and machine_shop_panel != null:
		if not _game_started or start_menu.visible or _purchase_in_progress() or GameClock.is_sleeping() or GameClock.is_day_end_held() or day_end_flow.is_advancing():
			get_viewport().set_input_as_handled()
			return
		machine_shop_panel.call("open")
		get_viewport().set_input_as_handled()

func _save_before_exit() -> void:
	if _purchase_in_progress():
		return
	if _game_started:
		npc_system.close_panels()
		_save_game_to_slot(1)

func _ready() -> void:
	Localization.load_translations()
	if is_instance_valid(debug_menu):
		debug_menu.configure(world.player)
	inventory = preload("res://scripts/domain/inventory_state.gd").new()
	machine_inventory = MachineInventory.new()
	machine_placements = MachinePlacementState.new()
	machine_placements.configure(preload("res://data/land_parcels.tres"), machine_inventory)
	machine_build = MachineBuildService.new()
	machine_operations = preload("res://scripts/domain/production/machine_operation_service.gd").new()
	machine_operations.configure(inventory, machine_placements)
	machine_build.configure(machine_placements, machine_operations as MachineOperationService)
	if OS.is_debug_build():
		machine_shop_panel = preload("res://scripts/view/machine_shop_panel.gd").new() as Control
		machine_shop_panel.name = "MachineShopPanel"
		add_child(machine_shop_panel)
	farm_state = preload("res://scripts/domain/farm_grid_state.gd").new()
	watering_can = WateringCanState.new()
	watering_can.configure(preload("res://data/watering_can_config.tres"))
	watering_runtime = WateringRuntime.new()
	add_child(watering_runtime)
	watering_runtime.configure(self)
	watering_runtime.water_changed.connect(_mark_save_dirty)
	land_ownership = LandOwnershipState.new()
	land_ownership.configure(preload("res://data/land_expansion_config.tres"))
	ecology_runtime = LifeEcologyRuntime.new()
	ecology_runtime.configure(ecology_state, GameClock.day_index)
	machine_placement_request = MachinePlacementRequest.new()
	machine_placement_request.configure(machine_build, farm_state, preload("res://data/machine_build_config.tres"), world.CONFIG.map_region, world.CONFIG.interaction_reach, land_ownership)
	day_simulator = preload("res://scripts/domain/day_simulator.gd").new()
	quest_state = preload("res://scripts/domain/tutorial_quest_state.gd").new()
	weather_state = preload("res://scripts/domain/weather_state.gd").new()
	weather_state.call("configure", preload("res://data/weather_profile.tres"), 0, GameClock.day_index)
	wallet = preload("res://scripts/domain/economy/wallet_state.gd").new(100)
	land_expansion = LandExpansionService.new()
	land_expansion.configure(preload("res://data/land_expansion_config.tres"), land_ownership, wallet)
	bag_upgrade = InventoryUpgradeService.new()
	bag_upgrade.configure(preload("res://data/bag_upgrade_config.tres"), inventory, wallet)
	watering_upgrade = WateringCanUpgradeService.new()
	watering_upgrade.configure(watering_upgrade_config, watering_can, wallet)
	_initial_wallet = wallet.serialize()
	_spawn_position = world.player.position
	if machine_shop_panel != null:
		machine_shop_panel.call("configure", self)
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
	if machine_shop_panel != null:
		world.machine_shop_interacted.connect(machine_shop_panel.open)
	machine_interaction = preload("res://scripts/view/machine_interaction_controller.gd").new()
	add_child(machine_interaction)
	machine_interaction.configure(world, machine_placements, machine_shop_panel)
	tool_controller.configure(world, farm_state, inventory, farm_view, world.player, inventory_panel, debug_menu, feedback, audio_service, hotbar_panel, shipping_bin_panel, seed_shop_panel)
	crop_inspector = CropInspector.new()
	add_child(crop_inspector)
	crop_inspector.configure(farm_state)
	tool_controller.configure_crop_inspector(crop_inspector)
	inventory_panel.slot_selected.connect(hotbar_panel.select_slot)
	hotbar_panel.register_tool(&"hoe", tr("UI_TOOL_HOE"), func() -> void: tool_controller.select_tool(&"hoe"))
	hotbar_panel.register_tool(&"shovel", tr("UI_TOOL_SHOVEL"), func() -> void: tool_controller.select_tool(&"shovel"))
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
	hud_presenter = LifeHudPresenter.new()
	add_child(hud_presenter)
	hud_presenter.configure(self)
	day_end_flow = LifeDayEndFlow.new()
	add_child(day_end_flow)
	day_end_flow.configure(self)
	morning_flow = LifeMorningFlow.new()
	add_child(morning_flow)
	morning_flow.configure(self)
	character_flow = LifeCharacterFlow.new()
	add_child(character_flow)
	character_flow.configure(self)
	machine_placement_flow = MachinePlacementFlow.new()
	add_child(machine_placement_flow)
	machine_placement_flow.configure(self)
	tool_controller.configure_placement(machine_placement_request)
	land_runtime = LandRuntime.new()
	add_child(land_runtime)
	land_runtime.configure(self)
	bag_upgrade_flow = BagUpgradeFlow.new()
	add_child(bag_upgrade_flow)
	bag_upgrade_flow.configure(self)
	watering_upgrade_flow = WateringUpgradeFlow.new()
	add_child(watering_upgrade_flow)
	watering_upgrade_flow.configure(self)
	chicken_coop_runtime = ChickenCoopRuntime.new()
	add_child(chicken_coop_runtime)
	chicken_coop_runtime.configure(self)
	chicken_coop_flow = ChickenCoopFlow.new()
	add_child(chicken_coop_flow)
	chicken_coop_flow.configure(self)
	director_runtime = LifeDirectorRuntime.new()
	add_child(director_runtime)
	director_runtime.configure(self)
	if OS.is_debug_build():
		director_debug_flow = LifeDirectorDebugFlow.new()
		add_child(director_debug_flow)
		director_debug_flow.configure(self)
	dog_runtime = LifeDogRuntime.new()
	add_child(dog_runtime)
	dog_runtime.configure(self)
	dog_state.changed.connect(_mark_save_dirty)
	story_runtime = LifeStoryRuntime.new()
	add_child(story_runtime)
	if not story_runtime.configure(self):
		push_error("Main: story configuration failed")
		return
	story_state.changed.connect(_mark_save_dirty)
	dog_name_flow = LifeDogNameFlow.new()
	add_child(dog_name_flow)
	dog_name_flow.configure(self)
	inventory_panel.attach_main(self)
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
	ecology_effects_flow = LifeEcologyEffectsFlow.new()
	add_child(ecology_effects_flow)
	ecology_effects_flow.configure(self)
	_apply_player_appearance()
	machine_presentation = preload("res://scripts/view/machine_presentation.gd").new()
	add_child(machine_presentation)
	machine_presentation.configure(self)
	ambient_audio_flow = LifeAmbientAudioFlow.new()
	ambient_audio_flow.name = "AmbientAudioFlow"
	add_child(ambient_audio_flow)
	ambient_audio_flow.configure(self)
	if OS.get_cmdline_user_args().has("--capture-chibi-characters"):
		call_deferred("_capture_chibi_characters")
	elif OS.get_cmdline_user_args().has("--capture-chibi-farming"):
		call_deferred("_capture_chibi_farming")
	elif OS.get_cmdline_user_args().has("--capture-chibi-world"):
		call_deferred("_capture_chibi_world")
	elif OS.get_cmdline_user_args().has("--capture-chibi-ui"):
		call_deferred("_capture_chibi_ui")

func _on_day_started(_day_index: int) -> void:
	if director_runtime.is_busy() or _day_index!=GameClock.day_index or ecology_runtime.busy or not ecology_state.day_quote(_day_index).ok or chicken_coop_runtime.busy or not bool(chicken_coop.coop.day_quote(_day_index-1).ok) or not bool(weather_state.call("day_quote",_day_index).ok):
		return
	var weather_day: Dictionary = weather_state.call("begin_day",_day_index)
	if not bool(weather_day.ok):
		return
	var ecology_day: Dictionary = ecology_runtime.begin_day(_day_index, farm_state, land_ownership)
	if not ecology_day.ok:
		weather_state.call("abort_day", weather_day.token)
		push_warning("Main: ecology preflight rejected: " + String(ecology_day.reason))
		return
	var director_day: Dictionary = director_daily_flow.begin(_day_index)
	if not director_day.ok:
		ecology_runtime.abort_day()
		weather_state.call("abort_day", weather_day.token)
		return
	chicken_coop_runtime.busy = true
	chicken_coop_runtime.simulator.simulate_day(farm_state,chicken_coop.coop,machine_operations,_day_index-1,_simulate_farm_day,_simulate_ecology_day.bind(_day_index))
	if int(chicken_coop.coop.serialize().current_day)!=_day_index:
		if not ecology_runtime.abort_day():
			push_warning("Main: inconsistent completed owners; lifecycle remains locked")
			return
		weather_state.call("abort_day",weather_day.token)
		director_daily_flow.abort()
		chicken_coop_runtime.busy = false
		push_warning("Main: daily simulation did not complete; weather retained")
		return
	if ecology_state.get_day_index() != _day_index:
		push_warning("Main: ecology did not complete; lifecycle remains locked")
		return
	chicken_coop_runtime.refresh_site()
	if not bool(weather_state.call("finish_day",weather_day.token)):
		push_warning("Main: weather reservation failed after simulation; lifecycle remains locked")
		return
	if bool(weather_state.call("is_rainy")):
		farm_state.water_all_crops()
	if not director_daily_flow.finish(_day_index):
		push_warning("Main: Director did not finish; lifecycle remains locked")
		return
	day_end_flow.on_morning(_day_index)
	chicken_coop_runtime.busy = false
	director_runtime.refresh_effects()
	if not day_end_flow.is_advancing():
		var saved: bool = _save_game_to_slot(0)
		_show_toast(tr("UI_SAVED") if saved else tr("PAUSE_SAVE_FAILED"))
	morning_flow.queue_day(_day_index)

func _simulate_farm_day(farm: FarmGridState) -> void:
	# Keep the injectable one-argument farm step while the outer simulator owns ordering.
	if bool(weather_state.call("is_rainy")):
		farm.water_all_crops()
	day_simulator.call("simulate_day",farm)
	farm.mark_out_of_season()

func _simulate_ecology_day(day: int) -> void:
	var result: Dictionary = ecology_runtime.finish_day(day, farm_state)
	if not result.ok:
		push_warning("Main: ecology daily update rejected: " + String(result.reason))

func _on_season_changed(season: StringName) -> void:
	_show_toast(tr("UI_SEASON_CHANGED") % tr(String(DataRegistry.get_season(season).get("display_name_key"))))

func _save_game() -> bool:
	var saved: bool = _save_game_to_slot(1)
	_show_toast(tr("UI_SAVED") if saved else tr("PAUSE_SAVE_FAILED"))
	return saved

func _save_game_to_slot(slot: int) -> bool:
	if _purchase_in_progress() or npc_system.is_open() or GameClock.is_sleeping() or (day_end_flow != null and day_end_flow.is_advancing()):
		return false
	var payload: Dictionary = {
		"story": story_state.serialize(),
		"dog": dog_state.serialize(),
		"clock": GameClock.serialize(),
		"player": {"position": _legacy_player_position()},
		"inventory": inventory.serialize(),
		"machine_inventory": machine_inventory.serialize(),
		"machine_placements": machine_placements.serialize(),
		"machine_operations": machine_operations.serialize(),
		"land_ownership": land_ownership.serialize(),
		"watering_can": watering_can.serialize(),
		"chicken_coop": chicken_coop.serialize(),
		"farm": farm_state.serialize(),
		"ecology": ecology_state.serialize(),
		"director_activity": director_activity.serialize(),
		"director": director_state.serialize(),
		"quests": quest_state.serialize(),
		"profile": profile,
		"weather": weather_state.call("serialize"),
		"wallet": wallet.serialize(),
		"social": npc_system.state.serialize(),
		"day_ledger": day_end_flow.ledger.serialize(),
		"day_end": day_end_flow.state.serialize()
	}
	if not SaveService.save_game(payload, slot):
		push_warning("Main: could not save slot %d" % slot)
		return false
	return true

func _load_game() -> bool:
	return _load_game_from_slot(1)

func _load_game_from_slot(slot: int) -> bool:
	_load_feedback = {}
	if _purchase_in_progress():
		return false
	var payload: Dictionary = SaveService.load_game(slot)
	var report: Dictionary = SaveService.get_load_report(slot)
	if payload.is_empty():
		_load_feedback = report
		return false
	if not _load_payload(payload):
		return false
	_load_feedback = report
	return true

func get_load_feedback() -> Dictionary:
	return _load_feedback.duplicate(true)

func _quit_game() -> void:
	if _purchase_in_progress():
		return
	_save_before_exit()
	get_tree().quit()

func _start_new_game(player_name: String, farm_name: String) -> void:
	if _purchase_in_progress():
		return
	var director_restore: Dictionary = director_runtime.prepare_restore({"clock": {"day_index": 0}, "farm": {}, "land_ownership": {}}, true)
	if not director_restore.ok:
		return
	if not ecology_runtime.begin_restore({"clock": {"day_index": 0}, "farm": {}, "land_ownership": {}}).ok:
		return
	if not director_runtime.begin_restore(director_restore):
		return
	if director_debug_flow != null:
		director_debug_flow.reset()
	bag_upgrade_flow.close()
	watering_upgrade_flow.close()
	chicken_coop_runtime.prepare_restore()
	_restore_land_for_lifecycle({})
	watering_runtime.busy = true
	machine_placement_flow.cancel()
	_game_started = false
	watering_runtime.reset()
	npc_system.journal.book_controller.reset()
	character_flow.close()
	dog_name_flow.close()
	GameClock.deserialize({})
	morning_flow.reset()
	inventory.deserialize({"capacity":InventoryState.CONFIG.default_capacity,"slots":[]})
	machine_inventory.deserialize({})
	machine_placements.deserialize({})
	machine_operations.deserialize({})
	if machine_presentation != null:
		machine_presentation.call("refresh")
	farm_state.reset()
	quest_state.deserialize({})
	wallet.deserialize(_initial_wallet)
	day_end_flow.reset()
	weather_state.call("restore_for_day",{},GameClock.day_index,0)
	world.player.position = _spawn_position
	npc_system.restore({})
	chicken_coop_runtime.reset()
	_pending_appearance = _normalize_player_appearance(_pending_appearance)
	profile = {"player_name": player_name, "farm_name": farm_name, "appearance": _pending_appearance.duplicate(true)}
	_apply_player_appearance()
	_game_started = true
	world.player.movement_enabled = true
	start_menu.visible = false
	if inventory.get_slots().is_empty():
		var starter_seed: StringName = DataRegistry.get_starter_seed_for_season(GameClock.season)
		inventory.add_item(starter_seed, 10)
	watering_runtime.busy = false
	watering_runtime.refresh()
	if not ecology_runtime.finish_restore(GameClock.day_index, farm_state, land_ownership):
		return
	if not director_runtime.finish_restore():
		return
	director_runtime.refresh_effects()
	dog_runtime.reset()
	if not story_runtime.reset(): return
	_save_game_to_slot(1)
	if not Settings.is_tutorial_dismissed():
		tutorial_panel.open_help()

func _continue_game() -> void:
	_load_feedback = {}
	if _purchase_in_progress():
		return
	var latest: Dictionary = SaveService.load_latest()
	if latest.is_empty():
		return
	var report: Dictionary = SaveService.get_load_report()
	if not _load_payload(latest):
		return
	_load_feedback = report
	start_menu.visible = false
	world.player.movement_enabled = not day_end_flow.panel.visible
	if report.get("status") == &"recovered":
		_show_toast(LifeSaveNotice.message(report))

func _return_to_start_menu() -> bool:
	if _purchase_in_progress():
		return false
	if director_debug_flow != null:
		director_debug_flow.reset()
	bag_upgrade_flow.close()
	watering_upgrade_flow.close()
	land_runtime.close()
	chicken_coop_flow.close()
	if _game_started and not _save_game_to_slot(1):
		_show_toast(tr("PAUSE_SAVE_FAILED"))
		return false
	machine_placement_flow.cancel()
	morning_flow.reset()
	pause_menu.close()
	character_flow.close()
	dog_name_flow.close()
	npc_system.journal.book_controller.reset()
	start_menu.refresh_continue()
	start_menu.visible = true
	world.player.movement_enabled = false
	director_runtime.refresh_effects()
	dog_runtime.suspend()
	story_runtime.suspend()
	return true

func _load_payload(payload: Dictionary) -> bool:
	if _purchase_in_progress():
		return false
	var story_restore: Dictionary = story_runtime.prepare(payload)
	if not story_restore.ok: return false
	var director_restore: Dictionary = director_runtime.prepare_restore(payload)
	if not director_restore.ok:
		return false
	if not ecology_runtime.begin_restore(payload).ok:
		return false
	if not director_runtime.begin_restore(director_restore):
		return false
	if director_debug_flow != null:
		director_debug_flow.reset()
	bag_upgrade_flow.close()
	watering_upgrade_flow.close()
	chicken_coop_runtime.prepare_restore()
	var raw_land: Variant = payload.get("land_ownership",{})
	_restore_land_for_lifecycle(raw_land if raw_land is Dictionary else {})
	watering_runtime.busy = true
	machine_placement_flow.cancel()
	npc_system.journal.book_controller.reset()
	character_flow.close()
	dog_name_flow.close()
	GameClock.deserialize(payload.get("clock", {}))
	morning_flow.reset()
	inventory.deserialize(payload.get("inventory", {}))
	machine_inventory.deserialize(payload.get("machine_inventory", {}))
	machine_placements.deserialize(payload.get("machine_placements", {}))
	machine_operations.deserialize(payload.get("machine_operations", {}))
	if machine_presentation != null:
		machine_presentation.call("refresh")
	farm_state.deserialize(payload.get("farm", {}))
	farm_view.configure(farm_state)
	quest_state.deserialize(payload.get("quests", {}))
	weather_state.call("restore_for_day",payload.get("weather",{}),GameClock.day_index,0)
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
	day_end_flow.restore(payload)
	chicken_coop_runtime.restore(payload)
	watering_runtime.restore(payload)
	watering_runtime.busy = false
	watering_runtime.refresh()
	var ecology_restored: bool = ecology_runtime.finish_restore(GameClock.day_index, farm_state, land_ownership)
	var director_restored: bool = director_runtime.finish_restore()
	if ecology_restored and director_restored:
		if not story_runtime.restore(story_restore): return false
		director_runtime.refresh_effects()
		if not dog_runtime.restore(payload.get("dog")): return false
	return ecology_restored and director_restored

func _restore_land_for_lifecycle(data: Dictionary) -> void:
	# LandRuntime.restore intentionally rejects global busy; this lifecycle owns that lock.
	land_runtime.close()
	land_ownership.deserialize(data)
	if presentation != null:
		presentation.refresh_land(land_ownership.get_owned_regions())

func _purchase_in_progress() -> bool:
	return story_state.is_busy() or (story_runtime!=null and story_runtime.is_busy()) or (npc_system!=null and npc_system.state.quests.is_busy()) or (dog_name_flow!=null and dog_name_flow.busy) or dog_state.is_busy() or (dog_runtime!=null and dog_runtime.is_busy()) or (director_runtime!=null and director_runtime.is_busy()) or (ecology_runtime!=null and ecology_runtime.busy) or ecology_state.is_busy() or (weather_state!=null and bool(weather_state.call("is_busy"))) or chicken_coop.coop.is_busy() or (chicken_coop_runtime!=null and chicken_coop_runtime.busy) or (watering_upgrade_flow!=null and watering_upgrade_flow.busy) or (land_runtime!=null and land_runtime.busy) or (bag_upgrade_flow!=null and bag_upgrade_flow.busy) or (watering_runtime!=null and watering_runtime.busy)

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
	toast.hide()
	hud_presenter.show_message(message)

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
