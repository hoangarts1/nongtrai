# HUD layout

## Compact HUD/crop inspection contract (2026-10-27)
- Default HotbarPanel shows only its four tool buttons (44 px target height). Its nine-slot grid/caption are hidden; InventoryPanel is the only expanded item surface. Each inventory row has a localized Select button, emits slot_selected(index), and closes the inventory after selection. Numeric 1–9 selection remains available while playing.
- Main constructs CropInspector (PanelContainer) from code and supplies the farm state. It is a nonmodal 360×252 maximum card at the lower-left, above the compact tool row. A crop click shows/replaces the selected cell's card without consuming items or pausing the clock. Opening a full modal hides the inspector; selecting empty terrain or its close button dismisses it.
- CropInspector displays localized crop name, large countdown in game days/hours/minutes, estimated game-day/morning, watering state and daily-watering assumption. It derives its estimate from remaining growth-day boundaries and GameClock; crops still grow only in DaySimulator. Ready/withered crops show an explicit state instead of a misleading timer. Water/Harvest buttons call the existing ToolActionController with reach/input checks.
- Tiny repeated Label3D crop status text is hidden; all detail is available on click. Existing labels remain queryable for API compatibility. No new action, scene node dependency or save field is introduced.

## UI repair contract (2026-10-26)
- Chibi visual follow-up: runtime `TitleBackdrop` uses assets/ui/title_valley.png (generated title art) with non-interactive decorative motes. StartMenu becomes a cream card at the left over this full-screen illustration; all real buttons remain Godot Controls. UiIcons loads crisp local SVG icons for inventory/help/journal/settings/tools/items; localized tooltips and quantity/key labels remain. No scene edits. A runtime WorldPresentation child replaces only existing placeholder visuals with procedural chibi meshes and gentle view-only movement; logical positions/collisions stay unchanged.
- Backdrop child is placed FIRST in sibling order for GUI picking; z_index alone does not establish click order. Modal `_input` ignores mouse events so buttons/scrollbars process them; the backdrop blocks clicks outside panels. Mouse regressions run through isolated SubViewport.push_input with press/release pairs rather than emitting button signals.
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
| Bottom-left | `HotbarPanel` | Compact four-tool icon strip; the full item grid and selection caption live in InventoryPanel |
| Above bottom-center | `InteractionPrompt` | Positioned above the hotbar, never in its rectangle |
| Bottom-right | `HudButtonBar` | Anchored to `(1, 1)` with a safe margin |
| Center modal | `PauseMenu` / `StartMenu` | Shared Theme panels; pause locks the player and start menu blocks gameplay until New Game or Continue |
| Lower-center overlay | `Toast` / `FeedbackPopup` | Short save/result messages; mouse input is ignored |
| Farm world | `FarmView` / `CropInspector` | Crop meshes are shape-specific and gently sway; tiny world labels stay hidden. Clicking a crop opens the readable nonmodal inspector card instead. |
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

## World-art presentation contract (2026-10-27)

- Farming input presentation: a default hoe click on a crop opens the readable CropInspector. With Seed, Water or Harvest selected, holding the existing left-use input and crossing reachable cells submits each one direct action once; no extra on-screen control or InputMap action is created.

- Existing `House`, `SeedShop`, `ShippingBin`, NPC-home and `FarmView` roots remain the interaction/display anchors documented by the world scene contract. The shipping bin and its marker now share the deliberately separated `(5.2, 0, 10.0)` sale location; all other presentation additions only add non-colliding mesh children and never own collision, cells or reach.
- Player house uses a cottage silhouette; the seed shop is a separate awning market; the shipping bin remains visually distinct. Rock/moss clusters are view-only and positioned outside farm cells and expected routes.
- Crop detail is a native 3D presentation: seedlings, roots, vines, tall stalks, wheat heads, pumpkins and cabbages are visibly different. Watered crops receive small dew accents, healthy crops sway subtly, and withered crops remain static/dry. The existing crop-click bounds and inspector remain the accessibility path for timing.
- Forward+ presentation uses warm restrained filmic tonemapping, color adjustment, glow, shallow fog and softened directional shadows. View-only grass tufts, path stones and soil furrows make ground readable without changing FarmGridState. DayNightProfile/WeatherState still own time/weather values; the presentation layer only applies them and retains the existing night-window light behavior.

## Phase 8 additions (scene contract for this task)
- `Main/NpcSystem` (Node3D, `scripts/view/npc_system.gd`) creates placeholder `minh` and `linh` actors and home boxes from `data/npcs/phase8_world.tres`. It never edits the world scene or existing shop/bin nodes.
- `Main/DialoguePanel` and `Main/NpcJournal` (PanelContainer, `scripts/view/npc_panel.gd`) are resized by UiLayout to the shared central modal rectangle, with scrollable VBox body/actions and a fixed close button. No extra input action: E talks, J opens/closes the journal, Esc closes the modal. Domain state belongs to NpcSocialState.
- NPC name labels show the existing E binding when the player is within the data-defined reach. Indoors NPCs are hidden; small labeled home boxes identify where they went.
- NPC modals pause the clock, lock movement, suppress the onboarding panel and hide the hotbar/HUD buttons; world/tool/inventory/help/debug input is consumed. They close before restoring input and HUD visibility; no save while an NPC modal is open. Exit closes the modal before the final save. Dialogue buttons are explicit confirmation; journal never consumes items.
- Main composes `social` in the save payload and restores it after clock/weather; no new autoload or world ownership is introduced.

## C1 character selector and character readability (2026-10-28)

- Selecting New Game hides the four direct title actions and opens one compact form: player name, farm name, a two-column appearance grid, Confirm and Back. The form contains four localized `OptionButton`s — hair style, skin tone, hair color and outfit color — each backed by six data options. Back restores the direct title actions; the legacy New Game callback still receives only player/farm names.
- The form remains a child of StartMenu's existing container/card. It has no world-space controls, extra InputMap action or scene dependency. `UiLayout` applies the existing modal size/margins, and focused layout tests cover 1152×648, 1280×720 and 1920×1080 in Vietnamese and English.
- Player, Minh and Linh now use the existing gameplay anchors with compact chibi avatars. Their name labels remain the accessibility / interaction text. Character face, idle/walk/tool/talk motion and reaction bubbles are 3D view details; they do not add a permanent HUD panel or compete with crop inspection, quest, hotbar or modal regions.
- During the developer-only C1 screenshot argument, labels are suppressed only in the temporary in-memory capture arrangement to keep the contact image legible. Normal player gameplay still uses the existing localized NPC names and nearby-talk hint.

## C2 farming presentation (2026-10-29)

- C2 does not add a permanent panel or change the established modal map. The existing hotbar/inventory/icon APIs may show generated 128 px seed/produce stickers and the four farming tool stickers; localized labels, quantities, keyboard shortcuts and SVG fallbacks remain intact.
- Crop state remains in the existing compact click-selected CropInspector. In-world crop labels stay hidden, while a crop itself gains readable stage silhouettes, small dew/sparkle feedback and a gentle mature bob within the existing cell bounds.
- Tilled/wet soil and short action effects are world details only. They may not cover the inspector, hotbar, inventory, prompts, NPC panels or map interaction targets.

## C3 world presentation (2026-10-29)

- C3 introduces no permanent HUD control, modal, localized player string or input action. `C3WorldArt` and `WorldSeasonFx` render behind the established anchored HUD, CropInspector, interaction prompt and all modal surfaces.
- Paths, buildings, water, boundary, village props and seasonal particles stay in world space outside farm cells, protected interaction reach, NPC routes and camera-critical play space. They must not become an overlay or a substitute for UI feedback.
- `--capture-chibi-world` is an internal art-review argument only; it has no player-facing button and does not alter layout, save state or modal ownership.
