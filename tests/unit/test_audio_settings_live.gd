extends GutTest

class RejectingStore extends SettingsFileStore:
	func persist(_path: String, _text: String) -> Dictionary:
		return {"ok": false, "error": &"injected_failure"}

var _service: Node
var _existed: bool
var _bytes: PackedByteArray
var _store: SettingsFileStore
var _locale: String

func before_each() -> void:
	_existed = FileAccess.file_exists(Settings.SETTINGS_PATH)
	_bytes = FileAccess.get_file_as_bytes(Settings.SETTINGS_PATH) if _existed else PackedByteArray()
	_store = Settings.file_store
	_locale = TranslationServer.get_locale()
	_service = preload("res://scripts/core/audio_service.gd").new()
	add_child(_service)

func after_each() -> void:
	if is_instance_valid(_service):
		_service.free()
	Settings.file_store = _store
	if _existed:
		var file: FileAccess = FileAccess.open(Settings.SETTINGS_PATH, FileAccess.WRITE)
		file.store_buffer(_bytes)
		file.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Settings.SETTINGS_PATH))
	Settings.call("_ready")
	TranslationServer.set_locale(_locale)

func _players() -> Array[AudioStreamPlayer]:
	var result: Array[AudioStreamPlayer] = []
	for child: Node in _service.get_children():
		if child is AudioStreamPlayer:
			result.append(child as AudioStreamPlayer)
	return result

func _connections(id: int) -> int:
	var count: int = 0
	for connection: Dictionary in Settings.preferences_changed.get_connections():
		var callback: Callable = connection.callable
		var owner: Object = callback.get_object()
		if is_instance_valid(owner) and owner.get_instance_id() == id:
			count += 1
	return count

func test_all_existing_effects_and_current_players_follow_accepted_gain_including_exact_zero() -> void:
	assert_true(Settings.apply_preferences({"effects_volume": 1.0}).ok)
	for id: StringName in [&"hoe", &"seed", &"water", &"harvest"]:
		_service.play_sound(id)
	assert_eq(_players().size(), 4)
	for gain: float in [0.5, 0.0, 1.0]:
		assert_true(Settings.apply_preferences({"effects_volume": gain}).ok)
		for player: AudioStreamPlayer in _players():
			assert_eq(player.volume_linear, gain, "Actual pinned-engine gain must reach exact mute")
		_service.play_sound(&"water")
		assert_eq(_players().back().volume_linear, gain)

func test_failed_apply_draft_and_mutated_signal_snapshot_never_override_accepted_volume() -> void:
	assert_true(Settings.apply_preferences({"effects_volume": 0.5}).ok)
	_service.play_sound(&"water")
	var player: AudioStreamPlayer = _players()[0]
	var draft: Dictionary = {"effects_volume": 0.8}
	assert_eq(player.volume_linear, 0.5, "Editing a draft alone changes no sound")
	Settings.file_store = RejectingStore.new()
	assert_false(Settings.apply_preferences(draft).ok)
	assert_eq(Settings.get_effects_volume(), 0.5)
	assert_eq(player.volume_linear, 0.5)
	Settings.file_store = _store
	# The receiver reads accepted values even if an external listener passes a modified snapshot.
	_service.call("_preferences_changed", {"effects_volume": 0.0})
	assert_eq(player.volume_linear, 0.5)
	_service.play_sound(&"seed")
	assert_eq(_players().back().volume_linear, 0.5)

func test_ready_is_idempotent_finished_players_and_freed_listener_do_not_leak() -> void:
	var id: int = _service.get_instance_id()
	_service.call("_ready")
	_service.call("_ready")
	assert_eq(_connections(id), 1)
	_service.play_sound(&"hoe")
	var player: AudioStreamPlayer = _players()[0]
	player.finished.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_true(_players().is_empty())
	_service.free()
	assert_eq(_connections(id), 0)
