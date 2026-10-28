# Scene contract — ChibiCharacterLineup

## Purpose

`tools/character_lineup.tscn` is an isolated C1 art-review scene. It loads the six generated C1 character assets on a one-metre grid for four-angle, day/night review. It is not a gameplay scene and must never become a dependency of `main.tscn`.

## Root

| Requirement | Value |
|---|---|
| Root node | `ChibiCharacterLineup` (`Node3D`) |
| Script | `res://tools/art/chibi/character_lineup.gd` |
| Required exported values | None |
| Autoloads / groups / collisions | None |

## Required generated assets

The runtime-created lineup loads these scenes by their stable generated paths:

- `assets/generated/models/characters/chr_player_base.tscn`
- `assets/generated/models/characters/chr_an.tscn`
- `assets/generated/models/characters/chr_lam.tscn`
- `assets/generated/models/characters/chr_linh.tscn`
- `assets/generated/models/characters/chr_minh.tscn`
- `assets/generated/models/characters/pet_dog.tscn`

The last asset is visual calibration only. It does not imply Roadmap 8.5 dog following, naming, collision, state or save behavior.

## Runtime-owned children and API

The script creates `WorldEnvironment`, `ReviewSun`, `ReviewFill`, `ReviewCamera`, `ReviewGround`, `OneMeterGrid`, one model root and one `Label3D` for each listed asset. The public review-only API is:

- `build_lineup() -> bool`
- `set_review_view(view_index: int, night: bool) -> void`
- `set_focus_model(model_id: StringName) -> void`
- `get_review_model_names() -> PackedStringArray`
- `get_model_path(model_id: StringName) -> String`

`last_error` describes a missing or incompatible generated asset. The normal-renderer `tools\art_review_characters.bat` fails instead of silently producing an incomplete sheet.

## Running it

Use `tools\art_review_characters.bat`. It writes one full-lineup and six focused 4-angle × day/night contact sheets under ignored `screenshots/chibi-characters/`, then calls `tools\capture_chibi_characters.bat`. The second wrapper starts the configured project scene with the private `--capture-chibi-characters` argument, so autoloads are available; `Main` creates a temporary daylight showcase pose, writes the actual `main.tscn` screenshot, never loads/writes a save and exits. Both wrappers fail on an empty capture or parse/script/engine error text.

No editor setup is required. Do not add this lineup to a shipping scene, do not attach input/collisions, and do not reuse its light or camera as gameplay authority.
