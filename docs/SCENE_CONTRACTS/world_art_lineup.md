# world_art_lineup.tscn — C3 isolated world-art review scene

Path: `tools/chibi_world_lineup.tscn`

Root: `ChibiWorldLineup` (`Node3D`)   Script: `tools/art/chibi/chibi_world_lineup.gd`

Purpose: render the generated C3 world art in a small isolated diorama. It is a review utility, never loaded by gameplay and never writes a save.

## Runtime-owned review nodes

`ChibiWorldLineup` creates these children at runtime:

```
ChibiWorldLineup
├─ WorldEnvironment
├─ ReviewSun
├─ ReviewFill
├─ ReviewCamera
├─ ReviewGround
├─ GeneratedModels
└─ ModelLabels
```

It loads only generated scenes named in `WorldArtCatalog`. It has no collision, navigation region, player, `GameClock`, `WeatherState`, input action, merchant data or save service.

## Review contract

- `build_lineup()` creates the isolated camera, lights and selected model group.
- `get_review_group_ids()` returns the stable contact-sheet group IDs.
- `set_focus_group(group_id)` shows only that group; missing generated models set `last_error`.
- `set_review_view(view_index, night, season)` selects the four 45-degree-spaced views, day/night light and one of the four display-only seasonal palettes.
- The review runner writes contact sheets only under ignored `screenshots/chibi-world/`; it must use a normal graphics renderer, never headless mode.
- Every tile uses the generated asset pivot at terrain level, with a readable 45-degree/35-degree gameplay view represented by the first daytime tile.
