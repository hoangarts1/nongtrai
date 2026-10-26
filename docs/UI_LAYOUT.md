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
| Under weather | `WalletHud` | Displays current player coins in gold font; stays inside the top-left region |
| Center modal | `ShippingBinPanel` | Centered modal for selling produce; locks player movement while open; uses shared UI Theme |
| Center modal | `SeedShopPanel` | Centered modal for buying seeds with season filtering; locks player movement while open; uses shared UI Theme |

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

## Phase 8 additions (scene contract for this task)
- `Main/NpcSystem` (Node3D, `scripts/view/npc_system.gd`) creates placeholder `minh` and `linh` actors and home boxes from `data/npcs/phase8_world.tres`. It never edits the world scene or existing shop/bin nodes.
- `Main/DialoguePanel` and `Main/NpcJournal` (PanelContainer, `scripts/view/npc_panel.gd`) use a centered 520×300 rectangle, shared Theme, scrollable VBox body/actions, and a close button. No extra input action: E talks, J opens/closes the journal, Esc closes the modal. Domain state belongs to NpcSocialState.
- NPC name labels show the existing E binding when the player is within the data-defined reach. Indoors NPCs are hidden; small labeled home boxes identify where they went.
- NPC modals pause the clock, lock movement, suppress the onboarding panel and hide the hotbar/HUD buttons; world/tool/inventory/help/debug input is consumed. They close before restoring input and HUD visibility; no save while an NPC modal is open. Exit closes the modal before the final save. Dialogue buttons are explicit confirmation; journal never consumes items.
- Main composes `social` in the save payload and restores it after clock/weather; no new autoload or world ownership is introduced.
