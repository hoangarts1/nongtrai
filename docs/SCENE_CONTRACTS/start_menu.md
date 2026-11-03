# ISO-8a StartMenu contract (D44)

Owner approved “Duyệt, commit ISO-7 và triển khai ISO-8a”. Main/StartMenu remains the existing PanelContainer in the existing scene. No old .tscn edits. Public configure(new_game_callback: Callable, continue_callback: Callable, exit_callback: Callable), appearance_selected(appearance: Dictionary), get_appearance_selection() -> Dictionary, refresh_continue()/apply_chibi_style() -> void remain. New screen: LifeTitleScreen and presenter: LifeTitlePresenter are typed adapter fields.

The approved internal path migration removes script-created MarginContainer/Column paths in favor of typed references below; existing NewGame/Continue/Settings/Exit behavior assertions move to screen.actions. Main/StartMenu path, input actions/data IDs/public callbacks stay unchanged. Legacy _name_box/_settings_box remain VBoxContainer references to the actual profile/settings components. Profile ConfirmNewGame and AppearanceGrid/{HairStyle,SkinTone,HairColor,OutfitColor} names remain.

| Scene / class | Root | Fields / requests |
|---|---|---|
| title_screen / LifeTitleScreen | PanelContainer (LifeHudFrame) | logo/tagline/version/hint: Label; latest: LifeLatestSaveCard; actions: LifeTitleActions; profile: LifeTitleProfileForm; settings: LifeTitleSettings; set_mode(mode: int), modes TITLE/PROFILE/SETTINGS |
| title_actions / LifeTitleActions | VBoxContainer | continue_button/new_game_button/settings_button/exit_button: Button; requested(id: StringName) |
| latest_save_card / LifeLatestSaveCard | PanelContainer | heading/farm/player/day/coins: Label; display(payload: Dictionary) -> void, display only validated/coerced actual fields, no game state |
| profile_form / LifeTitleProfileForm | VBoxContainer | player_name/farm_name: LineEdit; appearance_grid: GridContainer; hair_style/skin_tone/hair_color/outfit_color: OptionButton; confirm_button/back_button: Button; submitted(), cancelled(); get_selection() -> Dictionary via unchanged catalogue normalization |
| title_settings / LifeTitleSettings | VBoxContainer | panel: LifeSettingsPanel; back_button: Button; cancelled(); begin()/apply()/defaults() -> void through existing Settings, transient control drafts only |

LifeTitlePresenter.configure(menu: StartMenu, screen: LifeTitleScreen, start: Callable, resume: Callable, exit: Callable), refresh(), request(id: StringName), submit() -> void. Revalidates Continue before callback; forwards normalized appearance before unchanged two-string New Game request. Main remains the gameplay/profile owner and controls Continue visibility/load. Existing TitleBackdrop and assets/ui/title_valley.png remain unchanged. LifeTitleParts supplies localized safe display/GUI construction helpers. All scripts static typed, no stateful domain added.

Profile tree: FieldsScroll/Fields contains player/farm labels/LineEdits and AppearanceGrid; root ConfirmNewGame/BackToTitle stay fixed outside that scroll. Selector node names remain unchanged; consumers use typed profile fields instead of old direct grid paths.

UiLayout owns title's left rectangle vs centered wide settings rectangle, with deferred resize after mode changes. Profile scrolls with confirm/back fixed outside the scroll; settings reuses existing four-tab component, no second modal. UiCoordinator retains StartMenu as sole modal owner and lets native GUI focus/activation/navigation pass before overlapping world actions, including when LineEdit has focus. Escape returns from profile/settings to title; it cannot dismiss title into a world. Native startup primary focus remains New Game for existing behavior; Continue is visually primary and only enabled for a valid latest slot0/1.

All scenes build native controls from script and shared Theme; no scene-local StyleBox or new InputMap action. Missing save fields are omitted/marked unavailable, not inferred. No playtime/house level/portrait is fabricated. vi/en and actual save game_version provide text/version; unknown version is hidden. No editor steps beyond import/F5. Check empty/latest/old/corrupt save, long names, physical input, form normalization and draft cancel/apply across three sizes.
