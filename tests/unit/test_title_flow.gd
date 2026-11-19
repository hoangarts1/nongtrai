extends GutTest

var _main: Node
var _viewport: SubViewport
var _clock: Dictionary
var _paused: bool
var _locale: String
var _music: float
var _effects: float
var _preference_locale: String
var _continue_requests: int = 0
var _backup_snapshots: Dictionary = {}

func before_each() -> void:
	_isolate_backups()
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	_music = Settings.get_music_volume()
	_effects = Settings.get_effects_volume()
	_preference_locale = Settings.get_locale()
	_continue_requests = 0
	SaveService.delete_save(0)
	SaveService.delete_save(1)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152,648)
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)

func after_each() -> void:
	_restore_backups()
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	Settings.set_music_volume(_music)
	Settings.set_effects_volume(_effects)
	Settings.set_locale(_preference_locale)
	TranslationServer.set_locale(_locale)
	SaveService.delete_save(0)
	SaveService.delete_save(1)

func test_latest_card_and_continue_use_newest_saved_state_without_mutating_live_world() -> void:
	assert_true(SaveService.save_game({"profile":{"farm_name":"Older"},"wallet":{"coins":50},"clock":{"day_index":2}},1))
	await get_tree().create_timer(0.01).timeout
	assert_true(SaveService.save_game({"profile":{"farm_name":"Mùa An Lành","player_name":"Mai"},"wallet":{"coins":1240},"clock":{"day_index":9}},0))
	var before: Dictionary = _main.inventory.serialize()
	var coins: int = _main.wallet.get_coins()
	_main.start_menu.refresh_continue()
	var card: LifeLatestSaveCard = _main.start_menu.screen.latest
	assert_eq(card.farm.text,"Mùa An Lành")
	assert_eq(card.player.text,"Mai")
	assert_eq(card.day.text,tr("TITLE_SAVE_DAY") % 10)
	assert_eq(card.coins.text,tr("UI_WALLET_COINS") % 1240)
	assert_false(_main.start_menu.screen.actions.continue_button.disabled)
	assert_eq(_main.inventory.serialize(),before)
	assert_eq(_main.wallet.get_coins(),coins,"Title must not apply saved wallet before Continue")
	_main.start_menu.presenter.request(&"continue")
	assert_false(_main.start_menu.visible)
	assert_eq(_main.wallet.get_coins(),1240)
	assert_eq(GameClock.day_index,9)
	assert_eq(String(_main.profile.player_name),"Mai")

func test_empty_corrupt_and_deleted_save_do_not_enter_game() -> void:
	_main.start_menu.configure(Callable(),_continued,Callable())
	_main.start_menu.refresh_continue()
	assert_true(_main.start_menu.screen.actions.continue_button.disabled)
	assert_eq(_main.start_menu.screen.latest.heading.text,tr("TITLE_NO_SAVE"))
	_main.start_menu.presenter.request(&"continue")
	assert_eq(_continue_requests,0)
	assert_true(SaveService.save_game({},1))
	_main.start_menu.refresh_continue()
	assert_false(_main.start_menu.screen.actions.continue_button.disabled)
	SaveService.delete_save(1)
	_main.start_menu.presenter.request(&"continue")
	assert_eq(_continue_requests,0,"Revalidate if the save disappears between display and click")
	assert_true(_main.start_menu.visible)
	assert_true(SaveService.save_game({},1))
	var file: FileAccess = FileAccess.open("user://saves/slot_1.json",FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	_main.start_menu.refresh_continue()
	assert_true(_main.start_menu.screen.actions.continue_button.disabled)
	_main.start_menu.presenter.request(&"continue")
	assert_eq(_continue_requests,0)

func test_all_old_goldens_remain_loadable_and_display_fields_from_migrated_payload() -> void:
	for version: int in range(1,9):
		var path: String = "res://tests/golden_saves/save_v%d.json" % version
		assert_true(FileAccess.file_exists(path))
		assert_true(SaveService.save_game({},1))
		var file: FileAccess = FileAccess.open("user://saves/slot_1.json",FileAccess.WRITE)
		file.store_string(FileAccess.get_file_as_string(path))
		file.close()
		_main.start_menu.refresh_continue()
		var payload: Dictionary = SaveService.load_latest()
		assert_false(payload.is_empty(),"Golden v%d remains a valid Continue source" % version)
		assert_false(_main.start_menu.screen.actions.continue_button.disabled)
		var farm: String = LifeTitleParts.text(LifeTitleParts.dictionary(payload.get("profile",{})),&"farm_name")
		assert_eq(_main.start_menu.screen.latest.farm.text,farm)
		assert_eq(int(payload.meta.save_version),15)

func test_bad_or_missing_optional_fields_are_omitted_without_fake_numbers() -> void:
	var card: LifeLatestSaveCard = _main.start_menu.screen.latest
	card.display({"profile":{"farm_name":17,"player_name":[]},"wallet":{"coins":-4},"clock":{"day_index":"bad"}})
	assert_false(card.farm.visible)
	assert_false(card.player.visible)
	assert_false(card.coins.visible)
	assert_false(card.day.visible)
	card.display({"profile":[],"clock":[],"wallet":[]})
	assert_false(card.coins.visible)
	assert_false(card.day.visible)
	card.display({"wallet":{"coins":2.5},"clock":{"day_index":NAN}})
	assert_false(card.coins.visible)
	assert_false(card.day.visible)
	assert_eq(LifeTitleParts.nonnegative_number(INF),-1)
	var paths: Array[String] = ["res://localization/strings_vi.csv","res://localization/strings_en.csv"]
	var keys: PackedStringArray = ["TITLE_LATEST_SAVE","TITLE_NO_SAVE","TITLE_SAVE_DAY","TITLE_PLAYER_NAME","TITLE_FARM_NAME","TITLE_NAV_HINT","TITLE_VERSION"]
	assert_true(DataValidator.validate_translation_keys(paths,keys).is_empty())

func test_form_retains_choices_and_submits_original_clean_game_flow() -> void:
	var menu: StartMenu = _main.start_menu
	menu.call("_show_new_game_fields")
	var form: LifeTitleProfileForm = menu.screen.profile
	form.player_name.text = "An"
	form.farm_name.text = "Vườn Nhỏ"
	form.hair_style.select(5)
	form.skin_tone.select(5)
	var count: int = form.get_child_count()
	menu.call("_show_new_game_fields")
	assert_eq(form.get_child_count(),count)
	assert_eq(form.player_name.text,"An")
	menu.handle_back()
	menu.call("_show_new_game_fields")
	assert_eq(form.hair_style.selected,5)
	assert_eq(form.player_name.text,"An")
	_main.wallet.add_coins(999,&"test")
	_main.inventory.add_item(&"turnip",8)
	_main.farm_state.till_cell(Vector2i(1,1))
	menu.call("_submit_new_game")
	assert_eq(_main.wallet.get_coins(),100)
	assert_eq(_main.inventory.get_quantity(&"turnip"),0)
	assert_eq(_main.inventory.get_quantity(&"turnip_seed"),10)
	assert_true(_main.farm_state.get_plot(Vector2i(1,1)).is_empty())
	assert_eq(String(_main.profile.player_name),"An")
	assert_eq(String(_main.profile.farm_name),"Vườn Nhỏ")
	assert_eq(String(_main.profile.appearance.hair_style),"twin_puffs")
	assert_eq(int(_main.profile.appearance.skin_index),5)
	assert_eq(int(SaveService.load_game(1).meta.save_version),15)

func test_title_settings_cancel_default_apply_reload_without_entering_game() -> void:
	Settings.set_locale("vi")
	Settings.set_music_volume(0.4)
	Settings.set_effects_volume(0.6)
	var menu: StartMenu = _main.start_menu
	menu.call("_toggle_settings")
	var settings: LifeTitleSettings = menu.screen.settings
	settings.panel.audio.set_values(0.7,0.85)
	settings.panel.game.set_locale("en")
	assert_eq(Settings.get_locale(),"vi")
	menu.handle_back()
	menu.call("_toggle_settings")
	assert_almost_eq(settings.panel.audio.music.value,0.4,0.001)
	assert_eq(settings.panel.game.get_locale(),"vi")
	settings.defaults()
	assert_almost_eq(Settings.get_music_volume(),0.4,0.001)
	settings.panel.game.set_locale("en")
	settings.apply()
	var config: ConfigFile = ConfigFile.new()
	assert_eq(config.load(Settings.SETTINGS_PATH),OK)
	assert_eq(String(config.get_value("ui","locale")),"en")
	assert_almost_eq(float(config.get_value("ui","music_volume")),1.0,0.001)
	assert_eq(menu.screen.actions.new_game_button.text,tr("UI_MAIN_NEW_GAME"))
	var first_style: String = String(menu.screen.profile.hair_style.get_item_metadata(0))
	assert_eq(menu.screen.profile.hair_style.get_item_text(0),tr("UI_APPEARANCE_HAIR_%s" % first_style.to_upper()))
	menu.handle_back()
	assert_true(menu.visible)
	assert_false(bool(_main.get("_game_started")))
	assert_eq(_main.ui_coordinator.get_active_panel(),menu)
	assert_false(_main.world.player.movement_enabled)

# Corruption without a usable backup must not inherit another test's recovery files.
func _isolate_backups() -> void:
	for slot: int in [0, 1]:
		for index: int in range(1, SaveService.MAX_BACKUPS + 1):
			var path: String = "%s/slot_%d.json.bak%d" % [SaveService.SAVE_DIRECTORY, slot, index]
			_backup_snapshots[path] = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
			if FileAccess.file_exists(path):
				assert_eq(DirAccess.remove_absolute(ProjectSettings.globalize_path(path)), OK)

func _restore_backups() -> void:
	for path: String in _backup_snapshots:
		if FileAccess.file_exists(path):
			assert_eq(DirAccess.remove_absolute(ProjectSettings.globalize_path(path)), OK)
		var bytes: Variant = _backup_snapshots[path]
		if bytes is PackedByteArray:
			var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
			assert_not_null(file)
			file.store_buffer(bytes)
			file.close()
	_backup_snapshots.clear()

func _continued() -> void:
	_continue_requests += 1
