# INPUT MAP — THE LIFE

The ONLY list of input actions. `project.godot` InputMap must match this file exactly (action names AND defaults). A mismatch is a bug. Agents never invent actions; to add one, add a row here first (and tell the human to add it in Project Settings → Input Map).

Gameplay reads these through `_unhandled_input` (so UI can consume events first) or `Input.get_vector` / `Input.is_action_*`. Never read raw keys.

## Migration status (D33/D34)

The table below is the CURRENT implemented InputMap. ISO-1 preserves it; movement is now screen-relative in 2D. The later mockup UI target is:

| Target | Context / migration requirement |
|---|---|
| B inventory, plus existing I/Tab | Remove B from `open_build` before adding it to `open_inventory`; preserve the build action ID, with no replacement key invented |
| J journal; K calendar; M map | Retain J; register K/M only with working views; Ctrl+M remains the debug shortcut |
| 1–8 visible tool slots | Keep existing `hotbar_9` action/key as compatibility; do not drop inventory state |
| Q/E previous/next tab | Modal-only; world E interaction and Q placement rotation must not run underneath |
| F quick-store, Z sort, T pin quest | Reserved targets; add documented actions/defaults only with the implemented operation |
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
| `use_tool` | Mouse Left, Space | use the selected tool on the targeted cell | 4 |
| `cancel` | Mouse Right | cancel placement / close sub-menu / deselect | 4 |
| `tool_next` | Mouse Wheel Down | next hotbar slot | 3 |
| `tool_prev` | Mouse Wheel Up | previous hotbar slot | 3 |
| `hotbar_1` … `hotbar_9` | 1 … 9 | pick hotbar slot | 3 |
| `open_inventory` | I, Tab | inventory | 3 |
| `open_help` | H | how to play | 4 |
| `open_build` | B | build mode | 6 |
| `open_journal` | J | notebook: quests, ecology, collection | 7 |
| `rotate_cw` | R | rotate ghost clockwise (build mode) | 6 |
| `rotate_ccw` | Q | rotate ghost counter-clockwise | 6 |
| `camera_zoom_in` | = , Numpad + | zoom in (2–3 fixed levels) | 1 |
| `camera_zoom_out` | - , Numpad - | zoom out | 1 |
| `pause` | Escape | pause / menu (also closes the top UI layer) | 2 |
| `toggle_debug` | F3 | debug overlay (debug builds only) | 0 |
| `toggle_debug_menu` | Ctrl+M | developer debug menu (debug builds only) | 0 |

Notes
- A held left-mouse farming stroke reuses `use_tool`: it submits Seed, Water or Harvest once for every newly crossed reachable cell. A default hoe click on a crop still opens CropInspector; Water and Harvest modes act directly on crops.
- Wheel is reserved for the hotbar, so zoom uses keys. If you prefer wheel-zoom, change here first.
- Debug console commands (set_time, give_item …) are opened from the debug overlay and exist only when `OS.is_debug_build()`.
- Gamepad bindings: Phase 11; keep the same action names.
- Built-in `ui_*` actions are left untouched.
- Phase 8 uses existing `interact` (E), `open_journal` (J), and `pause`/`cancel` (Esc). E opens the nearest available NPC; dialogue actions use buttons; Esc closes the NPC modal before the pause menu. J closes an open NPC modal or opens the journal. No new InputMap entries are needed.
