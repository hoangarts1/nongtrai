# CREDITS & LICENSES

Add a row EVERY time an outside asset, font, addon or sound enters the project. Keep a copy of each license text/page. Unknown source = do not use.

| Asset / addon | Type | Author | License | URL | Date taken | Changes made | Used in |
|---|---|---|---|---|---|---|---|
| Godot Engine | engine | Godot Engine contributors | MIT (include the license notice as required) | https://godotengine.org | | none | everything |
| Open Sans | font | The Open Sans Project | SIL Open Font License 1.1 | https://openfontlicense.org | 2026-10-25 | copied `OpenSans-Regular.ttf` | UI |
| GUT 9.7.1 | addon | GUT contributors | MIT | https://github.com/bitwes/Gut/releases/tag/v9.7.1 | 2026-10-25 | none | tests only |
| title_valley.png | generated illustration | Generated for this project with built-in image_gen | Generated output; tool terms review remains a release checklist item | Project-local prompt: assets/ui/title_valley.prompt.txt | 2026-10-26 | none; original copied into workspace | title screen |
| ui_*.svg (22 icons) | original vector UI art | Created in this project | Original project artwork; no third-party pack | assets/icons/ | 2026-10-26 | original SVG drawings | HUD, tools, inventory, shop, title buttons |
| ChibiAvatar / WorldPresentation | procedural mesh art | Created in this project | Original project artwork; no external model download | scripts/view/chibi_avatar.gd; world_presentation.gd | 2026-10-26 | code-built character, cottage, stall, chest and trees | in-game 3D presentation |
| hoe.wav, seed.wav, water.wav, harvest.wav | original generated sound effects | Created in this project | Original project audio; no third-party samples | tools/build_audio.gd | 2026-10-27 | deterministic PCM WAV synthesis | farming actions |

Rules
- Check the license of EACH pack individually (a site being "mostly CC0" is not enough); commercial use must be allowed.
- AI-generated assets/music: read the tool's terms for commercial use before shipping.
- This file also feeds the in-game Credits screen.
