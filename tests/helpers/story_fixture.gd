## StoryFixture - actual Main and isolated save families, no fake event producers.
extends "res://tests/helpers/dog_fixture.gd"
func core_owners() -> Dictionary:
	var result: Dictionary = super.owners()
	result["dog"] = main.dog_state.serialize()
	return result
func owners() -> Dictionary:
	var result: Dictionary = core_owners()
	result["story"] = main.story_state.serialize()
	return result
