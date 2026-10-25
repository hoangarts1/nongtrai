# HUD layout

The HUD uses viewport anchors and containers so panels do not depend on a
single window size.

| Region | Component | Rule |
|---|---|---|
| Top-left | `ClockHud` | Anchored to `(0, 0)` with a small margin |
| Top-right | `DebugMenu` | Anchored to `(1, 0)`, hidden by default and debug-only |
| Left-middle | `QuestPanel` | Reserved for the current farming checklist |
| Center | `TutorialPanel` / `InventoryPanel` | Centered modal panels; inventory has a close button |
| Bottom-center | `HotbarPanel` | Centered above the bottom safe margin |
| Above bottom-center | `InteractionPrompt` | Positioned above the hotbar, never in its rectangle |
| Bottom-right | `HudButtonBar` | Anchored to `(1, 1)` with a safe margin |

Panels must use `Container` children for internal layout. New HUD controls
must register in the existing bars or use a documented region; they must not
introduce screen-space coordinates that overlap another region.
