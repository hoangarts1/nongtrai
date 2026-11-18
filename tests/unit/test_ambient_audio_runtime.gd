extends GutTest

class RejectingStore extends SettingsFileStore:
	func persist(_path: String, _text: String) -> Dictionary:
		return {"ok": false, "error": &"injected_failure"}

const PROFILE: AmbientAudioProfile = preload("res://data/ambient_audio_profile.tres")
var _main: Node
var _viewport: SubViewport
var _clock: Dictionary
var _paused: bool
var _locale: String
var _layout: AudioBusLayout
var _store: SettingsFileStore
var _files: Dictionary = {}

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	_layout = AudioServer.generate_bus_layout()
	_store = Settings.file_store
	_files[Settings.SETTINGS_PATH] = FileAccess.get_file_as_bytes(Settings.SETTINGS_PATH) if FileAccess.file_exists(Settings.SETTINGS_PATH) else null
	for slot: int in [0, 1]:
		for index: int in range(4):
			var path: String = "user://saves/slot_%d.json%s" % [slot, "" if index == 0 else ".bak%d" % index]
			_files[path] = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
	assert_true(Settings.apply_preferences({"music_volume": 1.0, "effects_volume": 1.0, "tutorial_dismissed": true}).ok)
	AudioServer.set_bus_layout(load("res://default_bus_layout.tres") as AudioBusLayout)
	GameClock.deserialize({})
	GameClock.paused = true
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152, 648)
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_main.set_process(false)
	_main.world.player.set_physics_process(false)

func after_each() -> void:
	await _settle()
	_viewport.free()
	Settings.file_store = _store
	for path: String in _files:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		var bytes: Variant = _files[path]
		if bytes is PackedByteArray:
			var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
			file.store_buffer(bytes)
			file.close()
	_files.clear()
	Settings.call("_ready")
	TranslationServer.set_locale(_locale)
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	AudioServer.set_bus_layout(_layout)

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func _activate() -> void:
	_main.set("_game_started", true)
	_main.start_menu.hide()
	_main.tutorial_panel.hide()
	_main.ui_coordinator.close_active()
	_main.world.player.move_to_cell(Vector2i(1, 1))
	GameClock.set_time(8, 0)
	GameClock.paused = true
	_main.weather_state.call("force_weather", &"sunny")
	await _settle()

func _owners() -> Dictionary:
	return {"clock": GameClock.serialize(), "weather": _main.weather_state.call("serialize"), "farm": _main.farm_state.serialize(), "bag": _main.inventory.serialize(), "coins": _main.wallet.serialize(), "ledger": _main.day_end_flow.ledger.serialize(), "water": _main.watering_can.serialize(), "coop": _main.chicken_coop.serialize(), "machines": _main.machine_operations.call("serialize")}

func _snapshot() -> Dictionary:
	return _main.ambient_audio_flow.get_playback_snapshot()

func _playing(snapshot: Dictionary) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for row: Dictionary in snapshot.players:
		if row.playing:
			rows.append(row)
	return rows

func _ids() -> Array[int]:
	var ids: Array[int] = []
	for row: Dictionary in _snapshot().players:
		ids.append(row.instance_id)
	return ids

func _gain(bus: StringName) -> float:
	return AudioServer.get_bus_volume_linear(AudioServer.get_bus_index(bus))

func _connections(signal_value: Signal, id: int) -> int:
	var count: int = 0
	for connection: Dictionary in signal_value.get_connections():
		var owner: Object = (connection.callable as Callable).get_object()
		if is_instance_valid(owner) and owner.get_instance_id() == id:
			count += 1
	return count

func _click(button: Control) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = button.get_global_rect().get_center()
		event.global_position = event.position
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		event.pressed = pressed
		_viewport.push_input(event, true)
		await get_tree().process_frame
	await _settle()

func test_pure_context_boundaries_priorities_and_malformed_profile_never_change_owners() -> void:
	var before: Dictionary = _owners()
	var rows: Array[Dictionary] = PROFILE.tracks.duplicate(true)
	for minute: int in [0, 359, 360, 719, 720, 1199, 1200, 1559]:
		var result: Dictionary = AmbientAudioContext.select(PROFILE, Vector2i(1, 1), minute, false)
		var normalized: int = posmod(minute, 1440)
		var night: bool = normalized < PROFILE.day_start or normalized >= PROFILE.night_start
		assert_eq(result.ambience, PROFILE.night_track if night else PROFILE.day_by_zone.farm)
		assert_eq(result.music, &"" if night else (PROFILE.morning_music if normalized < PROFILE.afternoon_start else PROFILE.afternoon_music))
		assert_eq(AmbientAudioContext.select(PROFILE, Vector2i(-14, 6), minute, true).ambience, PROFILE.rain_track)
	assert_eq(AmbientAudioContext.select(null, Vector2i.ZERO, 480, false), {})
	var bad: AmbientAudioProfile = PROFILE.duplicate(true) as AmbientAudioProfile
	bad.fade_seconds = 0.0
	assert_eq(AmbientAudioContext.select(bad, Vector2i.ZERO, 480, false), {})
	assert_eq(PROFILE.tracks, rows)
	assert_eq(_owners(), before)

func test_actual_main_zones_day_night_rain_and_shared_imports_are_readonly() -> void:
	assert_false(_snapshot().enabled)
	assert_eq(_playing(_snapshot()).size(), 0)
	await _activate()
	for row: Dictionary in [{"cell": Vector2i(1, 1), "zone": &"farm"}, {"cell": Vector2i(-12, -12), "zone": &"forest"}, {"cell": Vector2i(-5, 6), "zone": &"village"}, {"cell": Vector2i(-14, 6), "zone": &"water"}, {"cell": Vector2i(15, 9), "zone": &"water"}]:
		_main.world.player.move_to_cell(row.cell)
		var before: Dictionary = _owners()
		await _settle()
		var snapshot: Dictionary = _snapshot()
		assert_true(snapshot.enabled)
		assert_eq(snapshot.zone, row.zone)
		assert_eq(snapshot.selected.ambience, PROFILE.day_by_zone[String(row.zone)])
		assert_eq(snapshot.selected.music, PROFILE.morning_music)
		assert_eq(snapshot.players.size(), 4)
		assert_eq(_owners(), before)
		print("[ambient_runtime] zone=", JSON.stringify(snapshot))
	GameClock.set_time(13, 0)
	await _settle()
	assert_eq(_snapshot().selected.music, PROFILE.afternoon_music)
	GameClock.set_time(21, 0)
	await _settle()
	assert_eq(_snapshot().selected.ambience, PROFILE.night_track)
	assert_eq(_snapshot().selected.music, &"")
	_main.weather_state.call("force_weather", &"rain")
	await _settle()
	assert_eq(_snapshot().selected.ambience, PROFILE.rain_track)
	_main.weather_state.call("force_weather", &"sunny")
	GameClock.set_time(8, 0)
	await _settle()
	assert_eq(_snapshot().selected.ambience, PROFILE.day_by_zone.water)
	for row: Dictionary in _playing(_snapshot()):
		assert_eq(row.loop_mode, AudioStreamWAV.LOOP_FORWARD)
	for row: Dictionary in PROFILE.tracks:
		assert_eq((load(row.path) as AudioStreamWAV).loop_mode, AudioStreamWAV.LOOP_DISABLED)
	var detached: Dictionary = _snapshot()
	detached.selected.music = &"fake"
	detached.players.clear()
	assert_eq(_snapshot().players.size(), 4)
	assert_eq(_snapshot().selected.music, PROFILE.morning_music)

func test_native_fade_completion_rapid_changes_and_same_context_keep_four_slots() -> void:
	await _activate()
	await get_tree().create_timer(PROFILE.fade_seconds + 0.1).timeout
	var ids: Array[int] = _ids()
	assert_eq(_playing(_snapshot()).size(), 2)
	assert_true(_main.ambient_audio_flow.configure(_main))
	assert_eq(_ids(), ids)
	var owner_id: int = _main.ambient_audio_flow.get_instance_id()
	assert_eq(_connections(GameClock.time_changed, owner_id), 1)
	assert_eq(_connections(Events.weather_changed, owner_id), 1)
	var music: AudioStreamPlayer
	for child: Node in _main.ambient_audio_flow.get_children():
		if child is AudioStreamPlayer and (child as AudioStreamPlayer).playing and (child as AudioStreamPlayer).bus == &"Music":
			music = child as AudioStreamPlayer
	assert_not_null(music)
	var stream_id: int = music.stream.get_instance_id()
	var position: float = music.get_playback_position()
	GameClock.set_time(8, 5)
	GameClock.set_time(8, 10)
	await _settle()
	assert_eq(music.stream.get_instance_id(), stream_id)
	assert_gte(music.get_playback_position(), position)
	_main.world.player.move_to_cell(Vector2i(-14, 6))
	await _settle()
	var ambience: Array[Dictionary] = []
	for row: Dictionary in _playing(_snapshot()):
		if row.bus == &"Ambience":
			ambience.append(row)
	assert_eq(ambience.size(), 2, "Outgoing and incoming native streams overlap during the fade")
	for row: Dictionary in ambience:
		assert_gt(row.gain, 0.0)
		assert_lt(row.gain, float(PROFILE.get_track(row.id).gain))
	print("[ambient_runtime] crossfade=", JSON.stringify(_snapshot()))
	for cell: Vector2i in [Vector2i(-14, 6), Vector2i(-5, 6), Vector2i(-12, -12), Vector2i(-14, 6), Vector2i(1, 1)]:
		_main.world.player.move_to_cell(cell)
		await _settle()
		assert_eq(_ids(), ids)
		assert_lte(_playing(_snapshot()).size(), 4)
	await get_tree().create_timer(PROFILE.fade_seconds + 0.1).timeout
	assert_eq(_playing(_snapshot()).size(), 2)
	for row: Dictionary in _snapshot().players:
		if row.playing:
			assert_almost_eq(row.gain, float(PROFILE.get_track(row.id).gain), 0.000001)
		else:
			assert_eq(row.id, &"")
			assert_eq(row.gain, 0.0)

func test_native_pause_apply_failed_draft_and_exact_mute_reach_actual_loop_buses() -> void:
	await _activate()
	await get_tree().create_timer(PROFILE.fade_seconds + 0.1).timeout
	_main.pause_menu.open()
	await _settle()
	var settings: LifeSettingsPanel = _main.pause_menu.shell.settings
	var presses: Array[int] = [0]
	settings.applied.connect(func() -> void: presses[0] += 1)
	settings.audio.set_values(0.25, 0.5)
	assert_eq(_gain(&"Music"), 1.0)
	assert_eq(_gain(&"Ambience"), 1.0)
	assert_eq(_playing(_snapshot()).size(), 2)
	await _click(settings.apply_button)
	assert_eq(presses[0], 1)
	assert_almost_eq(_gain(&"Music"), 0.25, 0.000001)
	assert_almost_eq(_gain(&"Ambience"), 0.5, 0.000001)
	for row: Dictionary in _playing(_snapshot()):
		assert_almost_eq(row.gain, float(PROFILE.get_track(row.id).gain), 0.000001, "Accepted gain is applied only at the bus")
	Settings.file_store = RejectingStore.new()
	settings.audio.set_values(0.8, 0.9)
	await _click(settings.apply_button)
	assert_eq(presses[0], 2)
	assert_eq(settings.status.text, tr("PREFERENCES_APPLY_FAILED"))
	assert_almost_eq(_gain(&"Music"), 0.25, 0.000001)
	assert_almost_eq(_gain(&"Ambience"), 0.5, 0.000001)
	Settings.file_store = _store
	_main.pause_menu.close()
	_main.pause_menu.open()
	await _settle()
	assert_almost_eq(settings.audio.music.value, 0.25, 0.000001)
	settings.audio.set_values(0.0, 0.0)
	await _click(settings.apply_button)
	assert_eq(presses[0], 3)
	assert_eq(_gain(&"Music"), 0.0)
	assert_eq(_gain(&"Ambience"), 0.0)
	for row: Dictionary in _playing(_snapshot()):
		assert_eq(float(row.gain) * _gain(row.bus), 0.0)
	_main.audio_service.play_sound(&"hoe")
	var effect: AudioStreamPlayer = _main.audio_service.get_child(0) as AudioStreamPlayer
	assert_eq(effect.volume_linear, 0.0)
	assert_eq(effect.bus, &"SFX")
	print("[ambient_runtime] muted_buses=", JSON.stringify({"music": _gain(&"Music"), "ambience": _gain(&"Ambience"), "players": _snapshot()}))
	settings.audio.set_values(1.0, 1.0)
	await _click(settings.apply_button)
	assert_eq(presses[0], 4)
	assert_eq(_gain(&"Music"), 1.0)
	assert_eq(_gain(&"Ambience"), 1.0)
	assert_eq(_playing(_snapshot()).size(), 2)
	assert_true(GameClock.paused)

func test_native_title_continue_load_newgame_reuse_slots_and_preserve_saved_owners() -> void:
	_main.call("_start_new_game", "Mai", "Vườn Mùa")
	GameClock.paused = true
	await _settle()
	var ids: Array[int] = _ids()
	assert_true(_snapshot().enabled)
	assert_true(_main.call("_save_game"))
	var saved: Dictionary = _owners()
	assert_true(_main.call("_return_to_start_menu"))
	await _settle()
	assert_false(_snapshot().enabled)
	assert_eq(_playing(_snapshot()).size(), 0)
	assert_eq(_ids(), ids)
	await _click(_main.start_menu.screen.actions.continue_button)
	GameClock.paused = true
	await _settle()
	assert_true(_snapshot().enabled)
	assert_eq(_ids(), ids)
	assert_eq(_owners(), saved)
	assert_true(_main.call("_load_game"))
	GameClock.paused = true
	await _settle()
	assert_eq(_ids(), ids)
	assert_eq(_owners(), saved)
	_main.call("_start_new_game", "Lan", "Vườn nắng")
	GameClock.paused = true
	var fresh: Dictionary = _owners()
	await _settle()
	assert_eq(_ids(), ids)
	assert_eq(_owners(), fresh)
	assert_eq(_playing(_snapshot()).size(), 2)
	assert_eq(SaveService.load_game(1).meta.save_version, 12)

func test_invalid_profile_and_freed_running_flow_have_no_receivers_or_node_leaks() -> void:
	var invalid: LifeAmbientAudioFlow = LifeAmbientAudioFlow.new()
	_main.add_child(invalid)
	var bad: AmbientAudioProfile = PROFILE.duplicate(true) as AmbientAudioProfile
	bad.fade_seconds = 0.0
	assert_false(invalid.configure(_main, bad))
	assert_eq(invalid.get_child_count(), 0)
	assert_false(invalid.get_playback_snapshot().enabled)
	invalid.free()
	await _activate()
	assert_eq(_playing(_snapshot()).size(), 2)
	var id: int = _main.ambient_audio_flow.get_instance_id()
	var player_ids: Array[int] = _ids()
	_main.ambient_audio_flow.free()
	assert_eq(_connections(GameClock.time_changed, id), 0)
	assert_eq(_connections(Events.weather_changed, id), 0)
	for player_id: int in player_ids:
		assert_false(is_instance_id_valid(player_id))
	GameClock.set_time(14, 0)
	_main.weather_state.call("force_weather", &"rain")
	var before: Dictionary = _owners()
	await _settle()
	assert_eq(_owners(), before)
