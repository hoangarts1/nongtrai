extends GutTest

const CATALOG_PATH: String = "res://data/art/characters/chibi_character_catalog.tres"
const PALETTE_PATH: String = "res://data/art/palette/chibi_valley.tres"
const BUILDER: Script = preload("res://tools/art/chibi/chibi_character_builder.gd")
const AUDIT: Script = preload("res://tools/art/chibi/chibi_mesh_audit.gd")
const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const SAVE_SLOT: int = 97

const MODEL_PATHS: Array[String] = [
	"res://assets/generated/models/characters/chr_player_base.tscn",
	"res://assets/generated/models/characters/chr_an.tscn",
	"res://assets/generated/models/characters/chr_lam.tscn",
	"res://assets/generated/models/characters/chr_linh.tscn",
	"res://assets/generated/models/characters/chr_minh.tscn",
	"res://assets/generated/models/characters/pet_dog.tscn"
]

func test_character_catalog_has_six_safe_player_options_and_profiles() -> void:
	var catalog: Resource = load(CATALOG_PATH) as Resource
	assert_not_null(catalog)
	assert_true(catalog.has_method("validate"))
	assert_eq((catalog.call("validate") as PackedStringArray).size(), 0)
	var choices: Dictionary = catalog.call("get_player_customization") as Dictionary
	assert_eq((choices["hair_styles"] as PackedStringArray).size(), 6)
	assert_eq((choices["skin_tones"] as Array[Color]).size(), 6)
	assert_eq((choices["hair_colors"] as Array[Color]).size(), 6)
	assert_eq((choices["outfit_colors"] as Array[Color]).size(), 6)
	var normalized: Dictionary = catalog.call("normalize_player_customization", {
		"hair_style": "unknown_style",
		"skin_index": 999,
		"hair_color_index": -3,
		"outfit_color_index": 2
	}) as Dictionary
	assert_eq(normalized["hair_style"], "round_bob")
	assert_eq(normalized["skin_index"], 5)
	assert_eq(normalized["hair_color_index"], 0)
	assert_eq(normalized["outfit_color_index"], 2)
	var resolved: Dictionary = catalog.call("resolve_player", normalized) as Dictionary
	assert_true(resolved["skin_color"] is Color)
	assert_true(resolved["hair_color"] is Color)
	assert_true(resolved["outfit_color"] is Color)
	for npc_id: StringName in [&"an", &"lam", &"linh", &"minh"]:
		var appearance: Resource = catalog.call("get_npc_appearance", npc_id) as Resource
		assert_not_null(appearance, "NPC appearance exists: %s" % npc_id)
		assert_true(appearance.has_method("to_builder_dictionary"))

func test_generated_character_models_are_grounded_safe_and_under_budget() -> void:
	var palette: Resource = load(PALETTE_PATH) as Resource
	var budget: int = palette.get_triangle_budget(&"character")
	for path: String in MODEL_PATHS:
		assert_true(ResourceLoader.exists(path), "Generated character scene exists: %s" % path)
		var scene: PackedScene = load(path) as PackedScene
		assert_not_null(scene)
		var model: Node3D = scene.instantiate() as Node3D
		add_child(model)
		assert_eq(AUDIT.validate_model(model, budget).size(), 0, "Model audit: %s" % path)
		assert_true(AUDIT.triangle_count(model) > 0)
		assert_true(AUDIT.triangle_count(model) <= budget)
		var rig: Node3D = model.get_node_or_null("Rig") as Node3D
		assert_not_null(rig)
		for pivot_name: StringName in [&"Body", &"Head", &"Accessory"]:
			assert_not_null(rig.get_node_or_null(String(pivot_name)), "Required pivot: %s" % pivot_name)
		if not path.ends_with("pet_dog.tscn"):
			for limb_name: StringName in [&"ArmLeft", &"ArmRight", &"LegLeft", &"LegRight"]:
				assert_not_null(rig.get_node_or_null(String(limb_name)), "Required limb pivot: %s" % limb_name)
			assert_not_null(rig.get_node_or_null("Head/Face"))
		var bounds: AABB = AUDIT.combined_bounds(model)
		assert_gte(bounds.position.y, -0.001, "Ground pivot: %s" % path)
		model.free()

func test_player_model_head_ratio_and_runtime_customization_match_art_data() -> void:
	var catalog: Resource = load(CATALOG_PATH) as Resource
	var profile: Dictionary = catalog.call("resolve_player", {
		"hair_style": "twin_puffs",
		"skin_index": 4,
		"hair_color_index": 5,
		"outfit_color_index": 3
	}) as Dictionary
	var model: Node3D = BUILDER.build_character(profile)
	add_child(model)
	var palette: Resource = load(PALETTE_PATH) as Resource
	assert_eq(AUDIT.validate_model(model, palette.get_triangle_budget(&"character")).size(), 0)
	var all_bounds: AABB = AUDIT.combined_bounds(model)
	var head: Node3D = model.get_node("Rig/Head") as Node3D
	var head_bounds: AABB = AUDIT.combined_bounds(head)
	var ratio: float = head_bounds.size.y / all_bounds.size.y
	assert_true(ratio >= float(palette.get("head_height_ratio_min")), "Head ratio is %.3f" % ratio)
	assert_true(ratio <= float(palette.get("head_height_ratio_max")), "Head ratio is %.3f" % ratio)
	assert_eq(StringName(model.get_meta("appearance_id")), &"player_default")
	model.free()

func test_runtime_avatar_has_pivot_animation_face_and_emotion_contract() -> void:
	var catalog: Resource = load(CATALOG_PATH) as Resource
	var profile: Dictionary = catalog.call("resolve_player", {
		"hair_style": "twin_puffs",
		"skin_index": 3,
		"hair_color_index": 4,
		"outfit_color_index": 5
	}) as Dictionary
	var avatar: ChibiAvatar = ChibiAvatar.new()
	add_child(avatar)
	avatar.configure_profile(profile)
	await get_tree().process_frame
	var model: Node3D = avatar.get_model()
	assert_not_null(model)
	for path: String in ["Rig", "Rig/Body", "Rig/Head", "Rig/ArmLeft", "Rig/ArmRight", "Rig/LegLeft", "Rig/LegRight", "Rig/Accessory", "Rig/Head/Face"]:
		assert_not_null(model.get_node_or_null(path), "Runtime pivot exists: %s" % path)
	var animation_player: AnimationPlayer = avatar.get_animation_player()
	assert_not_null(animation_player)
	for animation_id: StringName in [&"Idle", &"Walk", &"Run", &"Tool", &"Sleep", &"Talk"]:
		assert_not_null(animation_player.get_animation(animation_id), "Animation clip exists: %s" % animation_id)
	animation_player.play(&"Walk")
	animation_player.advance(0.28)
	var left_leg: Node3D = model.get_node("Rig/LegLeft") as Node3D
	assert_ne(left_leg.rotation.x, 0.0, "Walk animation moves the leg pivot")
	avatar.set_facing_direction(Vector3(1.0, 0.0, 0.0))
	assert_almost_eq((model.get_node("Rig") as Node3D).rotation.y, PI * 0.5, 0.001, "Facing snaps to one of eight directions")
	for emotion_id: StringName in [&"normal", &"happy", &"surprised", &"sad", &"sleep", &"talk"]:
		assert_true(avatar.set_emotion(emotion_id), "Known emotion is accepted: %s" % emotion_id)
	assert_false(avatar.set_emotion(&"unknown"))
	assert_true(avatar.show_emotion_bubble(&"heart", 0.30))
	assert_true((model.get_node("EmotionBubble") as Node3D).visible)
	avatar.play_tool(&"watering_can")
	assert_eq(animation_player.current_animation, &"Tool")
	assert_not_null(model.get_node_or_null("Rig/ArmRight/ToolProp"))
	avatar.free()

func test_old_profile_falls_back_and_cosmetic_profile_round_trips_without_schema_change() -> void:
	SaveService.delete_save(SAVE_SLOT)
	var catalog: Resource = load(CATALOG_PATH) as Resource
	var default_selection: Dictionary = catalog.call("normalize_player_customization", {}) as Dictionary
	assert_eq(default_selection["hair_style"], "round_bob")
	var selected: Dictionary = catalog.call("normalize_player_customization", {
		"hair_style": "leaf_braid",
		"skin_index": 4,
		"hair_color_index": 2,
		"outfit_color_index": 1
	}) as Dictionary
	assert_true(SaveService.save_game({"profile": {"player_name": "Cũ", "farm_name": "Mùa", "appearance": selected}}, SAVE_SLOT))
	var stored: Dictionary = SaveService.load_game(SAVE_SLOT)
	var stored_selection: Dictionary = stored["profile"]["appearance"] as Dictionary
	assert_eq(stored_selection["hair_style"], selected["hair_style"], "Opaque profile preserves selected hair style")
	for numeric_key: String in ["skin_index", "hair_color_index", "outfit_color_index"]:
		assert_eq(int(stored_selection[numeric_key]), int(selected[numeric_key]), "JSON profile preserves %s" % numeric_key)
	var main: Node = MAIN_SCENE.instantiate()
	add_child(main)
	await get_tree().process_frame
	main.call("_load_payload", {"profile": {"player_name": "Save cũ", "farm_name": "Mùa cũ"}})
	assert_eq(main.profile["appearance"], default_selection, "Older profile gets a deterministic default, not lost progress")
	assert_not_null(main.presentation.get_player_avatar())
	main.free()
	await get_tree().process_frame
	SaveService.delete_save(SAVE_SLOT)

func test_runtime_player_and_existing_npc_anchors_stay_intact_and_dialogue_animates() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	add_child(main)
	await get_tree().process_frame
	main.set("_game_started", true)
	main.start_menu.hide()
	main.tutorial_panel.hide()
	main.world.player.movement_enabled = true
	var avatar: PlaceholderAvatar2D = main.presentation.get_player_avatar()
	assert_not_null(avatar)
	assert_eq(avatar.get_parent(), main.world.player, "Player avatar remains beneath the existing player anchor")
	main.tool_controller.set("_hovered_cell", Vector2i(0, 0))
	main.tool_controller.set("_selected_tool", &"hoe")
	main.tool_controller.call("_use_selected_tool")
	assert_eq(avatar.action_id, &"Tool", "Existing successful tool path triggers only the avatar presentation")
	for npc_id: StringName in [&"minh", &"linh"]:
		var actor: NpcActor = main.npc_system.actors.get(npc_id) as NpcActor
		assert_not_null(actor)
		assert_eq(actor.position, main.world.cell_to_global(main.npc_system.state.cells[npc_id]), "NPC keeps its logical schedule anchor")
		assert_not_null(actor.get_node_or_null("Avatar"))
	main.npc_system.debug_visit()
	await get_tree().process_frame
	main.npc_system.open_dialogue(&"minh")
	var minh: NpcActor = main.npc_system.actors[&"minh"] as NpcActor
	assert_eq(minh.avatar.action_id, &"Talk", "Opening existing dialogue triggers only a view animation")
	assert_eq(minh.avatar.get_emotion(), &"music")
	main.npc_system.close_panels()
	main.free()
	await get_tree().process_frame

func test_new_game_appearance_form_normalizes_all_six_data_backed_choices() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	add_child(main)
	await get_tree().process_frame
	var menu: StartMenu = main.start_menu
	menu.call("_show_new_game_fields")
	var form: VBoxContainer = menu.get("_name_box") as VBoxContainer
	var hair: OptionButton = form.get_node("AppearanceGrid/HairStyle") as OptionButton
	var skin: OptionButton = form.get_node("AppearanceGrid/SkinTone") as OptionButton
	var hair_color: OptionButton = form.get_node("AppearanceGrid/HairColor") as OptionButton
	var outfit: OptionButton = form.get_node("AppearanceGrid/OutfitColor") as OptionButton
	hair.select(5)
	skin.select(5)
	hair_color.select(5)
	outfit.select(5)
	var selection: Dictionary = menu.get_appearance_selection()
	assert_eq(selection["hair_style"], "twin_puffs")
	assert_eq(selection["skin_index"], 5)
	assert_eq(selection["hair_color_index"], 5)
	assert_eq(selection["outfit_color_index"], 5)
	menu.appearance_selected.emit(selection)
	assert_eq(main.get("_pending_appearance"), selection, "Signal keeps legacy two-argument New Game callback compatible")
	main.free()
	await get_tree().process_frame
