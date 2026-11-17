extends GutTest

var _main: Node
var _viewport: SubViewport
var _clock: Dictionary
var _paused: bool
var _locale: String
var _preference_locale: String
var _start_count: int = 0
var _appearance_count: int = 0
var _last_appearance: Dictionary = {}
var _reenter: bool = false

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	_preference_locale = Settings.get_locale()
	_start_count = 0
	_appearance_count = 0
	_last_appearance = {}
	_reenter = false
	SaveService.delete_save(0)
	SaveService.delete_save(1)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152,648)
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_main.start_menu.call("_show_new_game_fields")

func after_each() -> void:
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	Settings.set_locale(_preference_locale)
	TranslationServer.set_locale(_locale)
	SaveService.delete_save(0)
	SaveService.delete_save(1)

func test_all_native_choices_update_preview_only_and_match_catalogue() -> void:
	await _settle()
	var form: LifeTitleProfileForm = _main.start_menu.screen.profile
	var bag: Dictionary = _main.inventory.serialize()
	var farm: Dictionary = _main.farm_state.serialize()
	var money: Dictionary = _main.wallet.serialize()
	var pending: Dictionary = _main.get("_pending_appearance").duplicate(true)
	var rows: Array[LifeProfileChoiceRow] = [form.hair_style,form.skin_tone,form.hair_color,form.outfit_color]
	for row: LifeProfileChoiceRow in rows:
		assert_eq(row.item_count,6)
		for index: int in range(row.item_count):
			await _click(row.buttons[index])
			assert_eq(row.selected,index)
			assert_true(row.buttons[index].button_pressed)
			var selected: Dictionary = form.get_selection()
			var resolved: Dictionary = LifeProfileChoices.CATALOG.call("resolve_player",selected)
			assert_eq(form.preview.avatar.get_hair_style(),StringName(selected.hair_style))
			assert_eq(form.preview.avatar.skin,resolved.skin_color)
			assert_eq(form.preview.avatar.hair,resolved.hair_color)
			assert_eq(form.preview.avatar.outfit,resolved.outfit_color)
	assert_eq(_main.inventory.serialize(),bag)
	assert_eq(_main.farm_state.serialize(),farm)
	assert_eq(_main.wallet.serialize(),money)
	assert_eq(_main.get("_pending_appearance"),pending,"Draft does not emit a game appearance request")
	assert_true(SaveService.load_latest().is_empty())
	assert_false(bool(_main.get("_game_started")))
	assert_false(_main.world.player.movement_enabled)

func test_arrows_wrap_hair_and_native_name_typing_keyboard_focus_stays_in_form() -> void:
	await _settle()
	var form: LifeTitleProfileForm = _main.start_menu.screen.profile
	await _click(form.preview.previous_button)
	assert_eq(form.hair_style.selected,5)
	await _click(form.preview.next_button)
	assert_eq(form.hair_style.selected,0)
	form.skin_tone.buttons[5].grab_focus()
	form.fields_scroll.ensure_control_visible(form.skin_tone.buttons[5])
	await _key(KEY_SPACE)
	assert_eq(form.skin_tone.selected,5)
	await _click(form.player_name)
	await _key(KEY_B,98)
	assert_eq(form.player_name.text,"b")
	assert_eq(form.preview.player_caption.text,"b","Live native typing refreshes the caption")
	assert_false(_main.inventory_panel.visible)
	await _key(KEY_TAB)
	assert_true(_main.start_menu.visible)
	await _key(KEY_ESCAPE)
	assert_eq(_main.start_menu.screen.mode,LifeTitleScreen.Mode.TITLE)
	_main.start_menu.call("_show_new_game_fields")
	assert_eq(form.player_name.text,"b")
	assert_eq(form.skin_tone.selected,5)

func test_locale_back_reopen_preserve_drafts_and_safe_normalization() -> void:
	var form: LifeTitleProfileForm = _main.start_menu.screen.profile
	form.player_name.text = "Ẩn ệ ữ ợ"
	form.farm_name.text = "Vườn Nhỏ"
	form.hair_style.select(5)
	form.skin_tone.select(4)
	var selection: Dictionary = form.get_selection()
	Settings.set_locale("en")
	assert_eq(form.player_name.text,"Ẩn ệ ữ ợ")
	assert_eq(form.farm_name.text,"Vườn Nhỏ")
	assert_eq(form.get_selection(),selection)
	assert_eq(form.confirm_button.text,tr("PROFILE_START"))
	assert_eq(form.hair_style.buttons[0].text,tr("UI_APPEARANCE_HAIR_ROUND_BOB"))
	_main.start_menu.handle_back()
	_main.start_menu.call("_show_new_game_fields")
	assert_eq(form.get_selection(),selection)
	assert_eq(form.preview.player_caption.text,form.player_name.text)
	form.hair_style.select(999)
	form.skin_tone.select(-20)
	assert_eq(form.hair_style.selected,5)
	assert_eq(form.skin_tone.selected,0)
	var paths: Array[String] = ["res://localization/strings_vi.csv","res://localization/strings_en.csv"]
	var keys: PackedStringArray = ["PROFILE_TITLE","PROFILE_START","PROFILE_PREVIOUS","PROFILE_NEXT","PROFILE_PREV_HAIR","PROFILE_NEXT_HAIR","PROFILE_CYCLE_HINT"]
	assert_true(DataValidator.validate_translation_keys(paths,keys).is_empty())

func test_one_confirmation_emits_appearance_before_callback_and_latches_reentry() -> void:
	var menu: StartMenu = _main.start_menu
	menu.configure(_started,Callable(),Callable())
	menu.appearance_selected.connect(_appearance)
	_reenter = true
	await _settle()
	await _click(menu.screen.profile.confirm_button)
	assert_eq(_start_count,1)
	assert_eq(_appearance_count,1)
	assert_eq(_last_appearance,menu.get_appearance_selection())
	menu.call("_submit_new_game")
	assert_eq(_start_count,1,"Hidden/reentrant/double submit cannot create another game")
	menu.show()
	menu.call("_show_new_game_fields")
	await _settle()
	await _click(menu.screen.profile.confirm_button)
	assert_eq(_start_count,2,"A fresh form opening rearms the request")

func test_confirm_actual_player_and_saved_profile_match_preview() -> void:
	var form: LifeTitleProfileForm = _main.start_menu.screen.profile
	form.player_name.text = "Mai"
	form.farm_name.text = "Mùa An Lành"
	for row: LifeProfileChoiceRow in [form.hair_style,form.skin_tone,form.hair_color,form.outfit_color]:
		row.select(5)
	var selection: Dictionary = form.get_selection()
	var expected: Dictionary = LifeProfileChoices.CATALOG.call("resolve_player",selection)
	assert_eq(form.preview.avatar.hair,expected.hair_color)
	_main.start_menu.call("_submit_new_game")
	var actual: PlaceholderAvatar2D = _main.presentation.get_player_avatar()
	assert_eq(actual.get_hair_style(),form.preview.avatar.get_hair_style())
	assert_eq(actual.hair,form.preview.avatar.hair)
	assert_eq(actual.skin,form.preview.avatar.skin)
	assert_eq(actual.outfit,form.preview.avatar.outfit)
	assert_eq(_main.profile.appearance,selection)
	assert_eq(_main.inventory.get_quantity(&"turnip_seed"),10)
	assert_eq(_main.wallet.get_coins(),100)
	assert_eq(int(SaveService.load_game(1).meta.save_version),12)
	assert_eq(JSON.parse_string(JSON.stringify(SaveService.load_game(1).profile.appearance)),JSON.parse_string(JSON.stringify(selection)))
	assert_true(selection.skin_index is int)
	assert_true(_main.call("_load_game"))
	assert_eq(_main.profile.appearance,selection,"Game load restores the typed normalized selection")
	assert_eq(actual.get_hair_style(),StringName(selection.hair_style))

func _appearance(selection: Dictionary) -> void:
	_appearance_count += 1
	_last_appearance = selection.duplicate(true)

func _started(_player: String, _farm: String) -> void:
	assert_eq(_appearance_count,_start_count+1,"Appearance emits before the original callback")
	_start_count += 1
	if _reenter:
		_main.start_menu.call("_submit_new_game")

func _click(control: Control) -> void:
	var form: LifeTitleProfileForm = _main.start_menu.screen.profile
	if form.fields_scroll.is_ancestor_of(control):
		form.fields_scroll.ensure_control_visible(control)
		await _settle()
	var point: Vector2 = control.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	_viewport.push_input(motion,true)
	for pressed: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		event.pressed = pressed
		_viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()

func _key(code: Key, character: int = 0) -> void:
	for pressed: bool in [true,false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.unicode = character
		event.pressed = pressed
		_viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
