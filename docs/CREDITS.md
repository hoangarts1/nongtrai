# CREDITS & LICENSES

## D72 inherited 2D visual work and C1 completion

Inherited avatar/hair/world/crop/machine/frame drawing and five draft PNGs are project-authored procedural work from the other coding agent's D72 slice. tools/build_isometric_2d_assets.gd reproducibly generates cottage160x140, market140x128, bin96x88, farmer sheet256x64 and wood frame96x96 under existing assets folders. They remain offline/draft outputs; active runtime components still draw their procedural visuals and use existing supplied crops/machine textures/shared Theme/fonts.

C1 retains those source images/imports and art direction, completes pointer/animation lifecycle and generator verification, and adds no externally sourced art/font/audio or license dependency. Separate inherited28-file and completion diff/artifacts are listed in PROGRESS; no claim is made that draft PNGs replaced runtime/customization renderers.

## Phase6.5g bag upgrade panel

No new external/generated bitmap, font, audio or source asset. New bag upgrade scenes reuse existing shared wood/paper/blue-banner Theme, native Godot controls and project fonts. New vi/en interface text is project-authored. Existing bag icons/grid assets are not edited. Screenshot review and validation are recorded in PROGRESS.

## Phase6.4b land panel

No new external/generated raster, font, audio or licensed asset. New land controls reuse the project's existing shared wood/paper Theme, native Godot controls and existing fonts. Generated passive scenery is rebuilt from existing assets without editing/deleting them; no source-art ownership or license changes. New vi/en interface text is project-authored. See PROGRESS for screenshot review and automated status.

Phase6.4a (2026-11-04): new land data/domain/test code introduces no external/generated art, font, audio, addon or license dependency. Existing world/NPC-world Resources are read-only validation context; no terrain or scene asset is modified.

Add a row EVERY time an outside asset, font, addon or sound enters the project. Keep a copy of each license text/page. Unknown source = do not use.

Phase6.5f reuse (2026-11-04): idle-machine Move reuses the existing projected idle sprite/pivot, isometric adapter, modal/status controls and shared Theme/reference10 styling. The original world machine remains visible during preview. No new outside/generated asset, font, addon, scene texture or license claim.

Phase6.5e reuse (2026-11-04): mouse placement projects the same supplied machine idle sprites/pivot and existing Theme colors/buttons/paper/wood styles. No new outside/generated asset, font, addon or license claim; the preview is drawn in Godot through the existing isometric adapter.

Phase6.5c reuse (2026-11-04): the modular machine UI reuses the existing shared Theme/fonts and project-supplied `assets/machines/` sprites resolved through `machines_manifest.json`. Existing registered item icons remain the processed-product fallback. Reference `docs/ui_reference/10-cua-hang.png` guides layout only and is not embedded as a texture. This slice introduces no downloaded/generated asset, font, addon or new license claim.

| Asset / addon | Type | Author | License | URL | Date taken | Changes made | Used in |
|---|---|---|---|---|---|---|---|
| Godot Engine | engine | Godot Engine contributors | MIT (include the license notice as required) | https://godotengine.org | | none | everything |
| Open Sans | font | The Open Sans Project | SIL Open Font License 1.1 | https://openfontlicense.org | 2026-10-25 | copied `OpenSans-Regular.ttf` | UI |
| GUT 9.7.1 | addon | GUT contributors | MIT | https://github.com/bitwes/Gut/releases/tag/v9.7.1 | 2026-10-25 | none | tests only |
| title_valley.png | generated illustration | Generated for this project with built-in image_gen | Generated output; tool terms review remains a release checklist item | Project-local prompt: assets/ui/title_valley.prompt.txt | 2026-10-26 | none; original copied into workspace | title screen |
| ui_*.svg (22 icons) | original vector UI art | Created in this project | Original project artwork; no third-party pack | assets/icons/ | 2026-10-26 | original SVG drawings | HUD, tools, inventory, shop, title buttons |
| ChibiAvatar / WorldPresentation | procedural mesh art | Created in this project | Original project artwork; no external model download | scripts/view/chibi_avatar.gd; world_presentation.gd | 2026-10-26 | code-built character, cottage, stall, chest and trees | in-game 3D presentation |
| hoe.wav, seed.wav, water.wav, harvest.wav | original generated sound effects | Created in this project | Original project audio; no third-party samples | tools/build_audio.gd | 2026-10-27 | deterministic PCM WAV synthesis | farming actions |
| C0 chibi palette, shaders and calibration models | procedural art/tooling | Created in this project | Original project artwork; no third-party model or texture source | data/art/palette/chibi_valley.tres; tools/art/chibi/; assets/generated/ | 2026-10-27 | deterministic Godot primitive/shader generation | C0 calibration/review only |
| C1 chibi character models and review sheets | procedural model art/tooling | Created in this project | Original project artwork; no third-party model, texture or motion source | tools/art/chibi/chibi_character_builder.gd; data/art/characters/; assets/generated/models/characters/ | 2026-10-28 | deterministic rounded primitives, pivot clips and normal-renderer review capture | player/NPC character presentation and C1 art review |
| C2 crop, item, tool models and stickers | procedural model/2D icon art | Created in this project | Original project artwork; no third-party model, texture or icon source | tools/art/chibi/chibi_farming_builder.gd; data/art/farming/; assets/generated/models/farming/; assets/generated/icons/ | 2026-10-29 | deterministic rounded primitives and 128 px transparent sticker baking | farm crop/item/tool presentation and C2 art review |
| C3 world, building, prop, critter models and seasonal review | procedural model/art tooling | Created in this project | Original project artwork; no third-party model, texture or audio source | tools/art/chibi/chibi_world_builder.gd; data/art/world/; assets/generated/models/world/ | 2026-10-29 | deterministic rounded primitives, bounded seasonal view effects and normal-renderer review capture | C3 world presentation and art review |
| C4 cursor and UI motion | code-drawn UI art | Created in this project | Original project artwork; no third-party cursor, icon pack or motion library | scripts/view/chibi_cursor.gd; chibi_ui_motion.gd | 2026-10-30 | original paw/tool cursor, Control tween wiring and native-theme presentation | C4 UI presentation |
| Baloo 2 variable | font | The Baloo 2 Project Authors / Ek Type | SIL Open Font License 1.1; notice in assets/fonts/Baloo_2/OFL.txt | https://github.com/google/fonts/tree/main/ofl/baloo2 | 2026-11-03 | unchanged binary, filename normalized to Baloo2-Variable.ttf; weight 800 via FontVariation | ISO-2 headings/title |
| Nunito variable | font | The Nunito Project Authors; Vernon Adams, Cyreal, Jacques Le Bailly | SIL Open Font License 1.1; notice in assets/fonts/Nunito/OFL.txt | https://github.com/google/fonts/tree/main/ofl/nunito | 2026-11-03 | unchanged binary, filename normalized to Nunito-Variable.ttf; weight 600 via FontVariation | ISO-2 body text |
| Noto Serif Italic variable | font | The Noto Project Authors / Google | SIL Open Font License 1.1; notice in assets/fonts/Noto_Serif/OFL.txt | https://github.com/google/fonts/tree/main/ofl/notoserif | 2026-11-03 | unchanged binary, filename normalized to NotoSerif-Italic-Variable.ttf; weight 400 | ISO-2 secondary italic text |
| ISO-2 shared Theme, component placeholders and gallery | code-drawn UI artwork | Created in this project | Original project artwork; no third-party icon/frame pack | ui/theme/theme_factory.gd; ui/components/; ui/ui_gallery.tscn | 2026-11-03 | deterministic StyleBoxFlat frames, circle/initial icons, toggle/slider/heart drawing | ISO-2 reusable UI foundation |

Rules
- Check the license of EACH pack individually (a site being "mostly CC0" is not enough); commercial use must be allowed.
- AI-generated assets/music: read the tool's terms for commercial use before shipping.
- This file also feeds the in-game Credits screen.
