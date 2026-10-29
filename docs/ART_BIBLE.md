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

## C2 farming asset contract

- C2 uses the C0 palette and original rounded primitive construction. It supplies five visual states per registered crop: four growth stages (`0`–`3`) plus `withered`. The nine current crop ids retain their gameplay IDs and use one of `root`, `vine`, `stalk`, `grain`, `ground_vine` or `leafy` silhouette families from `chibi_farming_catalog.tres`.
- Crop pivots remain at soil level and stay below the existing `FarmView` logical crop root. That transparent root remains the selectable surface; model silhouette must never become a gameplay hit-test dependency.
- Stage progression is a visual mapping of the existing `FarmGridState` growth ratio. No duration, yield, watering, season, inventory or save value belongs to an art scene.
- Tilled furrows, wet-soil sheen, dew, mature sparkle/bob and hoe/seed/water/harvest effects are view-only. C2 effects have a bounded lifetime and are emitted only after the existing action succeeds.
- Each of the 18 seed/produce ItemData resources points at one generated grounded prop model and one transparent 128×128 PNG sticker. The sticker has a soft project-local outline/shadow and is preferred by the current icon service while SVG fallbacks remain available.
- The four held props are hoe, watering can, seed bag and harvest basket. They are compact, readable at the fixed 45°/35° camera and retain the C1 procedural fallback if a generated scene cannot load.
- Generated C2 source art lives in `assets/generated/models/farming/` and `assets/generated/icons/`. It is reproducible from data and code; do not hand-edit those generated scenes or PNGs.
- C2 audits every crop scene against the C0 crop budget of 400 triangles (current maximum: 292) and each item/tool prop against the C0 prop budget of 1,500 triangles (current maxima: 120 item, 96 tool). The build also rejects ungrounded, non-finite or empty models.

## C2 visual review procedure

1. Run `tools\build_chibi_farming.bat` after changing the C2 catalogue or builder.
2. Run `tools\art_review_farming.bat` with the normal renderer, never `--headless`.
3. Inspect the 14 ignored sheets under `screenshots/chibi-farming/`: one overview, nine crop focus sheets, three item groups and one tool group. Each has daytime and night rows across four review views.
4. Inspect `chibi_farming_main_scene.png` from the same command for the real `main.tscn` integration under its normal HUD/lighting. The private capture flag creates only an in-memory showcase and exits without loading or saving a slot.
5. Run `tools\run_tests.bat`. C2 tests audit all generated models/icons, visual data paths, crop picking, effect success/failure boundaries and review layout.

## C3 world asset contract

- C3 supplies original rounded-primitive scenes under `assets/generated/models/world/` for the player cottage, seed market, shipping bin, NPC cottage, inactive observatory, rounded tree, forest/cliff boundary, pond/bridge, path/fence and village props (well, lamp, mailbox, signpost, bench, woodpile, flowers and rock cluster), plus bird/butterfly/firefly silhouettes.
- All C3 model pivots meet the terrain at local `y = 0`; models are finite and audited against the existing C0 budgets: buildings <= 8,000 triangles, tree <= 1,000 triangles and small props <= 1,500 triangles. The C3 generated manifest records measured totals.
- `WorldArtCatalog` is presentation data only. Stable scene IDs and passive map placements belong there; crop/quest/economy/NPC schedule/navigation/farm-grid/time/weather/save values do not.
- Major model silhouettes are deliberately distinct at the fixed camera: player cottage has a warm rounded roof/chimney/porch, market has an awning and crates, bin has a lid/handle, homes have roof/window cues, observatory has a dome, pond/bridge separates blue water from path, and tree/rock/flower silhouettes retain readable floor contact.
- Four-season presentation is controlled by the existing clock and weather authorities. Spring uses light petals/flowers, summer uses richer green + daytime critters, autumn uses leaves/orange warmth, winter uses snow/cool water, and rainy weather adds only small visual water ripples.
- Ambient movement is toy-like and secondary: leaf/petal drift, bird/butterfly glide and night-only firefly twinkle. It is deterministic view motion with a catalog cap, never a gameplay random source.

## C3 visual review procedure

1. Run `tools\build_chibi_world.bat` after a C3 builder/catalog change.
2. Run `tools\art_review_world.bat` with a normal graphics renderer, never `--headless`.
3. Inspect the ignored sheets under `screenshots/chibi-world/`: building, terrain, village-prop, boundary/water and critter groups. Each sheet shows four views in day and night across the four seasons.
4. Inspect `chibi_world_main_scene.png` from the same command. Its private capture starts no save/slot flow and exits after an in-memory screenshot.
5. Run `tools\run_tests.bat`. C3 tests audit all generated world models/catalogue placements, anchor/marker preservation, seasonal view bounds and review layout; existing farm/NPC/merchant tests remain required.

The generated C3 source scenes retain the C0 toon, foliage, water and optional outline material vocabulary. Under the established main-world `DayNightProfile` lighting, the C0 toon/outline pass renders unreadably dark on C3 geometry, so `WorldArtFactory` creates a local readable `StandardMaterial3D` only for instantiated toon pieces. Foliage/water keep their matching lightweight shader treatment. This is a runtime presentation compatibility layer, not a palette fork, source-asset rewrite or gameplay-lighting change.

## C4 UI presentation contract

- C4 UI is original code/vector presentation, not a borrowed icon pack or a raster replacement for gameplay controls. Its cream surface, outline, purple-tinted shadow, sunlight highlight and peach accent resolve from the existing C0 palette roles; the shared Theme supplies the rounded pill silhouette and focus/disabled states.
- The cursor is a small code-drawn paw: four toe pads, a central pad and a compact selected-tool badge. It stays within a 38×42 px visual bound, uses no image asset, is non-interactive, and is deliberately less prominent than the player/crop/world art. The icon cue changes only after an existing tool button’s real `pressed` signal.
- UI motion is toy-like but restrained: button hover is at most 3.5% scale, press is at most 6% inward scale, and panel-open bounce starts at 97% before returning to 100%. These are Canvas presentation transforms only; Container geometry, click rects, modal ownership and keyboard input remain Godot-owned.
- Title styling favors readable Open Sans with an outline and a ±1.2% breathing scale instead of a separate logo bitmap. The title illustration remains the already-credited project-generated asset, while pointer-relative motes are code-drawn overlays.
- C4 review uses `tools\capture_chibi_ui.bat` on the normal Forward+ renderer plus layout/mouse regressions. Inspect title and HUD captures for clipped card corners, tooltip/focus contrast, oversized chrome, modal click-through and any cursor obstruction before accepting the milestone.
