# ISO-10 character and relationships (D47)

Owner approved commit ISO-9 and implement ISO-10. ISO-9 commit ec3c6d3 records exactly44 files, owner master-plan edit excluded. Existing scenes/data/domain/core/avatars/art/Theme/save-v8 remain unchanged. Main constructs character_flow before inventory.attach_main/UiCoordinator.configure.

| Scene / class | Root | Typed view API |
|---|---|---|
| character_sheet / LifeCharacterSheet | VBoxContainer | tabs: LifeInventoryTabs; identity: LifeCharacterIdentity; skills: LifeCharacterSkills; relationships: LifeCharacterRelationships; hint: Label |
| identity_card / LifeCharacterIdentity | VBoxContainer | portrait: LifeCharacterPortrait; player_name/farm_name/note: Label; display(snapshot: Dictionary) -> void |
| avatar_portrait / LifeCharacterPortrait | PanelContainer | avatar: PlaceholderAvatar2D; stage: Control; display_player(selection: Dictionary), display_npc(id: StringName, fallback: Color) -> void |
| skills_panel / LifeCharacterSkills | VBoxContainer | heading/note: Label; rows: Array[LifeCharacterSkill]; refresh() -> void |
| skill_row / LifeCharacterSkill | PanelContainer | title/status: Label; display(key: StringName) -> void; unavailable labels only, no fake XP/bar/effect |
| relationship_list / LifeCharacterRelationships | VBoxContainer | heading/empty: Label; scroll: ScrollContainer; cards: GridContainer; display(rows: Array[Dictionary]) -> void |
| relationship_card / LifeCharacterRelationship | PanelContainer | portrait: LifeCharacterPortrait; title/points: Label; hearts: LifeHeartRow; display(row: Dictionary) -> void |

LifeCharacterFlow.configure(main: Node), open(), close(), refresh() -> void; panel: LifeCharacterSheet. Main child is CharacterScreen. Open requires a started game, no title/tutorial/sleep/day-end guard; UiCoordinator alone owns modal hold/input. Visibility/social.changed/locale refresh actual values. No profile/social state cached or saved. Close hides only; no direct talk/gift/quest/economy/simulation requests.

CharacterSnapshot.capture(main: Node) -> Dictionary: actual profile name/farm/normalized appearance, array of actual NPC rows{id,name_key,color,points,maximum}. No mutation; NpcSocialState/content/NpcData remain authoritative. CharacterPresenter.render(panel: LifeCharacterSheet, snapshot: Dictionary) -> void updates values. Five hearts floor the points/cap ratio; raw points/cap remain visible, no gameplay tiers or benefits implied. NPC portraits use catalogue recipes, same fallback color as NpcActor.

Tree: CharacterScreen VBox -> existing common_tabs, wood frame/paper -> HBox(identity card, VBox(skills panel, relationship list)), fixed Q/E/Escape hint. Left portrait expands, names wrap; right five unavailable skill rows and independently scrolling two-column NPC cards. Existing Theme variations only. UI-local avatars have no collision/camera/domain state. No Inspector/project-setting steps.

Existing common_tabs enables indices0/1/2 only. InventoryController.attach_main connects all three headers to show_tab; existing Q/E cycle Bag->Character->Quest, reverse wraps. J/B/I retain their original target. Native Tab/Space/Enter in Character remain GUI actions; world Q/E/Space never run. Calendar/Map stay disabled. No new InputMap action or hotkey. Day-end review keeps precedence; prior pause restores through UiCoordinator.

Manual F5: open Bag, Q/E/click through all three tabs, close/Escape/native focus; inspect actual names/all six player cosmetics/all NPC recipes and zero/partial/max friendship; talk via original nearby dialogue, reopen and compare actual points. No friendship is earned by looking. Check vi/en/three sizes/long names/scroll, title/new-game/load/old-save refresh and day-end/morning/pause compatibility. XP/levels/bonuses/birthdays/gifting remain unavailable; no save migration or fabricated statistics.

## Phase8.5h companion card and naming

Character public aliases remain; left ScrollContainer/VBox wraps original identity and new LifeDogCompanionCard. CharacterSnapshot adds detached dog{name,revision,maximum}; CharacterPresenter delegates card localization. Rename action opens Main.dog_name_flow (LifeDogNameFlow) only from active Character. Main child DogName is LifeDogNameSheet with separate LifeDogNameForm/native LineEdit/Save/Cancel, shared Theme. Main composes flow after dog runtime and before UiCoordinator. No new input or creation flow.

UiCoordinator owns modal/pause/focus/Esc; LineEdit keyboard entry/Tab/Enter stay native. Save requires captured revision and sole DogState command; max_length0 preserves overlong draft for explicit validation. Cancel/Back return to Character; close_active/new/load/title hide without opening another screen. Empty saved name renders DOG_UNNAMED in current locale. Manual F5/OS Vietnamese IME and human tone/art acceptance remain separate; automated native key events and fresh vi/en/three-size captures in PROGRESS.
