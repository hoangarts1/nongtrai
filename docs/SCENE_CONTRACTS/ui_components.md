# ISO-2 reusable UI contracts

Approved ISO-2 scope: ui/components/**, ui/theme/** and ui/ui_gallery.*. These are VIEW-only Controls. They never mutate inventory, coins, crops, clock, save data or InputMap. Every component scene has its own script; decorative children ignore mouse input. Components use the shared the_life_theme.tres and theme_type_variation, never per-node StyleBox overrides.

## Component catalogue

All paths below are under ui/components/ with matching .tscn/.gd names. Runtime children are built in code; callers use typed fields/methods rather than undocumented paths.

| Scene / class | Root | Runtime children / view API |
|---|---|---|
| panel_wood / LifePanelWood | PanelContainer | content container supplied by caller; shared wood/paper frame |
| banner / LifeBanner | PanelContainer | Caption Label; set_caption(key), set_tone(green/red/blue) |
| btn_primary / LifeBtnPrimary | Button | LifeButtonBase localized text_key; set_preview_state for gallery only |
| btn_secondary / LifeBtnSecondary | Button | same button API, wood tone |
| btn_danger / LifeBtnDanger | Button | same button API, red tone |
| btn_accent / LifeBtnAccent | Button | same button API, yellow tone |
| btn_round_hud / LifeBtnRoundHud | Button | icon placeholder + Key Label; set_hint(action); native pressed signal |
| item_slot / LifeItemSlot | Button | CenterContainer/Icon placeholder or texture, QuantityInset/Quantity, Lock; set_item(id, quantity, name_key, icon), set_state; slot_requested(item_id: StringName) |
| progress_bar_styled / LifeProgressBar | ProgressBar | set_displayed_value(current, maximum), set_tone(green/blue/gold) |
| toggle_on_off / LifeToggle | CheckButton | localized on/off labels, native toggled(bool) |
| slider_styled / LifeSlider | HSlider | native value_changed(float); presentation only |
| heart_row / LifeHeartRow | Control | five drawn hearts; set_hearts(count: int), no friendship calculation |
| key_hint / LifeKeyHint | PanelContainer | Caption Label; set_action(action: StringName) reads existing InputMap only |
| pill / LifePill | PanelContainer | Caption Label; localized text_key, display_value and set_value(value: int) |
| tag / LifeTag | PanelContainer | Caption Label; localized text_key and new/main tone |
| coin_label / LifeCoinLabel | HBoxContainer | Icon, Amount Label; set_coins(value: int) formats read-only quantity |
| tab_bar / LifeTabBar | HBoxContainer | Tab_0…Tab_4 Buttons; set_active(index); tab_requested(index: int); no new Q/E input actions |

Helpers icon_placeholder (Control/scene) and component_button.gd (LifeButtonBase) live in the same directory. The icon helper draws a 32×32 two-tone outlined circle/initial when final icon PNGs are absent. It can be replaced by Texture2D without changing a component's public API.

Style variants live in the shared Theme: LifePrimary/Secondary/Danger/Accent, their preview-hover/pressed variants, LifeRound, LifeItemSlot/Selected/Locked, LifeProgressGreen/Blue/Gold, LifeWood, LifeBannerGreen/Red/Blue, LifePill, LifeTagNew/Main, LifeKeyHint, LifeHeading/Title/SecondaryText/Small/Quantity and world-label variants. Root theme assignment does not introduce gameplay ownership.

Frame margins are 28 px for reusable wood panels. Existing game panels use a compact variation during ISO-2 to preserve their tested footprints; later HUD/modal layout conversion remains ISO-3 onward. Nine-slice textures may replace StyleBoxFlat later through the Theme alone. All captions use localization keys in both CSVs.

ISO-3 consumer: `ui/hud/` composes these shared resources with dedicated HUD type variations. It uses existing SVG artwork for toolbar/round/coin icons and Theme-backed wood/paper surfaces. CoinLabel's documented Icon child may be hidden by the HUD in favor of the existing coin SVG; its integer formatter remains unchanged. Key hints now read the implemented B/I/Tab binding; no calendar/map/tab action is added. See `hud.md` for the active composition and adapter contracts.
