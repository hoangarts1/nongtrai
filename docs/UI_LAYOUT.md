# HUD layout

The HUD uses viewport anchors and containers so panels do not depend on a
single window size.

| Region | Component | Rule |
|---|---|---|
| Top-left | `ClockHud` | Anchored to `(0, 0)` with a small margin |
| Top-right | `DebugMenu` | Anchored to `(1, 0)`, hidden by default and debug-only |
| Left-middle | `QuestPanel` | Reserved for the current farming checklist |
| Upper-center | `TutorialPanel` | Narrow modal (max 36% viewport width), uses the shared UI Theme; suppresses the quest panel while open |
| Center-lower | `InventoryPanel` | Compact modal with shared UI Theme and close button |
| Bottom-center | `HotbarPanel` | Centered above the bottom safe margin |
| Above bottom-center | `InteractionPrompt` | Positioned above the hotbar, never in its rectangle |
| Bottom-right | `HudButtonBar` | Anchored to `(1, 1)` with a safe margin |
| Center modal | `PauseMenu` / `StartMenu` | Shared Theme panels; pause locks the player and start menu blocks gameplay until New Game or Continue |
| Lower-center overlay | `Toast` / `FeedbackPopup` | Short save/result messages; mouse input is ignored |
| Farm world | `FarmView` crop labels | Billboard labels sit above each crop, use no-depth-test rendering, and are kept in the world-space farm region rather than a HUD panel |
| Top-left clock | `ClockHud` period text | Shows day, time and localized dawn/morning/afternoon/dusk/night beside the clock |
| Under clock | `WeatherHud` | Shows today's weather and tomorrow's forecast below the clock; it stays inside the top-left region |

Panels must use `Container` children for internal layout. New HUD controls
must register in the existing bars or use a documented region; they must not
introduce screen-space coordinates that overlap another region.

The shared Theme is `scenes/main/ui_theme.tres`: body text is 14 px and
modal headings are 18 px. Layout tests cover all panels at 1152x648,
1280x720, and 1920x1080 with the tutorial visible and the quest panel
suppressed.

The pause menu uses `Esc` / the `pause` InputMap action. Its settings controls
persist language and music/effects volume through `Settings`. New-game profile
names are stored in the normal save slot; sleeping writes the autosave slot 0.
