# ui_gallery.tscn — ISO-2 UI comparison scene

Path: ui/ui_gallery.tscn; root UIGallery (Control), script ui/ui_gallery.gd, class LifeUiGallery. This is a standalone review scene, not the project's main scene or a gameplay system.

## Tree

```text
UIGallery (Control, full rect; shared Theme)
├─ Background (ColorRect, full rect, ignores mouse)
└─ Margin (MarginContainer, full rect)
   └─ Scroll (ScrollContainer; horizontal disabled)
      └─ Content (VBoxContainer, expand horizontally)
         ├─ Header (LifeBanner)
         ├─ Subtitle (Label, localized review-only caption)
         ├─ Sections (GridContainer, responsive columns)
         │  └─ Section_<id> (LifePanelWood, runtime)
         │     └─ Content (VBoxContainer)
         │        └─ component instances / labels in state rows
         └─ Section_tabs (LifePanelWood, full width)
            └─ Content (VBoxContainer; heading and LifeTabBar)
```

Sections show button normal/hover/pressed/disabled states; empty/filled/selected/locked slots; three progress colors; slider/toggle/heart states; key hints/pills/tags/coins/tabs; all eight palette tokens; title/body/serif Vietnamese samples. Example numbers are clearly labelled as gallery samples, never read or written as game state. No new InputMap action is added.

Public review API: get_sections() -> Dictionary, rebuild() -> void. Inspector translation keys/styles remain localization- and Theme-owned. Screen layout uses anchors, containers and minimum sizes at 1152×648, 1280×720, 1920×1080, vi/en. A private --capture-ui-gallery argument writes review screenshots under user:// and quits; it requires a graphics renderer and never loads/writes a game save.

Manual review: open this scene and F6, scroll through every component/state, test actual Button/Toggle/Slider/Tab interactions and compare with docs/ui_reference/15-bo-ui-kit.png. Final UI sprites/frames are still placeholders.
