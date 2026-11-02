extends GutTest

const REQUIRED_ACTIONS: Array[StringName] = [
	&"move_up", &"move_down", &"move_left", &"move_right", &"sprint",
	&"interact", &"use_tool", &"cancel", &"tool_next", &"tool_prev",
	&"hotbar_1", &"hotbar_2", &"hotbar_3", &"hotbar_4", &"hotbar_5",
	&"hotbar_6", &"hotbar_7", &"hotbar_8", &"hotbar_9", &"open_inventory",
	&"open_build", &"open_journal", &"rotate_cw", &"rotate_ccw",
	&"camera_zoom_in", &"camera_zoom_out", &"pause", &"toggle_debug",
	&"toggle_debug_menu"
]

const REQUIRED_LAYERS: Array[String] = [
	"world_static", "player", "interactable", "npc",
	"trigger", "water", "occluder_fade", "placement"
]

func test_required_input_actions_exist() -> void:
	for action: StringName in REQUIRED_ACTIONS:
		assert_true(InputMap.has_action(action), "Missing input action: %s" % action)

func test_required_physics_layer_names_exist() -> void:
	for index: int in range(REQUIRED_LAYERS.size()):
		assert_eq(ProjectSettings.get_setting("layer_names/2d_physics/layer_%d" % (index + 1)), REQUIRED_LAYERS[index])
