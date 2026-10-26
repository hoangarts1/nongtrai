# HUD layout

## UI repair contract (2026-10-26)
- Main creates UiCoordinator (Node) in code. It owns one active modal among inventory/help/debug/pause/start/shop/bin/dialogue/journal, closes the previous panel through its existing API, and restores player/clock state only after the active modal closes.
- UiCoordinator creates a full-viewport dimming ColorRect behind active panels; world interaction prompts, hotbar, HUD buttons and onboarding checklist are hidden during modal interaction. Escape closes the active panel; I/H/J/Ctrl+M switch to the requested panel without stacking.
- UiLayout is a view helper: duplicates the existing Theme to 18 px body/24 px titles, applies opaque panels and 40 px minimum buttons, places central modals within viewport margins with scrollable content and fixed close/footer controls. Existing scene nodes are bound through Main references; no scene or .tres edits.
- Hotbar uses nine readable slots (keys 1–9), full item names in a selected-item caption and tooltips; inventory keeps every slot in a scrollable list. NPC/home labels use a larger world-space font.
- At 1152×648 normal HUD uses top-left status, top-right compact onboarding, bottom-left tool/item bar and bottom-right menu buttons; modal layout replaces these secondary HUD regions while preserving the scene behind a dim background.

The HUD uses viewport anchors and containers so panels do not depend on a
single window size.

| Region | Component | Rule |
|---|---|---|
| Top-left | `ClockHud` | Anchored to `(0, 0)` with a small margin |
| Center modal | `DebugMenu` | Debug-only, explicit close button and scrollable full-width actions |
| Top-right | `QuestPanel` | Readable farming checklist, hidden behind modals |
| Center modal | `TutorialPanel` | Readable controls help, separate from the start screen |
| Center modal | `InventoryPanel` | Fixed header/close button and scrollable item list |
| Bottom-left | `HotbarPanel` | Nine large slots, full-name caption and tool buttons |
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

The shared Theme is `scenes/main/ui_theme.tres`; UiLayout duplicates it at runtime
to 18 px body and 24 px headings. Hotbar item labels use 16 px; key badges use
14 px and a full-name caption uses 18 px. Layout tests cover visible panels at
1152x648, 1280x720 and 1920x1080 in Vietnamese and English. Main modals use a
680×560 maximum rectangle constrained by viewport margins; long lists scroll,
while close and transaction controls stay outside the scrolling region.

The pause menu uses `Esc` / the `pause` InputMap action. Its settings controls
persist language and music/effects volume through `Settings`. New-game profile
names are stored in the normal save slot; sleeping writes the autosave slot 0.

## Phase 8 additions (scene contract for this task)
- `Main/NpcSystem` (Node3D, `scripts/view/npc_system.gd`) creates placeholder `minh` and `linh` actors and home boxes from `data/npcs/phase8_world.tres`. It never edits the world scene or existing shop/bin nodes.
- `Main/DialoguePanel` and `Main/NpcJournal` (PanelContainer, `scripts/view/npc_panel.gd`) are resized by UiLayout to the shared central modal rectangle, with scrollable VBox body/actions and a fixed close button. No extra input action: E talks, J opens/closes the journal, Esc closes the modal. Domain state belongs to NpcSocialState.
- NPC name labels show the existing E binding when the player is within the data-defined reach. Indoors NPCs are hidden; small labeled home boxes identify where they went.
- NPC modals pause the clock, lock movement, suppress the onboarding panel and hide the hotbar/HUD buttons; world/tool/inventory/help/debug input is consumed. They close before restoring input and HUD visibility; no save while an NPC modal is open. Exit closes the modal before the final save. Dialogue buttons are explicit confirmation; journal never consumes items.
- Main composes `social` in the save payload and restores it after clock/weather; no new autoload or world ownership is introduced.
