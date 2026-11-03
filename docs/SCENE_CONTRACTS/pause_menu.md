# ISO-7 Pause/settings contract (D43)

Approved by owner: commit ISO-6b1 and implement the ISO-7 plan/ALLOW_LIST in PROGRESS. Main/PauseMenu remains the existing PanelContainer and public configure/open/close/toggle API; no existing scene edits. Its new runtime child shell comes from ui/pause/pause_shell.tscn. UiLayout supplies the wide modal rectangle; UiCoordinator owns exclusivity, focus and clock/input restoration. Closing or switching discards drafts. DayEndSheet retains precedence.

All six component scenes use script-built native Controls and the shared Theme; scripts own only presentation/request state. Each scene has its same-named .gd, no editor signal connections or external node paths.

| Scene / class | Root | Typed runtime fields / requests |
|---|---|---|
| pause_shell / LifePauseShell | VBoxContainer | actions: LifePauseActions; settings: LifeSettingsPanel; close_button: Button; hints: Label |
| pause_actions / LifePauseActions | PanelContainer (LifeHudFrame) | resume_button/save_button/load_button/settings_button/menu_button: Button; summary: Label; requested(id: StringName) |
| settings_panel / LifeSettingsPanel | PanelContainer (LifeHudFrame) | tabs: Array[Button]; audio: LifeAudioSettings; game: LifeGameSettings; controls: LifeControlsHelp; graphics: VBoxContainer; apply_button/default_button: Button; status: Label; select_tab(index: int); applied(), defaulted() |
| audio_settings / LifeAudioSettings | VBoxContainer | music/effects: HSlider; music_value/effects_value: Label; set_values(music_value: float, effects_value: float); separate weather audio unavailable |
| game_settings / LifeGameSettings | VBoxContainer | language: OptionButton; set_locale(value: String); get_locale() -> String; unsupported switches disabled |
| controls_help / LifeControlsHelp | VBoxContainer | refresh() -> void renders current supported InputMap bindings read-only |

LifePausePresenter is a RefCounted view adapter. configure(menu: PanelContainer, shell: LifePauseShell, save: Callable, load: Callable, exit: Callable), begin(), apply(), defaults(), refresh_summary(), show_result(key: StringName). It snapshots Settings into transient draft controls and applies supported values through existing setters. Main's private save/load/menu callbacks return bool, so failed/blocked writes never report success or discard a running game. Existing Settings/SaveService schema remains unchanged.

LifePauseParts supplies localized labels/buttons/unavailable rows; unsupported rows are explicitly disabled and explain availability. Four tabs: Audio, Graphics, Controls, Game. New paths are internal ui/pause resources, never guessed Main paths. The only world lookup is the existing Main sibling GrayBoxWorld.player adapter. No new autoload, Events signal, InputMap action or save field. Native ui_* actions provide keyboard navigation; pause routing permits those GUI actions before world-shortcut handling.

Manual: F5, start/continue, Esc; check Save/Load/Return/Resume, Apply/Default/cancel, vi/en, all tabs and 1152x648/1280x720/1920x1080. Load a day-end review and verify it wins. Reference 14 is read-only composition guidance, never a runtime asset. No editor tree/Inspector changes required.
