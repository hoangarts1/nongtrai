# Inherited D72 visuals and C1 completion (D73)

## AUDIT-F1 crop rendering and care alignment (D87)

No existing scene/PNG/font/Theme/camera edit. CropPresentation uses the new DATA stage config and pure stage rules. Normal first-growth art advances at quarters, while mature metadata and actual harvest wait for the full target. Repeat state from the existing plot keeps image3, including wilted variants, until image4 at actual readiness. Both tomato IDs and the five supplied perennials follow this rule. Texture basename/pivot/click root remain unchanged. FarmGridState uses the matching boundary predicate for care, preserving moisture/grace/dry-limit/death and existing day/save behavior. Current stage/ready flags are derived, never persisted. Test/capture results remain pending until recorded in PROGRESS.

## D83 coop presentation
New ChickenCoopSiteView is projected through the shared grid at the data footprint, grounded in objects y-sort and outside WorldArt2D. Passive scenery excludes approved site/route shoulders; no saved actor/plot/machine removed. Actual hens/fed status drive code-native warm wood/hen illustration; cosmetic motion freezes when paused. No existing PNG/renderer/Theme/font is replaced.


## Phase6.5h2a source art and larger terrain (D77)

Ground expands85×85; player roaming39×39; only43×43 receives passive scenery. Existing imported ground variants and unchanged-cell hash variants remain; source footprints/banks/routes are excluded from trees/rocks/grass. This intentionally clears approved access corridors, not owned farmland/progress. No PNG/Theme/font/avatar/crop/machine renderer change.

WaterSourceView uses procedural well and water/shore/path polygons projected with actual Ground.map_to_local/to_global and shared diamond helper. Generated floor views belong to the existing WorldCanvas, z=-15 between Ground and Farmland; the well's tall art joins Objects y-sort at ground cell. Plain translated source labels update live; ripple phase is cosmetic and pauses with GameClock. No per-source crop/machine clock or gameplay state/refill prompt.

Inspect actual source-centered vi/en1152/1600 and overview captures, camera transforms/picking at all five zoom levels, safe dry-bank access and preserved old anchors. Ground is finite; extreme overview/pan may show edges. No editor wiring; see water_sources.md and PROGRESS for measured evidence/remaining human F5.

## D72-C4 live-language label/feedback correction (D76)

No scene/tree/Inspector/InputMap/Theme/localization-file edit. Existing WorldPresentation-created House/SeedShop/ShippingBin art labels and NpcSystem.homes labels respond to the existing translation notification, using current profile name/NpcData and existing keys. The same nodes/positions/colors/colliders/appearance and paused animation phases remain. Requesting redraw updates the decorative label pill while paused; it does not reconfigure/reset art. Empty/unconfigured/teardown states are guarded. Player-authored names stay unchanged.

Existing HudRoot.toasts dismisses old formatted messages on an actual locale change. Hide immediately during tree notification, free captured old IDs afterward; show_message flushes only dismissed IDs before adding new cards. Three-second/max-two and same-locale lifetime stay unchanged. Old deferred timer IDs cannot affect replacements. Public view APIs/signals remain; no event replay/metadata/Settings/domain/save change. Earlier startup-language residue described below is the historical C1/C3 limitation corrected here for these named labels and visible toasts, not a claim about every other UI/debug string.

Manual: on one running game with visible feedback, use existing pause/settings Apply to switch vi->en->vi; player/shop/bin/NPC-home signs change without reopening game, old toast disappears, subsequent feedback uses chosen language. Same-language Apply keeps existing feedback under normal max-two policy. Inspect paused pill text/geometry and preserve current player name/location/appearance/items/coins/crops/jobs/NPC state. No editor wiring. Full measured proof/status in PROGRESS.

## D72-C3 current toolbar selection (D75)

Existing node tree/scene/public signals/methods stay unchanged. Eight buttons comprise four tools0-3 (hoe/shovel/watering/harvest), then four item buttons4-7. Display selection uses the same four-tool offset as request; caption/tooltip/icon/quantity and selected style correspond to the real item. Invalid/empty/out-of-window selection clears selected styling and resets caption through the existing UI_TOOL_SEED translation. No new label, key, Resource, asset or Theme binding.

HotbarPanel select/remap derives pages from actual four item buttons: bag0-3/page0,4-7/page4,8-11/page8. Legacy physical9 still selects bag8, now visible button4 (key5); the previous display offset/page5 defect below is historical and corrected by D75. Native5-8/clicks/F-selection and page-local Shift/toolbar wheel resolve the same actual stacks; empty last-page slots cannot request nonexistent items. Domain state and camera/modal/placement behavior remain unchanged. No editor wiring/Inspector step. Manual: select first seed (button5, not harvest), cross bag3->4/7->8, try9/F/sort/discard, scroll both ways on partial pages, inspect vi/en caption/icon/quantity and empty bag fallback. Full proof in PROGRESS.

No .tscn or manual editor wiring. Keep the existing gray_box_world/player/HUD/profile/machine contracts and actual node fields. Main/domain/save-v9 ownership and scene paths are unchanged. CameraRig remains a Node driving the player's single Camera2D; no rotation or duplicated projection math.

Native wheel routing: map wheel zooms across0.35/0.5/0.75/1/1.25 (default0.5). Camera yields Shift and GUI-hover wheel; visible HotbarPanel directly handles qualified native events since tool_next/tool_prev have no bound physical events. One event changes one target once. Existing +/- actions remain. RMB/MMB drag uses actual zoom and Resource camera_pan_min/max=(-1400,-800)/(1400,800), with finite/ordered/zero-containing validation. Walking eases pan to zero; double-right/reset is immediate. Modal/sleep/movement gates win; placement receives RMB cancel, LMB remains farming. No new key/layer/signal/group/exported scene path.

MachinePresentation internal root is the existing Machines Node2D under world.objects. Each cell root remains grounded at world.cell_to_global; Sprite2D uses actual manifest pivot and existing texture paths. Working rows hold a read-only actual MachineState ref plus idle/work_a/work_b textures. Process synchronizes ready/idle state before pause gating, only cycles work textures while unpaused and disables itself when no working rows remain. Refresh resets transient timer/frame/rows. No job advance/output transfer/owner serialization/extra lookup mutation.

Inherited PlaceholderAvatar2D/AvatarHair2D/world/crop and LifeHudFrame/LifePanelWood custom draw remain active. Six appearance choices and actual colors are preserved. World cosmetic phases freeze under GameClock.paused; prior avatar feedback timers retain real-time semantics. Crops keep cell/offset/wither visibility; procedural UI uses existing Theme tokens/fonts. No renderer is silently replaced by a fixed character sheet that would drop customization.

Five PNGs from tools/build_isometric_2d_assets.gd are offline/draft outputs, currently unreferenced by live renderers: buildings cottage160x140/market140x128/bin96x88; character farmer_sheet256x64; UI frame96x96. Validator checks PNG bytes/existence/dimensions without resource-image export warnings. Generator supports --output-root=<path>, creates directories/checks writes, fails nonzero and prints PASS only on success. Two isolated regenerations must match inherited source hashes. Source PNG/imports/Theme/fonts remain protected.

Review matrix: actual world/crops/working machine/HUD at overview/default/close zoom, vi/en,1152x648/1600x900; bag, profile customization, night/rain. It renders real state, never embeds a mockup. Snapshot checks prove drawing doesn't advance/change farm/items/wallet/jobs/weather/clock. Screenshots and scope/diff/logs live in the external takeover verification directory recorded in PROGRESS. Map borders remain the inherited finite diamond; overview shows its edges. Lighting/terrain generation is unchanged.

Manual F5: wheel on map zooms; Shift+wheel or wheel over hotbar cycles only slots. Try +/- and all zoom limits, RMB/MMB pan, walking reset/double-right. Open bag/scroll, modal and placement: world camera stays locked, RMB placement cancel restores LMB farming. Start a real machine job, complete its actual day(s), see static ready frame and collect once; pause freezes cosmetic work frames. Inspect vi/en bag/profile/HUD and six hair choices. No editor setup; human playtest remains separate from automation.

D72-C1 cycle detail: HotbarPanel uses actual tool/selected inventory/window rather than the legacy display active_index, skips absent item slots and safely wraps into/out of the four displayed stacks. Historical C1 limitation, corrected by D75 above: the protected toolbar item highlight/caption offset marked the preceding slot although the actual selected item was correct. See PROGRESS for regression evidence and the scoped follow-up boundary.
