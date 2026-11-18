# ISO-7 Pause/settings contract (D43)

## F13 supported draft persistence

PausePresenter.apply submits one supported music/effects/locale patch. It reports PAUSE_APPLIED only after actual persistence success, otherwise PREFERENCES_APPLY_FAILED; existing show_result clears recovery notice and restores the generic status region. Failed Apply keeps accepted values/locale and retryable drafts. Default/cancel/close behavior remains; no scene/layout/input changes or new settings options.

## F12 truthful recovery feedback (D98)

Presenter.notice:LifeSaveNotice is a new runtime component beside the existing status Label in its documented parent column. Recovered/error messages hide the generic Label and show this component; generic show_result clears its report and restores the Label. Its own translation notification re-renders the detached report, so language changes do not revive a stale generic status. Title uses presentation_enabled to keep the same component hidden in profile/settings even across translation changes. No existing .tscn edits.

PausePresenter captures bool load result and the callback owner's get_load_feedback()->Dictionary before refreshing the summary. Main provides this transient detached report only for that actual request, clears it before blocked/error paths, and sets it after restore succeeds (or a real load error). Custom callbacks without the getter keep the original generic result messages. Recovered/future/corrupt feedback uses LifeSaveNotice.message; primary/missing/blocked keep PAUSE_LOADED/PAUSE_LOAD_FAILED. No extra modal/toast for pause loading; Continue recovery uses one Main toast. Save/return failure remains bool-based and cannot show UI_SAVED or exit the running game. Existing settings draft/modal/lock and restore order stay.

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
