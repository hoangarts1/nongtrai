# ISO-8b character creation (D45)

Owner approved “Duyệt, commit ISO-8a và triển khai ISO-8b”. Existing Main/StartMenu and ui/title/profile_form.tscn VBox root remain. Profile mode becomes a transparent wide TitleScreen containing profile_form's two columns: left LifeHudFrame/paper/red banner/FieldsScroll/name-fields/choices/fixed Back+Start, right avatar_preview. No old .tscn edits. UiCoordinator still owns the single start modal.

Public LifeTitleProfileForm fields player_name/farm_name: LineEdit; hair_style/skin_tone/hair_color/outfit_color: LifeProfileChoiceRow (explicit replacement for old OptionButtons); confirm_button/back_button: Button; choices: LifeProfileChoices; names: LifeProfileNameFields; preview: LifeProfileAvatarPreview; fields_scroll: ScrollContainer (follow_focus=true). get_selection() -> Dictionary and submitted()/cancelled() stay. begin_submission() -> bool latches one request; reset_submission() -> void arms the next opening. StartMenu._name_box remains the real VBox. Internal AppearanceGrid paths are replaced by typed choice fields; tests keep full six-choice/normalization assertions.

| Scene / class | Root | API/fields |
|---|---|---|
| name_fields / LifeProfileNameFields | HBoxContainer | player_name/farm_name: LineEdit; changed(); draft text, no new validation |
| profile_choices / LifeProfileChoices | VBoxContainer | hair_style/skin_tone/hair_color/outfit_color: LifeProfileChoiceRow; get_selection() -> Dictionary; changed(selection: Dictionary), normalized via existing catalogue |
| choice_row / LifeProfileChoiceRow | VBoxContainer | selected: int, buttons: Array[Button], item_count getter; configure_styles(PackedStringArray), configure_colors(Array[Color], StringName), select(index: int), get_item_text(index: int) -> String, get_item_metadata(index: int) -> Variant; selected_changed(index: int) |
| choice_swatch / LifeProfileSwatch | Button | paint: Color; native toggle/focus; Theme-backed selection and drawn color/check |
| avatar_preview / LifeProfileAvatarPreview | VBoxContainer | avatar: PlaceholderAvatar2D; stage: Control; previous_button/next_button: Button; player_caption/farm_caption/style_caption: Label; display(selection: Dictionary, player_text: String, farm_text: String); hair_cycled(direction: int) |

LifeProfilePresenter.configure(form: LifeTitleProfileForm), refresh(_value: Variant = null), cycle(direction: int) -> void binds draft changes to the preview; no game state. LifeProfileParts builds localized frames/banner/limited display labels. Preview stage contains only a UI-local Node2D renderer, decorative scenery and mouse-capable arrow buttons; no collision/camera/3D/pet state. Arrows cycle six hairstyles, not camera facing.

Shared stateless VIEW helper AvatarHair2D.draw_back(canvas: CanvasItem, style: StringName, color: Color, ink: Color) and draw_front(...) -> void draws actual six catalogue IDs. PlaceholderAvatar2D.configure_profile applies its existing normalized player customization; get_hair_style() -> StringName exposes the displayed cosmetic ID. Empty customization keeps the legacy NPC hair arc unchanged. All body/action/motion/collision/gameplay values remain unchanged. Preview and active player use the same class/helper.

TitlePresenter submission checks visible profile mode and begin_submission before its original appearance signal/two-string callback. Opening profile resets latch; Back/reopen retains names/choices. Locale refresh does not rebuild emitting controls or clear drafts. UiLayout uses the existing wide bounds for profile/settings; old title remains left-card layout.

Manual: F5/New Game; all six hair/skin/hair-color/outfit choices, native keyboard/mouse, arrow wrapping, names/defaults/long captions, Back/reopen, one Start, actual game/saved-profile parity, vi/en/three sizes. No Inspector/scene/project setting steps. Shared Theme/title illustration retained; body artwork remains replaceable. Renderer suite alone gets180s bound, with all checks unchanged.

## D72-C1 inherited appearance review (D73)

Form/choices/scene/domain/save are unchanged. Active inherited PlaceholderAvatar2D/AvatarHair2D remain procedural renderers; generated farmer_sheet_2x is a draft/offline output and does not replace their six hair/skin/hair-color/outfit choices. New render review checks all six styles, resolved actual colors and unchanged Main profile/inventory/wallet/jobs while previewing. Existing native profile tests remain byte-identical.
