# Scene contract — ChibiArtLineup

## Purpose

`tools/art_lineup.tscn` is an isolated C0 art-review tool scene. It compares generated calibration models under four camera angles and day/night lighting. It is not a gameplay scene and must never become a dependency of `main.tscn`.

## Root

| Requirement | Value |
|---|---|
| Root node | `ChibiArtLineup` (`Node3D`) |
| Script | `res://tools/art/chibi/art_lineup.gd` |
| Required exported values | None |
| Autoloads / groups / collisions | None |

## Runtime-owned children

The script creates these direct children. They are implementation details, so the editor must not add hard-coded gameplay paths or signal connections to them.

- `WorldEnvironment`
- `ReviewSun`
- `ReviewFill`
- `ReviewCamera`
- `ReviewGround`
- `OneMeterGrid`
- `Character`, `Prop`, `Crop`, `Building`, `Tree`, plus their `Label3D` review labels

Each model is made by `ChibiMeshBuilder` from the `chibi_valley` palette and is placed on the ground plane at `y = 0`. The root exposes `build_lineup()`, `set_review_view(view_index, night)` and `set_focus_model(model_name)` only for review tooling/tests.

## Running it

Use `tools\art_review.bat`; it creates a temporary `SubViewport`, instances this scene, and writes the ignored lineup and per-model contact sheets under `screenshots/chibi-core/`. The runner requires a normal Forward+ graphics renderer. It must fail if capture is empty or its log contains a parse/script/engine error.

No human editor setup is required. Do not add the lineup to any shipping scene, do not attach collisions/input, and do not reuse its camera/light nodes as game authority.
