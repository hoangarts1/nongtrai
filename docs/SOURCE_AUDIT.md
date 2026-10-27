# Source audit inventory ? 2026-10-26

Readable project-owned code/content reviewed for roadmap coverage. Vendor addons, generated Godot cache, Git internals and starter/reference duplicates are excluded. Binary art/font content is inspected by metadata or rendering.

| Folder | Files | Lines |
|---|---:|---:|
| scripts | 66 | 5742 |
| data | 42 | 598 |
| tools | 6 | 285 |
| scenes | 4 | 480 |
| tests | 44 | 2313 |

## Code responsibilities

- `scripts/components/interaction_prompt.gd` ? InteractionPrompt — reusable UI prompt for nearby interactions.. Methods: _ready, show_prompt, hide_prompt.
- `scripts/core/audio_service.gd` ? AudioService — optional data-driven placeholder audio playback.. Methods: play_sound.
- `scripts/core/data_registry.gd` ? DataRegistry — runtime item and crop data lookup.. Methods: _ready, get_item, get_crop, get_crop_for_seed, get_all_items, get_all_crops, get_seed_items, get_tool, get_season, get_starter_seed_for_season, get_quest, get_all_quests.
- `scripts/core/data_validator.gd` ? DataValidator — validates shipped gameplay Resources before tests or builds.. Methods: validate_item_resources, validate_item_paths, validate_crop_references, validate_crop_paths, validate_translation_keys, validate_weather_profile, validate_quest_resources, validate_quest_paths, validate_npc_world, validate_vietnamese_values, _read_translation_values, _parse_csv_line, _resource_identifier, _is_snake_case.
- `scripts/core/events.gd` ? Events — typed cross-system signal bus.. Methods: .
- `scripts/core/game_clock.gd` ? GameClock — owns the in-game day clock and morning rollover.. Methods: _process, advance_real_seconds, advance_minutes, sleep_to_morning, can_sleep, try_sleep, is_sleeping, _finish_sleep, set_time, set_speed, get_hour, get_minute_in_hour, format_time, serialize, deserialize, get_day_in_season, _update_season.
- `scripts/core/localization.gd` ? Localization — runtime translation registry for the player-facing UI.. Methods: _ready, apply_default_locale, load_translations, _load_translations, _read_translation, _parse_csv_line.
- `scripts/core/save_service.gd` ? SaveService — validates, migrates and atomically stores JSON save payloads.. Methods: save_game, load_game, has_save, load_latest, get_latest_summary, delete_save, _migrate, migrate_3_to_4, _save_path, _rotate_backups.
- `scripts/core/settings.gd` ? Settings — persistent player preferences.. Methods: _ready, is_tutorial_dismissed, set_tutorial_dismissed, get_locale, set_locale, get_music_volume, set_music_volume, get_effects_volume, set_effects_volume.
- `scripts/data/crop_data.gd` ? CropData — data-only definition for a plantable crop.. Methods: .
- `scripts/data/day_night_profile.gd` ? DayNightProfile — data-driven keyframes for world lighting.. Methods: sample.
- `scripts/data/dialogue_data.gd` ? DialogueData — localized, conditional dialogue and optional quest action.. Methods: .
- `scripts/data/item_data.gd` ? ItemData — data-only definition of an inventory item.. Methods: .
- `scripts/data/merchant_offer_data.gd` ? MerchantOfferData — isolated daily trade quote; never mutates ItemData prices.. Methods: .
- `scripts/data/npc_data.gd` ? NpcData — data-only definition of a villager: home, schedule, rain behaviour, friendship.. Methods: .
- `scripts/data/npc_schedule_entry.gd` ? NpcScheduleEntry — one data-defined time block in an NPC daily schedule.. Methods: applies_to.
- `scripts/data/npc_world_data.gd` ? NpcWorldData — declared Phase 8 content, navigation and schedule parameters.. Methods: .
- `scripts/data/quest_data.gd` ? QuestData — data-only definition of a quest with requirements and rewards.. Methods: .
- `scripts/data/season_data.gd` ? SeasonData — data for one playable season.. Methods: .
- `scripts/data/tool_data.gd` ? ToolData — data-only definition for a farm tool.. Methods: .
- `scripts/data/weather_profile.gd` ? WeatherProfile — probabilities and visual effects for each weather id.. Methods: get_entry.
- `scripts/data/world_locations.gd` ? WorldLocations — named world positions and the walkable navigation grid for NPCs.. Methods: has_location, get_location_position.
- `scripts/domain/day_simulator.gd` ? DaySimulator — advances farm state once at the morning boundary.. Methods: simulate_day.
- `scripts/domain/economy/wallet_state.gd` ? WalletState — manages player coins, atomic spend/earn, and serialization.. Methods: _init, get_coins, add_coins, remove_coins, has_coins, can_afford, serialize, deserialize.
- `scripts/domain/farm_grid_state.gd` ? FarmGridState — till, plant, water and harvest farm plots.. Methods: get_plot, reset, till_cell, plant_crop, water_cell, water_all_crops, mark_out_of_season, clear_withered, advance_day, can_harvest, get_growth_remaining, get_harvest_payload, harvest_cell, serialize, deserialize.
- `scripts/domain/inventory_state.gd` ? InventoryState — slot-limited, stackable inventory domain state.. Methods: _init, add_item, can_add_item, remove_item, has_item, get_quantity, get_slots, clear, serialize, deserialize, _emit_changed.
- `scripts/domain/quests/det_random.gd` ? DetRandom — stable seeded streams for Phase 8 daily stock.. Methods: mix, make_rng.
- `scripts/domain/quests/merchant_service.gd` ? MerchantService — deterministic daily trade with finite saved stock.. Methods: get_offer, is_consumed, confirm_trade, serialize, deserialize.
- `scripts/domain/quests/npc_schedule.gd` ? NpcSchedule — pure schedule resolution and obstacle-aware cell routing.. Methods: configure, destination, location_cell, route.
- `scripts/domain/quests/npc_social_state.gd` ? NpcSocialState — authoritative friendship, dialogue history and NPC cells.. Methods: configure, _on_quest_accepted, _on_quest_completed, get_npc, get_dialogue, talk, update_schedule, advance_step, is_indoors, serialize, deserialize, _dictionary.
- `scripts/domain/quests/quest_manager.gd` ? QuestManager — tracks accepted quests, delivery validation, and atomic reward payout.. Methods: register_quest, get_quest, accept_quest, is_quest_active, is_quest_completed, get_active_quest_ids, get_completed_quest_ids, can_deliver, confirm_delivery, serialize, deserialize.
- `scripts/domain/tool_action.gd` ? ToolAction — pure farm action dispatcher for the MVP tools.. Methods: is_in_reach, apply.
- `scripts/domain/tutorial_quest_state.gd` ? TutorialQuestState — tracks the five farming onboarding milestones.. Methods: _init, is_step_completed, is_complete, serialize, deserialize, _complete_step, _on_plot_tilled, _on_crop_planted, _on_plot_watered, _on_sleep_finished, _on_crop_harvested, _on_item_sold, _on_item_purchased.
- `scripts/domain/weather_state.gd` ? WeatherState — seeded current weather and saved forecasts.. Methods: configure, advance_day, force_weather, is_rainy, is_stormy, get_entry, serialize, deserialize, _roll_forecast, _roll_weather, _string_array.
- `scripts/player/player.gd` ? Player — camera-relative CharacterBody3D controller for the gray-box MVP.. Methods: _ready, _physics_process, camera_relative_direction.
- `scripts/player/player_config.gd` ? PlayerConfig — tunable movement values for the placeholder player.. Methods: .
- `scripts/util/grid_math.gd` ? GridMath — converts between logical XZ cells and world positions.. Methods: world_to_cell, cell_to_world, footprint_cells.
- `scripts/view/camera_rig.gd` ? CameraRig — smooth orthographic follow with a fixed map-safe center.. Methods: set_target, _process, _safe_center.
- `scripts/view/chibi_avatar.gd` ? ChibiAvatar — procedural cozy character and view-only idle/walk animation.. Methods: configure, _process, _ellipsoid, _part.
- `scripts/view/clock_hud.gd` ? ClockHud — small gray-box readout for validating GameClock behavior.. Methods: _ready, _on_time_changed, _period_key.
- `scripts/view/debug_menu.gd` ? DebugMenu — debug-only developer controls built from registered actions.. Methods: _ready, _unhandled_input, _process, configure, configure_inventory, configure_wallet, configure_farm, configure_save_load, configure_weather, register_action, _build_base_ui, _add_action_button, _register_default_actions, _set_time, _toggle_pause, _start_next_day, _move_near_house, _hoe_all, _water_all, _grow_one_day, _reset_farm, _add_all_seeds, _update_status.
- `scripts/view/farm_view.gd` ? FarmView — placeholder grid renderer driven by FarmGridState.. Methods: _ready, configure, get_cell_view, get_crop_view, get_crop_label, _build_grid, set_hovered_cell, is_target_highlight_visible, is_target_in_reach, _render_all, _on_plot_changed, _render_cell.
- `scripts/view/feedback_popup.gd` ? FeedbackPopup — short player-facing feedback for domain results.. Methods: _ready, configure, show_message, _on_item_added.
- `scripts/view/gray_box_world.gd` ? GrayBoxWorld — minimal 3D test world for the MVP.. Methods: _ready, _process, _unhandled_input, _update_interaction_prompt, _on_sleep_started, _on_sleep_finished, _on_time_changed, _apply_day_night, get_day_night_lighting, _on_weather_changed, is_player_near_interactable, pick_cell.
- `scripts/view/hotbar_panel.gd` ? HotbarPanel — selectable view of inventory stacks for tool/item selection.. Methods: _ready, configure, get_selected_slot, _build_ui, register_tool, _on_inventory_changed, _render_slots, refresh_readability, _unhandled_input, _select_slot.
- `scripts/view/hud_button_bar.gd` ? HudButtonBar — shared bottom-corner button bar for player-facing HUD actions.. Methods: _ready, _process, register_button, set_button_active, get_button, _build_ui.
- `scripts/view/inventory_panel.gd` ? InventoryPanel — fixed header/close button with a scrollable inventory list.. Methods: _ready, configure, _unhandled_input, toggle_inventory, close_inventory, _build_ui, _on_inventory_changed, _update_list.
- `scripts/view/main.gd` ? Main — wires shared debug tooling to the active gray-box world.. Methods: _process, _notification, _save_before_exit, _ready, _on_day_started, _on_season_changed, _save_game, _save_game_to_slot, _load_game, _load_game_from_slot, _quit_game, _start_new_game, _continue_game, _return_to_start_menu, _load_payload, _mark_save_dirty, _show_toast.
- `scripts/view/npc_actor.gd` ? NpcActor — placeholder and route interpolation; logical cells live in NpcSocialState.. Methods: configure, _process, reset_position.
- `scripts/view/npc_panel.gd` ? NpcPanel — scrollable dialogue/journal surface, no gameplay state.. Methods: _ready, show_content.
- `scripts/view/npc_system.gd` ? NpcSystem — wires Phase 8 domain, placeholder actors and modal requests.. Methods: configure, _process, _input, _unhandled_input, _can_open, _nearest_npc, is_open, _lock, close_panels, open_journal, open_dialogue, _render_dialogue, _item_name, _accept_quest, _deliver, _trade, _time_changed, _weather_changed, _refresh_schedule, restore, _state_changed, debug_visit, debug_delivery_items, debug_journal, _add_home.
- `scripts/view/pause_menu.gd` ? PauseMenu — pause controls and settings overlay.. Methods: _ready, configure, _unhandled_input, toggle, open, close, _set_player_locked, _build_ui, _add_button, _add_slider, _toggle_settings.
- `scripts/view/quest_panel.gd` ? QuestPanel — displays the current farming onboarding checklist.. Methods: _ready, configure, set_help_suppressed, _build_ui, _render, _on_step_changed, _on_all_completed.
- `scripts/view/seed_shop_panel.gd` ? SeedShopPanel — modal UI for purchasing seeds plantable in the current season.. Methods: _ready, configure, open, close, toggle, is_open, _unhandled_input, _on_wallet_changed, _on_inventory_changed, _build_ui, _update_wallet_label, _render, _is_item_in_season, _select_item, _change_quantity, _set_max_quantity, _update_detail, _confirm_purchase, try_buy_item.
- `scripts/view/shipping_bin_panel.gd` ? ShippingBinPanel — modal UI for selling inventory items through the shipping bin.. Methods: _ready, configure, open, close, toggle, is_open, _unhandled_input, _on_inventory_changed, _build_ui, _render, _select_item, _change_quantity, _set_max_quantity, _update_detail, _confirm_sale.
- `scripts/view/start_menu.gd` ? StartMenu — new-game and continue entry screen.. Methods: _ready, apply_chibi_style, configure, refresh_continue, _build_ui, _show_new_game_fields, _toggle_settings, _continue_summary, _add_slider.
- `scripts/view/title_backdrop.gd` ? TitleBackdrop — illustrated opening screen; decoration never receives input.. Methods: _ready, _process, _draw.
- `scripts/view/tool_action_controller.gd` ? ToolActionController — connects hotbar tools, mouse targeting and farm actions.. Methods: configure, _on_slot_selected, select_tool, select_seed, get_selected_tool, _process, _unhandled_input, _can_apply_drag, _apply_drag_cell, _use_selected_tool, _harvest_selected_crop, _show_feedback, _play_sound, _reach_for_selected_tool, _is_input_locked.
- `scripts/view/tool_drag_stroke.gd` ? ToolDragStroke — deduplicates cells crossed by held left mouse input and delegates the existing action path.. Methods: handle, _handle_button, _handle_motion, _apply_once, _pick_cell, _end.
- `scripts/view/tutorial_panel.gd` ? TutorialPanel — first-run and repeatable controls help.. Methods: _ready, configure, configure_modal, _unhandled_input, open_help, close_help, is_help_open, _build_ui, _build_instruction_text, _key_for_action, _format_input_event, _key_name, _tool_binding_text, _keys_for_action, _keys_for_hotbar.
- `scripts/view/ui_coordinator.gd` ? UiCoordinator — one modal at a time and a single UI input/visibility lock.. Methods: configure, get_active_panel, _resize, _queue_layout, _visibility_changed, _close, close_active, _process, _sync, _input.
- `scripts/view/ui_icons.gd` ? UiIcons — original local SVG textures; UI keeps localized tooltips.. Methods: get_icon, for_item, decorate.
- `scripts/view/ui_layout.gd` ? UiLayout — readable runtime theme and viewport-based HUD/modal rectangles.. Methods: apply, _surface, _style_children, reflow, _rect.
- `scripts/view/wallet_hud.gd` ? WalletHud — displays player's coin balance on the HUD.. Methods: configure, _on_coins_changed, _render.
- `scripts/view/weather_fx.gd` ? WeatherFx — placeholder rain and storm presentation driven by WeatherState.. Methods: _ready, configure, _on_weather_changed.
- `scripts/view/weather_hud.gd` ? WeatherHud — localized current weather and next-day forecast.. Methods: configure, _refresh, _on_forecast_updated, _weather_name.
- `scripts/view/world_presentation.gd` ? WorldPresentation — handmade procedural scenery; no gameplay state or collision changes.. Methods: configure, _tree, _box, _mesh.
