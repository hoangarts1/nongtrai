extends GutTest

var _main: Node
var _viewport: SubViewport
var _clock: Dictionary
var _paused: bool
var _locale: String
var _settings_bytes: PackedByteArray
var _settings_existed: bool

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	_settings_existed = FileAccess.file_exists(Settings.SETTINGS_PATH)
	_settings_bytes = FileAccess.get_file_as_bytes(Settings.SETTINGS_PATH) if _settings_existed else PackedByteArray()
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152,648)
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_main.set("_game_started",true)
	_main.start_menu.hide()
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()

func after_each() -> void:
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	if _settings_existed:
		var file: FileAccess = FileAccess.open(Settings.SETTINGS_PATH,FileAccess.WRITE)
		file.store_buffer(_settings_bytes)
		file.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Settings.SETTINGS_PATH))
	Settings.set("_config",ConfigFile.new())
	Settings.call("_ready")
	TranslationServer.set_locale(_locale)
	SaveService.delete_save(0)
	SaveService.delete_save(1)

func test_drafts_cancel_on_close_or_modal_switch_without_changing_gameplay() -> void:
	Settings.set_music_volume(0.35)
	Settings.set_effects_volume(0.65)
	Settings.set_locale("vi")
	_main.pause_menu.open()
	await _settle()
	var screen: LifePauseShell = _main.pause_menu.shell
	var farm: Dictionary = _main.farm_state.serialize()
	var bag: Dictionary = _main.inventory.serialize()
	var coins: int = _main.wallet.get_coins()
	screen.settings.audio.set_values(0.1,0.2)
	screen.settings.game.set_locale("en")
	assert_eq(Settings.get_locale(),"vi")
	assert_almost_eq(Settings.get_music_volume(),0.35,0.001)
	_main.pause_menu.close()
	_main.pause_menu.open()
	assert_almost_eq(screen.settings.audio.music.value,0.35,0.001)
	assert_eq(screen.settings.game.get_locale(),"vi")
	screen.settings.audio.set_values(0.9,0.9)
	_action(&"open_inventory")
	await _settle()
	assert_false(_main.pause_menu.visible)
	assert_true(_main.inventory_panel.visible)
	_main.ui_coordinator.close_active()
	_main.pause_menu.open()
	assert_almost_eq(screen.settings.audio.effects.value,0.65,0.001)
	assert_eq(_main.farm_state.serialize(),farm)
	assert_eq(_main.inventory.serialize(),bag)
	assert_eq(_main.wallet.get_coins(),coins)

func test_apply_and_defaults_persist_supported_preferences_only() -> void:
	Settings.set_locale("en")
	_main.pause_menu.open()
	var screen: LifePauseShell = _main.pause_menu.shell
	screen.settings.audio.set_values(0.7,0.85)
	screen.settings.game.set_locale("vi")
	_main.pause_menu.presenter.apply()
	Settings.set("_config",ConfigFile.new())
	Settings.call("_ready")
	assert_eq(Settings.get_locale(),"vi")
	assert_almost_eq(Settings.get_music_volume(),0.7,0.001)
	assert_almost_eq(Settings.get_effects_volume(),0.85,0.001)
	assert_eq(screen.settings.tabs[0].text,tr("PAUSE_AUDIO"))
	assert_eq(screen.actions.save_button.text,tr("UI_SAVE"))
	_main.pause_menu.presenter.defaults()
	assert_almost_eq(Settings.get_music_volume(),0.7,0.001,"Default is a draft")
	assert_almost_eq(screen.settings.audio.music.value,1.0,0.001)
	_main.pause_menu.presenter.apply()
	Settings.set("_config",ConfigFile.new())
	Settings.call("_ready")
	assert_eq(Settings.get_locale(),"vi")
	assert_almost_eq(Settings.get_music_volume(),1.0,0.001)
	assert_almost_eq(Settings.get_effects_volume(),1.0,0.001)
	assert_eq(SaveService.CURRENT_VERSION,12)

func test_save_load_results_and_blocked_return_preserve_game() -> void:
	_main.pause_menu.open()
	await _settle()
	var screen: LifePauseShell = _main.pause_menu.shell
	var coins: int = _main.wallet.get_coins()
	_main.pause_menu.presenter.request(&"save")
	assert_eq(screen.settings.status.text,tr("UI_SAVED"))
	assert_eq(int(SaveService.load_game(1).wallet.coins),coins)
	var summary: Dictionary = SaveService.get_latest_summary()
	assert_eq(screen.actions.summary.text,tr("PAUSE_SAVE_SUMMARY") % [int(summary.day_index),String(summary.saved_at)])
	_main.wallet.add_coins(5,&"test")
	_main.pause_menu.presenter.request(&"load")
	assert_eq(_main.wallet.get_coins(),coins)
	assert_eq(screen.settings.status.text,tr("PAUSE_LOADED"))
	SaveService.delete_save(1)
	_main.pause_menu.presenter.request(&"load")
	assert_eq(screen.settings.status.text,tr("PAUSE_LOAD_FAILED"))
	_main.pause_menu.close()
	await _settle()
	_main.npc_system.open_journal()
	await _settle()
	assert_true(_main.npc_system.is_open(),"Use a reachable NPC journal safe-point guard")
	assert_false(_main.call("_save_game"),"NPC modal blocks the real save path")
	assert_eq(_main.toast.text,tr("PAUSE_SAVE_FAILED"))
	assert_false(_main.call("_return_to_start_menu"))
	assert_false(_main.start_menu.visible,"Failed required save must not discard the game")
	assert_true(bool(_main.get("_game_started")))
	assert_eq(_main.wallet.get_coins(),coins)
	assert_true(SaveService.load_game(1).is_empty())

func test_backend_rejection_is_reported_without_false_success_and_retry_works() -> void:
	_main.pause_menu.open()
	SaveService.delete_save(1)
	# Exercise the real Main -> SaveService false result without an intentional engine error.
	_main.pause_menu.configure(_main._save_game_to_slot.bind(-1),_main._load_game,_main._return_to_start_menu)
	_main.pause_menu.presenter.request(&"save")
	assert_eq(_main.pause_menu.shell.settings.status.text,tr("PAUSE_SAVE_FAILED"))
	assert_true(SaveService.load_game(1).is_empty())
	_main.pause_menu.configure(_main._save_game,_main._load_game,_main._return_to_start_menu)
	_main.pause_menu.presenter.request(&"save")
	assert_eq(_main.pause_menu.shell.settings.status.text,tr("UI_SAVED"))
	assert_false(SaveService.load_game(1).is_empty())

func test_day_end_review_wins_over_pause_and_clock_hold_restores() -> void:
	_main.pause_menu.open()
	GameClock.deserialize({"day_index":1,"minute":1560})
	_main.day_end_flow.state.review(1,true)
	var payload: Dictionary = {"clock":GameClock.serialize(),"day_end":_main.day_end_flow.state.serialize()}
	_main.call("_load_payload",payload)
	await _settle()
	assert_true(_main.day_end_flow.panel.visible)
	assert_false(_main.pause_menu.visible)
	assert_true(GameClock.paused)
	_main.pause_menu.open()
	assert_false(_main.pause_menu.visible)
	assert_eq(_main.ui_coordinator.get_active_panel(),_main.day_end_flow.panel)
	assert_true(GameClock.paused)
	assert_false(_main.world.player.movement_enabled)

func test_close_restores_an_existing_clock_hold() -> void:
	GameClock.paused = true
	_main.pause_menu.open()
	await _settle()
	_main.pause_menu.close()
	assert_true(GameClock.paused,"The modal owner preserves the pre-existing hold")
	assert_true(_main.world.player.movement_enabled)

func _action(id: StringName) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = id
	event.pressed = true
	_viewport.push_input(event)

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
