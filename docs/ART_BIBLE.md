# ART BIBLE — Chibi Valley Core

## Purpose and scope

This is the visual contract for the original, code-generated chibi assets introduced by C0. It establishes an opt-in palette, material vocabulary, primitive construction rules and review process. It does not migrate existing gameplay presentation, scenes, saves, input, timing or economy. Those integrations belong to later chibi milestones.

The intended feeling is a warm toy-diorama valley: soft, rounded, cheerful and readable at a glance. These are original project designs; do not imitate a specific game, film, logo or character.

## Silhouette, scale and pivots

- Use rounded primitive forms and chunky silhouettes. Avoid needle-like details and visually sharp, aggressive corners.
- A character is `1.0 m` tall. The head occupies `50–55%` of total height; torso, limbs and accessories remain secondary silhouettes.
- Doors read at roughly `1.3×` character height. A mature tree reads at `2–3×` character height.
- The logical pivot is at the visual ground contact (`y = 0`) for a character, prop, crop, building and tree. No calibration mesh may extend below the ground plane.
- At 64 px, each category must be distinguishable by silhouette before small color details are considered.

## Palette

The source of truth is [chibi_valley.tres](../data/art/palette/chibi_valley.tres), backed by `ArtPalette`.

| Role | Intended use |
|---|---|
| `ground`, `foliage`, `water`, `roof` | Four-season color families |
| `wood`, `stone` | Stable environmental material roles |
| `ui_accent` | Warm focal / interaction accent |
| `outline` | Thin dark-brown contour, never pure black |
| `shadow` | Purple-blue tinted shade |
| `sunlight` | Soft cream rim/highlight |

Colors should remain warm pastels with moderate saturation. Light/shadow contrast must preserve the silhouette rather than make night unreadable. Runtime art obtains role colors through `ArtPalette.get_color()` or `ChibiMaterialFactory`; it does not hard-code a competing palette.

## Shared material vocabulary

Generated shaders live in `assets/generated/shaders/`; their matching reusable material resources live in `assets/generated/materials/`.

- `chibi_toon.gdshader`: lightweight toon bands, tinted shadow and restrained rim.
- `chibi_outline.gdshader`: inverted-hull outline capability for important characters, tools and interactables.
- `chibi_foliage.gdshader`: gentle deterministic visual wind for foliage.
- `chibi_water.gdshader`: shallow wave and foam treatment.
- `chibi_dither_fade.gdshader`: fade capability for tall view blockers.

`ChibiMaterialFactory` creates independent `ShaderMaterial` instances from the palette. C0 provides the capability only; the user-facing outline setting and runtime application of these materials are deferred to later graphics/UI milestones.

## Primitive construction and budgets

All C0 geometry is built by `tools/art/chibi/chibi_mesh_builder.gd` from Godot primitives, using deterministic parameters. It has no downloaded model dependency. Generated calibration assets use stable paths under `assets/generated/models/chibi_core/` and must be rebuilt with `tools\build_chibi_core.bat` when the generator changes.

| Category | Budget | Calibration asset | Actual triangles |
|---|---:|---|---:|
| Character | 6,000 | `chr_calibration.tscn` | 672 |
| Small prop | 1,500 | `prop_calibration_a.tscn` | 100 |
| Crop stage | 400 | `crp_calibration_s0.tscn` | 128 |
| Building | 8,000 | `bld_calibration_lv1.tscn` | 300 |
| Tree variant | 1,000 | `env_tree_calibration_01.tscn` | 220 |

The generated `manifest.json` records the same measured values. `ChibiMeshAudit` rejects missing geometry, invalid bounds/transforms, below-ground pivots and over-budget meshes. Later asset groups retain their game/data IDs and add their own calibration entries rather than replacing stable IDs.

## Animation guidance

Later character and world work should favor small toy-like motion: breathing/idle bob, a clear walk cycle, subtle foliage sway, and brief tool arcs. Animation must be view-only; domain state remains authoritative. C0 intentionally supplies no character/NPC gameplay animation.

## C1 character extension

C1 makes the character part of this contract concrete. `tools/art/chibi/chibi_character_builder.gd` produces original rounded-primitive chibi rigs with named `Rig`, `Body`, `Head`, `ArmLeft`, `ArmRight`, `LegLeft`, `LegRight`, `Accessory` and `Face` pivots. Generated scenes live under `assets/generated/models/characters/` and must be rebuilt with `tools\build_chibi_characters.bat` after builder/data changes.

| Character asset | Role / recognition cue | Actual triangles | Budget |
|---|---|---:|---:|
| `chr_player_base.tscn` | compact straw hat, leaf accent and customizable hair/colors | 2,808 | 6,000 |
| `chr_an.tscn` | round chef hat and apron | 3,120 | 6,000 |
| `chr_lam.tscn` | tool belt and pencil silhouette | 2,820 | 6,000 |
| `chr_linh.tscn` | flower crown / nature palette | 3,240 | 6,000 |
| `chr_minh.tscn` | merchant pack and hat | 2,820 | 6,000 |
| `pet_dog.tscn` | small dog calibration/reference silhouette only | 2,052 | 6,000 |

The player selector offers six data-defined hair styles, skin tones, hair colors and outfit colors. Face parts sit immediately over the rounded head surface and are raised toward the fixed camera; a compact, slightly rear-shifted straw hat keeps eyes and cheeks readable. `ChibiAvatar` uses `AnimationPlayer` clips for `Idle`, `Walk`, `Run`, `Tool`, `Sleep` and `Talk`, snaps visual facing to eight directions, and creates held tools/reaction bubbles as transient view details. No C1 animation, expression or accessory changes domain state.

The dog is deliberately art calibration only. It is not a pet implementation and has no runtime follow/name/collision/save behavior until Roadmap 8.5 is separately approved.

## C1 visual review procedure

1. Run `tools\build_chibi_characters.bat` after C1 builder/catalog changes.
2. Run `tools\art_review_characters.bat` with the normal renderer, never `--headless`.
3. Inspect the lineup and six focused sheets under `screenshots/chibi-characters/`. Each sheet has daytime and night rows; its first tile preserves the 45-degree yaw / 35-degree gameplay pitch and the three supporting tiles expose the face and silhouette.
4. The same command captures the configured real `main.tscn` through a review-only project argument. This capture has no save mutation and is supplemental integration evidence, not a replacement for game playtesting.
5. Run `tools\run_tests.bat`. The C1 tests audit generated meshes/budgets/pivots/head ratio, profile fallback/save round-trip, runtime avatar clips/face/bubble, existing anchors and all three selector resolutions.

## Visual review procedure

1. Run `tools\build_chibi_core.bat` after generator changes.
2. Run `tools\art_review.bat` with a normal graphics renderer, never `--headless`.
3. Inspect the lineup sheet and five model sheets under `screenshots/chibi-core/`: four camera angles in the top daytime row and four matching night views below.
4. Run `tools\run_tests.bat`; the C0 tests load each model, check its bounds/pivot/budget, verify shader material usage, and bind the generated materials to a viewport.

The contact sheets are an isolated calibration diorama, not proof of integration in `main.tscn`; real-world scene review is deferred until the corresponding world/character milestone. The screenshots directory is intentionally ignored. Do not call art “finished” solely because it loads: inspect readability, silhouette, clipping, shadows, palette balance and scale. Keep visual corrections focused and record the actual review result in `PROGRESS.md`; use at most three correction rounds per asset group.
