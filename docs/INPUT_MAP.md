# INPUT MAP — THE LIFE

## AUDIT-F2 exact debug action (D88; full 603/603 automation verified)

InputMap bytes remain unchanged. Existing toggle_debug_menu is physical Ctrl+M; every runtime matching route delegates to MachineShopShortcut.matches(event,OS.is_debug_build()), with allow_echo=false/exact_match=true. Extra Shift/Alt/Meta/plainM/release are not this shortcut. Existing open_map=M has no active screen/handler; tests distinguish exact actions without claiming a dual-screen trigger was reproduced. Existing explicit InputEventAction debug requests remain supported only with true buildflag. World entry additionally respects title/not-started/busy/sleep/day-end; modal/native priority and normal E shop stay. Testfalse buildflag is not an exported release run.

## Phase6.6d chicken-coop interaction (D83; existing E only)

Walk near data entrance south of the house and press existing interact/E. Water refill keeps priority, then coop, then existing bin/shop/bed anchors. Coop screen pauses world/locks movement via UiCoordinator; native Tab/arrows/Space/Enter operate controls, Escape closes, explicit Open Bag returns to actual inventory. UI quantities are transient; no extra keyboard action, raw gameplay key or project.godot edit. Commands require active coop panel and actual nearby player context, plus safe-point guard. Transaction-time input is consumed.


## Phase6.5h3 native can-upgrade entry (D79; no binding change)

Open Bag with existing B/I/Tab, then use its separate Upgrade can footer Button. Confirmation uses native mouse/Tab/Space/Enter; Escape closes through UiCoordinator, explicit Back returns to Bag. Existing F/Z/Q/E/filter/discard/bag-upgrade paths remain. No new shortcut or E/world context: modal input cannot refill/water. Upgrade preserves current water; return to the existing source/E interaction to refill40. Prior debug pause holds and world locks remain owned by UiCoordinator.


## Phase6.5h2b existing E water refill context (D78; no binding change)

Select the existing watering-can toolbar slot, stand on a dry bank beside the existing well/stream/pond, then use existing interact/E to refill. At such a bank this context takes priority over the nearby bin; with ordinary tool selection prior bin/shop/bed/NPC behavior remains. A full can shows full feedback with no state change. Wrong source/interior/far/locked gameplay cannot refill; GUI/modal/NPC/menu Q/E routing retains precedence. No extra action/key/project.godot binding.

Existing LMB/stroke/Space/Inspector water requests use one actual can; only successful new manual water consumes one. Empty feedback points to the existing sources. Native wheel/hotbar/CameraRig paths remain. HUD meter is pointer-ignore presentation beside the original caption, not an input action or inventory slot. Rain/day/overnight retain existing simulation and never reset/debit this amount. See watering.md/PROGRESS for native tests/manual limits.

## D72-C1 corrected native wheel routing (D73)

Physical plain map wheel changes CameraRig zoom; Shift+wheel or wheel over the visible hotbar cycles its slots once and preserves zoom. Native pointer events are handled directly in these VIEW adapters because tool_next/tool_prev currently have empty physical event lists; no project.godot binding is added. Camera yields GUI-hover wheel so controls/hotbar can receive it. Existing +/- zoom actions and RMB/MMB pan remain; overlays/sleep/placement block camera input, RMB cancels placement, LMB keeps farming.

Current toolbar order is hoe/shovel/watering can/harvest followed by four displayed bag stacks; native wheel cycles actual adapter selection, skips absent item slots and wraps in either direction; it does not depend on the legacy item highlight offset. Walking returns pan smoothly; double-right-click/reset_pan immediately resets to player, as the API does. Earlier D72's generalized smooth-reset wording and older toolbar-order notes below are historical.

## ISO-Visual & Camera Pan/Zoom Slice (D72; no project.godot InputMap change)

- **Map Zoom**: Mouse Wheel Up / Down when the cursor is over the map (outside the bottom hotbar) zooms the 2D isometric camera across `IsometricWorldConfig.zoom_levels` (`0.35`, `0.5`, `0.75`, `1.0`, `1.25`), in addition to existing `camera_zoom_in` (`=`, `Numpad +`) and `camera_zoom_out` (`-`, `Numpad -`).
- **Hotbar Wheel Cycle**: Scrolling the Mouse Wheel while hovering over the bottom hotbar or holding `Shift + Mouse Wheel` cycles `tool_prev` / `tool_next`.
- **Map Drag Pan**: Holding Right Mouse Button (`MOUSE_BUTTON_RIGHT`) or Middle Mouse Button (`MOUSE_BUTTON_MIDDLE`) and dragging pans the camera across the map while keeping Left Mouse Button (`MOUSE_BUTTON_LEFT`) dedicated to tile targeting and farming strokes. Double-clicking Right Mouse Button or moving the character with `WASD`/arrows smoothly returns the camera to the player.

## Phase6.5g bag upgrade entry (D70; no InputMap change)

Open the existing bag (B/I/Tab) and use its new footer upgrade Button. Confirmation uses native mouse/Tab/Space/Enter, Escape closes through UiCoordinator, explicit Back returns to the bag when safe. Existing F quick-select and Z sort apply to real extra-slot indices; native wheel scroll reaches the added rows. No new shortcut/world interaction or watering input.

## Phase6.4b land purchase entry (D69; no InputMap change)

Existing debug Ctrl+M opens the machine shop. Its shop-mode header now offers land expansion; native mouse/Tab/Space/Enter navigate/activate, Escape closes via UiCoordinator. Operation mode does not expose this button. No F1 action, merchant interaction, new shortcut or normal-game shop access is introduced. Existing placement/tool/Player inputs remain unchanged.

The ONLY list of input actions. `project.godot` InputMap must match this file exactly (action names AND defaults). A mismatch is a bug. Agents never invent actions; to add one, add a row here first (and tell the human to add it in Project Settings → Input Map).

Gameplay reads these through `_unhandled_input` (so UI can consume events first) or `Input.get_vector` / `Input.is_action_*`. Never read raw keys.

Phase6.5e clarification: the actual project has Space as use_tool and Escape as cancel; mouse aliases are not registered there. Existing farming and the new placement click plane use native mouse-button events, as GUI Buttons do. Placement's left-click confirm/right-click cancel are native GUI gestures, not newly added InputMap bindings. Q/R reuse the actual rotate actions, Tab/Enter/Space retain native focused-Control behavior, Escape closes the top modal, and open_build remains unbound. No project.godot change in this slice. Other historical binding notes below are not an authorization to migrate defaults.

## Migration status (D33/D34)

The table below is the CURRENT implemented InputMap. Movement is screen-relative in 2D. ISO-3 implements B/I/Tab inventory and eight visible tool/item keys; the remaining later mockup targets are:

| Target | Context / migration requirement |
|---|---|
| B inventory, plus I/Tab | Implemented in ISO-3; B removed from `open_build`, whose action ID remains unbound. Tab was documented historically but absent from the actual project defaults; ISO-3 adds the documented alias explicitly. |
| J journal; K calendar; M map | Retain J; register K/M only with working views; Ctrl+M remains the debug shortcut |
| 1–8 visible tool slots | Implemented: 1 hoe, 2 watering can, 3 harvest; 4–8 the displayed five-stack inventory window. `hotbar_9` retains legacy inventory index 8 selection; no inventory state/capacity is dropped. |
| Q/E previous/next tab | ISO-10 extends ISO-5 to Bag/Character/Quest; consumes world E/Q |
| F quick-select, Z sort, T pin quest | ISO-5 implements toolbar selection and Bag sorting; T remains unavailable |
| Esc | Existing pause/close-top-modal routing |

This is an approved binding migration plan, not a claim that new actions exist in `project.godot`. New action IDs must be specified in the relevant implementation task before use. Do not register or display unsupported shortcuts.

## Current runtime bindings

| Action | Default binding | Used for | Phase |
|---|---|---|---|
| `move_up` | W, Up | move toward screen top (screen-relative in 2D) | 1 |
| `move_down` | S, Down | move toward the bottom of the screen | 1 |
| `move_left` | A, Left | move left on screen | 1 |
| `move_right` | D, Right | move right on screen | 1 |
| `sprint` | Left Shift (hold) | run *(added vs Master Plan S01 — the plan mentions walk/run)* | 1 |
| `interact` | E | talk / open / sleep / pick up (nearest Interactable) | 1 |
| `use_tool` | Space | selected tool; native left mouse is handled separately by farming/placement views | 4 / 6.5e |
| `cancel` | Escape | close/cancel top UI; native right mouse cancels the placement click plane separately | 4 / 6.5e |
| `tool_next` | unbound | retained next-slot action; native qualified wheel is handled directly | D72-C1 |
| `tool_prev` | unbound | retained previous-slot action; native qualified wheel is handled directly | D72-C1 |
| `hotbar_1` … `hotbar_8` | 1 … 8 | current mixed toolbar: hoe/shovel/watering/harvest, then four inventory stacks | D72 |
| `hotbar_9` | 9 | legacy ninth inventory stack; display window follows selection | ISO-3 compatibility |
| `open_inventory` | B, I, Tab | inventory | 3 / ISO-3 |
| `inventory_tab_prev` | Q | previous enabled Bag/Character/Quest tab while shell is active | ISO-5 / ISO-10 |
| `inventory_tab_next` | E | next enabled Bag/Character/Quest tab; consumes world interaction | ISO-5 / ISO-10 |
| `inventory_quick_select` | F | select highlighted real stack on toolbar; Bag only | ISO-5 |
| `inventory_sort` | Z | stable inventory sort; Bag only | ISO-5 |
| `open_help` | H | how to play | 4 |
| `open_build` | unbound | retained future build action ID; B now opens inventory | 6 |
| `open_journal` | J | notebook: quests, ecology, collection | 7 |
| `rotate_cw` | R | rotate ghost clockwise (build mode) | 6 |
| `rotate_ccw` | Q | rotate ghost counter-clockwise | 6 |
| `camera_zoom_in` | = , Numpad + | zoom in across five Resource-owned levels | D72 |
| `camera_zoom_out` | - , Numpad - | zoom out | 1 |
| `pause` | Escape | pause / menu (also closes the top UI layer) | 2 |
| `toggle_debug` | F3 | debug overlay (debug builds only) | 0 |
| `toggle_debug_menu` | Ctrl+M | developer debug menu (debug builds only) | 0 |

Notes
- A held left-mouse farming stroke reuses `use_tool`: it submits Seed, Water or Harvest once for every newly crossed reachable cell. A default hoe click on a crop still opens CropInspector; Water and Harvest modes act directly on crops.
- Native map wheel zooms; Shift/toolbar-hover wheel cycles populated toolbar slots. Existing +/- zoom keys also remain. GUI/modal/placement input wins as specified above.
- Debug console commands (set_time, give_item …) are opened from the debug overlay and exist only when `OS.is_debug_build()`.
- Gamepad bindings: Phase 11; keep the same action names.
- Built-in `ui_*` actions are left untouched.
- Phase 8 uses existing `interact` (E), `open_journal` (J), and `pause`/`cancel` (Esc). E opens the nearest available NPC; dialogue actions use buttons; Esc closes the NPC modal before the pause menu. J closes an open NPC modal or opens the journal. No new InputMap entries are needed.
