# HUD layout

## ISO-7 pause/settings composition (D43)

Reference14 is implemented as six small ui/pause scene/script pairs, with separate presenter/construction helpers. Existing Main/PauseMenu mounts a transparent VBox shell: top-right close control with motion padding, side-by-side wood/paper action and settings cards, fixed footer. UiLayout supplies the wide summary-style rectangle (up to1200x760, viewport margins32x24). The red pause ribbon, green Resume/Apply/active tab and yellow Settings reuse the shared Theme; no mockup bitmap or new Theme override is used.

Right card has fixed Audio/Graphics/Controls/Game tabs and fixed status/Default/Apply controls around a vertically scrolling page. Native sliders keep their real input and numeric percentages; read-only Theme-backed ProgressBars supply visible tracks without altering the shared Theme. Language/volume drafts apply only on Apply; Default selects the supported defaults in the draft. Close/modal switching discards unapplied drafts on reopening. All captions refresh in vi/en. Graphics, rain/wind audio, key-hint/autosave/shake/font-size switches are explicitly unavailable; no fake active values. Controls read current InputMap bindings.

Left card keeps Resume/Save/Settings/Return to menu plus secondary Load. Latest-save day/timestamp comes from SaveService metadata. Save/load outcomes are real bool results; failed required save keeps the current game open. Existing morning/periodic/dirty autosave behavior and v8 data/backups/goldens remain. UiCoordinator remains the modal owner, permits native Tab/Space/arrows before overlapping world actions in pause and retains Escape, modal switching, player/clock locking and day-end precedence. See SCENE_CONTRACTS/pause_menu.md for fields and manual cases.

## ISO-6b1 repeat-growth readout (D42)

Existing CropInspector reads each plot's frozen growth_target, showing the real repeat countdown and localized new-fruit care note. Dry warning has precedence; withered/ready states retain their truthful behavior. FarmView stages use the same owner query so legacy first crops and repeat crops cannot disagree with the inspector. Restore refreshes every crop through the existing FarmView.configure API, including cells other than zero. No new scene/input/theme/HUD state; vi/en captures at three sizes cover legacy-ready, repeat, repeat-ready and dry-repeat views. Bag/shop/bin continue to show actual updated Resource prices; no unavailable fertilizer/house action is displayed.

## ISO-6a crop-care warning (D41)

Existing CropInspector remains a small nonmodal HUD region (360×262 default; native minimum size may expand for longer text, within the tested viewport bounds). Its existing note Label shows actual remaining dry days after a missed watering day, including ripe plants left in soil; wet/watered/water-free plants use the ordinary care estimate, and terminal withered status disables actions. It reads FarmGridState and sends the existing Water/Harvest request through ToolActionController; no view owns the counter. Visible text refreshes on locale change. The terminal description applies to both drought/season withering and no longer asks a dead plant to be watered. The day-end sheet retains its real generic unwatered count; no new per-plot countdown or modal is added there. Check warning/ripe-warning/withered states at all three design sizes in vi/en.

## ISO-5 inventory (D40)

InventoryPanel uses small ui/inventory scene/script components, shared Theme and reference-06 wood/paper frame. At 1152×648 it occupies viewport minus 64×48 margins, growing to at most 1200×760. Five tabs plus close remain fixed; only Bag/Quest work. Left region has metadata filters, eight-column/five-row 40-cell default grid, actual occupied/capacity bar and sort/key hints. Right region has existing item art/name/category/count/description/actual unit sale price and explicit toolbar-selection/discard requests. Legacy capacities above 40 add scrolling rows. Icons use trimmed AtlasTexture views without editing art. Eating/quality/market effects stay unavailable.

Journal shares the header and original content. Q/E cycles Bag/Quest while consuming world E/Q; F selects a stack and closes Bag, Z sorts/remaps surviving selection. Discard replaces details with quantity/confirm/cancel; Escape cancels that subview first. InventoryState/InventoryActions own mutations; selection/filtering never changes money/items/ledger. Day-end modal has precedence. Three-size vi/en empty/partial/full/filter/discard/journal captures and physical key/mouse tests cover layout/routing. Human editor acceptance remains pending.

## ISO-4 active day-end sheet (2026-11-03, D39)

Reference 13 is composed by small ui/day_end views: centered wood/paper sheet, blue title, scrolling ledger/totals on the left, actual next-day date/forecast/tutorial completion on the right, green next-day and manual-stay buttons, and an unwatered-crop warning. Separate presenter/flow classes bind real state. No example income, XP/stamina/event data is shown; SVG/code placeholder artwork remains replaceable.

Reachable bedtime interaction or 02:00 cutoff opens the existing modal lock. Review holds the clock/hides interactive HUD. Manual Stay/Escape returns without simulation; forced cutoff hides Stay and ignores dismissal. Confirm runs one existing rollover and autosaves the completed morning. Restored reviews reopen held; confirmation cannot run twice. Ledger scrolls independently of fixed action buttons. Captions refresh in vi/en while hidden/visible; manual, incomplete-history and forced/rain-preview states are renderer-checked at three sizes against reference 13.

## ISO-3 active layout (2026-11-03, D38)

This section supersedes the historical C4 HUD region geometry below. Reference targets are `03-trong-game-ban-ngay.png` and `04-trong-game-dem-mua.png`. New UI is split into small scene/script pairs under `ui/hud/`: clock/weather card + time arc, pinned checklist, toolbar + slot, round shortcut bar, toast stack + card, with separate root/presenter/region/decoration helpers. Main supplies wiring; UiCoordinator retains sole modal ownership; UiLayout retains existing modal rectangles and delegates HUD anchors to LifeHudRegions.

- Upper left: pinned paper, actual tutorial completed/7 and up to three relevant steps. Existing tutorial stores booleans, so no 4/4 counts or reward figures from the mockup are fabricated.
- Upper right: shared wooden clock/weather card and wallet frame. Day/season/year/time/weather/forecast/coins come from existing state. The sun/moon arc observes time; world rain/tint remain on their existing layer. Stamina, calendar events and unavailable map/calendar buttons are hidden.
- Bottom center: eight visible slots with selected-item/tool caption. 1–3 are existing hoe/water/harvest; 4–8 are real stacks in a five-stack inventory window. InventoryPanel selection can address the whole inventory; the window follows it, including legacy key 9 (inventory index 8). Capacity and save payload do not change.
- Bottom left: supported B/J/H/Esc round buttons, with up to two timed result messages above. B/I/Tab open inventory; B is removed from the still-existing open_build action. H keeps help reachable. No dead K/M controls or modal Q/E bindings are introduced.
- Existing crop inspector and interaction prompt remain separate views. All visible UI uses the shared Theme; frame grain/studs, clock symbols and existing SVG icons are replaceable artwork. Mockup PNGs are never loaded as assets. Full-screen decorative shell ignores mouse input; buttons consume clicks and modal ownership hides interactive HUD/locks world input.

Anchor/container placement is verified at 1152×648, 1280×720 and 1920×1080 in vi/en; final measured dimensions and test results are recorded in PROGRESS. Actual day/night/rain renderer captures are compared to reference layout rather than treating code generation as visual proof. Existing world art remains ISO-1 placeholder art; ISO-3 does not replace the entire farm illustration.

## ISO-2 Theme foundation (2026-11-03, D37)

The active UI now shares `ui/theme/the_life_theme.tres`: paper/wood surfaces, ink borders and downward shadows, Nunito 600 body, Baloo 2 800 headings and Noto Serif Italic secondary text. UiLayout assigns this resource and type variations instead of duplicating/building a Theme. Reusable `LifeWood` frames have 28 px content margins; existing game panels use `LifeCompactPanel` to preserve their measured footprint. The old `scenes/main/ui_theme.tres` is retained for compatibility but has no active runtime consumer.

Open `ui/ui_gallery.tscn` with F6 for the isolated component/state comparison. It uses native Controls and localized sample values, supports vertical scrolling at 1152×648/1280×720/1920×1080 in vi/en, and exposes 24 replaceable circle/initial icon placeholders. Compare with `docs/ui_reference/15-bo-ui-kit.png`: palette/font roles, dark borders, selected/locked slots, progress, hearts, toggle/slider, badges and five tabs are represented; textured wood, illustrated icons and nine-slice art are still pending. The gallery is a component review, not a replica of the reference sheet layout.

ISO-2 preserves the existing HUD rectangles/modal behavior below. Eight visible tool slots, redesigned clock/coins/date, contextual Q/E tabs and later mockup screens are not wired by this milestone. Keyboard hints read the existing I/J/Escape/etc. InputMap; no new bindings are registered.

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
- UiLayout is a view helper: assigns the shared ISO-2 Theme with 18 px body/24 px titles, opaque panels and 40 px minimum buttons, places central modals within viewport margins with scrollable content and fixed close/footer controls. Existing scene nodes are bound through Main references.
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

The shared Theme is `ui/theme/the_life_theme.tres`; UiLayout assigns it with
18 px body and 24 px heading variations. Hotbar item labels use 16 px; key badges use
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

## C4 chibi UI / M7 (2026-10-30)

- The runtime Theme remains derived from `scenes/main/ui_theme.tres`, but C4 applies the C0 palette at runtime: cream rounded panels, pastel pill Button/OptionButton/field states, a clear keyboard focus ring, soft tinted shadow and a native Godot `TooltipPanel` surface. Tooltip text stays on the existing controls and is localized by its existing `tr()` caller; no tooltip becomes a texture or a gameplay target.
- `ChibiUiMotion` is a view-only Main child. It adds a non-interactive topmost `ChibiCursor`, binds existing controls through normal mouse/focus/button signals, and gives only a small hover/press/open bounce. The cursor shows a rounded paw over UI and a tiny code-drawn hoe/watering-can/seed/harvest cue after the corresponding existing tool button is selected. It changes neither tool authority nor input routing.
- The OS cursor is hidden only while the live non-headless `ChibiCursor` exists and is restored in `_exit_tree`; headless tests retain their normal input path. The cursor uses `MOUSE_FILTER_IGNORE`, so it cannot intercept a click intended for Godot Controls or the world.
- Title keeps its real Control buttons and now has a subtle outlined/breathing logo plus pointer-relative decorative backdrop drift. New Game is the title’s initial keyboard focus; opening the character form focuses the name field, settings focuses its language chooser, and other modals receive their first enabled Control. No custom hitboxes are introduced.
- Map-first rules remain unchanged: the four tool buttons stay within `220×60` at 1152×648, the corner icon bar within `216×60`, and expanded inventory/modal content replaces those regions instead of staying open over the world. Regression coverage checks C4 focus/cursor/motion plus existing modal/input/layout tests at 1152×648, 1280×720 and 1920×1080 in both locales.
- `tools\capture_chibi_ui.bat` invokes private `--capture-chibi-ui` and writes title/HUD evidence under ignored `screenshots/chibi-ui/`. It starts no slot flow and creates no save; it is an art/layout review tool, not a player command.
