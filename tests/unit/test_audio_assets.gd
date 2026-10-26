extends GutTest

const SOUND_IDS: Array[StringName] = [&"hoe", &"seed", &"water", &"harvest"]

func test_original_farming_effects_are_importable_and_playable() -> void:
	var audio: Node = preload("res://scripts/core/audio_service.gd").new()
	get_tree().root.add_child(audio)
	for sound_id: StringName in SOUND_IDS:
		var path: String = audio.get_sound_path(sound_id)
		assert_eq(path, "res://assets/audio/%s.wav" % sound_id)
		assert_true(ResourceLoader.exists(path), "Effect asset exists: %s" % sound_id)
		assert_true(load(path) is AudioStream, "Effect imports as AudioStream: %s" % sound_id)
	audio.play_sound(&"hoe")
	assert_eq(audio.get_child_count(), 1, "Existing tool effect call creates an audio player")
	audio.queue_free()
