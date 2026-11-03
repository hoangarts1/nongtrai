extends GutTest

const SIZES: Array[Vector2i] = [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]
var _viewport: SubViewport
var _main: Node
var _clock: Dictionary
var _paused: bool
var _locale: String

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	SaveService.delete_save(0)
	SaveService.delete_save(1)
	_viewport = SubViewport.new()
	_viewport.size = SIZES[0]
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_start(0)

func after_each() -> void:
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)
	SaveService.delete_save(0)
	SaveService.delete_save(1)

func _start(index: int, long_names: bool = false) -> void:
	var styles: PackedStringArray = LifeCharacterPortrait.CATALOG.player_hair_styles
	_main.set("_pending_appearance",{"hair_style":styles[index],"skin_index":index,"hair_color_index":index,"outfit_color_index":index})
	_main.call("_start_new_game","Mai Thung Lũng Mùa Mai Thung Lũng Mùa" if long_names else "Mai","Vườn Bình Minh và những người bạn trong thung lũng" if long_names else "Vườn Mùa")
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	GameClock.paused = true

func _friendships(kind: String) -> void:
	var social: NpcSocialState = _main.npc_system.state
	var payload: Dictionary = social.serialize()
	for index: int in range(social.content.npcs.size()):
		var npc: NpcData = social.content.npcs[index] as NpcData
		payload.friendship[String(npc.npc_id)] = npc.friendship_max if kind=="max" else (int(npc.friendship_max*index/3.0) if kind=="mixed" else 0)
	social.deserialize(payload)

func test_reference07_both_locales_three_sizes_and_real_friendship_states() -> void:
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in SIZES:
			_viewport.size = dimensions
			for kind: String in ["zero","mixed","max","long"]:
				_start(0,kind=="long")
				_friendships(kind)
				_main.character_flow.open()
				await _settle()
				var sheet: LifeCharacterSheet = _main.character_flow.panel
				var bounds: Rect2 = Rect2(Vector2.ZERO,Vector2(dimensions))
				assert_true(bounds.encloses(sheet.get_global_rect()),"Character fits %s/%s: %s" % [dimensions,kind,sheet.get_global_rect()])
				for region: Control in [sheet.tabs,sheet.identity,sheet.skills,sheet.relationships,sheet.hint]:
					assert_true(sheet.get_global_rect().encloses(region.get_global_rect()),"Region fits: %s %s" % [region.name,region.get_global_rect()])
				assert_false(sheet.identity.get_global_rect().intersects(sheet.skills.get_global_rect()))
				assert_eq(sheet.relationships.cards.get_child_count(),_main.npc_system.state.content.npcs.size())
				assert_true(sheet.find_children("*","ProgressBar",true,false).is_empty(),"No fictional XP or working skill progress")
				for row: LifeCharacterSkill in sheet.skills.rows:
					assert_eq(row.status.text,tr("INV_UNAVAILABLE"))
				for index: int in range(sheet.tabs.buttons.size()):
					assert_eq(sheet.tabs.buttons[index].disabled,index not in [0,1,2])
				_check_npcs(sheet)
				assert_false(_main.world.player.movement_enabled)
				assert_true(GameClock.paused)
				await _capture("%s_%s_%d" % [locale,kind,dimensions.x])

func _check_npcs(sheet: LifeCharacterSheet) -> void:
	for index: int in range(sheet.relationships.cards.get_child_count()):
		var card: LifeCharacterRelationship = sheet.relationships.cards.get_child(index) as LifeCharacterRelationship
		var npc: NpcData = _main.npc_system.state.content.npcs[index] as NpcData
		var value: int = int(_main.npc_system.state.friendship[npc.npc_id])
		assert_eq(card.title.text,tr(String(npc.display_name_key)))
		assert_eq(card.points.text,tr("CHAR_FRIENDSHIP") % [value,npc.friendship_max])
		assert_eq(card.hearts.filled,int(floor(value*5.0/npc.friendship_max)))
		var actual: PlaceholderAvatar2D = _main.npc_system.actors[npc.npc_id].avatar
		assert_eq(card.portrait.avatar.outfit,actual.outfit)
		assert_eq(card.portrait.avatar.skin,actual.skin)
		assert_eq(card.portrait.avatar.hair,actual.hair)
		assert_eq(card.portrait.avatar.get_hair_style(),actual.get_hair_style())

func test_all_six_saved_player_choices_match_actual_avatar_and_refresh_after_new_game() -> void:
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for index: int in range(LifeCharacterPortrait.CATALOG.player_hair_styles.size()):
			_start(index)
			assert_false(_main.character_flow.panel.visible,"New game closes stale profile")
			_main.character_flow.open()
			await _settle()
			var avatar: PlaceholderAvatar2D = _main.character_flow.panel.identity.portrait.avatar
			var actual: PlaceholderAvatar2D = _main.presentation.get_player_avatar()
			assert_eq(avatar.get_hair_style(),actual.get_hair_style())
			assert_eq(avatar.skin,actual.skin)
			assert_eq(avatar.hair,actual.hair)
			assert_eq(avatar.outfit,actual.outfit)
			await _capture("%s_choice_%d" % [locale,index])

func test_native_relationship_scroll_and_empty_legacy_display_are_read_only() -> void:
	_main.character_flow.open()
	await _settle()
	var sheet: LifeCharacterSheet = _main.character_flow.panel
	var before: Dictionary = _main.npc_system.state.serialize()
	# The current world has two NPCs, which fit. Stress overflow with repeated
	# real display rows in this isolated view, without adding NPCs to the owner.
	var overflow: Dictionary = CharacterSnapshot.capture(_main)
	var repeated: Array[Dictionary] = []
	for index: int in range(8):
		repeated.append(overflow.npcs[index%overflow.npcs.size()].duplicate(true))
	overflow.npcs = repeated
	CharacterPresenter.render(sheet,overflow)
	await _settle()
	var point: Vector2 = sheet.relationships.scroll.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	_viewport.push_input(motion,true)
	for index: int in range(8):
		var wheel: InputEventMouseButton = InputEventMouseButton.new()
		wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
		wheel.pressed = true
		wheel.position = point
		wheel.global_position = point
		_viewport.push_input(wheel,true)
		await get_tree().process_frame
	assert_gt(sheet.relationships.scroll.scroll_vertical,0,"Native wheel exposes remaining real NPC cards: scroll=%s cards=%s" % [sheet.relationships.scroll.get_global_rect(),sheet.relationships.cards.get_global_rect()])
	assert_eq(_main.npc_system.state.serialize(),before)
	var snapshot: Dictionary = CharacterSnapshot.capture(_main)
	snapshot.player_name = ""
	snapshot.farm_name = ""
	snapshot.npcs = []
	CharacterPresenter.render(sheet,snapshot)
	await _settle()
	assert_eq(sheet.identity.player_name.text,tr("UI_DEFAULT_PLAYER"))
	assert_eq(sheet.identity.farm_name.text,tr("UI_DEFAULT_FARM"))
	assert_true(sheet.relationships.empty.visible)
	assert_eq(sheet.relationships.cards.get_child_count(),0)
	assert_eq(_main.npc_system.state.serialize(),before)
	var paths: Array[String] = ["res://localization/strings_vi.csv","res://localization/strings_en.csv"]
	var keys: PackedStringArray = ["CHAR_PROFILE_NOTE","CHAR_SKILLS","CHAR_SKILL_GARDEN","CHAR_SKILL_WATER","CHAR_SKILL_HARVEST","CHAR_SKILL_FISH","CHAR_SKILL_TRADE","CHAR_SKILLS_NOTE","CHAR_RELATIONSHIPS","CHAR_FRIENDSHIP","CHAR_NO_NPCS","CHAR_KEYS"]
	assert_true(DataValidator.validate_translation_keys(paths,keys).is_empty())

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func _capture(id: String) -> void:
	if DisplayServer.get_name()!="headless":
		await RenderingServer.frame_post_draw
		assert_eq(_viewport.get_texture().get_image().save_png("user://iso10_%s.png" % id),OK)
