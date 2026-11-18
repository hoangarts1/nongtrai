extends GutTest

class RejectingStore extends SettingsFileStore:
	func persist(_path: String, _text: String) -> Dictionary:
		return {"ok": false, "error": &"injected_failure"}

var _layout: AudioBusLayout
var _service: Node
var _existed: bool
var _bytes: PackedByteArray
var _store: SettingsFileStore
var _locale: String

func before_each() -> void:
	_layout = AudioServer.generate_bus_layout()
	_store = Settings.file_store
	_locale = TranslationServer.get_locale()
	_existed = FileAccess.file_exists(Settings.SETTINGS_PATH)
	_bytes = FileAccess.get_file_as_bytes(Settings.SETTINGS_PATH) if _existed else PackedByteArray()
	AudioServer.set_bus_layout(load("res://default_bus_layout.tres") as AudioBusLayout)
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
	AudioServer.set_bus_layout(_layout)

func _gain(name: StringName) -> float:
	return AudioServer.get_bus_volume_linear(AudioServer.get_bus_index(name))

func test_shipped_layout_has_five_native_routes_and_master_is_not_changed() -> void:
	assert_eq(AudioServer.bus_count, 5)
	assert_true(LifeAudioBusRouter.is_layout_ready())
	assert_eq(AudioServer.get_bus_name(0), &"Master")
	for name: StringName in [&"Music", &"SFX", &"Ambience", &"UI"]:
		assert_eq(AudioServer.get_bus_send(AudioServer.get_bus_index(name)), &"Master")
	AudioServer.set_bus_volume_linear(0, 0.75)
	assert_true(LifeAudioBusRouter.new().apply_accepted())
	assert_almost_eq(_gain(&"Master"), 0.75, 0.000001)
	assert_eq(_service.get_child_count(), 0, "Router adds no Node child or loop in this milestone")

func test_accepted_gains_mute_unmute_active_and_new_sfx_exactly_once() -> void:
	assert_true(Settings.apply_preferences({"music_volume": 1.0, "effects_volume": 1.0}).ok)
	_service.play_sound(&"hoe")
	var original: AudioStreamPlayer = _service.get_child(0) as AudioStreamPlayer
	for gain: float in [0.5, 0.0, 1.0]:
		assert_true(Settings.apply_preferences({"music_volume": gain, "effects_volume": gain}).ok)
		assert_almost_eq(_gain(&"Music"), gain, 0.000001)
		assert_almost_eq(_gain(&"Ambience"), gain, 0.000001)
		assert_almost_eq(_gain(&"UI"), gain, 0.000001)
		assert_eq(_gain(&"SFX"), 1.0)
		assert_eq(original.bus, &"SFX")
		assert_eq(original.volume_linear, gain)
		assert_eq(original.volume_linear * _gain(&"SFX"), gain, "Gain is not squared")
		_service.play_sound(&"water")
		var newest: AudioStreamPlayer = _service.get_child(_service.get_child_count() - 1) as AudioStreamPlayer
		assert_eq(newest.bus, &"SFX")
		assert_eq(newest.volume_linear * _gain(&"SFX"), gain)
		if gain == 0.0:
			assert_eq(_gain(&"Music"), 0.0)
			assert_eq(_gain(&"Ambience"), 0.0)

func test_draft_failed_apply_and_spoofed_event_do_not_publish_bus_gains() -> void:
	assert_true(Settings.apply_preferences({"music_volume": 0.25, "effects_volume": 0.5}).ok)
	var draft: Dictionary = {"music_volume": 0.8, "effects_volume": 0.9}
	assert_almost_eq(_gain(&"Music"), 0.25, 0.000001)
	Settings.file_store = RejectingStore.new()
	assert_false(Settings.apply_preferences(draft).ok)
	_service.call("_preferences_changed", {"music_volume": 0.0, "effects_volume": 0.0})
	assert_almost_eq(_gain(&"Music"), 0.25, 0.000001)
	assert_almost_eq(_gain(&"Ambience"), 0.5, 0.000001)
	assert_almost_eq(_gain(&"UI"), 0.5, 0.000001)
	assert_eq(_gain(&"SFX"), 1.0)

func test_invalid_layout_fails_without_partial_write_and_receiver_is_freed() -> void:
	var wrong_route: AudioBusLayout = (load("res://default_bus_layout.tres") as AudioBusLayout).duplicate() as AudioBusLayout
	wrong_route.set("bus/4/send", &"Music")
	AudioServer.set_bus_layout(wrong_route)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"Music"), 0.6)
	assert_false(LifeAudioBusRouter.is_layout_ready())
	assert_false(LifeAudioBusRouter.new().apply_accepted())
	assert_almost_eq(_gain(&"Music"), 0.6, 0.000001, "A bad later route prevents earlier bus gain writes")
	AudioServer.set_bus_layout(AudioBusLayout.new())
	AudioServer.set_bus_volume_linear(0, 0.7)
	assert_false(LifeAudioBusRouter.is_layout_ready())
	assert_false(LifeAudioBusRouter.new().apply_accepted())
	assert_almost_eq(_gain(&"Master"), 0.7, 0.000001)
	var id: int = _service.get_instance_id()
	_service.call("_ready")
	var listeners: int = 0
	for connection: Dictionary in Settings.preferences_changed.get_connections():
		var owner: Object = (connection.callable as Callable).get_object()
		if is_instance_valid(owner) and owner.get_instance_id() == id:
			listeners += 1
	assert_eq(listeners, 1)
	_service.free()
	for connection: Dictionary in Settings.preferences_changed.get_connections():
		var owner: Object = (connection.callable as Callable).get_object()
		assert_true(not is_instance_valid(owner) or owner.get_instance_id() != id)
