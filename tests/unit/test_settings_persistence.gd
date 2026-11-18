extends GutTest

class FaultBackend extends SaveFileStore:
	var mode: String = ""
	func write_bytes(path: String, bytes: PackedByteArray) -> bool:
		if mode == "write" and path.ends_with(".tmp"):
			mode = ""
			return false
		return super.write_bytes(path, bytes)
	func rename_file(source: String, target: String) -> bool:
		if mode == "rename" and source.ends_with(".new0.tmp"):
			mode = ""
			return false
		return super.rename_file(source, target)

class CountingStore extends SettingsFileStore:
	var writes: int = 0
	func persist(path: String, text: String) -> Dictionary:
		writes += 1
		return super.persist(path, text)

var _existed: bool
var _bytes: PackedByteArray
var _locale: String
var _clock: Dictionary
var _paused: bool
var _original_store: SettingsFileStore
var _nodes: Array[Node] = []
var _viewport: SubViewport

func before_each() -> void:
	_existed = FileAccess.file_exists(Settings.SETTINGS_PATH)
	_bytes = FileAccess.get_file_as_bytes(Settings.SETTINGS_PATH) if _existed else PackedByteArray()
	_locale = TranslationServer.get_locale()
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_original_store = Settings.file_store

func after_each() -> void:
	if is_instance_valid(_viewport):
		_viewport.free()
	for node: Node in _nodes:
		node.free()
	_nodes.clear()
	if _existed:
		var file: FileAccess = FileAccess.open(Settings.SETTINGS_PATH, FileAccess.WRITE)
		file.store_buffer(_bytes)
		file.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Settings.SETTINGS_PATH))
	Settings.file_store = _original_store
	Settings.call("_ready")
	TranslationServer.set_locale(_locale)
	GameClock.deserialize(_clock)
	GameClock.paused = _paused

func _config() -> ConfigFile:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("ui", "music_volume", 0.25)
	config.set_value("ui", "effects_volume", 0.5)
	config.set_value("ui", "locale", "vi")
	config.set_value("ui", "tutorial_dismissed", false)
	config.set_value("ui", "future_key", {"kept": [1, 2]})
	config.set_value("custom", "note", "unchanged")
	return config

func _settings(config: ConfigFile) -> Node:
	var node: Node = preload("res://scripts/core/settings.gd").new()
	node.set("_config", config)
	_nodes.append(node)
	return node

func test_codec_defaults_load_normalization_and_strict_draft_validation() -> void:
	assert_eq(SettingsCodec.decode({}).values, SettingsCodec.defaults())
	for value: Variant in [NAN, INF, -INF, "loud", false, [], {}]:
		var result: Dictionary = SettingsCodec.decode({"music_volume": value, "effects_volume": value, "locale": "xx", "tutorial_dismissed": 1})
		assert_true(result.ok)
		assert_eq(result.values, SettingsCodec.defaults())
		assert_false(SettingsCodec.decode({"effects_volume": value}, true).ok)
	assert_eq(SettingsCodec.decode({"music_volume": -1, "effects_volume": 2}).values.music_volume, 0.0)
	assert_eq(SettingsCodec.decode({"effects_volume": 2}).values.effects_volume, 1.0)
	assert_false(SettingsCodec.decode({"music_volume": -1}, true).ok)
	assert_true(SettingsCodec.decode({"music_volume": 0, "effects_volume": 1, "locale": &"en", "tutorial_dismissed": true}, true).ok)

func test_apply_persists_once_preserves_unknown_keys_and_emits_detached_accepted_snapshot() -> void:
	var node: Node = _settings(_config())
	var store: CountingStore = CountingStore.new()
	node.file_store = store
	var events: Array[Dictionary] = []
	var reentry: Array[bool] = []
	node.preferences_changed.connect(func(values: Dictionary) -> void:
		events.append(values.duplicate(true))
		reentry.append(bool(node.apply_preferences({"music_volume": 0.1}).ok))
		values.effects_volume = 0.0)
	var patch: Dictionary = {"music_volume": 0.7, "effects_volume": 0.85, "locale": "en"}
	assert_true(node.apply_preferences(patch).ok)
	assert_eq(store.writes, 1)
	assert_eq(events.size(), 1)
	assert_eq(reentry, [false])
	assert_eq(node.get_effects_volume(), 0.85)
	assert_eq(TranslationServer.get_locale(), "en")
	var saved: ConfigFile = ConfigFile.new()
	assert_eq(saved.load(Settings.SETTINGS_PATH), OK)
	assert_eq(saved.get_value("ui", "effects_volume"), 0.85)
	assert_eq(saved.get_value("ui", "future_key"), {"kept": [1, 2]})
	assert_eq(saved.get_value("custom", "note"), "unchanged")
	assert_true(node.apply_preferences(patch).ok)
	assert_eq(store.writes, 2)
	assert_eq(events.size(), 1, "Unchanged accepted values emit no change event")

func test_write_and_rename_fault_leave_file_runtime_locale_and_signals_unchanged_until_retry() -> void:
	for mode: String in ["write", "rename"]:
		var config: ConfigFile = _config()
		assert_eq(config.save(Settings.SETTINGS_PATH), OK)
		var hash_before: String = FileAccess.get_sha256(Settings.SETTINGS_PATH)
		var node: Node = _settings(config)
		var backend: FaultBackend = FaultBackend.new()
		backend.mode = mode
		node.file_store.backend = backend
		TranslationServer.set_locale("vi")
		var before: Dictionary = node.get_preferences()
		var events: Array[Dictionary] = []
		node.preferences_changed.connect(func(values: Dictionary) -> void: events.append(values.duplicate(true)))
		assert_false(node.apply_preferences({"music_volume": 0.6, "effects_volume": 0.8, "locale": "en"}).ok)
		assert_eq(node.get_preferences(), before)
		assert_eq(TranslationServer.get_locale(), "vi")
		assert_eq(FileAccess.get_sha256(Settings.SETTINGS_PATH), hash_before)
		assert_eq(events.size(), 0)
		assert_true(node.apply_preferences({"music_volume": 0.6, "effects_volume": 0.8, "locale": "en"}).ok)
		assert_eq(events.size(), 1)
		assert_eq(node.get_locale(), "en")

func test_rejected_draft_does_not_write_and_legacy_clamping_does_not_change_locale() -> void:
	var node: Node = _settings(_config())
	var store: CountingStore = CountingStore.new()
	node.file_store = store
	for patch: Dictionary in [{"music_volume": NAN}, {"locale": "bad"}, {"tutorial_dismissed": 1}, {"fullscreen": true}]:
		assert_false(node.apply_preferences(patch).ok)
	assert_eq(store.writes, 0)
	TranslationServer.set_locale("en")
	node.set_music_volume(-1.0)
	node.set_effects_volume(2.0)
	assert_eq(node.get_music_volume(), 0.0)
	assert_eq(node.get_effects_volume(), 1.0)
	assert_eq(TranslationServer.get_locale(), "en", "Volume-only wrapper keeps the current locale")
	assert_eq(store.writes, 2)

func test_title_and_pause_apply_fail_honestly_then_retry_without_changing_drafts_or_savegame() -> void:
	assert_true(Settings.apply_preferences({"music_volume": 0.2, "effects_volume": 0.3, "locale": "vi"}).ok)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152, 648)
	add_child(_viewport)
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(main)
	main.start_menu.call("_toggle_settings")
	var backend: FaultBackend = FaultBackend.new()
	var store: SettingsFileStore = SettingsFileStore.new()
	store.backend = backend
	Settings.file_store = store
	var before: Dictionary = Settings.get_preferences()
	var coins: int = main.wallet.get_coins()
	main.start_menu.screen.settings.panel.audio.set_values(0.7, 0.8)
	main.start_menu.screen.settings.panel.game.set_locale("en")
	backend.mode = "write"
	main.start_menu.screen.settings.apply()
	assert_eq(main.start_menu.screen.settings.panel.status.text, tr("PREFERENCES_APPLY_FAILED"))
	assert_eq(Settings.get_preferences(), before)
	main.start_menu.screen.settings.apply()
	assert_eq(Settings.get_locale(), "en")
	main.start_menu.hide()
	main.set("_game_started", true)
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	main.pause_menu.open()
	main.pause_menu.shell.settings.audio.set_values(0.1, 0.2)
	main.pause_menu.shell.settings.game.set_locale("vi")
	backend.mode = "rename"
	main.pause_menu.presenter.apply()
	assert_eq(main.pause_menu.shell.settings.status.text, tr("PREFERENCES_APPLY_FAILED"))
	assert_eq(Settings.get_locale(), "en")
	main.pause_menu.presenter.apply()
	assert_eq(Settings.get_locale(), "vi")
	assert_eq(main.pause_menu.shell.settings.status.text, tr("PAUSE_APPLIED"))
	assert_eq(main.wallet.get_coins(), coins)
